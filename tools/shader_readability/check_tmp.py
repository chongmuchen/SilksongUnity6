#!/usr/bin/env python3
"""Read-only token-equivalence check for the 16 shared recovered TMP shaders.

Expand project includes, reverse only explicit interface renames, then run Clang's
C preprocessor over both programs including the installed UnityCG include tree.
Every pragma-reachable keyword set is checked independently. Arithmetic, uniform
order, precision, semantic bindings and numeric literals must match exactly.

The projection macro UNITY_MATRIX_P is expanded by Unity's actual include files;
there is no checker exception for replacing a matrix or mathematical expression.
Only --output writes a JSON report. GPU compilation/rendering is a separate check.
"""

import argparse
import datetime
import hashlib
import itertools
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[2]
BASELINE = 'fd1bc3a6c'
DEFAULT_UNITY_INCLUDES = Path('/Applications/Unity/Hub/Editor/6000.5.4f1/Unity.app/Contents/Resources/CGIncludes')
PROGRAM = re.compile(r'HLSLPROGRAM\n(.*?)\s*ENDHLSL', re.S)
INCLUDE = re.compile(r'^\s*#include\s+"([^"]+)"\s*$', re.M)
VERTEX_INPUT_RENAMES = {
    'positionOS': 'POSITION0', 'normalOS': 'NORMAL0', 'vertexTint': 'COLOR0',
    'atlasUV': 'TEXCOORD0', 'packedUVAndScale': 'TEXCOORD1',
}
FULL_VARYING_RENAMES = {
    'positionCS': 'mtl_Position', 'vertexTint': 'COLOR0',
    'atlasAndSurfaceUV': 'TEXCOORD0', 'distanceParams': 'TEXCOORD1',
    'softMask': 'TEXCOORD2', 'viewDirectionEnv': 'TEXCOORD3',
    'underlayUVScaleBias': 'TEXCOORD4', 'underlayColor': 'COLOR1',
}
MOBILE_VARYING_RENAMES = {
    'positionCS': 'mtl_Position', 'faceColor': 'COLOR0', 'outlineBlendColor': 'COLOR1',
    'atlasAndMaskUV': 'TEXCOORD0', 'distanceParams': 'TEXCOORD1',
    'softMask': 'TEXCOORD2', 'underlayUVAndAlpha': 'TEXCOORD3',
    'underlayScaleBias': 'TEXCOORD4',
}
FRAGMENT_OUTPUT_RENAMES = {'color': 'SV_Target0'}


def targets():
    for mobile in (False, True):
        stem = 'TextMeshPro_Mobile_Distance Field' if mobile else 'TextMeshPro_Distance Field'
        for suffix in ('', '_0', '_1', '_2', '_3', '_4', '_5'):
            yield Path('Assets/Shader') / (stem + suffix + '.shader'), mobile
        yield Path('Assets/Resources/shaders') / ('tmpro_sdf-mobile.shader' if mobile else 'tmpro_sdf.shader'), mobile


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def git_bytes(path, baseline):
    return subprocess.check_output(['git', 'show', f'{baseline}:{path.as_posix()}'], cwd=ROOT)


def strip_comments(text):
    return re.sub(r'/\*.*?\*/|//[^\n]*', '', text, flags=re.S)


def tokens(text):
    return re.findall(r'"(?:\\.|[^"\\])*"|\w+|[^\w\s]', strip_comments(text))


def expand_local_includes(text, parent, dependencies, stack=()):
    def expand(match):
        name = match[1]
        if name == 'UnityCG.cginc':
            return match[0]  # Clang expands the actual installed Unity builtins.
        path = (ROOT / name if name.startswith('Assets/') else parent / name).resolve()
        assert path.is_relative_to(ROOT / 'Assets'), ('Non-project include', name)
        assert path not in stack, ('Recursive include', path)
        dependencies[path.relative_to(ROOT).as_posix()] = digest(path)
        return expand_local_includes(path.read_text(), path.parent, dependencies, (*stack, path))
    return INCLUDE.sub(expand, text)


def replace_member_names(text, variable, renames):
    return re.sub(r'\b' + variable + r'\.([A-Za-z_]\w*)',
                  lambda m: variable + '.' + renames.get(m[1], m[1]), text)


def canonical_program(text, mobile, readable):
    text = strip_comments(text)
    family = 'TMPMobileDistanceField' if mobile else 'TMPDistanceField'
    varyings = MOBILE_VARYING_RENAMES if mobile else FULL_VARYING_RENAMES
    if readable:
        def structure(match):
            role, body = match.groups()
            renames = VERTEX_INPUT_RENAMES if role == 'VertexInput' else (FRAGMENT_OUTPUT_RENAMES if role == 'FragmentOutput' else varyings)
            def field(field_match):
                typ, name, semantic = field_match.groups()
                assert name in renames, ('Unexpected interface field', name)
                return typ + ' ' + renames[name] + ' : ' + semantic + ';'
            body = re.sub(r'\b(\w+) (\w+)\s*:\s*(\w+);', field, body)
            return 'struct ' + family + role + '\n{' + body + '\n};'
        text = re.sub(r'struct ' + family + r'(VertexInput|VertexOutput|FragmentInput|FragmentOutput)\s*\{(.*?)\n\};', structure, text, flags=re.S)

        def function(match):
            value = match[0]
            is_vertex = match[1] == 'Vertex'
            value = replace_member_names(value, 'input', VERTEX_INPUT_RENAMES if is_vertex else varyings)
            return replace_member_names(value, 'output', varyings if is_vertex else FRAGMENT_OUTPUT_RENAMES)
        text = re.sub(family + r'(Vertex|Fragment)Output ' + family + r'(?:Vertex|Fragment)\([^\n]*\)\s*\{\n.*?\n\}', function, text, flags=re.S)
        for role in ('VertexInput', 'VertexOutput', 'FragmentInput', 'FragmentOutput', 'Vertex', 'Fragment'):
            text = re.sub(r'\b' + family + role + r'\b', 'Recovered' + role, text)
    else:
        for prefix, stage in [('RV', 'Vertex'), ('RF', 'Fragment')]:
            for direction in ('Input', 'Output'):
                text = re.sub(r'\b' + prefix + r'_[0-9a-f]{12}_' + direction + r'\b', 'Recovered' + stage + direction, text)
        text = text.replace('RecoveryVertex', 'RecoveredVertex').replace('RecoveryFragment', 'RecoveredFragment')
    return text


