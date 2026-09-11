#!/usr/bin/env python3
"""Read-only checks for ScrollTexture, Water and CameraScrollingSpriteTexture.

ScrollTexture: all 64 keyword masks (including the 32 declared combinations),
exact preprocessed tokens except reviewed interface/local identifier renames.
Water and CameraScrolling: fragment RGBA expression trees and ordered samples;
ShaderLab, pragma and resource declarations remain unchanged. Vertex matrix
helpers and actual GPU behavior require the separate Unity comparisons.
Only --output writes a report; no shader or include is modified.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[2]
SCROLL = 'Assets/Shaders/ScrollTexture.shader'
WATER = 'Assets/Shaders/Water.shader'
CAMERA = 'Assets/Shader/Sprites_CameraScrollingSpriteTexture.shader'
KEYWORDS = ('USE_COLOR_FLASH', 'USE_MASK', 'USE_OBJECT_SCALE', 'USE_SECONDARY', 'USE_WORLD_OFFSET', 'INSTANCING_ON')
VERTEX_LOCALS = {
    'u_xlat0': 'uvAndPositionWork', 'u_xlat1': 'positionWork',
    'u_xlat2': 'secondaryUV', 'u_xlat4': 'scrollUV', 'u_xlat5': 'mainScrollUV',
    'u_xlat6': 'scrollTime', 'u_xlati0': 'instanceOffsets', 'u_xlati2': 'propertyOffset',
}
FRAGMENT_LOCALS = {
    'u_xlat0': 'colorWork', 'u_xlat1': 'sampleWork', 'u_xlat2': 'primarySample',
    'u_xlat3': 'flashDifference', 'u_xlat6': 'maskedAlpha', 'u_xlat9': 'maskedAlpha',
    'u_xlati0': 'propertyOffset', 'u_xlati1': 'instanceOffsets', 'u_xlati4': 'secondaryOffset',
}


def tokens(source):
    return re.findall(r'\w+|[^\s\w]', re.sub(r'//[^\n]*|/\*[\s\S]*?\*/', '', source))


def programs(source):
    return re.findall(r'HLSLPROGRAM(.*?)ENDHLSL', source, re.S)


def shell(source):
    return tokens(re.sub(r'HLSLPROGRAM.*?ENDHLSL', 'HLSLPROGRAM ENDHLSL', source, flags=re.S))


def function(source, name):
    match = re.search(r'\b' + name + r'\([^)]*\)[^{]*\{', source)
    assert match, name
    begin = match.end()
    depth = 1
    for end in range(begin, len(source)):
        depth += (source[end] == '{') - (source[end] == '}')
        if depth == 0:
            return begin, end
    raise AssertionError('Unclosed function ' + name)


def canonical_scroll(source):
    for prefix, typ in [('RV', 'ScrollVertex'), ('RF', 'ScrollFragment')]:
        source = re.sub(prefix + r'_[a-f0-9]+_(Input|Output)', lambda m: typ + m[1], source)
    for old, new in {'POSITION0': 'positionOS', 'TEXCOORD0': 'mainUV',
                     'TEXCOORD1': 'maskUV', 'TEXCOORD2': 'secondaryUV',
                     'COLOR0': 'color', 'SV_Target0': 'color', 'SV_InstanceID0': 'instanceID'}.items():
        source = re.sub(r'\b' + old + r'(?=\s*:)', new, source)
        source = re.sub(r'\.' + old + r'\b', '.' + new, source)
    for old, new in {'mtl_Position': 'positionCS', 'recovered_InstanceID': 'instanceID'}.items():
        source = re.sub(r'\b' + old + r'\b', new, source)
    for name, mapping in [('RecoveryVertex', VERTEX_LOCALS), ('RecoveryFragment', FRAGMENT_LOCALS)]:
        begin, end = function(source, name)
        body = source[begin:end]
        for old, new in mapping.items():
            body = re.sub(r'\b' + old + r'\b', new, body)
        source = source[:begin] + body + source[end:]
    return tokens(source)


def preprocess(program, keywords=()):
    program = re.sub(r'^\s*#include\s+"([^"]+)"\s*$', r'READABILITY_INCLUDE("\1")', program, flags=re.M)
    result = subprocess.run(['clang', '-E', '-P', '-x', 'c', '-'] + ['-D' + k + '=1' for k in keywords],
                            input=program, text=True, capture_output=True)
    assert result.returncode == 0, result.stderr
    return result.stdout


def replay_fragment(program, aliases, widths, parser_module):
    begin, end = function(program, 'RecoveryFragment')
    source = program[begin:end]
    source = re.sub(r'//[^\n]*', '', source)
    source = source.replace('output.SV_Target0', 'outputColor')
    for old, new in aliases.items():
        source = source.replace('input.' + old, new)
    swizzles = str.maketrans('rgba', 'xyzw')
    source = re.sub(r'\.([rgbaxyzw]{1,4})\b', lambda m: '.' + m[1].translate(swizzles), source)
    unset = parser_module.UNSET
    values = {name: tuple(('input', name, i) for i in range(width)) for name, width in widths.items()}
    values['outputColor'] = (unset,) * 4
    for width, name in re.findall(r'^float([234]?)\s+(_\w+)\s*;', program, re.M):
        values[name] = tuple(('uniform', name, i) for i in range(int(width or 1)))
    values['_Time'] = tuple(('uniform', '_Time', i) for i in range(4))
    samples = []

    def evaluate(expression):
        parser = parser_module.Expression(expression, values, samples)
        value = parser.parse()
        assert parser.index == len(parser.tokens), parser.tokens[parser.index:]
        return value

    for line in source.splitlines():
        line = line.strip()
        if not line or re.fullmatch(r'RF_\w+_Output output;', line) or line == 'return output;':
            continue
        if line.startswith('return '):
            values['outputColor'] = evaluate(line[7:-1])
            continue
        declaration = re.fullmatch(r'float([234]?) (\w+)(?: = (.*))?;', line)
        if declaration:
            width, name, rhs = declaration.groups()
            value = evaluate(rhs) if rhs is not None else (unset,) * int(width or 1)
            assert len(value) == int(width or 1), line
            values[name] = value
            continue
        assignment = re.fullmatch(r'(\w+)(?:\.([xyzw]+))? = (.*);', line)
        assert assignment, line
        name, swizzle, expression = assignment.groups()
        result = evaluate(expression)
        value = list(values[name])
        swizzle = swizzle or 'xyzw'[:len(value)]
        assert len(result) == len(swizzle), line
        for component, lane in zip(swizzle, result):
            value['xyzw'.index(component)] = lane
        values[name] = tuple(value)
    assert all(v is not unset for v in values['outputColor'])
    return values['outputColor'], samples


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', default='fd1bc3a6c')
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    revision = subprocess.check_output(['git', 'rev-parse', args.baseline + '^{commit}'], cwd=ROOT, text=True).strip()
    spec = importlib.util.spec_from_file_location('ui_expression_check', Path(__file__).with_name('check_ui.py'))
    expression_module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(expression_module)
    report = {'baselineRevision': revision, 'passed': False, 'shaders': {}, 'scrollKeywordMasks': 64,
              'scrollDeclaredCombinations': 32, 'fragmentExpressionComparisons': 3,
              'scope': 'Scroll exact declaration/interface/arithmetic tokens after explicit identifier renames; Water and CameraScrolling exact fragment RGBA expression trees and ordered samples; unchanged ShaderLab/pragmas/metas. Vertex helper arithmetic needs GPU/compiled comparison.'}
    pairs = {}
    for path in (SCROLL, WATER, CAMERA):
        before = subprocess.check_output(['git', 'show', revision + ':' + path], cwd=ROOT, text=True)
        after = (ROOT / path).read_text()
        assert shell(before) == shell(after), (path, 'ShaderLab')
        assert re.findall(r'#pragma[^\n]*', before) == re.findall(r'#pragma[^\n]*', after), (path, 'pragma')
        assert subprocess.check_output(['git', 'show', revision + ':' + path + '.meta'], cwd=ROOT) == (ROOT / (path + '.meta')).read_bytes(), (path, 'meta')
        pairs[path] = (programs(before), programs(after))
        assert len(pairs[path][0]) == len(pairs[path][1])
        report['shaders'][path] = {'candidateSha256': hashlib.sha256(after.encode()).hexdigest(),
                                 'baselineSha256': hashlib.sha256(before.encode()).hexdigest(),
                                 'beforeLines': len(before.splitlines()), 'afterLines': len(after.splitlines())}
    for mask in range(64):
        keys = [k for bit, k in enumerate(KEYWORDS) if mask & (1 << bit)]
        before, after = (preprocess(p[0], keys) for p in pairs[SCROLL])
        assert canonical_scroll(before) == canonical_scroll(after), ('Scroll keyword mismatch', keys)
    layouts = [
        (WATER, 0, {'TEXCOORD0': 'grabPosition', 'TEXCOORD1': 'normalUV', 'TEXCOORD2': 'tintUV', 'TEXCOORD3': 'reflectionUV'},
         {'grabPosition': 4, 'normalUV': 2, 'tintUV': 2, 'reflectionUV': 2}),
        (WATER, 1, {'TEXCOORD0': 'uv'}, {'uv': 2}),
        (CAMERA, 0, {'TEXCOORD0': 'spriteUV', 'TEXCOORD1': 'colorUV', 'COLOR0': 'color'}, {'spriteUV': 2, 'colorUV': 2, 'color': 4}),
    ]
    for path, index, old_aliases, widths in layouts:
        old, new = (preprocess(p[index]) for p in pairs[path])
        resource_pattern = r'^(?:float[234]?\s+_\w+|Texture2D<float4>\s+_\w+|SamplerState\s+sampler_\w+)\s*;'
        assert re.findall(resource_pattern, old, re.M) == re.findall(resource_pattern, new, re.M), (path, index, 'resource declarations')
        current_aliases = {name: name for name in widths}
        assert replay_fragment(old, old_aliases, widths, expression_module) == replay_fragment(new, current_aliases, widths, expression_module), (path, index, 'fragment expressions')
    report['passed'] = True
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
