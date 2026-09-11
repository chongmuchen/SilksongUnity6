#!/usr/bin/env python3
"""Read-only, exhaustive HLSL token comparison for the Sprites/Lit refactor.

Requires git and clang. Unity includes remain opaque markers on both sides;
their placement, all declarations, macros, and arithmetic tokens are compared.
Only comments, whitespace, and the explicitly renamed interface identifiers are
normalized. This complements Unity compilation and GPU validation.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys


SHADER = "Assets/Shaders/Sprites-Lit.shader"
KEYWORDS = (
    "AMBIENT_LERP", "BLACKTHREAD", "COLOR_FLASH", "DITHERING_NOISE",
    "ETC1_EXTERNAL_ALPHA", "PIXELSNAP_ON", "SATURATION_LERP", "INSTANCING_ON",
)


def canonical_identifiers(source):
    for prefix, replacement in (("RV", "SpriteVertex"), ("RF", "SpriteFragment")):
        source = re.sub(prefix + r"_[a-f0-9]+_Input\b", replacement + "Input", source)
        source = re.sub(prefix + r"_[a-f0-9]+_Output\b", replacement + "Output", source)
    for old, new in (("POSITION0", "positionOS"), ("COLOR0", "color"),
                     ("TEXCOORD0", "uv"), ("SV_Target0", "color")):
        source = re.sub(r"\b" + old + r"(?=\s*:)", new, source)
        source = re.sub(r"\." + old + r"\b", "." + new, source)
    for old, new in (("mtl_Position", "positionCS"),
                     ("recovered_InstanceID", "instanceID"),
                     ("mtl_FragCoord", "positionSS"),
                     ("hlslcc_FragCoord", "fragmentCoord")):
        source = re.sub(r"\b" + old + r"\b", new, source)
    return source


def tokens(source):
    source = re.sub(r"//[^\n]*|/\*[\s\S]*?\*/", "", source)
    return re.findall(r"\w+|[^\s\w]", canonical_identifiers(source))


def split_program(source):
    if source.count("HLSLPROGRAM") != 1 or source.count("ENDHLSL") != 1:
        raise ValueError("Expected exactly one HLSLPROGRAM block in Sprites/Lit")
    prefix, tail = source.split("HLSLPROGRAM", 1)
    program, suffix = tail.split("ENDHLSL", 1)
    # Keep includes visible to the comparison without expanding Unity's library.
    program = re.sub(r'^\s*#include\s+([<"][^>"\n]+[>"])\s*$',
                     r"SHADER_READABILITY_INCLUDE(\1)", program, flags=re.MULTILINE)
    return prefix + "HLSLPROGRAM ENDHLSL" + suffix, program


def preprocess(program, keywords):
    command = ["clang", "-E", "-P", "-x", "c", "-"]
    command.extend("-D" + keyword + "=1" for keyword in keywords)
    result = subprocess.run(command, input=program, text=True, capture_output=True)
    if result.returncode:
        raise RuntimeError("clang preprocessing failed: " + result.stderr.strip())
    return tokens(result.stdout)


def first_difference(before, after):
    index = next((i for i, pair in enumerate(zip(before, after)) if pair[0] != pair[1]),
                 min(len(before), len(after)))
    return {"token_index": index, "baseline": before[max(0, index - 8):index + 12],
            "current": after[max(0, index - 8):index + 12]}


def compare(root, baseline):
    revision = subprocess.check_output(
        ["git", "rev-parse", "--verify", "--end-of-options", baseline + "^{commit}"],
        cwd=root, text=True).strip()
    old = subprocess.check_output(["git", "show", revision + ":" + SHADER],
                                  cwd=root, text=True)
    new = (root / SHADER).read_text()
    old_shell, old_program = split_program(old)
    new_shell, new_program = split_program(new)
    report = {
        "shader": SHADER, "baseline_revision": revision,
        "baseline_sha256": hashlib.sha256(old.encode()).hexdigest(),
        "current_sha256": hashlib.sha256(new.encode()).hexdigest(),
        "old_lines": len(old.splitlines()), "new_lines": len(new.splitlines()),
        "combinations_checked": 0, "keywords": list(KEYWORDS),
        "shaderlab_equal": tokens(old_shell) == tokens(new_shell),
        "comparison": "clang -E -P; includes retained as opaque markers",
        "normalization": "comments, whitespace, explicit struct/interface identifier renames",
        "scope": "declaration order, types, CBUFFER and Unity macros, arithmetic, and all 256 keyword selections",
        "limitations": "Unity includes are not expanded; this is not GPU or backend compilation validation",
        "mismatches": [],
    }
    digest = hashlib.sha256()
    for mask in range(1 << len(KEYWORDS)):
        keywords = [keyword for i, keyword in enumerate(KEYWORDS) if mask & (1 << i)]
        before, after = preprocess(old_program, keywords), preprocess(new_program, keywords)
        report["combinations_checked"] += 1
        if before != after:
            report["mismatches"].append({"keywords": keywords,
                                          "difference": first_difference(before, after)})
        digest.update((" ".join(after) + "\n").encode())
    report["canonical_combinations_sha256"] = digest.hexdigest()
    report["all_equal"] = report["shaderlab_equal"] and not report["mismatches"]
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", default="fd1bc3a6c", help="Baseline git revision")
    parser.add_argument("--output", type=Path, help="Optional JSON report path")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    try:
        report = compare(root, args.baseline)
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        report = {"shader": SHADER, "baseline": args.baseline, "all_equal": False,
                  "error": str(error)}
    serialized = json.dumps(report, indent=2, ensure_ascii=False) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(serialized)
    sys.stdout.write(serialized)
    return 0 if report["all_equal"] else 1


if __name__ == "__main__":
    sys.exit(main())
