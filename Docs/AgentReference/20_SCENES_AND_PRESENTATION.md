# Scenes, camera, terrain, animation, art and audio — Agent reference

## Contract and evidence

- Scope: current `SilksongUnity6` checkout, inspected 2026-09-18; HEAD during research: `4b53c3a6e6300363aeee553a8b11c37c7538d34b`. Working-tree source/resources take precedence over HEAD. This is an implementation navigation document, not a declaration that the recovered project is identical to the shipped game.
- Evidence in this chapter: **SOURCE** = method body inspected; **SERIALIZED** = source YAML and GUID references inspected; **HISTORICAL-TEST** = an earlier report records a runtime/GPU result; **PROPOSED-TEST** = acceptance work still to perform in the destination project. No Unity session, scene rebuild, gameplay test or audio audition was performed for this chapter.
- Full project discovery uses `data/source-index.tsv`, `data/source-symbols.tsv`, `data/asset-index.tsv`, `data/asset-references.tsv`, `data/scene-prefab-index.tsv`, `data/script-bindings/`, and `data/fsm-index.tsv` beside this chapter. Additional specialized indexes, when present: `data/scene-transitions.tsv` for static TransitionPoint edges and the tk2d clip index described by `00_RETRIEVAL.md`. Read each table's header row before querying. A row in an index is discovery coverage, not semantic review of every object or state.
- All paths below are repository-relative. A local `fileID` is scoped to its containing `.unity`/`.prefab`/`.asset`/`.mixer`; it is not globally unique. An external reference is `(guid, fileID)`; preserve both. Textual object names and asset display names are hints, never identity.
- Retrieval protocol: identify requested feature → read the relevant section → open the listed source symbol → locate its serialized component through the script GUID → follow each referenced object/asset → inspect runtime overrides and event subscribers → implement a small vertical slice → run the proposed tests. Do not read a 20 MB scene wholesale into the Agent context.

## Fast routing / 中文检索词

| Intent | Start here | Runtime/resource continuation |
|---|---|---|
| New room / 场景、关卡、地形 | §Terrain; `tk2dTileMap.Build` | logical chunks → mesh → `EdgeCollider2D`; authored decoration is separate |
| Connect rooms / 场景切换、门、入口 | §Travel; `TransitionPoint.DoSceneTransition` | `GameManager.BeginSceneTransition` → `SceneLoad.BeginRoutine` → `HeroController.EnterScene` |
| Room look / 场景颜色、光照、黑线世界 | §Art; `CustomSceneManager.Start/UpdateScene` | map-zone defaults → `SceneColorManager` → camera effects / global shader parameters |
| Follow player / 相机跟随、前瞻、落下、镜头锁定 | §Camera; `CameraTarget.Update` | target movement → `CameraController.LateUpdate` → scene/lock bounds |
| Layered art / 背景、前景、视差、遮罩 | §Art; `_GameCameras.prefab`, scene SpriteRenderer | perspective projection + world Z + sorting + material render state |
| Character frames / 动画、动作帧、帧事件 | §Animation; Hero root tk2d animator | `Assets/Animations/Knight.prefab` → collection → atlas/material |
| Footsteps / 脚步、落地声音 | §Audio; `HeroAnimationController.AnimationEventTriggered` | `HeroAudioController.PlayFootstep` → environment-selected table → AudioSource |
| One-shot SFX / 打击音效、声音池 | §Audio; `AudioEvent.SpawnAndPlayOneShot` | settings prefab → frequency/distance gate → ObjectPool → recycle |
| Music / 音乐、多轨、混音、淡入淡出 | §Audio; `AudioManager.ApplyMusicCue/ApplyMusicSnapshot` | cue channels, synchronized sources, snapshots, regions/markers |
| Ambient effects / 环境粒子、雾、模糊 | §Art; `SceneParticlesController`, `BlurPlane` | scene manager zone flags + camera-parented particles + scene-local effects |
| Pink/incorrect materials / 材质、Shader恢复 | §Shader boundary | actual shader GUID → material keywords → includes → historical GPU evidence |

## Terrain: logical map, generated geometry, decoration

### Source locators

| Path | Symbols and purpose |
|---|---|
| `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dTileMap.cs` | `Awake`, `Build`, `ForceBuild`, `GetTileAtPosition`, `GetTileIdAtPosition`, `SetTile`, `ClearTile`; primary facade |
| `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dTileMapData.cs` | shared grid/layer rules, not per-room tile occupancy |
| `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dRuntime/TileMap/Layer.cs` | chunk coordinate resolution, raw tile encoding, dirty tracking |
| `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dRuntime/TileMap/SpriteChunk.cs` | `spriteIds`, generated mesh and collider references |
| `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dRuntime/TileMap/BuilderUtil.cs` | `InitDataStore`, `CreateRenderData`, `SpawnPrefabs`, `GetTileFromRawTile`, flags and tile placement |
| `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dRuntime/TileMap/RenderMeshBuilder.cs` | `Build/BuildForChunk`; vertices, UV, colors, triangles, material submeshes |
| `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dRuntime/TileMap/ColliderBuilder2D.cs` | `Build/BuildForChunk`, weld vertices, remove duplicate edges, merge contours |
| `Assets/Scripts/ProjectCode/Game/01_Core/GameManager.cs` | `RefreshTilemapInfo`; tilemap supplies room width/height for camera and borders |

**SOURCE:** `Build` creates data stores and material IDs, remembers current layer activation, then calls `BuilderUtil.CreateRenderData`, `RenderMeshBuilder.Build`, and, outside edit mode, a 2D or 3D collider builder followed by prefab spawning. It clears dirty flags and records the collection `buildKey`. The physics branch is selected from the collection's first valid sprite definition, not from whether the camera is orthographic. `ColliderBuilder2D` uses collection collider shapes; it does not trace visible art pixels.

`Awake` can rebuild when the collection `buildKey` differs, material instances are required, or `renderData` is missing. Entering play while `_inEditMode` is true also ends edit mode and builds. Therefore importing only the TileMap MonoBehaviour without its existing render data can be a destructive change to recovered geometry.

Generated hierarchy is `TileMap Render Data` → configured layer → `Chunk <row> <column>`. `CreateRenderData` creates `MeshFilter` and `MeshRenderer`, assigns the configured Unity physics layer, positions chunks, and applies tiny `-1E-06` Z offsets per visited chunk. It may preserve an existing layer's active state. Collider generation skips configured tile prefabs, whose own components supply behavior/collision. Chunk contour merging is local to each chunk.

**SERIALIZED shared configuration:**

| Resource | GUID / fileID | Relevant contents |
|---|---|---|
| `Assets/Data Assets/tileMapData.asset` | `db58d0a4a52bf4d4aa4182bd5414e0d5` / `11400000` | tile size `(1,1,0)`, origin `(0,0,0)`, rectangular, layer `Scenemap`, hash `1939926937`, `generateCollider=1`, `unityLayer=8`, `useSortingLayers=0` |
| `Assets/Collections/Terrain Data/Terrain.prefab` | `36f396041a114364f8571cc22c67747f` / `114724804207875695` | one sprite definition `level_tile` (ID 0), unit square, physics engine 2D, box collider, `buildKey=895126549` |
| `Assets/Materials/Terrain.physicsMaterial2D` | `0537214dc5c960f4a8a1d72c6a6b24c5` / `6200000` | collider physics material referenced by `Scenemap` |

