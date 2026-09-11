#!/usr/bin/env python3
"""Share the two identical recovered TMP shader families without changing math.

Only interface type/field names and entry points are renamed. Numeric tokens,
temporary variables, arithmetic, declaration order and preprocessor conditions
stay intact. check_tmp.py independently expands every keyword combination and
checks that equivalence against the recovered Git baseline.
"""

import argparse
import hashlib
from pathlib import Path
import re
import subprocess
import uuid

ROOT = Path(__file__).resolve().parents[2]
BASELINE = 'fd1bc3a6c'
INCLUDES = Path('Assets/Shader/Includes')
PROGRAM = re.compile(r'(?<=HLSLPROGRAM\n)(.*?)(?=\s*ENDHLSL)', re.S)
STRUCT = re.compile(r'struct ((?:RV|RF)_\w+_(?:Input|Output))\s*\{(.*?)\n\};', re.S)
FUNCTION = re.compile(r'((RV|RF)_\w+_Output) (RecoveryVertex|RecoveryFragment)\([^\n]*\)\s*\{\n(.*?)\n\}', re.S)
VERTEX_INPUT = {
    'POSITION0': 'positionOS', 'NORMAL0': 'normalOS', 'COLOR0': 'vertexTint',
    'TEXCOORD0': 'atlasUV', 'TEXCOORD1': 'packedUVAndScale',
}
FULL_VARYINGS = {
    'mtl_Position': 'positionCS', 'COLOR0': 'vertexTint',
    'TEXCOORD0': 'atlasAndSurfaceUV', 'TEXCOORD1': 'distanceParams',
    'TEXCOORD2': 'softMask', 'TEXCOORD3': 'viewDirectionEnv',
    'TEXCOORD4': 'underlayUVScaleBias', 'COLOR1': 'underlayColor',
}
MOBILE_VARYINGS = {
    'mtl_Position': 'positionCS', 'COLOR0': 'faceColor', 'COLOR1': 'outlineBlendColor',
    'TEXCOORD0': 'atlasAndMaskUV', 'TEXCOORD1': 'distanceParams',
    'TEXCOORD2': 'softMask', 'TEXCOORD3': 'underlayUVAndAlpha',
    'TEXCOORD4': 'underlayScaleBias',
}
FRAGMENT_OUTPUT = {'SV_Target0': 'color'}


def paths(mobile):
    stem = 'TextMeshPro_Mobile_Distance Field' if mobile else 'TextMeshPro_Distance Field'
    result = [Path('Assets/Shader') / (stem + suffix + '.shader') for suffix in ['', '_0', '_1', '_2', '_3', '_4', '_5']]
    result.append(Path('Assets/Resources/shaders') / ('tmpro_sdf-mobile.shader' if mobile else 'tmpro_sdf.shader'))
    return result


def git_bytes(path, baseline):
    return subprocess.check_output(['git', 'show', f'{baseline}:{path.as_posix()}'], cwd=ROOT)


def tokens(text):
    text = re.sub(r'/\*.*?\*/|//[^\n]*', '', text, flags=re.S)
    return re.findall(r'"(?:\\.|[^"\\])*"|\w+|[^\w\s]', text)


def rename_fields(text, prefix, names):
    pattern = r'\b' + re.escape(prefix) + r'\.(' + '|'.join(map(re.escape, names)) + r')\b'
    return re.sub(pattern, lambda m: prefix + '.' + names[m[1]], text)


