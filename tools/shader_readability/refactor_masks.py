#!/usr/bin/env python3
"""Deduplicate four recovered mask shaders without changing any stage arithmetic.

The baseline's ordered branch selection is evaluated for every Boolean assignment,
including assignments outside pragma groups and the empty keyword set. Equivalent
stage programs share a body; exact truth tables determine their new conditions.
ShaderLab and pragma order are retained verbatim. Run check_masks.py afterward.
"""

import argparse
from collections import defaultdict
from functools import lru_cache
import json
from pathlib import Path
import re
import subprocess


SHADERS = (
    "Assets/Shader/Alpha Masked_Sprites Alpha Masked - World Coords.shader",
    "Assets/Shader/Alpha Masked_Unlit Alpha Masked - World Coords.shader",
    "Assets/Shaders/Sprites-TiledScrollingMasked.shader",
    "Assets/Shaders/Sprites-TiledMasked.shader",
)
DEFAULT_BASELINE = "fd1bc3a6c"


def canonical_identifiers(source, path):
    for prefix, replacement in (("RV", "MaskedVertex"), ("RF", "MaskedFragment")):
        source = re.sub(prefix + r"_[a-f0-9]+_Input\b", replacement + "Input", source)
        source = re.sub(prefix + r"_[a-f0-9]+_Output\b", replacement + "Output", source)
    fields = [("POSITION0", "positionOS"), ("COLOR0", "color"), ("SV_Target0", "color")]
    if "/Alpha Masked_" in path:
        fields += [("TEXCOORD0", "uv"), ("TEXCOORD1", "mainUv"), ("TEXCOORD2", "maskUv")]
    else:
        fields += [("TEXCOORD0", "spriteUv"), ("TEXCOORD1", "scrollUv"), ("TEXCOORD2", "heroMaskUv")]
    for old, new in fields:
        source = re.sub(r"\b" + old + r"(?=\s*:)", new, source)
        source = re.sub(r"\." + old + r"\b", "." + new, source)
    for old, new in (("mtl_Position", "positionCS"), ("recovered_InstanceID", "instanceID"),
                     ("mtl_FragCoord", "positionSS"), ("hlslcc_FragCoord", "fragmentCoord")):
        source = re.sub(r"\b" + old + r"\b", new, source)
    return source


def pragma_groups(program):
    """Return ordered groups; the first option of a forced group is significant."""
    groups = []
    for line in program.splitlines():
        parts = line.split()
        if len(parts) < 2 or parts[0] != "#pragma":
            continue
        if parts[1] == "multi_compile_instancing":
            groups.append([None, "INSTANCING_ON"])
        elif parts[1] == "multi_compile":
            groups.append([None if option in ("_", "__") else option for option in parts[2:]])
        elif parts[1].startswith(("multi_compile", "shader_feature")):
            raise ValueError("Unsupported variant pragma: " + line)
    return groups


def all_keywords(program):
    ordered = []
    for group in pragma_groups(program):
        for keyword in group:
            if keyword and keyword not in ordered:
                ordered.append(keyword)
    for keyword in re.findall(r"defined\((\w+)\)", program):
        if keyword not in ordered:
            ordered.append(keyword)
    return ordered


def resolve_revision(root, baseline):
    return subprocess.check_output(
        ["git", "rev-parse", "--verify", "--end-of-options", baseline + "^{commit}"],
        cwd=root, text=True).strip()


def baseline_source(root, revision, path):
    return subprocess.check_output(["git", "show", revision + ":" + path], cwd=root, text=True)


def parse_branches(program, path):
    start = program.index("#if ")
    end = program.rindex("#endif") + len("#endif")
    selection = program[start:end - len("#endif")]
    parts = re.split(r"(?m)^(#(?:if|elif|else)[^\n]*)\n", selection)[1:]
    branches = []
    for order, (condition, body) in enumerate(zip(parts[::2], parts[1::2])):
        sha = re.search(r"Original Metal program SHA256: vertex (\w+); fragment (\w+)", body)
        if not sha:
            raise ValueError("Expected recovered branch provenance: " + path)
        body = re.sub(r"\s*// Original Metal program SHA256:[^\n]*\n", "", body, count=1)
        if re.search(r"(?m)^#(?:if|elif|else|endif)", body):
            raise ValueError("Unexpected nested condition in recovered body: " + path)
        vertex_start, fragment_start = body.index("struct RV_"), body.index("struct RF_")
        vertex = canonical_identifiers(body[vertex_start:fragment_start], path).strip()
        fragment = canonical_identifiers(body[fragment_start:], path).strip()
        vertex_structs = re.findall(r"struct \w+\s*\{[^}]*\};", vertex)
        fragment_structs = re.findall(r"struct \w+\s*\{[^}]*\};", fragment)
        if len(vertex_structs) != 2 or len(fragment_structs) != 2:
            raise ValueError("Unexpected interface declarations: " + path)
        branches.append({
            "order": order, "condition": condition, "header": body[:vertex_start].strip(),
            "vertex_input": vertex_structs[0], "vertex_output": vertex_structs[1],
            "vertex": vertex[vertex.index("MaskedVertexOutput RecoveryVertex("):],
            "fragment_input": fragment_structs[0], "fragment_output": fragment_structs[1],
            "fragment": fragment[fragment.index("MaskedFragmentOutput RecoveryFragment("):],
            "vertex_sha": sha[1], "fragment_sha": sha[2],
        })
    return program[:start], program[end:], branches


