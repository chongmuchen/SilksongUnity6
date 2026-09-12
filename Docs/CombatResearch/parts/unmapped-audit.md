# 未匹配 HealthManager 演员审计

结论：`unmapped_health_actors` 的 **105个名称键不是105种额外敌人**。它混合了编号实例、已映射Boss部位、缺少根journalRecord但由FSM记图鉴的真敌人、蜂巢/攻击部件、机关及尸体交互。下表覆盖全部105名称键，归为33个审计组；只审计，不修改catalog。

已发现与当前`journal_records[].instances`同source+game_object_id重叠的8个名称键：Lost Lace Boss、Giant Centipede Head、Giant Centipede Coil、Giant Centipede Butt、Dancer A、Dancer B、Mapper Spar NPC、Garmond Fighter。因此这个字段更像初次匹配的遗留结果集，不能直接用长度作为最终未解决数量。

补充复现数据位于 `data/unmapped/*.json`：按去掉尾部实例编号的名称分组，每组选择一个代表实例导出完整动作数据。它补足图鉴身份仍未知的真实战斗演员（如 Shellwood Goomba）的实现资料；分组数也不等于额外敌种数，身份/计数仍以本审计的证据等级为准。

判断优先级：直接图鉴GUID/RecordJournalKill动作 ＞ 当前场景/prefab引用+可执行攻防/伤害组件 ＞ 动画族相同 ＞ 名称相似。后两者不能单独证明图鉴归属。表中的“保持未知”表示身份/计数归属未证，不代表已排除其战斗逻辑。active仅是序列化开关，实际能否出场仍受父对象、FSM和存档条件影响。

