# 90 — Coverage, provenance, validation and unresolved boundaries

This page prevents future agents from confusing a broad inventory with a verified recreation. The source of truth is the current local recovered `SilksongUnity6` project; claims about original/retail behavior require additional evidence.

## 90.1 Snapshot and scope

See [snapshot.json](data/snapshot.json) for the exact UTC time, Git HEAD, initial dirty worktree, totals and extraction methods. The base Git revision is `4b53c3a6e6300363aeee553a8b11c37c7538d34b`; content hashes include local changes and untracked research material, so checking out that commit alone does not reproduce this snapshot.

Input scope: all loose files under `Assets`, `Packages`, `ProjectSettings`, `RecoveredPlayerAssemblies`, existing `Docs` and `tools`, plus root solution/project files and Git import configuration. Excluded: `.git`, `Library`, `Temp`, `Logs`, `obj`, IDE/user state, `.DS_Store`, Python bytecode caches, and the newly generated reference directory itself. The installed package cache was consulted separately to classify unresolved package GUIDs; its contents are not part of the frozen source inventory.

The original worktree already had edits to `DebugDrawColliderRuntime.cs`, tk2d `Layer.cs` and `tk2dTileMap.cs`, plus untracked demo/editor/research files. This task preserves those files and describes the content actually present. `Docs/SceneResearch/Bone_02_Readable.md` explicitly describes a derived hierarchy copy. The current input compatibility layer, save codec and recovered shaders also require local-recovery attribution.

## 90.2 Measured coverage

| Item | Snapshot count | What was done |
|---|---:|---|
| Input files | 114,909 | Inventoried with SHA-256; includes metadata and existing research |
| C# files under Assets | 4,814 | Full file bytes parsed/indexed; core routes additionally read semantically |
| Additional research C# file | 1 | `tools/shader_readability/ShaderCompileComparison.cs`; not game runtime code |
| Total C# lines | 521,267 | 520,943 under Assets plus 324 in the research source |
| Source symbol rows | 70,604 | Syntactic declarations/fields/events/methods/enum members |
| Candidate source type-reference rows | 16,931 | Lexical identifier links; not a compiler call graph |
| Scenes | 594 | All loose `.unity` files, including variants/legacy/research content |
| Prefabs | 1,947 | All loose `.prefab` files, including exported clip libraries |
| Unity text assets parsed for structure/references | 38,701 | Full-file GUID occurrences and selected serialized object structures |
| Script bindings | 551,524 | MonoBehaviour→script identities, owners and source/component anchors; 16 shards |
| Serialized FSM definitions | 18,134 | 17,210 in scenes, 705 in prefabs, 219 in `.asset` templates |
| FSM instance→template bindings | 5,042 | Explicit component `fsmTemplate` links |
| Distinct serialized action type strings | 1,292 | Includes one empty-name category; implementation resolution records confidence |
| GUID occurrence rows | 316,793 | Source+GUID aggregation, classified by reference kind |
| Unity object-reference rows | 316,483 | GUIDs appearing inside `{fileID: ..., guid: ...}` references |
| Addressable group entries | 611 | Explicit group address→GUID/path rows |
| Explicit `m_AssetGUID` references | 9 | Separate AssetReference field index |
| TransitionPoint components | 1,514 | Static source/entry-gate destinations and selected fields; not all dynamic travel routes |
| tk2d clip definitions | 8,710 | Library/component/clip identity, fps, frame count and event frame indices |
| tk2d frames | 46,940 | Collection GUID/fileID, sprite index and event payload |
| Source string literals | 21,881 | Event/name/resource/reflection search candidates |
| Source execution-order rows | 3,728 | Explicit metadata order and/or attribute presence; not a runtime schedule proof |

Media inventory under `Assets` includes 9,360 OGG files, 2,582 PNG files, 167 shaders, 1,507 Unity `.anim` clips, 814 Animator controllers, 43 override controllers and 13 mixers. Media bytes were hashed and their bindings traced where documented; this does not mean every sound was heard or every sprite/frame was visually reviewed.

## 90.3 Semantic reading coverage