Raw occupancy values use low 24 bits for tile ID and high bits for flags; `-1` means empty. `GetTile` masks flags; `GetRawTile` preserves them. `GetTileAtPosition` returning true means the point is inside logical room bounds, not that it touches terrain. `SetTile`/`ClearTile` mark dirty data; they do not immediately update renderers/colliders. Use `Build` after validated edits. `GetTile(x,y,layer)` validates layer but not coordinates; callers must bounds-check x/y.

### Verified room anchors

| Scene | Asset GUID | TileMap GO / component | Size / partitions | Render-data GO | Scene manager GO / component |
|---|---|---|---|---|---|
| `Assets/Scenes/Hornet/Bone_02.unity` | `73a3bd746b3ede444b28541f3747f37c` | `609` / `6870` | `155×46`, chunks `32×32` (5 columns × 2 rows) | `171` | `936` / `7729` |
| `Assets/Scenes/Hornet/Tut_01.unity` | `71c29baa37ab4d24ea141430b0fb0c93` | `936` / `11123` | `120×120`, chunks `32×32` (4 columns × 4 rows) | `67` | `1416` / `12104` |

Both use the shared configuration above and serialized existing meshes. `GameManager.GetTileMap` accepts a root only when it has tag `TileMap` and that component; the fallback searches tagged objects. Preserve the tag and root placement when retaining the original manager. Bone's `TileMap` transform `2823` and render-data transform `2388` are separate scene roots. Decoration object names are not the terrain topology. A floor-looking SpriteRenderer may have no collider; gameplay may rely on a nearby generated edge, standalone collider, moving platform or scripted hazard.

Static YAML component counts (all active and inactive objects, direct serialized documents, not spawned runtime objects):

| Scene | GameObjects | SpriteRenderers | MeshRenderers | Unity Animators | ParticleSystems | AudioSources | EdgeCollider2D | BoxCollider2D | PolygonCollider2D |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| Bone_02 | 2,215 | 1,585 | 45 | 19 | 160 | 63 | 23 | 186 | 30 |
| Tut_01 | 3,552 | 2,694 | 102 | 27 | 197 | 83 | 28 | 372 | 32 |

These are structural anchors for this snapshot, not claims about simultaneous visible objects or performance. Use `scene-prefab-index.tsv` for other rooms and current counts.

### Recovery boundary: do not rebuild blindly

**SERIALIZED:** Bone_02 contains 10 `spriteIds` blobs with **7,533 `/` characters**; Tut_01 contains 16 with **5,332 `/` characters**. These are not valid hexadecimal data. `Docs/SceneResearch/Bone_02_Readable.md` records that Unity saving its derived copy normalized `/` to `0`; its suggestion that some should have been `f` is a recovery hypothesis, not verified original occupancy. Existing baked mesh/collider data can display useful geometry despite malformed logical occupancy. Never treat a successful scene opening as proof that `GetTile` or a fresh `ForceBuild` is correct.

Separately, `ProjectSettings/Physics2DSettings.asset` contains non-hex characters in `m_LayerCollisionMatrix` (`/`, `+`, `)`, `(` were observed). Actual Editor interpretation of those bytes was not measured here. Preserve the source for comparison and verify collision pairs deliberately when migrating; a blind textual copy or global character substitution is not a verified collision matrix.

**Empty-project extraction unit:** tk2d grid rules + required collection/material/texture + selected occupancy + intended collision shapes + layer definitions. First create a disposable tiny room whose occupancy is known. Preserve the source room and its meshes as a reference; perform recovery experiments on derived assets. The historical `Docs/SceneResearch/Tk2dTileMap_Runtime_Demo.md` records a known `8×6` grid test, four chunks, and a single-chunk dirty update. That earlier experiment tests valid newly-created occupancy and the real Terrain collection, not all recovered room blobs.

**PROPOSED-TEST:** build known occupied/empty cells; test world→tile conversion, flip/rotation, boundary cells, walk/jump/wall contact and chunk seams; compare one dirty update with the intended local mesh/collider change. Test terrain collisions separately from damage triggers and decoration.

## Travel: room graph, load phases, entry choreography

### Source locators and chain

- `Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/TransitionPoint.cs`: `TryDoTransition`, `DoSceneTransition`, `DoFadeOut`, `GetGatePosition`, `EnterDoorSequence`, `PrepareEntry/BeforeEntry/AfterEntry`.
- `Assets/Scripts/ProjectCode/Game/01_Core/GameManager.cs`: `BeginSceneTransition`, `BeginSceneTransitionRoutine`, `SetupSceneRefs`, `FindEntryPoint`, `FindTransitionPoint`, `EnterHero`, `FinishedEnteringScene`, `RefreshTilemapInfo`.
- `Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/SceneLoad.cs`: `BeginRoutine`, fetch/activation gating, Addressables ownership, optional boss/additive load and completion events.
- `Assets/Scripts/Assembly-CSharp/SceneTeleportMap.cs` and `Assets/Resources/SceneTeleportMap.asset`: gate existence lookup; inspect target-scene variants as well as base room name.
- `Assets/Scripts/ProjectCode/Game/02_Player/HeroController.cs`: `EnterScene`, leaving/entry state and player placement; consult the player chapter for the movement contract.

**SOURCE:** a boundary gate accepts a Collider2D on player layer **9** in allowed game states; doors use interaction. Before crossing, it handles recoil, binding and special-move restrictions and can push the hero out of the gate. `GetGatePosition` infers direction from its own object name (`top`, `right`, `left`, `bot`, `door`) or door flag. Renaming a gate is a behavior change.

`DoSceneTransition` checks `(targetScene, entryPoint)` in `SceneTeleportMap`, tests subscene suffixes, and falls back to the current scene/current gate if unresolved. It builds `GameManager.SceneLoadInfo`, records leaving state, suppresses input and calls the manager. `entryOffset` belongs to the destination gate's positioning data; it is not a world-space spawn coordinate supplied by the departing gate.

`GameManager.BeginSceneTransitionRoutine` saves level state, changes game state, informs the hero, freezes/fades camera as needed, pauses actor audio and raises unload events. `SceneLoad.BeginRoutine` loads Addressables address **`Scenes/` + scene name** additively with activation disabled; fetch and activation are independently gated. At activation the manager unloads the previous room and refreshes tilemap dimensions; completion sets scene references and begins the room. There is a next-frame `StartCalled` phase and optional additive boss loading before `Finish`. `OnFinishedSceneTransition` and `OnFinishedEnteringScene` are different events.

`FindTransitionPoint` searches registered transition components by object name and can fall back to the first available gate. Therefore a visible hero after teleport is not evidence the requested gate resolved. `EnterHero` has distinct respawn, hazard-respawn, dream-gate and normal-entry branches; normal entry calls the player's coroutine. `FinishedEnteringScene` sets PLAYING, records readiness and emits `HeroEnteredScene`.

Door entry additionally relinquishes control, runs an optional door animation handler, plays tk2d `Enter`/`Exit`, manages pause/invincibility and walking sound, runs custom FSM hooks and starts the load. `TransitionPoint.OnSceneLintUpgrade` can convert a legacy `Door Control` FSM to fields and destroy that FSM in memory. A recovered scene's original YAML and its runtime component list may therefore differ legitimately.

### Serialized exit examples

