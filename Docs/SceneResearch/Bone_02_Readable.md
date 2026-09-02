# Bone_02 可读场景（Phase 0 + Phase 1）

> 生成时间：2026-09-02 15:14:15 UTC  
> 源场景：`Assets/Scenes/Hornet/Bone_02.unity`  
> 可读副本：`Assets/Scenes/Hornet/Bone_02_Readable.unity`  
> 源场景 SHA-256：`4f8d37c73d9bcc20f49f92a9b6793f91833b4ca9f0187b81bd6a1a741e4db3d8`

这是研究用整理副本，不代表 Team Cherry 原始 Hierarchy 或 Prefab 结构。本阶段没有创建或重连 Prefab，也没有移动任何带脚本、Collider、Rigidbody、Animator、ParticleSystem 或 AudioSource 的根树。另有一小批特殊 Layer/命名的纯视觉树被保守留在根层，列入 ManualReview。

## 结果

| 指标 | 原场景 | 可读副本 |
| --- | ---: | ---: |
| 原有 GameObject | 2215 | 2215 |
| 整理目录 GameObject | 0 | 7 |
| GameObject 总数 | 2215 | 2222 |
| Scene Root 数量 | 570 | 175 |
| 移入 `_00_ART` 的静态视觉根树 | 0 | 396 |
| 保守留根、等待人工确认的纯视觉树 | 19 | 19 |
| Missing Script | 0 | 0 |

验证结果：**PASS**。原对象数量、组件、引用、世界矩阵、内部子节点顺序、SpriteRenderer 设置均保持不变。

## 新层级

```text
_00_ART
├─ 00_Background (54)
├─ 10_Midground (48)
├─ 20_Architecture (152)
├─ 30_Foreground (48)
├─ 40_Fog_Haze (31)
├─ 50_Masks (63)
```

分类规则是确定性的：以对象名和 Sprite 名为主，世界 Z 只辅助判断名称含 `deep` 的散落视觉根。无法可靠推断语义的对象默认进入 `20_Architecture`。现有多节点视觉树始终整体移动，不拆子节点，也不改名或改组件。

## 明确保留在 Scene Root 的对象

- `TileMap`、`TileMap Render Data`
- `_SceneManager`、`_Managers`、`Music Control`
- 所有敌人、活动机关、PlayMaker FSM、Rigidbody2D、Damage/Breakable 根对象
- Black Thread、Rock Roller、Chain Drop Platform 等复杂 set piece

这些对象没有放进共享父节点，因为工程逻辑会使用 `transform.root`、直接父节点或固定子节点名。`TileMap` 也必须维持 Scene Root，供 `GameManager.RefreshTilemapInfo` 的主路径发现。

## Unity 中查看

1. 打开 `Assets/Scenes/Hornet/Bone_02_Readable.unity`。
2. 展开 `_00_ART`；六个子目录分别对应背景、中景、建筑、前景、雾霭和遮罩。
3. 使用 Hierarchy 左侧眼睛图标临时隐藏某个目录，观察该视觉层在 Scene View 中的作用。
4. 需要核对恢复前结构时，同时参考只读源场景 `Bone_02.unity`；不要把可读副本当作原始 Prefab 证据。
5. 修改副本后，可执行 `Tools > Scene Research > Bone 02 > Validate Readable Copy` 重新验证 Phase 1 不变量。

## 自动验证范围

- 每个原 GameObject 的 scene localID 仍存在
- Active、Layer、Tag、Static Flags 不变
- Component 类型、顺序以及除 Transform 层级外的全部序列化字段哈希不变；字段基线来自同一 Unity 6 版本临时规范化并重开的源副本，仅新增目录 Transform
- 所有序列化 ObjectReference 的目标不变
- Local Transform 与世界矩阵不变
- 原有直接子节点及顺序不变
- Sprite、材质、颜色、Sorting Layer/Order、Flip、Draw Mode、Mask 设置不变
- `TileMap` 和保守管理对象仍为 Scene Root
- RenderSettings、LightmapSettings 与 LightingSettings 引用不变
- 研究副本使用独立 GUID，且清空继承来的 legacy AssetBundle 名称

## 已知恢复数据边界

源 YAML 的 `tk2dTileMap` 含 10 段 `spriteIds` typeless-data，其中共有 7,533 个非十六进制字符 `/`。Unity 6 保存派生副本时会把这些字符规范化成 `0`；若 `/` 原本应为 `f`，它们本应组成 `-1` 空 Tile 哨兵。因此，本报告的严格字段比较证明的是‘同一 Unity 6.5（6000.5.4f1）规范化解释下，层级整理没有引入额外数据变化’，并不证明恢复源文本与原游戏 TileMap 数据逐字节等价。

