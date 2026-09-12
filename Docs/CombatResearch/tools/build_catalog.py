#!/usr/bin/env python3
"""Read-only Unity text-asset census. No third-party dependencies.

This indexes serialized actors, not a claim about shipped/encountered enemies.
Use journal GUIDs first, exact normalized object names second; never fuzzy-match.
"""
from pathlib import Path
import argparse, re, json, hashlib, time, collections

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'Docs/CombatResearch/data'
HEADER = re.compile(r'^--- !u!(\d+) &(-?\d+)[^\n]*\n', re.M)
HEALTH = '7e0b9799fb0157646caefd91bc67f0a6'

def field(s, name, default=''):
    m = re.search(r'^  '+re.escape(name)+r':\s*([^\n]*)', s, re.M)
    return m.group(1).strip() if m else default

def ref(s, name):
    m=re.search(r'^  '+re.escape(name)+r': \{fileID: (-?\d+)',s,re.M)
    return m.group(1) if m else None

def blocks(text):
    matches=list(HEADER.finditer(text)); line=1; last=0
    for i,m in enumerate(matches):
        line += text.count('\n',last,m.start()); last=m.start()
        end=matches[i+1].start() if i+1<len(matches) else len(text)
        yield m.group(1),m.group(2),text[m.start():end],line

def norm(name):
    return re.sub(r'[^a-z0-9]','',re.sub(r'\s*\(\d+\)$','',name).lower())

def load_journal():
    result={}
    master=(ROOT/'Assets/Data Assets/Enemy Journal/Master Journal List.asset').read_text()
    order=re.findall(r'guid: ([0-9a-f]{32})',master)[1:]
    for p in sorted((ROOT/'Assets/Data Assets/Enemy Journal/Journal Records').glob('*.asset')):
        s=p.read_text(); guid=field(p.with_suffix('.asset.meta').read_text(),'guid')
        if not guid:
            guid=re.search(r'^guid: (\w+)',p.with_suffix('.asset.meta').read_text(),re.M).group(1)
        result[guid]={'id':p.stem,'guid':guid,'path':str(p.relative_to(ROOT)),
            'key':re.search(r'displayName:\n    Sheet: .*\n    Key: (.*)',s).group(1),
            'record_type':int(field(s,'recordType','0')),
            'kills_required':int(field(s,'killsRequired','0')),
            'required_type':int(field(s,'requiredType','0')),
            'master_order':order.index(guid)+1 if guid in order else None,
            'instances':[],'canonical':None}
    return result

