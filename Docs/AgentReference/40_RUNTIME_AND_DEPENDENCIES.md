# 40 — Runtime infrastructure, FSMs and dependency boundaries

Use this chapter when code compiles but does not initialize, events disappear, pooled objects behave differently on their second use, or a copied prefab loses behavior. Paths here are project-relative. Source-derived observations are static unless explicitly stated otherwise.

## 40.1 Engine and assembly baseline

| Evidence | Snapshot fact | Consequence for an empty project |
|---|---|---|
| `ProjectSettings/ProjectVersion.txt` | Unity `6000.5.4f1` | Use this as the reference interpretation version; record any target-version difference |
| `Packages/manifest.json` | Addressables `2.9.1`; Input System `1.19.0`; Rider `3.0.40` and Unity modules | Restore target-appropriate package dependencies; editor tooling is not a gameplay dependency |
| `ProjectSettings/GraphicsSettings.asset` | `m_CustomRenderPipeline: {fileID: 0}` | The snapshot uses the Built-in rendering configuration; a URP project needs explicit shader/effect adaptation |
| `ProjectSettings/ProjectSettings.asset` | `activeInputHandler: 2` | Current project enables both input backends; see the current input adapter rather than assuming an older input library |
| `ProjectSettings/EditorBuildSettings.asset` | One enabled build scene, `Assets/Scenes/Pre_Menu_Loader.unity` | The rest of the route is not enumerated in Build Settings; inspect Addressables |
| `Assets/Scripts/TeamCherry/TeamCherry.TK2D/TeamCherry.TK2D.asmdef` | Separate `TeamCherry.TK2D` assembly; unsafe allowed; overrides references; explicit `TeamCherry.SharedUtils.dll`; auto-referenced | Preserve or deliberately replace this assembly boundary when reusing its runtime |
| `.csproj` files at root | Generated reference/compile views for the current local Editor | Useful diagnostic evidence; these do not replace Unity assembly/plug-in settings |
| `Assets/**/*.cs.meta` | Script GUID and importer execution order | Copying only C# can lose serialized bindings and scheduling |

`Assembly-CSharp` in a directory name is not an asmdef. Use `data/source-index.tsv` for a nearest-asmdef/folder-rule hint, then verify platform defines and generated compilation references. `Assets/Scripts/BuildSupport/` contains compatibility dummy namespace classes, including serialization/cryptography stubs; these are evidence of recovery support, not implementations of those .NET services.

### Binary boundaries

`data/asset-index.tsv` inventories every scoped DLL and its hash. Important groups:

- `Assets/Plugins/PlayMaker.dll` and `Assets/Plugins/PlayMaker/WebGL/PlayMaker.dll`: core FSM runtime variants, with distinct platform importer metadata. Action/editor source in this project is not the complete runtime source.
- `Assets/Plugins/TeamCherry.SharedUtils.dll`, `TeamCherry.NestedFadeGroup.dll`, `TeamCherry.Splines.dll`, `TeamCherry.Cinematics.dll`, `TeamCherry.Localization.dll`, `TeamCherry.BuildBot.dll`: shared proprietary runtime/tooling boundaries. Follow the actual namespace/type and serialized DLL subasset reference; do not invent missing method bodies.
- Unity/TMP/UI/Timeline/Collections/Burst/Recorder/MemoryProfiler DLLs in `Assets/Plugins/`: restored binaries may overlap packages or Editor-supplied assemblies in a fresh project. Resolve assembly identity and version before copying.
- `com.rlabrecque.steamworks.net.dll`, `GalaxyCSharp.dll`, `XblPCSandbox.dll`: platform integration branches. Keep a local gameplay slice independent of platform availability where its selected contracts allow that.
- `RecoveredPlayerAssemblies/`: retained Input System assemblies; their presence is not proof they are the currently compiled package implementation.

Inspect each DLL's `.meta` platform selection. Two files with the same assembly name are not necessarily both enabled, and a file under `Editor` is not a player runtime dependency. The full C# index covers loose source; DLL internals are explicitly outside semantic-source coverage here.

## 40.2 Three graphs must be followed together

1. **Code graph:** types, methods, interfaces, extension methods, lifecycle callbacks, reflection. `source-type-references.tsv` gives lexical candidates only.
2. **Serialized graph:** scripts, GameObjects, child hierarchy, ScriptableObjects, FSM templates, sprites, clips, materials, audio, colliders. `asset-references.tsv` and `script-bindings/` give concrete bindings.
3. **Name/event graph:** PlayMaker events and variables, UnityEvents/animation methods, tags/layers, scene gates, Addressable/Resources paths, PlayerData/quest field names. `source-literals.tsv` and selected serialized blocks expose these contracts.

