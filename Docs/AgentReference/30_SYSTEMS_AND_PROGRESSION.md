# Systems, lifecycle, persistence, progression, tools, quests, and UI

This is a navigation and implementation reference for **the current recovered Unity project**. It is intended for an agent building a separate Unity project incrementally. It does not assert that every recovered implementation equals the shipped game. All observations below are static source/serialized-data observations; no gameplay, save round-trip, store service, or platform certification test was run for this chapter.

Paths are project-relative. Use the symbol together with the path; line numbers are supplementary and can move. For serialized objects, use **file path + GameObject fileID + component fileID + FSM name/state**. A fileID alone is not globally unique. The shared `data/` indexes in this reference directory supply the exhaustive file/symbol/reference census; this chapter supplies semantic reading routes and migration boundaries.

## 1. Start here for a requested feature

| Request | First implementation to read | Data / serialized entry | Follow-up |
|---|---|---|---|
| Start the game / title menu | `Assets/Scripts/Assembly-CSharp/AddressablesLoadScene.cs::Start`; `Assets/Scripts/ProjectCode/Game/00_Bootstrap/StartManager.cs::Start` | `Assets/Scenes/Pre_Menu_Loader.unity`; `Assets/Scenes/Pre_Menu_Intro.unity`; `Assets/Scenes/Menu_Title.unity` | Section 2 |
| New game / continue / quit | `Assets/Scripts/ProjectCode/Game/01_Core/GameManager.cs::StartNewGame`, `RunStartNewGame`, `RunContinueGame`; `Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/QuitToMenu.cs::Start` | `Assets/Prefabs/Managers/_GameManager.prefab`; `Assets/Scenes/Opening_Sequence.unity` | Sections 2–3 |
| Save a global unlock | `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/PlayerData.cs`; `Assets/Scripts/ProjectCode/Game/01_Core/GameManager.cs::SaveGame` | Public player fields / named save records | Section 3 |
| Keep a door open / item collected across room reload | `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/PersistentItem.cs::SaveStateNoCondition`, `EnsureSetup`; `SceneData.cs::PersistentItemDataCollection` in that directory | Scene name + persistent ID; bool/int component binding | Section 3.4 |
| Grant movement ability | `Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/SetPlayerDataVariable.cs`; `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/PlayerData.cs` | Shrine `Inspection` or NPC dialogue FSM; verified examples in section 4 | Player chapter for execution/gating |
| Add tools, crests, equipment slots, replenishment | `Assets/Scripts/Assembly-CSharp/ToolItem.cs::Unlock`; `ToolCrest.cs::Unlock`; `ToolItemManager.cs::SetEquippedTools`, `TryReplenishTools` in the same directory | `Assets/Data Assets/Tools/Tool Lists/Master Tool List.asset`; `Assets/Data Assets/Tools/Crest Lists/Master Crest List.asset` | Section 5 |
| Pickup / money / shards / shop | `Assets/Scripts/Assembly-CSharp/CollectableItemPickup.cs::DoPickupAction`; `CollectableItem.cs::Collect`; `CurrencyManager.cs::ChangeCurrency`; `ShopItem.cs::SetPurchased` in that directory | `Assets/Data Assets/Collectables/Collectables Master List.asset`; shop-specific assets | Section 5.4 |
| Add a wish / quest / reward | `Assets/Scripts/Assembly-CSharp/FullQuestBase.cs::BeginQuest`, `TryEndQuest`; `QuestManager.cs` in the same directory | `Assets/Data Assets/Quest System/Master Quest List.asset` and individual quest assets | Section 6 |
| NPC talk / inspect / interaction prompt | `Assets/Scripts/Assembly-CSharp/InteractableBase.cs`; `InteractManager.cs`; `NPCControlBase.cs`; `BasicNPC.cs` in that directory | Trigger layers, prompt marker, dialogue keys, persistent state, FSM event target | Section 7 |
| Inventory, map, journal, localization | `Assets/Scripts/Assembly-CSharp/InventoryPaneList.cs`; `Assets/Scripts/ProjectCode/Game/07_UI_Localization/GameMap.cs`; `Assets/Scripts/Assembly-CSharp/EnemyJournalManager.cs` | HUD/camera prefab, named panes, journal list, language sheets | Section 8 |
| Input, settings, achievements, vibration | `Assets/Scripts/ProjectCode/Game/02_Player/InputSystem/InputManager.cs`; `Assets/Scripts/ProjectCode/Game/09_Platform_Input_Achievements/Platform.cs`; `AchievementHandler.cs` in the platform directory | `Assets/InputSystem_Actions.inputactions`; `Assets/Data Assets/GameConfig.asset`; achievements list | Section 9 |
| Breakable / platform / bench | `Assets/Scripts/ProjectCode/Game/04_World_Environment/Breakable.cs`; `DropPlatform.cs`; `RestBench.cs` in that directory | Per-instance components; `Assets/PlayMaker/Templates/bench_control.asset` | Section 10 |

**Do not use folder names as an architecture proof.** Many important Silksong systems are in `Assets/Scripts/Assembly-CSharp`, while `Assets/Scripts/ProjectCode/Game/11_Actors_Quests` includes classes such as Grimm/Hollow Knight-era actors. Search symbols and serialized script GUID bindings, then follow the active instance.

## 2. Bootstrap and global lifetime

### 2.1 Verified startup route

```text
Runtime initialization (before first scene; independent hooks)
  CoreLoop.Init -> persistent main-thread callback dispatcher
  Platform.Init -> DesktopPlatform -> BecomeCurrent
  InputSystem.InputManager.InitializeBeforeSceneLoad -> native Input System callbacks

Pre_Menu_Loader / Loader
  AddressablesLoadScene.Start -> address "Scenes/Pre_Menu_Intro"
Pre_Menu_Intro / StartManager
  optional language selector
  QuitToMenu.StartLoadCoreManagers -> preload _GameManager / _UIManager / _GameCameras
  wait for shared data / loading order / logo animation
  load "Scenes/Menu_Title" without activation, then activate
Menu_Title
  serialized _GameManager / _UIManager / _GameCameras objects initialize
  user chooses profile and New Game
```

The three `RuntimeInitializeOnLoadMethod` hooks above do not establish their mutual order. Do not introduce a dependency on one hook having already run unless the actual call path proves it.

Exact anchors:

- `Assets/Scenes/Pre_Menu_Loader.unity`: `Loader` GameObject **2**, `AddressablesLoadScene` component **10**, script GUID `f338c72cfde2be078064211dde63ba13`; `loadScene.m_AssetGUID` empty, `address: Scenes/Pre_Menu_Intro`. `Assets/Scripts/Assembly-CSharp/AddressablesLoadScene.cs::Start` chooses the AssetReference when present, otherwise the address string.
- `Assets/Scenes/Pre_Menu_Intro.unity`: `StartManager` GameObject **11**, component **55**. `Assets/Scripts/ProjectCode/Game/00_Bootstrap/StartManager.cs::Start` waits for `Platform.Current.IsSharedDataMounted`, can refresh language-dependent fonts/layout, waits for the Animator state named `LoadingIcon`, and activates the loaded menu scene. Copying only this script without its Animator and language-selector reference is insufficient.
- `Assets/Scenes/Menu_Title.unity`: `_GameManager` GameObject **652**, `_UIManager` **237**, `_GameCameras` **532**. These are actual serialized scene objects. `QuitToMenu.StartLoadCoreManagers` only **loads assets**; it does not instantiate these managers.
- `Assets/Scripts/ProjectCode/Game/00_Bootstrap/CoreLoop.cs::Init`, `InvokeNext`, `InvokeSafe`, `InvokeOnGameThread`, `FireInvokeNext`, `Update`: `InvokeSafe` routes through a locked producer queue, `Update` transfers work to the main thread, and `FireInvokeNext` swaps callback buffers. `InvokeNext` itself is not the cross-thread-safe entry. This is the current locally documented implementation.
- `Assets/Scripts/ProjectCode/Game/09_Platform_Input_Achievements/Platform.cs::Init`, `CreatePlatform`: this checkout creates `DesktopPlatform` unconditionally. Other platform source files are not evidence that this checkout selects those platforms at runtime.

