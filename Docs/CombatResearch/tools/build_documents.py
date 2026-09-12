#!/usr/bin/env python3
"""Assemble two audience-specific books and audit the supporting data."""
from build_catalog import *
from export_entities import slug,count_unknown
from urllib.parse import unquote

BASE=ROOT/'Docs/CombatResearch';PARTS=BASE/'parts'

def link(label,path,line=None):
    p=str(path if str(path).startswith('/') else ROOT/path)
    if line:p+=':'+str(line)
    return f'[{label}](<{p}>)'

def esc(s):return str(s).replace('|','\\|').replace('\n',' ')

def listfmt(xs,limit=None):
    vals=list(dict.fromkeys(str(x) for x in xs if x not in (None,'')))
    return '、'.join('`'+x+'`' for x in (vals[:limit] if limit else vals)) or '—'

def val(v):
    if isinstance(v,dict):
        if 'var' in v:return '$'+str(v['var'])
        return json.dumps(v,ensure_ascii=False,separators=(',',':'))
    if isinstance(v,float):return f'{v:.6g}'
    return str(v)

def index_actions(entities):
    used=collections.defaultdict(set)
    for e in entities:
        for f in e['fsms']:
            for s in f['states']:
                for a in s['actions']:used[a['full_type']].add(e['journal']['id'])
    files=collections.defaultdict(list)
    for root in (ROOT/'Assets/Scripts',ROOT/'Assets/PlayMaker/Actions'):
        for p in root.rglob('*.cs'):files[p.stem].append(str(p.relative_to(ROOT)))
    records=[]
    for typ,ids in sorted(used.items()):
        name=typ.rsplit('.',1)[-1];paths=files.get(name,[])
        if not paths and '+' in name:paths=files.get(name.split('+')[0],[])
        if not paths:paths=[p for stem,ps in files.items() if stem.casefold()==name.casefold() for p in ps]
        binary={'FadeNestedFadeGroup':'Assets/Plugins/TeamCherry.NestedFadeGroup.dll',
                'MissingAction':'Assets/Plugins/PlayMaker.dll'}.get(name)
        records.append({'full_type':typ,'used_by':sorted(ids),'candidate_source_paths':paths,'binary_candidate':binary,
                        'resolution':'filename_candidates_require_namespace_check' if paths else 'binary_dependency_semantics_not_decompiled' if binary else 'engine_or_combined_source_search_required'})
    (OUT/'action_index.json').write_text(json.dumps(records,ensure_ascii=False,indent=2)+'\n')
    return records