class TruthTable:
    def __init__(self, keywords, branches):
        self.keywords = keywords
        self.universe = frozenset(range(1 << len(keywords)))
        self.selection = {}
        evaluators = []
        for branch in branches:
            condition = re.sub(r"^#(?:if|elif)\s+", "", branch["condition"])
            if condition == "#else":
                condition = "True"
            else:
                if re.sub(r"defined\(\w+\)|[!&|()\s]", "", condition):
                    raise ValueError("Unsupported recovered keyword expression: " + condition)
                condition = re.sub(r"defined\((\w+)\)", lambda m: "k[" + str(keywords.index(m[1])) + "]", condition)
                condition = condition.replace("&&", " and ").replace("||", " or ").replace("!", " not ")
            evaluators.append(compile(condition.strip(), "<shader-condition>", "eval"))
        for mask in self.universe:
            values = [bool(mask & (1 << index)) for index in range(len(keywords))]
            for branch, code in zip(branches, evaluators):
                if eval(code, {"__builtins__": {}}, {"k": values}):
                    self.selection[mask] = branch
                    break
            if mask not in self.selection:
                raise ValueError("Baseline has no selected program for mask " + str(mask))

    @lru_cache(maxsize=None)
    def condition(self, members):
        """Merge only exact cubes; unreachable pragma combinations are not don't-cares."""
        if members == self.universe:
            return None
        if not members:
            raise ValueError("Cannot emit an unreachable program group")
        level = {(len(self.universe) - 1, n) for n in members}
        primes = set()
        while level:
            consumed, next_level = set(), set()
            for mask, bits in level:
                for index in range(len(self.keywords)):
                    bit = 1 << index
                    if mask & bit and (mask, bits ^ bit) in level:
                        consumed.add((mask, bits))
                        next_level.add((mask ^ bit, bits & ~bit))
            primes |= level - consumed
            level = next_level
        cover = {p: {n for n in self.universe if n & p[0] == p[1]} for p in primes}
        if not all(values <= members for values in cover.values()):
            raise ValueError("Boolean minimization escaped the exact truth table")
        remaining, selected = set(members), []
        while remaining:
            pick = min(cover, key=lambda p: (-len(cover[p] & remaining), bin(p[0]).count("1"), p))
            if not cover[pick] & remaining:
                raise ValueError("Incomplete truth table coverage")
            selected.append(pick)
            remaining -= cover[pick]
        terms = []
        for mask, bits in sorted(selected):
            terms.append(" && ".join(("" if bits & (1 << i) else "!") + "defined(" + keyword + ")"
                                     for i, keyword in enumerate(self.keywords) if mask & (1 << i)))
        return " || ".join("(" + term + ")" for term in terms) if len(terms) > 1 else terms[0]


def shared_header(table):
    sequences = {mask: [line.rstrip() for line in branch["header"].splitlines() if line.strip()]
                 for mask, branch in table.selection.items()}
    nodes, edges, indegree = [], defaultdict(set), defaultdict(int)
    for sequence in sequences.values():
        if len(sequence) != len(set(sequence)):
            raise ValueError("Repeated header lines require a more specific declaration parser")
        for line in sequence:
            if line not in nodes:
                nodes.append(line)
        for before, after in zip(sequence, sequence[1:]):
            if after not in edges[before]:
                edges[before].add(after)
                indegree[after] += 1
    ordered = []
    while len(ordered) < len(nodes):
        ready = [line for line in nodes if line not in ordered and indegree[line] == 0]
        if not ready:
            raise ValueError("Baseline declaration orders cannot share a single sequence")
        line = ready[0]
        ordered.append(line)
        for target in edges[line]:
            indegree[target] -= 1
    runs = []
    for line in ordered:
        members = frozenset(mask for mask, sequence in sequences.items() if line in sequence)
        if runs and runs[-1][0] == members:
            runs[-1][1].append(line)
        else:
            runs.append((members, [line]))
    output = []
    for members, lines in runs:
        condition = table.condition(members)
        if condition:
            output.append("#if " + condition)
        output.extend(lines)
        if condition:
            output.append("#endif")
        output.append("")
    return "\n".join(output)