### 2.2 What GameManager really requires

Read `Assets/Scripts/ProjectCode/Game/01_Core/GameManager.cs` in this order: `Awake` (**459**) → `SetupGameRefs` (**3400**) → `SetupSceneRefs` → `BeginScene` / `OnNextLevelReady` → `LevelActivated` → `OnDestroy`.

`GameManager.instance` searches for an existing instance and logs when absent; it does not create a complete manager. `Awake` preserves the manager, sets up references, and writes the PlayMaker global GameObject variable named `GameManager`. `SetupGameRefs` requires much more than player data:

- `GameCameras.instance`, its camera controller and HUD camera;
- `HUDCamera.GameplayChild`, its FSM named **Screen Fader**, and a child named **Inventory** with a PlayMaker FSM;
- `InputHandler` and `AchievementHandler` on the manager object;
- `Platform.Current`, `GameSettings`, shared settings, and camera/audio events.

`SetupSceneRefs` locates a tagged scene manager, attaches the hero to input, ensures global pools in gameplay scenes, refreshes the tilemap when requested, and gathers other scene-specific data. The scene/rendering chapter covers those dependencies. `Assets/Scripts/Assembly-CSharp/ManagerSingleton.cs` has a narrower generic pattern: find an existing component, destroy duplicate components, clear the static reference on destruction. It does not itself guarantee persistence or create objects.

Concrete manager prefab: `Assets/Prefabs/Managers/_GameManager.prefab`, GameObject **1709254077376921**:

| Component fileID | Script / binding verified |
|---|---|
| `114634108722742392` | `GameManager`; `gameConfig` → `Assets/Data Assets/GameConfig.asset`; paused/unpaused/silent/music/atmos snapshots and loading spinner prefabs are serialized references |
| `114946936116752871` | `AchievementHandler`; `achievementsList` → `Assets/Data Assets/Achievements List.asset` |
| `114711914853252429` | `ToolItemManager`; `toolItems` → master tool list; `crestList` → master crest list; `cursedCrest` → `Assets/Data Assets/Tools/Crest Items/Cursed.asset` |
| `114587397909062814` | `QuestManager`; `masterList` → master quest list; accepted/finished sequence prefabs → `Assets/Prefabs/UI/Wish Promised Prompt.prefab` / `Assets/Prefabs/UI/Wish Granted Prompt New.prefab` |
| `114371939378208658` | `CollectableItemManager`; `masterList` → collectables master list; `invalidTemplate` → `Assets/Data Assets/Collectables/Invalid Item Template.asset` |
| `114672306508523268` | `CurrencyManager` |

The recovered scene may contain its own serialized manager state. Use its actual component data when reproducing that scene; the prefab table is a reusable dependency entry, not proof that every scene instance equals the prefab.

### 2.3 New game, opening, continue, quit

New-game call chain:

1. `Assets/Scripts/ProjectCode/Game/00_Bootstrap/StartGameEventTrigger.cs::OnSubmit` prevents duplicate submit and invokes `UIManager.StartNewGame(permaDeath, bossRush)`.
2. `Assets/Scripts/ProjectCode/Game/07_UI_Localization/UIManager.cs::StartNewGame` (**949**) handles brightness/overscan first-run flow, stops UI input and requests save-slot space, then invokes `GameManager.StartNewGame`.
3. `Assets/Scripts/ProjectCode/Game/01_Core/GameManager.cs::StartNewGame` (**5124**) creates a new `PlayerData` singleton, sets permadeath and calls `Platform.PrepareForNewGame`. The ordinary path is `RunStartNewGame` → fade/snapshots → `LoadGlobalPoolPrefab` → pool initialization → `BeginSceneTransition` to **Opening_Sequence**.
4. `Assets/Scripts/ProjectCode/Game/08_Audio_Visual_Cinematics/OpeningSequence.cs::StartAsync` / `StartSync` runs a `ChainSequence`, loads the hero, then selects **Tut_01** unless `loadSave` is true. The async branch preloads the world before activation and gates skipping on both sequence permissions and load readiness.
5. `Assets/Scenes/Opening_Sequence.unity`: `Sequence` GameObject **17**, `OpeningSequence` component **264**, `loadSave: 0`, `skipChargeDuration: 6`. The six-second value is this serialized opening instance, not a universal skip duration.

`GameManager.LoadGlobalPoolPrefab` (**5243**) uses address **GlobalPool**; `LoadHeroPrefab` (**5262**) uses **Hero_Hornet**. Preserve those address-to-asset mappings if adopting the original loader. Do not substitute an obsolete `Tutorial_01` constant for the observed opening destination.

Continue is a different route: `GameManager.LoadGameFromUI` → `LoadGame` → `SetLoadedGameData` → `ContinueGame` / `RunContinueGame` (**5169**). It runs save upgrades and fixups, handles queued Act 3 intro separately, creates pools and hero, and either goes to **Opening_Sequence_Act3** or calls `ReadyForRespawn`. The saved respawn scene/marker and temporary respawn rules matter; loading JSON alone does not resume play.

`Assets/Scripts/ProjectCode/Game/05_Scenes_Travel/QuitToMenu.cs::Start` is the teardown reference: destroys hero/UI/cameras/managers, releases pool and hero handles, resets selected static systems, releases preloads, checks PlayMaker state, then reloads the menu. If a small prototype can start once but fails on the second run, inspect this cleanup contract before adding more singletons.

### 2.4 Global configuration is also an asset graph

`Assets/Scripts/ProjectCode/GlobalSettings/GlobalSettingsBase.cs::Get` loads **GlobalSettings/{fileName}.asset** via Addressables, coordinates load ordering, and waits for completion. When no asset is obtained it creates a default `ScriptableObject`; this can hide a missing asset behind null/default members. `StartPreloadAddressable` uses `Assets/Scripts/ProjectCode/GlobalSettings/GlobalSettings.cs::StartLoad` and its end-of-frame loader.

Settings entry points are `Assets/Scripts/ProjectCode/GlobalSettings/Gameplay.cs`, `UI.cs`, `Audio.cs`, `Camera.cs`, `Effects.cs`, `Corpse.cs`, and `Demo.cs` in that directory. Concrete assets live under `Assets/Data Assets/GlobalSettings/`, including **Global Gameplay Settings.asset** and **Global UI Settings.asset**. Import one referenced setting category with its dependencies, or replace the category with an explicit local configuration interface.

For a blank project, a reasonable first slice is one bootstrap object, one player-data object, one room loader, one input adapter, and a camera. Copying `GameManager` wholesale brings HUD, audio, PlayMaker, achievements, pooling, Addressables and progression dependencies immediately. This is an implementation recommendation, not a claim about the original architecture.

## 3. Save/load and persistence

### 3.1 Three distinct kinds of state