本阶段保留源场景及其 SHA-256，不在层级整理中顺带修复 TileMap。若后续需要编辑或查询 TileMap，应另建派生副本，专项恢复 `/`→`f` 并验证 tile 查询、持久网格与碰撞结果。

## ManualReview（本阶段未移动）

- `cairn_medium (2)` — Layer 19 (Interactive Object)，5 GameObject，localID `953`
- `Boneforest_breakables_0015_4 (5)` — Name suggests a state-dependent breakable visual，1 GameObject，localID `170`
- `Boneforest_breakables_0015_4 (3)` — Name suggests a state-dependent breakable visual，1 GameObject，localID `486`
- `Boneforest_breakables_0015_4 (4)` — Name suggests a state-dependent breakable visual，1 GameObject，localID `896`
- `Boneforest_breakables_0015_4 (1)` — Name suggests a state-dependent breakable visual，1 GameObject，localID `1104`
- `Boneforest_breakables_0015_4` — Name suggests a state-dependent breakable visual，1 GameObject，localID `1107`
- `Boneforest_breakables_0002_17` — Name suggests a state-dependent breakable visual，1 GameObject，localID `1127`
- `char_grass_sil (20)` — Layer 21 (Grass)，3 GameObject，localID `1475`
- `char_grass_sil (6)` — Layer 21 (Grass)，3 GameObject，localID `1489`
- `char_grass_sil (1)` — Layer 21 (Grass)，5 GameObject，localID `1486`
- `char_grass_sil (17)` — Layer 21 (Grass)，3 GameObject，localID `1431`
- `char_grass_sil (26)` — Layer 21 (Grass)，2 GameObject，localID `1459`
- `char_grass_sil (7)` — Layer 21 (Grass)，3 GameObject，localID `1458`
- `char_grass_sil (11)` — Layer 21 (Grass)，3 GameObject，localID `1552`
- `char_grass_sil` — Layer 21 (Grass)，3 GameObject，localID `1551`
- `char_grass_sil (2)` — Layer 21 (Grass)，3 GameObject，localID `1549`
- `char_grass_sil (16)` — Layer 21 (Grass)，3 GameObject，localID `1532`
- `char_grass_sil (13)` — Layer 21 (Grass)，3 GameObject，localID `1512`
- `Vignette Cutout` — Vignette/Over-layer scene presentation object，1 GameObject，localID `1854`

## 移动清单

<details><summary>00_Background（54 个根树）</summary>

- `bone_BG_03 (36)` — 1 GameObject，localID `43`
- `bone_deep_0206_o (7)` — 1 GameObject，localID `165`
- `bone_BG_03 (20)` — 1 GameObject，localID `174`
- `bone_deep_0206_o (3)` — 1 GameObject，localID `218`
- `bone_BG_03 (35)` — 1 GameObject，localID `223`
- `bone_BG_03 (32)` — 1 GameObject，localID `231`
- `bone_BG_03 (33)` — 1 GameObject，localID `300`
- `bone_BG_03 (23)` — 1 GameObject，localID `309`
- `bone_BG_03 (27)` — 1 GameObject，localID `343`
- `bone_BG_03 (39)` — 1 GameObject，localID `364`
- `bone_BG_03 (17)` — 1 GameObject，localID `406`
- `bone_BG_03 (5)` — 1 GameObject，localID `463`
- `bone_BG_03 (9)` — 1 GameObject，localID `465`
- `bg_plank_plat (1)` — 4 GameObject，localID `511`
- `Bone_Statues_0001_1 (3)` — 1 GameObject，localID `520`
- `bone_deep_0206_o (5)` — 1 GameObject，localID `631`
- `bone_BG_03 (37)` — 1 GameObject，localID `648`
- `Bone_Statues_0001_1 (6)` — 1 GameObject，localID `710`
- `Bone_Statues_0001_1` — 1 GameObject，localID `721`
- `bone_deep_0145_u_bg (3)` — 1 GameObject，localID `723`
- `bone_BG_03 (13)` — 1 GameObject，localID `757`
- `bone_BG_03 (30)` — 1 GameObject，localID `810`
- `bone_BG_03 (11)` — 1 GameObject，localID `811`
- `bone_deep_0206_o (8)` — 1 GameObject，localID `820`
- `bone_BG_03 (28)` — 1 GameObject，localID `830`
- `bone_BG_03 (31)` — 1 GameObject，localID `842`
- `bone_BG_03 (3)` — 1 GameObject，localID `863`
- `bone_BG_03 (15)` — 1 GameObject，localID `875`
- `bone_BG_03 (25)` — 1 GameObject，localID `950`
- `bone_deep_0206_o (1)` — 1 GameObject，localID `963`
- `bone_deep_0206_o (4)` — 1 GameObject，localID `966`
- `collapse_chunk__0000_bone1 (6)` — 1 GameObject，localID `983`
- `bone_BG_03 (26)` — 1 GameObject，localID `994`
- `bone_BG_03 (8)` — 1 GameObject，localID `1001`
- `bone_BG_03 (10)` — 1 GameObject，localID `1012`
- `bone_BG_03 (16)` — 1 GameObject，localID `1026`
- `bg_plank_plat` — 4 GameObject，localID `1071`
- `bone_BG_03 (12)` — 1 GameObject，localID `1110`
- `bone_BG_03 (21)` — 1 GameObject，localID `1118`
- `bone_BG_03 (4)` — 1 GameObject，localID `1123`
- `bone_BG_03 (18)` — 1 GameObject，localID `1143`
- `bone_BG_03 (34)` — 1 GameObject，localID `1172`
- `bone_BG_03 (29)` — 1 GameObject，localID `1173`
- `bone_deep_0206_o (2)` — 1 GameObject，localID `1198`
- `bone_BG_03 (22)` — 1 GameObject，localID `1217`
- `bone_deep_0206_o` — 1 GameObject，localID `1226`
- `bone_BG_03 (40)` — 1 GameObject，localID `1233`
- `bone_BG_03 (14)` — 1 GameObject，localID `1234`
- `bone_BG_03 (6)` — 1 GameObject，localID `1276`
- `Bone_Statues_0001_1 (7)` — 1 GameObject，localID `1297`
- `bone_BG_03 (38)` — 1 GameObject，localID `1300`
- `bone_BG_03 (19)` — 1 GameObject，localID `1304`
- `bone_BG_03 (2)` — 1 GameObject，localID `1365`
- `bone_BG_03 (24)` — 1 GameObject，localID `1409`