def shared_stage(table, branches, field, provenance=None):
    # Preserve first appearance in the original ordered branch chain.
    groups = {}
    for branch in branches:
        groups.setdefault(branch[field], {"members": set(), "hashes": set()})
        if provenance:
            groups[branch[field]]["hashes"].add(branch[provenance])
    for mask, branch in table.selection.items():
        groups[branch[field]]["members"].add(mask)
    output = []
    for body, group in groups.items():
        condition = table.condition(frozenset(group["members"]))
        if condition:
            output.append("#if " + condition)
        if provenance:
            output.append("// Captured " + provenance.split("_")[0] + " program SHA256:")
            output.extend("// " + sha for sha in sorted(group["hashes"]))
        output.append(body)
        if condition:
            output.append("#endif")
        output.append("")
    return "\n".join(output), len(groups)


def refactor(source, path):
    if source.count("HLSLPROGRAM") != 1 or source.count("ENDHLSL") != 1:
        raise ValueError("Expected one recovered HLSLPROGRAM in " + path)
    shell, rest = source.split("HLSLPROGRAM", 1)
    program, tail = rest.split("ENDHLSL", 1)
    prefix, suffix, branches = parse_branches(program, path)
    keywords = all_keywords(program)
    table = TruthTable(keywords, branches)
    sections, counts = {}, {}
    for field in ("vertex_input", "vertex_output", "vertex", "fragment_input", "fragment_output", "fragment"):
        provenance = field + "_sha" if field in ("vertex", "fragment") else None
        sections[field], counts[field] = shared_stage(table, branches, field, provenance)
    notes = "\n".join([
        "// Shared declarations and independent stage selection preserve the recovered programs.",
        "// Keep pragma option order, especially forced DUMMY/axis groups and their defaults.",
        "// Conditions preserve the original first-matching branch, including extra keyword",
        "// combinations and an empty keyword set; features must not be independently stacked.",
        "// Float precision, declaration/CBUFFER layout, sampling and arithmetic remain unchanged.",
        "// Reproduce with tools/shader_readability/refactor_masks.py; verify with check_masks.py.",
        "", "// Material and per-renderer data.",
    ])
    body = prefix + notes + "\n" + shared_header(table)
    body += "\n// Vertex interface.\n" + sections["vertex_input"] + "\n" + sections["vertex_output"]
    body += "\n// Vertex programs, shared across fragment variants.\n" + sections["vertex"]
    body += "\n// Fragment interface.\n" + sections["fragment_input"] + "\n" + sections["fragment_output"]
    body += "\n// Fragment programs, shared across vertex variants.\n" + sections["fragment"] + suffix
    shell = shell.replace("// Generated by tools/shader_reconstruction/shaderlab_generator.py.",
                          "// Initial recovery: tools/shader_reconstruction/shaderlab_generator.py.")
    result = shell + "HLSLPROGRAM" + body + "ENDHLSL" + tail
    return result, {"path": path, "old_lines": len(source.splitlines()), "new_lines": len(result.splitlines()),
                    "original_combined_branches": len(branches), "unique_vertex_bodies": counts["vertex"],
                    "unique_fragment_bodies": counts["fragment"], "keyword_order": keywords,
                    "pragma_groups": pragma_groups(program), "boolean_assignments": len(table.universe)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", default=DEFAULT_BASELINE)
    parser.add_argument("--output", type=Path, help="Optional generation statistics JSON")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[2]
    revision = resolve_revision(root, args.baseline)
    pending, rows = [], []
    for path in SHADERS:
        source = baseline_source(root, revision, path)
        result, row = refactor(source, path)
        if (root / path).read_text() not in (source, result):
            raise ValueError("Refusing to overwrite edits outside this transformation: " + path)
        pending.append((root / path, result))
        rows.append(row)
    for path, result in pending:
        if path.read_text() != result:
            path.write_text(result)
    report = {"baseline_revision": revision, "shaders": rows}
    serialized = json.dumps(report, indent=2) + "\n"
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(serialized)
    print(serialized, end="")


if __name__ == "__main__":
    main()
