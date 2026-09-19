# SilksongUnity6 — Agent Reference

> Purpose: enable an unfamiliar coding agent to locate, understand, and progressively reuse this recovered Unity project's implementation in an initially empty game project.
> Authority: **the current local project**, including its recovery work and local modifications. This is not an assertion of access to Team Cherry's original source or exact shipped behavior.
> Language: English with Chinese retrieval aliases. All `Assets/...`, `Packages/...`, and `ProjectSettings/...` paths are relative to the **reference project root**, not the new game's root.

## START HERE

1. Identify the requested behavior and use the routing table below.
2. Read only the relevant chapter section (`data/document-sections.tsv` provides line ranges); query the TSV appendices for exact files/objects.
3. Read the located source implementation **and its actual serialized instance**. Resolve referenced settings, animation, FSM, audio, materials, and services.
4. Consult [the reuse procedure](50_REUSE_IN_AN_EMPTY_PROJECT.md) before deciding a migration boundary.
5. Record evidence and verify the behavior in the target project. Treat static findings and runtime observations as separate evidence.

Do not load the entire reference pack, a giant scene, or an entire TSV into the model context. `rg`, exact TSV column filters, source symbol ranges, and Unity YAML object blocks are the primary retrieval units. The main file is the entry point; the adjacent chapters and data files are its appendices. Preserve the directory when moving this reference.

## Task router

| Intent / retrieval aliases | Read first | Follow-up evidence |
|---|---|---|
| All folders/resource kinds 全目录、资源类型 | [05 Directory atlas](05_DIRECTORY_ATLAS.md) | Physical counts, source folders, scene filename families and configuration boundaries |
| How do I find anything? 索引、定位、追踪 | [00 Retrieval](00_RETRIEVAL.md) | Full source symbols, GUID map, component bindings, scene/FSM tables |
| Move, jump, fall, dash, sprint, wall actions 移动、跳跃、冲刺、疾跑、爬墙 | [10 Player and combat](10_PLAYER_AND_COMBAT.md) | `HeroController`, `HeroControllerConfig`, current crest config, `Hero_Hornet` bindings |
| Slash, downspike/pogo, parry, weapon windows 挥击、下劈、反弹、格挡、判定帧 | [10 Player and combat](10_PLAYER_AND_COMBAT.md) | `NailSlash`, `Downspike`, `DamageEnemies`, tk2d clips/frame events |
| Damage, invulnerability, knockback, hit stop, death 伤害、无敌、击退、顿帧、死亡 | [10 Player and combat](10_PLAYER_AND_COMBAT.md) | `HealthManager`, `HeroBox`, `CustomPlayerLoop`, death FSM and pooled effects |
| Enemy/Boss behavior, phases, projectiles 怪物、Boss、阶段、弹幕 | [10 Player and combat](10_PLAYER_AND_COMBAT.md) | Existing combat catalog → chosen scene instance → decoded FSM → action implementation |
| Room layout, terrain, collision, tilemap 场景、关卡、地形、碰撞 | [20 Scenes and presentation](20_SCENES_AND_PRESENTATION.md) | Scene object hierarchy, `tk2dTileMap`, persisted meshes, physics/layer settings |
| Camera, boundaries, transitions 镜头、边界、切场景 | [20 Scenes and presentation](20_SCENES_AND_PRESENTATION.md) | `GameManager`, transition points, `SceneManager`, camera lock areas |
| Sprites, animation, background layering 美术、精灵、动画、前后景 | [20 Scenes and presentation](20_SCENES_AND_PRESENTATION.md) | tk2d collection/animation assets versus Unity Animator assets, texture import metadata |
| Shader, material, lighting, fog, particles 材质、光照、雾、粒子、特效 | [20 Scenes and presentation](20_SCENES_AND_PRESENTATION.md) | Current recovered Shader sources and `Docs/ShaderRecovery` provenance |
| Sound, music, atmosphere, mixer 音效、音乐、环境音、混音 | [20 Scenes and presentation](20_SCENES_AND_PRESENTATION.md) | Audio event/source → clip GUID; music/atmos cue → channel/snapshot |
| Boot, singleton/service initialization 启动、初始化、管理器 | [30 Systems and progression](30_SYSTEMS_AND_PROGRESSION.md) | Addressable entries, startup scenes, core manager prefabs; [40 Runtime](40_RUNTIME_AND_DEPENDENCIES.md) |
| Save/load, checkpoints, persistence 存档、读档、复活点、持久化 | [30 Systems and progression](30_SYSTEMS_AND_PROGRESSION.md) | `GameManager`, player/scene data, save queue, platform store/codec |
| Unlock abilities, crests, tools, inventory 能力、纹章、工具、背包 | [30 Systems and progression](30_SYSTEMS_AND_PROGRESSION.md) | Lists/data assets → manager → actual pickup/equipment FSM → player config |
| Currency, items, shops, crafting 货币、道具、商店、制作 | [30 Systems and progression](30_SYSTEMS_AND_PROGRESSION.md) | Currency/item managers, serialized definitions, transaction FSM |
| NPC, dialogue, quests, rewards 任务、对话、奖励 | [30 Systems and progression](30_SYSTEMS_AND_PROGRESSION.md) | `QuestManager`, quest assets/actions, NPC instance, delivery/reward FSM |
| UI, HUD, map, localization 界面、地图、文本、多语言 | [30 Systems and progression](30_SYSTEMS_AND_PROGRESSION.md) | Prefab hierarchy, UI scripts, text keys/sheets, font assets, DLL boundaries |
| Input, platform, achievements 按键、手柄、平台、成就 | [30 Systems and progression](30_SYSTEMS_AND_PROGRESSION.md) | Current Input System adapter and assets, platform managers/plug-ins |
| PlayMaker states/actions/events 状态机、事件、动作 | [40 Runtime and dependencies](40_RUNTIME_AND_DEPENDENCIES.md) | Global FSM variables, event routes, action type → source/DLL; decode one selected machine |
| Pools, asynchronous loads, update order 对象池、异步加载、执行顺序 | [40 Runtime and dependencies](40_RUNTIME_AND_DEPENDENCIES.md) | Global versus typed pools, initialization interfaces, metadata execution order |
| Blank-project implementation sequence 移植、复用、最小依赖 | [50 Reuse](50_REUSE_IN_AN_EMPTY_PROJECT.md) | Evidence-backed feature packet; one playable slice at a time |
| Can I trust this finding? What is missing? 覆盖、验证、缺失、版本 | [90 Coverage](90_COVERAGE_AND_LIMITS.md) | Snapshot hashes, parser results, restored data anomalies, current worktree provenance |