Each row is a `TransitionPoint` component in the named scene; destination connection is the authored field value, not a runtime-validated journey.

| Source scene | Gate / GO / component | Target scene → target gate | Source gate entry offset |
|---|---|---|---|
| Bone_02 | `left1` / `1004` / `7746` | `Bone_01c` → `right1` | `(0,0)` |
| Bone_02 | `right1` / `735` / `7745` | `Bone_16` → `left1` | `(0,0)` |
| Bone_02 | `top1` / `1240` / `7747` | `Bone_03` → `bot1` | `(0,3.5)` |
| Bone_02 | `top2` / `294` / `7744` | `Bone_10` → `bot1` | `(0,3.5)` |
| Tut_01 | `top1` / `121` / `12123` | `Bonetown` → `bot2` | `(0,2)` |
| Tut_01 | `left2` / `141` / `12124` | `Tut_02` → `right1` | `(0,0)`; `customEntryFSM={fileID:11790}` |
| Tut_01 | `left3` / `1243` / `12126` | `Tut_02` → `right2` | `(0,0)` |
| Tut_01 | `left1` / `1527` / `12127` | `Tut_03` → `right1` | `(0,0)` |
| Tut_01 | `right2` / `903` / `12125` | `Tut_01b` → `left2` | `(0,0)`; `alwaysEnterLeft=1` |
| Tut_01 | `right1` / `2116` / `12128` | `Tut_01b` → `left1` | `(0,0)` |

Script GUID for all these components: **`c68009fe067ad1532625036ddc0eee40`**. To map another room, select that script's bindings in the index, then read each component's `targetScene`, `entryPoint`, entry flags, snapshots, custom FSMs and respawn marker. Also inspect scripts/FSMs that call `SetTargetScene`, `SetTargetDoor` or `BeginSceneTransition`; the static gate graph does not cover dynamic routes, story variants, benches and scripted travel.

**Empty-project extraction unit:** two small rooms, explicit gate registry, entry placement, camera placement, input ownership, actor/scene lifetime and fade contract. Either retain the whole relevant manager/bootstrap/Addressables stack or deliberately implement a smaller adapter. Copying `TransitionPoint.cs` alone pulls in interaction, PlayerData, HeroController, PlayMaker, pooling, map metadata, platform and audio dependencies.

**PROPOSED-TEST:** traverse left/right/top/bottom both ways; enter while falling; blocked-state contact; door interaction; missing gate; same-scene reload; respawn; cutscene entry. Assert destination scene **and exact resolved gate**, input regained, one persistent camera/listener, correct scene-local teardown, no duplicate GUID registration and no stuck actor-audio snapshot.

Historical research tool: `Assets/Editor/GameResearch/SceneReferenceTeleportWindow.cs`, documented in `Docs/SceneResearch/SceneReferenceTeleport.md`. It uses normal `BeginSceneTransition`; starting directly in a gameplay scene is not an equivalent bootstrap. Tool availability and old documented runtime behavior are not a new test result.

## Camera: two-stage follow, room bounds and authored locks

### Source and prefab entry points

| Source/resource | What to inspect |
|---|---|
| `Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/GameCameras.cs` | persistent singleton, `SetupGameRefs`, `StartScene`, listener uniqueness, main/HUD routing, camera effects and particles |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/CameraTarget.cs` | player-state lookahead and target smoothing in `Update`; lock entry/exit, free mode, motion flags |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/CameraController.cs` | `LateUpdate`, `LockToArea/ReleaseLock`, `PositionToHero`, effect configuration and flashes |
| `Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/CameraLockArea.cs` | trigger → lock bounds/priority; `GetWorldBounds`, `ValidateBounds` |
| `Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/ForceCameraAspect.cs` | viewport/aspect, FOV and HUD-size adjustment |
| `Assets/Prefabs/Camera/_GameCameras.prefab` | GUID `362eac96b81545c4ab206f1ae3d530ab`; full rig, FSMs, all camera components and serialized settings |

**SERIALIZED anchors inside the rig:** GameCameras component `114036902516141123`; main camera GO `1917217801272704`, Unity Camera `20439424569976623`, CameraController `114955944218431678`, tk2dCamera `114486309250869385`; target GO `1612649490615443`, CameraTarget `114666059592051547`; HUD camera `20137474183565770`. Main camera uses **perspective** (`orthographic=0`, serialized FOV 24, near/far 10/1000), local Z `-38.1`; HUD is orthographic, serialized size `8.710664`. Main tk2d settings use transparency sort mode `2` and native resolution `1920×1080`. Runtime `ForceCameraAspect` can change FOV/viewport; serialized XY positions are not room start positions.

**SOURCE follow chain:** player state → `CameraTarget.Update` computes destination, facing offset, dash/sprint/harpoon/slide lookahead, rising/updraft/fall/umbrella offsets, lock clamps and smoothing → `CameraController.LateUpdate` adds player look-up/look-down offset, computes camera destination through viewport conversion, smooths X/Y, clamps scene bounds. Both stages matter to feel; replacing them with one `Lerp(hero.position)` changes lag and lookahead.

Key current prefab values: target normal/slow/slower damping `0.2/0.5/0.75`; facing/dash/sprint lookahead `1`; harpoon `3`; slide `5` and vertical `-1`; updraft/superjump `3`. Controller base damping `0.075`, slow-look time `0.35`. Read the actual state branches before changing these: serialized fields with suggestive names are not proof every field is currently used.

Scene bounds are based on logical tilemap width/height, with hardcoded margins **14.6 X and 8.3 Y** (`xLimit=width-14.6`, `yLimit=height-8.3`). These are not measured every frame from arbitrary camera viewport bounds. A very small new room or different world scale/FOV needs an intentional boundary policy. `PositionToHero` waits for a physics step, initializes target placement, respects active locks and eventually emits `PositionedAtHero`; scene audio and particles subscribe to that event.

`CameraLockArea` extends trigger tracking, supports world/self coordinates, negative-value defaults, look-up/down limits and priority. Higher/equal entering priority can take control; release chooses the greatest remaining priority. The initial lock timer allows immediate entry positioning. Bone_02 contains 12 serialized lock components `7730..7741`; e.g. `CameraLockArea (6)` GO `547`, component `7732`, locks Y to `12.6` with priority `2`. Preserve trigger dimensions and transforms as well as clamp numbers.

`ForceCameraAspect.AutoScaleViewportShared` clamps aspect to `1.6..2.3916667`, computes letter/pillarbox viewport and height multiplier; `AutoScaleViewport` updates main tk2d FOV and HUD orthographic size. `GameCameras.MoveMenuToHUDCamera` changes UI layer culling masks. Camera shake/fade also depend on serialized PlayMaker FSMs referenced by GameCameras; trace their component fileIDs, not just C# calls such as `StopCameraShake`.

**Empty-project extraction unit:** begin with explicit world scale, player state adapter, target/controller pair, room bounds and a single lock trigger. Add FOV/aspect, postprocessing, shake/fade and HUD stack after movement tests. Directly copying `_GameCameras.prefab` also imports UI/SilkSpool/PlayMaker/environment dependencies.

**PROPOSED-TEST:** run-stop-turn, dash/slide, tall fall, jump to a ledge, look up/down, enter/leave overlapping locks of different priorities, pause, room transition, multiple aspect ratios. Record hero/target/camera positions over the same input sequence; compare camera placement with the real rig at fixed world coordinates. Do not conclude that an orthographic mockup preserves depth/parallax behavior.

