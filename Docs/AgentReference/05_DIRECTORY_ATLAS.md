# 05 — Physical directory atlas

This is a physical census, not a claim that directory names define runtime architecture. Use the semantic router in [README](README.md), then the declaration/binding indexes. Counts are snapshot facts.

## Source roots

| Source root | C# files | Retrieval interpretation |
|---|---:|---|
| `Assets/Scripts/Assembly-CSharp/` | 2,040 | Major Silksong systems and actions; search this even when ProjectCode has a similarly named category. |
| `Assets/Scripts/ProjectCode/` | 970 | Curated game, FSM, settings, enums and utility groups. |
| `Assets/PlayMaker/` | 1,160 | Action/editor source plus binary runtime/template assets. |
| `Assets/Scripts/ThirdParty/` | 412 | Third-party support and game-facing custom actions; verify actual type and binding. |
| `Assets/Scripts/MixedIntegrations/` | 88 | Mixed action/input/integration code. |
| `Assets/Scripts/TeamCherry/` | 69 | tk2d runtime assembly and support. |
| `Assets/Plugins/` | 57 | Firstpass/plug-in source; inspect platform and assembly import settings. |
| `Assets/Editor/` | 13 | Editor recovery/research utilities and drawers. |
| `Assets/Scripts/BuildSupport/` | 4 | Recovery/compilation support types. |
| `tools/` | 1 | Offline research/validation source, outside game compilation. |

## Curated game categories

These rows include their descendants; they do not account for equivalent systems left in `Assembly-CSharp`.

