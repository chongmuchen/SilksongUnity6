# Player, movement, attacks, damage, enemy and boss reference

Purpose: retrieve an implemented behavior and its **actual serialized owner, runtime call chain, animation window, and migration dependencies** before implementing it in a new Unity project. This is a static reference to the current recovered/modified `SilksongUnity6` workspace, not a claim to possess pristine official source or a verified retail simulation.

Read [README](README.md) and [retrieval protocol](00_RETRIEVAL.md) first. All `Assets/...` and `ProjectSettings/...` paths below are relative to the source project. Identifiers, event strings, fileIDs, and GUIDs are evidence keys; line numbers are optional hints and must be refreshed after edits. `fileID` is unique only within its containing asset. Use `data/asset-index.tsv` to resolve GUIDs, `data/script-bindings/` shards to find attached scripts, and `data/fsm-index.tsv` to find serialized FSM owners. See [assembly/FSM reference](40_RUNTIME_AND_DEPENDENCIES.md) for dynamic calls and template interpretation.

## 1. Retrieval map

| Requested behavior / search aliases | First code anchors | Required serialized evidence / continuation |
|---|---|---|
| Player bootstrap / 主角出生 | `HeroController.Awake`, `SetupGameRefs`, `Start`, `SceneInit` | `Assets/Prefabs/Heroes/Hero_Hornet.prefab`; game bootstrap, `GameManager`, input and scene setup |
| Walk, run / 行走、跑步 | `HeroController.LookForInput`, `FilterInput`, `DoMovement`, `Move`, `GetRunSpeed`, `GetWalkSpeed` | Hero prefab constants; `HeroAnimationController`; floor, slope, conveyor contacts |
| Jump, short hop, coyote time / 跳跃、小跳、土狼时间 | `LookForQueueInput`, `CanJump`, `HeroJump`, `Jump`, `JumpReleased`, `LeftGround` | Hero prefab `JUMP_*`; nonserialized queue/buffer fields in source; fixed timestep |
| Double jump, umbrella / 二段跳、浮空 | `CanDoubleJump`, `DoDoubleJump`, `DoubleJump`, `CanFloat`, `StartFloat` | ability flags **and** active hero config; `hornet_umbrella_float.asset` |
| Dash, sprint, dash attack / 冲刺、疾跑、冲刺攻击 | `CanDash`, `HeroDashPressed`, `HeroDash`, `Dash`, `FinishedDashing` | `hornet_sprint.asset`, active config's `DashStab`, `DashStabAlt`; dash and sprint are cooperating controllers |
| Wall slide/jump/scramble/mantle / 滑墙、蹬墙、爬墙、攀边 | `BeginWallSlide`, `LateUpdate`, `DoWallJump`, `CanWallScramble`, `CheckClamberLedge` | `NonSlider`, `SlideSurface`, `NoClamberRegion`; `hornet_wall_scramble.asset`, `hornet_mantle.asset` |
| Normal/up/down slash / 平砍、上劈、下劈 | `DoAttack`, `Attack`, `DownAttack`; `NailSlash.StartSlash` | `HeroController.ConfigGroup`, active config asset, slash object, tk2d library, PolygonCollider2D |
| Pogo / 下劈反弹、弹跳 | `HeroDownAttack.OnHitResponded`, `ContinueBounceTrigger`; `Downspike.QueueBounce`, `NailSlash.QueueBounce`; `HeroController.DownspikeBounce` | `NonBouncer`, `HeroSlashBounceConfig`, `crest_downslash_reaction.asset`, `crest_attacks.asset` |
| Charged needle / 蓄力攻击 | `HeroController.Update`, `CanNailCharge`, `CanNailArt`, `NeedleArtRecovery` | `hornet_nail_arts.asset`; active config's `ChargeSlash`; charge effect bindings |
| Tools / 工具、投掷、弹药 | `GetWillThrowTool`, `CanThrowTool`, `ThrowTool`, `DidUseAttackTool` | `ToolItem.UsageOptions`, `ToolItemManager`, `tool_attacks.asset` or ThrowPrefab |
| Silk skills / 丝技能、技能弹反 | `CanDoSpecial`, `ThrowTool`, `CheckParry`, `TakeDamage` | `hornet_specials.asset`, tool `FsmEventName`, silk economy |
| Bind/heal / 结丝、治疗 | `CanBind`, `BindCompleted`, `BindInterrupted`, `AddHealth`, `TakeSilk` | `hornet_bind.asset`, `PlayerData`, `SilkSpool`, crest-specific modes |
| Damage to enemies / 命中、伤害 | `DamageEnemies.LateFixedUpdate`, `DoDamage`, `ProcessDamageBuffer`; `HitTaker.GetHitResponders`; `HealthManager.Hit`, `TakeDamage` | actual attacking and receiving colliders; attack lifecycle and shared damage groups |
| Contact damage / 主角受伤 | `HeroBox.TakeDamageFromDamager`, `ApplyBufferedHit`; `DamageHero`; `HeroController.TakeDamage` | `CustomPlayerLoop`; `HeroBox` geometry per posture; HazardType/flags |
| Clash/parry / 拼刀、弹反 | `DamageHero.TryClashTinkCollider`, `NailClash`; `HeroController.NailParry`, `NailParryRecover` | `Clash Tink` child collider, layer/tag, `canClashTink`; distinct from special-skill parry |
| Invulnerability, recoil / 无敌帧、硬直、击退 | `CanTakeDamage`, `StartRecoil`, `StartInvulnerable`; `HealthManager.IsBlockingByDirection`; `Recoil` | hero config, status sources, enemy directional block and attack immunities |
| Death, hazard respawn / 死亡、地形重生 | `HeroController.Die`, `DieFromHazard`, `Respawn`, `HazardRespawn`; `HealthManager.Die` | `GameManager` death coroutine, corpse marker, currency, save, enemy special-death FSM |
| Enemy/boss move / 敌人、Boss招式 | identify journal + exact instance first; then owner/FSM/state/action | `Docs/CombatResearch/data/catalog.json`, individual `entities/*.json`; §9 below |
| Animation active frames / 动画、前摇、攻击帧、后摇 | `NailSlash.OnAnimationEventTriggered`, `Downspike.StartSlash`; `HeroAnimationController.UpdateAnimation`; `tk2dSpriteAnimator.UpdateAnimation` | actual clip, frame events, fps, animation overrides, FSM listeners; §5 |

### Source path dictionary

Use these abbreviations only within this document; they are not Unity namespaces.