def main():
    parser=argparse.ArgumentParser(); parser.add_argument('--limit',type=int); args=parser.parse_args()
    OUT.mkdir(parents=True,exist_ok=True)
    journals=load_journal(); byname={norm(x['id']):g for g,x in journals.items()}
    scripts={}
    for p in (ROOT/'Assets/Scripts').rglob('*.cs.meta'):
        m=re.search(r'^guid: (\w+)',p.read_text(),re.M)
        if m:scripts[m.group(1)]=str(p.relative_to(ROOT))[:-5]
    paths=sorted((ROOT/'Assets/Scenes').rglob('*.unity'))+sorted((ROOT/'Assets/Prefabs').rglob('*.prefab'))+sorted((ROOT/'Assets/GameObject').rglob('*.prefab'))
    if args.limit:paths=paths[:args.limit]
    unmatched={}; counts=collections.Counter(); started=time.time(); filehash={}
    candidates={}
    for n,p in enumerate(paths):
        text=p.read_text(errors='replace'); counts['files_scanned']+=1
        if HEALTH not in text:continue
        rel=str(p.relative_to(ROOT)); filehash[rel]=hashlib.sha256(text.encode()).hexdigest()
        docs=list(blocks(text)); gos={}; comps=collections.defaultdict(list); transforms={}; hp={}
        for typ,fid,s,line in docs:
            go=ref(s,'m_GameObject')
            if typ=='1':gos[fid]={'name':field(s,'m_Name'),'line':line,'active':field(s,'m_IsActive')}
            elif go:
                comps[go].append((typ,fid,s,line))
                if typ in ('4','224'):transforms[fid]=(go,ref(s,'m_Father'))
                if typ=='114' and re.search(r'm_Script:.*'+HEALTH,s):hp[go]=(fid,s,line)
        parents={go:transforms.get(parent,(None,None))[0] for go,parent in transforms.values()}
        owners={}
        for go in gos:
            q=go; seen=set()
            while q and q not in seen:
                if q in hp:owners[go]=q; break
                seen.add(q); q=parents.get(q)
        grouped=collections.defaultdict(list)
        for go,actor in owners.items():
            grouped[actor].extend((go,*c) for c in comps.get(go,[]))
        for go,(fid,h,line) in hp.items():
            counts['health_actors']+=1
            name=gos.get(go,{}).get('name',go); records=set()
            for child,typ,cid,s,ln in grouped[go]:
                for g in re.findall(r'journalRecord: \{fileID: \d+, guid: ([0-9a-f]{32})',s):
                    if g in journals:records.add(g)
            match='journal_guid'
            if not records and norm(name) in byname:records={byname[norm(name)]};match='exact_normalized_name'
            fsms=[]; component_names=[]; damages=[]
            for child,typ,cid,s,ln in grouped[go]:
                script=re.search(r'm_Script:.*guid: ([0-9a-f]{32})',s)
                scriptpath=scripts.get(script.group(1),'') if script else ''
                if scriptpath:component_names.append(scriptpath)
                if '\n  damageDealt:' in s:damages.append({'object':gos.get(child,{}).get('name',child),'damage':field(s,'damageDealt'),'line':ln})
                if '\n  fsm:\n' in s:
                    fm=re.search(r'^    name: (.*)$',s,re.M); st=re.search(r'^    startState: (.*)$',s,re.M)
                    states=re.findall(r'^    - name: (.*)$',s.split('\n    events:')[0],re.M)
                    acts=sorted(set(re.findall(r'^        - (HutongGames\.[^\n]+)$',s,re.M)))
                    fsms.append({'object':gos.get(child,{}).get('name',child),'game_object_id':child,'component_id':cid,'name':fm.group(1) if fm else '',
                        'start':st.group(1) if st else '', 'states':states,'action_types':acts,'line':ln,'lines':s.count('\n'),
                        'source_sha256':hashlib.sha256(s.encode()).hexdigest()})
            actor={'source':rel,'line':line,'game_object_id':go,'name':name,'active':gos.get(go,{}).get('active'),
                'hp':field(h,'hp'),'special_death':field(h,'hasSpecialDeath'),'invincible':field(h,'invincible'),
                'fsms':fsms,'components':sorted(set(component_names)),'damages':damages,
                'evidence':match if records else 'unmapped_health_actor',
                'is_hornet_scene':rel.startswith('Assets/Scenes/Hornet/'),
                'is_temp_scene':bool(re.search(r'temp|test|unused',rel,re.I))}
            if records:
                counts['mapped_actors']+=1
                for g in records:
                    j=journals[g]; j['instances'].append(actor)
                    score=(not actor['is_temp_scene'],actor['is_hornet_scene'],len(sum([f['states'] for f in fsms],[])),match=='journal_guid')
                    if g not in candidates or score>candidates[g][0]:candidates[g]=(score,actor)
            else:
                key=name
                unmatched.setdefault(key,[]).append(actor)
        if n%40==0:print(json.dumps({'file':n,'of':len(paths),'actors':counts['health_actors'],'mapped_species':len(candidates),'seconds':round(time.time()-started)}),flush=True)
    for g,(_,a) in candidates.items():journals[g]['canonical']=a
    for j in journals.values():
        j['scene_count']=len({a['source'] for a in j['instances'] if a['source'].endswith('.unity')})
        j['object_names']=sorted({a['name'] for a in j['instances']})
        j['instance_count']=len(j['instances'])
    result={'schema':'silksong-combat-census-v1','created':'2026-09-12','root':str(ROOT),'counts':dict(counts),
        'journal_records':sorted(journals.values(),key=lambda j:j['master_order'] or 10000),
        'unmapped_health_actors':unmatched,'source_hashes':filehash,'script_guids':scripts}
    (OUT/'catalog.json').write_text(json.dumps(result,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'finished':True,'seconds':round(time.time()-started),'counts':dict(counts),'journal_records':len(journals),'mapped_species':len(candidates),'unmapped_names':len(unmatched)},ensure_ascii=False),flush=True)

if __name__=='__main__':main()