def make_atlas(catalog,entities,ai=False):
    byid={e['journal']['id']:e for e in entities}
    rows=['\n## 全量附录：237 条图鉴记录的复现入口\n',
      '本附录严格按主图鉴顺序排列。HP列是扫描到的**序列化初值集合**，包括占位/特殊值，不能直接视作战斗有效血量。`路线`表示找到登记/特殊组件路线而非普通生命主体。FSM/状态数量属于该规范样本及子FSM。全部实例位置见 '+link('catalog.json',OUT/'catalog.json')+'。\n',
      '|序号|图鉴内部ID|HP初值集合|FSM / 状态|完整机器数据|\n|---:|---|---|---|---|']
    for j in catalog['journal_records']:
        e=byid[j['id']];hp=sorted({str(a['hp']) for a in j['instances'] if a['hp'] is not None},key=lambda s:float(s) if re.match(r'^-?[\d.]+$',s) else 0)
        rows.append(f"|{j['master_order']}|{esc(j['id'])}|{esc('/'.join(hp) or '路线')}|{len(e['fsms'])} / {sum(len(f['states']) for f in e['fsms'])}|{link('JSON',OUT/'entities'/(slug(j['id'])+'.json'))}|")
    rows.append('\n### 每条记录的行为结构与决策入口\n')
    rows.append('下面的摘要由解码状态/事件生成，方便定位；状态名只作为索引线索。实际条件看动作参数，空转移不补全，未列出的状态仍完整保存在对应JSON中。可被图鉴登记的交互对象与战斗体明确区别。\n')
    for j in catalog['journal_records']:
        e=byid[j['id']];a=e['specimen'];fs=e['fsms']
        rows.append(f"\n#### {j['master_order']:03d} · {j['id']}\n")
        rows.append('样本：'+link(str(a['name']),a['source'],a['line'])+'；图鉴：'+link(j['key'],j['path'])+'。已索引 '+str(j['instance_count'])+' 个实例/登记组件，来自 '+str(j['scene_count'])+' 个场景。证据方式：`'+a['evidence']+'`。\n')
        if 'reference_component' in a['evidence']:
            rows.append('**专用路线**：这里导出的可能是图鉴登记器、发射/召唤控制器或交互器；应与“特殊条目”章节合读，不能为它自动添加常规HP和普通死亡。\n')
        if not fs:
            rows.append('此样本没有PlayMaker FSM；行为由以下挂载脚本/组件实现：'+listfmt([Path(x).stem for x in a['components']])+ '。原始组件与绑定保存在JSON的components中。\n')
            continue
        main=max(fs,key=lambda f:(f['owner_id']==int(a['game_object_id']) if a['game_object_id'] else False,f['name'] in ('Control','Behaviour'),len(f['states'])))
        rows.append('主要状态机：`'+str(main['name'])+'`，初态 `'+str(main['start_state'])+'`，'+str(len(main['states']))+' 个状态。并行/子状态机：'+listfmt([str(f['owner'])+'/'+str(f['name']) for f in fs if f is not main])+ '。\n')
        states=main['states']; combat=[s['name'] for s in states if re.search(r'attack|slash|shoot|spit|throw|charge|swoop|dive|slam|stomp|bite|roll|burst|roar|summon|spear|stab|counter|flare|tornado|bomb|beam',str(s['name']),re.I)]
        movement=[s['name'] for s in states if re.search(r'idle|walk|patrol|chase|fly|turn|evade|hop|jump|hide|burrow',str(s['name']),re.I)]
        interrupt=[s['name'] for s in states if re.search(r'hit|stun|death|dead|die|recover|phase|defeat',str(s['name']),re.I)]
        rows.append('运动/等待节点：'+listfmt(movement,18)+'。攻击相关节点：'+listfmt(combat,24)+'。受击/恢复/阶段相关节点：'+listfmt(interrupt,15)+'。完整节点不受本摘要的显示上限限制，见JSON。\n')
        choices=[s for s in states if re.search(r'choice|choose|select|range check|attack check|distance check|next attack|next move|phase check',str(s['name']),re.I)]
        if not choices:choices=[s for s in states if len(s['transitions'])>=2][:3]
        if choices:
            rows.append('|决策节点|条件/动作线索（保留变量引用）|事件→目标|\n|---|---|---|')
            for s in choices[:8 if not ai else 12]:
                conditions=[]
                for action in s['actions']:
                    if action['enabled'] and re.search(r'Compare|RandomEvent|AlertRange|BoolTest|Check|Distance',action['type']):
                        fields=action['params']
                        keys=[k for k in fields if not re.search(r'gameObject|store|target|eventTarget',k,re.I)]
                        description=action['type']+'('+', '.join(k+'='+val(fields[k]) for k in keys[:7])+')'
                        conditions.append(description)
                edge='; '.join(str(t['event'])+' → '+str(t['to'] or '∅（空目标）') for t in s['transitions'])
                rows.append('|'+esc(s['name'])+'|'+esc('; '.join(conditions) or '以该节点actions为准')+'|'+esc(edge or '无本地转移；检查全局事件/持续动作')+'|')
        globals=[]
        for f in fs:
            for t in (f.get('global_transitions') or []):
                if isinstance(t,dict):globals.append(str(f['name'])+':'+str((t.get('fsmEvent') or {}).get('name'))+'→'+str(t.get('toState')))
        rows.append('\n全局退出/旁路：'+listfmt(globals,12)+'。移植验收应覆盖上述分支、当前攻击中受击、目标跨身/失去视线、退出房间及对象重置；具体技能时间与命中开关读取 `actions` 和组件动画引用。\n')
    return '\n'.join(rows)

def normalize_links(s):
    # Filesystem links use literal spaces in angle brackets, not URL-escaped paths.
    def fix(m):return '](<'+unquote(m.group(1).strip('<>'))+'>)'
    return re.sub(r'\]\((<?/Users/[^)]+)\)',fix,s)