| Kind | Owner / implementation | Identity and lifetime |
|---|---|---|
| Game-slot state | `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/SaveGameData.cs` contains `PlayerData` + `SceneData` | One selected game profile |
| Player progression | `PlayerData.cs` in the same directory; `Assets/Scripts/Assembly-CSharp/SerializableNamedList.cs` | Typed public fields plus named tool/crest/quest/collectable/journal records |
| Per-scene persistence | `SceneData.cs`, `PersistentItem.cs`, `PersistentBoolItem.cs`, `PersistentIntItem.cs` in the data directory | **SceneName + ID**, with separate semi-persistent rules |
| User/device settings and shared records | `GameSettings.cs`, `PlayerPrefsSharedData.cs`; `Assets/Scripts/ProjectCode/Game/09_Platform_Input_Achievements/DesktopPlatform.cs::Awake` | Local shared data and roaming shared data; not identical to game-slot JSON |

`PlayerData.CreateNewSingleton` (**3315**) deserializes `{}` through the configured serializer, initializes containers, then performs existing-data setup. `SetupNewPlayerData` (**3875**) initializes visited/mapped scene sets, tools/crests, quests, journal, collectables, relics and related containers, and marks **Hunter** crest unlocked. Do not construct just an empty dictionary and assume all default field values and upgrade hooks have been reproduced.

`SerializableNamedList` serializes a list of `Name + Data` entries and rebuilds a runtime dictionary. These are **names**, not GUIDs. For example `FullQuestBase.Completion` uses the quest asset's `name`; tool and crest data also uses names. Renaming an asset in a reuse project is a save-data migration unless its persistent key is decoupled first. The current deserializer groups duplicate names and selects the first entry; duplicate records should not be deliberately relied on.

### 3.2 Save request → durable file

Read `Assets/Scripts/ProjectCode/Game/01_Core/GameManager.cs` at `SaveGame(Action<bool>)` (**4045**), `QueueSaveGame`, `DoQueuedSaveGame`, private `SaveGame(int,...)` (**4233**) and `PreparePlayerDataForSave` (**4452**).

```text
QueueSaveGame -> mark pending only
DoQueuedSaveGame -> queuedSaveFrameDelay = 3
GameManager.Update -> after three Update calls dispatch pending save
  SaveGame / SaveGameWithAutoSave
    FixUpSaveState
    SaveLevelState -> SavePersistentObjects event
    PreparePlayerDataForSave
      achievement shared-record flush
      accumulate playTime, version/revision/profile, completion percentage
      PlayerData.OnBeforeSave
    SaveGameData(playerData, sceneData)
    SaveDataUtility.SerializeSaveData on async queue
    GetBytesForSaveJson -> SaveFileCodec
    Platform.Current.WriteSaveSlot
    backup and optional restore point
```

`QueueAutoSave` similarly queues a named restore-point request. `QueueSaveGame` alone is not a durability guarantee. `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/SaveGameV2.cs::OnEnter` invokes a save/auto-save and immediately `Finish()`es the FSM action; FSM completion does not mean the asynchronous disk write succeeded. A new implementation that requires a durable transaction must explicitly await the callback.

Important implementation boundaries:

- `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/SaveDataUtility.cs::CreateJsonObjects` configures Newtonsoft's Unity converters, default-value population, ignored reference loops, nulls and missing members. Its two `AddTaskToAsyncQueue` overloads have different mechanisms (task queue vs `WorkerThread`). Read the chosen overload's completion/thread contract before adding Unity-object access to it.
- `SaveGameData(PlayerData, SceneData)` stores references; it does not deep-copy a snapshot. The current asynchronous serialization therefore is not evidence of an immutable save snapshot. A new architecture should specify snapshot ownership explicitly.
- `PlayerData.OnBeforeSave` (**3972**) can change temporary crest state and send equipment-change events. `GameManager.FixUpSaveState` has additional game-specific repairs. Saving is not a pure JSON dump in this code.
- `GameManager.PreparePlayerDataForSave` writes version **1.0.30000** and revision break **28104**. These are current source values, not external release verification.
- `Assets/Data Assets/GameConfig.asset` serializes `disableSaveGame: 0`, `useSaveEncryption: 1`, `enableDemoMode: 0`. Runtime guards (`CheatManager`, demo mode, platform engagement) can still alter behavior.

`Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/SaveFileCodec.cs` is the current versioned **TCSAVE** container implementation: magic, version, flags, payload length, SHA-256 corruption checksum, strict UTF-8 and optional encryption. `DecodeJson` accepts the container or a constrained legacy serialized-string format. The checksum is not an authenticity proof. This implementation contains clear reconstruction/maintenance choices and must not be labeled the original retail format.

`Assets/Scripts/ProjectCode/Game/09_Platform_Input_Achievements/DesktopPlatform.cs::WriteSaveSlot` (**353**) chooses an online save provider only when it handles saves; otherwise writes a `.new` file, flushes, replaces/moves into the primary path, and makes a backup. `Awake` roots desktop saves at `Application.persistentDataPath` plus the online user ID or **default**. A new game should use its own company/product identity and storage path, not silently share this project's saves.

### 3.3 Load request → playable world

`GameManager.LoadGame` (**4536**) validates the slot, calls `Platform.ReadSaveSlot`, decodes bytes and deserializes. `SetLoadedGameData` replaces **both** `PlayerData.instance` / manager player data and `SceneData.instance` / manager scene data; resets nonserialized fields, sets slot ID, clears `silk` and `silkParts`, performs existing-data setup, refreshes input's data reference and upgrades quest chains.

Then `RunContinueGame` applies `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/SaveDataUpgradeHandler.cs::UpgradeSaveData` and `FixUpSaveState` before respawn. The upgrade file currently contains a specific Ward relic/one-way-wall recovery rule and an empty scene-split list. It is not a general-purpose migration engine covering arbitrary future changes.

Further exact routes: `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/SaveRestoreHandler.cs`, `DesktopSaveRestoreHandler.cs`, `RestorePointData.cs`, `RestorePointFileWrapper.cs`, `SaveStats.cs`; UI slot and recovery callers in `Assets/Scripts/ProjectCode/UnityNamespaceExtensions/UI/SaveSlotButton.cs`, `RestoreSaveButton.cs`, `ClearSaveButton.cs`. These were indexed for navigation; their complete UI/recovery branches were not semantically audited in this chapter.

### 3.4 Scene persistence and reset

`PersistentItem<T>.Awake` subscribes to `GameManager.SavePersistentObjects`; `Start` resolves identity and reads saved values; callbacks or a matching FSM provide the live value; destruction unsubscribes. `EnsureSetup` uses the serialized ID and scene when provided; otherwise defaults to object name and `GameManager.GetBaseSceneName(gameObject.scene.name)`.

`PersistentBoolItem` looks for a persistent FSM, reading/writing its boolean **Activated**. `PersistentIntItem` is the integer counterpart. `SaveCondition` can suppress writing, `dontSave` makes the component read-only, and `SetValueOverride` takes ownership of the saved value. A reused object must keep a stable, unique ID within its logical scene. Duplicating a named object with an empty ID can produce a persistence collision.

`SceneData.PersistentItemDataCollection` keeps runtime dictionaries but excludes `IsSemiPersistent` entries when serializing its disk list. `GameManager.ResetSemiPersistentItems` first invokes component reset callbacks, then removes semi-persistent entries from scene data. Room reload, bench/rest reset and disk reload are therefore separate behaviors. Do not replace all three with “clear the room.”

Minimum independent persistence slice: typed player progress, a scene-keyed object-state store, a notification to collect live state, serializer, file writer and a load/respawn entry. Add version upgrades and restore points after a single-room save/load test works.

