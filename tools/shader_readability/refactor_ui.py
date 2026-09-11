#!/usr/bin/env python3
"""Reproduce the readable UI blend shaders from the recovered Git baseline.

Only the vertex matrix expansion is replaced by UnityObjectToClipPos. Fragment
assignments retain their order, operand components, float precision and numeric
tokens. A component-level def/use map gives each value a descriptive local name
instead of reusing the recovered compiler registers for unrelated quantities.
Identical fragment bodies share named includes, with the original grab texture
and sampler selected by preprocessor aliases (never a runtime branch).

Run without arguments to write candidates; --check only checks reproducibility,
the preserved ShaderLab envelope, shader metadata and component substitutions.
GPU and real GrabPass comparisons are separate required checks.
"""

from __future__ import annotations

import argparse
import collections
import hashlib
from pathlib import Path
import re
import subprocess
import uuid


ROOT = Path(__file__).resolve().parents[2]
SHADERS = Path("Assets/GUIBlendModes/Shaders")
INCLUDES = SHADERS / "Includes"
BASELINE = "c8d3683ff"
COMPONENTS = "xyzw"
REFERENCE = re.compile(r"\b(u_xlat(?:b)?\d+)(?:\.([xyzw]+))?\b")
FRAGMENT = re.compile(
    r"RF_\w+_Output RecoveryFragment\(([^\n]*)\)\s*\{\n(.*?)\n\}", re.S
)
PROGRAM = re.compile(r"(?<=HLSLPROGRAM\n)(.*?)(?=\s*ENDHLSL)", re.S)
BRANCH = re.compile(
    r"// Original Metal program SHA256: vertex (\w+); fragment (\w+)\.\n"
    r"(.*?)(?=\n\s*#(?:elif|else|endif)\b)", re.S
)
VERTEX_TOKEN_HASHES = {
    "e8a9390e720e488a88e40250c1ba00023b6a0912c1a9c492b33e4eeae6773cf0":
        "dc3a9c2b4a0afa577d98954f932d68a10b23f8a383c3ec62f393ea8d815c117d",
    "4c427b1893dd1578a0cd519683fa421379edda04c9eb362bf2198edee4f8c2f7":
        "9fdd73308f5828128bd370f2119d34249fcde0cb7d47812215927357f306d783",
}
COMMON = '''// Shared UI blend inputs and vertex transform.
// Fragment includes preserve the captured blend equations and float precision.
#ifndef SILKSONG_UI_BLEND_COMMON_INCLUDED
#define SILKSONG_UI_BLEND_COMMON_INCLUDED

#include "UnityCG.cginc"

float4 _Color;
#if UI_BLEND_HAS_GRAB
Texture2D<float4> UI_BLEND_BACKGROUND_TEXTURE;
#endif
Texture2D<float4> _MainTex;
#if UI_BLEND_HAS_GRAB
SamplerState UI_BLEND_BACKGROUND_SAMPLER;
#endif
SamplerState sampler_MainTex;

struct UIBlendVertexInput
{
    float4 positionOS : POSITION0;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
};

struct UIBlendVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
#if UI_BLEND_HAS_GRAB
    float4 grabPositionCS : TEXCOORD1;
#endif
};

struct UIBlendFragmentInput
{
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
#if UI_BLEND_HAS_GRAB
    float4 grabPositionCS : TEXCOORD1;
#endif
};

UIBlendVertexOutput UIBlendVertex(UIBlendVertexInput input)
{
    UIBlendVertexOutput output;
    output.positionCS = UnityObjectToClipPos(input.positionOS);
    output.color = input.color * _Color;
    output.uv = input.uv;
#if UI_BLEND_HAS_GRAB
    // Keep clip coordinates interpolated exactly as the captured fragment expects.
    output.grabPositionCS = output.positionCS;
#endif
    return output;
}

#endif
'''


def git_bytes(path: Path, baseline: str) -> bytes:
    return subprocess.check_output(
        ["git", "show", f"{baseline}:{path.as_posix()}"], cwd=ROOT
    )


def tokens(text: str) -> list[str]:
    return re.findall(r"\w+|[^\w\s]", re.sub(r"//[^\n]*", "", text))


def envelope(text: str) -> list[str]:
    """All ShaderLab tokens outside the replaced HLSL region."""
    return tokens(PROGRAM.sub("", text))


def canonical_body(body: str) -> str:
    return re.sub(r"RF_\w+_Output", "FragmentOutput", body).replace(
        "sampler_GUIBlendingSharedGT", "UI_BLEND_BACKGROUND_SAMPLER"
    ).replace("sampler_GrabTexture", "UI_BLEND_BACKGROUND_SAMPLER").replace(
        "_GUIBlendingSharedGT", "UI_BLEND_BACKGROUND_TEXTURE"
    ).replace("_GrabTexture", "UI_BLEND_BACKGROUND_TEXTURE")