## What this project actually contains

- `Assets/Scripts/Assembly-CSharp/`: a major source of Silksong gameplay, progression, tools, quest, event, pooling, and custom action code. The name describes an assembly/export layout, not low importance.
- `Assets/Scripts/ProjectCode/`: curated game/FSM/settings/utilities folders. Useful navigation, but not a complete partition of the game's implementation.
- `Assets/Scripts/MixedIntegrations/` and `Assets/Scripts/ThirdParty/`: integrations and many game-facing PlayMaker actions. A folder named “ThirdParty” is not proof an action is generic or unused.
- `Assets/PlayMaker/`: action/editor source plus binaries. The core state-machine runtime is supplied as a DLL.
- `Assets/Scripts/TeamCherry/TeamCherry.TK2D/`: a separate source assembly for the sprite/animation/tile runtime. This is central to presentation and attack timing.
- `Assets/Prefabs/`, `Assets/GameObject/`, `Assets/Scenes/`, `Assets/MonoBehaviour/`, `Assets/Data Assets/`: runtime objects and serialized configuration, including behavior that has no dedicated C# class.
- `Assets/AnimationClip/`, `Assets/Animations/`, `Assets/AnimatorController/`, `Assets/Animation Controllers/`, `Assets/AnimatorOverrideController/`, `Assets/Sprite/`, `Assets/Texture2D/`, `Assets/Textures/`, `Assets/Collections/`: several parallel exported/organized resource locations. Resolve GUIDs instead of guessing by directory name.
- `Assets/Audio/`, `Assets/AudioClip/`, `Assets/Material/`, `Assets/Materials/`, `Assets/Shader/`, `Assets/Shaders/`: presentation resources, imported/serialized data, and recovered sources.
- `Assets/AddressableAssetsData/`, `Assets/Resources/`, `Packages/`, `ProjectSettings/`, `.meta` files: initialization, asset lookup, dependencies, import settings, identity, and engine behavior.
- `Assets/Editor/`, `Docs/`, `tools/`: recovery, research, editor utilities, and prior evidence. They can describe or modify derived content; distinguish their outputs from original instances.

