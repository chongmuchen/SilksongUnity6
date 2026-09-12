#!/usr/bin/env python3
"""Resolve journal entries with scripted recording or nonstandard health.
The exact GUID evidence is retained; curated body aliases are marked as such.
"""
from build_catalog import *

BODY_ALIASES={
 'Lost Lace':['Lost Lace Boss'],
 'Giant Centipede':['Giant Centipede Head','Giant Centipede Butt','Giant Centipede Coil'],
 'Clockwork Dancer':['Dancer A','Dancer B'],
 'Shakra':['Mapper Spar NPC'],
 'Garmond_Zaza':['Garmond Fighter'],
}

def main():
    p=OUT/'catalog.json'; data=json.loads(p.read_text()); missing={j['guid']:j for j in data['journal_records'] if not j['canonical']}
    refs=collections.defaultdict(list)
    for path in sorted((ROOT/'Assets/Scenes/Hornet').glob('*.unity'))+sorted((ROOT/'Assets/Prefabs').rglob('*.prefab')):
        text=path.read_text(errors='replace'); present=[g for g in missing if g in text]
        if not present:continue
        docs=list(blocks(text)); gos={fid:field(s,'m_Name') for typ,fid,s,ln in docs if typ=='1'}
        bygo=collections.defaultdict(list)
        for typ,fid,s,ln in docs:
            go=ref(s,'m_GameObject')
            if go:bygo[go].append((typ,fid,s,ln))
        for typ,fid,s,ln in docs:
            for g in present:
                if g not in s:continue
                go=ref(s,'m_GameObject')
                fsms=[]; components=[]
                for ct,cf,cs,cl in bygo.get(go,[]):
                    sm=re.search(r'm_Script:.*guid: ([0-9a-f]{32})',cs)
                    if sm and sm[1] in data['script_guids']:components.append(data['script_guids'][sm[1]])
                    if '\n  fsm:\n' in cs:
                        fm=re.search(r'^    name: (.*)$',cs,re.M); st=re.search(r'^    startState: (.*)$',cs,re.M)
                        fsms.append({'object':gos.get(go),'game_object_id':go,'component_id':cf,'name':fm[1] if fm else '', 'start':st[1] if st else '',
                            'states':re.findall(r'^    - name: (.*)$',cs.split('\n    events:')[0],re.M),
                            'action_types':sorted(set(re.findall(r'^        - (HutongGames\.[^\n]+)$',cs,re.M))),
                            'line':cl,'lines':cs.count('\n'),'source_sha256':hashlib.sha256(cs.encode()).hexdigest()})
                refs[g].append({'source':str(path.relative_to(ROOT)),'line':ln,'name':gos.get(go),'game_object_id':go,
                    'hp':None,'special_death':None,'invincible':None,'active':None,'damages':[],
                    'fsms':fsms,'components':sorted(set(components)),'evidence':'journal_reference_component_not_necessarily_body',
                    'is_hornet_scene':str(path.relative_to(ROOT)).startswith('Assets/Scenes/Hornet/'),'is_temp_scene':False})
    for g,j in missing.items():
        j['recording_references']=refs[g]
        aliases=BODY_ALIASES.get(j['id'],[])
        bodies=[]
        for name in aliases:
            for actor in data['unmapped_health_actors'].get(name,[]):
                actor=dict(actor); actor['evidence']='curated_body_alias_with_separate_recording_reference';bodies.append(actor)
        if bodies:
            j['instances']=bodies;j['canonical']=max(bodies,key=lambda a:sum(len(f['states']) for f in a['fsms']))
        elif refs[g]:
            j['instances']=refs[g];j['canonical']=max(refs[g],key=lambda a:(bool(a['fsms']),sum(len(f['states']) for f in a['fsms'])))
        j['instance_count']=len(j['instances']);j['scene_count']=len({a['source'] for a in j['instances'] if a['source'].endswith('.unity')})
        j['object_names']=sorted({a['name'] or '' for a in j['instances']})
        print(j['id'], '=>',j['canonical']['name'] if j['canonical'] else None, len(refs[g]))
    data['counts']['entries_with_source_route']=sum(bool(j['canonical']) for j in data['journal_records'])
    data['counts']['special_routes']=len(missing)
    p.write_text(json.dumps(data,ensure_ascii=False,indent=2)+'\n')

if __name__=='__main__':main()
