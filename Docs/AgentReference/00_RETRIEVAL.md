# 00 — Retrieval and evidence tracing

Read [README](README.md) first. Run examples with the working directory at the reference project root. Commands are read-only except decoder output explicitly directed to `/tmp`. TSV files have a header, UTF-8 encoding, tab separators, and one physical line per row. Path-list columns (`target_paths`, `template_paths`, `script_paths`, `candidate_source_paths`, `source_candidates`) contain JSON arrays; parse with `json.loads`. This is essential because some real texture filenames contain a literal `|`. Other compact display lists use `|` and are search aids; return to raw data for exact names that contain separators. Use an exact column filter when a substring could match the wrong object.

## 1. Retrieval order and context budget

1. **Intent**: the README router selects a chapter.
2. **Symbol**: query `source-index.tsv` or `source-symbols.tsv` for exact classes/methods; read the relevant source range and callers.
3. **Binding**: query `script-bindings/*.tsv` for the source script's GUID/path and choose the correct scene/Prefab instance.
4. **Object**: extract a Unity YAML block by fileID; follow local fileIDs and external `(GUID, fileID)` references.
5. **Behavior**: inspect the selected FSM, action parameters, execution order, clip events, collider geometry, and data overrides.
6. **Resources**: follow `asset-references.tsv` and `addressables.tsv` one hop at a time. Open `.meta` for import/execution settings.
7. **Provenance**: verify file hashes against the snapshot if precision matters or files have changed.

Typical first read: README router plus one chapter section. Query `data/document-sections.tsv` for its heading and exact line range, or `data/document-source-map.tsv` to return from a source file to its explanations. Typical follow-up: a few exact index rows, a source method, and a few object blocks. Do not emit all matching scene lines or the raw action byte arrays into context. Reduce by source, owner, and FSM first.

## 2. Appendix schemas

All data are in `Docs/AgentReference/data/`. See [snapshot.json](data/snapshot.json) for full scan scope and totals.

| File | Row identity / columns | Intended query |
|---|---|---|
| `document-sections.tsv` | `document, level, heading, start_line, end_line, words` | Retrieve one section of a long chapter without loading the entire file |
| `document-source-map.tsv` | `document, source` | Find chapters that explicitly cite a source/asset path; not a semantic-coverage grade |
| `source-index.tsv` | `source, guid, sha256, bytes, lines, assembly, types, bases, namespaces, usings, parse_errors` | Every loose C# file; exact type/file lookup and assembly/declaration context |
| `source-symbols.tsv` | `source, namespace, owner_type, kind, symbol, line, end_line, signature` | Type, method, constructor, property, field, event, enum member; line range lookup |
| `source-type-references.tsv` | `source, type_name, candidate_source_paths, identifier_occurrences` | Candidate outgoing/incoming source dependencies; lexical identifiers, not semantic binding |
| `asset-index.tsv` | `path, extension, guid, bytes, sha256, meta_sha256, content_kind` | Asset GUID ↔ path; includes directories with `.meta` identities |
| `file-inventory.tsv` | `path, bytes, sha256, content_kind` | All scoped files including metadata, binaries, existing docs and configuration |
| `asset-references.tsv` | `source, target_guid, target_paths, count, first_line, resolution, object_reference_count, reference_kind` | One row per distinct lowercase `guid:` in a text asset; inspect reference_kind before treating it as a Unity asset dependency |
| `scene-prefab-index.tsv` | `source, guid, sha256, bytes, lines, game_objects, mono_behaviours, fsms, sprite_renderers, animators, audio_sources, colliders_2d, prefab_instances` | All loose `.unity`/`.prefab` text assets, basic composition and relative complexity |
| `script-bindings/*.tsv` | `source, component_id, owner_id, owner_name, owner_hierarchy, component_line, script_guid, script_file_id, script_paths, enabled` | Every indexed YAML MonoBehaviour with `m_Script`; includes ScriptableObjects, where `owner_id=0` is normal |
| `fsm-index.tsv` | `source, component_id, owner_id, owner_name, owner_hierarchy, component_line, fsm_name, start_state, state_count, action_count, states, action_types` | Machine identity and behavior search across the full YAML scope |
| `fsm-actions.tsv` | `action_type, source, component_id, owner_id, fsm_name, count` | Find actual serialized uses of an action type before tracing its code |
| `fsm-template-links.tsv` | `source, component_id, owner_id, fsm_name, template_guid, template_file_id, template_paths` | Actual instance → external template bindings; no implicit flattening |
| `scene-transitions.tsv` | `source, component_id, owner_id, owner_name, owner_hierarchy, line, target_scene, entry_point, is_door, entry_delay, always_enter_left, always_enter_right` | Static TransitionPoint routes; inspect all dynamic overrides in source/component |
| `tk2d-clips.tsv` | `source, component_id, owner_id, clip_index, clip_name, line, fps, wrap_mode, loop_start, frame_count, event_frames_zero_based, collection_guids` | Actual tk2d library clip definitions; IDs are local to the component |
| `tk2d-frames.tsv` | `source, component_id, clip_index, clip_name, frame_index, collection_guid, collection_file_id, sprite_id, trigger_event, event_info, event_int, event_float` | Exact frame → sprite collection and event binding |
| `asset-addressable-references.tsv` | `source, line, target_guid, target_paths` | Explicit serialized `m_AssetGUID` fields |
| `fsm-action-implementations.tsv` | `action_type, serialized_occurrences, source_candidates, resolution` | Exact/nested type matches versus short-name candidates or no loose source; empty type is retained |
| `addressables.tsv` | `group_source, address, target_guid, target_paths, labels` | Explicit Addressable group entry mappings; does not interpret every runtime-constructed address |
| `script-execution-order.tsv` | `source, meta_execution_order, declared_default_execution_order` | Metadata and attribute scheduling; custom player loops require source tracing |
| `source-literals.tsv` | `source, line, literal` | Source string candidates: FSM events, names, resource paths, reflection fields, animation clips |
| `source-parse-errors.json` | Source paths + syntax-error locations | Tree-sitter extraction caveats, not compiler diagnostics |
| `duplicate-guids.json` | GUID + all local paths | Ambiguous local identities, if any |
| `validation.json` | Checks, counts, samples, limitations | Integrity checks of the generated reference appendices |

