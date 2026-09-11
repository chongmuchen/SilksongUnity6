#!/usr/bin/env python3
"""Verify final report coverage and source hashes before saving a compact audit."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import re
import subprocess

PROJECT = Path(__file__).resolve().parents[2]


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--work", type=Path, default=Path("/private/tmp/shader-readability-validation"))
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    root = args.work / "batch-validation"
    load = lambda path: json.loads(path.read_text())
    manifest_path = root / "candidate-manifest.json"
    manifest = load(manifest_path)
    gpu_path = root / "results/gpu-verified.json"
    grab_path = root / "results/grab-verified.json"
    compiled_path = root / "results/compiled.json"
    gpu, grab, compiled = map(load, (gpu_path, grab_path, compiled_path))
    batch = manifest.get("batch", "first")
    static_paths = [args.work / name for name in
                   (("lit-static.json", "ui-static.json") if batch == "first" else
                    ("masks-static.json", "tmp-static.json", "scroll-water-static.json"))]
    inputs = load(root / "input.json")["shaders"]
    grab_inputs = load(root / "input-grab.json")["shaders"]
    source_paths = {entry["path"] for entry in manifest["shaders"]}
    wrappers = {entry["path"]: entry for entry in manifest.get("subshaderWrappers", [])}
    assert len(inputs) == len(source_paths) + len(wrappers)
    assert {row["path"] for row in inputs} == source_paths | wrappers.keys()
    assert grab_inputs == [row for row in inputs if row["grabCount"]]
    requested_by_source = {path: 0 for path in source_paths}
    for row in inputs:
        source = wrappers[row["path"]]["sourcePath"] if row["path"] in wrappers else row["path"]
        assert all(p["subshader"] == 0 for p in row["passes"])
        requested_by_source[source] += sum(len(p["variants"]) for p in row["passes"])
    for entry in manifest["shaders"]:
        assert sha(PROJECT / entry["path"]) == entry["candidateSha256"], entry["path"]
        assert sha(root / entry["path"]) == entry["candidateSha256"], entry["path"]
        assert requested_by_source[entry["path"]] == entry["variants"], entry["path"]
        original = subprocess.check_output(["git", "show", f'{manifest["baseline"]}:{entry["path"]}'], cwd=PROJECT)
        assert hashlib.sha256(original).hexdigest() == entry["baselineSha256"], entry["path"]
        label = hashlib.sha256(entry["path"].encode()).hexdigest()[:16]
        renamed = re.sub(r'Shader\s+"[^"]+"', f'Shader "ReadabilityBaseline/{label}"', original.decode(), count=1)
        baseline_file = root / "Assets/ReadabilityBaseline" / entry["path"].removeprefix("Assets/")
        assert baseline_file.read_bytes() == renamed.encode(), entry["path"]
        meta = entry["path"] + ".meta"
        original_meta = subprocess.check_output(["git", "show", f'{manifest["baseline"]}:{meta}'], cwd=PROJECT)
        assert (PROJECT / meta).read_bytes() == (root / meta).read_bytes() == original_meta, meta
    for entry in manifest["includes"]:
        assert sha(PROJECT / entry["path"]) == sha(root / entry["path"]) == entry["sha256"], entry["path"]
    for entry in manifest.get("subshaderWrappers", []):
        assert sha(root / entry["path"]) == entry["candidateSha256"], entry["path"]
        assert sha(root / "Assets/ReadabilityBaseline" / entry["path"].removeprefix("Assets/")) == entry["baselineSha256"]
    for report in (gpu, grab):
        assert report["passed"] and not report["failure"]
        assert report["comparisonReference"] == "Git baseline"
        assert report["baselineRevision"] == manifest["baseline"]
        assert report["candidateManifestSha256"] == sha(manifest_path)
    gpu_rows = {s["path"]: s for s in gpu["shaders"]}
    expected_gpu = {(s["path"], p["ordinal"] if gpu_rows[s["path"]]["candidatePassCount"] == s["renderPassCount"] else p["index"],
                     tuple(v["keywords"]), profile)
                    for s in inputs for p in s["passes"] if p["subshader"] == 0 for v in p["variants"] for profile in range(2)}
    observed_gpu = [(s["path"], c["pass"], tuple(c["keywords"].split()), c["profile"])
                    for s in gpu["shaders"] for c in s["cases"]]
    assert len(observed_gpu) == len(expected_gpu) and set(observed_gpu) == expected_gpu
    candidate_hashes = {s["path"]: s["candidateSha256"] for s in manifest["shaders"]}
    candidate_hashes.update({s["path"]: s["candidateSha256"] for s in manifest.get("subshaderWrappers", [])})
    for row in gpu["shaders"]:
        assert row["candidateSha256"] == candidate_hashes[row["path"]]
        assert row["candidateEntity"] != row["referenceEntity"]
    expected_grab = {(s["path"], tuple(sorted(k for k in v["keywords"] if k != "INSTANCING_ON")), profile)
                     for s in grab_inputs for p in s["passes"] if p["subshader"] == 0 for v in p["variants"] for profile in range(2)}
    observed_grab = [(s["path"], tuple(c["keywords"].split()), c["profile"])
                     for s in grab["shaders"] for c in s["cases"]]
    assert len(observed_grab) == len(expected_grab) and set(observed_grab) == expected_grab
    expected_stages = {(s["path"], p["subshader"], p["ordinal"], tuple(v["keywords"]), stage)
                       for s in inputs for p in s["passes"] if p["subshader"] == 0 for v in p["variants"] for stage in ("Vertex", "Fragment")}
    observed_stages = [(s["path"], s["subshader"], s["passOrdinal"], tuple(s["keywords"]), s["stage"]) for s in compiled["comparisons"]]
    assert len(observed_stages) == len(expected_stages) and set(observed_stages) == expected_stages
    assert compiled["allCompilesSucceeded"] and compiled["sourceMetricsIdenticalCount"] == len(expected_stages)
    assert compiled["candidateManifestSha256"] == sha(manifest_path)
    assert compiled["baselineRevision"] == manifest["baseline"]
    assert sha(root / "Assets/Editor/ShaderCompileComparison.cs") == sha(PROJECT / "tools/shader_readability/ShaderCompileComparison.cs")
    assert all(c["textureBindingsIdentical"] and c["constantBuffersIdentical"] for c in compiled["comparisons"])
    if batch == "first":
        lit, ui = map(load, static_paths)
        assert lit["all_equal"] and lit["combinations_checked"] == 256
        assert lit["current_sha256"] == candidate_hashes[lit["shader"]]
        assert ui["passed"] and ui["branch_count"] == 86
        for path, digest in {**ui["shader_sha256"], **ui["include_sha256"]}.items():
            assert sha(PROJECT / path) == digest, path
        static_summary = {"litKeywordCombinationsEqual": 256, "uiFragmentExpressionTreesEqual": 86}
    else:
        masks, tmp, scroll_water = map(load, static_paths)
        assert masks["passed"] and masks["requested_keyword_sets_checked"] == 530
        assert masks["boolean_assignments_checked"] == 912 and masks["pragma_combinations_checked"] == 528
        for row in masks["shaders"]:
            assert row["passed"] and row["current_sha256"] == candidate_hashes[row["path"]]
        assert tmp["passed"] and tmp["case_count"] == 48
        for path, digest in {**tmp["shader_sha256"], **tmp["include_sha256"]}.items():
            assert sha(PROJECT / path) == digest, path
        assert scroll_water["passed"] and scroll_water["scrollDeclaredCombinations"] == 32
        assert scroll_water["scrollKeywordMasks"] == 64 and scroll_water["fragmentExpressionComparisons"] == 3
        for path, row in scroll_water["shaders"].items():
            assert row["candidateSha256"] == candidate_hashes[path]
        static_summary = {"maskBooleanAssignmentsEqual": masks["boolean_assignments_checked"],
                          "maskKeywordRequestsEqual": 530, "tmpKeywordCombinationsEqual": 48,
                          "scrollKeywordMasksEqual": 64, "waterAndCameraFragmentExpressionTreesEqual": 3}
    static_summary["shaderlabPragmasAndShaderMetasPreserved"] = True
    gpu_cases = [c for s in gpu["shaders"] for c in s["cases"]]
    grab_cases = [c for s in grab["shaders"] for c in s["cases"]]
    baseline_lines = sum(s["baselineLines"] for s in manifest["shaders"])
    current_lines = sum(s["candidateLines"] for s in manifest["shaders"]) + sum(len((PROJECT / s["path"]).read_text().splitlines()) for s in manifest["includes"])
    summary = {
        "generatedAt": datetime.now(timezone.utc).isoformat(),
        "baselineRevision": manifest["baseline"],
        "environment": {k: gpu[k] for k in ("unity", "device", "colorSpace")},
        "batch": batch, "shaderCount": len(manifest["shaders"]), "testAssetCount": len(inputs),
        "includeCount": len(manifest["includes"]),
        "sourceLines": {"baseline": baseline_lines, "readableIncludingSharedFiles": current_lines},
        "gpu": {"reference": "Git baseline", "variants": len(expected_gpu) // 2,
                "cases": len(gpu_cases), "maxDifference": max(c["maxDifference"] for c in gpu_cases), "passed": True},
        "grabPass": {"shaders": len(grab_inputs), "cases": len(grab_cases),
                     "maxDifference": max(c["maxDifference"] for c in grab_cases), "passed": True},
        "compiled": {"stageComparisons": len(expected_stages), "compileFailures": compiled["compileFailures"],
                     "rawBytesIdentical": compiled["rawIdenticalCount"],
                     "fragmentStages": sum(c["stage"] == "Fragment" for c in compiled["comparisons"]),
                     "fragmentRawBytesIdentical": sum(c["stage"] == "Fragment" and c["rawBytesIdentical"] for c in compiled["comparisons"]),
                     "litRawBytesIdentical": sum(c["path"].endswith("/Sprites-Lit.shader") and c["rawBytesIdentical"] for c in compiled["comparisons"]),
                     "metalSourceMetricsIdentical": compiled["sourceMetricsIdenticalCount"], "resourceBindingsIdentical": True},
        "static": static_summary,
        "limits": ["Two synthetic input profiles on the recorded Metal/Gamma environment; not all scenes or graphics backends.",
                   "Compiled source syntax counts are not measured GPU timings or hardware instruction counts.",
                   "Unity matrix helpers can change floating-point accumulation order; measured image differences are reported above."],
        "candidateManifestSha256": sha(manifest_path),
        "evidence": {str(p.relative_to(args.work)): sha(p) for p in
                     (gpu_path, grab_path, compiled_path, root / "input.json", root / "input-grab.json", *static_paths)},
        "tools": {str(p.relative_to(PROJECT)): sha(p) for p in Path(__file__).parent.iterdir() if p.suffix in (".py", ".cs")},
        "shaders": manifest["shaders"], "includes": manifest["includes"],
        "subshaderWrappers": manifest.get("subshaderWrappers", []),
    }
    if args.output is None:
        args.output = PROJECT / "Docs/ShaderRecovery" / ("readability-validation.json" if batch == "first" else "readability-second-validation.json")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(summary, indent=2, ensure_ascii=False) + "\n")
    print(json.dumps({"report": str(args.output), **{k: summary[k] for k in ("sourceLines", "gpu", "grabPass", "compiled")}}, indent=2))


if __name__ == "__main__":
    main()