</details>

<details><summary>10_Midground（48 个根树）</summary>

- `bone_deep_0142_i (58)` — 1 GameObject，localID `18`
- `boneforest_mid_wall_0002_2 (29)` — 1 GameObject，localID `100`
- `boneforest_mid_wall_0002_2 (40)` — 1 GameObject，localID `156`
- `boneforest_mid_wall_0002_2 (36)` — 1 GameObject，localID `158`
- `boneforest_mid_wall_0002_2 (30)` — 1 GameObject，localID `179`
- `bone_mid_plat_float (2)` — 1 GameObject，localID `187`
- `boneforest_mid_wall_0002_2 (31)` — 1 GameObject，localID `202`
- `bone_deep_0142_i (26)` — 1 GameObject，localID `239`
- `bone_deep_0206_o (12)` — 1 GameObject，localID `252`
- `bone_deep_0142_i (57)` — 1 GameObject，localID `311`
- `bone_deep_0142_i (49)` — 1 GameObject，localID `412`
- `boneforest_mid_wall_0002_2 (25)` — 1 GameObject，localID `415`
- `boneforest_mid_wall_0002_2 (34)` — 1 GameObject，localID `430`
- `boneforest_mid_wall_0002_2 (38)` — 1 GameObject，localID `479`
- `boneforest_mid_wall_0002_2 (37)` — 1 GameObject，localID `592`
- `bone_deep_0206_o (9)` — 1 GameObject，localID `651`
- `boneforest_mid_wall_0002_2 (39)` — 1 GameObject，localID `677`
- `boneforest_mid_wall_0002_2 (44)` — 1 GameObject，localID `687`
- `boneforest_mid_wall_0002_2 (23)` — 1 GameObject，localID `690`
- `bone_deep_0206_o (11)` — 1 GameObject，localID `694`
- `boneforest_mid_wall_0002_2 (22)` — 1 GameObject，localID `782`
- `bone_deep_0142_i (50)` — 1 GameObject，localID `834`
- `bone_deep_0146_u (74)` — 1 GameObject，localID `851`
- `bone_deep_0206_o (10)` — 1 GameObject，localID `854`
- `Hornet_Core__0058_bone_52 (6)` — 1 GameObject，localID `857`
- `bone_deep_0146_u (73)` — 1 GameObject，localID `862`
- `bone_deep_0142_i (18)` — 1 GameObject，localID `882`
- `bone_deep_0146_u (72)` — 1 GameObject，localID `900`
- `boneforest_mid_wall_0002_2 (10)` — 1 GameObject，localID `910`
- `bone_mid_plat_float (1)` — 1 GameObject，localID `917`
- `boneforest_mid_wall_0002_2 (35)` — 1 GameObject，localID `921`
- `bone_deep_0206_o (13)` — 1 GameObject，localID `967`
- `bone_deep_0206_o (6)` — 1 GameObject，localID `968`
- `boneforest_mid_wall_0002_2 (24)` — 1 GameObject，localID `1017`
- `boneforest_mid_wall_0002_2 (33)` — 1 GameObject，localID `1096`
- `boneforest_mid_wall_0002_2 (27)` — 1 GameObject，localID `1108`
- `bone_deep_0142_i (25)` — 1 GameObject，localID `1137`
- `boneforest_mid_wall_0002_2 (43)` — 1 GameObject，localID `1191`
- `bone_mid_plat_float` — 1 GameObject，localID `1224`
- `boneforest_mid_wall_0002_2 (26)` — 1 GameObject，localID `1225`
- `bone_deep_0142_o (6)` — 1 GameObject，localID `1231`
- `boneforest_mid_wall_0002_2 (32)` — 1 GameObject，localID `1263`
- `boneforest_mid_wall_0002_2 (42)` — 1 GameObject，localID `1270`
- `boneforest_mid_wall_0002_2 (28)` — 1 GameObject，localID `1286`
- `boneforest_mid_wall_0002_2 (41)` — 1 GameObject，localID `1287`
- `big_bone_mid_wall` — 4 GameObject，localID `1566`
- `boneforest_mid_wall (7)` — 91 GameObject，localID `1511`
- `boneforest_mid_wall (6)` — 28 GameObject，localID `1488`