`assembly` uses the nearest asmdef or Unity folder naming rules. Treat it as an explanatory hint; the generated `.csproj`, platform defines, plug-in import settings and actual Unity compilation determine the compilation result. A `signature` can include attributes and default values and is clipped to 1,200 characters. It is a locator, not a replacement implementation.

`owner_hierarchy` is reconstructed from serialized Transform/RectTransform parent IDs, useful for browsing but not guaranteed unique. Prefab variants/stripped records/overrides can require following their source prefabs. FileIDs, rather than hierarchy strings, are the exact identity.

## 3. Find a class or method

```sh
rg -n -F 'HeroController.cs' Docs/AgentReference/data/source-index.tsv
rg -n '(^|\t)(Attack|DoJump|TakeDamage)(\t|$)' Docs/AgentReference/data/source-symbols.tsv
rg -n 'HeroController|CustomPlayerLoop' Docs/AgentReference/data/source-type-references.tsv
```

For a precise range, select symbol rows rather than searching a whole repository:

```python
import csv
from pathlib import Path
index = Path('Docs/AgentReference/data/source-symbols.tsv')
with index.open() as stream:
    for r in csv.DictReader(stream, delimiter='\t'):
        if r['source'].endswith('/HeroController.cs') and r['symbol'] == 'Attack':
            print(r)
```

Then open only the returned `line` through `end_line`. To locate callers, search the symbol in the **relevant source directories** and inspect the receiving type/overload. The lexical dependency table cannot distinguish identically named methods or runtime interface dispatch.

## 4. From script to a real scene object

```sh
rg -n -F 'Assets/Scripts/ProjectCode/Game/02_Player/HeroController.cs' Docs/AgentReference/data/script-bindings/
rg -n -F 'Assets/Prefabs/Heroes/Hero_Hornet.prefab' Docs/AgentReference/data/fsm-index.tsv
```

Choose the desired `source`, `component_id`, `owner_id`. Extract the exact component without parsing a 100 MB scene into a generic YAML library:

```python
from pathlib import Path
import re
source = Path('Assets/Prefabs/Heroes/Hero_Hornet.prefab')
file_id = 'REPLACE_WITH_COMPONENT_ID_FROM_INDEX'
header = re.compile(r'^--- !u!\d+ &(-?\d+)(?:\s|$)')
printing = False
with source.open() as stream:
    for line in stream:
        m = header.match(line)
        if m:
            if printing:
                break
            printing = m.group(1) == file_id
        if printing:
            print(line, end='')
```

The GO block gives component fileIDs. The transform block gives parent/children. The component block gives its actual serialized values. Follow references by exact identity. For large FSM/mesh/texture blocks, summarize desired fields before printing; the example intentionally leaves selection explicit.

## 5. Resolve an external reference and find its consumers

For `{fileID: 11400000, guid: ..., type: 2}`:

1. Look up `guid` in `asset-index.tsv` (its `path` is one literal path). In other tables, decode a path-list column with `json.loads(row["target_paths"])`; never split a filename on `|`.
2. Open the referenced asset; select `fileID` when it contains multiple subobjects.
3. Preserve importer metadata and subasset identity. A GUID alone does not choose a sprite, clip, material, DLL type, or other subasset.
4. Use reverse GUID edges to find where the resource is bound.

