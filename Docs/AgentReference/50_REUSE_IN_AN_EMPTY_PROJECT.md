# 50 — Reuse in an initially empty Unity project

This chapter defines how the next agent should turn a user request into a small, correct implementation using the reference. It is an implementation procedure, not a claim that a new playable game has already been produced.

## 50.1 Keep reference and target identities explicit

The reference root is the directory containing this pack and `Assets/Scripts/ProjectCode/`. The target root is the user's new game. Resolve both once per task. Paths inside this pack always name the reference unless labeled otherwise. Place the target implementation and target evidence in the target project.

Use the current user's design and target constraints to choose the feature. Follow direct source/configuration evidence before reproducing defaults from prose. Preserve reference hashes and identities in the handoff so future agents can return to the same implementation without repeating discovery.

## 50.2 Build a feature packet before transplanting dependencies

For the selected feature, fill these fields with precise evidence:

| Field | Required evidence |
|---|---|
| Behavior | Input/trigger, preconditions, resulting state, cancellation, completion, repeat behavior |
| Reference instance | Source path, GO fileID, component fileIDs, prefab/template identity and variant |
| Entry and logic | Class/method/overload; caller, lifecycle, inherited action behavior, relevant branches |
| Configuration | Actual serialized fields and referenced data asset, effective crest/equipment/difficulty overrides |
| State machine | FSM/template names, variables, state/action order, event transitions, owner/target bindings |
| Time | Update loop, fixed/render frame relationship, animation fps/events, timers, freeze/time scale |
| Geometry | Transform spaces, pivots, collider shape/offset/size, rigidbody, layers/masks and parent hierarchy |
| Presentation | Clip/library/collection, frame events, sprites, materials/shaders, particles, sounds, mixer routes |
| Services | Input, player data, game manager, camera, pool, audio, FSM/global events, localization, save hooks |
| Lifecycle | Creation, initialization, enable, reuse, disable, scene unload, save/load, disposal |
| Target boundary | What is reused verbatim, adapted, represented by a small interface, or intentionally deferred |
| Verification | Observable success criteria; reference evidence versus actual target runtime tests |

This packet is the unit of future reuse. Do not copy a large generic study chapter into each task; copy the exact packet and links for the feature being implemented.

## 50.3 Dependency closure: determine what must travel together

Start at the actual component instance and expand until each dependency is accounted for:

1. **Compile dependencies:** declared types/base classes/interfaces/extensions, namespaces, package/assembly references and conditional compilation.
2. **Serialized dependencies:** script GUID + subobject fileID; fields; attached components; hierarchy; external resources. Follow outbound GUID edges one hop at a time.
3. **Dynamic dependencies:** strings, global FSM variables, scene gates, tags/layers, named children, Resources/Addressables, reflection and animation callbacks.
4. **Behavior dependencies:** scheduling, event subscriptions, pooled initialization/reset, manager readiness, actual parameter overrides.
5. **Engine dependencies:** physics, render pipeline, input backend, sorting layers, import settings, default execution order.

Classify each discovered dependency as `required now`, `replaceable contract`, `presentation optional for this milestone`, or `later feature`. State why. Stop expanding when every edge needed for the selected behavior has a target implementation or an explicit deferred contract. This avoids importing all historical managers to make one attack work while still preserving the dependencies that determine that attack's behavior.

A data-only reference can still be a behavioral dependency: a tk2d clip carries the attack-window events; a crest asset changes attack objects; a music snapshot changes the mix; an FSM variable selects a target; a scene's collider determines valid movement.

## 50.4 Recommended construction order

Adapt the following sequence to the user's requested game; this is a dependency-aware order, not a mandatory schedule.