## Art, scene appearance and shader boundary

### Distinguish four layers of evidence

1. **Gameplay geometry:** colliders, Rigidbody2D, hazards, platform code and tilemap occupancy.
2. **Visual geometry:** SpriteRenderer, tk2d mesh sprites, generated meshes, particle renderers, authored transforms and materials.
3. **Scene appearance:** room/map-zone color curves, lighting, hero light/desaturation, blur planes, appearance regions and progression overrides.
4. **Camera composition:** perspective depth, sort mode, sorting layer/order, render queue, depth/stencil/blend states, multiple cameras and image effects.

Do not infer a collider from visible silhouette, a texture from GameObject name, or parallax from a class name. `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/ParallaxSorter.cs` only sets `stripSortingLayers=true` in `Awake`; it does not implement a parallax movement algorithm. Perspective projection and varied Z already produce depth-dependent movement. Any additional movement must be traced to actual scripts/FSMs/animation/shader code.

### A complete static-art reference chain

In `Assets/Scenes/Hornet/Bone_02.unity`, GO **43** is named `bone_BG_03 (36)`, but SpriteRenderer **5280** references **`Assets/Sprite/Bonetown_rubble_0006_1_front.asset`**, GUID `cffe7644c00b75249a1391026b06d9b3`, fileID `21300000`. Its transform **2258** is at `(17.3,28.96,4.6099205)`, with nontrivial rotation/scale. The renderer has sorting layer/order 0/0 and uses **`Assets/Materials/Crossroads_Material.mat`**, GUID `8b4bd58195e0a054fa41b6cb381423d9`, fileID `2100000`.

That sprite's `m_RD.texture` points to **`Assets/Texture2D/sactx-0-4096x8192-BC7-HBone-0e365193.png`**, GUID `ac7ad4d813a01f346982a2908eb8a572`, fileID `2800000`; rect `(1614,1848,224,330)`, pixels-per-unit `64`, pivot `(0.5,0.5)`. Its mesh data is serialized in the Sprite asset. The material's `_MainTex` is null but its shader is **`Assets/Shaders/Sprites-Lit.shader`**, GUID `b77956671711ebb40963caef124d0a7c`; per-renderer sprite texture binding is meaningful here. A null material `_MainTex` is not sufficient evidence of a missing texture.

This example deliberately demonstrates name reuse/mismatch. General chain: scene renderer → exact Sprite `(guid,fileID)` → serialized texture/rect/mesh → texture and `.meta`; renderer material → shader GUID → shader/includes/keywords; transform ancestry → world position/scale; camera → projection/sorting/culling. For tk2d, replace the Sprite asset step with sprite collection + numeric definition ID.

### Room appearance chain

`Assets/Scripts/Assembly-CSharp/CustomSceneManager.cs` is the room controller (script GUID **`13a73adb0f92d3df5665deeab0498c59`**). It configures scene type, map zone, environment, wind, darkness, teleport restrictions, particles, snapshots, borders, corpse spawning and scene pools. `Start` loads `ReferencesData` and `sceneDefaultSettings.GetMapZoneSettingsRuntime` unless the room overrides color settings. Both sampled rooms set `overrideColorSettings=0`; their serialized color fields alone do not establish final runtime color.

`SceneManagerSettings` path: `Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/SceneManagerSettings.cs`. `CustomSceneManager.UpdateScene` sets camera color correction curves, ambient lighting, hero light, `_HeroDesaturation`, and `_BlurPlaneVibranceOffset`. Current `AdjustSaturationForPlatform` returns `originalSaturation + 0.4f`. Hero desaturation derives from `heroSaturationOffset + 0.5f`, then is negated for the shader global. `SetLighting` mixes intensity using `AmbientIntesityMix` and writes `RenderSettings.ambientLight` with ambient intensity 1. Do not copy only the room tint and expect the same image.

`Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/SceneColorManager.cs`: `UpdateScript/UpdateScriptParameters` blend A/B saturation, paired RGB curves, ambient colors/intensity and hero light. `Assets/Scripts/Assembly-CSharp/SceneAppearanceRegion.cs` is a further lookup target when regional appearance changes; `CustomSceneManager.AddInsideAppearanceRegion/RemoveInsideAppearanceRegion` tracks active overrides and uses per-region fade durations.

`Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/BlurPlane.cs` maintains a Z-sorted active plane list and swaps renderer material/visibility. It writes the global vibrance offset; it is not the whole blur implementation. Follow `Assets/Scripts/Assembly-CSharp/CameraBlurPlane.cs` and `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/LightBlurredBackground.cs` for camera-side effect work.

`Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/SceneParticlesController.cs` selects default, map-zone, custom or act-3 particles from `CustomSceneManager`, activates them when the camera is positioned, and scales horizontally with viewport aspect. `_GameCameras.prefab.sceneParticlesPrefab` references **`Assets/Prefabs/Effects/Particle System/Knight Particles_follow.prefab`**, GUID `738b0731c74291f4a976140c5295066b`, component fileID `114321827775029018`. The rig instantiates it and parents it to tk2dCamera. This global environment layer is additional to hundreds of scene-local/actor particles; inspect individual ParticleSystem modules, renderer material, sorting, subemitters and lifecycle components for an effect.

`Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/MeshSortingOrder.cs` enforces MeshRenderer sorting layer/order through a callback singleton, so Inspector-only changes may be overwritten. `SetZ.cs`, `SetZRandom.cs`, and related scripts in `Assembly-CSharp` are further search targets for dynamic depth. Physics layers, sorting layers, Z position and shader render queues are distinct mechanisms.

### Shader boundary

Current `ProjectSettings/GraphicsSettings.asset` has `m_CustomRenderPipeline={fileID:0}` and `ProjectSettings/ProjectSettings.asset` has `m_ActiveColorSpace=0` (Gamma). Use the current built-in rendering setup as baseline; a URP migration is a separate implementation/validation task.

`Assets/Shaders/Cherry-Sprites-Default.shader` was read in full: transparent queue, `Cull Off`, `ZWrite Off`, `ZTest LEqual`, premultiplied `Blend One OneMinusSrcAlpha`; texture × tint then alpha multiplication, optional pixel snap, optional dithering added to RGBA. `Assets/Shaders/Sprites-Lit.shader` properties/render state/variant declarations were inspected: ambient, saturation, flash, black-thread, external alpha, pixel snap, dithering and instancing branches. Its name does not imply standard Unity lit/PBR behavior.

Recovery/maintenance references: `Docs/ShaderRecovery/README.md`, `READABILITY.md`, `READABILITY_SECOND.md`, their JSON reports, and `tools/shader_readability/`. Existing reports describe 167 reconstructed shaders, preservation of material references and Metal/Gamma testing on Unity 6000.5.4f1. These are **HISTORICAL-TEST**, not a new audit of every pass or every target platform. The reconstructed shaders carry source-program hashes and comments; authored original shader organization and stripped variants are unavailable.

Keep `.meta` GUIDs, shader names, render states, keywords and shared includes together. GUI shared includes live under `Assets/GUIBlendModes/Shaders/Includes/`; TMP shared includes under `Assets/Shader/Includes/`. Do not use the old external recovery generator to overwrite later readability work. The documented `Sprites-Screen`/`Sprites-VividLight` internal-name collision is another reason to resolve by GUID and path, not shader name alone.

