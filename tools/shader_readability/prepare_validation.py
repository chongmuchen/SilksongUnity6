#!/usr/bin/env python3
"""Prepare an isolated Unity project comparing readable shaders with a Git baseline.

Reuses the recovery fixtures without changing SilksongSource or the game project.
Run Unity separately; this script never launches the editor or overwrites old reports.
"""
import argparse
import copy
import hashlib
import itertools
import json
from pathlib import Path
import re
import shutil
import subprocess

PROJECT = Path(__file__).resolve().parents[2]
TARGETS = [
    "Assets/Shaders/Cherry-Sprites-Default.shader",
    "Assets/Shaders/Sprites-Lit.shader",
    "Assets/Shaders/Noise.shader",
    "Assets/Shader/Unlit_Noise New.shader",
]
SECOND_TARGETS = [
    "Assets/Shader/Alpha Masked_Sprites Alpha Masked - World Coords.shader",
    "Assets/Shader/Alpha Masked_Unlit Alpha Masked - World Coords.shader",
    "Assets/Shaders/Sprites-TiledScrollingMasked.shader",
    "Assets/Shaders/Sprites-TiledMasked.shader",
    "Assets/Shaders/Water.shader",
    "Assets/Shaders/ScrollTexture.shader",
    "Assets/Shader/Sprites_CameraScrollingSpriteTexture.shader",
    "Assets/Resources/shaders/tmpro_sdf.shader",
    "Assets/Resources/shaders/tmpro_sdf-mobile.shader",
]


def baseline_text(revision, path):
    return subprocess.check_output(["git", "show", f"{revision}:{path}"], cwd=PROJECT).decode()


def keyword_combinations(program, include_default=False):
    groups = []
    for line in re.findall(r"^\s*#pragma\s+(.+)$", program, re.M):
        words = line.split()
        if words[0] == "multi_compile_instancing":
            groups.append([[], ["INSTANCING_ON"]])
        elif words[0].startswith("multi_compile"):
            groups.append([[] if word in ("_", "__") else [word] for word in words[1:]])
    variants = [{"keywords": sorted(sum(combination, []))}
                for combination in itertools.product(*groups)]
    if include_default and not any(not v["keywords"] for v in variants):
        variants.append({"keywords": []})
    return variants


def isolate_subshader(text, index, name):
    """Keep the original properties, one complete SubShader, and the fallback."""
    neutral = re.sub(r'"(?:\\.|[^"\\])*"|//[^\n]*|/\*[\s\S]*?\*/',
                     lambda m: " " * len(m[0]), text)
    blocks = []
    for match in re.finditer(r"\bSubShader\s*\{", neutral):
        start = match.start()
        end = neutral.index("{", start) + 1
        depth = 1
        while depth:
            depth += (neutral[end] == "{") - (neutral[end] == "}")
            end += 1
        blocks.append((start, end))
    start, end = blocks[index]
    isolated = text[:blocks[0][0]] + text[start:end] + text[blocks[-1][1]:]
    return re.sub(r'Shader\s+"[^"]+"', f'Shader "{name}"', isolated, count=1)


def local_includes(paths):
    """Collect the transitive local includes used by this batch, excluding Unity's library."""
    found = set()
    pending = [PROJECT / path for path in paths]
    while pending:
        source = pending.pop()
        for include in re.findall(r'#include\s+"([^"\n]+)"', source.read_text()):
            candidate = PROJECT / include if include.startswith("Assets/") else source.parent / include
            if candidate.is_file() and candidate not in found:
                candidate = candidate.resolve()
                candidate.relative_to(PROJECT)
                found.add(candidate)
                pending.append(candidate)
    return sorted(found)