| Stage | Small deliverable | Read / establish | Observable completion |
|---|---|---|---|
| 0. Foundation | One empty room with explicit scale, camera and collision | Engine/input/render/physics settings; chosen minimal service boundaries | Starts cleanly; consistent world scale and collision; no accidental reference-project singleton assumptions |
| 1. Locomotion | Run, jump, fall, land and basic wall interaction | Player config and update order; selected animation/physics chain | Reproducible movement trajectory, input buffering/cancellation and contact handling at varied frame rates |
| 2. One attack | One attack against one target | Slash/Downspike/DamageEnemies/HealthManager; exact hitbox and event timing | Active window, one-hit policy, damage/knockback/hit stop and recovery match the selected contract |
| 3. Damage loop | Contact damage, invulnerability, death and respawn | HeroBox, damage queues, death FSM, respawn data | Simultaneous hits/overlap do not double-apply incorrectly; respawn restores controllable state |
| 4. One enemy | A chosen small enemy with its real behavior | Actual scene instance; FSM/template/actions; pool and death handling | Telegraph/attack/recovery cycles and second spawn behave correctly |
| 5. Connected rooms | Two rooms, gates, camera regions and persistent objects | Scene lifecycle, tilemap/terrain contract, transition points, save keys | Correct gate/position, camera bounds, unload cleanup and re-entry state |
| 6. Presentation | Selected environment layering, animation, VFX, sound/music | Rendering/resource chains and audio routing | Visual layers and collision agree; animation and audio cues occur at intended events |
| 7. Progression | One ability unlock or tool/crest; checkpoint/save | Manager/data definitions, pickup/quest sequence and queued persistence | Reload preserves the intended unlock/equipment and no state is granted twice |
| 8. Boss slice | One arena and one selected encounter variant | Full FSM phases, arena/event gates, projectiles, camera/music and reset | Win/death/retry all clean up; phase transitions have explicit evidence |
| 9. Broader game | Additional content, UI/map/localization, quests/economy | Add each subsystem through its own feature packet | Each increment is tested and indexed in the target project |

“Looks similar” is not a substitute for a recorded behavior contract. Where no runtime reference recording exists, state that parameters/logic came from static source/configuration and tune/test in the target without presenting that tuning as a measured original.

## 50.5 Resource migration choices

- **Keep `.meta` with copied source/resources** when preserving their serialized GUID relationships. Check for GUID collisions with target content first. If identities are deliberately regenerated, remap every dependent reference rather than leaving partial links.
- **Unity asset identity includes subobjects.** Materials, sprite collections, atlas sprites, clips, DLL scripts and mixers may use distinct fileIDs under one GUID.
- **Copy the actual selected config.** Defaults in a C# initializer may differ from serialized fields, crest selections, prefab variants, scene overrides and runtime modifications.
- **Separate source behavior from recovery fixes.** A patched input adapter, custom save codec, restored shader, repaired tilemap or research scene is the current project's implementation; decide whether its target role is needed.
- **Choose a render pipeline deliberately.** This reference snapshot has Built-in rendering configuration. Adopting URP entails validating shaders, transparency, sorting, lighting and post-effects in that pipeline.
- **Choose an animation representation deliberately.** Converting tk2d data into Unity Animator or another system must preserve frame events, fps, looping, clip changes, root/child transforms and combat callbacks.
- **Preserve audio behavior, not only clips.** Pitch/volume variation, positioning, event timing, loop lifecycle, pooling and snapshot/channel changes are part of the reference behavior.

Use the target's own asset authoring and organization as it evolves; keep a small reference mapping rather than repeatedly renaming/restoring imported assets with no provenance.

## 50.6 Feature-specific verification

Use checks that catch behavioral integration errors:

| Feature | Check |
|---|---|
| Movement | Press/hold/release cases; edge/wall/ceiling contact; buffered input; pause/unpause; several render rates |
| Attack | First/last active frame; target with multiple colliders; repeated overlap; swing cancellation; crest/attack-direction change |
| Downspike | Airborne/falling preconditions, terrain/enemy/parry response, rebound velocity and repeated contacts |
| Damage | Two contacts in the same physics cycle; invulnerability; healing/damage interaction; disable/recycle/death during callbacks |
| Pool | First spawn, second spawn, recycle while active, scene unload, missing optional effect, no stale hit/animation/audio state |
| Enemy/Boss | Activation distance, phase thresholds, arena locks, target loss, death/reset/retry, projectile cleanup |
| Scene | Exit and entry gate pair, async completion order, player position, camera lock, persistent object identity |
| Visuals | Sorting layer/order/Z, parent transforms, sprite pivot/scale, material/shader and texture import behavior |
| Audio | Event timing, mixer group/snapshot, loop stop/release, music/atmos transitions and volume settings |
| Save/progression | Queue versus actual write; completion callback; reload; already-collected/quest-completed state; invalid/missing optional data |

For each check, record whether it was a static assertion, target Editor observation, automated test, or comparison to an actual reference run. Passing compilation establishes only type/linkage compatibility.

## 50.7 Compact future-agent handoff template

```text
Feature:
Target root and current milestone:
Reference snapshot / changed source hashes:
Reference source symbols:
Reference source + object/component IDs:
FSM/template + state/action route:
Effective values and resource bindings:
Required dependency closure:
Target files and identity remaps:
Implementation differences and reasons:
Verification performed and result:
Unverified cases / next exact retrieval step:
```

The target project should maintain its own current architecture and feature map. This reference remains a source of evidence; new game's changed behavior should not silently overwrite descriptions of the reference behavior.
