#!/usr/bin/env python3
"""Decode Unity-text PlayMaker FSMs without third-party Python packages.

Requires macOS/system Ruby with built-in psych (yaml). API: parse_fsm(text,
source='') -> list[dict]. CLI: python3 fsm_decode.py FILE [--owner NAME]
[--fsm NAME] [--output FILE]. Selected Unity component blocks are sent to Ruby;
the entire scene is never YAML-parsed. Unknown parameter types remain explicit.
All decoded FSMs also retain lossless actionData in raw_action_data.
"""
import argparse
import json
import re
import struct
import subprocess
from pathlib import Path

RUBY = r'''
require 'yaml'; require 'json'
s = STDIN.read
s = s.gsub(/^(\s*(?:[^:\n]+:|-)[ \t]*)(on|off|yes|no)([ \t]*)$/i) { "#{$1}\"#{$2}\"#{$3}" }
s = s.gsub(/^(\s*(?:actionStartIndex|actionHashCodes|paramDataType|paramDataPos|paramByteDataSize|byteData|arrayParamSizes|customTypeSizes|actionEnabled|actionIsOpen):)[ \t]*(.*?)$/, '\1 "\2"')
puts YAML.load_stream(s).to_json
'''

TABLES = {3:'stringParams',5:'unityObjectParams',15:'fsmFloatParams',16:'fsmIntParams',
          17:'fsmBoolParams',18:'fsmStringParams',19:'fsmGameObjectParams',
          20:'fsmOwnerDefaultParams',21:'functionCallParams',22:'animationCurveParams',23:'stringParams',
          24:'fsmObjectParams',25:'fsmColorParams',28:'fsmVector3Params',
          29:'fsmRectParams',31:'fsmEventTargetParams',32:'fsmPropertyParams',35:'fsmQuaternionParams',36:'fsmPropertyParams',
          37:'fsmVector2Params',38:'fsmTemplateControlParams',39:'fsmVarParams',
          41:'fsmArrayParams',42:'fsmEnumParams'}

