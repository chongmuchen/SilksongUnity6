#!/usr/bin/env python3
"""Read-only exhaustive token comparison of the four mask shader refactors.

Every Boolean assignment is checked, a strict superset of pragma-reachable variants.
The empty keyword set and the first-option defaults of forced groups are reported
explicitly. Unity compilation/GPU tests are still needed for backend validation.
"""

import argparse
from concurrent.futures import ThreadPoolExecutor
import hashlib
import itertools
import json
from pathlib import Path
import re
import subprocess
import sys

sys.dont_write_bytecode = True
from refactor_masks import (SHADERS, DEFAULT_BASELINE, all_keywords, baseline_source,
                            canonical_identifiers, pragma_groups, resolve_revision)


def tokens(source, path):
    source = re.sub(r"//[^\n]*|/\*[\s\S]*?\*/", "", source)
    return re.findall(r"\w+|[^\s\w]", canonical_identifiers(source, path))


def split_program(source):
    if source.count("HLSLPROGRAM") != 1 or source.count("ENDHLSL") != 1:
        raise ValueError("Expected exactly one HLSLPROGRAM block")
    prefix, rest = source.split("HLSLPROGRAM", 1)
    program, suffix = rest.split("ENDHLSL", 1)
    program = re.sub(r'^\s*#include\s+([<"][^>"\n]+[>"])\s*$',
                     r"SHADER_READABILITY_INCLUDE(\1)", program, flags=re.MULTILINE)
    return prefix + "HLSLPROGRAM ENDHLSL" + suffix, program


def preprocess(program, keywords, path):
    command = ["clang", "-E", "-P", "-x", "c", "-"]
    command.extend("-D" + keyword + "=1" for keyword in keywords)
    result = subprocess.run(command, input=program, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError("clang preprocessing failed: " + result.stderr.strip())
    return tokens(result.stdout, path)


def first_difference(before, after):
    index = next((i for i, pair in enumerate(zip(before, after)) if pair[0] != pair[1]),
                 min(len(before), len(after)))
    return {"token_index": index, "baseline": before[max(0, index - 8):index + 12],
            "current": after[max(0, index - 8):index + 12]}


def check_shader(root, revision, path):
    old = baseline_source(root, revision, path)
    new = (root / path).read_text()
    old_shell, old_program = split_program(old)
    new_shell, new_program = split_program(new)
    keywords = all_keywords(old_program)
    if not set(all_keywords(new_program)) <= set(keywords):
        raise ValueError("Refactor introduced unvalidated keywords: " + path)
    groups = pragma_groups(old_program)
    default_keywords = [group[0] for group in groups if group[0]]
    reachable = {frozenset(k for k in combination if k) for combination in itertools.product(*groups)}
    pragma_lines = re.findall(r"(?m)^#pragma[^\n]*", old_program)
    report = {
        "path": path, "old_lines": len(old.splitlines()), "new_lines": len(new.splitlines()),
        "baseline_sha256": hashlib.sha256(old.encode()).hexdigest(),
        "current_sha256": hashlib.sha256(new.encode()).hexdigest(),
        "keyword_order": keywords, "pragma_groups": groups,
        "pragma_order_equal": groups == pragma_groups(new_program),
        "pragma_lines_equal": pragma_lines == re.findall(r"(?m)^#pragma[^\n]*", new_program),
        "shaderlab_equal": tokens(old_shell, path) == tokens(new_shell, path),
        "pragma_combinations": len(reachable), "pragma_combinations_checked": 0,
        "boolean_assignments_checked": 0, "empty_keyword_equal": False,
        "forced_group_default_keywords": default_keywords,
        "forced_group_default_equal": False, "mismatches": [],
    }

    def compare(mask):
        enabled = [keyword for i, keyword in enumerate(keywords) if mask & (1 << i)]
        before = preprocess(old_program, enabled, path)
        after = preprocess(new_program, enabled, path)
        return enabled, before, after

    digest = hashlib.sha256()
    # Four independent preprocessor pairs run at a time; iteration stays deterministic.
    with ThreadPoolExecutor(max_workers=4) as pool:
        for enabled, before, after in pool.map(compare, range(1 << len(keywords))):
            report["boolean_assignments_checked"] += 1
            if frozenset(enabled) in reachable:
                report["pragma_combinations_checked"] += 1
            equal = before == after
            if not enabled:
                report["empty_keyword_equal"] = equal
            if set(enabled) == set(default_keywords):
                report["forced_group_default_equal"] = equal
            if not equal:
                report["mismatches"].append({"keywords": enabled, "difference": first_difference(before, after)})
            digest.update((json.dumps(enabled) + "\n" + " ".join(after) + "\n").encode())
    report["canonical_combinations_sha256"] = digest.hexdigest()
    report["all_equal"] = (report["pragma_order_equal"] and report["shaderlab_equal"]
                           and report["pragma_lines_equal"]
                           and report["empty_keyword_equal"] and report["forced_group_default_equal"]
                           and report["pragma_combinations_checked"] == report["pragma_combinations"]
                           and not report["mismatches"])
    report["passed"] = report["all_equal"]
    report["passes"] = [{
        "subshader": 0, "render_pass_ordinal": 0, "pragma_lines": pragma_lines,
        "pragma_combinations": len(reachable),
        "pragma_combinations_checked": report["pragma_combinations_checked"],
        "requested_keyword_sets_checked": len(reachable | {frozenset()}),
        "boolean_assignments_checked": report["boolean_assignments_checked"],
        "empty_keyword_set": [], "empty_keyword_checked": True,
        "empty_keyword_equal": report["empty_keyword_equal"],
        "forced_group_default_keywords": default_keywords,
        "forced_group_default_equal": report["forced_group_default_equal"],
        "passed": report["passed"],
    }]
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", default=DEFAULT_BASELINE)
    parser.add_argument("--output", type=Path, help="Optional JSON report path")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    report = {
        "baseline": args.baseline,
        "comparison": "clang -E -P; includes retained as opaque markers",
        "normalization": "comments, whitespace, explicit mask struct/interface identifier renames",
        "scope": "ShaderLab, pragma order, declaration/CBUFFER/macro order, and every HLSL arithmetic token for every Boolean assignment",
        "limitations": "Unity library includes are not expanded; raw empty keywords and forced-group defaults are both checked, but Unity selection still needs runtime validation",
        "shaders": [], "all_equal": False, "passed": False,
    }
    try:
        revision = resolve_revision(root, args.baseline)
        report["baseline_revision"] = revision
        for path in SHADERS:
            row = check_shader(root, revision, path)
            report["shaders"].append(row)
            print("Checked " + path + ": " + str(row["boolean_assignments_checked"]) +
                  " Boolean assignments; equal=" + str(row["all_equal"]), file=sys.stderr)
        report["all_equal"] = all(row["all_equal"] for row in report["shaders"])
        report["passed"] = report["all_equal"]
        report["boolean_assignments_checked"] = sum(row["boolean_assignments_checked"] for row in report["shaders"])
        report["pragma_combinations_checked"] = sum(row["pragma_combinations_checked"] for row in report["shaders"])
        report["requested_keyword_sets_checked"] = sum(p["requested_keyword_sets_checked"] for row in report["shaders"] for p in row["passes"])
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        report["error"] = str(error)
    serialized = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(serialized)
    sys.stdout.write(serialized)
    return 0 if report["all_equal"] else 1


if __name__ == "__main__":
    sys.exit(main())