**Empty-project art slice:** one collision-tested room + a few exact decorative references + original camera depth/projection + chosen shader/material/texture chain. Then add scene grading, hero light, particles, blur, special masks and camera effects. Keep source composition as measurement reference even if the new game's art changes.

**PROPOSED-TEST:** same world coordinate screenshots with main camera movement, backdrop/foreground visibility, alpha edges, flash, darkness and selected scene-grade changes; assert no sorting inversion or missing includes. Test each intended graphics backend/color space separately. Historical Metal/Gamma parity does not establish other backends or a URP port.

## Animation: tk2d frame libraries and Unity Animator coexist

### Player reference chain

- Hero prefab: **`Assets/Prefabs/Heroes/Hero_Hornet.prefab`**, GUID **`41acb66e2e431c44ab8b638ce897d292`**; root GO **`1709254077376921`**.
- Root `HeroAnimationController` component **`114977247909169898`** points to root tk2d animator **`114226160322065142`**.
- That animator (script GUID `5996133e774984aa7a33c40ed829e17f`) points to **`Assets/Animations/Knight.prefab`**, GUID **`a14142627197a144586ee7b8abd07265`**, `tk2dSpriteAnimation` component **`114724804207875695`**, with serialized default clip 0.
- Root `tk2dSprite` component **`114898726725907312`** points to **`Assets/Collections/Knight Data/Knight.prefab`**, GUID **`3f4d9d6376d359348a4555fe49e6ca15`**, collection component **`114724804207875695`**; serialized initial `_spriteId=875`.
- Windy needolin library: **`Assets/Animations/Hornet NeedolinWindy.prefab`**, GUID `758698ffb2831164c96633a9252a3e30`, referenced by `HeroAnimationController.windyAnimLib`.

The root hero has tk2d/MeshRenderer/MeshFilter, not a Unity Animator for its primary body animation. The entire Hero_Hornet prefab nevertheless contains **60 Unity Animator components**, **117 ParticleSystems**, and **121 AudioSources** across descendants. Do not flatten all descendants into the root animation mechanism. Old asset names `Knight` contain current Hornet animation data.

The inspected library has **501** top-level clip entries and the collection **1,828** sprite-definition entries in this snapshot. A clip can use different collections per frame; do not assume every frame always uses the root collection. Collection sprite definitions carry frame name, vertices, UVs, material ID, optional colliders and attach points, then material/texture/platform data. Preserve atlas UV/mesh data and material selection, not just cropped frame PNGs.

### Code and timing contract

Read together:

- `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimator.cs`
- `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimation.cs`
- `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimationClip.cs`
- `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimationFrame.cs`
- `Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimatorCallbackHooks.cs`
- `Assets/Scripts/ProjectCode/Game/02_Player/HeroAnimationController.cs`

**SOURCE:** tk2d uses `clipTime` in frame units, advanced by `deltaTime * clipFps`; `ClipTimeSeconds` converts back. Clip `Duration=frames.Length/fps`. Animator is driven through the callback singleton's late update, selecting scaled or unscaled delta from `isRealtime`. It supports local and global pause. `Play(clip)` for the same already-playing clip at start time 0 updates FPS without restarting; do not assume repeated `Play` restarts an attack.

Wrap modes: `0 Loop`, `1 LoopSection`, `2 Once`, `3 PingPong`, `4 RandomFrame`, `5 RandomLoop`, `6 Single`. LoopSection repeats from `loopStart`. Frame structs store `spriteCollection`, `spriteId`, `triggerEvent`, `eventInfo`, `eventInt`, `eventFloat`. `WarpClipToLocalTime` can trigger a frame event immediately; normal advancement uses `ProcessEvents` and invokes completion for Once. Subscribe to frame/completion callbacks or PlayMaker animation actions according to the consumer; do not replace them with a fixed timer without checking the original contract.

Selected **SERIALIZED** base-library examples (0-based frame indices):

| Clip | Frames / FPS | Wrap | Frame events |
|---|---|---|---|
| `Idle` | 6 / 12 | Loop | none |
| `Run` | 10 / 15 | Loop | frame 3 and 8: `Footstep` |
| `Dash` | 9 / 16 | Once | frame 3: `Footstep` |
| `Slash`, `SlashAlt` | 5 / 20 each | Once | no triggerEvent frames in these base clips |
| `UpSlash` | 7 / 24 | Once | none |
| `DownSpike` | 4 / 25 | LoopSection | none; inspect loopStart when implementing |
| `HardLand` | 12 / 12 | Once | none |
| `Wake Up Ground` | 33 / 12 | Once | triggers on frames 21 and 28 |

These frame counts are visual playback data, **not attack hit-window duration**. Hitboxes, movement, damage, effects, animation remapping and interruptions are independently driven by HeroController, attack objects, configuration and FSMs. Read the combat/player chapter before reusing a move.

`HeroAnimationController.AnimationEventTriggered` handles wake-up sounds by event count, sends `Footstep` to `HeroAudioController` when the mesh renderer is enabled, and starts looped audio for `Sprint Backflip`. `RefreshAnimationEvents` rewires subscriptions. The clip's `eventInfo` is interpreted by the consumer, not universally sent as a PlayMaker event.

For Unity Animator descendants: inspect the component's `m_Controller` → `.controller`/override controller → states, transitions and actual AnimationClips → property bindings and `m_Events`. The directories `Assets/AnimatorController`, `Assets/AnimatorOverrideController`, `Assets/AnimationClip`, and `Assets/Animation Controllers` coexist with tk2d `Assets/Animations` and `Assets/Collections`. Directory naming alone does not tell the active runtime driver. `AudioEventAnimationEvents.PlayAudioEvent(int)` is one Unity animation-event receiver; read its serialized event table/index.

**Empty-project extraction unit:** one tk2d clip/library + each frame's collection/material/texture + renderer + callback hooks + consumer/event contract. Start with Idle/Run and footsteps, then one attack with separately verified hitbox timing. If converting to Unity Animator, preserve frame timing, pivots, attach points, pause behavior, restart semantics, completion and custom frame events explicitly.

**PROPOSED-TEST:** frame sequence at normal/low frame rates, pause/unpause, replay of same clip, Once completion, LoopSection, frame-event count, left/right transform, crest/config remapping, animation interruption. Verify effects and sound sync separately from health/damage.

## Audio: sources, pooled events, cues, snapshots and environment

### Source locators