def ints(s):
    b = bytes.fromhex(str(s or ''))
    return list(struct.unpack('<'+'i'*(len(b)//4), b)) if b else []

def compact(v):
    if isinstance(v, dict):
        if 'variableName' in v or 'objectReferences' in v:
            return v
        if 'useVariable' in v:
            value=v.get('value',v.get('intValue'))
            return {'var':v.get('name') or None, 'stored':value} if v['useVariable'] else value
        if 'ownerOption' in v:
            return {'owner':'self'} if v['ownerOption']==0 else {'owner':compact(v.get('gameObject'))}
        return {k:compact(x) for k,x in v.items()}
    if isinstance(v,list): return [compact(x) for x in v]
    return v

def decode_actions(d):
    names=d.get('actionNames') or []
    starts=ints(d.get('actionStartIndex')); types=ints(d.get('paramDataType'))
    pos=ints(d.get('paramDataPos')); sizes=ints(d.get('paramByteDataSize'))
    pnames=d.get('paramName') or []; arr=ints(d.get('arrayParamSizes'))
    inline_events=any(t==23 and z>0 for t,z in zip(types,sizes))
    custom_sizes=ints(d.get('customTypeSizes'))
    raw=bytes.fromhex(d.get('byteData') or '')
    enabled=bytes.fromhex(d.get('actionEnabled') or '')
    def at(i):
        t=types[i]; p=pos[i]; sz=sizes[i]
        if p == -1: return None,i+1
        if t==12:
            n=arr[p]; vals=[]; j=i+1
            for _ in range(n):
                v,j=at(j); vals.append(v)
            return vals,j
        if t==40:
            n=custom_sizes[p]; fields={'custom_type':d.get('customTypeNames',[])[p]}; j=i+1
            for _ in range(n):
                key=pnames[j] or f'unnamed_{j}'; v,j=at(j); fields[key]=v
            return fields,j
        b=raw[p:p+sz]
        # Older PlayMaker action versions inline Fsm primitive + UseVariable
        # + remaining UTF-8 name in byteData rather than the typed tables.
        if t==23 and (sz>0 or inline_events): return b.decode('utf-8') or None,i+1
        if t==3 and sz>0: return b.decode('utf-8') or None,i+1
        if t==8 and sz==8: return dict(zip('xy',struct.unpack('<ff',b))),i+1
        if sz>0 and t in (15,16,17,25,28,35,37):
            count={15:4,16:4,17:1,25:16,28:12,35:16,37:8}[t]
            if len(b)>=count+1:
                if t==15: value=struct.unpack('<f',b[:4])[0]
                elif t==16: value=struct.unpack('<i',b[:4])[0]
                elif t==17: value=bool(b[0])
                else: value=dict(zip('rgba' if t==25 else 'xyzw',struct.unpack('<'+'f'*(count//4),b[:count])))
                return ({'var':b[count+1:].decode('utf-8') or None,'stored':value} if b[count] else value),i+1
        if t in TABLES and sz==0:
            table=d.get(TABLES[t]) or []
            if 0<=p<len(table): return compact(table[p]),i+1
            if t in (3,23): return None,i+1
        if t==1 and sz==1: return bool(b[0]),i+1
        if t in (0,7) and sz==4: return struct.unpack('<i',b)[0],i+1
        if t==2 and sz==4: return struct.unpack('<f',b)[0],i+1
        # Preserve evidence instead of inventing a meaning for unsupported kinds.
        return {'unknown_type':t,'position':p,'size':sz,'bytes':b.hex()},i+1
    result=[]
    for a,n in enumerate(names):
        start=starts[a]; end=starts[a+1] if a+1<len(starts) else len(types)
        params={}; i=start
        while i<end:
            key=pnames[i] or f'unnamed_{i}'; value,j=at(i)
            params[key]=value; i=j
        result.append({'type':n.rsplit('.',1)[-1], 'full_type':n,
                       'enabled':bool(enabled[a]) if a<len(enabled) else None,
                       'params':params})
    return result

def parse_fsm(text, source=''):
    docs=list(re.finditer(r'^--- !u!(\d+) &(-?\d+)[^\n]*\n',text,re.M))
    objects={}; candidates=[]
    for i,m in enumerate(docs):
        end=docs[i+1].start() if i+1<len(docs) else len(text)
        block=text[m.end():end]
        if m[1]=='1':
            name=re.search(r'^  m_Name: (.*)$',block,re.M)
            if name: objects[int(m[2])]=name[1]
        elif m[1]=='114' and re.search(r'^  fsm:\s*$',block,re.M):
            candidates.append((m,block))
    if not candidates: return []
    stream='\n---\n'.join(b for _,b in candidates)
    loaded=json.loads(subprocess.run(['ruby','-e',RUBY],input=stream,text=True,capture_output=True,check=True).stdout)
    result=[]
    for (m,block),doc in zip(candidates,loaded):
        mb=doc['MonoBehaviour']; f=mb['fsm']; base_line=text.count('\n',0,m.end())+1
        owner=mb.get('m_GameObject',{}).get('fileID')
        states=[]
        statematches=list(re.finditer(r'^    - name: (.*)$',block[:block.find('\n    events:')] if '\n    events:' in block else block,re.M))
        for k,s in enumerate(f.get('states') or []):
            line=base_line+block.count('\n',0,statematches[k].start()) if k<len(statematches) else None
            ad=s.get('actionData') or {}
            states.append({'name':s['name'],'line':line,'sequence':s.get('isSequence'),
                           'transitions':[{'event':t.get('fsmEvent',{}).get('name'),'to':t.get('toState')} for t in (s.get('transitions') or [])],
                           'actions':decode_actions(ad),'raw_action_data':ad})
        result.append({'source':source,'line':base_line,'file_id':int(m[2]),
                       'owner_id':owner,'owner':objects.get(owner),'name':f.get('name'),
                       'start_state':f.get('startState'),'states':states,
                       'global_transitions':f.get('globalTransitions'),
                       'variables':f.get('variables'),'fsm_metadata':{k:v for k,v in f.items() if k not in ('states','variables')}})
    return result

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__); p.add_argument('file'); p.add_argument('--owner'); p.add_argument('--fsm'); p.add_argument('--output'); p.add_argument('--compact',action='store_true')
    a=p.parse_args(); data=parse_fsm(Path(a.file).read_text(),a.file)
    if a.owner: data=[f for f in data if f['owner']==a.owner]
    if a.fsm: data=[f for f in data if f['name']==a.fsm]
    if a.compact:
        for f in data:
            for s in f['states']: s.pop('raw_action_data',None)
    out=json.dumps(data,ensure_ascii=False,indent=2)
    if a.output: Path(a.output).write_text(out+'\n')
    else: print(out)
