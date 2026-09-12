#!/usr/bin/env python3
"""Check source anchors, graph integrity and local document links, not gameplay."""
from build_catalog import *
from export_entities import count_unknown
from urllib.parse import unquote

BASE=ROOT/'Docs/CombatResearch'

def main():
    errors=[];checks=collections.Counter();wanted=collections.defaultdict(dict)
    catalog=json.loads((OUT/'catalog.json').read_text())
    entities=[]
    for p in sorted((OUT/'entities').glob('*.json'))+sorted((OUT/'unmapped').glob('*.json')):
        prefix='' if p.parent.name=='entities' else 'supplemental_'
        e=json.loads(p.read_text())
        if not prefix:entities.append(e)
        checks[prefix+'entity_files']+=1
        for f in e['fsms']:
            names=[s['name'] for s in f['states']]
            if any(not isinstance(n,str) for n in names):errors.append([p.name,f['name'],'non_string_state'])
            if len(names)!=len(set(names)):errors.append([p.name,f['name'],'duplicate_state'])
            checks[prefix+'states']+=len(names)
            for s in f['states']:
                wanted[ROOT/f['source']][s['line']]=('state',str(s['name']))
                checks[prefix+'actions']+=len(s['actions']);checks[prefix+'disabled_actions']+=sum(a['enabled'] is False for a in s['actions'])
                checks[prefix+'unknown_parameters']+=count_unknown(s['actions'])
                for t in s['transitions']:
                    if not t['to']:checks[prefix+'empty_targets_preserved']+=1
                    elif t['to'] not in names:errors.append([p.name,f['name'],s['name'],'dangling',t['to']])
    if len(entities)!=len(catalog['journal_records']):errors.append(['journal_count_mismatch'])
    for p in BASE.glob('丝之歌战斗逻辑_*.md'):
        text=p.read_text();checks['main_documents']+=1
        if '<!-- AI_SPEC_' in text or '<!-- HUMAN_GUIDE_' in text:errors.append([p.name,'unremoved_assembly_marker'])
        if text.count('```')%2:errors.append([p.name,'unbalanced_code_fences'])
        for angle,plain in re.findall(r'\]\((?:<([^>]+)>|([^\s)]+))\)',text):
            dest=unquote(angle or plain)
            if not dest.startswith('/'):continue
            line=None
            m=re.match(r'(.+):(\d+)$',dest)
            if m:dest=m[1];line=int(m[2])
            target=Path(dest);checks['local_links']+=1
            if not target.exists():errors.append([p.name,'missing_link',dest]);continue
            if line:wanted[target].setdefault(line,('link',p.name))
    for path,lines in wanted.items():
        if not path.exists():errors.append(['missing_source',str(path)]);continue
        last=0
        with path.open(errors='replace') as stream:
            for n,line in enumerate(stream,1):
                last=n
                if n not in lines:continue
                kind,expected=lines[n];checks['source_anchors']+=1
                if kind=='state':
                    actual=re.match(r'^    - name: (.*)',line)
                    if not actual or actual[1].strip('"\'\n')!=expected:
                        errors.append([str(path.relative_to(ROOT)),n,'state_anchor_mismatch',expected,line.strip()])
        for n in lines:
            if n<1 or n>last:errors.append([str(path),'line_out_of_range',n,last])
    result={'scope':'Static data and document integrity; no gameplay run claimed.',
            'checks':dict(checks),'errors':errors,'passed':not errors and checks['unknown_parameters']==0 and checks['supplemental_unknown_parameters']==0 and checks['main_documents']==2}
    (OUT/'document-validation.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps(result,ensure_ascii=False,indent=2)[:12000])

if __name__=='__main__':main()