Validation to run in the new project: collect once → save → restart → item absent; change room and return; reset semi-persistent objects without erasing permanent doors; duplicate object IDs are detected; failed/truncated writes fail cleanly; save callback occurs after the required write; load refreshes all consumers of replaced player data. These are proposed tests, not executed results.

## 4. Ability unlocks and progression conditions

Abilities are not all granted by a single C# `UnlockAbility` method. Their data writes occur in scene FSMs and general item/interact sequences; movement execution reads player flags and crest/configuration conditions elsewhere.

### 4.1 Verified shrine example: wall jump

`Assets/Scenes/Hornet/Shellwood_10.unity`, **Shrine Weaver Ability**, GameObject **2347**, FSM component **10756**, FSM **Inspection** (component begins at source line **725211**):

1. FSM enum variable **Ability** has `enumName: GlobalEnums.WeaverSpireAbility`, `intValue: 3`.
2. **Check Type** compares the enum; `3` sends **WALLJUMP** → **Set Walljump**.
3. **Set Walljump** writes FSM string **PlayerData Bool = hasWalljump**, sets powerup metadata, and **Auto Save Enum = 12**; then **Collected Check** reads that chosen player flag to avoid re-granting it.
4. The sequence drives hero animation, camera locks, sounds, particles and UI. **End** writes `SetPlayerDataBool($PlayerData Bool, true)`, sets `hasSilkSpecial`, reports tool-unlock progress, calls `HeroController.SetBenchRespawn` with this instance's marker (reference fileID **10917**), and regains control.
5. **Set Finished** clears temporary invincibility, adds silk, sends **SHRINE SEQUENCE END**, then calls `SaveGameV2(createAutoSave=true, nameEnum=$Auto Save Enum)`.

The same serialized FSM contains sprint/harpoon/super-jump branches; their mere presence does **not** mean this room grants all those abilities. Resolve the instance variable first. Inspect `Assets/Scripts/ProjectCode/GlobalEnums/WeaverSpireAbility.cs` and `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/AutoSaveName.cs` to interpret enum integers for the current version.

The shrine's `Init` state finds named children such as **CamLock Near**, **CamLock LookUp**, **Burst Deactivate**, **Bind Thread**, **Pt SilkDust**, and **Unravel Point**. A transplant that renames/reparents those objects without updating lookups can break the sequence even when GUID references resolve.

### 4.2 Verified NPC example: umbrella

`Assets/Scenes/Hornet/Bone_East_Umbrella.unity`, **Seamstress**, GameObject **174**, FSM **Dialogue**, component **604** (source line **49722**), state **Msg** invokes `SetPlayerDataVariable` with `VariableName = hasBrolly` and a literal boolean true. It also creates the item message and sets its **Msg Control / Item** string to **Brolly**. This is an NPC delivery route, not the shrine route.

`Assets/Data Assets/Quest System/Quests/Brolly Get.asset` supplies a target of **25** `Assets/Data Assets/Collectables/Collectable Items/Common Spine.asset`, consumes targets, and has a null `rewardItem`. The ability grant is in the NPC FSM above; inferring “null reward means no reward” would lose the actual behavior. This chapter verifies the grant and quest asset, not every dialogue prerequisite in that NPC's complete graph.

### 4.3 Conditions and minimum port

`Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/PlayerDataTest.cs` is a reusable condition format: tests within a group are **AND**, groups are **OR**, an empty `TestGroups` array passes. Tests support booleans, numbers, enums and strings. `Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/SetPlayerDataVariable.cs` uses `PlayerData.instance.SetVariable` with the actual FSM value type. Older `PlayerData.SetBool/GetBool` access public fields via optimizers/reflection; unknown names must not be silently translated into guessed abilities.

For a blank project, implement one typed ability flag plus one grant sequence that updates the flag, movement gate, prompt and save state together. Read the player chapter for `HeroController.CanDash`, `CanWallJump`, `CanDoubleJump`, `CanFloat`, `HasHarpoonDash` and crest-specific limits before equating “flag true” with “action usable in every state.” Add the original multi-stage presentation only after grant/reload/duplicate-interaction behavior passes.

## 5. Tools, crests, inventory items and economy

### 5.1 Runtime assets and saved state are separate

The manager bindings in section 2 point to **65 direct entries** in `Assets/Data Assets/Tools/Tool Lists/Master Tool List.asset` and **11 direct entries** in `Assets/Data Assets/Tools/Crest Lists/Master Crest List.asset`. These are current serialized list counts, not a claim about distinct player-visible categories.

| Role | Exact implementation |
|---|---|
| Tool definition and unlock/reload behavior | `Assets/Scripts/Assembly-CSharp/ToolItem.cs`; concrete variants `ToolItemBasic.cs`, `ToolItemStates.cs`, `ToolItemStatesLiquid.cs` in the same directory |
| Tool save record | `Assets/Scripts/Assembly-CSharp/ToolItemsData.cs::Data`: `IsUnlocked`, `IsHidden`, seen/selected flags, `AmountLeft` |
| Crest definition / slot layout / upgrade chain | `Assets/Scripts/Assembly-CSharp/ToolCrest.cs`: `slots`, `previousVersion`, configuration and UI references |
| Crest save record | `Assets/Scripts/Assembly-CSharp/ToolCrestsData.cs::Data`, `SlotData`: crest unlock and list of slot unlock/equipped tool names |
| Floating slots | `Assets/Scripts/Assembly-CSharp/FloatingCrestSlotsData.cs`; `ToolItemManager.SetExtraEquippedTool` |
| Runtime equipment service | `Assets/Scripts/Assembly-CSharp/ToolItemManager.cs`: list lookup, equipment caches, events, bindings, replenishment |
| Player containers | `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/PlayerData.cs`: `ToolEquips`, `ExtraToolEquips`, `Tools`, `ToolLiquids`, `CurrentCrestID`, `PreviousCrestID` |

`ToolItem.Unlock` (**497**) differentiates first unlock from refill/unhide. First unlock sets the starting amount, may show a tutorial, queues/reports tool progress and can replace an old tool in equipment via `getReplaces`. Already-unlocked tools refill to storage capacity. `Unlock()` is therefore not an idempotent no-op when owned. `ToolItem.Get` delegates into this workflow through the common `SavedItem` API.

`ToolCrest.Unlock` (**224**) can recursively unlock `previousVersion`, copy its slot save data and switch the currently equipped previous crest. A base crest builds saved slots from serialized `IsLocked` flags. Keep upgrade links and slot order; a crest is not just a sprite plus a movement enum.

### 5.2 Equipment changes are a multi-step contract

Reading order: `ToolItemManager.SetEquippedTools` (**377**), `SetEquippedCrest` (**461**), `SendEquippedChangedEvent` (**513**), `RefreshEquippedState`, then the player chapter's crest configuration readers. This is not a direct call chain: the first two setters neither call each other nor emit the equipment event; callers such as `AutoEquip(ToolItem)` and `AutoEquip(ToolCrest)` explicitly flush the queued changes.

`SetEquippedTools` writes ordered slot names, marks queued equipment/attack changes, clears the tool cache and recalculates capacity. `SetEquippedCrest` updates current/previous crest IDs and removes tools that collide with extra-slot equipment. `SendEquippedChangedEvent` refreshes equipment state, refreshes hero silk, sends **EquipsChangedEvent**, invokes `OnEquippedStateChanged`, and sends **EquipsChangedPostEvent**. Editing the save list directly omits those notifications. The active attack/configuration bridge is `SendEquippedChangedEvent` → EventRegister event `TOOL EQUIPS CHANGED` → HC's registered `ResetAllCrestState` callback → current crest `HeroConfig` → `UpdateConfig`. This can change animation libraries and attack objects as well as stat values.