def main():
    catalog=json.loads((OUT/'catalog.json').read_text());entities=[json.loads(p.read_text()) for p in sorted((OUT/'entities').glob('*.json'))]
    supplemental=[json.loads(p.read_text()) for p in sorted((OUT/'unmapped').glob('*.json'))]
    action_index=index_actions(entities+supplemental)
    primary_action_types=len({a['full_type'] for e in entities for f in e['fsms'] for s in f['states'] for a in s['actions']})
    core=(PARTS/'core.md').read_text();core_ai=core.split('## A. 给 AI 的实现规格',1)[1].split('## B. 给人学习的解释',1)[0]
    core_human=core.split('## B. 给人学习的解释',1)[1]
    mobs=(PARTS/'mobs.md').read_text()
    mobs_ai=mobs.split('<!-- AI_SPEC_START -->')[1].split('<!-- AI_SPEC_END -->')[0]
    mobs_human=mobs.split('<!-- HUMAN_GUIDE_START -->')[1].split('<!-- HUMAN_GUIDE_END -->')[0]
    specials=(PARTS/'specials.md').read_text()
    audit=(PARTS/'unmapped-audit.md').read_text() if (PARTS/'unmapped-audit.md').exists() else ''
    validation=json.loads((OUT/'validation.json').read_text())
    metrics='\n## 数据完整性与复现验收状态\n\n'+f"237 条记录均有导出文件；共有 {validation['total_states']:,} 个状态、{validation['total_actions']:,} 个动作条目（包含禁用动作），{primary_action_types} 种完整动作类型。连同补充对象共索引 {len(action_index)} 种动作类型。未知参数类型占位：{validation['unknown_parameters']}；源文件解析错误：{len(validation['errors'])}。这些是静态提取校验，**不代表实机行为测试已通过**。\n\n"+link('完整验证结果',OUT/'validation.json')+'；'+link('动作到源码候选索引',OUT/'action_index.json')+'。动作索引的候选文件须检查namespace/assembly，找不到同名文件不等于动作不存在，可能来自合并源码或DLL。\n'
    missing=[]
    for e in entities:
        for f in e['fsms']:
            for s in f['states']:
                for a in s['actions']:
                    if a['type']=='MissingAction':missing.append([e['journal']['id'],f['source'],f['name'],s['name'],s['line'],a['params'].get('actionName'),a['enabled']])
    metrics+='\n### 当前恢复工程的明确缺口\n\n参数类型解码完整不等于原动作实现完整。以下3处启用的 `MissingAction` 是源资产里就存在的占位，保留了原动作名，但没有原始动作参数与实现闭环。其影响范围需对照原版或找到更完整资产验证；不能静默当作空操作后宣布原版复现成功。\n\n|条目|FSM / 状态|缺失动作名|证据|\n|---|---|---|---|\n'
    for eid,src,fsm,state,line,name,enabled in missing:metrics+='|'+esc(eid)+'|'+esc(str(fsm)+' / '+str(state))+'|`'+str(name)+'`|'+link('原状态',src,line)+'|\n'
    metrics+='\n此外，PlayMaker内核事件重入、部分Stun历史变量的类型绑定、特定零售版的窗口时序与所有外部资源绑定尚未经过实机验证。六个精读案例已给出可实施的原始合同与验收方法；不能据此把全237条的每个战斗版本都标为“已实机复现”。\n'
    if supplemental:
        sv=json.loads((OUT/'unmapped-validation.json').read_text())
        audit+='\n## 初次未匹配集合的完整补充导出\n\n105个原始名称去掉尾部实例编号后导出为41个规范对象文件，包含 '+str(sv['total_states'])+' 状态、'+str(sv['total_actions'])+' 动作；未知解码类型 '+str(sv['unknown_parameters'])+'。这里有已映射Boss部位、真实敌人变体以及机关/尸体，所以**不是额外41种敌人，也不能直接与237相加作物种数**。各项分类与证据见上面的审计表。\n\n|对象组|规范样本|完整补充规格|\n|---|---|---|\n'
        for e in supplemental:
            a=e['specimen'];eid=e['journal']['id']
            audit+='|'+esc(eid)+'|'+link(str(a['name']),a['source'],a['line'])+'|'+link('JSON',OUT/'unmapped'/(slug(eid)+'.json'))+'|\n'
    (OUT/'known-gaps.json').write_text(json.dumps({'active_missing_actions':missing,'scope':'Serialized recovery gaps, not invented gameplay behavior.'},ensure_ascii=False,indent=2)+'\n')
    commands='''
## 更新文档与在项目中继续研究

在项目根目录执行以下步骤即可重新建立目录和数据；这些工具只读取游戏资源，输出到 Docs/CombatResearch。

```bash
python3 Docs/CombatResearch/tools/build_catalog.py
python3 Docs/CombatResearch/tools/resolve_specials.py
python3 Docs/CombatResearch/tools/export_entities.py
python3 Docs/CombatResearch/tools/export_entities.py --unmapped
python3 Docs/CombatResearch/tools/build_documents.py
python3 Docs/CombatResearch/tools/validate_documents.py
```

解析器使用 Python 标准库与 macOS 自带 Ruby/Psych。移到其他系统时需要相应 Ruby/YAML 环境。只导出某个现有场景的指定对象可用：

```bash
python3 Docs/CombatResearch/tools/fsm_decode.py \\
  Assets/Scenes/Hornet/Bone_East_12.unity \\
  --owner 'Lace Boss1' --fsm Control --compact --output /tmp/lace-control.json
```

此命令导出该对象指定FSM；正式实现还需其子FSM、碰撞、动画与场景导演。不要误把这个单FSM命令的结果当作完整Boss。新版本工程应重新计算引用与SHA-256，再比较状态、动作参数、动画事件、组件和每个场景的覆盖，不能只比较HP。

实际复现验收应输出：使用的场景与版本、已解析绑定清单、玩家输入与随机序列、原实现/复现的事件轨迹、窗口和轨迹误差、通过/失败/未运行的测试表。文中列出的实验是待执行的验收规格，本文没有代填通过结果。
'''
    ai='\n\n'.join([(PARTS/'framing-ai.md').read_text(),'## 共享运行时实施合同\n'+core_ai,mobs_ai,(PARTS/'bosses-ai.md').read_text(),specials,metrics,audit,make_atlas(catalog,entities,True),commands])
    human='\n\n'.join([(PARTS/'framing-human.md').read_text(),'## 共享机制：先建立四条并行的因果线\n'+core_human,mobs_human,(PARTS/'bosses-human.md').read_text(),specials,
        '## 实现时可直接查用的共享规则\n\n为了让这本学习版能够独立用于复现，下列部分保留完整的伤害、方向盾、击退、调度和测试合同，不要求先阅读AI版。\n'+core_ai,
        '## 小怪实施参数与完整边表\n\n前三课解释为何这样设计；下面给出同三只小怪的完整参数合同、事件边表和伪代码，供实际动手时核对。\n'+mobs_ai,
        '## Boss 实施参数与状态查询\n\n前文按战斗体验逐招解释；这里补上可供独立实现的精确合同与完整状态表。\n'+(PARTS/'bosses-ai.md').read_text(),metrics,audit,make_atlas(catalog,entities),commands])
    for name,s in [('丝之歌战斗逻辑_AI复现规格.md',ai),('丝之歌战斗逻辑_人类学习版.md',human)]:
        if 'AI复现' in name:
            toc='\n## 阅读导航\n\n[共享运行时](#shared-runtime) · [三个小怪的实施规格](#mob-cases) · [三个Boss的实施规格](#boss-cases) · [特殊图鉴路线](#special-cases) · [校验与明确缺口](#known-gaps) · [237条全量目录](#full-atlas)\n'
            anchors={'## 共享运行时实施合同':'shared-runtime','## AI 精确规格：范围、证据和读取约定':'mob-cases',
                     '## 典型 Boss 的可执行规格':'boss-cases'}
        else:
            toc='\n## 阅读导航\n\n[共享机制](#shared-runtime) · [小怪三课](#mob-cases) · [Boss三课](#boss-cases) · [特殊图鉴路线](#special-cases) · [独立实现的参数参考](#implementation-reference) · [校验与明确缺口](#known-gaps) · [237条全量目录](#full-atlas)\n'
            anchors={'## 共享机制：先建立四条并行的因果线':'shared-runtime',
                     '## 典型 Boss 精读：从表现还原可以实现的系统':'boss-cases',
                     '## 实现时可直接查用的共享规则':'implementation-reference'}
            if mobs_human.strip():s=s.replace(mobs_human,'<a id="mob-cases"></a>\n'+mobs_human,1)
        anchors.update({'# 非普通 HealthManager 战斗条目：补充机制':'special-cases',
                        '## 数据完整性与复现验收状态':'known-gaps',
                        '## 全量附录：237 条图鉴记录的复现入口':'full-atlas'})
        for heading,anchor in anchors.items():
            if heading in s:s=s.replace(heading,'<a id="'+anchor+'"></a>\n\n'+heading,1)
        if '<a id="special-cases">' not in s:s=s.replace(specials,'<a id="special-cases"></a>\n'+specials,1)
        first=s.index('\n');s=s[:first+1]+toc+s[first+1:]
        p=BASE/name;p.write_text(normalize_links(s));print(name,len(s),'chars')
    print('action types',len(action_index))

if __name__=='__main__':main()