</details>

<details><summary>20_Architecture（152 个根树）</summary>

- `Bone_inner_arch_white` — 1 GameObject，localID `907`
- `sc arch set` — 14 GameObject，localID `25`
- `Bone_rubble_short (3)` — 1 GameObject，localID `31`
- `Bone_corners_0002_2 (34)` — 1 GameObject，localID `41`
- `bone_deep_0146_u (71)` — 1 GameObject，localID `42`
- `Bone_corners_0002_2 (24)` — 1 GameObject，localID `49`
- `Bone_spikes_0003_2 (12)` — 1 GameObject，localID `55`
- `spine corridor` — 21 GameObject，localID `283`
- `Bone_spikes_0003_2 (11)` — 1 GameObject，localID `60`
- `Bone_corners_0002_2 (17)` — 1 GameObject，localID `62`
- `shellwood_large_doors_0000_1` — 1 GameObject，localID `65`
- `Bone_rubble_short (7)` — 1 GameObject，localID `79`
- `Bone_corners_0002_2 (9)` — 1 GameObject，localID `87`
- `Bone_inner_arch_white (4)` — 1 GameObject，localID `94`
- `shellwood_large_doors_0000_1 (2)` — 1 GameObject，localID `102`
- `Bone_floor_02` — 1 GameObject，localID `107`
- `Bone_inner_arch_white (6)` — 1 GameObject，localID `108`
- `Bone_rubble_short (13)` — 1 GameObject，localID `111`
- `Bone_spikes_0003_2 (4)` — 1 GameObject，localID `114`
- `Bone_inner_arch_white (8)` — 1 GameObject，localID `118`
- `Bone_corners_0002_2 (8)` — 1 GameObject，localID `120`
- `Bone_rubble_short (37)` — 1 GameObject，localID `131`
- `Bone_floor_02 (2)` — 1 GameObject，localID `141`
- `shellwood_large_doors_0000_1_orb (3)` — 1 GameObject，localID `152`
- `Bone_rubble_short (30)` — 1 GameObject，localID `161`
- `Bone_corners_0002_2` — 1 GameObject，localID `200`
- `bone_deep_0142_i (73)` — 1 GameObject，localID `201`
- `Bonechurch_01_floor_02 (2)` — 9 GameObject，localID `540`
- `Hornet_bone_rubble (5)` — 1 GameObject，localID `215`
- `Bone_rubble_short (38)` — 1 GameObject，localID `237`
- `dock_cap_end` — 1 GameObject，localID `243`
- `Coral_Stone_0002_wall_mid_large (16)` — 1 GameObject，localID `266`
- `Bone_rubble_short (25)` — 1 GameObject，localID `270`
- `dock_cap_end (4)` — 1 GameObject，localID `273`
- `Bone_corners_0002_2 (22)` — 1 GameObject，localID `313`
- `dock_arch (1)` — 1 GameObject，localID `320`
- `bone_deep_0142_i (54)` — 1 GameObject，localID `324`
- `Bone_inner_arch_white (13)` — 1 GameObject，localID `340`
- `shellwood_large_doors_0000_1_orb (1)` — 1 GameObject，localID `347`
- `bone_deep_0145_u (8)` — 1 GameObject，localID `349`
- `Bone_corners_0002_2 (6)` — 1 GameObject，localID `351`
- `Hornet_bone_rubble (2)` — 1 GameObject，localID `359`
- `Bone_corners_0002_2 (25)` — 1 GameObject，localID `365`
- `Bone_spikes_0003_2 (6)` — 1 GameObject，localID `383`
- `Bonechurch_01_floor (4)` — 9 GameObject，localID `387`
- `Bone_rubble_short (34)` — 1 GameObject，localID `399`
- `Bonechurch_01_floor (8)` — 1 GameObject，localID `437`
- `Bone_corners_0002_2 (35)` — 1 GameObject，localID `461`
- `Bone_rubble_short (17)` — 1 GameObject，localID `504`
- `Bone_rubble_short (6)` — 1 GameObject，localID `505`
- `Bone_rubble_short (31)` — 1 GameObject，localID `509`
- `Bone_spikes_0003_2 (9)` — 1 GameObject，localID `522`
- `Bonechurch_01_floor (6)` — 1 GameObject，localID `526`
- `Bone_rubble_short (15)` — 1 GameObject，localID `537`
- `Bone_rubble_short (36)` — 1 GameObject，localID `548`
- `dock_arch` — 1 GameObject，localID `550`
- `Bone_spikes_0003_2 (3)` — 1 GameObject，localID `558`
- `Bone_inner_arch_white (12)` — 1 GameObject，localID `564`
- `Bone_inner_arch_white (15)` — 1 GameObject，localID `566`
- `Bone_inner_arch_white (1)` — 1 GameObject，localID `570`
- `Bone_corners_0002_2 (30)` — 1 GameObject，localID `584`
- `Bone_corners_0002_2 (4)` — 1 GameObject，localID `591`
- `Bone_inner_arch_white (18)` — 1 GameObject，localID `621`
- `Hornet_Core__0023_bone_25 (2)` — 1 GameObject，localID `641`
- `Bone_inner_arch_white (5)` — 1 GameObject，localID `650`
- `shellwood_large_doors_0000_1_orb` — 1 GameObject，localID `665`
- `Bone_corners_0002_2 (23)` — 1 GameObject，localID `671`
- `Bone_corners_0002_2 (28)` — 1 GameObject，localID `676`
- `Bone_rubble_short (41)` — 1 GameObject，localID `682`
- `Bone_rubble_short (24)` — 1 GameObject，localID `688`
- `Bone_corners_0002_2 (26)` — 1 GameObject，localID `691`
- `Bone_corners_0002_2 (31)` — 1 GameObject，localID `697`
- `Bone_rubble_short (43)` — 1 GameObject，localID `702`
- `shellwood_large_doors_0000_1 (1)` — 1 GameObject，localID `715`
- `Bone_rubble_short (16)` — 1 GameObject，localID `719`
- `Bone_inner_arch_white (17)` — 1 GameObject，localID `725`
- `Bone_rubble_short (29)` — 1 GameObject，localID `746`
- `Bone_spikes_0003_2 (5)` — 1 GameObject，localID `763`
- `Bone_rubble_short (14)` — 1 GameObject，localID `764`
- `Bone_rubble_short (42)` — 1 GameObject，localID `769`
- `Bonechurch_01_floor (5)` — 1 GameObject，localID `774`
- `Bone_corners_0002_2 (3)` — 1 GameObject，localID `780`
- `bone_rubble_wall (1)` — 4 GameObject，localID `794`
- `Bone_spikes_0003_2 (10)` — 1 GameObject，localID `804`
- `Bone_rubble_short (45)` — 1 GameObject，localID `815`
- `Bone_rubble_short (21)` — 1 GameObject，localID `853`
- `SC_0050_sc_cap_01` — 1 GameObject，localID `868`
- `Bone_corners_0001_3 (1)` — 1 GameObject，localID `890`
- `Bone_rubble_short (11)` — 1 GameObject，localID `892`
- `Bone_spikes_0003_2 (2)` — 1 GameObject，localID `897`
- `Hornet_bone_rubble (4)` — 1 GameObject，localID `899`
- `Coral_Stone_0002_wall_mid_large (19)` — 1 GameObject，localID `901`
- `Bonechurch_01_floor (7)` — 1 GameObject，localID `904`
- `Bone_rubble_short (39)` — 1 GameObject，localID `909`
- `Hornet_bone_rubble (6)` — 1 GameObject，localID `916`
- `Coral_Stone_0002_wall_mid_large (17)` — 1 GameObject，localID `933`
- `Bone_spikes_0003_2 (13)` — 1 GameObject，localID `935`
- `bone_deep_0142_i (55)` — 1 GameObject，localID `937`
- `Bone_spikes_0003_2 (14)` — 1 GameObject，localID `945`
- `Hornet_bone_rubble (1)` — 1 GameObject，localID `972`
- `Bone_spikes_0003_2 (7)` — 1 GameObject，localID `975`
- `Bone_inner_arch_white (9)` — 1 GameObject，localID `980`
- `Bone_rubble_short (20)` — 1 GameObject，localID `995`
- `Bone_corners_0002_2 (33)` — 1 GameObject，localID `1000`
- `Bone_corners_0002_2 (11)` — 1 GameObject，localID `1013`
- `Bone_rubble_short (1)` — 1 GameObject，localID `1025`
- `Bone_spikes_0003_2 (8)` — 1 GameObject，localID `1030`
- `Bone_corners_0002_2 (1)` — 1 GameObject，localID `1048`
- `Bone_inner_arch_white (7)` — 1 GameObject，localID `1056`
- `bone_rubble_wall` — 8 GameObject，localID `1074`
- `bone_deep_0146_u (70)` — 1 GameObject，localID `1083`
- `Bone_inner_arch_white (14)` — 1 GameObject，localID `1094`
- `Bone_rubble_short (33)` — 1 GameObject，localID `1099`
- `Bone_rubble_short (44)` — 1 GameObject，localID `1135`
- `Bone_corners_0002_2 (29)` — 1 GameObject，localID `1142`
- `Bone_inner_arch_white (11)` — 1 GameObject，localID `1148`
- `shellwood_large_doors_0000_1_orb (2)` — 1 GameObject，localID `1150`
- `Bone_rubble_short (40)` — 1 GameObject，localID `1155`
- `Bone_corners_0002_2 (7)` — 1 GameObject，localID `1169`
- `Coral_Stone_0002_wall_mid_large (12)` — 1 GameObject，localID `1174`
- `Hornet_Core__0023_bone_25` — 1 GameObject，localID `1177`
- `Bone_rubble_short (35)` — 1 GameObject，localID `1205`
- `Bone_spikes_0003_2` — 1 GameObject，localID `1208`
- `Bone_corners_0002_2 (27)` — 1 GameObject，localID `1228`
- `Bone_spikes_0003_2 (1)` — 1 GameObject，localID `1243`
- `Hornet_Core__0023_bone_25 (3)` — 1 GameObject，localID `1264`
- `Bone_corners_0002_2 (16)` — 1 GameObject，localID `1274`
- `Bone_rubble_short (22)` — 1 GameObject，localID `1275`
- `bone_deep_0142_i (47)` — 1 GameObject，localID `1282`
- `Bone_rubble_short (10)` — 1 GameObject，localID `1293`
- `Hornet_Core__0023_bone_25 (1)` — 1 GameObject，localID `1295`
- `Coral_Stone_0002_wall_mid_large (18)` — 1 GameObject，localID `1302`
- `Bone_rubble_short (32)` — 1 GameObject，localID `1309`
- `Bone_inner_arch_white (16)` — 1 GameObject，localID `1341`
- `bone_deep_0140_p` — 1 GameObject，localID `1343`
- `Bone_rubble_short (19)` — 1 GameObject，localID `1350`
- `sc arch set (1)` — 7 GameObject，localID `1358`
- `Bone_inner_arch_white (10)` — 1 GameObject，localID `1362`
- `Bone_corners_0002_2 (5)` — 1 GameObject，localID `1384`
- `Bone_corners_0002_2 (2)` — 1 GameObject，localID `1386`
- `Bonechurch_01_floor (12)` — 23 GameObject，localID `1388`
- `gold_spike_fence (1)` — 6 GameObject，localID `1653`
- `bone_rubble (2)` — 5 GameObject，localID `1467`
- `bone_rubble` — 13 GameObject，localID `1471`
- `bone_rubble (1)` — 7 GameObject，localID `1477`
- `Bonechurch_01_floor` — 5 GameObject，localID `1487`
- `gold_spike_fence (3)` — 3 GameObject，localID `1584`
- `gold_spike_fence (4)` — 3 GameObject，localID `1596`
- `dock_base` — 27 GameObject，localID `1658`
- `dock_metal_floor_standard` — 18 GameObject，localID `1550`
- `dock_fences_long` — 12 GameObject，localID `1528`
- `bone_corner_01` — 3 GameObject，localID `1611`