| Area | Evidence deepened in this pass | Remaining distinction |
|---|---|---|
| Player/movement/combat | Major HeroController routes, actual hero config/prefab, input clocks, attack objects, hit windows, rebound, damage scheduling, invulnerability/death, selected enemy/Boss state graphs | Every crest move, tool, attack branch and encounter has not been replayed or equally explained |
| Scenes/presentation | Boot/reference rooms, gates, tilemap recovery, camera bounds/projection, sprite→atlas→material/shader chains, tk2d/Animator boundaries, audio events/music/atmos routing | Every room composition, transition override, visual artifact and sound mix remains instance-specific |
| Systems/progression | Manager initialization, save queue/codec/platform route, actual ability-grant examples, tools/crests, item/currency/quest/reward/interaction contracts | All shops, quest branches, NPC dialogue, UI flows and platform services have not been exhaustively simulated |
| Infrastructure | Event/FSM helpers, template indirection, custom fixed loop, two object-pool systems, initialization interfaces, Addressable wrappers and actual configuration | Core DLL internals, engine-native behavior and every third-party subsystem remain binary/runtime boundaries |
| Whole loose-source tree | Complete input-byte pass plus syntactic declaration/type/literal extraction and exact file hashes | Static extraction is not line-by-line semantic proof for 521,267 lines |

Each domain chapter includes its own reading ledger. The existing CombatResearch report adds prior static entity analysis: 237 catalog records, 237 canonical exports, 41 supplemental objects and selected detailed cases. Those figures describe that research's scope; they are not the total count of all enemies, all behaviors or all scene instances in this project.

## 90.4 Parser and indexing boundaries

- C# extraction uses tree-sitter-c-sharp 0.23.1. [source-parse-errors.json](data/source-parse-errors.json) records **35 files** with parser errors, all in PlayMaker action/editor source with conditional/preprocessor patterns. These are extraction warnings, not Unity compile-error claims. Use raw source and actual compilation conditions for those files; partial declarations may be incomplete.
- [source-encoding-warnings.json](data/source-encoding-warnings.json) records one source file with non-UTF-8 bytes. Original bytes/hashes were preserved; readable index text uses replacement characters where decoding requires them.
- Identically named/nested/generic types, preprocessor alternatives, extension methods, reflection, interfaces and DLL types prevent lexical references from being a definitive dependency graph.
- The FSM index does not expand templates or execute actions. State/action counts include serialized disabled/unreachable/dormant data. Zero inline actions can mean a template-backed machine.
- Script binding rows include ScriptableObjects with no GameObject, and component names/types supplied through DLLs. Owner/hierarchy reconstruction does not flatten every prefab override/stripped-object relationship.
- The GUID index separates `unity_object_reference`, `mixer_internal_parameter_guid`, `asset_linker_audio_guid`, and other opaque GUID fields. A hex string named `guid` is not necessarily a Unity asset dependency.
- Scene transitions cover the current static `TransitionPoint` fields, not FSM-driven travel, fast travel, conditional redirects, runtime SetTargetScene changes, or actual traversability.
- tk2d clip/frame tables retain serialized timing/event data. Actual speed modifiers, start frames, interruptions, animator time sources and callback ordering must be read from their consumers.
- Binary DLLs, font internals, audio/video waveforms, texture pixels and archive contents are inventoried rather than fully semantically decoded. Packages are represented by manifests/lockfiles; cache contents can differ after package/version changes.

## 90.5 Recovered FSM gaps and decoder failure

[fsm-recovery-audit.json](data/fsm-recovery-audit.json) records exact source hashes, component/owner IDs, states, zero-based action indices and raw enabled bytes for **17 suspect slots**:

- **7 `MissingAction` slots:** 5 enabled, 2 disabled.
- Hero_Hornet `ProxyFSM`: `Respawn` action 0 and `Healed Max` action 1 are disabled; original action name is `SendEventToRegister`.
- Pinstress prefab `Control`: `Throw` action 6 and `G Dash Recover` action 6 are enabled (`SetRecoilBlockedOnExit`). The same two scene-instance slots are enabled in `Peak_07`.
- Lost Lace in `Abyss_Cocoon`, `Control / Sing` action 0 is enabled (`StartSingDuration`).
- **10 empty action-name slots**, all with enabled byte 0, occur in caravan/festival/Bone_10/Coral_Judge_Arena/Greymoor/Song_Enclave machines. Their exact identities are in the audit.

Enabled does not prove a state is reached. Disabled does not make malformed serialized data harmless to an offline decoder.

The existing `Docs/CombatResearch/tools/fsm_decode.py` raises `AttributeError: 'NoneType' object has no attribute 'rsplit'` on a null action name. This was reproduced using `Song_Enclave.unity`, component `7925`, `Dialogue / Churchkeeper`. CLI owner/FSM selection occurs after decoding, so a malformed unrelated machine can also prevent whole-file decoding. No game or existing decoder source was changed during this documentation task. For these sources, extract the selected raw component/state and preserve the unknown slot; a future decoder extension must handle and report null names explicitly.

The decoder also omits component-root enabled/template fields and does not automatically recurse into templates. This is why the binding/template indexes and raw component remain part of every reliable trace.

## 90.6 Unresolved GUID candidates: distinguish kinds

