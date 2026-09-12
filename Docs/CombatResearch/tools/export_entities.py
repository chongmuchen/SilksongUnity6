#!/usr/bin/env python3
"""Export one fully decoded canonical specimen per journal record.
All sampled instance locations remain in catalog.json. Source files are read only.
"""
from build_catalog import *
from fsm_decode import parse_fsm
import bisect

def slug(s):return re.sub(r'[^A-Za-z0-9_-]+','_',s).strip('_')

def count_unknown(v):
    if isinstance(v,dict):return int('unknown_type' in v)+sum(count_unknown(x) for x in v.values())
    if isinstance(v,list):return sum(count_unknown(x) for x in v)
    return 0

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--unmapped',action='store_true');args=parser.parse_args()
    data=json.loads((OUT/'catalog.json').read_text()); groups=collections.defaultdict(list)
    export_dir=OUT/('unmapped' if args.unmapped else 'entities');export_dir.mkdir(exist_ok=True)
    if args.unmapped:
        extras=collections.defaultdict(list)
        for name,actors in data['unmapped_health_actors'].items():
            extras[re.sub(r'\s*\(\d+\)$','',name)].extend(actors)
        data['journal_records']=[{'id':name,'record_kind':'unmapped_health_object_not_an_additional_species_count',
            'instances':actors,'canonical':max(actors,key=lambda a:(not a['is_temp_scene'],sum(len(f['states']) for f in a['fsms'])))} for name,actors in extras.items()]
    for j in data['journal_records']:
        if j['canonical']:groups[j['canonical']['source']].append(j)
    validation={'schema':'combat-export-validation-v1','source_files':len(groups),'entities':[],'errors':[]}
    for n,(rel,js) in enumerate(groups.items()):
        text=(ROOT/rel).read_text(errors='replace'); docs=list(blocks(text)); byid={fid:(typ,s,ln) for typ,fid,s,ln in docs}
        selected={str(f['component_id']) for j in js for f in j['canonical']['fsms']}
        chunks=[]; originals={}
        for typ,fid,s,ln in docs:
            if typ=='1' or fid in selected:
                chunks.append(s);originals[fid]=ln
        subset=''.join(chunks)
        try:
            parsed=parse_fsm(subset,rel)
        except Exception as exc:
            validation['errors'].append({'source':rel,'error':str(exc)});print('ERROR',rel,str(exc),flush=True);continue
        fsmmap={}
        for f in parsed:
            delta=originals[str(f['file_id'])]+1-f['line']
            f['line']+=delta
            for s in f['states']:
                if s['line'] is not None:s['line']+=delta
                if not count_unknown(s['actions']):s.pop('raw_action_data',None)
            fsmmap[str(f['file_id'])]=f
        for j in js:
            actor=j['canonical']; fsms=[fsmmap[str(f['component_id'])] for f in actor['fsms'] if str(f['component_id']) in fsmmap]
            # Preserve all same-object non-FSM components and descendant colliders/damagers.
            owners={actor['game_object_id']}|{f['game_object_id'] for f in actor['fsms']}
            transforms={fid:(ref(s,'m_GameObject'),ref(s,'m_Father')) for typ,fid,s,ln in docs if typ in ('4','224')}
            parents={go:transforms.get(parent,(None,None))[0] for go,parent in transforms.values()}
            for go in parents:
                q=go;seen=set()
                while q and q not in seen:
                    if q==actor['game_object_id']:owners.add(go);break
                    seen.add(q);q=parents.get(q)
            components=[]
            for typ,fid,s,ln in docs:
                if ref(s,'m_GameObject') in owners and typ not in ('1','23','33','212','120','199','198') and '\n  fsm:\n' not in s:
                    sm=re.search(r'm_Script:.*guid: ([0-9a-f]{32})',s)
                    components.append({'file_id':fid,'game_object_id':ref(s,'m_GameObject'),'unity_class_id':typ,'line':ln,'script':data['script_guids'].get(sm[1]) if sm else None,'serialized_yaml':s})
            game_objects=[{'file_id':fid,'name':field(s,'m_Name'),'line':ln,'serialized_yaml':s} for typ,fid,s,ln in docs if typ=='1' and fid in owners]
            entity={'schema':'silksong-combat-entity-v1','journal':{k:v for k,v in j.items() if k not in ('instances','canonical','recording_references')},
                    'specimen':actor,'source_sha256':hashlib.sha256(text.encode()).hexdigest(),
                    'fsms':fsms,'game_objects':game_objects,'components':components,'recording_references':j.get('recording_references',[]),
                    'limits':['Static serialized specimen; no runtime timing capture.','Scene variants may override values; see catalog.json instances.',
                              'External fileID/GUID dependencies remain explicit; do not replace with guessed values.']}
            filename=slug(j['id'])+'.json'; (export_dir/filename).write_text(json.dumps(entity,ensure_ascii=False,indent=2)+'\n')
            states=sum(len(f['states']) for f in fsms); acts=sum(len(s['actions']) for f in fsms for s in f['states'])
            empty=[]; dangling=[]
            for f in fsms:
                names={s['name'] for s in f['states']}
                for s in f['states']:
                    for t in s['transitions']:
                        if not t['to']:empty.append([f['name'],s['name'],t['event']])
                        elif t['to'] not in names:dangling.append([f['name'],s['name'],t['to']])
            validation['entities'].append({'id':j['id'],'file':filename,'fsms':len(fsms),'states':states,'actions':acts,
                'unknown_parameters':count_unknown(fsms),'empty_transition_targets':empty,'dangling_transitions':dangling,
                'fsm_counts_match_census':len(fsms)==len(actor['fsms'])})
        if n%10==0:print(json.dumps({'source':n+1,'of':len(groups),'entities':len(validation['entities'])}),flush=True)
    validation['total_states']=sum(e['states'] for e in validation['entities']);validation['total_actions']=sum(e['actions'] for e in validation['entities'])
    validation['unknown_parameters']=sum(e['unknown_parameters'] for e in validation['entities'])
    (OUT/('unmapped-validation.json' if args.unmapped else 'validation.json')).write_text(json.dumps(validation,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({k:v for k,v in validation.items() if k not in ('entities',)},ensure_ascii=False),flush=True)

if __name__=='__main__':main()