</details>

<details><summary>30_Foreground（48 个根树）</summary>

- `bone_deep_0142_i (22)` — 1 GameObject，localID `39`
- `bone_deep_0142_i (53)` — 1 GameObject，localID `101`
- `bone_deep_0142_i (24)` — 1 GameObject，localID `106`
- `bone_deep_0142_i (12)` — 1 GameObject，localID `116`
- `bone_deep_0142_i (20)` — 1 GameObject，localID `166`
- `bone_deep_0142_i (16)` — 1 GameObject，localID `194`
- `bone_deep_0142_i (41)` — 1 GameObject，localID `276`
- `bone_deep_0142_i (66)` — 1 GameObject，localID `299`
- `bone_bush_03 (10)` — 1 GameObject，localID `329`
- `bone_deep_0142_i (23)` — 1 GameObject，localID `352`
- `bone_sil (3)` — 1 GameObject，localID `358`
- `bone_bush_03 (1)` — 1 GameObject，localID `436`
- `bone_deep_0142_i (27)` — 1 GameObject，localID `472`
- `bone_front_piece_type_s (4)` — 29 GameObject，localID `1068`
- `bone_sil (2)` — 1 GameObject，localID `493`
- `bone_deep_0142_i (74)` — 1 GameObject，localID `525`
- `bone_deep_0142_i (69)` — 1 GameObject，localID `535`
- `bone_deep_0142_i (62)` — 1 GameObject，localID `586`
- `bone_deep_0142_i (6)` — 1 GameObject，localID `620`
- `bone_FG_03` — 2 GameObject，localID `654`
- `bone_deep_0142_i (13)` — 1 GameObject，localID `674`
- `bone_deep_0142_o (22)` — 1 GameObject，localID `685`
- `bone_deep_0142_i (40)` — 1 GameObject，localID `686`
- `bone_bush_03 (7)` — 1 GameObject，localID `732`
- `bone_deep_0142_i (15)` — 1 GameObject，localID `743`
- `bone_deep_0142_i (63)` — 1 GameObject，localID `758`
- `bone_sil (1)` — 1 GameObject，localID `773`
- `bone_FG_03 (4)` — 141 GameObject，localID `337`
- `bone_deep_0142_i (21)` — 1 GameObject，localID `884`
- `bone_deep_0142_i (14)` — 1 GameObject，localID `888`
- `bone_deep_0142_i (19)` — 1 GameObject，localID `13`
- `bone_front_piece_type_s` — 21 GameObject，localID `274`
- `bone_deep_0142_i (42)` — 1 GameObject，localID `925`
- `bone_front_piece_type_s (6)` — 22 GameObject，localID `986`
- `bone_deep_0142_i (67)` — 1 GameObject，localID `1009`
- `bone_deep_0142_i (17)` — 1 GameObject，localID `1106`
- `bone_deep_0142_i (65)` — 1 GameObject，localID `1167`
- `bone_front_piece_type_s (5)` — 4 GameObject，localID `1175`
- `bone_deep_0142_i (64)` — 1 GameObject，localID `1179`
- `bone_deep_0142_i (51)` — 1 GameObject，localID `1200`
- `bone_front_piece_type_s (7)` — 4 GameObject，localID `1230`
- `bone_bush_03 (9)` — 1 GameObject，localID `1251`
- `bone_deep_0142_i (44)` — 1 GameObject，localID `1256`
- `bone_bush_03 (13)` — 1 GameObject，localID `1324`
- `bone_FG_03 (7)` — 191 GameObject，localID `605`
- `bone_front_piece_type_s (3)` — 11 GameObject，localID `1631`
- `bone_front_piece_type_s (2)` — 16 GameObject，localID `1674`
- `bone_front_piece_type_s (1)` — 46 GameObject，localID `1619`