- **HC** = `Assets/Scripts/ProjectCode/Game/02_Player/HeroController.cs` (12,153 lines at review).
- **HAC** = `Assets/Scripts/ProjectCode/Game/02_Player/HeroAnimationController.cs`.
- **player/** = `Assets/Scripts/ProjectCode/Game/02_Player/` (`HeroActions`, `InputHandler`, `HeroControllerStates`, `HeroBox`, `HeroAudioController`, `NailSlash`).
- **combat/** = `Assets/Scripts/ProjectCode/Game/03_Combat/` (`DamageEnemies`, `DamageHero`, `HealthManager`, `HitInstance`, `HitTaker`, `IHitResponder`, `AttackTypes`, `SpecialTypes`, `Recoil`, `Sweep`, `AlertRange`, `EnemyDeathEffects`).
- **aux/** = `Assets/Scripts/Assembly-CSharp/` (`HeroControllerConfig`, `HeroControllerConfigWarrior`, `HeroSlashBounceConfig`, `NailAttackBase`, `HeroDownAttack`, `Downspike`, `NailSlashRecoil`, `NailSlashTravel`, `NailSlashTerrainThunk`, `CustomPlayerLoop`).
- **templates/** = `Assets/PlayMaker/Templates/`.
- **hero prefab** = `Assets/Prefabs/Heroes/Hero_Hornet.prefab`.
- **tk2d/** = `Assets/Scripts/TeamCherry/TeamCherry.TK2D/`.

## 2. Actual hero composition and initialization contract

The hero prefab's root GameObject is `1709254077376921`; HC component is `114276157351848250`, script GUID `53b6110480c6c14054e1d629ea0bb027`. HC is attached, not merely a suggestively named old class. Its root Rigidbody2D is dynamic, gravityScale=1; root solid BoxCollider2D offset `(0,-0.51323676)`, size `(0.5,2.078899)`. This solid locomotion collider is distinct from the child `HeroBox` receiving damage and child attack colliders.

`HC.Awake` makes one persistent singleton, calls `SetupGameRefs`, instantiates status-effect children, initializes every ConfigGroup, selects the current config, subscribes to tool-equipment changes, creates tag-damage and bump helpers, and accesses `wallClingEffect`. `SetupGameRefs` obtains `GameManager.instance`, its `InputHandler`, HAC, Rigidbody2D, Collider2D, MeshRenderer, HeroAudioController, AudioSource, `ProxyFSM`, EnviroRegionListener, HeroNailImbuement, HeroVibrationController, InvulnerablePulse, and SpriteFlash. Several references are used unconditionally. Copying the HC class into an empty scene does not produce a self-contained controller.

`HC.Start` resolves `PlayerData.instance` and `UIManager.instance`, finds fallback FSMs by names/child paths, distinguishes gameplay from menu scenes, reads named Sprint/Tool FSM variables, sets up pooled death effects and delivery items, and caches child DamageEnemies. In non-gameplay scenes it hides the hero far below the map and disables gravity. `SceneInit` and scene-entry routines reset another set of state flags. For spawn failures, inspect this sequence before changing movement code.

The prefab contains **47 inline FSM components**, but many serialize a one-state placeholder with a non-null `fsmTemplate`. The external template is the behavioral graph. Current verified root bindings:

| Hero component/FSM (local fileID) | Template path under `templates/` | Actual template graph at review |
|---|---|---|
| `Bind` (`114640522854344479`) | `hornet_bind.asset` | template FSM name `Spell Control`, 96 states |
| `Sprint` (`114195663224090321`) | `hornet_sprint.asset` | 156 states |
| `Harpoon Dash` (`114514865527688870`) | `hornet_harpoon_dash.asset` | 90 states |
| `Umbrella Float` (`114026881652295167`) | `hornet_umbrella_float.asset` | binding verified; full graph not behavior-reviewed here |
| `Tool Attacks` (`114940161511173612`) | `tool_attacks.asset` | template FSM name `Init`, 159 states |
| `Silk Specials` (`114808008904197051`) | `hornet_specials.asset` | 119 states |
| `Nail Arts` (`114926484194617170`) | `hornet_nail_arts.asset` | 44 states |
| `Superjump` (`114837889324699812`) | `hornet_superjump.asset` | binding verified |
| `Sprint Silk Usage` (`114673304322830374`) | `hornet_sprint_silk_usage.asset` | binding verified |
| `Crest Attacks` (`114283010227348851`) | `crest_attacks.asset` | 72 states |
| `Wall Scramble` (`114931007380020989`) | `hornet_wall_scramble.asset` | 25 states |
| `Mantle` (`114030420127766190`) | `hornet_mantle.asset` | prefab also contains 17 inline states; inspect template and overrides |
| `Roar and Wound States` (`114442553484811663`) | `roar_and_wound_states.asset` | binding verified |

Read the component's `fsmTemplate`, local variables and template-control/override fields, not just the template's stored defaults. Graph counts are search aids, not proof that every state can be reached. Do not confuse serialized component name with the template's internal FSM name. HC's `spellControl` field directly points to the prefab's `Bind` component, despite the `Spell Control` fallback lookup in code.

### Control handoff is an API contract

The HC/C# controller and FSMs share motion ownership. `RelinquishControl` resets motion/input/attacks; `RelinquishControlNotVelocity` deliberately preserves velocity through a different path. `StopAnimationControl` is separate. `RegainControl` restores posture/input/gravity, checks locks, then consumes a **prioritized chain** of queued flags such as `startWithWallslide`, `startWithShuttlecock`, `startWithJump`, `startWithDash`, `startWithAttack`, and rebound variants. Many `SetStartWith*` methods queue a continuation rather than execute immediately.

For a custom move migration, read all of: its start FSM state, its cancel/global transitions, its `SetStartWith*` calls, `RegainControl`, and animation-control start/stop. Missing one exit causes persistent input locks, stale gravity, wrong hurtbox shape, lost buffered input, or competing velocity writers. `HeroControllerMethods` action enums resolve in `Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/HeroControllerMethods.cs`; e.g. serialized method 1=`RelinquishControlNotVelocity`, 2=`StopAnimationControl`, 6=`RegainControl`, 7=`RelinquishControl`. Never infer a method from the numeric value without that enum.

## 3. Movement and input semantics

### 3.1 Input and clocks

`player/HeroActions.cs` derives from the local `InputSystem.PlayerActionSet` compatibility API and selects the **Player** map in its base constructor. The current implementation in `player/InputSystem/PlayerActions.cs::PlayerActionSet` calls `InputManager.GetActionMap`, which looks up that map in `UnityEngine.InputSystem.InputSystem.actions` and creates a fallback map if absent; the project asset is `Assets/InputSystem_Actions.inputactions`. Preserve this adapter and the native map/bindings together when reusing the current input system. `InputHandler.OnAwake/OnStart` constructs actions, waits for `InputManager` setup, maps keyboard/controller bindings and maintains its own button queue. HC has a **second**, fixed-step queue layer. `LookForInput` handles directional input, release/cancellation and ordinary wall-slide entry; `LookForQueueInput` prioritizes wall jump, ground/coyote jump, double jump, infinite jump and float, then queues unavailable actions.

`FilterInput` snaps horizontal input beyond ±0.3 to ±1 and vertical beyond ±0.5 to ±1. Hold/release state matters: queued attack/dash/tool actions may clear when their button is released. Queue counters increment in HC.FixedUpdate, while decisions and cooldown decrement often occur in Update.

Current source-initialized, nonserialized values in HC: jump queue=2, jump-release queue=2, double-jump queue=10, attack queue=8, tool-throw queue=5, harpoon queue=8, ledge buffer=4 steps. Hero prefab `DASH_QUEUE_STEPS=10`. These are counters with explicit `<=` tests and call-order effects; avoid equating `N steps` with an exact wall-clock input tolerance without a runtime trace.

`ProjectSettings/TimeManager.asset` stores fixed step as `2822399/141120000 ≈ 0.0199999929 s` (about 50 Hz). `ProjectSettings/Physics2DSettings.asset` records gravity (0,−60), solver iterations8/3 and contact offset.01; it is part of any faithful locomotion comparison. `CustomPlayerLoop.SetupCustomPlayerLoop` appends late processing at the end of the FixedUpdate subsystem: LateFixedUpdate list → SuperLateFixedUpdate list → increment FixedUpdateCycle. `DamageEnemies` registers in the former; `HeroBox` in the latter. The ordering permits attack/pogo/parry consequences to be established before buffered ordinary contact damage.

### 3.2 Run/jump/double jump

`FixedUpdate → DoMovement → Move` normally sets X velocity directly from filtered input times GetRunSpeed/GetWalkSpeed; it also considers grounded downspike recovery, blocked slopes and decaying extra velocities. A generic acceleration controller would change this behavior. Normal HC facing is `scale.x < 0` for facing right; verify individual enemy art conventions separately.

`HeroJump` prepares state, resets selected air moves, starts effects/audio, leaves the ground with a small contact-offset correction and lets fixed-step `Jump` supply vertical velocity. `Jump` sets Y to JUMP_SPEED while `jump_steps <= JUMP_STEPS`, increments counters and cancels afterwards. This is sustained velocity assignment for multiple physics ticks, not one impulse. `JumpReleased` halves positive Y velocity after the minimum steps, subject to full-jump and release-queue rules. `CanJump` consumes ledgeBufferSteps only after control, roof, death and other gates pass. `LeftGround` initializes the buffer; inspect both ends when tuning forgiveness.

`DoDoubleJump` has its own flags/effects, clamps excessive falling speed, and switches to `doubleJumping`. `DoubleJump` has fall and rise step phases; Y is set to `1.1*JUMP_SPEED` only when `doubleJump_steps > DOUBLE_JUMP_FALL_STEPS`. `CanDoubleJump` requires both saved `hasDoubleJump` and `Config.CanDoubleJump`, no consumed double jump, no relevant lock, no immediate wall-jump interrupt, and no imminent solid-ground landing. `CanFloat` likewise requires saved `hasBrolly` and config permission; `StartFloat` sends `FLOAT` to the umbrella FSM.

`FixedUpdate` detects the descending phase and starts reduced air-hang gravity, restores it progressively by AIR_HANG_ACCEL, and restores default gravity on jump release when allowed. Hard landings use timers and `ShouldHardLand`; don't replace them with a fixed fall-distance rule.

### 3.3 Dash versus sprint

`HeroDashPressed` can branch to the scuttle tool, wall scramble, or HeroDash. `HeroDash` resets attacks/jumps, selects horizontal versus exclusive-down input, sets dash time, consumes the aerial dash, configures audio/effects/facing and emits `DASHED` to Sprint. `Dash` controls fixed-step velocity: X=±DASH_SPEED with Y=0 for horizontal dash, or Y=−GetMaxFallVelocity for down dash. It disables gravity and can enter a wall slide. `FinishedDashing` restores gravity and sends `TRY SPRINT` or `CANCEL SPRINT`.

The Sprint template is essential even for understanding the short serialized AIR_DASH_TIME. Its `Idle` reacts to `DASHED`, `TRY SPRINT`, `WANDERER DASH COMBO`; `Try` tests `CheckHeroCanSprint`; `Start Sprint` relinquishes control without erasing velocity, stops HC animation control, changes HeroBox and chooses ground/air motion. `Ground Sprint R/L` manage speed buffs, animation choice, bump/vault tests, gravity timers, turn, attack, jump and tool cancellation. It uses InputHandler's queued button API, which is separate from HC's fixed-step queues.

For dash attacks, start at `Dash Stab Dir`, `Attack Antic`, `Attack Dash Start`, `Attack Dash`, `Hit Enemy`, `Dash Stab Bounce`, `Attack Recovery`, then the crest-specific branches: `Reaper Antic/Upper`, Wanderer attack/recoil, Warrior leap/slash, Shaman leap/slash, Toolmaster drill, Witch lash. The active ConfigGroup selects attack objects; a single universal dash-stab animation or damage number loses these branches.

### 3.4 Walls, ledges, ground contacts

`BeginWallSlide` chooses touched wall + requested input, resets dash/double-jump availability, cancels jump/dash, disables gravity, changes HeroBox and starts dust. HC.LateUpdate owns the stick delay, cling deceleration and later slide acceleration. Moving that code into another tick without compensating changes the feel.

`DoWallJump` flips away, clears wall contact, restores air moves, sets `currentWalljumpSpeed=WJ_KICKOFF_SPEED`, and decays horizontal kickoff toward run speed during a fixed-step lock. Opposite input can release the lock after WJLOCK_STEPS_SHORT; the long window and chain window differ. Wall detection includes ray heights and NonSlider rejection (`IsFacingNearWall`), not just a single side collision boolean.

`CanWallScramble` requires a current wall slide, saved wall-jump ability and input toward the wall; HC dispatches `SCRAMBLE`. The template handles `Scramble Up`, `Hit Roof`, `Wall Jump`, `Harpoon Cancel`, `To Attack`, `To Tool Throw`, `Mantle Shift` and `Walldash Cancel`. `CheckClamberLedge` is coupled to mantle and NoClamberRegion. Inspect `OnCollisionEnter2D/Stay2D/Exit2D`, `HandleCollisionTouching`, `CheckTouchingGround`, `BackOnGround`, `LeftGround`, `UpdateSteepSlopes`, and `HeroPlatformStick` when reproducing moving-platform/edge cases.

Ability granting is separate from these permission checks. Verified examples: `Shellwood_10.unity`, `Shrine Weaver Ability` GO `2347`, `Inspection` FSM `10756`, enum Ability=3 → `Set Walljump` selects `hasWalljump` → `End` sets that selected bool; `Bone_East_Umbrella.unity`, `Seamstress` GO `174`, `Dialogue` FSM `604`, `Msg` sets `hasBrolly`. Shared ability FSMs contain many other branches; only the selected branch establishes an instance's grant.

### 3.5 Baseline tuning values (not a universal profile)

Values below are from **HC component 114276157351848250 of the hero prefab**, not field defaults or a retail runtime recording. Buffs/configs/FSMs can modify effective motion.

| Field(s) | Serialized value |
|---|---|
| RUN_SPEED / WALK_SPEED / JUMP_SPEED | 8.25 / 5 / 18.6 |
| JUMP_STEPS / JUMP_STEPS_MIN | 8 / 2 (inclusive comparison in Jump) |
| AIR_HANG_GRAVITY / AIR_HANG_ACCEL | 0.1 / 5 |
| DOUBLE_JUMP_RISE_STEPS / FALL_STEPS | 4 / 4 |
| WJ_KICKOFF_SPEED / short-lock / long-lock / chain | 25 / 5 / 15 / 10 steps |
| WALL_STICKY_STEPS / WALLSLIDE_STICK_TIME / WALLSLIDE_ACCEL | 3 / 0.15 s / −24 |
| DASH_SPEED / DASH_TIME / AIR_DASH_TIME / DOWN_DASH_TIME | 28 / 0.1 / 0.02 / 0.25 s |
| DASH_COOLDOWN / MAX_FALL_VELOCITY | 0.425 s / 30 |
| DOWNSPIKE_REBOUND_STEPS / SPEED | 6 / 20 |
| DOWNSPIKE_INVULNERABILITY_STEPS / LONG | 8 / 16 |
| RECOIL_HOR_VELOCITY / LONG / STEPS | 3.75 / 16 / 8 |
| RECOIL_DURATION / RECOIL_VELOCITY / INVUL_TIME | 0.2 s / 15 / 1 s |
| INVUL_TIME_PARRY / QUAKE / CROSS_STITCH | 0.15 / 0.4 / 0.35 s |
| DAMAGE_FREEZE_DOWN / WAIT / UP / SPEED | 0 / 0.1 / 0.1 / 0 |
| HARD_LANDING_TIME / BIG_FALL_TIME | 0.67 / 0.5 s |

## 4. Config-driven attacks, crests, tools and silk

### 4.1 Configs change behavior, objects and animation lookup

`aux/HeroControllerConfig.cs` is a ScriptableObject with ability permissions, downslash mode, timings, dash-stab settings and animation override library. `HC.UpdateConfig → SetConfigGroup` chooses `configs[]` by crestConfig; a `specialConfigs[]` overlay may replace selected attack objects during Warrior rage. `ConfigGroup.Setup` resolves NailSlash or Downspike based on DownSlashType. Its roots are separately activated/deactivated. HAC is notified and `HC CONFIG UPDATED` is sent.

The equipment-to-moveset bridge is event-driven: `aux/ToolItemManager.cs::SendEquippedChangedEvent` emits `EventRegisterEvents.EquipsChangedEvent` (string **TOOL EQUIPS CHANGED**). HC's `Awake` subscribes `ResetAllCrestState`, which reads `ToolItemManager.GetCrestByName(PlayerData.CurrentCrestID).HeroConfig` into `crestConfig` and calls `UpdateConfig`; HAC independently subscribes `UpdateToolEquipFlags`. `SetEquippedTools` and `SetEquippedCrest` queue changes but do not themselves call `SendEquippedChangedEvent` or each other. Preserve a caller that flushes the event, such as `ToolItemManager.AutoEquip`, or explicitly perform that step after equipment mutation. Otherwise saved crest identity and the active attack objects can disagree. See [systems/equipment](30_SYSTEMS_AND_PROGRESSION.md#52-equipment-changes-are-a-multi-step-contract).

All eight files below are in `Assets/Data Assets/HeroController Configs/`. Durations are raw asset values; rage and quickening modify the effective values.

| Config | DownSlashType / event | AttackDuration | AttackRecoveryTime | AttackCooldownTime | QuickAttackCooldownTime |
|---|---|---:|---:|---:|---:|
| `Default.asset` | DownSpike (0) | .35 | .15 | .41 | .205 |
| `Cloakless.asset` | DownSpike (0) | .35 | .10 | .41 | .205 |
| `Wanderer.asset` | Slash (1) | .25 | .10 | .30 | .15 |
| `Reaper.asset` | Custom (2), `RPR DOWNSLASH` | .35 | .30 | .50 | .25 |
| `Warrior.asset` | Custom, `WARRIOR DOWNSLASH` | .30 | .20 | .39 | .195 |
| `Toolmaster.asset` | Custom, `TOOLMASTER DOWNSLASH` | .35 | .20 | .45 | .225 |
| `Shaman.asset` | Custom, `SHAMAN DOWNSLASH` | .35 | .10 | .50 | .25 |
| `Whip.asset` | Custom, `WITCH DOWNSLASH` | .40 | .30 | .45 | .2375 |

`HeroControllerConfigWarrior` overrides attack duration/recovery/cooldown properties during rage. Shaman's asset allows turning while slashing; the others in this table do not. Default downspike antic=.1, motion time=.1, speed=26, recovery=.25; these are not the same as the slash effect's clip duration. `HC.DidAttack` chooses quick/normal cooldown **then clamps it to at least Config.AttackDuration**. Effective quickening attack duration is separately divided by QuickAttackSpeedMult in `Attack`. Do not copy the raw quick-cooldown field as the final attack rate.

### 4.2 Normal slash chain

```text
HeroActions.Attack / direction
  → HC.LookForQueueInput → CanAttack → CanAttackAction
  → DoAttack (Up first; Down only when permitted, otherwise normal)
  → Attack (current config, wall behavior, alternating attack, attack count)
  → currentSlashDamager.SetDirection(0/90/180/270 degrees)
  → NailSlash.StartSlash → NailAttackBase.OnSlashStarting / OnPlaySlash
  → tk2d effect clip frame events open/close attack collider
  → DamageEnemies late physics response → HealthManager / other IHitResponder
  → NailSlashRecoil / HeroDownAttack / effect and FSM callbacks
```

`Attack` alternates normal/up/down objects if the config provides alternates; the alternation resets on direction change or after AttackRecoveryTime+ALT_ATTACK_RESET. Wall attacks use WallSlash unless Toolmaster redirects the behavior. `NailAttackBase` applies long-needle scale, element/imbuement, supplementary damagers and vibration, coordinates duplicate-hit prevention, and resets properties on cancellation. Its child names `Clash Tink` and `Extra Damager` are executable hierarchy dependencies.

Verified Default config binding in hero prefab:

| Purpose | GameObject fileID / name | Key component evidence |
|---|---|---|
| Normal | `1808113985169905` / `Slash` | NailSlash `114243116046688445`; DamageEnemies `114626796401570045`; animName=`SlashEffect` |
| Alternate | `1472185465350827` / `AltSlash` | NailSlash `114757836356347682`; DamageEnemies `114258089171457190`; `SlashEffectAlt` |
| Up | `1344419225485095` / `UpSlash` | NailSlash `114668567464662426`; DamageEnemies `114521604562973748`; `UpSlashEffect` |
| Down | `1841364053301648` / `DownSlash` | Downspike `114070843845074976`; DamageEnemies `114659245398074480`; HeroDownAttack `114664329654166497`; `DownSlashEffect` |

All four Damagers have useNailDamage=1 and nailDamageMultiplier=1; the raw `damageDealt=5` is **not** the authoritative current needle damage. Normal/up have manualTrigger=0; default down has manualTrigger=1, direction=270, waitForBounceTrigger=0 and useKnockbackDamagers=0.

### 4.3 Down attack and rebound chain

DownSlashType has three implementations:

1. **DownSpike:** `HC.DownAttack` selects Downspike, clamps/decelerates antic motion, can relinquish control and disable gravity. `HC.Update` finishes the antic and calls `currentDownspike.StartSlash`; `HC.FixedUpdate → Downspike` assigns diagonal velocity for thrusting configs. Downspike opens its polygon immediately and switches HeroBox posture. End/rebound calls `FinishDownspike`, which restores control/gravity and applies recovery.
2. **Slash:** `NailSlash` handles the effect animation and may use an explicit Bounce animation event plus a queued bounce. `HeroSlashBounceConfig.Default` uses JumpSteps=4 and JumpedSteps=−20; Wanderer can bind `Assets/Data Assets/Hero Bounce Configs/Wanderer.asset`. Do not assume every downslash uses the default configuration.
3. **Custom:** `crestAttacksFSM.SendEvent(Config.DownSlashEvent)` transfers ownership to `crest_attacks.asset`. `Init` resolves hardcoded children such as `Attacks/Scythe/DownSlash New`, `Attacks/Witch/Lash Damager`, `Attacks/Warrior/SpinSlash`, `Attacks/Shaman/DownSlash`, and Toolmaster's drill/charged variants.

The shared physical rebound adapter is **`aux/HeroDownAttack.cs`**, not NailSlashRecoil's downward branch (that branch does nothing). `OnHitResponded` rejects terrain/soft-terrain/nonbounce cases and stunned/inactive attacks, starts short downspike immunity, optionally stops velocity and gravity, then calls `ContinueBounceTrigger → attack.QueueBounce`. That method excludes active NonBouncer and BounceBalloon; a standalone enemy-type DamageHero without HealthManager can receive a .5 s cooldown unless noBounceCooldown. `Downspike.TryDownBounce` requires a queued bounce, the configured animation trigger policy and CanCustomRecoil. NailSlash's queue path differs and is also connected to EndedDamage.

`HC.DownspikeBounce` resets air moves, sets `jumping`, `downSpikeBouncing`, jump counters from the bounce config, ends the downspike and makes the hero airborne. The subsequent Jump ticks generate rise; it is not a one-line velocity inversion. Short and slightly-short variants use different counters; harpoon variants can retain horizontal rebound. `StartDownspikeInvulnerability` is a **fixed-step** contact-protection counter, distinct from normal post-damage invulnerability.

Custom downslash feedback is also serialized. `crest_downslash_reaction.asset` listens for `HIT LANDED` or interactive contact, checks CanCustomRecoil/NonBouncer, writes the hero Crest Attacks `Attack Target` and sends `ATTACK LANDED`/`BOUNCE TINKED`. Example: `crest_attacks.asset::Rpr Downslash` starts `v3 Down Slash`, calls StartSlash on the resolved object, sets initial scaled velocity (−30,−30), and reacts to attack-landed, bounce-tink, thunk and scene-exit events. `Rpr Downslash Bounce` queues `SetStartWithDownSpikeBounce` before returning control. Copy this message bridge with the movement graph.

### 4.4 Tools, charge, specials, bind

`GetWillThrowTool` selects Up, Down or Neutral `AttackToolBinding`. `CanThrowTool` differentiates Red tools (stock, UsableWhenEmpty, SilkRequired) from Skill tools (SilkSkillCost). `ThrowTool` then chooses among: skill FSM event; blocking tool FSM event with `TAKE CONTROL`; ordinary ThrowPrefab; or nonblocking event. The prefab path handles wall throwing, obstruction-adjusted spawn point, offsets, facing/scale, damage direction, projectile velocity and quick-sling follow-up. Tool animation duration comes from HAC.GetClipDuration; stock consumption is not implied by merely entering a throw animation.

Needle charge accumulates in HC.Update while attack is held and CanNailCharge; CanNailArt also requires CurrentNailChargeTime. `hornet_nail_arts.asset` selects the active config's ChargeSlash (`GetHeroAttackObject`, Attack=7 in the current action enum), takes motion/animation control, runs antic/lunge/spin/crest branches and regains partial/full control. Read `Do Slash`'s animation listener and the attack object's own collider schedule together.

`hornet_specials.asset` is the navigation target for needle throw/return, sphere, parry/cross-slash, silk charge, silk bomb/sonar, taunt and boss needle. Its graph also contains travel/Needolin paths; a template name is not a single-purpose subsystem guarantee. `HC.TakeDamage`/`CheckParry` send `PARRIED` to this FSM when the special parry stance is active. This differs from colliding with a clash-tink collider.

`hornet_bind.asset` owns the bind/heal sequence, silk deductions, air/ground and crest/cursed/reserve/quick-craft branches. `HC.BindCompleted` starts Warrior rage and/or Reaper mode depending on crest; `BindInterrupted` clears relevant moss/silk-part state. `HealthManager.TakeDamage → HC.SilkGain(HitInstance)` respects Full/FirstHit/None silk generation and excluded enemy types; `NailHitEnemy` updates rage healing or Hunter combo meters. For economy migration, follow `PlayerData` and `SilkSpool` rather than replacing all these calls with `silk++`.

## 5. Animation, attack windows and feedback

### 5.1 Two separate animation responsibilities

HAC chooses hero body clips from cState/actorState, attack count and recovery flags; attack objects play **their own effect clips**. Their completion and collider activation times can differ. HAC.GetClip first asks active HeroControllerConfig for an override, then an optional windy/updraft library, then the base animator library. `UpdateAnimation` has explicit priority for no-input/recoil/transition, dashing, downspike antic/bounce/active, slash/tool throws, shuttlecock, float, walls and normal locomotion. Replacing it with one `Animator.SetBool("attacking")` will not preserve transitions or cancel recovery.

The actual default root and attack tk2d library GUID is **`a14142627197a144586ee7b8abd07265` → `Assets/Animations/Knight.prefab`**, component `114724804207875695`. Despite the filename, this is an active Hornet binding. Conversely, the presence of an old HK-named class does not prove its use. Follow GUIDs in both directions.

Freshly inspected clips in that library (frame indices are zero-based):

| Clip | fps | Frames | Trigger-event indices | Interpretation |
|---|---:|---:|---|---|
| `Slash`, `SlashAlt` | 20 | 5 | none | hero body animation, not damage collider schedule |
| `SlashEffect`, `SlashEffectAlt` | 20 | 4 | 0, 2 | NailSlash's first event enables, second disables |
| `UpSlashEffect` | 24 | 6 | 1, 3 | later opening; separate effect clip |
| `DownSlashEffect` | 33.333332 | 5 | none | default Downspike enables polygon in StartSlash |
| `DownSpike Antic` | 42.857143 | 3 | none | body appearance; HC antic timer still controls transition |
| `DownSpike` | 25 | 4 | none | body appearance |
| `Air Dash` | 20 | 4 | none | body appearance; dash/sprint physics clocks differ |

`NailSlash.PlaySlash` applies quickening FPS multiplier. `OnAnimationEventTriggered` treats eventInfo=`Bounce` specially; **other trigger events are counted**, first/second controlling polygon, Clash Tink, Extra Damager and damage end. A newly inserted unrelated event can therefore change hitbox timing. `CancelAttack` clears collider, mesh and callbacks. `Downspike` has a different event contract: trigger marks the bounce trigger reached and ends active damage rather than implementing the two-event window.

`tk2d/tk2dSpriteAnimator.cs::UpdateAnimation`, `ProcessEvents`, `OnLateUpdate` must accompany timing claims. OnLateUpdate uses scaled deltaTime unless isRealtime. Events are processed over crossed frame ranges, not only if the current displayed frame happens to equal an index. Timing `index/fps` is a nominal estimate only: starting frame, replay/reset semantics, speed override, timeScale/freezes, skipped render frames and state exit all matter. Follow the particular action's `OnEnter/OnExit` before assuming animation listeners persist.

### 5.2 Feedback dependencies

- `HC.Attack` plays attack/rage audio tables; `NailSlash.StartSlash` plays its AudioSource (quickening slightly raises pitch); `NailAttackBase` owns vibration and imbuement sound/effects.
- `HAC.AnimationEventTriggered` handles `Footstep`, Wake Up Ground sound phases and sprint-backflip audio. `HeroAudioController` exposes SetFootstepsTable and gates individual PlayFootstep calls; HC.Update enables walk/run/sprint footstep modes and HC.checkEnvironment selects the environment table. Actual footfalls are animation-event driven; do not replace these modes with an assumed continuously looping footstep clip.
- `HealthManager.TakeDamage/Invincible` owns hit flash/effects, slash impact overrides, blocked-hit direction/audio, recoil and silk response. `EnemyDeathEffects` plus its profile/class controls death presentation, corpse and drops.
- `DamageHero.NailClash` plays clash shake/audio/effect, emits directional ClashEvents, applies needle parry protection/recoil, sends `PARRIED` to itself and parent, then recovers after .1 s.
- Hero damage uses `GameManager.FreezeMoment` alongside recoil and invulnerability; visual/physics timeScale behavior is part of combat feedback.

Resolve external GUIDs from the concrete component and FSM action to audio events/tables, clips, effect prefabs, materials/textures, vibration assets and mixer groups. Searching only `Assets/Audio/SFX` by a translated move name is insufficient.

## 6. Outgoing hit contract and enemy health

### 6.1 Attack lifecycle and scheduler

`DamageEnemies` is an attack producer, **not** an enemy AI. OnEnable starts a damage cycle; TriggerEnter filters physics layers and buffers colliders; TriggerExit removes overlaps. LateFixedUpdate evaluates accumulated/current contacts, multi-hit cadence and damage responses. `StartDamage` and `EndDamage` form the attack lifecycle; EndDamage clears colliders/hit counts and invokes EndedDamage once. Disable additionally clears lists. Manual triggers and `ForceUpdate` are separate pathways; inspect the actual attack configuration.

There are several deduplication levels: `damagedColliders`, responders in `hitsResponded`, persistent `damagePrevented`, and optional `sharedDamagedGroup`. Multiple hurtboxes on one enemy must not automatically multiply one swing's damage. Multi-hitter `stepsPerHit` counts physics ticks via `DamageEnemiesCallbackHooks`; subsequent hits can select another damageMultPerHit entry and hit-effect type. The response buffer orders by HitPriority; inspect `AddAndOrder` when a multi-component target behaves unexpectedly.

`HitTaker.GetHitResponders` walks from target upward for at most three levels by default, stopping at a Rigidbody2D or a responder with HitRecurseUpwards=false. Reparenting or adding a rigidbody can silently alter who receives a hit. `HealthManager.SendDamageTo` and `IsPartOfSendToTarget` add shared-body routing.

### 6.2 Hit data and actual damage

`HitInstance` carries Source, attack/element/imbuement/tool identity, base damage, scaling level, stun, poison/zap ticks, direction overrides, magnitude, silk policy, first-hit/manual flags, nonlethal, critical/rage/combo and other properties. Keep a valid Source: several downstream branches dereference it. Degrees use 0=right, 90=up, 180=left, 270=down; `DirectionUtils` cardinal indexes are Right=0/Up=1/Left=2/Down=3, while `HitInstance.HitDirection` is Left=0/Right=1/Up=2/Down=3. They cannot be directly cast between each other.

`DamageEnemies.DoDamage` starts with serialized damage or PlayerData.nailDamage, applies needle/imbuement/crest/tool modifiers and offsets, per-hit multipliers and integer rounding, constructs HitInstance, sends preparatory FSM callbacks, then queues responder calls. `HealthManager.TakeDamage` applies target damageScaling, rapid-hit reductions, critical multipliers, hit/FSM/recoil/effect and silk feedback, then subtracts the final integer damage from self or sendDamageTo. It applies damage tags and routes fatal/nonfatal outcomes. Do not collapse this into one multiplication without preserving rounding and stateful counters.

Current exact `HealthManager.Hit` skeleton:

```text
dead / evasion timer / unusable zero damage => Response.None
send Source "DEALT DAMAGE"
compute actual hit direction
IsBlockingByDirection => Invincible effects/events, Response.Invincible
otherwise TakeDamage(hit) => Response.DamageEnemy
```

A Response.DamageEnemy **does not guarantee HP decreased**: TakeDamage can return early for an immune attack type. `IgnoreInvulnerable` is not passed into the IsBlockingByDirection bypass check. It affects subsequent evasion/death handling. Legacy `invulnerableTime` is in deprecated/unused fields; do not use it to invent a universal per-enemy invulnerability timer.

`IsBlockingByDirection` first requires invincible=true; directional values only matter under that flag. Some damage types/tags/piercing flags bypass blocking; immunity in `IsImmuneTo` is a different check. Blocks may still produce `HIT LANDED` and bounce/tink feedback unless NonBouncer prevents it. Therefore hit, HP loss, stun, silk, bounce, charge consumption and FX are separate outcomes.

### 6.3 Events, stun and death

| Producer | Important outputs | Consumer search |
|---|---|---|
| DamageEnemies.DoDamage | `TAKE DAMAGE`, configured damage/dealt/recorded event | exact target FSM; event may precede actual responder hit |
| HealthManager.Hit | source `DEALT DAMAGE` | attack source FSM |
| HealthManager.TakeDamage | self `HIT`, `TOOK DAMAGE`, sometimes `TOOK SPELL DAMAGE`, `TOOK EXPLOSION DAMAGE`; source `HIT LANDED`, `DEALT ACTUAL DAMAGE` | enemy behavior reactions and attack rebound |
| HealthManager.Invincible | `BLOCKED HIT`, `ATTACK BLOCKED`, directional blocked events; tink callbacks | shield/counter states and player recoil |
| HealthManager.ApplyStunDamage | sets `Stun Damage` then `STUN DAMAGE` | configured stunControlFsm |
| HealthManager.Die | `ZERO HP`, special `LAVA DEATH`, or `FATAL DAMAGE`; C# death events; battle counters | full boss death/phase graph; battle arena state |
| Recoil | `RECOIL`, `RECOIL END`, directional HIT, `FREEZE IN PLACE` | parallel movement/FSM reaction |

With hasSpecialDeath=true, HealthManager.Die sends ZERO HP and returns through a special path without performing all normal death work. Bosses often use this for phases/cinematic death; deleting the object at hp<=0 destroys the graph's remaining contract. `zeroHPEventOverride`, `sendKilledTo`, `battleScene`, `preventDeathAfterHero`, corpse effects, journal recording and persistence also belong to migration scope.

`Recoil` is a separate state machine (Ready/Frozen/Recoiling). It uses Sweep and moves body.position/transform by clipped displacement; it is not always equivalent to AddForce or overwriting velocity. Move actions may block directions, change speed or cancel recoil during attacks. Read those action exit policies with the Recoil component's serialized values.

The existing [combat core](../CombatResearch/parts/core.md) provides expanded formulas and suspicious-current-code cases; use it as a secondary map and re-open the current source symbols above for changes.

## 7. Incoming damage, clash, invulnerability, death and respawn

`HeroBox.CheckForDamage` supports a legacy `damages_hero` FSM path and the ordinary DamageHero path. Ordinary DamageHero contact is collected by `TakeDamageFromDamager`; enemy-type hits are deferred to SuperLateFixedUpdate, whereas other hazards can apply immediately. The buffer keeps the largest damage number but updates hazard/source/side/flags as contacts are processed. Thus simultaneous contacts need a runtime ordering test; do not assume the complete metadata always belongs to the highest-damage source.

`DamageHero.OnAwake` can overwrite damageDealt from DamageReference. It can configure kinematic full-contact physics for clash-enabled colliders and dynamically install a steam wounder FSM from global Gameplay settings. Prefab damage=0 can still be a force-parry/event/multiwounder setup. The actual behavior depends on Awake, enabled state, CanCauseDamage cooldown and linked FSM.

`HC.TakeDamage` normalizes certain hazards (spikes/acid/coal/zap=1, lava/steam=2, respawn pit=0 when entering the positive-damage branch), applies boss-scene modifiers and layered immunity/parry/tool protections, then health/effects/resource consequences. It cancels interrupted motion/attacks and routes to true death, hazard death, or normal recoil. Normal enemy, explosion, non-hazard and environment damage do not share identical invulnerability bypass rules. Read the branch, not just `CanTakeDamage`.

The source includes distinct protections: cState.Invulnerable (including contributed sources), damageMode, transition gates, player invincibility, HeroInvincibilitySource, parryInvulnTimer, downspikeInvulnerabilitySteps, shadow dash, evasion/whiplash, parrying/parryAttack and tool/crest reactions. `StartRecoil` chooses a directional recoil vector, freezes the game, enters no-input/stun, starts Invulnerable and later marks recoiling; Update exits recoil at RECOIL_DURATION. Weighted Anklet modifies recoil/invulnerability values. `StartInvulnerable` can extend an existing pulse routine.

Clash and special parry are different: `DamageHero.TryClashTinkCollider` requires clash configuration and the correct attack-detection layer, obtains the source DamageEnemies, prevents damage to the associated enemy and cancels lag hits, rejects doesNotParry, and starts NailClash. `HC.CheckParry/TakeDamage` instead responds to a special stance by sending `PARRIED` to Silk Specials. Test each separately.

Hurtbox posture examples from **HeroBox methods**, local-space dimensions before transform scale:

| Posture | Offset | Size |
|---|---|---|
| Normal grounded | (0,−.3799) | (.4554,2.2498) |
| Normal airborne | (0,−.14) | (.4554,1.77) |
| Downspike | (0,−.1) | (.4554,1.218) |
| Sprint | (0,−.5844275) | (.4554,1.391145) |
| Airdash | (0,−.4780059) | (.4554,1.036407) |
| Wall slide | (.2101475,−.2755051) | (.875695,1.280464) |

Other methods cover down-drill, Reaper downslash and further postures. Keep posture changes synchronized with attack/control transitions; do not copy only the root collision box.

`HC.Die` interrupts hazard respawn, sends global death/cancel events, disables pause/input/hurtbox, makes the rigidbody kinematic, spawns the selected death prefab, records corpse scene/marker/position/scene size and money, breaks silk spool, clears silk, and delegates to GameManager.PlayerDead. Memory/nonlethal/permadeath/frost/cursed modes choose other paths. `DieFromHazard` uses hazard-specific presentation and GameManager.PlayerDeadFromHazard. `Respawn` and `HazardRespawn` are separate reset flows. For a small new project, explicitly substitute a complete simple respawn service rather than retaining half the original corpse/map/save assumptions.

## 8. Empty-project migration slices and checks

These are proposed implementation slices, not claims that these exports are already packaged. For each slice, gather its code closure through source index and its asset closure through GUID edges, then decide what to port versus replace.

| Slice | Minimum behavior contract | Hidden dependencies to resolve | Meaningful verification |
|---|---|---|---|
| Movement sandbox | input → grounded movement → jump/release → contact/buffer | layer matrix, gravity/fixed step, facing, HC singleton/bootstrap assumptions, environment placeholders | trace x/y/velocity/state at fixed step; short/full jump, edge departure, low roof, wall and slope |
| One default slash | body animation + effect clip + hit collider + attack lifecycle | ConfigGroup; PlayerData.nailDamage; tk2d collection/material; DamageEnemies late loop; IHitResponder | one target with multiple colliders loses HP once per swing; cancel disables collider; up and normal differ correctly |
| Downspike/pogo | antic → diagonal attack → hit response → jump-counter rebound → recovery | manualTrigger, HeroDownAttack, NonBouncer, HeroBox, temporary immunity, reset air moves | hit descending target, simultaneous body contact, shield, nonbouncer, spikes, moving target, whiff/land/cancel |
| Hero damage/retry | deferred contact → protection → health → freeze/recoil → death or hazard respawn | CustomPlayerLoop, DamageHero Awake changes, pulse/FX, complete substitute for original save/map/corpse | simultaneous slash/contact; lethal vs nonlethal; hazard during immunity; respawn has control/gravity/hurtbox restored |
| One simple enemy | exact FSM + sensing/motion + HealthManager + DamageHero + death | action lifecycle, animation events, local child references, alert range, recoil | idle/alert/attack/whiff/interrupt/death; distance and wall edge conditions; no residual damage collider |
| Sprint/crest/tools | explicit control ownership + cancellation + selected objects | templates, queued InputHandler actions, ToolItem/crest data, event bridges, animation overrides | jump/dash/attack/tool cancellation matrix and regained-control flags; depleted resources; equipment changes |
| One boss arena | selected concrete instance + arena actors + all related FSMs | stun, phase/death, battle gate/camera/music, projectile pools and scene constants | every move and phase, interrupted move cleanup, death during projectile/transition, retry/reset |

At least compare 30/60/120 render FPS with the same approximately 50 Hz physics clock for frame-event and counter-sensitive features. Record: physics cycle, frame/timeScale, FSM state/event, cState, velocity, collider activation, HP before/after, responder and source identities. Static indexing cannot prove runtime equivalence. Do not advertise a whole feature as validated solely because it compiles.

## 9. Enemies and bosses: concrete instances, not imagined classes

Most detailed attack behavior is a combination of serialized FSMs/actions, C# components, animation libraries and arena objects. Searching for `LaceController.cs` is not a reliable starting point. Use `Docs/CombatResearch/data/catalog.json` to select a journal record and **all candidate instances**. Then use a specific instance's source + GameObject fileID + FSM component fileID + state/action index. `entities/<id>.json` holds one selected specimen, not every variant.

Current previously extracted entity source hashes were freshly checked against these six files and matched: MossBone_Fly→Arborium_01, Bone_Hunter→Bone_East_17, Pilgrim_Moss_Spitter→Bonegrave, Mossbone_Mother→Tut_03, Lace→Song_Tower_01, Trobbio→Library_13. A hash match verifies the snapshot's source bytes; it does not verify the prior author's interpretation or runtime behavior.

**Variant trap:** `data/entities/Lace.json` selects `Song_Tower_01.unity / Lace Boss2 New` (HP800 in that specimen), not Lace's first encounter. `parts/bosses-data.json["lace"]` is `Bone_East_12.unity / Lace Boss1`. Likewise, `parts/mobs-data.json` uses tutorial/Ant_04/Mosstown instances different from the canonical entity samples above. Never combine one instance's HP with another's graph/arena geometry without labeling an intentional adaptation.

### 9.1 Six re-opened current graphs

The following graphs were decoded again from current Unity asset blocks; selected transitions/actions were inspected directly. Full earlier exports are useful companions, not substitutes for checking current bindings.

| Reference goal | Current source / owner / FSM component | Verified structure and useful states |
|---|---|---|
| Simple flying drill enemy | `Assets/Scenes/Hornet/Tut_02.unity`, `MossBone Fly`, Control `9893` | 18 states; Idle→Startle→Initiate/Get Above→Attack Antic→Drill/Drill Collide→Drill Recover; separate range, pray and extract paths |
| Mobile melee enemy | `Assets/Scenes/Hornet/Ant_04.unity`, `Bone Hunter`, Control `8121` | 114 states; range-choice, triple slashes, ground/air dash, guard/block, ambush, arena/respawn variants; companion Detect Offscreen `7951` |
| Ranged enemy | `Assets/Scenes/Hornet/Mosstown_01.unity`, `Pilgrim Moss Spitter`, Control `6867` | 36 states; Patrol, Spit Antic, Spit, Wait For Spit Anim, escape/jump/snipe, possess/black-thread/sing paths |
| Basic boss flight and staged attacks | `Assets/Scenes/Hornet/Tut_03.unity`, `Mossbone Mother`, Control `6290`, Stun Control `6008` | 68 main states and 17 stun states; Swoop family, Slam/Rock/Crawler, double-fight branches, special entry/end/extract |
| Complex duelist first encounter | `Assets/Scenes/Hornet/Bone_East_12.unity`, `Lace Boss1`, Control `6175` | 132 main states; distance choice, hop positioning, charge/combo/jump/downstab, counter, cross-slash, multihit and arena/lava behavior |
| Boss with arena/projectiles | `Assets/Prefabs/Hornet Bosses/Trobbio.prefab`, `Trobbio`, Control `114581786255902400` | 144 main states; throw/flurry, flash, flight/drop, tornado/multihit, elaborate entry/death/fake-death; also inspect `Assets/Scenes/Hornet/Library_13.unity` |

Selected facts useful for choosing a reference:

- **MossBone Fly / Idle:** plays Fly, runs IdleBuzzV3, turns with FaceDirection, checks vision and AlertRange; the alert event requires both conditions. `TOOK DAMAGE` can startle. Needolin/performance region reactions coexist with normal sensing. Treat its collision/alert shape as part of behavior, not just a distance threshold.
- **Bone Hunter / Block:** SetInvincible(true, direction=0, resetOnStateExit=true), Block animation, .75 s Wait and DecelerateV2(.8); exits on BLOCKED HIT, TOOK DAMAGE, elapsed time or falling. This shows why invulnerability must be restored on exit and cannot be a permanent class property.
- **Pilgrim Moss Spitter / Spit:** plays Spit and watches `SPIT TRIGGER` separately from completion; initial vertical velocity=19 and child activations coexist with a ground check. Projectile/emission timing must follow the trigger/linked object, not state entry alone. `Wait For Spit Anim` and `Recover` are separate continuations.
- **Mossbone Mother / Move Choice:** reads live HP, can force SWOOP above a threshold, otherwise SendRandomEventV2 selects SLAM/SWOOP with max streaks 1/2 and stored initial trackers. Idle DistanceFlyV2 maintains target-relative distance/height. `Swoop` samples ground Y once, adds 2.2, combines scaled horizontal acceleration with vertical iTween, waits .9 s then enters Swoop Extend. `Slam` explicitly sends FINISHED immediately after starting Smash; it does not wait for the full clip before Drop Type.
- **Lace Boss1 / Distance Check:** compares **GetDistance** against 6. Close uses SendRandomEventV3 and wall-range override; current `J SLASH` transition in Close goes to **Charge Antic**, despite the event name. Charge sets scaled speed80, uses per-tick X damping .89 and a .3 s exit. Counter, Stun, CrossSlash and special hero multi-hit require companion graphs, not only Control.
- **Trobbio / Tornado:** AccelerateToX(.6/tick), wall ray1.7 on terrain layer8, decrements Tornado Time, exits normally only when timer ended **and** X is within Tornado X Min/Max (stored66/82 in inspected prefab variables). MULTI HIT CONNECT is another exit. The arena stage, tornado damager, emission FSM, stun template and bombs must be resolved through Library_13 and actual prefab overrides.

Expanded datasets: [mobs data](../CombatResearch/parts/mobs-data.json), [bosses data](../CombatResearch/parts/bosses-data.json), [boss state reference](../CombatResearch/parts/bosses-state-reference.md), [boss interpretation](../CombatResearch/parts/bosses-ai.md), [special entities](../CombatResearch/parts/specials.md), [unmapped audit](../CombatResearch/parts/unmapped-audit.md). Read only the relevant entry/state; these JSON files are too large to paste in full.

### 9.2 Action semantics that change the fight

- `Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/AccelerateToX.cs`: applies accelerationFactor directly to X velocity on Enter **and each FixedUpdate**, without multiplying by dt; clamps to target. Hero has a special self-velocity/conveyor path.
- `Assets/Scripts/MixedIntegrations/PlayMakerActions/DecelerateXY.cs`: multiplies selected velocity axes on Enter and each FixedUpdate; None leaves an axis alone, explicit zero stops it; brakeOnExit optionally clears selected axes. A value .89 is a per-call multiplier, not a per-second factor.
- `Assets/Scripts/ProjectCode/FSM/01_Project_Actions/Hollow_Knight/CheckAlertRange.cs`: despite HandleFixedUpdate setup, repeated range-delay evaluation is in OnUpdate. Range changes reset the corresponding delay. Read the actual callback, not the category/name.
- `Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/SendRandomEventV3.cs`: combines weighted sampling, consecutive counts, missed counts/forced choice, and a loop fallback. Preserve arrays, initial tracking variables and ordering. It is not independent uniform randomness even when all weights=1. V2 is a different implementation beside it.
- `Assets/PlayMaker/Actions/Physics2D/SetVelocity2d.cs`: scalar/whole-vector values and unused (`IsNone`) axes differ; follow current action code and update flags.
- Animation actions/listeners and `ActivateGameObject` can have resetOnExit behavior. `isSequence=false` is not a serial script that waits for each action; actions can remain active together. Follow the installed PlayMaker behavior and record uncertainties about event reentry/order.

Use `data/fsm-action-implementations.tsv` for the current whole-project action map and `Docs/CombatResearch/data/action_index.json` for the earlier combat-specific source candidates or DLL dependencies. Filename matching alone can be ambiguous. `Assets/Plugins/PlayMaker.dll` contains runtime types; source wrappers do not establish all internal event scheduling details.

### 9.3 Missing actions and recovery caveats

`Docs/CombatResearch/data/known-gaps.json` records three enabled MissingAction instances in the earlier combat export: Lost Lace (`Abyss_Cocoon.unity`, Control/Sing, missing StartSingDuration); Pinstress Boss (`Peak_07.unity`, Control/Throw and G Dash Recover, missing SetRecoilBlockedOnExit). These are evidence of unresolved serialized action instances, even if a similarly named source file now exists. Re-open current state/action and verify binding before claiming recovery. The current whole-project scan additionally found the corresponding two **enabled** MissingAction instances in `Assets/Prefabs/Hornet Enemies/Pinstress Boss.prefab`, Control component `114689364072382846`, `Throw` action[6] and `G Dash Recover` action[6] (zero-based). The hero prefab has two **disabled** MissingAction entries in `ProxyFSM` component `114927647628675231`: `Respawn` action[0] and `Healed Max` action[1], both recorded actionName=`SendEventToRegister`. These four additional entries were decoded directly for this chapter. Thus the earlier file's three entries are not a whole-project total; the current scan identifies seven serialized MissingAction instances, five enabled and two disabled. This is a count of serialized action entries, not seven distinct missing implementations.

The retrieved scripts also include old names, no-op methods and local compatibility changes. Examples: HC.BackDash is empty, while other back-movement states/FSMs exist; NailSlash.PlaySlash and HAC.GetClip use compatible clip lookup and log missing clips. Distinguish current implementation facts from original-release intent. Do not silently repair suspicious recovered behavior and then describe it as verified original behavior.

## 10. Token-efficient queries and verification recipes

Run from the source project root. These are read-only lookup examples; temporary output files are outside the project.

Find a stable code anchor, then read a bounded region rather than all HC:

```sh
rg -n 'private void (LookForQueueInput|Attack|DownAttack)|public void DownspikeBounce|public bool CanDash' Assets/Scripts/ProjectCode/Game/02_Player/HeroController.cs
rg -n 'fsmTemplate:|sprintFSM:|crestAttacksFSM:|configs:' Assets/Prefabs/Heroes/Hero_Hornet.prefab
rg -n 'a14142627197a144586ee7b8abd07265' Docs/AgentReference/data/asset-index.tsv
```

Decode one FSM or external template; preserve variable references and disabled-action status:

```sh
python3 Docs/CombatResearch/tools/fsm_decode.py Assets/PlayMaker/Templates/crest_attacks.asset --compact --output /tmp/crest-attacks.json
python3 Docs/CombatResearch/tools/fsm_decode.py Assets/Scenes/Hornet/Bone_East_12.unity --owner 'Lace Boss1' --fsm Control --compact --output /tmp/lace-first-control.json
```

Extract only the relevant state, including transitions, ordered actions, and variable bindings:

```python
import json
fsms = json.load(open('/tmp/crest-attacks.json'))
for fsm in fsms:
    for state in fsm['states']:
        if state['name'] in {'Rpr Downslash', 'Rpr Downslash Bounce', 'End'}:
            print(json.dumps({'fsm': fsm['name'], 'state': state}, ensure_ascii=False, indent=2))
```

Select all instances before choosing an entity specimen:

```python
import json
catalog = json.load(open('Docs/CombatResearch/data/catalog.json'))
for record in catalog['journal_records']:
    if record['id'] == 'Lace':
        for actor in record['instances']:
            print(actor['source'], actor['name'], actor['game_object_id'], actor['hp'])
```

Resolve a local fileID without loading a million-line scene into context:

```python
from pathlib import Path
import re
text = Path('Assets/Prefabs/Heroes/Hero_Hornet.prefab').read_text()
file_id = '114276157351848250'  # choose a verified ID in this exact asset
match = re.search(r'^--- !u!\d+ &' + re.escape(file_id) + r'[^\n]*\n.*?(?=^--- !u!|\Z)',
                  text, re.M | re.S)
print(match.group(0) if match else 'NOT FOUND: refresh index/asset identity')
```

After finding a GUID, resolve it in asset-index or matching `.meta`; after finding a local fileID, resolve it in **the same asset**. Follow m_GameObject→Transform→parent chain to retain hierarchy. For enemy JSON inspect `components[].serialized_yaml`, `game_objects`, `fsms[].variables` and `source_sha256`; for raw templates inspect the template's variables plus the host component's overrides. Do not treat decoder `{'var': 'X', 'stored': 0}` as constant0, or `{'var': null, ...}` as a selected constant without checking IsNone semantics.

## 11. Review coverage and open work

Review date: 2026-09-18. This chapter was produced by reading current code regions and re-opening current prefab/template/scene evidence. No gameplay files were edited, and no Unity runtime experiment was conducted for this chapter.

**Deep method-level reading:** HC initialization/config selection; Update's attack/downspike/charge paths; full FixedUpdate, DoMovement/Move/Jump/DoubleJump/Attack/DownAttack/Dash; input and movement gates; wall entry/jump; control handoff; tool dispatch; rebound; TakeDamage/parry/recoil/invulnerability; Die/DieFromHazard; setup/facing/filtering and relevant cancellation endpoints. HC's delivery quests, full scene-transition/respawn coroutines, all status-effect branches, full currency/save methods and every remaining utility branch were **not** exhaustively reviewed here.

**Complete small/medium files read:** HeroActions, HeroAudioController, NailSlash, HeroControllerConfig, HeroControllerConfigWarrior, HeroSlashBounceConfig, NailAttackBase, Downspike, HeroDownAttack, NailSlashRecoil, DamageHero, IHitResponder, HitTaker, CustomPlayerLoop, DamageEnemiesCallbackHooks, CheckAlertRange, AccelerateToX, DecelerateXY, SendRandomEventV3. **Focused regions read:** DamageEnemies (initialization, contacts, late evaluation, damage construction/buffer/end), HealthManager (Hit/block/scaling/TakeDamage/immunity/stun/Die), HeroBox, HAC (selection/events/lookup), InputHandler setup + symbol map, InputSystem/InputManager.GetActionMap and PlayerActions.PlayerActionSet construction, ToolItemManager equipment/event/binding/replenishment/AutoEquip paths and ToolItem/ToolCrest unlocks, Recoil physics, tk2d animation update/events. HitInstance/AttackTypes were read for contract and direction semantics. HeroControllerStates invulnerability-source/reflection/reset methods were additionally inspected; its broader field surface and remaining player/combat source families are indexed, not all independently behavior-reviewed.

**Fresh serialized evidence:** hero prefab's HC constants/config array/FSM links and selected root/attack/physics components; all eight hero config assets; default Knight animation clips above; complete state-name scans of nine hero templates with selected move/control/damage-bridge actions inspected; six current enemy/boss Control graphs decoded with selected states re-read (§9.1). Remaining actor variants are discoverable through the whole-project indexes and prior CombatResearch exports, but are not all deeply reinterpreted in this chapter.

**Before claiming complete feature parity, still resolve:** runtime PlayMaker event scheduling/reentry and legacy variable coercion; nested/template overrides on the selected live instance; animation/physics ordering at render-rate variation; dynamic spawns/global variables; complete resource dependency closure including shaders/audio/mixers; active MissingAction behavior; available imported assets; actual in-editor ability/progression setup; all selected move cancellation/death/retry paths. Static source/hash coverage and semantic understanding are separate evidence levels.