```sh
rg -n -F 'REPLACE_WITH_GUID' Docs/AgentReference/data/asset-index.tsv
rg -n -F 'REPLACE_WITH_GUID' Docs/AgentReference/data/asset-references.tsv
```

For reverse lookups, filter `target_guid` exactly and limit printing. `object_reference_count` counts actual `{fileID: ..., guid: ...}` pointers; `reference_kind` separates them from mixer internal parameter IDs and PS5 AssetLinker strings. `resolution=local` only reports a metadata lookup, not runtime loading or consumption. The `first_line` locates the first occurrence, not every consuming object. Return to the source and inspect all matching object blocks for instance-specific overrides.

Special cases:

- `fileID: 0` normally means no referenced object; it is not automatically an error.
- Unity built-in references have special GUIDs and may have no local `.meta`.
- Package assets can resolve from `Library/PackageCache` after restore. That generated cache is not frozen into this reference.
- `m_AssetGUID`, group entry `m_GUID`, resource string paths, animation names, tags, global variables and reflection field names are distinct lookup mechanisms. Use the Addressable index or source literals and then inspect the binding. They are not covered by lowercase `guid:` edges alone.
- `m_Script` pointing at a DLL needs the script subasset fileID. A DLL path is not sufficient to infer the managed component type.
- Imported texture/atlas subassets require `.meta` and Unity's subasset interpretation. Use tk2d collection mappings where appropriate.

## 6. Trace one PlayMaker machine

First use `fsm-index.tsv` to locate `(source, owner_id, component_id, fsm_name)`. Then run the **existing** decoder:

```sh
python3 Docs/CombatResearch/tools/fsm_decode.py 'Assets/Scenes/Hornet/Tut_01.unity' --owner 'Sound Control' --fsm 'Control' --compact --output /tmp/silksong-selected-scene-fsms.json
```

The decoder needs system Ruby with its YAML/JSON libraries. It parses candidate component blocks rather than the entire Unity file. `--owner 'exact name'` and `--fsm 'exact name'` help narrow output, but identical names can match several machines. Filter by the returned `owner_id` and `file_id` to disambiguate. `--compact` removes repeated raw action bytes; the decoded parameters and variables remain.

**Decoder limits:** owner/FSM CLI filters are applied after decoding candidate machines, so they reduce output rather than whole-scene parse cost. The example selects Tut_01 owner `2441`, component `11126`. The decoder does not return component-root `m_Enabled` or `fsmTemplate`, and does not automatically expand templates: retrieve them from the raw YAML plus `script-bindings/` and `fsm-template-links.tsv`. The current decoder raises `AttributeError` on a null/blank action name even when that slot is disabled; this was reproduced on Song_Enclave component `7925`. See `fsm-recovery-audit.json`; use raw component/state evidence for such cases, preserve unknown types, and do not invent an action to make decoding pass.

For each selected machine, read: enabled state, start state, global transitions, local/global variables, state order and sequence flag, action order, action enabled flag, transition event/target, and object references. Variable-backed values have both a variable name and stored fallback; **do not replace a runtime variable with its stored number**.

An action's `Finish()` completes that action; it is not intrinsically a state transition or a duration. Check emitted events, sequence mode, repeat/every-frame flags, animation completion callbacks and the PlayMaker runtime contract. See [40](40_RUNTIME_AND_DEPENDENCIES.md).

For a combat entity, start from existing `Docs/CombatResearch/data/catalog.json` rather than decoding every scene. The JSON has `journal_records`, each with `id`, `instances`, `canonical`, and `guid`. Pick the requested encounter from `instances`. `data/entities/*.json` stores the exported canonical sample, not all variants.

## 7. Search by a runtime string

```sh
rg -n -F 'HERO DAMAGED' Docs/AgentReference/data/source-literals.tsv
rg -n -F 'HERO DAMAGED' Docs/AgentReference/data/fsm-index.tsv
rg -n -F 'Scenes/Pre_Menu_Intro' Docs/AgentReference/data/addressables.tsv
```

The FSM index includes state and action type names, not all event/variable values. If the string is absent there, search the selected decoded machine or narrow source scene/Prefab. Unity YAML may quote or escape non-ASCII strings. Source literal rows are syntax text, so C# escaping/interpolation still needs interpretation. Do not infer an absent runtime event from a failed text search alone.

## 7A. Three exercised end-to-end retrieval examples

### Sprint: instance → external template → real entry state