</details>

<details><summary>40_Fog_Haze（31 个根树）</summary>

- `temp fog (12)` — 1 GameObject，localID `17`
- `temp fog (10)` — 1 GameObject，localID `26`
- `lava haze (12)` — 1 GameObject，localID `148`
- `lava haze (14)` — 1 GameObject，localID `251`
- `temp fog (7)` — 1 GameObject，localID `390`
- `Fog (3)` — 1 GameObject，localID `421`
- `lava haze (27)` — 1 GameObject，localID `450`
- `lava haze (26)` — 1 GameObject，localID `452`
- `fog (6)` — 1 GameObject，localID `475`
- `Fog` — 1 GameObject，localID `545`
- `temp fog (4)` — 1 GameObject，localID `561`
- `lava haze (3)` — 1 GameObject，localID `576`
- `temp fog (2)` — 1 GameObject，localID `593`
- `lava haze (15)` — 1 GameObject，localID `610`
- `fog (7)` — 1 GameObject，localID `652`
- `temp fog (6)` — 1 GameObject，localID `661`
- `lava haze (28)` — 1 GameObject，localID `664`
- `fog (5)` — 1 GameObject，localID `672`
- `temp fog (11)` — 1 GameObject，localID `714`
- `temp fog` — 1 GameObject，localID `792`
- `Group (2)` — 10 GameObject，localID `802`
- `lava haze (6)` — 1 GameObject，localID `845`
- `temp fog (5)` — 1 GameObject，localID `869`
- `temp fog (3)` — 1 GameObject，localID `874`
- `fog (2)` — 1 GameObject，localID `971`
- `temp fog (9)` — 1 GameObject，localID `1115`
- `temp fog (8)` — 1 GameObject，localID `1265`
- `lava haze (10)` — 1 GameObject，localID `1321`
- `Group` — 7 GameObject，localID `1347`
- `lava haze (2)` — 1 GameObject，localID `1348`
- `lava haze (5)` — 1 GameObject，localID `1393`