`GetBoundAttackTool` (**762 / 768**) resolves neutral/up/down attack-tool input against current crest slots, temporary tool override and the requested read source. `ToolEquippedReadSource.Active` and `.Hud` are distinct inputs; do not use a displayed tool as proof that its gameplay effect is currently active. `SetActiveState` / `SetIsInCutscene` and temporary overrides need explicit handling in a reuse project.

### 5.3 Replenishment is resource accounting

`ToolItemManager.TryReplenishTools` (**946**) snapshots currencies, chooses eligible equipped tools, computes per-use costs from each tool's `ReplenishUsage`, multiplier, resource and `GlobalSettings.Gameplay.ToolReplenishCost`, and asks `ToolItem.TryReplenishSingle`. It handles liquid reserve costs, quick-craft special cases, limits and silent bench presentation. When replenishment occurs it charges aggregate rounded costs and updates liquid stores. On the completed `doReplenish=true` path it also calls `ReportAllBoundAttackToolsUpdated` and `SendEquippedChangedEvent(force:true)`, even when the returned replenishment flag is false. An equipment-change event is therefore not proof that an amount was replenished.

`doReplenish=false` is an availability/probe route; it is not a full mutation. `ReplenishMethod.BenchSilent` controls presentation; `QuickCraft` has extra behavior even when no ordinary refill occurred. Read this method and the concrete tool subclass together before simplifying the cost model.

For a minimum tool slice, use one crest, one typed slot and one tool with no tutorial/popup dependencies. Then add saved quantities, equipment-change notifications, neutral binding and a refill source. Only after those work add directional bindings, crest upgrades, liquids, quick craft, replacement tools and temporary restrictions.

### 5.4 Collection, money, shops and rewards

Collection route:

```text
scene pickup / NPC / FSM SavedItemGetV2
  -> SavedItem.TryGet / Get
  -> concrete CollectableItem.Collect, ToolItem.Unlock, ToolCrest.Unlock, etc.
  -> named PlayerData record + inventory/version/event updates
  -> pickup component records whether this scene object was collected
  -> later save request gathers persistent object state
```

`Assets/Scripts/Assembly-CSharp/CollectableItemPickup.cs::DoPickupAction` can set `playerDataBool`, call the assigned `SavedItem.TryGet`, invoke pickup callbacks and drive presentation. Its persistence uses separate `activatedRead` / `activatedSave` and `PersistentBoolItem` handlers. A null `item` may be valid when `playerDataBool` is assigned; otherwise it logs an error. It is not safe to remove the pickup object's persistent identity just because an inventory amount exists.

`Assets/Scripts/Assembly-CSharp/CollectableItem.cs::Collect` (**269**) checks capacity, adds amount through `CollectableItemManager`, updates unseen flags, emits **ItemCollected**, records the story event, refreshes bound tool displays and item counters. `Take` removes amount and updates the counter. `GetCompletionAmount` includes hidden-mode amounts when applicable. Inventory quantities, seen markers, and quest counter increments are distinct pieces of state.

`Assets/Scripts/Assembly-CSharp/CurrencyManager.cs` maps **Money → PlayerData.geo**, **Shard → PlayerData.ShellShards**. `ChangeCurrency` (**151**) merges deltas into a queue; `LateUpdate` applies them and updates counters. Legacy names `AddGeo` / `geo` survive in current money code; the name alone does not mean a Hollow Knight-only system. Money added in the same frame may not yet appear in `PlayerData.geo` until the queue runs.

Shop route:

- `Assets/Scripts/Assembly-CSharp/ShopOwnerBase.cs::SpawnUpdateShop` creates/reuses a shared shop prefab, sets its `Stock` and localized title.
- `Assets/Scripts/ProjectCode/Game/07_UI_Localization/ShopMenuStock.cs` builds and exposes available stock, item costs, display state and post-purchase events.
- `Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/SetShopItemPurchasedV2.cs::OnEnter` finds `ShopItemStats`, sets an **IsWaitingBool**, invokes its purchase callback, and immediately finishes the action. The waiting bool/callback governs later presentation.
- `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/ShopItemStats.cs` bridges the displayed item to `Assets/Scripts/Assembly-CSharp/ShopItem.cs::SetPurchased` (**437**).
- `ShopItem.SetPurchased` charges the chosen currency, consumes required/upgrade items, applies player bool/int writes, invokes serialized `onPurchase`, spawns conditional objects, handles map updates, and grants a saved item or tool tutorial. Affordability/availability checks belong to the caller/UI contract; do not expose `SetPurchased` as a self-validating public economy transaction in a new game.

Key shop-asset fields: `currencyType`, `cost` / `costReference`, `requiredItem` / amount, `requiredTools`, appearance conditions, `savedItem`, `playerDataBoolName`, `playerDataIntName`, `subItems`, `onPurchase`, extra writes and `eventAfterPurchased`. Copying only a `savedItem` reference loses the transaction.

Validation to run: first unlock vs refill; equipment changed while paused; duplicate tool in floating and crest slots; empty quantity; exact and insufficient resource refill; collecting at capacity; purchase callback/presentation; same-frame currency updates; save/load after changing a crest. No such runtime cases are claimed as already passed.

## 6. Quests / wishes / story progression

### 6.1 Definitions, runtime registry and completion state

`Assets/Data Assets/Quest System/Master Quest List.asset` contains **82 direct list entries** in this snapshot. The list can contain quest/group objects; do not report that number as a verified count of distinct player-visible quests. `Assets/Scripts/Assembly-CSharp/QuestList.cs` and `QuestGroupBase.cs` are the grouping entry points.

`Assets/Scripts/Assembly-CSharp/QuestManager.cs::Awake` initializes the master list and increments its cache version. `GetAllQuests`, `GetAcceptedQuests`, `GetActiveQuests`, `GetQuest` and `UpgradeQuests` are the query/upgrade routes. `GetQuest` looks up full quest assets by **asset name**. Accepting an unregistered quest is not equivalent to adding one to the master list.

`Assets/Scripts/Assembly-CSharp/BasicQuestBase.cs` defines availability, accepted/hidden/seen state and UI entry points. `FullQuestBase.cs` implements targets, prerequisites, progression links, turn-in, rewards metadata and persisted completion. `Quest.cs` adds a serialized quest type; `MainQuest.cs`, `SubQuest.cs` and other group types provide variants. `QuestCompletionData.cs::Completion` stores `IsAccepted`, `CompletedCount`, `IsCompleted`, `WasEverCompleted`, and `HasBeenSeen`.

Fields to resolve on every full quest asset:

- `targets[]`: `Counter`, `Count`, alternate player-data test, hidden-count flag;
- `playerDataTest`, `persistentBoolTests`, `requiredCompleteQuests`, `requiredUnlockedTools`, `requiredCompleteTotalGroups`;
- `previousQuestStep`, `markCompleted`, `cancelIfIncomplete`, `hideIfComplete`;
- `consumeTargetIfApplicable`, `canTurnInAtBoard`, `getTargetCondition`;
- `rewardItem`, `rewardCount`, `rewardCountAct3`, quest type and localized descriptions.

`FullQuestBase.IsAvailable` evaluates its prerequisites; `CanComplete` compares every target/counter pair. A completed quest displays target counts as complete. `AltTest` can satisfy a target without incrementing its normal counter. Therefore counting `CompletedCount` alone is not a general completion rule.