| Directory | C# files |
|---|---:|
| `Assets/Scripts/ProjectCode/Game/00_Bootstrap/` | 3 |
| `Assets/Scripts/ProjectCode/Game/01_Core/` | 5 |
| `Assets/Scripts/ProjectCode/Game/02_Player/` | 32 |
| `Assets/Scripts/ProjectCode/Game/03_Combat/` | 43 |
| `Assets/Scripts/ProjectCode/Game/04_World_Environment/` | 88 |
| `Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/` | 34 |
| `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/` | 75 |
| `Assets/Scripts/ProjectCode/Game/07_UI_Localization/` | 87 |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/` | 161 |
| `Assets/Scripts/ProjectCode/Game/09_Platform_Input_Achievements/` | 60 |
| `Assets/Scripts/ProjectCode/Game/10_Bosses_Godmaster/` | 35 |
| `Assets/Scripts/ProjectCode/Game/11_Actors_Quests/` | 29 |
| `Assets/Scripts/ProjectCode/Game/12_Utilities/` | 31 |

For every direct C# directory, query `data/source-folder-index.tsv`. For every actual file and symbol, query `source-index.tsv` and `source-symbols.tsv`. A file with no declarations can contain assembly attributes, commented-out obsolete source, or conditional code; it is still inventoried.

## Scene-name families

The table groups scene filename text before the first underscore. It is a lookup shortcut, **not** a verified geographic region, encounter list, release inclusion list, or connected world graph. Use `scene-transitions.tsv` and the scene chapter for actual links and overrides.

| Filename prefix | Scene files | Example |
|---|---:|---|
| `Bone` | 67 | `Assets/Scenes/Hornet/Bone_01.unity` |
| `Song` | 32 | `Assets/Scenes/Hornet/Song_01.unity` |
| `Coral` | 31 | `Assets/Scenes/Hornet/Coral_02.unity` |
| `Under` | 30 | `Assets/Scenes/Hornet/Under_01.unity` |
| `Shadow` | 28 | `Assets/Scenes/Hornet/Shadow_01.unity` |
| `Slab` | 26 | `Assets/Scenes/Hornet/Slab_01.unity` |
| `Dust` | 25 | `Assets/Scenes/Hornet/Dust_01.unity` |
| `Greymoor` | 25 | `Assets/Scenes/Hornet/Greymoor_01.unity` |
| `Shellwood` | 24 | `Assets/Scenes/Hornet/Shellwood_01.unity` |
| `Dock` | 19 | `Assets/Scenes/Hornet/Dock_01.unity` |
| `Hang` | 19 | `Assets/Scenes/Hornet/Hang_01.unity` |
| `Library` | 19 | `Assets/Scenes/Hornet/Library_01.unity` |
| `Peak` | 17 | `Assets/Scenes/Hornet/Peak_01.unity` |
| `Ant` | 16 | `Assets/Scenes/Hornet/Ant_02.unity` |
| `Bellway` | 16 | `Assets/Scenes/Hornet/Bellway_01.unity` |
| `Clover` | 15 | `Assets/Scenes/Hornet/Clover_01.unity` |
| `Abyss` | 14 | `Assets/Scenes/Hornet/Abyss_01.unity` |
| `Belltown` | 14 | `Assets/Scenes/Hornet/Belltown.unity` |
| `Cog` | 13 | `Assets/Scenes/Hornet/Cog_04.unity` |
| `Arborium` | 12 | `Assets/Scenes/Hornet/Arborium_01.unity` |
| `Room` | 12 | `Assets/Scenes/Hornet/Room_Caravan_Interior.unity` |
| `Aqueduct` | 11 | `Assets/Scenes/Hornet/Aqueduct_01.unity` |
| `Crawl` | 11 | `Assets/Scenes/Hornet/Crawl_01.unity` |
| `Weave` | 11 | `Assets/Scenes/Hornet/Weave_02.unity` |
| `Ward` | 10 | `Assets/Scenes/Hornet/Ward_01.unity` |
| `Cradle` | 9 | `Assets/Scenes/Hornet/Cradle_01.unity` |
| `Memory` | 8 | `Assets/Scenes/Hornet/Memory_Ant_Queen.unity` |
| `Wisp` | 8 | `Assets/Scenes/Hornet/Wisp_02.unity` |
| `Bellshrine` | 7 | `Assets/Scenes/Hornet/Bellshrine.unity` |
| `Cinematic` | 7 | `Assets/Scenes/Cinematic_Ending_A.unity` |
| `Tut` | 6 | `Assets/Scenes/Hornet/Tut_01.unity` |
| `Mosstown` | 4 | `Assets/Scenes/Hornet/Mosstown_01.unity` |
| `End` | 3 | `Assets/Scenes/End_Credits.unity` |
| `Bonetown` | 2 | `Assets/Scenes/Hornet/Bonetown.unity` |
| `Last` | 2 | `Assets/Scenes/Hornet/Last_Dive.unity` |
| `Menu` | 2 | `Assets/Scenes/Menu_Credits.unity` |
| `Opening` | 2 | `Assets/Scenes/Opening_Sequence.unity` |
| `Pre` | 2 | `Assets/Scenes/Pre_Menu_Intro.unity` |
| `Abandoned` | 1 | `Assets/Scenes/Hornet/Abandoned_town.unity` |
| `Aspid` | 1 | `Assets/Scenes/Hornet/Aspid_01.unity` |
| `Bonegrave` | 1 | `Assets/Scenes/Hornet/Bonegrave.unity` |
| `Chapel` | 1 | `Assets/Scenes/Hornet/Chapel_Wanderer.unity` |
| `City` | 1 | `Assets/Scenes/Hornet/City_Lace_cutscene.unity` |
| `Demo` | 1 | `Assets/Scenes/Demo_Scene.unity` |
| `Demo End` | 1 | `Assets/Scenes/Hornet/Demo End.unity` |
| `Demo Start` | 1 | `Assets/Scenes/Hornet/Demo Start.unity` |
| `Halfway` | 1 | `Assets/Scenes/Hornet/Halfway_01.unity` |
| `Organ` | 1 | `Assets/Scenes/Hornet/Organ_01.unity` |
| `PermaDeath` | 1 | `Assets/Scenes/Data/PermaDeath.unity` |
| `Quit` | 1 | `Assets/Scenes/Quit_To_Menu.unity` |
| `Shellgrave` | 1 | `Assets/Scenes/Hornet/Shellgrave.unity` |
| `Sprintmaster` | 1 | `Assets/Scenes/Hornet/Sprintmaster_Cave.unity` |
| `Tube` | 1 | `Assets/Scenes/Hornet/Tube_Hub.unity` |

## Resource kinds

Counts below are restricted to `Assets/`. Different export directories may contain the same conceptual resource kind; follow GUIDs and subobject IDs.

| Extension | Files | Interpretation |
|---|---:|---|
| `.asset` | 32,549 | ScriptableObjects and exported data; resolve m_Script before assigning a role. |
| `.ogg` | 9,360 | Audio clips; event/mixer semantics live elsewhere. |
| `.cs` | 4,814 | See file/asset inventory and importer metadata. |
| `.png` | 2,582 | Textures/atlases; sprite identity and import metadata matter. |
| `.prefab` | 1,947 | Reusable and exported GameObject hierarchies, including tk2d clip libraries. |
| `.anim` | 1,507 | Unity AnimationClips; tk2d clips also live inside other assets. |
| `.mat` | 1,181 | Materials; inspect shader and texture bindings. |
| `.controller` | 814 | Unity Animator controllers. |
| `.unity` | 594 | Scenes, including recovered, legacy, variants, demos and derived research copies. |
| `.txt` | 412 | See file/asset inventory and importer metadata. |
| `.bytes` | 182 | Opaque or format-specific payloads. |
| `.shader` | 167 | Recovered/current shader source. |
| `.cginc` | 45 | Shader includes. |
| `.dll` | 44 | Binary dependency boundaries; platform metadata matters. |
| `.overridecontroller` | 43 | Animation replacement mappings. |
| `.ttf` | 28 | Font files. |
| `.mp4` | 26 | Video content. |
| `.playable` | 15 | See file/asset inventory and importer metadata. |
| `.mixer` | 13 | Mixer graph, groups, snapshots and internal identifiers. |
| `.physicsmaterial2d` | 10 | See file/asset inventory and importer metadata. |
| `.otf` | 6 | Font files. |
| `.json` | 4 | See file/asset inventory and importer metadata. |
| `.lighting` | 2 | See file/asset inventory and importer metadata. |
| `.texture2d` | 1 | See file/asset inventory and importer metadata. |
| `.inputactions` | 1 | Current Unity Input System action asset. |
| `.zip` | 1 | Archive inventoried as opaque content; embedded files are not loose-source census entries. |
| `.asmdef` | 1 | See file/asset inventory and importer metadata. |

## Configuration and derived material

- `Packages/manifest.json` and `Packages/packages-lock.json`: requested and resolved package graph. Generated `Library/PackageCache` is not duplicated into the source census.
- `ProjectSettings/`: engine, physics, input, tags/layers, rendering, build/addressable registrations and player settings.
- `.meta`: GUIDs, importer settings, sprite/subasset mappings, platform selection and script execution order. Included in the file manifest.
- `Docs/CombatResearch`, `Docs/SceneResearch`, `Docs/ShaderRecovery`: earlier evidence and derived research; see each report’s scope and source hashes.
- `Library`, `Temp`, `Logs`, `obj`, IDE/user settings and `.git`: generated or administrative state excluded from the frozen content census. The current package cache was consulted only to classify unresolved external references.
- The new `Docs/AgentReference` directory is excluded from its own input manifest to avoid self-referential hashes.