def rename_program(program, mobile):
    family = 'TMPMobileDistanceField' if mobile else 'TMPDistanceField'
    varyings = MOBILE_VARYINGS if mobile else FULL_VARYINGS
    type_names = {}
    field_notes = {
        'packedUVAndScale': 'x: packed secondary UV; y: signed distance scale / bold selection.',
        'atlasAndSurfaceUV': 'xy: font atlas UV; zw: face/outline texture UV.',
        'atlasAndMaskUV': 'xy: font atlas UV; zw: normalized rectangle UV.',
        'softMask': 'xy: centered rectangle position; zw: reciprocal soft-edge width.',
        'underlayUVScaleBias': 'xy: shifted atlas UV; z: scale; w: distance bias.',
        'underlayUVAndAlpha': 'xy: shifted atlas UV; z: original vertex alpha; w: unused.',
        'underlayScaleBias': 'x: underlay distance scale; y: distance bias.',
    }
    field_notes['distanceParams'] = ('x: distance scale; yz: outline thresholds; w: face bias.' if mobile else 'x: cutoff; y: distance scale; z: face threshold; w: glyph weight.')

    def structure(match):
        name, body = match.groups()
        is_vertex = name.startswith('RV_')
        is_input = name.endswith('_Input')
        role = ('Vertex' if is_vertex else 'Fragment') + ('Input' if is_input else 'Output')
        type_names[name] = family + role
        fields = VERTEX_INPUT if is_vertex and is_input else (FRAGMENT_OUTPUT if not is_vertex and not is_input else varyings)
        def field(line):
            typ, old, semantic = line.groups()
            renamed = fields[old]
            result = f'    {typ} {renamed} : {semantic};'
            if renamed in field_notes:
                result += ' // ' + field_notes[renamed]
            return result
        body = re.sub(r'^\s*(\w+) (\w+) : (\w+);', field, body, flags=re.M)
        return f'struct {family + role}\n{{\n' + body.lstrip('\n') + '\n};'

    program = STRUCT.sub(structure, program)

    def function(match):
        original = match[0]
        is_vertex = match[2] == 'RV'
        original = rename_fields(original, 'input', VERTEX_INPUT if is_vertex else varyings)
        original = rename_fields(original, 'output', varyings if is_vertex else FRAGMENT_OUTPUT)
        annotated = []
        seen = set()
        for line in original.splitlines():
            stripped = line.strip()
            note = None
            if is_vertex:
                if 'input.positionOS.xy + float2(_VertexOffsetX, _VertexOffsetY)' in stripped:
                    note = 'Apply glyph offsets and preserve the captured world/clip transform.'
                elif 'input.packedUVAndScale.x * 0.000244140625' in stripped:
                    note = 'Decode the packed secondary UV used by face and outline textures.'
                elif 'dot(input.normalOS.xyz, transpose(unity_WorldToObject)[0].xyz)' in stripped:
                    note = 'View-facing scale controls distance smoothing under perspective.'
                elif '_ScreenParams.yy * transpose(glstate_matrix_projection)[1].xy' in stripped:
                    note = 'Derive screen-pixel size and the reciprocal soft-mask edge widths.'
                elif '(-_WeightNormal) + _WeightBold' in stripped:
                    note = 'Select normal/bold glyph weight and account for face dilation.'
                elif '= max(_ClipRect,' in stripped:
                    note = 'Build the centered soft rectangle, retaining the captured clamp range.'
                elif 'float4(_UnderlaySoftness, _UnderlayDilate, _UnderlayOffsetX, _UnderlayOffsetY)' in stripped:
                    note = 'Compute shifted underlay atlas coordinates and distance scale/bias.'
            else:
                if '_OutlineUVSpeedX, _OutlineUVSpeedY' in stripped:
                    note = 'Sample animated face/outline textures and form premultiplied colors.'
                elif '_MainTex.Sample(sampler_MainTex, input.atlas' in stripped:
                    note = 'Evaluate the face/outline coverage from the font-atlas distance value.'
                elif '_MainTex.Sample(sampler_MainTex, input.underlay' in stripped:
                    note = 'Sample the shifted underlay and composite it behind the face.'
                elif '= _GlowOffset * _ScaleRatioB;' in stripped:
                    note = 'Evaluate the captured glow falloff, including its log2/exp2 power curve.'
                elif '= (-_ClipRect.xy) + _ClipRect.zw;' in stripped:
                    note = 'Multiply RGBA by soft rectangle coverage; this is not hard clipping.'
            if note and note not in seen:
                annotated += ['', '    // ' + note]
                seen.add(note)
            annotated.append(line)
        return '\n'.join(annotated)

    program = FUNCTION.sub(function, program)
    assert len(type_names) == (8 if mobile else 16)
    for old, new in type_names.items():
        program = re.sub(r'\b' + old + r'\b', new, program)
    program = program.replace('RecoveryVertex', family + 'Vertex').replace('RecoveryFragment', family + 'Fragment')
    # Unity upgrades legacy projection names when importing new .cginc files.
    # Its own macro expands back to the original matrix (also under stereo), so
    # the full preprocessor/token check verifies this without a rename exception.
    program = program.replace('glstate_matrix_projection', 'UNITY_MATRIX_P')
    # Declaration whitespace has no effect on binding order or numeric tokens.
    program = re.sub(r'(?m)^(float\w* \w+;|Texture2D<float4> \w+;|SamplerState \w+;)\n\n(?=(?:float\w* |Texture2D<float4> |SamplerState ))', r'\1\n', program)
    program = re.sub(r'\n{3,}', '\n\n', program)
    # Label the original branch order; do not reorder or combine variant conditions.
    labels = ['Underlay enabled', 'Base distance field'] if mobile else ['Glow and underlay enabled', 'Base distance field', 'Underlay enabled', 'Glow enabled']
    index = 0
    def branch_label(match):
        nonlocal index
        label = labels[index]
        index += 1
        return '\n// ' + label + '.\n' + match[0].lstrip()
    program = re.sub(r'(?m)^\s*// Original Metal program SHA256:.*$', branch_label, program)
    assert index == len(labels)
    heading = '// Shared recovered ' + ('mobile ' if mobile else '') + 'distance-field program.\n'
    heading += '// Interface names explain packed channels; arithmetic temporaries and operation order\n'
    heading += '// remain unchanged so check_tmp.py can verify each expanded variant token-for-token.\n'
    return heading + '\n' + program.strip() + '\n'