### 6.2 Accept → collect → turn in → reward → save

1. **Accept:** board/NPC/FSM calls `FullQuestBase.BeginQuest`. It first checks `QuestManager.IsQuestInList`, completes/updates previous steps, cancels configured incomplete quests, marks accepted/not complete/unseen, marks the inventory pane, and optionally waits on the accepted prompt callback. `BeginQuest` itself does not re-evaluate every availability condition; caller/UI conditions remain relevant.
2. **Progress:** `Assets/Scripts/Assembly-CSharp/QuestTargetCounter.cs::Increment` broadcasts `OnIncrement`. `FullQuestBase.IncrementCounterHandler` updates accepted unfinished quests whose counters match. Other counters read current inventory, player data or journal state through overrides of `GetCompletionAmount`.
3. **Turn in:** `FullQuestBase.TryEndQuest` checks `CanComplete` unless `forceEnd`; completes previous steps, writes completion, optionally consumes targets, updates inventory/achievement presentation, calls `GameManager.QueueSaveGame`, and notifies the quest type.
4. **Reward:** `TryEndQuest` does **not** directly execute `RewardItem.Get`. `Assets/Scripts/ProjectCode/FSM/QuestActions/GetQuestRewardV2.cs` retrieves the reward object and count; an NPC/board/delivery sequence must actually grant it, e.g. `Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/SavedItemGetV2.cs::OnEnter`. Some rewards are custom player-data writes or scene sequences and have null `rewardItem`.
5. **Flush:** the queued save must be dispatched. A verified normal interaction endpoint is `Assets/Scripts/Assembly-CSharp/NPCControlBase.cs::CallEndAction`, which calls `GameManager.DoQueuedSaveGame` after conversation teardown. Other flows can save explicitly.

FSM adapters: `Assets/Scripts/ProjectCode/FSM/QuestActions/QuestFsmAction.cs` reads an object-typed `Quest`; `BeginQuestV2.cs` can wait for the prompt; `EndQuestV2.cs` force-ends and assumes prior validation; `TryEndQuestV2.cs` is the checked route to inspect. Availability/completion actions include `CanBeginQuest.cs` and `CanEndQuestV2.cs` in the same directory. Preserve the specific action class used by a state rather than assuming numbered versions have identical semantics.

### 6.3 A concrete data example

`Assets/Data Assets/Quest System/Quests/Mossberry Collection 1.asset`:

- target `Assets/Data Assets/Collectables/Collectable Items/Mossberry.asset`, count **3**;
- `consumeTargetIfApplicable: 1`, `canTurnInAtBoard: 1`;
- previous step `Assets/Data Assets/Quest System/Quests/Mossberry Collection Pre.asset`;
- display key **Quests / QUEST_MOSSBERRY1_TITLE**;
- `rewardItem: {fileID: 0}` despite a configured reward icon.

This is a good small quest-state exercise, but its reward must be traced through the scene giver before reproducing the original reward. This chapter does not substitute a guessed reward for that missing semantic trace.

Board UI entry: `Assets/Scripts/Assembly-CSharp/QuestItemBoard.cs::OpenPane`, `SubmitQuestSelection`, its yes/no state handling; board datasets include `Assets/Data Assets/Quest System/Bonetown Quest Board.asset`, **Pilgrims Rest Quest Board.asset**, and **Enclave Quest Board.asset**. `Assets/Scripts/ProjectCode/FSM/QuestActions/ShowQuestBoard.cs` is the FSM-facing route.

Minimal quest slice: stable quest key + accept state + one counter + completion + explicit reward transaction + save. Then add availability predicates, consume-on-turn-in, prior-step progression, board UI, NPC delivery, journal counters, repeat/donation semantics and Act 3 reward differences. Validate pre-accept collection, duplicate acceptance, insufficient turn-in, forced turn-in, repeat completion, interrupted reward presentation, save/reload and renamed definitions.

## 7. NPCs and interaction lifecycle

`Assets/Scripts/Assembly-CSharp/InteractableBase.cs` uses trigger membership and an optional enter/exit detector. Its source checks **layer 9** for the hero. `ShowInteraction` registers the interactable and prompt marker with `Assets/Scripts/Assembly-CSharp/InteractManager.cs`.

`InteractManager.Update` finds the nearest eligible object by priority: high priority, then regular, then any remaining. It checks manager and hero interaction eligibility. The observed input condition uses **Up.WasPressed or Down.WasPressed**, with neither left nor right held. A custom game can change that binding, but importing a trigger alone does not automatically create an interaction path.

`Assets/Scripts/Assembly-CSharp/NPCControlBase.cs` then handles the control lifecycle:

```text
Interact -> StartDialogueMove
  -> optionally move hero to configured side/distance
  -> StartDialogue -> HeroTalkAnimation.EnterConversation
  -> subclass OnStartDialogue
  -> line begin/end events and hero talking animation
  -> EndDialogue -> cancel movement / stop talking
  -> CallEndAction -> exit conversation / EndedDialogue / dispatch queued save
```

Relevant serialized fields include `talkPosition`, `centreOffset`, `targetDistance`, `outsideRangeBehaviour`, `checkGround`, `heroAnimation`, and manual/automatic animation begin. Scene exit and disable paths remove input blockers and cancel movement. Preserve those cleanup paths before adding conversation branches.

`Assets/Scripts/Assembly-CSharp/BasicNPCBase.cs::OnStartDialogue` opens `DialogueBox.StartConversation` from a `LocalisedString`, disables interaction, and emits configured events to an `eventTarget` FSM. `BasicNPC.cs` selects first/repeat/return text, persists its talk index through `PersistentIntItem`, and can grant `giveOnFirstTalkItems` at dialogue end. It is the smallest readable NPC route; more complex NPCs can use entirely different FSM orchestration.

`Assets/Scripts/ProjectCode/Game/07_UI_Localization/DialogueBox.cs::StartConversation`, `ShowShared`, `RunDialogue`, `ParseTextForDialogueLines` are the presentation route. The box has its own singleton, Animator, text mesh, HUD FSM, line parsing and cancellation callbacks. Starting a conversation while no box instance exists does not instantiate one. `Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/RunDialogueBase.cs` and the `RunDialogue` versions bridge FSM states into that box.

Minimal port: one overlap detector, one prompt, one priority decision, a temporary player input lock, one dialogue presenter, then an explicit cleanup callback. Add position correction and persistence after interruption by damage/scene exit cannot strand input. Prefer explicit item-grant callbacks over embedding grants in text parsing.

## 8. UI, localization, inventory, map and journal navigation

These are indexed routes with selected entry-body reads, not a claim that every screen/FSM was reviewed.