| 原名称组（键数） | 归类 | 建议图鉴ID/范围 | 证据与判断 |
|---|---|---|---|
| Weaver Servitor Broken（3） | 残骸/可破坏交互 | 保持未知，不自动并入Weaver Servitor | HP1；无DamageHero；Control仅Look/Swivel/Jitter/Death与歌唱反应，根journalRecord=0。没有主动战斗证据。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Abyss_08.unity:651873>) |
| Lost Lace Boss（1） | 已在图鉴instances中，重复集合 | Lost Lace | 同source+game_object_id已存在Lost Lace.instances；完整攻防/眩晕FSM证明战斗身份，不能再次增加敌种数。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Abyss_Cocoon.unity:2045899>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Abyss_Cocoon.unity:2005613>) |
| MossBone Cocoon（16） | 可破坏茧/提取交互 | 不列独立敌种 | HP1、无伤害；Idle/Sway/Die/Extract/Extract Kill，EnemyDeathEffectsNoEffect且journalRecord=0。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Arborium_04.unity:335720>) |
| Shellwood Goomba（3） | 确认真实战斗敌人，图鉴未证 | 保持未知 | Hornet多个场景HP15、伤害1；Hide/Emerge/Start Walker/Roof Drop等完整控制；Animator引用Shellwood Goomba Anim，DeathEffects有正常死亡profile但journalRecord=0。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Arborium_05.unity:353474>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Arborium_05.unity:315712>) |
| Shellwood Goomba Flyer（5） | 确认真实战斗敌人，图鉴未证 | 保持未知；不与地面型强制合并 | HP15、伤害1；Idle/Chase/Pursue/Burst Out/Hang等飞行攻击状态，虽共用Shellwood Goomba Anim，行为原型不同；journalRecord=0。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Arborium_05.unity:344950>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Arborium_05.unity:315532>) |
| Music Box Bell（14） | 机关 | 不列独立敌种 | HP0、无伤害、无自身战斗FSM；钟组件不等价敌人。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Arborium_10.unity:109435>) |
| Giant Centipede Head（1） | 已纳入的Boss本体部位 | Giant Centipede | 同source+game_object_id已被纳入；与Coil/Butt共用Giant Centipede Anim，含Appear/Attack/Death流程。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bellway_Centipede_Arena.unity:815786>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bellway_Centipede_Arena.unity:741589>) |
| Giant Centipede Coil（5） | Boss攻击部件 | Giant Centipede（战斗部件） | 基础Coil已经映射；5个编号形态共享Giant Centipede Anim和Attack1..6/Descend控制，HP10000、伤害2，保留部件实例而非额外物种。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bellway_Centipede_Arena.unity:853762>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bellway_Centipede_Arena.unity:741481>) |
| Giant Centipede Butt（1） | 已纳入的Boss本体部位 | Giant Centipede | 同source+game_object_id已被纳入；与Head同Boss动画库和死亡控制，不能单列新敌种。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bellway_Centipede_Arena.unity:768557>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bellway_Centipede_Arena.unity:741265>) |
| Pierce Dmg Receiver（1） | Boss受伤代理 | Skull King（受伤代理） | 两个实例parent链均为Skull King→Boss Scene；自身inactive、HP9999999、无DamageHero/攻击FSM。必须保留伤害路由，不能计为小怪。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_15.unity:1361062>) |
| Black_Thread_Core_Citadel（2） | 真实可攻击核心变体 | Black Thread Core | 根journalRecord虽为0，但自身FSM Death Stagger启用RecordJournalKill直接指向Black Thread Core。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_26.unity:658496>)；[图鉴动作](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_26.unity:662595>) |
| Dancer A（1） | 已纳入的双体Boss部位 | Clockwork Dancer | 当前catalog同source+GO已经关联Clockwork Dancer；两个本体共享Clockwork Dancers Anim且都有攻击FSM。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Cog_Dancers_boss.unity:682609>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Cog_Dancers_boss.unity:303781>) |
| Dancer B（1） | 已纳入的双体Boss部位 | Clockwork Dancer | 当前catalog同source+GO已经关联Clockwork Dancer；不能将双体当两条新增图鉴。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Cog_Dancers_boss.unity:650456>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Cog_Dancers_boss.unity:303799>) |
| Dock Guard Thrower Enc1（1） | 真实敌人的脚本遭遇版本 | 候选Dock Guard Thrower；计数归属仍待证 | HP9999、Throw/Jump/Ready/Jump Leave等交战演出；Animator实际引用Dock Guard Thrower库，而非仅名称相近。根journalRecord=0，未见直接记图鉴动作。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Dock_02b.unity:1592023>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Dock_02b.unity:1471843>) |
| Dock Guard Slasher（1） | 真实Boss/交战演员 | 保持未知 | HP720、多段Combo/Slash/Spin及Stun Control，8个伤害体；Dock Guard Anim资源。不可因同场Thrower就擅自并入其图鉴ID。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Dock_09.unity:619549>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Dock_09.unity:600618>) |
| Mapper Spar NPC（1） | 已纳入的可战斗NPC | Shakra | 同source+GO已关联Shakra；Defeat Start启用RecordJournalKill(Shakra)，同时存在对话/战斗控制。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Greymoor_08_mapper.unity:18461>)；[图鉴动作](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Greymoor_08_mapper.unity:38261>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Greymoor_08_mapper.unity:16949>) |
| Garmond Fighter（1） | 已纳入的可战斗NPC | Garmond_Zaza | 同source+GO已关联；Death Hit启用RecordJournalKill直接指向Garmond_Zaza。不要误并黑丝Garmond条目。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_09.unity:614503>)；[图鉴动作](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_09.unity:832788>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_09.unity:609847>) |
| red_memory_silk_pod（20） | 回忆场景物件 | 不列独立敌种 | Memory_Red中的HP0物件，无伤害与自身战斗FSM。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Memory_Red.unity:2953841>) |
| Swamp Muckman Lurer（1） | 真实诱敌/场景变体 | Swamp Muckman | 自身Die状态启用RecordJournalKill，参数GUID直接对应Swamp Muckman；不是凭Lurer名称推测。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_10.unity:857482>)；[图鉴动作](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_10.unity:867129>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_10.unity:792237>) |
| Swamp Muckman (5) -replaced by tall guys（1） | 当前场景仍保存的战斗实例 | Swamp Muckman；实际生成条件待运行确认 | 自身与parent Swamp Muckman All Control均active=1；Die直接记Swamp Muckman图鉴。名称里的replaced只是备注，不足以判定旧资产或安全排除。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_12.unity:684116>)；[图鉴动作](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_12.unity:693763>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_12.unity:653385>) |
| Swamp Muckman A（1） | 真实场景变体 | Swamp Muckman | Die启用RecordJournalKill直接指向Swamp Muckman；共享Swamp Muckman Anim。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_18.unity:841774>)；[图鉴动作](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_18.unity:851421>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_18.unity:736822>) |
| Swamp Muckman B（1） | 真实场景变体 | Swamp Muckman | Die启用RecordJournalKill直接指向Swamp Muckman；共享Swamp Muckman Anim。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_18.unity:805820>)；[图鉴动作](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_18.unity:815467>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_18.unity:736858>) |
| Control（1） | 战斗环境生成器 | 无独立图鉴；保留为Shellwood Hive遭遇组件 | 3实例parent实际为Shellwood Hive；HP50；FSM包含Spawn Wasps/Spawn1..3/Invincible；是蜂巢战斗依赖，不是一个名叫Control的新物种。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shellwood_01.unity:994331>) |
| Splinter Queen Spike（6） | Boss可破坏危险物 | Splinter Queen（辅助攻击对象） | 共享Splinter Queen Anim，HP12、伤害1，有Down/Spike/Shatter攻击与破坏流程；不是尸体，也不应当增加6个物种。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shellwood_18.unity:2349254>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shellwood_18.unity:2245345>) |
| Slab Alarm Prisoner Fly（2） | 确认真实飞行警报/锁链敌人 | 保持未知；不自动并入Slab Prisoner Fly New | HP9、伤害1，Roar/Alert和Chain In Place控制。可确定为战斗/警报演员，未找到根图鉴归属。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Slab_14.unity:252988>) |
| Slab Alarm Prisoner（4） | 确认真实警报/锁链敌人 | 保持未知；不自动并入Slab Prisoner Leaper New | HP12、伤害1，Roar/Alert/Rest/Shake和Chain In Place控制；引用Slab Prisoner Leaper Anim而根journalRecord=0。共享美术不足以证明New条目的计数归属。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Slab_14.unity:245960>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Slab_15.unity:243453>) |
| Mossbone Mother B（1） | 真实双Boss遭遇变体 | Mossbone Mother | 与A同场双体；图鉴由Battle End集中授予两次，根journalRecord=0是统计路径不同，并非未使用资产。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Weave_03.unity:1118018>)；[集中Award Journal](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Weave_03.unity:1086496>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Weave_03.unity:1053329>) |
| Mossbone Mother A（1） | 真实双Boss遭遇变体 | Mossbone Mother | A/B都有HP350及Swoop/Slam/Stun控制，共用Bosses/Mossbone Mother Anim；本场Battle End/Award Journal有两次启用RecordJournalKillV2，均直接指向Mossbone Mother。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Weave_03.unity:1120253>)；[集中Award Journal](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Weave_03.unity:1086496>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Weave_03.unity:1053347>) |
| Farmer Wisp Immolater Variant（4） | 确认真实战斗变体 | 保持未知；Farmer Wisp仅为已证美术族 | 多个Wisp场景HP90、伤害1，Wisp Antic/Cast/Charge/Summon Wisps Multiple、Fall Tele；Animator明确引用Farmer Wisp Anim，但根journalRecord=0且自身FSM未找到记图鉴动作。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Wisp_02.unity:1092202>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Wisp_02.unity:1010055>) |
| NPC（1） | 尸体剧情/交互演员 | 不列独立小怪；按各尸体任务保留 | 该同名键含Corpse Flower Queen、Corpse Green Prince、Corpse Hunter Queen三个不同prefab内节点；有Leap/Grab/Yank取物等交互。不能把通用名NPC及HP1000当第四种Boss。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Corpse Flower Queen.prefab:5538>) |
| Aspid Hatchling（1） | 被当前战斗prefab引用的召唤物 | 保持未知 | HP1/伤害1、Chase/Follow/Spawn等控制；Grove Pilgrim Fly prefab实际引用其GUID，而Grove本身被Hornet Dust场景引用，不能因Aspid名称判作空洞骑士旧资产。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Aspid Hatchling.prefab:652>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Aspid Hatchling.prefab:210>) |
| Grove Pilgrim Fly（1） | 有当前场景引用的战斗prefab | 保持未知 | HP22/伤害1、Chase/Attack Antic/Shake等FSM；GUID被Dust_01/02/03/04/06/11场景引用。未证明独立图鉴条目。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Grove Pilgrim Fly.prefab:748>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Grove Pilgrim Fly.prefab:283>) |
| Song Automaton Tiny（1） | 有当前场景引用的战斗/召唤prefab | 保持未知 | HP28/伤害1、Fire/Swoop In/Return等FSM；GUID被Hang_02/Hang_04_boss/Hang_13引用，不能当只存盘未使用的资产排除。 [FSM/组件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Song Automaton Tiny.prefab:652>)；[动画引用](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Song Automaton Tiny.prefab:230>) |