| Path | Read for |
|---|---|
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/AudioEvent.cs` | serializable single-clip event, pitch/volume, pooled one-shot/loop, optional vibration |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/AudioEventRandom.cs` | random clip selection and per-clip vibration mapping |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/AudioEventManager.cs` | global per-clip frequency gate and camera-distance culling |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/SpawnableAudioSource.cs` | recycle source after minimum five frames when no longer playing |
| `Assets/Scripts/ProjectCode/GlobalSettings/Audio.cs` | Addressable global settings and source prefab getters |
| `Assets/Scripts/ProjectCode/Game/02_Player/HeroAudioController.cs` | persistent hero sources, footsteps gating, pause/stop, vibrations |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/AudioManager.cs` | persistent music/atmos source arrays, cue lifetime, snapshots, scene handshakes |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/MusicCue.cs` | channels, sync flags, PlayerData alternatives, preload |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/AtmosCue.cs` | five atmosphere channels and alternatives |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/AudioLoopMaster.cs` | music channel time/sample sync and resync |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/MusicRegion.cs` | trigger-based music cue/snapshot changes |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/AtmosRegion.cs` | trigger-based atmos changes; inspect anomaly below |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/SnapshotMarker.cs` | distance/curve snapshot influence measured from main camera |
| `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/AudioEventAnimationEvents.cs` | animation-event index → serialized random event / supplied source |

### One-shot sound execution

`AudioEvent` is a **serializable struct**, not necessarily an independent ScriptableObject asset. It is embedded in components/data assets with clip, pitch range, volume and optional vibration. `SpawnAndPlayOneShot` checks clip/volume, resolves the default source prefab, asks `AudioEventManager.TryPlayAudioClip`, spawns from the object pool, sets priority/volume/pitch, plays, registers recycle cleanup and optionally vibrates. Sound routing/spatial blend/falloff come from the source prefab, not the clip filename.

`AudioEventManager` tracks a cooldown by **AudioClip** globally within its instance and clears on scene load. It rejects playback if no `GameCameras` exists, even for sources that do not need distance culling. When source `spatialBlend>0.95`, it rejects sources beyond `maxDistance` from the main camera. If a migrated action is silent, check these guards before assuming its sound asset is missing.

`Assets/Data Assets/GlobalSettings/Global Audio Settings.asset`, GUID **`4c4c595322b493945b0598c77dc23af0`**, sets actual `audioEventFrequencyLimit=0.05` seconds (the source initializer is 0.02, so use the asset). Addressable key **`Global Audio Settings`** is requested in `GlobalSettings.Audio`. Prefab bindings:

| Setting | Prefab / GUID | AudioSource fileID |
|---|---|---|
| default | `Assets/Audio/Audio Player Actor.prefab` / `99068b2a95bddff419cb6f176648d4e6` | `82724804207875695` |
| 2D | `Assets/Audio/Audio Player Actor 2D.prefab` / `e8466d04a5c03bc4b8d6a0838af84de7` | `82724804207875695` |
| UI | `Assets/Audio/Audio Player UI.prefab` / `06c175e5eb31b7b4fa8efc06d3560a53` | `82724804207875695` |

Default Actor source routes to **`Assets/Audio/Actors.mixer`**, GUID `d910a835fc4287448b891cc742c2a38a`, group fileID **`24300004`** (`Actors`); serialized min/max distance 39/70, Doppler 0. Follow prefab components for recycle/pause/lifetime. `SpawnableAudioSource.Update` recycles after `framesPassed>5 && !audioSource.isPlaying`; delayed/looped playback must retain its original lifecycle contract.

`AudioEvent.PlayOnSource` sets pitch/clip and plays but does **not** assign `Volume`, unlike the spawned path. `AudioEventRandom.PlayOnSource` likewise uses the source's own volume. A refactor changing the playback route can therefore change gain.

### Hero/environment sounds

Hero root `HeroAudioController` component **`114929544267463227`** references child sources for jump, landing, dash, recoil, wallslide, falling, etc. Trace each local source fileID to its AudioClip, output mixer group and settings. `PlaySound` suppresses work while hero is paused; footstep enum calls mostly enable eligibility/run-start foley rather than firing every step immediately. The actual animation `Footstep` callback calls `PlayFootstep`, which uses the current `RandomAudioClipTable`, eligibility/grace, block flag and sprint vibration.

Environment changes can replace the table through `SetFootstepsTable`; continue through `HeroController.checkEnvironment` and environment region/config references. The scene manager sets default environment type and asks the hero to check it shortly after entry. Source comments enumerate Dust/Grass/Bone/Spa/Metal/NoEffect/Wet, but inspect enum/config and region overrides for the final surface. Bone_02's serialized default is `0`, Tut_01's is `6`; do not infer final footsteps from scene name.

### Music and atmosphere

`AudioManager` is serialized in **`Assets/Prefabs/Managers/_GameManager.prefab`** (script GUID `a1b09a7a4ab69fc700bfb75efe174a20`). Read the exact component's source arrays, mixers and AudioLoopMaster references when migrating. Music channel enum is `Main=0, MainAlt=1, Action=2, Sub=3, Tension=4, Extra=5`; Atmos has `Layer1..Layer5`.

`ApplyMusicCue` resolves PlayerData alternatives, skips null/same cue, stops any pending cue coroutine and begins playback after realtime delay. `BeginApplyMusicCue` clears old sources and schedules enabled tracks together at `AudioSettings.dspTime+0.1`; then enables loop sync. `AudioLoopMaster` corrects drift using samples when sample rates match and time otherwise, with periodic resync. These are stems whose arrangement/mix can change through snapshots, not one audio file per room.

**Current-source trap:** `AudioManager.ApplyMusicCue(MusicCue,float,float,bool)` currently does not use its `transitionTime` or `applySnapshot` parameters. Snapshot fades are performed by `ApplyMusicSnapshot`/`BeginApplyMusicSnapshot` and other explicit snapshot calls. Do not promise a fade merely from passing those arguments. `MusicCue.Snapshot` exists in data, but that does not prove this method applies it.

`ApplyAtmosCue` resolves alternatives; new enabled channels choose a randomized initial playback time and retain already-playing identical clips. Current cue setters acquire a reference to the current Addressables scene handle and release the old one to retain referenced audio assets across room unloads. Removing that ownership can cut off or unload continuing music.

`CustomSceneManager.Start` waits for `CameraController.PositionedAtHero` before applying room music/atmos cues and snapshots, then announces snapshot readiness. Actor audio has a separate load-pause/unpause handshake between GameManager, CustomSceneManager and AudioManager with a five-frame fallback and manager wait timer. A correct AudioSource alone can remain inaudible under the wrong snapshot.

`MusicRegion` and `AtmosRegion` use player-detecting trigger tracking on layer 13; they can change cue and snapshot independently on enter/exit. **Observed anomaly:** `AtmosRegion.FadeOut` tests `exitAtmosSnapshot != null` but passes **`enterAtmosSnapshot`** to `TransitionToAtmosOverride`. This chapter records current source behavior; origin and desired correction are unverified. Test enter/exit before cloning it.

`SnapshotMarker.GetBlendAmountRaw` measures squared 2D distance from the **main camera**, not directly the hero, between inner/outer radii and applies `blendCurve`. `AudioManager.TransitionToCurrentSnapshots` selects the marker with greatest influence and blends it with cue/override snapshot; it does not average every nearby marker. Camera motion can therefore affect the mix.

### Concrete Bone/Tutorial audio bindings

| Room/resource | Binding |
|---|---|
| Bone_02 `_SceneManager` component `7729` | Atmos cue `Assets/Audio/AtmosCues/Boneforest.asset` (`f1af3a3cee041c14780f0fea7351ea46`, `11400000`); music cue `Assets/Audio/MusicCues/Boneforest.asset` (`05b1557de1ab6f94b81a197ee7ebd06d`, `11400000`) |
| Bone_02 room snapshots | Atmos mixer `662c9539a453ed1478ee449d319c5ba8` / `24500044`; Enviro `ea18ab3cc2f27344b97372bea7eadfaa` / `24500026`; Actors `d910a835fc4287448b891cc742c2a38a` / `24500034`; Needolin `93145315692fcbe448006e0c8023ea1a` / `24500012`; room musicSnapshot null |
| Bone_02 timing | music delay `0.5`, serialized transition `2`; other room transition `0.25`; gates reference Actors snapshot `24500036` and transition `1.5` |
| Tut_01 `_SceneManager` component `12104` | Atmos `Assets/Audio/AtmosCues/Moss Cave.asset` (`b1583dc5f171c1e4da322c7f69f1c0a5`, `11400000`); musicCue/musicSnapshot null; enviro snapshot `24500016`; transition `1` |

Null room music cue means that this component does not choose a new music cue; it is not proof that the room is silent. Inspect its FSMs/regions/cutscenes and currently retained cue.

Boneforest music cue contains four tracks: `Assets/Audio/HornetMusic/BONEFOREST/H49-102 MAIN BONE.ogg`, `H49-102 MAIN LAVA.ogg`, `H49-102 ACTION.ogg`, `H49-102 SUB.ogg` in channels 0..3; action has `sync=2` (ExplicitOff), others `0` (Implicit). Atmos cue channels 0..2 reference `Assets/Audio/HornetMusic/ATMOS/atmos_boneforest.ogg`, `Assets/Audio/HornetMusic/ATMOS/atmos_lava_far.ogg`, `Assets/Audio/Atmos/cave_atmos_misc_3.ogg`. The cue assets have null snapshots and no alternatives at this snapshot; room/marker/FSM snapshots remain significant.

Mixer assets present under `Assets/Audio/`: `Master.mixer`, `Actors.mixer`, `Atmos.mixer`, `EnviroEffects.mixer`, `DamageEffects.mixer`, `UI.mixer`, `Music.mixer`, `Music Effects.mixer`, `Music Groups.mixer`, `Music Options.mixer`, `Sound Options.mixer`, `Diegetic Music.mixer`, `Needolin Mixer.mixer`. Trace each source's output group and each group's output/mixer relationship. Similar snapshot names in different mixers are different objects; GUID + subasset fileID distinguishes them.

**Empty-project audio slice:** one direct hero source and one pooled event using an explicit global settings asset/source prefab, valid camera/listener and mixer output; then footsteps with surface tables; then multi-channel cue manager/snapshots and cross-scene ownership. Music Manager import additionally needs singleton lifecycle, player state alternatives, Addressables, loop master, camera placement and scene readiness.

**PROPOSED-TEST:** play the same clip rapidly from several objects (0.05s cooldown); near/far 3D source vs 2D source; pool reuse; delayed/looped stop; pause/unpause; footstep event cadence; crest/surface changes; multi-stem sync; cue change vs snapshot-only change; scene unload while music continues; marker enter/exit and no-cue room. Listen and inspect mixer state/source ownership, not only logs saying Play was called.

## Global lookup and extraction recipes

### Find a component without loading an entire scene

1. Resolve exact source file and `.meta` GUID; script bindings find `(asset, component fileID, owner GO)`.
2. In source YAML, find `--- !u!114 &<componentID>` and read through the next document header. For built-in components use class IDs: GameObject 1, Transform 4, Camera 20, MeshRenderer 23, MeshFilter 33, Rigidbody2D 50, CircleCollider2D 58, PolygonCollider2D 60, BoxCollider2D 61, EdgeCollider2D 68, AudioSource 82, Animator 95, ParticleSystem 198, ParticleSystemRenderer 199, SpriteRenderer 212.
3. Resolve `m_GameObject` in the same file. Read Transform and parent chain, active state/layer/tag, other components and child references. Root GameObject fileID repeats between prefab files, so include asset identity in notes.
4. Resolve external GUID with `data/asset-index.tsv` and inspect its exact subasset fileID. Follow dependencies recursively with `data/asset-references.tsv` as candidate edges, then confirm the field's meaning in source. Include `.meta` for asset identity and import settings.
5. For script bindings to `Assets/Plugins/PlayMaker.dll`, inspect serialized `fsm.name`, states/transitions/action types/parameters; do not expect a `.cs` file named after the object's FSM. Use `data/fsm-index.tsv` to narrow the state machine.
6. Search code for runtime changes to the inspected fields/events. Serialized defaults are only starting conditions.

Minimal bounded commands (run from repository root):

```sh
rg -n 'BeginSceneTransition|RefreshTilemapInfo' Assets/Scripts/ProjectCode/Game/01_Core/GameManager.cs
rg -n 'targetScene:|entryPoint:' Assets/Scenes/Hornet/Bone_02.unity
rg -n 'c68009fe067ad1532625036ddc0eee40' Docs/AgentReference/data/script-bindings/
rg -n '^  - name: (Run|DownSpike)$' Assets/Animations/Knight.prefab
rg -n 'a14142627197a144586ee7b8abd07265' Docs/AgentReference/data/asset-index.tsv
```

For an exact object YAML slice, use a streaming reader bounded by document headers; avoid `rg -A` on large typeless-data fields where one line can contain thousands of bytes. PlayMaker tables and binary/hex fields need the format-aware reader described in the FSM chapter, not an ad-hoc guess at bytes.

### Per-feature migration record to leave for the next Agent

Record feature name and search terms; source snapshot; source symbols; `(asset path, GUID, component/fileID)` anchors; inbound events and callers; outbound events; serialized configuration; dependent prefabs/collections/textures/audio/mixers/shaders; global services/Addressable keys; lifecycle/pool ownership; destination implementation and deliberate adaptations; source anomalies; exact tests performed with results. Mark missing runtime evidence explicitly. A copied file list is not enough to reconstruct scene-bound behavior.

## Unresolved GUID audit: distinguish object references from metadata

A lexical `guid:` scan is not automatically an asset dependency graph. The final static audit examined the 322 distinct GUID strings that were unresolved in scoped local `.meta` files; these classify as follows. See `data/unresolved-reference-audit.json` for the exact candidate list and package-cache evidence. Counts refer to this snapshot.

| Kind | Distinct GUIDs | Meaning and evidence |
|---|---:|---|
| Package script PPtrs | 11 | True `m_Script: {fileID, guid, type}` references resolved in the currently installed Addressables/Input System package cache; restore through package manifest/lock, not by synthesizing local scripts |
| Mixer exposed-parameter IDs | 6 | Internal identifiers in `m_ExposedParameters[].guid`, repeated in the same mixer's `m_Volume` fields and snapshot parameter dictionaries; **not asset PPtrs**, no missing external assets implied |
| PS5 source-clip linker strings | 303 | `audioClipSource.guid` inside `AssetLinker<AudioClip>`; serialized string metadata with intended source-clip association, **not a Unity PPtr**; its local resolution/runtime fallback is a separate recovery concern |
| Unresolved scene object PPtrs | 2 | One snapshot GUID in Bellway_City plus one script GUID bound to 11 Coral components; specific anchors below |

The six mixer IDs are `22ff5ad1bdd4e8a43bca016861216889` (Sound Options), `46b496ccdef9b78419a52ba6553217b1` and `fc44a01b4ebb7be41bdb3760fb5cfbae` (Master), `59dc5192db44a4844885b916bd1a7b10` (Music Options), `90283d798dd1b0141be87889d4e523df` (UI), and `b6981a9fc24edd945908916522e7d91a` (Actors), all under `Assets/Audio/*.mixer`. For example, Actors repeats its ID in its group volume and snapshot float maps. Actual AudioMixer object references instead carry `fileID` and possibly external asset `guid/type`. `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/MuteAudioChannel.cs` accesses exposed parameters by serialized name via `GetFloat/SetFloat`; preserve parameter identity/names during migration, but do not search the AssetDatabase for these six internal IDs.

**PS5 source evidence:** `Assets/Scripts/ProjectCode/TeamCherry/PS5/PS5VibrationData.cs` declares `vibrationClip: AudioClip` and `audioClipSource: AssetLinker<AudioClip>`. `Assets/Scripts/Assembly-CSharp/AssetLinker.cs` serializes a private `string guid` and holds `[NonSerialized] T asset`; `Asset` is a getter/setter for that in-memory value and does not resolve `guid`. No GUID resolver was found in the inspected loose-source `AssetLinker` consumers. Do not assume Unity resolves this custom string automatically; editor/platform tooling or explicit `SetAsset` would have to supply it. `PS5VibrationData`'s implicit AudioClip conversion returns the direct `VibrationClip` when present, otherwise `ClipSource`.

All 303 candidate PS5 assets were checked for this exact field layout and PS5VibrationData script GUID `ec89f3fd3753f15c8420de317f866cad`: **301 have a direct vibrationClip PPtr resolving to a local audio asset; 2 have vibrationClip null**. The latter are `Assets/Audio/Vibration Files/PS5/understore_toll_bench_deactivate_vd.asset` (linker string `af84d9717612b634fa525c47ed27f57c`) and `Assets/Audio/Vibration Files/PS5/hornet_walk_footsteps_wetwood_vd.asset` (`cbdded5b18fb4f14d92ff016f9abcbbd`). Thus “303 missing sound assets” would be incorrect; retain the custom-link recovery caveat, especially for fallback use. Actual platform vibration output was not tested.

**True unresolved PPtr anchors:**

- `Assets/Scenes/Hornet/Bellway_City.unity`: `Atmos Snapshot Marker` GO `1849`, `AtmosSnapshotMarker` component `8641`; `snapshot: {fileID:24500000, guid:0000000deadbeef15deadf00d0000000, type:2}`. The marker script itself resolves to `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/AtmosSnapshotMarker.cs`. The snapshot target does not resolve in local metadata/package cache; do not invent its intended mixer/snapshot or assert an audible impact without runtime inspection.
- Script GUID **`5d4bff728ab3570cbc12741204593b03`**, `fileID:11500000`, is unresolved in **11 enabled MonoBehaviour components**. Raw YAML and the sharded script-binding index independently agree: **10** in `Assets/Scenes/Hornet/Coral_36.unity` (`2777,2785,2788,2796,2799,2804,2831,2840,2843,2846`, on Judge Child objects), and **1** in `Assets/Scenes/Hornet/Coral_Judge_Arena.unity` (`5462`, GO `835`, hierarchy `Boss Scene/Pilgrims/Gate NPC`). Each serializes `animator` pointing to an existing tk2dSpriteAnimator and `debugPlayedAnimations:1`. The component's true class/behavior remains unidentified; those two fields are insufficient to replace or declare it harmless. This is 1 missing script identity used 11 times, not 11 distinct missing script types.

This audit read `AssetLinker.cs`, `IAssetLinker.cs`, `PS5VibrationData.cs`, `PS5VibrationManager.cs`, `AtmosSnapshotMarker.cs` and `MuteAudioChannel.cs`, plus all candidate PS5 field layouts, six mixer internal-ID repetitions and all 12 affected scene PPtr occurrences. It performed static classification only and changed no game assets.

## Existing research and coverage boundaries

- `Docs/SceneResearch/Bone_02_Readable.md`: derived organizational scene `Assets/Scenes/Hornet/Bone_02_Readable.unity`, not the original hierarchy. Prior report records grouping 396 static visual roots into `_00_ART` while keeping active logic/terrain managers out. Original scene-local IDs were preserved, but use the original Bone_02 as evidence and the derived copy for navigation. Its previous normalization caveat remains material.
- `Docs/SceneResearch/Tk2dTileMap_Flowcharts.md`, `Tk2dTileMap_Runtime_Demo.md`: useful explanations and historical valid-data experiment; verify current source before reusing an algorithm.
- `Docs/SceneResearch/SceneReferenceTeleport.md`: earlier workflow for initialized game navigation; not a standalone scene loader specification.
- `Docs/ShaderRecovery/*`: source recovery/maintenance history and bounded GPU evidence; do not generalize platform coverage.

### Semantic reading ledger for this chapter

**Full/near-full method-level source reading:** `CustomSceneManager.cs`; `SceneManagerSettings.cs`; `SceneLoad.cs`; `TransitionPoint.cs`; `tk2dTileMap.cs`; `GameCameras.cs`; `CameraLockArea.cs`; `SceneParticlesController.cs`; `BlurPlane.cs`; `ParallaxSorter.cs`; `MeshSortingOrder.cs`; `tk2dSpriteAnimator.cs`; `tk2dSpriteAnimation.cs`; `tk2dSpriteAnimationClip.cs`; `tk2dSpriteAnimationFrame.cs`; `AudioEvent.cs`; `AudioEventRandom.cs`; `AudioEventManager.cs`; `AudioEventAnimationEvents.cs`; `SpawnableAudioSource.cs`; `HeroAudioController.cs`; `AudioManager.cs`; `MusicCue.cs`; `AtmosCue.cs`; `MusicRegion.cs`; `AtmosRegion.cs`; `SnapshotMarker.cs`; `AudioLoopMaster.cs`; `GlobalSettings/Audio.cs`; music/atmos/sync enums. Exact paths are given in the locator sections; use the global source index to disambiguate names.

**Focused method/field review, not whole-file certification:** `GameManager` load/entry/tilemap methods; `CameraTarget` fields/GameInit/SceneInit/Update and API inventory; `CameraController` fields/GameInit/SceneInit/effect configuration/LateUpdate/lock/bounds/positioning entry; `ForceCameraAspect` viewport/FOV methods; `SceneColorManager` curve/lighting update; `BuilderUtil.CreateRenderData` and method inventory; `ColliderBuilder2D.Build/BuildForChunk/BuildLocalMeshForChunk`; Layer/SpriteChunk/RenderMeshBuilder symbol navigation; `HeroAnimationController` event callback and bindings; Cherry sprite shader complete and Sprites-Lit interface/render states/variant declarations.

**Serialized structural traversal and targeted field reading:** entire YAML document inventories for Bone_02, Tut_01, Hero_Hornet and _GameCameras; components/anchors tabulated above; shared TileMap data/Terrain definition; Knight clip and sprite-definition tables (counts and selected clip events, not visual review of every frame); global audio settings; Boneforest/Moss Cave cues; actor source/mixer group; one full Bone decoration asset chain; relevant ProjectSettings. This does not imply semantic reading of every FSM, particle module, collider path, audio clip, animation frame or scene object in those assets.

**Still requires targeted research when selected for a new feature:** every room-specific encounter/set piece, conditional/additive world variants, full PlayMaker action parameters, all camera shake states, regional color/blur implementations, Unity animation property curves, particle lifetime scripts, cinematic/video sequence content, platform audio importer behavior, each shader variant and non-Metal backend. The global indexes provide reachability for these; future Agents should extend the ledger and add measured examples instead of promoting indexed data to tested behavior.