| System | Exact entry and source route | Binding / caveat |
|---|---|---|
| Main menu, pause, profile flow | `Assets/Scripts/ProjectCode/Game/07_UI_Localization/UIManager.cs::Awake`, `Start`, `UIGoToMainMenu`, `StartNewGame`, `UIContinueGame`, `MakeMenuLean` | `Assets/Prefabs/UI/_UIManager.prefab`; concrete menu scene; Animator/UI object references |
| Save slot buttons | `Assets/Scripts/ProjectCode/UnityNamespaceExtensions/UI/SaveSlotButton.cs`; data routes `GameManager.GetSaveStatsForSlot` / `LoadGameFromUI` | Selection and metadata load are distinct from loading gameplay |
| Inventory panes | `Assets/Scripts/Assembly-CSharp/InventoryPaneList.cs`; `InventoryItemTool.cs`, `InventoryToolCrest.cs`, `InventoryItemCollectable.cs`, `InventoryItemQuestManager.cs` in that directory | Named panes **Tools**, **Inv**, **Quests** are used by item/quest APIs; manager setup expects HUD child **Inventory** |
| Map | `Assets/Scripts/ProjectCode/Game/07_UI_Localization/GameMap.cs`; `Assets/Scripts/Assembly-CSharp/MapSceneRegion.cs`, `MapPin.cs` | `PlayerData.scenesVisited` / `scenesMapped`, map ownership and scene-specific map data; map purchase invokes `GameManager.UpdateGameMap` |
| Fast travel | `Assets/Scripts/Assembly-CSharp/FastTravelScenes.cs`, `FastTravelMap.cs`, `FastTravelCutscene.cs` | Travel unlock fields in `PlayerData`; destination data and cutscene bindings; see scene/travel chapter before loading a scene directly |
| Enemy journal | `Assets/Scripts/Assembly-CSharp/EnemyJournalManager.cs::RecordKill`, `RecordKillToJournalData`; `EnemyJournalRecord.cs`, `EnemyJournalKillData.cs` in that directory | `Assets/Data Assets/Enemy Journal/Master Journal List.asset`; record name is the save key; `RecordKill` also calls counter increment and quest update paths |
| Text localization | `Assets/Scripts/Assembly-CSharp/LocalizationProjectSettings.cs`; `Assets/Scripts/ProjectCode/Game/07_UI_Localization/AutoLocalizeTextUI.cs`, `SetTextMeshProGameText.cs` | `Assets/Resources/LocalizationProjectSettings.asset`; `Assets/Resources/Languages/` sheets; core implementation in `Assets/Plugins/TeamCherry.Localization.dll` |
| Font/layout changes | `Assets/Scripts/ProjectCode/Game/07_UI_Localization/ChangeFontByLanguage.cs`; `Assets/Scripts/Assembly-CSharp/ChangePositionByLanguage.cs`, `ChangeSpacingByLanguage.cs`, `ChangeByLanguageBase.cs` | Serialized language-specific fonts/scales; uses the project `TMProOld` API in multiple callers |

Localization keys are a pair, **Sheet + Key**, not only an English text string. For example a quest title resolves through `Quests / QUEST_MOSSBERRY1_TITLE`; the corresponding language sheet is `Assets/Resources/Languages/EN_Quests.txt` or another language's equivalent. `LocalizationProjectSettings.TryGetSavedLanguageCode` reads **M2H_lastLanguage** from `Platform.LocalSharedData`; `OnSwitchedLanguage` persists it. `AutoLocalizeTextUI` subscribes to `GameManager.RefreshLanguageText`. `StartManager` can reload language before menu activation and refresh font/position components.

The core `Language`, `LocalisedString` and localization base implementation was not read from DLL internals here. No claim is made that Unity Localization package APIs can replace it without an adapter. For a small original project, define a simple Sheet/Key resolver and a text presenter; add language-dependent sizing/font fallback only after the first HUD/menu exists.

## 9. Platform, user settings, input and achievements

`Assets/Scripts/ProjectCode/Game/09_Platform_Input_Achievements/Platform.cs` is the boundary for save storage, shared data, engagement, graphics, achievements, scene-loading notifications and other native behavior. `DesktopPlatform.Awake` chooses packaged online providers, initializes local and roaming shared data and save restoration. Serialized `steamEnabled`/`galaxyEnabled` flags alone are not proof of an active online session. `CreateOnlineSubsystem` tests packaged providers and rejects multiple providers.

`Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/GameSettings.cs` contains explicit load/save/reset routes for game options, keyboard/controller, audio, display, brightness and overscan. Source names such as `dreamNailKey` or `superDashKey` can persist as compatibility names. Follow actual `HeroActions` consumers instead of renaming them based only on labels.

Input in this checkout is explicitly a reconstruction/compatibility layer:

- `Assets/Scripts/ProjectCode/Game/02_Player/InputSystem/InputManager.cs` states that its API mirrors the used InControl subset while using **Unity Input System**. `Initialize` subscribes to native device/update events. `ResetRuntime` clears static state and unsubscribes for a new play session.
- `GetActionMap` looks up `UnityEngine.InputSystem.InputSystem.actions` by map name, optionally clones and removes binding overrides; if unavailable it creates a runtime fallback map with a warning. Empty fallback existence is not proof that every action is correctly bound.
- `Assets/InputSystem_Actions.inputactions`, `Assets/Scripts/ProjectCode/Game/02_Player/HeroActions.cs`, and `InputHandler.cs` are the asset → compatibility action → gameplay/UI mode route. The player chapter covers action execution.
- `Assets/Scripts/ProjectCode/Game/09_Platform_Input_Achievements/NativeInputModuleManager.cs`, `InputModuleBinder.cs`, `InputModuleActionAdaptor.cs` and `PreMenuInputModuleActionAdaptor.cs` are navigation entries for UI event-system integration; these internals were not deeply audited here.

Achievements: `Assets/Scripts/ProjectCode/Game/09_Platform_Input_Achievements/AchievementHandler.cs::AwardAchievementToPlayer` checks demo mode, membership in `AchievementsList`, allowed map-zone conditions and platform unlock state before `Platform.PushAchievementUnlock`. `QueueAchievement` deduplicates keys; `AwardQueuedAchievements` dispatches pending unlock/progress; `FlushRecordsToDisk` saves roaming shared data. `Achievements List.asset` is serialized on the manager. The hardcoded **GODS_GLORY** whitelist remains in source; do not treat it as proof of current story use.

Vibration routes: `Assets/Scripts/ProjectCode/Game/09_Platform_Input_Achievements/VibrationManager.cs`, `PlatformVibrationHelper.cs`, `VibrationMixer.cs`, `GamepadVibration.cs`, `WorldRumbleManager.cs`, and `VibrationDataAsset.cs`. They are precise starting points; timing/mixer behavior was not fully read in this chapter. A local gameplay prototype can use a no-op platform-achievement/vibration adapter until a concrete target platform is chosen.

Minimum validation: two play-session starts with domain reload settings relevant to the new project; keyboard + connected/disconnected controller; rebinding persists without affecting an unrelated action map; menu/gameplay input switching; local save with no online provider; language/preferences survive restart; queued achievement cannot duplicate unnecessarily. External store side effects are not part of this documentation task.

## 10. World interactions and reusable prop patterns

World objects mix C# and serialized FSMs. They are not all `HealthManager` enemies and not all descendants of the same generic interactable class.