## 核心补漏证据

- Mossbone Mother A/B：[Battle End/Control](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Weave_03.unity:1085889>)等待BATTLE END后进入Award Journal，两次RecordJournalKillV2都引用`f1f3615eea7d8b04d9b7e446d04e1108`；该GUID对应`Mossbone Mother.asset`。A/B是同图鉴的双体遭遇，必须保留各自HP350与协同控制，不能只用教程母亲的参数代替。
- Swamp Muckman Lurer：[Die状态](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Shadow_10.unity:867129>)启用RecordJournalKill，指向`b0b7b008018b8ae49b550c9249ab28d4`（Swamp Muckman）。同样证据见A/B和名字带replaced备注的实例。
- Black_Thread_Core_Citadel：[Death Stagger](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_26.unity:662595>)启用RecordJournalKill(Black Thread Core)。这说明只扫根EnemyDeathEffects.journalRecord会漏掉正常战斗演员。
- 召唤链：[Dust_01引用Grove Pilgrim Fly](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Dust_01.unity:732192>)；[Grove引用Aspid Hatchling](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Grove Pilgrim Fly.prefab:4050>)；[Hang Boss引用Song Automaton Tiny](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Hang_04_boss.unity:293127>)。当前引用成立，独立图鉴归属仍未知。

## 全部105原键（供核对遗漏）