The first metadata lookup returned 334 source+GUID rows, representing 322 distinct GUIDs, without a scoped local path. [unresolved-reference-audit.json](data/unresolved-reference-audit.json) classifies them and records source positions. They are **not 322 missing game assets**:

| Distinct GUIDs | Interpretation |
|---:|---|
| 11 | Addressables/Input System package script PPtrs, resolved in the currently installed package cache; restore via the package graph |
| 6 | Mixer exposed-parameter internal IDs, also used in the same mixer graph/snapshot values; not asset PPtrs |
| 303 | PS5 `audioClipSource.guid` strings in `AssetLinker<AudioClip>` metadata; not Unity PPtrs; current getter does not itself resolve the GUID |
| 1 | Unresolved script PPtr GUID `5d4bff728ab3570cbc12741204593b03`, used by 11 enabled components in two Coral scenes |
| 1 | Unresolved snapshot PPtr GUID `0000000deadbeef15deadf00d0000000` in Bellway_City |

The unresolved script appears in `Assets/Scenes/Hornet/Coral_36.unity`, components `2777,2785,2788,2796,2799,2804,2831,2840,2843,2846`, and `Assets/Scenes/Hornet/Coral_Judge_Arena.unity`, component `5462`. Their `animator` bindings and `debugPlayedAnimations` fields are not enough to infer a class name or declare the component unnecessary. Query the script-binding shards by GUID for the full owners and line anchors.

Bellway_City's missing snapshot is on `Atmos Snapshot Marker`, GO `1849`, component `8641`; the marker script resolves, its `snapshot` does not. This is distinct from the unrelated mixer internal GUIDs above.

Of the 303 PS5 vibration assets, 301 directly reference locally resolved `vibrationClip` objects; two have a null direct clip (`understore_toll_bench_deactivate_vd.asset`, `hornet_walk_footsteps_wetwood_vd.asset`). The serialized linker string alone is not proof the fallback AudioClip is populated at runtime. See the scene/presentation chapter for the relevant source contract.

## 90.7 Other high-impact recovery limits

| Finding | Evidence / response |
|---|---|
| Malformed tilemap data | Bone_02 has 7,533 non-hex `/` characters in 10 spriteIds payloads; Tut_01 has 5,332 in 16. Preserve raw evidence; verify interpreted geometry before rebuilding or migrating |
| Malformed 2D layer matrix | `ProjectSettings/Physics2DSettings.asset` contains non-hex characters in `m_LayerCollisionMatrix`. Names/layer numbers alone do not establish a valid collision matrix |
| Recovered shaders | Consult `Docs/ShaderRecovery` for current provenance and scope of historical visual/compile validation. No new full shader equivalence test was run here |
| Local input/save compatibility | Current input wrapper and TCSAVE codec must be attributed to this checkout; do not present them as proven retail architecture |
| Audio method semantics | Current `AudioManager.ApplyMusicCue` ignores selected formal parameters; `AtmosRegion.FadeOut` checks one snapshot but passes another. The presentation chapter gives exact source routes; these were documented, not silently fixed |
| Legacy names | Old HK names can be dormant or actively bound. `Assets/Animations/Knight.prefab` is actually used by current Hornet; name-based deletion/classification is unsafe |

## 90.8 Verification performed and meaning

[data/validation.json](data/validation.json) is the machine-readable final validation report. Checks cover inventory coverage/hashes, table identities/count consistency, source ranges, local paths/links, selected serialized anchors, generated table schemas and exercised retrieval routes. Independent chapter reviews cross-checked source claims and corrected input-backend, equipment-event and decoder/template descriptions.

Three end-to-end retrieval routes were independently exercised:

1. Hero Sprint component → template GUID/path → real `Init → Idle` graph, instead of the inline placeholder.
2. Default Slash object → selected Knight library → clip 6 → frames/events → sprite collection/atlas materials/textures, with eight same-named clip libraries disambiguated.
3. Tut_01 `left2` → Tut_02 `right1` → Addressable mapping → reverse gate and custom entry FSM.

No Unity Editor play session, game build, automated combat simulation, audio playback, visual parity review, save round-trip, or platform service test was performed for this pass. Historical validation reported in older documents retains its original scope and date. Runtime checks in chapters 10–50 are instructions for future feature work, not completed results.

## 90.9 How to deepen the reference without wasting context

For a new feature, promote only its selected dependency closure from structural indexing to semantic tracing, then runtime verification. Add exact object/state/clip identities and measured outcomes, not another generic overview. For source edits, refresh affected table rows and chapter evidence, record hashes, and rerun relevant retrieval/integrity checks. Keep uncertainty visible until tested; do not overwrite an unknown with a plausible implementation guess.