## Non-negotiable interpretation rules

1. **File existence is not runtime reachability.** Old Hollow Knight/Godmaster names, research scenes, test assets, and dormant branches coexist with Silksong paths. Establish a binding or call route for the selected use case.
2. **C# is only one part of implementation.** FSM order/variables, animation events, collision geometry, layer masks, configuration assets, child names, and pooled prefab state often carry the behavior.
3. **Identity is composite.** A scene object is `(source path, GameObject fileID)`; a component adds its fileID; an FSM adds its name. Names alone are not unique. External objects require GUID **and** fileID.
4. **A canonical enemy sample is one instance.** Use the combat catalog's `instances` for the requested encounter. A similarly named boss can have a different fight, variant, phase, or arena.
5. **Source-derived behavior is not proven shipped behavior.** This recovery includes deliberate compatibility changes, known missing actions, and malformed serialized data.
6. **Read the overload and lifecycle.** A method named “save” may queue work; a reward accessor may not grant the reward; an audio parameter may be unused; activation may start callbacks before initialization completes.
7. **Use stable symbols and fresh hashes.** Line numbers are snapshot conveniences. If a source hash differs, locate the symbol/object again and re-evaluate the affected claim.
8. **Navigation indexes are evidence locators.** A syntactic type reference is not a compiled call graph. A GUID edge is not proof the asset is loaded. An unresolved GUID is not automatically a missing asset.

## Evidence levels

| Level | Meaning |
|---|---|
| `INVENTORIED` | File/identity/hash recorded; binary media may not have been viewed or heard |
| `STRUCTURALLY_INDEXED` | Source declarations or Unity text bindings/FSM identities extracted from full file content |
| `SEMANTICALLY_TRACED` | Selected source logic and relevant configuration were read and the chain explained in a chapter |
| `RUNTIME_VERIFIED` | Behavior observed under a stated Unity version, scene, input/setup, and test procedure |

This documentation pass establishes the first two levels across the stated inventory and the third for the documented core flows. It does **not** claim all 520,943 source lines, all scene variants, all media, or every DLL implementation have received equal semantic/runtime review. Exact scope and validation results live in [90](90_COVERAGE_AND_LIMITS.md). Future work should increase the recorded evidence level for the feature being implemented.

## Existing research to retain

| Reference | Reuse |
|---|---|
| [Combat research](../CombatResearch/README.md) | Enemy catalog, source action index, decoded parameters, selected complete cases, known gaps and validation tools |
| [Combat AI specification](../CombatResearch/丝之歌战斗逻辑_AI复现规格.md) | Detailed combat contracts; open the relevant section after locating an entity |
| [Scene research](../SceneResearch/) | Bone_02 derived hierarchy, tilemap analysis, reference teleport and demos |
| [Shader recovery](../ShaderRecovery/README.md) | Recovered shader provenance and validation boundaries |
| [Original learning plan](../Silksong-Learning-Plan.md) | Background roadmap; planned work is not proof it was completed |

## Reference contract for the next agent

For every implementation task, leave a compact handoff with:

`feature → reference version/hash → entry symbols → selected scene/Prefab + object IDs → data/assets/events → copied/adapted dependencies → target implementation → checks performed → remaining uncertainty`.

The new project's own design and subsequent user instructions determine what to implement. This reference explains how the local reference project works; it does not require reproducing every historical dependency or recovery workaround.
