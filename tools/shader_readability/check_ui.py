#!/usr/bin/env python3
"""Read-only symbolic comparison of recovered and readable UI fragments.

Every output component, ordered texture sample and discard predicate is replayed
from HLSL expressions. This parser does not call the refactorer's component mapper.
It preserves mad/dot operations, operand order and literal tokens in expression
trees instead of comparing a finite selection of numerical inputs.

This verifies fragment equations, not UnityObjectToClipPos or compiled GPU
behavior. Use the separate Metal and actual GrabPass validation for those checks.
Only --output writes a report; shader/include files are always read-only.
"""
import argparse
import datetime
import hashlib
import importlib.util
import json
import re
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('ui', root/'tools/shader_readability/refactor_ui.py')
ui = importlib.util.module_from_spec(spec)
spec.loader.exec_module(ui)
UNSET = object()
components = 'xyzw'
type_pattern = r'(float|bool)([234]?)'


class Expression:
    def __init__(self, source, values, samples):
        self.tokens = re.findall(r'(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?[fu]?|[A-Za-z_]\w*|[^\s]', source)
        self.index, self.values, self.samples = 0, values, samples

    def peek(self, offset=0):
        return self.tokens[self.index+offset] if self.index+offset < len(self.tokens) else None

    def pop(self, expected=None):
        token = self.peek()
        if expected is not None:
            assert token == expected, (expected, token, self.tokens)
        self.index += 1
        return token

    def broadcast(self, left, right):
        if len(left) == 1:
            left = left * len(right)
        if len(right) == 1:
            right = right * len(left)
        assert len(left) == len(right)
        return zip(left, right)

    def parse(self, minimum=0):
        if self.peek() == '-':
            self.pop()
            value = tuple(('negative', v) for v in self.parse(5))
        elif self.peek() == '(':
            self.pop()
            if re.fullmatch(type_pattern, self.peek() or '') and self.peek(1) == ')':
                typ = self.pop()
                self.pop(')')
                value = self.cast(typ, [self.parse(5)])
            else:
                value = self.parse()
                self.pop(')')
        elif re.match(r'\d|\.', self.peek()):
            value = (('number', self.pop()),)
        else:
            name = self.pop()
            if self.peek() == '.' and self.peek(1) == 'Sample':
                self.pop('.')
                name += '.' + self.pop()
            if self.peek() == '(':
                self.pop('(')
                args = []
                while self.peek() != ')':
                    args.append(self.parse())
                    if self.peek() != ',':
                        break
                    self.pop(',')
                self.pop(')')
                value = self.call(name, args)
            elif name.startswith('sampler_') or name == 'UI_BLEND_BACKGROUND_SAMPLER':
                value = name
            else:
                value = self.values[name]
                # Partial register writes are legal; reject only components read.
        while self.peek() == '.':
            self.pop('.')
            swizzle = self.pop()
            assert set(swizzle) <= set(components), swizzle
            value = tuple(value[components.index(c)] for c in swizzle)
        assert all(v is not UNSET for v in value), ('uninitialized read', self.tokens)
        precedence = {'<': 1, '+': 2, '-': 2, '*': 3, '/': 3}
        while self.peek() in precedence and precedence[self.peek()] >= minimum:
            operator = self.pop()
            right = self.parse(precedence[operator] + 1)
            value = tuple((operator, a, b) for a, b in self.broadcast(value, right))
        if self.peek() == '?' and minimum == 0:
            self.pop('?')
            yes = self.parse()
            self.pop(':')
            no = self.parse()
            branches = list(self.broadcast(yes, no))
            conditions = value * len(branches) if len(value) == 1 else value
            assert len(conditions) == len(branches)
            value = tuple(('select', cond, a, b) for cond, (a, b) in zip(conditions, branches))
        return value

    def cast(self, name, args):
        base, width = re.fullmatch(type_pattern, name).groups()
        width = int(width or 1)
        values = tuple(v for arg in args for v in arg)
        if len(values) == 1:
            values *= width
        assert len(values) == width
        if base == 'bool':
            assert all(v[0] == '<' for v in values), values
        return values

    def call(self, name, args):
        if re.fullmatch(type_pattern, name):
            return self.cast(name, args)
        if name.endswith('.Sample'):
            assert len(args) == 2
            sample = (name, args[0], args[1])
            self.samples.append(sample)
            return tuple(('sample', sample, i) for i in range(4))
        if name == 'dot':
            assert len(args) == 2 and len(args[0]) == len(args[1])
            return (('dot', args[0], args[1]),)
        if name in ('frac', 'abs'):
            return tuple((name, a) for a in args[0])
        if name in ('min', 'max'):
            return tuple((name, a, b) for a, b in self.broadcast(*args))
        if name == 'mad':
            width = max(map(len, args))
            args = [arg * width if len(arg) == 1 else arg for arg in args]
            assert all(len(arg) == width for arg in args)
            return tuple(('mad', *values) for values in zip(*args))
        raise AssertionError(name)