class FragmentNames:
    """Names describe values, not the recovered register storing them."""

    def __init__(self, mode: str, font: bool):
        self.mode, self.font = mode, font
        self.used: collections.Counter[str] = collections.Counter()
        self.product_count = 0

    def unique(self, name: str) -> str:
        self.used[name] += 1
        return name if self.used[name] == 1 else f"{name}{self.used[name]}"

    def choose(self, rhs: str, width: int) -> str:
        name = None
        if "_MainTex.Sample" in rhs:
            name = "fontAtlasAlpha" if self.font else "spriteSample"
        elif "-0.00999999978" in rhs:
            name = "alphaAndMidpointOffsets" if width == 4 else "alphaThreshold"
        elif re.search(r"<\s*0\.0\b", rhs):
            name = "belowAlphaThreshold"
        elif "input.grabPositionCS.xy /" in rhs:
            name = "ndcPosition"
        elif "ndcPosition" in rhs:
            name = "grabOffset"
        elif "grabOffset.x *" in rhs:
            name = "grabU"
        elif "grabOffset.y" in rhs:
            name = "grabV"
        elif "UI_BLEND_BACKGROUND_TEXTURE.Sample" in rhs:
            name = "backgroundColor"
        elif re.fullmatch(r"(?:spriteSample(?:\.[xyzw]+)?|fontAtlasAlpha) \* input.color(?:\.[xyzw]+)?", rhs):
            name = "opacity" if width == 1 else ("sourceAlphaRGB" if ".wxyz" in rhs else "sourceColor")
        elif rhs == "input.color.xyz":
            name = "sourceColor"
        elif "0.298999995" in rhs:
            name = "backgroundLuminance" if "backgroundColor" in rhs else "sourceLuminance"
        elif "Luminance" in rhs:
            name = "useBackground"
        elif rhs.startswith("dot(") and "rasterCoordinates.xy" not in rhs:
            name = ("twiceProduct" if self.mode == "Exclusion" else "multiplyBlend") + "RGB"[self.product_count]
            self.product_count += 1
        elif "rasterCoordinates.xy" in rhs:
            name = "ditherSeed"
        elif "ditherSeed" in rhs:
            name = "ditherFraction"
        elif "ditherFraction" in rhs:
            name = "ditherScaled"
        elif "ditherScaled" in rhs:
            name = "ditherPattern"
        elif "ditherPattern" in rhs:
            name = "dither"
        elif "?" in rhs:
            channel = re.search(r"\.([xyz])\) \?", rhs)[1]
            name = "blended" + {"x": "Red", "y": "Green", "z": "Blue"}[channel]
        elif "<" in rhs:
            if "0.5" in rhs:
                name = "backgroundAboveMidpoint" if "backgroundColor" in rhs else "sourceAboveMidpoint"
            else:
                name = "chooseWhite"
        elif rhs.startswith("(-backgroundColor") and "float3(1.0, 1.0, 1.0)" in rhs:
            name = "inverseBackground"
        elif (rhs.startswith("(-input.color") or rhs.startswith("mad((-spriteSample")) and "float3(1.0, 1.0, 1.0)" in rhs:
            name = "inverseSource"
        elif self.mode == "ColorBurn":
            name = "burnRatio"
        elif self.mode == "Difference":
            name = "colorDifference"
        elif self.mode == "Exclusion":
            name = "colorSum"
        elif self.mode in ("HardLight", "Overlay"):
            if "float3(-0.5, -0.5, -0.5)" in rhs:
                name = "backgroundMidpointOffset" if "backgroundColor" in rhs else "sourceMidpointOffset"
            elif "float3(2.0, 2.0, 2.0)" in rhs:
                name = "doubledInverseBackground" if self.mode == "Overlay" else "doubledInverseSource"
            else:
                name = "screenBlend"
        elif self.mode == "LinearBurn":
            name = "colorSum"
        elif self.mode == "LinearLight":
            if "float3(-0.5, -0.5, -0.5)" in rhs:
                name = "sourceMidpointOffset"
            elif "MidpointOffset" in rhs:
                name = "lightBranch"
            elif "float3(-1.0, -1.0, -1.0)" in rhs:
                name = "darkBranch"
            else:
                name = "doubledSourcePlusBackground"
        elif self.mode == "PinLight":
            if rhs.startswith("max("):
                name = "lightBranch"
            elif rhs.startswith("min("):
                name = "darkBranch"
            elif "float3(-0.5, -0.5, -0.5)" in rhs:
                name = "sourceMidpointOffset"
            elif "MidpointOffset" in rhs:
                name = "doubledSourceOffset"
            else:
                name = "doubledSource"
        elif self.mode == "Screen":
            name = "screenColor"
        elif self.mode == "SoftLight":
            if rhs.startswith("mad("):
                name = "screenColor"
            elif "inverseBackground" in rhs:
                name = "backgroundContrast"
            else:
                name = "screenWeighted"
        elif self.mode == "VividLight":
            if "float3(-0.5, -0.5, -0.5)" in rhs:
                name = "sourceMidpointOffset"
            elif rhs.startswith("mad("):
                name = "dodgeDenominator"
            elif "backgroundColor /" in rhs:
                name = "dodgeBranch"
            elif " / " in rhs:
                name = "burnRatio"
            elif rhs.startswith("(-burnRatio"):
                name = "burnBranch"
            else:
                name = "burnDenominator"
        if name is None:
            raise AssertionError(f"Missing semantic name: {self.mode}: {rhs}")
        return self.unique(name)