An apparent “unused method” may be invoked by an animation event, UnityEvent, reflection, or FSM action. An apparent “unused asset” may be loaded by string. Do not remove a dependency solely because lexical references or GUID consumers are absent.

## 40.3 PlayMaker lookup, templates and execution

### Authoritative locations

| Need | Exact entry |
|---|---|
| Find every serialized machine | `data/fsm-index.tsv` → `(source, component_id, owner_id, fsm_name)` |
| Find actual use of an action | `data/fsm-actions.tsv` |
| Resolve its implementation | `data/fsm-action-implementations.tsv`, then source/DLL evidence |
| Detailed action parameters/transitions | Existing `Docs/CombatResearch/tools/fsm_decode.py` |
| Global variable asset | `Assets/Resources/PlayMakerGlobals.asset` |
| Shared machine definitions | `Assets/PlayMaker/Templates/` assets; follow the instance's `fsmTemplate` reference |
| Project wrappers/helpers | `Assets/Scripts/ProjectCode/FSM/00_Core/FSMUtility.cs` |
| Staggered activation | `Assets/Scripts/ProjectCode/FSM/00_Core/FSMActivator.cs` |
| Project/event bus | `Assets/Scripts/ProjectCode/FSM/00_Core/EventRegister.cs`, `Assets/Scripts/Assembly-CSharp/EventBase.cs` |

There are several source locations for action classes: `Assets/PlayMaker/Actions/`, `Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/`, `Assets/Scripts/MixedIntegrations/PlayMakerActions/`, `Assets/Scripts/ProjectCode/FSM/`, `Assets/Scripts/Assembly-CSharp/`, and its `HutongGames/PlayMaker/Actions/` subtree. Query by **full serialized type**, including nested `+` type names, then verify namespace/class and any compilation guards. Short-name candidates are explicitly lower-confidence.

### Instance → template is essential

A machine with one placeholder state and zero inline actions may delegate to a template. For example, `Assets/Prefabs/Heroes/Hero_Hornet.prefab` has a `Sprint` component whose actual template is `Assets/PlayMaker/Templates/hornet_sprint.asset`; its template contains 156 serialized states in this snapshot. Other player abilities use the same pattern. Read the component's `fsmTemplate`, variable overrides and bindings, then the template's full machine. A nested template action can introduce another level of indirection.

The global FSM index includes inline and template definitions as distinct rows; it does not flatten templates into every instance. The same template can behave differently under different bound variables. Avoid counting a template row as an additional in-world actor.

### FSMUtility behavior, read from source

- `LocateFSM`/`LocateMyFSM` scan components on the given GameObject for **exact** `FsmName` equality. This is not a hierarchy-wide search.
- `SendEventToGameObject` sends to each FSM on that GameObject; `isRecursive=true` explicitly descends child transforms.
- `SendEventUpwards` visits the object and each parent. Moving an object under a new parent can change event delivery.
- `GetSafe(FsmOwnerDefault, FsmStateAction)` selects the action owner or configured GameObject; the same action class can therefore affect a different object than the FSM owner.
- `FindFSMWithPersistentBool/Int` look for variables named `Activated` / `Value`.
- `SendEventToGlobalGameObject` resolves a named global FSM GameObject variable, then sends to its FSMs.
- The abstract action bases distinguish one-shot `OnEnter`+`Finish` behavior from `OnUpdate`/`EveryFrame`. Read the concrete override and inherited lifecycle together.

### EventRegister behavior, read from source

`Awake → UpdateEventHash → SubscribeEvent`; `OnDestroy → UnsubscribeEvent`. Registrations are keyed by the runtime string hash. `SendEvent` dispatches to registered listeners, optionally excluding one GameObject. `ReceiveEvent` can substitute an alias, enable a disabled target FSM, call `SendEventRecursive`, set a configured FSM bool, and raise the C# `ReceivedEvent` callback. If there is no configured `targetFsm`, it visits FSM components on the same object.

`OnDisable` does not unsubscribe, and `SendEvent` does not check `isActiveAndEnabled`: an already initialized disabled/pooled listener may still receive C# dispatch. If `ReceiveEvent` temporarily enables a target FSM and `SendEventRecursive` reports no delivery, it restores that FSM to disabled. Replacing this with an OnEnable/OnDisable subscription changes the contract.