def shell(text):
    text = re.sub(r"HLSLPROGRAM.*?ENDHLSL", "HLSLPROGRAM ENDHLSL", text, flags=re.S)
    return re.sub(r"\s+", "", re.sub(r"//[^\n]*", "", text))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=PROJECT.parent / "SilksongSource")
    parser.add_argument("--work", type=Path, default=Path("/private/tmp/shader-readability-validation"))
    parser.add_argument("--baseline", default="fd1bc3a6c")
    parser.add_argument("--batch", choices=("first", "second"), default="first")
    args = parser.parse_args()
    revision = subprocess.check_output(["git", "rev-parse", "--verify", "--end-of-options", args.baseline + "^{commit}"], cwd=PROJECT, text=True).strip()
    work = args.work.resolve()
    work.mkdir(parents=True, exist_ok=True)
    marker = work / "readability-workspace.json"
    if any(work.iterdir()) and not marker.exists():
        raise SystemExit("Refusing to use a nonempty directory without a readability workspace marker")
    if marker.exists():
        previous = json.loads(marker.read_text())
        if previous.get("batch", "first") != args.batch or previous["project"] != str(PROJECT):
            raise SystemExit("Use a different --work directory for a different batch/project")
    marker.write_text(json.dumps({"project": str(PROJECT), "baseline": revision, "batch": args.batch}, indent=2) + "\n")
    target = work / "batch-validation"
    fixtures = args.source / "batch-validation"
    for directory in ["Assets/Editor", "results", "references", "Packages", "ProjectSettings"]:
        (target / directory).mkdir(parents=True, exist_ok=True)
    for directory in ["Packages", "ProjectSettings"]:
        shutil.copytree(fixtures / directory, target / directory, dirs_exist_ok=True)
    shutil.copy2(fixtures / "references/original-shaders.bundle", target / "references/original-shaders.bundle")
    if args.batch == "first":
        paths = TARGETS + sorted(str(p.relative_to(PROJECT)) for p in (PROJECT / "Assets/GUIBlendModes/Shaders").rglob("*.shader"))
    else:
        paths = SECOND_TARGETS + sorted(str(p.relative_to(PROJECT)) for pattern in
            ("TextMeshPro_Distance Field*.shader", "TextMeshPro_Mobile_Distance Field*.shader")
            for p in (PROJECT / "Assets/Shader").glob(pattern))
    native = {s["path"]: s for s in json.loads((fixtures / "input.json").read_text())["shaders"]}
    grabs = {s["path"]: s for s in json.loads((args.source / "grab-validation/input.json").read_text())["shaders"]}
    rows, manifest, wrappers = [], [], []
    for path in paths:
        original = baseline_text(revision, path)
        current = (PROJECT / path).read_text()
        if shell(original) != shell(current):
            raise SystemExit(f"ShaderLab properties/render states changed: {path}")
        def pragmas(text):
            return [re.sub(r"^(vertex|fragment)\s+\w+$", r"\1 ENTRYPOINT", p.strip())
                    for p in re.findall(r"#pragma\s+([^\n]+)", text)]
        if pragmas(original) != pragmas(current):
            raise SystemExit(f"Pragmas changed: {path}")
        if subprocess.check_output(["git", "show", f"{revision}:{path}.meta"], cwd=PROJECT) != (PROJECT / (path + ".meta")).read_bytes():
            raise SystemExit(f"Shader GUID/meta changed: {path}")
        dest = target / path
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(PROJECT / path, dest)
        shutil.copy2(PROJECT / (path + ".meta"), str(dest) + ".meta")
        before = target / "Assets/ReadabilityBaseline" / path.removeprefix("Assets/")
        before.parent.mkdir(parents=True, exist_ok=True)
        baseline_shader = re.sub(r'Shader\s+"[^"]+"', 'Shader "ReadabilityBaseline/' + hashlib.sha256(path.encode()).hexdigest()[:16] + '"', original, count=1)
        before.write_text(baseline_shader)
        row = copy.deepcopy(native[path])
        programs = re.findall(r"HLSLPROGRAM(.*?)ENDHLSL", original, re.S)
        if len(programs) != len(row["passes"]):
            raise SystemExit(f"Unexpected program/pass count: {path}")
        for program, shader_pass in zip(programs, row["passes"]):
            shader_pass["variants"] = keyword_combinations(program, include_default=args.batch == "second")
        row["grabNames"] = grabs.get(path, {}).get("grabNames", [])
        row["grabCount"] = grabs.get(path, {}).get("grabCount", 0)
        all_passes = row["passes"]
        row["passes"] = [p for p in all_passes if p["subshader"] == 0]
        rows.append(row)
        # Force inactive SubShaders into separate assets so the GPU actually runs them.
        for subshader in sorted({p["subshader"] for p in all_passes} - {0}):
            wrapper_path = f"Assets/ReadabilitySubshaders/{Path(path).stem}-sub{subshader}.shader"
            label = hashlib.sha256(wrapper_path.encode()).hexdigest()[:16]
            current_wrapper = isolate_subshader(current, subshader, "ReadabilitySubshader/" + label)
            old_wrapper = isolate_subshader(original, subshader, "ReadabilityBaselineSubshader/" + label)
            for wrapper, data in ((target / wrapper_path, current_wrapper),
                    (target / "Assets/ReadabilityBaseline" / wrapper_path.removeprefix("Assets/"), old_wrapper)):
                wrapper.parent.mkdir(parents=True, exist_ok=True)
                wrapper.write_text(data)
            wrapper_row = copy.deepcopy(row)
            wrapper_row.update(path=wrapper_path, name="ReadabilitySubshader/" + label, grabNames=[], grabCount=0)
            wrapper_row["passes"] = [copy.deepcopy(p) for p in all_passes if p["subshader"] == subshader]
            for p in wrapper_row["passes"]:
                p["subshader"] = 0
            wrapper_row["renderPassCount"] = len(wrapper_row["passes"])
            wrapper_row["serializedPassCount"] = len(wrapper_row["passes"])
            # The isolated fallback pass uses the original shader's property defaults/textures.
            wrapper_row["referenceAsset"] = ""  # Native fixtures are not used for these Git-baseline wrappers.
            rows.append(wrapper_row)
            wrappers.append({"path": wrapper_path, "sourcePath": path, "subshader": subshader,
                             "candidateSha256": hashlib.sha256(current_wrapper.encode()).hexdigest(),
                             "baselineSha256": hashlib.sha256(old_wrapper.encode()).hexdigest()})
        manifest.append({"path": path, "baselineSha256": hashlib.sha256(original.encode()).hexdigest(),
                         "candidateSha256": hashlib.sha256(current.encode()).hexdigest(),
                         "variants": sum(len(p["variants"]) for p in all_passes),
                         "baselineLines": len(original.splitlines()), "candidateLines": len(current.splitlines())})
    # Include files are part of the candidate, but not part of the baseline shaders.
    includes = []
    for src in local_includes(paths):
        relative = src.relative_to(PROJECT)
        dest = target / relative
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        if Path(str(src) + ".meta").exists():
            shutil.copy2(str(src) + ".meta", str(dest) + ".meta")
        includes.append({"path": str(relative), "sha256": hashlib.sha256(src.read_bytes()).hexdigest()})
    (target / "input.json").write_text(json.dumps({"shaders": rows}, indent=2) + "\n")
    (target / "input-grab.json").write_text(json.dumps({"shaders": [r for r in rows if r["grabCount"]]}, indent=2) + "\n")
    (target / "candidate-manifest.json").write_text(json.dumps({"baseline": revision, "batch": args.batch,
        "shaders": manifest, "includes": includes, "subshaderWrappers": wrappers}, indent=2) + "\n")
    manifest_hash = hashlib.sha256((target / "candidate-manifest.json").read_bytes()).hexdigest()
    provenance = f'public string baselineRevision="{revision}", candidateManifestSha256="{manifest_hash}";'
    batch = (fixtures / "Assets/Editor/BatchShaderValidation.cs").read_text().replace(str(args.source.resolve()), str(work))
    batch = batch.replace("public TextureInfo[] textures;", "public TextureInfo[] textures; public string[] grabNames; public int grabCount;")
    (target / "Assets/Editor/BatchShaderValidation.cs").write_text(batch)
    gpu = (fixtures / "Assets/Editor/BatchGpuValidation.cs").read_text()
    gpu = gpu.replace('[Serializable] public class Report {', '[Serializable] public class Report {' + provenance + ' public string comparisonReference;')
    gpu = gpu.replace('try {\n            ShaderUtil.allowAsyncCompilation', 'report.comparisonReference=Environment.GetEnvironmentVariable("READABILITY_NATIVE_REFERENCE")=="1"?"Captured native Metal":"Git baseline";\n        try {\n            ShaderUtil.allowAsyncCompilation', 1)
    gpu = gpu.replace('stencilRead=new Material(Shader.Find("RecoveryValidation/StencilRead"));', 'var stencilShader=Shader.Find("RecoveryValidation/StencilRead");stencilRead=stencilShader?new Material(stencilShader):null;')
    gpu = gpu.replace("var rs=bundle.LoadAsset<Shader>(info.referenceAsset);", 'var rs=Environment.GetEnvironmentVariable("READABILITY_NATIVE_REFERENCE")=="1" ? bundle.LoadAsset<Shader>(info.referenceAsset) : AssetDatabase.LoadAssetAtPath<Shader>("Assets/ReadabilityBaseline/"+info.path.Substring(7));')
    gpu = gpu.replace('"gpu-all"', '"gpu-readable"')
    gpu = gpu.replace('if(profile==1) {', 'if(profile==1) {\n            if(m.HasProperty("_TimeSnap"))m.SetFloat("_TimeSnap",.37f);')
    gpu = gpu.replace('new Vector4(.173f,3.46f,6.92f,10.38f)', 'profile==0?new Vector4(.173f,3.46f,6.92f,10.38f):new Vector4(1.234f,24.68f,49.36f,74.04f)')
    gpu = gpu.replace("two synthetic material/texture/transform profiles", "two synthetic material/texture/transform profiles; all declared combinations, including fallback mappings; reference is the Git baseline unless READABILITY_NATIVE_REFERENCE=1")
    (target / "Assets/Editor/BatchGpuValidation.cs").write_text(gpu)
    grab = (args.source / "grab-validation/Assets/Editor/GrabCameraValidation.cs").read_text().replace(str(args.source.resolve()), str(work))
    grab = grab.replace('[Serializable]public class Report{', '[Serializable]public class Report{' + provenance + 'public string comparisonReference="Git baseline";')
    grab = grab.replace("var input=BatchShaderValidation.ReadInput();", 'var input=JsonUtility.FromJson<BatchShaderValidation.Input>(File.ReadAllText(Root+"/batch-validation/input-grab.json"));')
    grab = grab.replace('Root+"/grab-validation/', 'Root+"/batch-validation/')
    grab = grab.replace("var reference=bundle.LoadAsset<Shader>(info.referenceAsset);", 'var reference=AssetDatabase.LoadAssetAtPath<Shader>("Assets/ReadabilityBaseline/"+info.path.Substring(7));')
    grab = grab.replace("All 75 shaders containing 79 captured GrabPass blocks", "Modified shaders with GrabPass, compared against the Git baseline")
    grab = grab.replace('"/batch-validation/results/grab-camera-gpu.json"', '"/batch-validation/results/"+(Environment.GetEnvironmentVariable("READABILITY_GRAB_RESULT")??"grab-camera-gpu")+".json"')
    (target / "Assets/Editor/GrabCameraValidation.cs").write_text(grab)
    shutil.copytree(args.source / "grab-validation/Assets/Validation", target / "Assets/Validation", dirs_exist_ok=True)
    for helper in Path(__file__).parent.glob("*.cs"):
        shutil.copy2(helper, target / "Assets/Editor" / helper.name)
    print(json.dumps({"project": str(target), "shaderCount": len(paths), "testAssetCount": len(rows),
        "variantCount": sum(len(p["variants"]) for s in rows for p in s["passes"]),
        "manifest": str(target / "candidate-manifest.json")}, indent=2))


if __name__ == "__main__":
    main()