- **Weaver Servitor Broken**：`Weaver Servitor Broken`；`Weaver Servitor Broken (1)`；`Weaver Servitor Broken (2)`
- **Lost Lace Boss**：`Lost Lace Boss`
- **MossBone Cocoon**：`MossBone Cocoon (1)`；`MossBone Cocoon`；`MossBone Cocoon (2)`；`MossBone Cocoon (3)`；`MossBone Cocoon (5)`；`MossBone Cocoon (6)`；`MossBone Cocoon (4)`；`MossBone Cocoon (11)`；`MossBone Cocoon (9)`；`MossBone Cocoon (14)`；`MossBone Cocoon (8)`；`MossBone Cocoon (10)`；`MossBone Cocoon (13)`；`MossBone Cocoon (7)`；`MossBone Cocoon (15)`；`MossBone Cocoon (12)`
- **Shellwood Goomba**：`Shellwood Goomba`；`Shellwood Goomba (2)`；`Shellwood Goomba (6)`
- **Shellwood Goomba Flyer**：`Shellwood Goomba Flyer`；`Shellwood Goomba Flyer (1)`；`Shellwood Goomba Flyer (4)`；`Shellwood Goomba Flyer (2)`；`Shellwood Goomba Flyer (3)`
- **Music Box Bell**：`Music Box Bell 6`；`Music Box Bell 1`；`Music Box Bell 2`；`Music Box Bell 3`；`Music Box Bell 4`；`Music Box Bell 7`；`Music Box Bell 5`；`Music Box Bell (5)`；`Music Box Bell (2)`；`Music Box Bell (1)`；`Music Box Bell (3)`；`Music Box Bell (4)`；`Music Box Bell (6)`；`Music Box Bell (7)`
- **Giant Centipede Head**：`Giant Centipede Head`
- **Giant Centipede Coil**：`Giant Centipede Coil`；`Giant Centipede Coil (2)`；`Giant Centipede Coil (4)`；`Giant Centipede Coil (1)`；`Giant Centipede Coil (3)`
- **Giant Centipede Butt**：`Giant Centipede Butt`
- **Pierce Dmg Receiver**：`Pierce Dmg Receiver`
- **Black_Thread_Core_Citadel**：`Black_Thread_Core_Citadel`；`Black_Thread_Core_Citadel (1)`
- **Dancer A**：`Dancer A`
- **Dancer B**：`Dancer B`
- **Dock Guard Thrower Enc1**：`Dock Guard Thrower Enc1`
- **Dock Guard Slasher**：`Dock Guard Slasher`
- **Mapper Spar NPC**：`Mapper Spar NPC`
- **Garmond Fighter**：`Garmond Fighter`
- **red_memory_silk_pod**：`red_memory_silk_pod0007 (15)`；`red_memory_silk_pod0007 (14)`；`red_memory_silk_pod0007 (5)`；`red_memory_silk_pod0007 (10)`；`red_memory_silk_pod0007 (16)`；`red_memory_silk_pod0007 (12)`；`red_memory_silk_pod0007 (13)`；`red_memory_silk_pod0007 (11)`；`red_memory_silk_pod0007`；`red_memory_silk_pod0007 (4)`；`red_memory_silk_pod0007 (8)`；`red_memory_silk_pod0007 (19)`；`red_memory_silk_pod0007 (23)`；`red_memory_silk_pod0007 (2)`；`red_memory_silk_pod0007 (17)`；`red_memory_silk_pod0007 (21)`；`red_memory_silk_pod0007 (9)`；`red_memory_silk_pod0007 (20)`；`red_memory_silk_pod0007 (18)`；`red_memory_silk_pod`
- **Swamp Muckman Lurer**：`Swamp Muckman Lurer`
- **Swamp Muckman (5) -replaced by tall guys**：`Swamp Muckman (5) -replaced by tall guys`
- **Swamp Muckman A**：`Swamp Muckman A`
- **Swamp Muckman B**：`Swamp Muckman B`
- **Control**：`Control`
- **Splinter Queen Spike**：`Splinter Queen Spike`；`Splinter Queen Spike (1)`；`Splinter Queen Spike (2)`；`Splinter Queen Spike (3)`；`Splinter Queen Spike (4)`；`Splinter Queen Spike (5)`
- **Slab Alarm Prisoner Fly**：`Slab Alarm Prisoner Fly (2)`；`Slab Alarm Prisoner Fly (1)`
- **Slab Alarm Prisoner**：`Slab Alarm Prisoner (2)`；`Slab Alarm Prisoner (1)`；`Slab Alarm Prisoner (3)`；`Slab Alarm Prisoner`
- **Mossbone Mother B**：`Mossbone Mother B`
- **Mossbone Mother A**：`Mossbone Mother A`
- **Farmer Wisp Immolater Variant**：`Farmer Wisp Immolater Variant`；`Farmer Wisp Immolater Variant (3)`；`Farmer Wisp Immolater Variant (2)`；`Farmer Wisp Immolater Variant (1)`
- **NPC**：`NPC`
- **Aspid Hatchling**：`Aspid Hatchling`
- **Grove Pilgrim Fly**：`Grove Pilgrim Fly`
- **Song Automaton Tiny**：`Song Automaton Tiny`

审计边界：这次没有将名称相似直接转成正式映射，没有修改既有敌种总数，也未声称验证所有出场条件。应把“237图鉴记录覆盖”与“额外战斗演员/变体已列出、部分图鉴归属未知”分别说明。对Shellwood、Slab警报囚徒、Immolater等明确有战斗证据的未知项，完整战斗范围应保留它们的FSM入口，不能把它们隐藏到道具列表。