def rewrite_fragment(body: str, mode: str, font: bool) -> tuple[str, int]:
    """Rename every assignment using its live component definitions.

    A reference is replaced by a swizzle of its current definition, or a typed
    constructor assembling exactly those components if the old register mixed
    unrelated values. No arithmetic operator or constant is introduced by this
    substitution. References to uninitialized components fail closed.
    """
    names = FragmentNames(mode, font)
    types = {register: typ for typ, register in re.findall(r"\b((?:float|bool)[234]?) (u_xlat(?:b)?\d+);", body)}
    definitions: dict[tuple[str, str], tuple[str, str, int]] = {}
    named_components: dict[tuple[str, str], tuple[str, str, int]] = {}
    versions: collections.Counter[tuple[str, str]] = collections.Counter()
    widths: dict[str, int] = {}
    lines = ["    float4 outputColor;"]
    checked_references = 0
    output_components: set[str] = set()

    def reference(match: re.Match[str]) -> str:
        nonlocal checked_references
        register, swizzle = match.groups()
        width = int(types[register][-1]) if types[register][-1].isdigit() else 1
        swizzle = swizzle or COMPONENTS[:width]
        refs = [definitions[register, c] for c in swizzle]
        # Each emitted component must refer to exactly the same reaching definition.
        for c, (name, component, version) in zip(swizzle, refs):
            assert named_components[name, component] == (register, c, version)
            assert version == versions[register, c]
            checked_references += 1
        if all(r[0] == refs[0][0] for r in refs):
            name = refs[0][0]
            components = "".join(r[1] for r in refs)
            if components == COMPONENTS[:widths[name]]:
                return name
            return name + "." + components
        typ = "bool" if types[register].startswith("bool") else "float"
        pieces = [name if widths[name] == 1 else name + "." + c for name, c, _ in refs]
        return f"{typ}{len(pieces)}(" + ", ".join(pieces) + ")"

    for original_line in body.splitlines():
        line = original_line.strip()
        if not line or line == "FragmentOutput output;" or re.fullmatch(r"(?:float|bool)[234]? u_xlat(?:b)?\d+;", line):
            continue
        line = line.replace("input.COLOR0", "input.color").replace("input.TEXCOORD0", "input.uv").replace("input.TEXCOORD1", "input.grabPositionCS")
        line = line.replace("hlslcc_FragCoord", "rasterCoordinates").replace("mtl_FragCoord", "rasterPosition")
        if line.startswith("float4 rasterCoordinates ="):
            lines.append("    " + line)
            continue
        if line == "return output;":
            assert output_components == set(COMPONENTS)
            lines.append("    return outputColor;")
            continue
        discard = re.fullmatch(r"if\(\(\(int\((u_xlatb\d+(?:\.[xyzw])?)\) \* int\(0xffffffffu\)\)\)!=0\)\{discard;\}", line)
        if discard:
            predicate = REFERENCE.sub(reference, discard[1])
            lines += [f"    if ({predicate})", "    {", "        discard;", "    }", ""]
            continue
        assignment = re.fullmatch(r"(u_xlat(?:b)?\d+|output\.SV_Target0)(?:\.([xyzw]+))? = (.*);", line)
        assert assignment, line
        register, swizzle, rhs = assignment.groups()
        rewritten = REFERENCE.sub(reference, rhs)
        # The comparison already produces bool3; the recovered cast is an identity.
        rewritten = rewritten.replace(
            "((((bool3)(chooseWhite))) ? (float3(1.0, 1.0, 1.0)) : (float3(0.0, 0.0, 0.0)))",
            "chooseWhite ? float3(1.0, 1.0, 1.0) : float3(0.0, 0.0, 0.0)"
        ).replace("(bool(useBackground))", "useBackground")
        rewritten = re.sub(r"\s*<\s*", " < ", rewritten)
        if register == "output.SV_Target0":
            output_components.update(swizzle or COMPONENTS)
            target = "outputColor" + ("." + swizzle if swizzle else "")
            lines.append(f"    {target} = {rewritten};")
            continue
        typ = types[register]
        old_width = int(typ[-1]) if typ[-1].isdigit() else 1
        swizzle = swizzle or COMPONENTS[:old_width]
        width = len(swizzle)
        name = names.choose(rewritten, width)
        widths[name] = width
        value_type = ("bool" if typ.startswith("bool") else "float") + (str(width) if width > 1 else "")
        if name == "ndcPosition":
            lines += ["    // Project the captured clip interpolator after interpolation; keep the", "    // original division, offset and Y flip order for GrabPass sampling."]
        elif name == "ditherSeed":
            lines += ["", "    // The captured dither is added to all four channels, including alpha."]
        lines.append(f"    {value_type} {name} = {rewritten};")
        for old_component, new_component in zip(swizzle, COMPONENTS[:width]):
            versions[register, old_component] += 1
            version = versions[register, old_component]
            definitions[register, old_component] = (name, new_component, version)
            named_components[name, new_component] = (register, old_component, version)
    assert not REFERENCE.search("\n".join(lines))
    noise = "rasterPosition" in "\n".join(lines)
    signature = "float4 UIBlendFragment(UIBlendFragmentInput input"
    if noise:
        signature += ", float4 rasterPosition : SV_POSITION"
    return signature + ") : SV_Target0\n{\n" + "\n".join(lines) + "\n}\n", checked_references