def meta(path, folder=False):
    guid = uuid.uuid5(uuid.NAMESPACE_URL, 'silksong-readable-tmp/' + path.as_posix()).hex
    kind = 'folderAsset: yes\nDefaultImporter:' if folder else 'ShaderIncludeImporter:'
    return f'fileFormatVersion: 2\nguid: {guid}\n{kind}\n  externalObjects: {{}}\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n'


def build(baseline):
    outputs = {}
    stats = {'shaders': 0, 'original_lines': 0, 'families': []}
    for mobile in [False, True]:
        family = 'TMPMobileDistanceField' if mobile else 'TMPDistanceField'
        family_paths = paths(mobile)
        originals = {path: git_bytes(path, baseline).decode() for path in family_paths}
        program_tokens = [tokens(PROGRAM.search(text)[1]) for text in originals.values()]
        assert all(value == program_tokens[0] for value in program_tokens), family
        first_program = PROGRAM.search(next(iter(originals.values())))[1]
        first_if = re.search(r'^#if\b', first_program, re.M).start()
        include = INCLUDES / (family + '.cginc')
        outputs[include] = rename_program(first_program[first_if:], mobile)
        stats['families'].append({'family': family, 'identical_programs': len(family_paths), 'original_program_token_sha256': hashlib.sha256(' '.join(program_tokens[0]).encode()).hexdigest()})
        for path, old in originals.items():
            prefix = first_program[:first_if].replace('RecoveryVertex', family + 'Vertex').replace('RecoveryFragment', family + 'Fragment')
            program = prefix + '\n#include "' + include.as_posix() + '"\n'
            new = PROGRAM.sub(lambda _: program, old)
            new = new.replace('// Generated by tools/shader_reconstruction/shaderlab_generator.py.', '// Recovered by shaderlab_generator.py; shared program: tools/shader_readability/refactor_tmp.py.')
            assert tokens(PROGRAM.sub('', new)) == tokens(PROGRAM.sub('', old)), path
            assert (ROOT / Path(str(path) + '.meta')).read_bytes() == git_bytes(Path(str(path) + '.meta'), baseline), path
            outputs[path] = new
            stats['shaders'] += 1
            stats['original_lines'] += len(old.splitlines())
    for path in list(outputs):
        if path.suffix == '.cginc':
            outputs[Path(str(path) + '.meta')] = meta(path)
    folder_meta = Path(str(INCLUDES) + '.meta')
    outputs[folder_meta] = (ROOT / folder_meta).read_text() if (ROOT / folder_meta).exists() else meta(INCLUDES, folder=True)
    stats['readable_shader_and_include_lines'] = sum(len(text.splitlines()) for path, text in outputs.items() if path.suffix in ('.shader', '.cginc'))
    return outputs, stats


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', default=BASELINE)
    parser.add_argument('--check', action='store_true')
    args = parser.parse_args()
    outputs, stats = build(args.baseline)
    for path, text in outputs.items():
        target = ROOT / path
        if args.check:
            assert target.read_text() == text, path
        else:
            target.parent.mkdir(parents=True, exist_ok=True)
            target.write_text(text)
    print(('Verified' if args.check else 'Wrote'), stats)


if __name__ == '__main__':
    main()