Consequences: preserve the original event strings, listener lifecycle, alias/target/bool configuration, and delivery scope. Do not persist `string.GetHashCode()` as a cross-process stable event ID. A copied listener is not connected merely because the publisher calls a similarly named event elsewhere.

`FSMActivator` caches its components in `Awake`. `ActivateStaggered` enables FSMs one per frame and starts sprite animation afterward. `Deactivate` disables machines but does not reset the `activated` guard. Document the intended lifecycle instead of assuming every method with “Activate”/“Deactivate” is a symmetric reset pair.

### Decoder boundaries

The decoder omits component-root `m_Enabled`/`fsmTemplate` and does not expand templates; use the component and `fsm-template-links.tsv`. It currently fails on null action-name slots even if disabled, as recorded in [90](90_COVERAGE_AND_LIMITS.md).

The existing decoder interprets action parameter tables and packed values, preserving unsupported values and raw data. Its success establishes serialization readability, not runtime behavior. Inspect `enabled`, sequence mode, event targets, object references, variable binding, nested templates, reflection calls and callbacks. Whole-scene output can be enormous; select a machine before passing it to an agent.

Old combat `known-gaps.json` records three **scene** locations with enabled missing actions. The whole-project scan also sees missing-action entries in the player and Pinstress prefabs and empty action-name slots. See [90](90_COVERAGE_AND_LIMITS.md) and the recovery audit; do not describe the old three-entry report as a complete project-wide gap count.

## 40.4 Update order and time contracts

`Assets/Scripts/Assembly-CSharp/CustomPlayerLoop.cs` is a small but critical dependency:

1. `SetupCustomPlayerLoop`, marked `BeforeSceneLoad`, obtains Unity's current loop.
2. It appends one subsystem to the existing `FixedUpdate` subsystem list.
3. That callback invokes registered active `ILateFixedUpdate` objects in `_lateFixedUpdateList`, then `_superLateFixedUpdateList`.
4. It increments `FixedUpdateCycle` after both passes.

It is not equivalent to simply putting both components in arbitrary MonoBehaviour `FixedUpdate` methods. The combat chapter traces `DamageEnemies` and `HeroBox` through the two queues. When adapting this architecture, preserve the intended order relative to physics contact callbacks and the two damage passes; test multiple simultaneous contacts and object disable/recycle during damage.

`data/script-execution-order.tsv` records `.meta` importer order and `DefaultExecutionOrder` attributes. In this snapshot `GameManager.cs.meta` has order `201`, `HeroController.cs.meta` order `208`. Treat the complete relevant order, event subscription timing, `Awake`/`OnEnable`/`Start`, coroutines, fixed versus rendered frames, and scaled versus unscaled clocks as part of the feature.

Physics settings are also behavior: `ProjectSettings/Physics2DSettings.asset` stores gravity `(0,-60)`. Do not copy its layer matrix as a trusted numeric mapping: its recovered serialized string has non-hex characters. `TimeManager.asset` stores the fixed timestep in rational form (`2822399 / 141120000`, approximately 0.02 seconds). Verify the target Editor's actual interpreted settings before movement/combat comparisons.

## 40.5 Global object pooling and reuse lifecycle

Do not confuse these two implementations:

| Implementation | Role |
|---|---|
| `Assets/Scripts/Assembly-CSharp/ObjectPool.cs` (`global::ObjectPool`) | MonoBehaviour singleton managing pooled/spawned GameObjects, startup pools, scene ownership, active recyclers |
| `Assets/Scripts/ProjectCode/TeamCherry/ObjectPool/ObjectPool.cs` (`TeamCherry.ObjectPool.ObjectPool<T>`) | Generic stack pool with factory/get/release/destroy delegates and `IPoolable<T>` constraints |

The frequent `.Spawn()` / `.Recycle()` extension calls resolve through `Assets/Scripts/ProjectCode/Game/12_Utilities/ObjectPoolExtensions.cs` to the **global** pool.

### Global path

`GameManager` must ensure the global pool exists before callers use it. `ObjectPool.instance` searches for an existing instance and handles primary persistence; it does not manufacture an arbitrary configured pool for a blank project.

`CreatePool → CreatePooledObjects` instantiates enough objects, distinguishes `ActiveRecycler`, then calls tk2d sprite `ForceBuild` and optionally `IInitialisable.DoFullInitForcePool`. This can execute initialization before a normal live spawn.

`Spawn(prefab, parent, position, rotation, stealActiveSpawned)`:

- Reuses a valid pooled object where available; otherwise instantiates and records it.
- Applies `localPosition` and `localRotation` after parenting. Verify coordinate space when supplying a non-null parent.
- Currency objects can enable stealing an already spawned object; the selection depends on distance from `HeroController.instance`.
- An `ActiveRecycler` receives `A SPAWN`; an ordinary pooled object is enabled.
- Newly created extras are registered with `PersonalObjectPool` accounting.

`Recycle` first calls an optional `RecycleResetHandler.OnPreRecycle`. Known spawned objects return to their pool; untracked objects may be destroyed. `RecycleProcess` resets dynamic hierarchy, reparents immediately or queues reparenting until `LateUpdate`, then either disables the object or moves an `ActiveRecycler` to `(-20,-20)` and sends `A RECYCLE`. `ActiveRecycler` itself is just a marker component (`Assets/Scripts/ProjectCode/Game/12_Utilities/ActiveRecycler.cs`). Its behavior is carried by the pool and recipient FSMs.

Preserve listeners, collider state, animation restart, transient attack-hit lists, particle/audio reset, and recycled child state. Test first spawn **and** subsequent spawns. Replacing every `.Recycle()` with `Destroy()` or every `.Spawn()` with `Instantiate()` changes lifecycle and may bypass the reset contract.

### Scene-specific ownership

- `Assets/Scripts/ProjectCode/Game/12_Utilities/PersonalObjectPool.cs`: `OnAwake`, `OnStart`, startup creation, shared/extra counts, scene unloading and transfer of pool ownership. `EnsurePooledInScene` explicitly calls `GameManager.instance.EnsureGlobalPool`.
- `Assets/Scripts/ProjectCode/Game/12_Utilities/StartupPool.cs`: global serializable configuration struct; distinct from the nested `ObjectPool.StartupPool` class.
- `Assets/Scripts/Assembly-CSharp/SceneObjectPool.cs`: ScriptableObject containing prefab pool definitions and held references. `SpawnPool(owner)` installs a `PersonalObjectPool` on the owner.
- `Assets/Scripts/Assembly-CSharp/IInitialisable.cs`: explicit `OnAwake`/`OnStart` interface; helper initialization walks inactive children and can force pool creation.

The typed pool's `Clear` destroys inactive stack contents when an `onDestroy` delegate exists; do not infer cleanup of all active borrowed instances from that method alone. Implement ownership and release discipline in the target feature rather than relying on the shared name “ObjectPool.”

## 40.6 Asynchronous asset loading

Read together:

- `Assets/Scripts/Assembly-CSharp/AddressableReferenceGameObject.cs`: generic wrapper caching load/instantiate handles and component lookup; `InstantiateAsyncCustom` adds load-order tracking and callback behavior; disposal releases handles.
- `Assets/Scripts/Assembly-CSharp/AddressableInstance.cs` and `AddressableInstanceExtensions.cs`: an instance helper releases its Addressables instance handle on destruction.
- `Assets/Scripts/Assembly-CSharp/AsyncLoadOrderingManager.cs`: tracks outstanding load IDs, supports waiting on preceding operations, and queues actions until the tracked list is empty; resets its static state on subsystem registration.
- `Assets/Scripts/Assembly-CSharp/AddressablesLoadScene.cs`: selects an AssetReference when its GUID is present, otherwise a string address, in `Start`.
- `Assets/AddressableAssetsData/AssetGroups/`: explicit group address → asset mappings, indexed in `data/addressables.tsv`.

Loading an asset, instantiating a manager, setting its singleton, and waiting for its initialization are separate steps. Follow the exact call site. Preserve completion/failure/release ownership and main-thread assumptions. Do not assume a cached handle wrapper automatically retries a failed operation or that its callbacks are synchronous.

## 40.7 Review ledger for this chapter

Semantically read in this pass: `CustomPlayerLoop`; `EventBase`, `EventRegister`, `FSMUtility`, `FSMActivator`, `FSMActionReplacements`; global and typed `ObjectPool`, `ObjectPoolExtensions`, `PersonalObjectPool`, `StartupPool`, `SceneObjectPool`, `IInitialisable`, `ActiveRecycler`; `AddressableReferenceGameObject`, `AddressableInstance`, `AddressableInstanceExtensions`, `AddressablesLoadScene`, `AsyncLoadOrderingManager`; the tk2d asmdef, package manifest, startup/build/input/graphics/physics/time/tag/audio configuration and selected plug-in/script metadata.

All remaining loose source files have full-content declaration/index extraction and are reachable by the appendices, but that extraction is not a claim that every runtime branch has been semantically explained here. DLL interiors and runtime scheduling under the target project remain separate verification work.