</details>

<details><summary>50_Masks（63 个根树）</summary>

- `black_fader_moon (20)` — 1 GameObject，localID `29`
- `black_solid 413 (5)` — 1 GameObject，localID `67`
- `Bone_corners_0002_2 (32)` — 1 GameObject，localID `76`
- `black_solid 413 (11)` — 1 GameObject，localID `92`
- `Bone_Statues_0001_1 (9)` — 1 GameObject，localID `113`
- `black_solid 413 (4)` — 1 GameObject，localID `123`
- `pipe_mask_02` — 1 GameObject，localID `145`
- `black_solid 413 (10)` — 1 GameObject，localID `175`
- `black_fader_moon (13)` — 1 GameObject，localID `207`
- `Bone_corners_0002_2 (12)` — 1 GameObject，localID `211`
- `black_fader_moon (1)` — 1 GameObject，localID `298`
- `pipe_mask_02 (1)` — 1 GameObject，localID `318`
- `black_fader_moon (21)` — 1 GameObject，localID `342`
- `Bone_corners_0002_2 (10)` — 1 GameObject，localID `346`
- `Bone_corners_0002_2 (37)` — 1 GameObject，localID `363`
- `black_fader_moon (17)` — 1 GameObject，localID `409`
- `black_fader_moon (7)` — 1 GameObject，localID `449`
- `Bone_Statues_0001_1 (11)` — 1 GameObject，localID `458`
- `black_fader_moon (16)` — 1 GameObject，localID `532`
- `Bone_corners_0002_2 (19)` — 1 GameObject，localID `569`
- `Bone_corners_0002_2 (38)` — 1 GameObject，localID `640`
- `black_fader_moon (23)` — 1 GameObject，localID `644`
- `black_fader_moon (19)` — 1 GameObject，localID `657`
- `black_fader_moon` — 1 GameObject，localID `684`
- `black_fader_moon (10)` — 1 GameObject，localID `696`
- `black_fader_moon (9)` — 1 GameObject，localID `768`
- `Bone_Statues_0001_1 (10)` — 1 GameObject，localID `826`
- `pipe_mask_02 (3)` — 1 GameObject，localID `835`
- `black_fader_moon (11)` — 1 GameObject，localID `838`
- `black_fader_moon (8)` — 1 GameObject，localID `839`
- `black_solid 413` — 1 GameObject，localID `850`
- `Bone_corners_0002_2 (21)` — 1 GameObject，localID `865`
- `black_solid 413 (9)` — 1 GameObject，localID `867`
- `black_fader_moon (18)` — 1 GameObject，localID `1033`
- `Bone_Statues_0001_1 (8)` — 1 GameObject，localID `1047`
- `black_fader_moon (5)` — 1 GameObject，localID `1052`
- `Bone_corners_0002_2 (20)` — 1 GameObject，localID `1098`
- `Bone_corners_0002_2 (18)` — 1 GameObject，localID `1138`
- `black_fader_moon (22)` — 1 GameObject，localID `1145`
- `black_solid 413 (7)` — 1 GameObject，localID `1157`
- `black_solid 413 (1)` — 1 GameObject，localID `1170`
- `black_fader_moon (15)` — 1 GameObject，localID `1189`
- `black_fader_moon (14)` — 1 GameObject，localID `1190`
- `black_fader_moon (4)` — 1 GameObject，localID `1215`
- `Bone_corners_0002_2 (36)` — 1 GameObject，localID `1218`
- `black_solid 413 (6)` — 1 GameObject，localID `1221`
- `black_solid 413 (8)` — 1 GameObject，localID `1260`
- `pipe_mask_02 (2)` — 1 GameObject，localID `1267`
- `black_fader_moon (12)` — 1 GameObject，localID `1273`
- `black_fader_moon (6)` — 1 GameObject，localID `1308`
- `black_fader_moon (3)` — 1 GameObject，localID `1335`
- `black_fader_moon (2)` — 1 GameObject，localID `1368`
- `Hornet_black_soft_masker (9)` — 1 GameObject，localID `1693`
- `Hornet_black_soft_masker (2)` — 1 GameObject，localID `1700`
- `Hornet_black_soft_masker (6)` — 1 GameObject，localID `1676`
- `Hornet_black_soft_masker` — 1 GameObject，localID `1652`
- `Hornet_black_soft_masker (3)` — 1 GameObject，localID `1655`
- `Hornet_black_soft_masker (8)` — 1 GameObject，localID `1637`
- `Hornet_black_soft_masker (1)` — 1 GameObject，localID `1624`
- `Hornet_black_soft_masker (4)` — 1 GameObject，localID `1605`
- `Hornet_black_soft_masker (10)` — 1 GameObject，localID `1577`
- `Hornet_black_soft_masker (5)` — 1 GameObject，localID `1587`
- `Hornet_black_soft_masker (7)` — 1 GameObject，localID `1570`

</details>