| Pattern | Source route | Dependencies / exact observation |
|---|---|---|
| Breakable prop | `Assets/Scripts/ProjectCode/Game/04_World_Environment/Breakable.cs::Awake`, `Hit` (**619**), `Break` (**912**) | Implements `IHitResponder`; filters hit kind, cooldown, range, prerequisites; binds persistent bool to `isBroken`; manages whole/remnant/debris/drop objects |
| Pickup prop | `Assets/Scripts/Assembly-CSharp/CollectableItemPickup.cs::DoPickupAction` | `SavedItem`, optional player flag, pickup animations/events, scene persistence |
| Falling/resetting platform | `Assets/Scripts/ProjectCode/Game/04_World_Environment/DropPlatform.cs::OnCollisionEnter2D`, `Flip` | Checks hero layer 9 and top-side contact; this implementation waits 0.7 s, disables collider, plays drop animation, waits 1.5 s, plays rise and re-enables; per-instance clips/collider/audio required |
| Platform impact/bob | `Assets/Scripts/ProjectCode/Game/04_World_Environment/LiftPlatform.cs::OnCollisionEnter2D`, `DoBobInternal` | Source entry/fields inspected; per-part delay/magnitude, dust, audio, vibration and `OnBob`; full timing path not audited |
| Lever bridge | `Assets/Scripts/ProjectCode/Game/04_World_Environment/BridgeLever.cs::Start`, `OnTriggerEnter2D`, `OpenBridge` | Navigation only; default player-data field is `cityBridge1`, so confirm actual current scene binding before reuse |
| Trigger activation | `Assets/Scripts/ProjectCode/Game/04_World_Environment/TriggerEnterEvent.cs`, `TriggerActivateGameObject.cs`, `TriggerActivateComponent.cs` | Resolve per-instance event/target and physics layers |
| Conveyors / lifts / hazards | `Assets/Scripts/ProjectCode/Game/04_World_Environment/ConveyorBelt.cs`, `ConveyorZone.cs`, `RuinsLift.cs`, `StalactiteControl.cs` | Indexed starting points, not semantically validated behavior here |
| Player-data activation | `Assets/Scripts/ProjectCode/Game/04_World_Environment/ActivateIfPlayerdataTrue.cs`; `Assets/Scripts/ProjectCode/Game/06_Data_Save_Progression/PersistentActivator.cs` | Global predicate vs per-object saved-state activation must be distinguished |
| Bench | `Assets/Scripts/ProjectCode/Game/04_World_Environment/RestBench.cs`; `Assets/PlayMaker/Templates/bench_control.asset` | `RestBench` only calls `HeroController.NearBench` and shows a queued reminder on exit. Rest/heal/save/respawn is in the FSM and related actions, not that short C# class |

`Breakable.Awake` can dynamically add a `PersistentBoolItem` for an active child named **rosary** and binds read/write callbacks. A static component census alone can therefore miss a runtime persistence component. Its hit and drop options are serialized per object; inspect the chosen prop before assuming the constructor defaults apply.

The bench template contains states **Save Game**, **Save Frame**, **Replenish Tools**, **Replenish Tools Silently** and actions calling `ResetSemiPersistentItems`, saving and `TryReplenishTools`. This chapter located those branches but did not decode every bench state. Use the shared FSM index and decoder to resolve the selected bench's template variables and surrounding scene bindings, including the respawn marker, before porting it.

Minimum prop slice: one collision layer contract, one `IHitResponder`-style hit receiver, one stable persistence key, and explicit visual/collider state transitions. Add debris/pools/sound/vibration only after repeated hit and save/reload behavior is reliable.

## 11. Progressive integration order for an empty Unity project

This is a suggested implementation order, not a completed implementation or a claim that the original game was built in this order.

| Step | Implement | Gate before continuing |
|---|---|---|
| 1 | Minimal boot, camera, one room, player input | Enter/exit play twice; no duplicate service/input state |
| 2 | Typed player state and one movement ability | Action unavailable before grant, available after, reversible in test setup |
| 3 | Player save + one permanent scene flag + one semi-persistent prop | Restart/room return/reset give the three intended results |
| 4 | One pickup and inventory quantity | Capacity, duplicate pickup and save persistence are correct |
| 5 | One crest/tool slot, one attack tool, quantity and refill | Equipment notifications and currency accounting work before UI complexity |
| 6 | One NPC, one quest target, explicit reward and save dispatch | Complete transaction survives interrupted presentation and reload |
| 7 | Bench/respawn and travel between two rooms | Respawn identity, reset policy and serialized entry gates remain consistent |
| 8 | HUD/menu/localization and platform adapters | Input mode switching and language change are reliable |
| 9 | Broader tool/quest/story content and presentation | Resolve each new asset's dependency graph; add targeted checks for new semantics |

A minimal dependency list in this chapter means conceptual dependencies for an extracted/adapted slice. It is **not** a tested list of files that can be copied unchanged and immediately compile. The current source frequently calls static globals, Unity extensions, PlayMaker, tk2d, Addressables, the `TMProOld` API, Newtonsoft converters and project-specific DLLs. Use source-symbol and asset-reference indexes to close the transitive dependency graph for the exact slice chosen.

## 12. Coverage record and remaining work

### Semantically read in this chapter

The named routes above were read from current implementation bodies, not inferred from class names or previous research prose:

- **Lifecycle:** `AddressablesLoadScene.Start`; `StartManager.Start`; `StartGameEventTrigger.OnSubmit`; `CoreLoop`; `QuitToMenu`; `GameManager` singleton/Awake/setup, save/load/new/continue/pool/hero-loading and selected fixup paths; `OpeningSequence`; global-settings loader/base; generic manager singleton.
- **Save/data:** `SaveGameData`; `SaveFileCodec`; `SaveDataUtility`; `SceneData`; `PersistentItem<T>`; `PersistentBoolItem`; `PlayerData` singleton/default setup/accessors/save hooks; `SaveDataUpgradeHandler`; `SerializableNamedList`; selected desktop save implementation; `SaveGame`, `SaveGameV2`.
- **Progression/equipment:** shrine wall-jump and Seamstress umbrella grant states decoded from scene YAML; `PlayerDataTest`; `SetPlayerDataVariable`; tool unlock, crest unlock, equipment writes/events and replenishment; tool and crest saved record types.
- **Items/economy:** `CollectableItem.Collect/Take`; pickup grant path; `CurrencyManager`; `ShopOwnerBase`; `ShopItem.SetPurchased`; purchase FSM adapter.
- **Quests/interactions:** `BasicQuestBase`; `FullQuestBase`; quest manager registry/query/upgrade paths; target and completion record; begin/end/reward FSM adapters; `InteractableBase` registration; `InteractManager` selection/input; `NPCControlBase` lifecycle; `BasicNPCBase` / `BasicNPC`; dialogue entry/presentation setup.
- **UI/platform/world selected slices:** UI new-game path; localization settings and text refresh; input initialization/action-map compatibility; achievement dispatch; breakable persistence/hit entry and break start; complete drop-platform class; complete proximity-only `RestBench` class.

### Static bindings inspected

Pre-menu loader and intro, the three menu manager objects, opening sequence, selected manager-prefab components and lists, GameConfig, tool/crest/quest master lists, Mossberry and Brolly quest assets and their referenced targets, the two concrete ability grant FSMs, language resource/DLL locations, and bench-template branch locations.

### Explicit gaps

- Not every method in large `GameManager`, UI, player-data or item classes was read. Untouched subsystems in the navigation tables are labeled as indexed/entry routes. The shared census provides full discoverability, not a false “all semantics verified” claim.
- No complete end-to-end NPC quest reward replay, complete bench decode, every quest prerequisite graph, all shop affordability/purchase FSM paths, all restored save formats in practice, or every input binding/device combination was verified.
- PlayMaker and localization DLL internals were not analyzed here; serialized FSM data and surrounding action source do not fully prove all engine scheduling behavior.
- Current source includes local reconstruction choices (save codec, input compatibility layer, CoreLoop maintenance comments and behavior). Treat these as current-project facts.
- `PlayerData.AddGGPlayerDataOverrides` is empty in current source; boss-rush branches/old achievement names are not evidence of a complete working mode. Scene travel constants, old NPC classes and legacy field names require actual runtime/serialized references before use.
- No game files were modified for this chapter. Future verification should run in the new project or isolated test copies and record which source/configuration hashes were used.