```sh
rg -F 'Assets/Prefabs/Heroes/Hero_Hornet.prefab' Docs/AgentReference/data/fsm-template-links.tsv | rg 'Sprint'
rg -F 'Assets/PlayMaker/Templates/hornet_sprint.asset' Docs/AgentReference/data/fsm-index.tsv
python3 Docs/CombatResearch/tools/fsm_decode.py Assets/PlayMaker/Templates/hornet_sprint.asset --compact --output /tmp/silksong-sprint.json
```

Select the exact `fsm_name= Sprint` row (not `Sprint Silk Usage`). Component `114195663224090321` points to template GUID `f87d2734e3be6c54f98a02c0bcd2ac09`. Its real start state is `Init`, which finishes into `Idle`; the instance's `State 1` is a placeholder. The template has 156 states and 920 serialized actions in the snapshot.

### Ordinary slash: selected object → library → clip → frame → atlas

The default Slash GO is `1808113985169905`; NailSlash component `114243116046688445` uses `animName=SlashEffect`. Its animation component `114025440191983101` binds library GUID `a14142627197a144586ee7b8abd07265` → `Assets/Animations/Knight.prefab`.

```sh
rg -F 'Assets/Animations/Knight.prefab' Docs/AgentReference/data/tk2d-clips.tsv | rg 'SlashEffect'
rg -F 'Assets/Animations/Knight.prefab' Docs/AgentReference/data/tk2d-frames.tsv | rg 'SlashEffect'
```

Filter `clip_name` exactly: this library's ordinary `SlashEffect` is clip index 6, 20 fps, 4 frames, trigger events at zero-based frames 0 and 2. `NailSlash.OnAnimationEventTriggered` opens the collider on the first event and closes it on the second. Uncancelled and at default playback speed, frames 0–1 form the active window. The same clip name appears in **eight** libraries with different events; a clip name alone is not identity.

Frame sprite IDs are `737,829,906,733` in collection GUID `3f4d9d6376d359348a4555fe49e6ca15` → `Assets/Collections/Knight Data/Knight.prefab`. A tk2d `spriteId` is the **zero-based `spriteDefinitions` array index**, not a Unity Sprite fileID. Follow that definition's material/atlas mapping to `_MainTex`; this one clip uses both atlas0 and atlas1. Preserve `(library source, library component_id, clip_index, frame_index, collection GUID, spriteId)` when translating animation.

### Room exit: both gates + Addressable + custom entry behavior

```sh
rg -F 'Assets/Scenes/Hornet/Tut_01.unity' Docs/AgentReference/data/scene-transitions.tsv
rg -F 'Scenes/Tut_02' Docs/AgentReference/data/addressables.tsv
rg -F 'Assets/Scenes/Hornet/Tut_02.unity' Docs/AgentReference/data/scene-transitions.tsv
```

Tut_01 has six indexed TransitionPoints. Select `left2` (GO `141`, component `12124`): its static target is `Tut_02`, entry `right1`. Address `Scenes/Tut_02` resolves to the Hornet scene. That scene's `right1` (GO `680`, component `10704`) points back to Tut_01/left2. The source component also has `customEntryFSM:11790` (`Weakness Scene / Control`); retrieve this machine to understand entry behavior. Inspect `isInactive`, `customFadeFSM`, offsets, map checks, respawn and dynamic overrides in the raw component; the compact route table does not flatten them.

## 8. Freshness and maintenance

Compare current bytes to `file-inventory.tsv` or `asset-index.tsv` using SHA-256. Hashes are content hashes, not timestamps. A scene hash covers all its serialized objects. The snapshot includes the dirty local worktree present during research; a Git commit hash by itself is not enough to reproduce it.

When updating the reference:

1. Record root, Unity/package versions, Git revision and local changes.
2. Re-inventory added/removed/changed files and metadata; regenerate affected declaration, binding and reference rows.
3. Recheck relevant chapter claims, IDs, FSM decodes and dependency closures.
4. Validate unique table keys, resolvable paths, extracted object identities, counts and example queries.
5. Update coverage honestly. Keep unverified branches explicit.

Script bindings use 16 deterministic shards (`sha256(source UTF-8)[0] % 16`), listed in `script-bindings-shards.tsv`. `rg` searches the directory recursively; Python readers should iterate `Path("Docs/AgentReference/data/script-bindings").glob("*.tsv")`. An absent execution-order field means unspecified in metadata/attributes, not a measured runtime order. The full source folder census is in `source-folder-index.tsv`. Recovery, unresolved-reference and text-encoding caveats have their own JSON reports linked by [90](90_COVERAGE_AND_LIMITS.md).

The appendices are documentation data, not a new runtime tool or application. They were produced with a temporary external analysis script. Their complete field definitions and extraction limits are documented here; existing combat extraction tools remain available for detailed entity/FSM refreshes. Do not treat the snapshot as automatically updating when the project changes.