def replay(source):
    values = {
        'vertexColor': tuple(('vertexColor', c) for c in components),
        'mainUV': tuple(('mainUV', c) for c in 'xy'),
        'grabClipPosition': tuple(('grabClipPosition', c) for c in components),
        'rasterPosition': tuple(('rasterPosition', c) for c in components),
        'outputColor': (UNSET,) * 4,
    }
    for old, new in {
        'input.COLOR0': 'vertexColor', 'input.color': 'vertexColor',
        'input.TEXCOORD0': 'mainUV', 'input.uv': 'mainUV',
        'input.TEXCOORD1': 'grabClipPosition', 'input.grabPositionCS': 'grabClipPosition',
        'output.SV_Target0': 'outputColor', 'mtl_FragCoord': 'rasterPosition',
    }.items():
        source = source.replace(old, new)
    samples, discards = [], []
    def evaluate(expression):
        parser = Expression(expression, values, samples)
        result = parser.parse()
        assert parser.index == len(parser.tokens), parser.tokens[parser.index:]
        return result
    for line in source.splitlines():
        line = line.strip()
        if not line or line.startswith('//') or line in ('{', '}', 'discard;', 'return output;', 'return outputColor;', 'FragmentOutput output;'):
            continue
        if line.startswith('float4 UIBlendFragment('):
            continue
        old_discard = re.fullmatch(r'if\(\(\(int\((.*?)\) \* int\(0xffffffffu\)\)\)!=0\)\{discard;\}', line)
        new_discard = re.fullmatch(r'if \((.*?)\)', line)
        if old_discard or new_discard:
            predicate = (old_discard or new_discard)[1]
            discards.append((evaluate(predicate), len(samples)))
            continue
        declaration = re.fullmatch(r'(?:float|bool)([234]?) (\w+)(?: = (.*))?;', line)
        if declaration:
            width, name, rhs = declaration.groups()
            value = evaluate(rhs) if rhs is not None else (UNSET,) * int(width or 1)
            assert len(value) == int(width or 1), (line, value)
            values[name] = value
            continue
        assignment = re.fullmatch(r'(\w+)(?:\.([xyzw]+))? = (.*);', line)
        assert assignment, line
        name, swizzle, rhs = assignment.groups()
        result = evaluate(rhs)
        original = list(values[name])
        swizzle = swizzle or components[:len(original)]
        assert len(swizzle) == len(result), (line, result)
        for component, value in zip(swizzle, result):
            original[components.index(component)] = value
        values[name] = tuple(original)
    assert all(v is not UNSET for v in values['outputColor'])
    return values['outputColor'], samples, discards


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def check(baseline):
    baseline_commit = subprocess.check_output(
        ['git', 'rev-parse', f'{baseline}^{{commit}}'], cwd=root, text=True
    ).strip()
    report = {
        'generated_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'baseline_commit': baseline_commit,
        'scope': 'All UI blend fragment variants: identical RGBA expression trees, ordered texture/sampler/UV calls and discard predicates with the same position relative to sampling. Shared vertex helper and compiled GPU behavior require separate validation.',
        'shader_sha256': {},
        'include_sha256': {},
        'tool_sha256': {
            'tools/shader_readability/check_ui.py': digest(Path(__file__)),
            'tools/shader_readability/refactor_ui.py': digest(root/'tools/shader_readability/refactor_ui.py'),
        },
        'branches': [],
        'passed': False,
    }
    for shader in sorted((root/ui.SHADERS).rglob('*.shader')):
        relative = shader.relative_to(root)
        before = ui.git_bytes(relative, baseline_commit).decode()
        after = shader.read_text()
        report['shader_sha256'][relative.as_posix()] = digest(shader)
        old_branches = list(ui.BRANCH.finditer(ui.PROGRAM.search(before)[1]))
        new_branches = list(ui.BRANCH.finditer(ui.PROGRAM.search(after)[1]))
        assert len(old_branches) == len(new_branches), relative
        assert ui.envelope(before) == ui.envelope(after), (relative, 'ShaderLab envelope changed')
        for original, readable in zip(old_branches, new_branches):
            assert original.group(1, 2) == readable.group(1, 2), (relative, 'source identity changed')
            body = ui.canonical_body(ui.FRAGMENT.search(original[3])[2])
            include = root/re.search(r'#include "(.*?)"', readable[3])[1]
            expected = replay(body)
            actual = replay(include.read_text())
            for label, a, b in zip(('RGBA expression trees', 'ordered texture samples', 'discard predicates/sample positions'), expected, actual):
                assert a == b, (relative, include, label)
            report['branches'].append({
                'shader': relative.as_posix(),
                'vertex_source_sha256': original[1],
                'fragment_source_sha256': original[2],
                'fragment_include': include.relative_to(root).as_posix(),
                'passed': True,
            })
    for include in sorted((root/ui.INCLUDES).glob('*.cginc')):
        report['include_sha256'][include.relative_to(root).as_posix()] = digest(include)
    assert len(report['shader_sha256']) == 84
    assert len(report['include_sha256']) == 43
    assert len(report['branches']) == 86
    report['shader_count'] = len(report['shader_sha256'])
    report['include_count'] = len(report['include_sha256'])
    report['branch_count'] = len(report['branches'])
    report['passed'] = True
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', default=ui.BASELINE, help='Git commit containing the recovered shader baseline')
    parser.add_argument('--output', type=Path, help='Optional JSON report with checked candidate shader/include hashes')
    args = parser.parse_args()
    report = check(args.baseline)
    if args.output is not None:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(report, indent=2) + '\n')
    print(f"PASS: {report['branch_count']} fragment variants in {report['shader_count']} shaders; identical RGBA expressions, sample order/coordinates and discard predicates. Hashed {report['include_count']} includes.")


if __name__ == '__main__':
    main()