def keyword_sets(text):
    groups = []
    for kind, options in re.findall(r'^\s*#pragma\s+(multi_compile\w*)\s+([^\n]+)', text, re.M):
        assert kind == 'multi_compile', ('Unexpected pragma kind', kind)
        groups.append([() if key in ('_', '__') else (key,) for key in options.split()])
    return [tuple(sorted(itertools.chain.from_iterable(choice))) for choice in itertools.product(*groups)]


def preprocess(text, keywords, unity_includes, cache):
    key = (text, keywords)
    if key not in cache:
        command = ['/usr/bin/clang', '-E', '-P', '-x', 'c', '-DSHADER_API_METAL=1', '-DSHADER_TARGET=45', '-I' + str(unity_includes)]
        command += ['-D' + keyword + '=1' for keyword in keywords]
        result = subprocess.run(command + ['-'], input=text, text=True, capture_output=True)
        assert result.returncode == 0, result.stderr
        cache[key] = tokens(result.stdout)
    return cache[key]


def require_equal(expected, actual, context):
    if expected == actual:
        return
    first = next((i for i, (a, b) in enumerate(zip(expected, actual)) if a != b), min(len(expected), len(actual)))
    raise AssertionError((context, 'first differing token', first,
                          expected[max(first-5, 0):first+6], actual[max(first-5, 0):first+6]))


def check(baseline, unity_includes):
    assert (unity_includes / 'UnityCG.cginc').is_file(), unity_includes
    baseline = subprocess.check_output(['git', 'rev-parse', f'{baseline}^{{commit}}'], cwd=ROOT, text=True).strip()
    report = {
        'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'baseline_commit': baseline,
        'scope': 'All 16 TMP family shaders and all 48 pragma-reachable keyword combinations. Project and installed Unity includes expanded; tokens identical after only explicit interface/type/entrypoint renames. ShaderLab envelope, pragma declarations, local condition trees, resource order and original shader metadata preserved.',
        'unity_include_directory': str(unity_includes),
        'preprocessor_defines': ['SHADER_API_METAL=1', 'SHADER_TARGET=45'],
        'shader_sha256': {}, 'include_sha256': {}, 'shader_meta_sha256': {},
        'tool_sha256': {'tools/shader_readability/check_tmp.py': digest(Path(__file__))},
        'shaders': [], 'passed': False,
    }
    cache = {}
    for relative, mobile in targets():
        before = git_bytes(relative, baseline).decode()
        current = ROOT / relative
        after = current.read_text()
        old_programs = PROGRAM.findall(before)
        new_programs = PROGRAM.findall(after)
        assert len(old_programs) == len(new_programs) == 1, relative
        require_equal(tokens(PROGRAM.sub('', before)), tokens(PROGRAM.sub('', after)), (relative, 'ShaderLab envelope'))
        metadata = ROOT / (str(relative) + '.meta')
        assert metadata.read_bytes() == git_bytes(Path(str(relative) + '.meta'), baseline), relative
        report['shader_sha256'][relative.as_posix()] = digest(current)
        report['shader_meta_sha256'][relative.as_posix()] = digest(metadata)
        expanded = expand_local_includes(new_programs[0], current.parent, report['include_sha256'])
        old = canonical_program(old_programs[0], mobile, readable=False)
        new = canonical_program(expanded, mobile, readable=True)
        for directive in ('pragma', '(?:if|elif|else|endif)'):
            require_equal(tokens('\n'.join(re.findall(r'^\s*#' + directive + r'\b[^\n]*', old, re.M))),
                          tokens('\n'.join(re.findall(r'^\s*#' + directive + r'\b[^\n]*', new, re.M))),
                          (relative, 'preprocessor directives', directive))
        row = {'path': relative.as_posix(), 'family': 'mobile' if mobile else 'full', 'cases': [], 'passed': False}
        for keywords in keyword_sets(old):
            expected = preprocess(old, keywords, unity_includes, cache)
            actual = preprocess(new, keywords, unity_includes, cache)
            require_equal(expected, actual, (relative, keywords, 'expanded program'))
            row['cases'].append({'keywords': list(keywords), 'passed': True, 'token_count': len(actual),
                                 'canonical_token_sha256': hashlib.sha256(' '.join(actual).encode()).hexdigest()})
        row['passed'] = True
        report['shaders'].append(row)
    report['shader_count'] = len(report['shaders'])
    report['include_count'] = len(report['include_sha256'])
    report['case_count'] = sum(len(row['cases']) for row in report['shaders'])
    assert report['shader_count'] == 16 and report['include_count'] == 2 and report['case_count'] == 48
    report['passed'] = True
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', default=BASELINE)
    parser.add_argument('--unity-includes', type=Path, default=DEFAULT_UNITY_INCLUDES)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    report = check(args.baseline, args.unity_includes)
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f"PASS: {report['shader_count']} TMP shaders, {report['include_count']} shared includes, {report['case_count']} keyword combinations; expanded tokens and original metadata identical.")


if __name__ == '__main__':
    main()