def meta(path: Path, folder: bool = False) -> str:
    guid = uuid.uuid5(uuid.NAMESPACE_URL, "silksong-readable-ui/" + path.as_posix()).hex
    if folder:
        return f"fileFormatVersion: 2\nguid: {guid}\nfolderAsset: yes\nDefaultImporter:\n  externalObjects: {{}}\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n"
    return f"fileFormatVersion: 2\nguid: {guid}\nShaderIncludeImporter:\n  externalObjects: {{}}\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n"


def build(baseline: str) -> tuple[dict[Path, str], dict[str, int]]:
    paths = sorted(Path(p) for p in subprocess.check_output(
        ["git", "ls-tree", "-r", "--name-only", baseline, "--", str(SHADERS)], cwd=ROOT, text=True
    ).splitlines() if p.endswith(".shader"))
    assert len(paths) == 84
    originals = {p: git_bytes(p, baseline).decode() for p in paths}
    grouped: dict[str, list[tuple[Path, str, str]]] = collections.defaultdict(list)
    bodies_by_shader = {}
    for path, text in originals.items():
        bodies = []
        for branch in BRANCH.finditer(PROGRAM.search(text)[1]):
            vertex, fragment, stage = branch.groups()
            vertex_source = stage[stage.index("struct RV_"):stage.index("struct RF_")]
            assert hashlib.sha256(" ".join(tokens(vertex_source)).encode()).hexdigest() == VERTEX_TOKEN_HASHES[vertex], path
            declarations = stage[stage.index('#include "UnityCG.cginc"') + len('#include "UnityCG.cginc"'):stage.index("struct RV_")]
            expected_declarations = "float4 _Color; Texture2D<float4> _MainTex; SamplerState sampler_MainTex;"
            if "TEXCOORD1" in vertex_source:
                texture = "_GUIBlendingSharedGT" if "_GUIBlendingSharedGT" in declarations else "_GrabTexture"
                expected_declarations += f" Texture2D<float4> {texture}; SamplerState sampler{texture};"
            assert sorted(tokens(declarations)) == sorted(tokens(expected_declarations)), path
            match = FRAGMENT.search(stage)
            assert match, path
            body = canonical_body(match[2])
            grouped[body].append((path, vertex, fragment))
            bodies.append(body)
        assert bodies, path
        bodies_by_shader[path] = bodies
    assert len(grouped) == 42

    outputs = {INCLUDES / "UIBlendCommon.cginc": COMMON}
    names_by_body = {}
    reference_count = 0
    for body, sources in grouped.items():
        path = sources[0][0]
        font = path.stem.startswith("UIFont")
        mode = path.stem.removeprefix("UIFontBlend" if font else "UIBlend")
        stems = {p.stem for p, _, _ in sources}
        if len(stems) > 1:
            name = "UIFontBlendTint" if font else "UIBlendTint"
        else:
            name = path.stem
        if "hlslcc_FragCoord" in body:
            name += "Dither"
        elif mode == "LinearBurn" and not font and "UI_BLEND_BACKGROUND_TEXTURE" not in body:
            name += "Fixed"
        include = INCLUDES / (name + ".cginc")
        assert include not in outputs, include
        text, checked = rewrite_fragment(body, mode, font)
        reference_count += checked
        description = "Font atlas alpha with vertex tint" if font else "Sprite texture with vertex tint"
        header = f"// {description}: {mode if len(stems) == 1 else 'fixed-function blending'}.\n"
        header += "// Each intermediate is a separate float value; captured operation order is preserved.\n"
        outputs[include] = header + text
        names_by_body[body] = include

    for path, old in originals.items():
        program = PROGRAM.search(old)[1]
        body_list = bodies_by_shader[path]
        vertices = {m[1] for m in BRANCH.finditer(program)}
        assert len(vertices) == 1
        has_grab = next(iter(vertices)) == "e8a9390e720e488a88e40250c1ba00023b6a0912c1a9c492b33e4eeae6773cf0"
        assert has_grab or next(iter(vertices)) == "4c427b1893dd1578a0cd519683fa421379edda04c9eb362bf2198edee4f8c2f7"
        background = "_GUIBlendingSharedGT" if "_GUIBlendingSharedGT" in program else "_GrabTexture"
        setup = [f"#define UI_BLEND_HAS_GRAB {int(has_grab)}"]
        if has_grab:
            setup += [f"#define UI_BLEND_BACKGROUND_TEXTURE {background}", f"#define UI_BLEND_BACKGROUND_SAMPLER sampler{background}"]
        setup.append(f'#include "{(INCLUDES / "UIBlendCommon.cginc").as_posix()}"')
        first_branch = re.search(r"^#if", program, re.M).start()
        prefix = program[:first_branch].replace("#pragma vertex RecoveryVertex", "#pragma vertex UIBlendVertex").replace("#pragma fragment RecoveryFragment", "#pragma fragment UIBlendFragment")
        body_iter = iter(body_list)
        def replace_branch(match: re.Match[str]) -> str:
            body = next(body_iter)
            return f"// Original Metal program SHA256: vertex {match[1]}; fragment {match[2]}.\n" + f'#include "{names_by_body[body].as_posix()}"\n'
        branches = BRANCH.sub(replace_branch, program[first_branch:])
        branches = re.sub(r"\n{3,}", "\n\n", branches)
        new_program = prefix + "\n" + "\n".join(setup) + "\n\n" + branches.rstrip() + "\n"
        candidate = PROGRAM.sub(lambda _: new_program, old)
        candidate = candidate.replace("// Generated by tools/shader_reconstruction/shaderlab_generator.py.", "// Recovered by shaderlab_generator.py; readable source: tools/shader_readability/refactor_ui.py.")
        assert envelope(candidate) == envelope(old), path
        original_pragmas = re.findall(r"^#pragma .*$", program, re.M)
        new_pragmas = re.findall(r"^#pragma .*$", new_program, re.M)
        assert original_pragmas == [p.replace("UIBlendVertex", "RecoveryVertex").replace("UIBlendFragment", "RecoveryFragment") for p in new_pragmas]
        assert re.findall(r"^#(?:if|elif|else|endif).*$", program, re.M) == re.findall(r"^#(?:if|elif|else|endif).*$", new_program, re.M)
        assert (ROOT / (str(path) + ".meta")).read_bytes() == git_bytes(Path(str(path) + ".meta"), baseline), path
        outputs[path] = candidate
    outputs[Path(str(INCLUDES) + ".meta")] = meta(INCLUDES, folder=True)
    for path in list(outputs):
        if path.suffix == ".cginc":
            outputs[Path(str(path) + ".meta")] = meta(path)
    return outputs, {"shaders": len(paths), "original_lines": sum(len(s.splitlines()) for s in originals.values()), "fragment_bodies": len(grouped), "checked_component_references": reference_count, "readable_shader_and_include_lines": sum(len(s.splitlines()) for p, s in outputs.items() if p.suffix in (".shader", ".cginc"))}


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", default=BASELINE)
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()
    outputs, stats = build(args.baseline)
    for path, contents in outputs.items():
        target = ROOT / path
        if args.check:
            assert target.read_text() == contents, f"Generated output differs: {path}"
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(contents)
    print(("Verified" if args.check else "Wrote"), stats)


if __name__ == "__main__":
    main()
