## 典型 Boss 精读：从表现还原可以实现的系统

以下研究针对当前 Unity 6 工程里的具体资产快照，不把同名 Boss 的所有变体合并。三个主案例分别是 `Tut_03 / Mossbone Mother`、`Bone_East_12 / Lace Boss1`、`Library_13 / Trobbio`（主行为以同名Prefab交叉校验）。第一场 Lace 的结果不能直接当作 Lace Boss2 或 Lost Lace 的参数。文中“事实”来自脚本、场景或预制体；“教学解释”说明机制为何产生这种体验；“验收”是复现应满足的可观测条件。

阅读时始终把四件事分开：进入状态时发生什么、状态停留期间每帧更新什么、什么事件结束状态、退出时恢复哪些碰撞与速度设置。动画事件不是装饰：许多攻击只在动画指定帧开启伤害碰撞体。下文秒数以游戏时间计；动画帧是资源内的动画帧，不是固定的显示器帧数。停帧、动画速度倍率、进入帧的处理都会使录像测量与 `索引 / fps` 的标称时间略有差异。

### 苔藓之母：用少量招式组织出逐层增加压力的战斗

事实：实例生命值为 120，身体接触伤害为 1，加载时处于无敌状态，入场流程负责解除它。主 FSM 有 68 个状态，另有 17 个状态处理眩晕。位置参数 `Left X=46.43`、`Right X=67.92`、`Centre X=57.37`、`Max Height=23.8` 属于 `Tut_03` 场景，移植到新房间时必须整体改为场地锚点。证据：[生命组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:491517>)、[接触伤害](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:565798>)、[Control](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:521388>)。

它的“待机”不是静止。`Idle` 每次物理更新都会尝试维持与 Hornet 的距离，同时浮在玩家上方。目标距离是欧氏距离 12，垂直目标为玩家高度加 6，横纵分量分别限制到 ±6，每次物理更新增加或减少 0.375。因为这里不是归一化向量移动，斜向速度的模可能大于 6。超过高度上限会向下加速，并非直接把坐标硬夹到上限。`DistanceFlyV2` 在进入状态时也执行一次更新，之后才是每次 FixedUpdate。证据：[Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:522164>)、[运动实现](</Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/DistanceFlyV2.cs:60>)。

这是一个很适合初学者练习的反馈控制器：远了向玩家加速，近了向远离玩家方向加速，高度再独立修正。它有惯性，因此看上去像飞行动物；如果改成每帧把位置插值到“玩家上方固定点”，轨迹和玩家可利用的空当都会改变。

**战斗如何逐步变化。** 初始化读取生命上限并计算三个阈值：95%、85%、70%。在这个 120 HP 实例里对应 114、102、84；85% 的阈值服务于双母变体呼叫同伴，本场 `Double Fight=false`。单体场真正使用的是：

|生命条件|进入选招时的行为|注意事项|
|---|---|---|
|HP > 114|强制俯冲|不是从开场就随机使用全部招式。|
|HP ≤ 114|俯冲与撞顶都可选，权重 1:1|撞顶最多连续 1 次，俯冲最多连续 2 次。|
|撞顶后 HP > 84|落石|阈值在落物选择状态再次读取，不是缓存一整轮的阶段。|
|撞顶后 HP ≤ 84|落石与召唤，权重 1:1，分别最多连续 1 次|低血量加入额外敌人的空间压力。|

这些是状态进入时的检查，不是“到达阈值立刻取消当前动作”。`Move Choice` 首先重置待机计时，再检查演奏反应和双母分支，随后读取 HP。随机器保留上次连续次数，不是每轮独立抛硬币。证据：[选招](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:522594>)、[落物选择](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:525574>)。

**一轮俯冲的完整过程。** `Swoop Antic` 播放 Antic，等待 0.4 秒、以 0.75 倍阻尼减速，同时小幅抖动。进入 `Swoop` 后，向下发射 20 单位射线读取地面，目标高度设为地面 Y 加 2.2。只在这时确定地面目标，不能一路追着玩家高度变化。水平目标速度为 `18 × 当前X缩放`；初始速度反而设为目标速度的 -1.3 倍，形成先后撤再前冲的蓄势。随后每次物理更新向目标速度靠近，步长为 `abs(目标速度 × 0.1)`。垂直位移在 0.5 秒内用序列化的 iTween easing 完成，而整段 `Swoop` 的等待为 0.9 秒。上下受击击退在这段被禁止，左右击退仍允许。

0.9 秒到后进入 `Swoop Extend`。此时不再有固定计时器：如果自身越过左右界，或者与玩家的水平距离不再在 2 单位容差内，就进入 `Swoop Return`。Return 播放回收动画、水平速度每物理步乘 0.95，保持 0.5 秒并恢复上下击退。然后 `Swoop Recover` 上升回空中：Y 速度每步趋近 6、步长 0.1，X 继续 0.95 阻尼，等待 0.65 秒后回 Idle；受到伤害也可提前回 Idle。若当前召唤物标志 `Spawned=true`，则改去 `Crawler Idle`。证据：[俯冲起手](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:522878>)、[俯冲](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:523095>)、[延长和收招](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:525145>)。

教学解释：玩家看到的是“抖动—后撤—贴地横冲—抬升”，实现上却是两个独立轴的控制、一个地面采样、三种退出条件。需要复现的是这些时序和约束，而不是画一条固定曲线从 A 点移动到 B 点。

**撞顶、落石和召唤。** `Slam Antic` 等 0.4 秒，设后续 Idle Time=2.25；`Set Antic Dir` 在单体模式给速度向量 (0,-8)，`Slam Antic 2` 播放 RoofAntic 并等 0.3 秒。`Fly Up` 立即设置 Y 速度 25，X 每步乘 0.85。顶部碰撞、左右碰撞、Y 速度落入 0±0.1、或者 1 秒超时都可触发 `SLAM`。所以必须提供真实天花板，不能只把“撞顶”写成播放动画。进入 `Slam` 后播放 Smash，并立即发送 FINISHED 去 `Drop Type`；Smash 的结束由稍后的 `Anim End` 监听，不能在 Slam 本身等完整动画才开始落石。

落石通过向场景 `Stals` 及子物体广播 FALL；召唤通过向 `Spawn Crawler` 发送 SPAWN。第一次只调用一个生成器，后续 `Done First Spawn=true` 时会先调用第二生成器，再调用第一生成器。召唤分支把 `Idle Time` 设成 0.5，`Recover Time` 设成 0.25，随后进入召唤期间的飞行状态；它最多停留 1 秒，若 Spawned 被外部清除则提前收招，受到伤害则直接发动俯冲。这是一套 Boss 与小怪控制器之间的事件协议：生成器必须在召唤物死亡时正确更新主 Boss 的标志。证据：[撞顶流程](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:524318>)、[召唤](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:527531>)、[第二生成器](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:532045>)。

**受到攻击并不都等于硬直。** Idle 收到 TOOK DAMAGE 进入 `Dmg Response`，等随机 0.25–0.4 秒后直接走下一轮选招检查。这让主动攻击会加快 Boss 的反应，而不是无限推迟它出招。眩晕是另一套 FSM 对 STUN DAMAGE 的累计，不能把变量 `Stun Combo=8` 直接翻译成“连打 8 下就晕”：对应连击比较动作在本快照中禁用；应按附表中 enabled 标记和累计 Stun Damage 运行。真正进入 `Stun Start` 后定时器为 2 秒，击退速度改为 2；`Stunned` 每秒扣 1，受到伤害再扣 0.1；结束后播放 Recover，击退速度恢复 5，并发送 STUN CONTROL START。生命为零全局进入 End。Extract 是独立全局机制，关闭伤害、移动到抽取点，EXTRACT FINISH 后扣 20 HP 再恢复伤害，不能把它误当普通攻击分支。证据：[受击反应](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:536751>)、[眩晕](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:530956>)、[抽取](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:532170>)。

验收时至少录制五条确定性轨迹：120 HP 时连续选招只到俯冲；114 HP 时撞顶进入候选；84 HP 的撞顶后召唤可达；俯冲采样后移动玩家不会改变已采样地面高度；召唤期间击中 Boss 会提前去俯冲。另在每个攻击状态注入 STUN 和 ZERO HP，检查上下击退、伤害与旧计时器是否完整清理。

### Lace 第一战：距离选择、反击陷阱与动画事件驱动的连段

事实：`Bone_East_12` 的 Lace Boss1 为 250 HP，主 FSM 132 状态。主身体及 Charge Hit、Downstab Hit、Circle Slash 1/2、Combo Slash 1/2 等单次伤害为 1；MultiHit 本体 DamageHero 设置为 0，因为它的职责是启动独立连击流程。证据：[生命](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:406523>)、[伤害组件](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:460982>)、[主控制](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:406652>)。

教学解释：Lace 的复杂度不是单纯“招式多”，而是先选择战术，再调整位置，再进入攻击。玩家远离她时看到前跳，可能以为她还没决定出什么招；实际上 `Next Event` 已保存将来的招式，前跳只是满足该招式的距离条件。

**决策的层次。** Idle 的默认等待为 0.75 秒；受到攻击直接进入选招，当前动画完成也可进入选招。同时监视场外、演奏和反击条件。常规选招之前先检查 CrossSlash：HP>125 时直接进入距离分支，计数保持不变；HP≤125 时才继续检查计数，若 `Ct CrossSlash≤0` 则进入十字斩，若 `Ct CrossSlash>0` 则计数减 1 后进入距离分支。十字斩起手把计数重新设为包含两端的随机整数 2–4，这个值表示未来选招检查的间隔，不是秒。

`Distance Check` 读取欧氏距离，≤6 为近，>6 为远。近距离权重相同的事件是 EVADE、COMBO、J SLASH，分别最多连续两次；遗漏上限前 3 项均为 4。这里有一个容易抄错的实证细节：本快照近距离的 `J SLASH` 事件连接的是 `Charge Antic`，并非 `J Slash Antic`。远距离权重相同的事件为 COMBO、CHARGE、J SLASH，最大连续次数为 2、1、2，遗漏上限全为 4；它们先分别设目标水平距离 9.25、16、12，再经过 `Hop Check`。只在前跳这层使用水平距离。每跳播放 Forward Hop，动画触发时赋水平速度 24，再等待动画节点收招；非墙范围下 `Hops>3` 也停止追跳。墙范围的先行事件会改变路线，应保留检查顺序。证据：[近远选择](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:414206>)、[前跳](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:415463>)、[半血技能](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:421192>)。

**冲刺不是一条匀速线。** 起手面朝玩家，先以相对朝向 -32 的速度后撤，水平每物理步乘 0.825，持续 0.2 秒并在退出时刹车。`Charge Break` 明确把 X 速度设为 0，再等 0.6 秒。之后才是 Charge：初速度 80、持续 0.3 秒、每物理步乘 0.89，开启 Charge Hit；退出自动恢复这个伤害物体的激活状态。最后播放 Charge Recover，水平阻尼 0.875、退出刹车。若只设置“冲刺速度80、时长0.3”，会严重高估实际位移，也失去前面的诱导停顿。证据：[Charge Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:408000>)、[Charge Break](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:425596>)、[Charge](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:408340>)。

**两段近战连斩。** 使用 `Combo Slash` 资源，28 动画帧、24 fps，triggerEvent 位于零基索引 14、15、20、21，对应标称 0.5833、0.625、0.8333、0.875 秒。第一事件进入 ComboSlash 2 并开启第一刀；第二事件进入 ComboSlash 3 并关闭第一刀；第三事件进入 ComboSlash 4 开启第二刀；第四事件进入 ComboSlash 5 关闭第二刀并等待全动画结束。第一刀和第二刀还各安排 0.041 秒后关闭碰撞体，是短有效窗的保险。两次刀启动都赋前向速度 30；刀间和收招时 X 每步乘 0.8，最终退出刹车。每一刀的形状是自己的子对象多边形，不能把身体碰撞框放大代替。证据：[连斩状态](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:413062>)、[动画库](</Users/mars/workspace/SilksongUnity6/Assets/Animations/Hornet Enemies/Lace Anim.prefab:96>)。

**升空斩接下刺。** Jump Antic 等 0.65 秒。Rising Slash 把重力设为 0，启动前向 60、向上 87 的速度，再以 0.825 阻尼衰减。该动画 5 帧、18 fps，在索引 2、3、4 触发事件，分别开启 Circle Slash 1、换成 Circle Slash 2、关闭并等待动画结束。下刺起手完成后赋前向45、向下45，开启 Downstab Hit。落地不只靠碰撞回调：3 条射线检测、底部碰撞、Y速度>-0.1、1 秒超时都可以触发 LAND；墙检测则发 WALL 进入 Wallcling。正常落地后将 Y 设为场地 Land Y=7.598696、恢复重力2、恢复约束、播放收招；若 X 不在 [81,107] 则转贴墙路线。证据：[升空和下刺](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:408759>)、[落地约束](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:410593>)。

**反击的危险在于玩家主动触发。** 招式结束后的 `Will Counter?` 用权重 0.33:0.66 决定是否留下 Will Counter 标记。Idle 必须同时满足距离<6、标记为真、Counter Pause>0.25 才开始反击起手；Counter Pause 是一个从0到1的缓动值，不应未经验证直接当作线性秒表。Counter Antic 完成后按朝向将无敌方向代码设成 9 或8，Counter Stance 持续0.75秒，退出自动恢复无敌。只有 BLOCKED HIT 触发反击，普通经过或等待不会。

触发后 Counter Hit 带 FreezeMoment(4)，再进入前移速度19的 RapidSlash Charge。此时普通身体伤害设成0，碰到玩家层20转入捕获连击；随后 RapidSlash Loop 的有效持续为0.65秒并启用 MultiHit 多边形。结束时恢复身体伤害1。真正多次伤害、玩家牵引与脱离由 MultiHit 的独立 FSM 和主 FSM 的 Hero Facing / Multihitting / Finish Multihit 协作完成，完整动作附表必须一起移植。证据：[反击姿态](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:411194>)、[反击冲锋](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:412286>)。

**十字斩和全局退出。** CrossSlash Aim 先确保与玩家水平距离至少6，并根据场地中心和面朝方向检查是否需要后撤。0.9秒预备后，主 Lace 被设为运动学刚体、隐藏Renderer、关闭Collider，由 Cross Slash 子对象接管画面与碰撞；主状态等待0.8秒，同时发送 ATTACK START 并跟踪子对象位置作为受击特效原点。Finish Multihit / Slash Slam 负责撤销接管：恢复刚体、Collider、Renderer，移动至 CS Exit Point，恢复击退速度15和眩晕控制。任何眩晕都必须清掉所有刀、冲刺框、连击框、十字斩能量，结束玩家 WOUND 状态；眩晕2秒，期间每次普通伤害额外扣0.25秒。死亡与熔岩处理是独立FSM/事件，不能仅用 Control 的一条 ZERO HP 迁移代替。证据：[十字斩接管](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:419901>)、[恢复](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:420684>)、[眩晕清理](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:418526>)。

验收要对照事件而不是只看最终伤害：两刀只能在各自0.041秒窗口或退出关闭之前命中；Charge 必须包含0.2秒后撤和0.6秒静止；未攻击 Counter Stance 时应自然结束，攻击被格挡后才启动反击；125 HP 可进入十字斩，126 HP 不可；十字斩结束必须恢复全部物理/渲染设置。对角位置用欧氏距离6、纯水平接近用9.25/12/16进行边界测试，才能排除“全都用X距离”的常见误差。

### Trobbio：Boss、投射物与舞台控制器组成的多层战斗

事实：本案例以 `Trobbio.prefab` 为根，700 HP，主 FSM144状态。其场地常量为中心X=74、地面Y=16.34、旋风可结束区间X∈[66,82]、投掷最高Y=25.91。它还依赖父舞台的 Flare Glitter、Trapdoor Bursts、Steam Jets、门和镜头节点；这些不是纯美术依赖。证据：[Prefab生命](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:1397>)、[初始化](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:1512>)。

教学解释：这里可以学习“编排式 Boss”。主控制器决定下一段演出，炸弹控制器独立模拟反弹和引爆，舞台控制器负责区域压制。只重写主角的技能列表，通常会做出招式看起来相似但安全区、随机节奏都不对的版本。

**选招既有权重，也有记忆。** Choice 的检查顺序依次为演奏、首次攻击、玩家死亡、二阶段、首轮柱攻击、阶段随机池。第一次只能在 TORNADO/BOMB THROW/JUMP 中等权选择。常规一阶段的权重为旋风1、投弹1、闪光1、跳跃1、退场0.75；连续上限都为1，遗漏上限依次5/5/4/3/4。二阶段把最后一项换成 BURST COLUMNS，五项等权，遗漏上限5/5/4/4/4。随机动作的“最多连续一次”仅约束这一个随机动作实例的选择记录，不等于整个Boss绝不可能连续表现同类招式；例如投弹还可经 Rethrow? 再投一次，跳跃也有空中技能池。证据：[Choice](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:3187>)、[再投掷](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:14927>)。

二阶段条件是 HP<350，严格小于，350不会切换。进入 Phase Roar Antic 先禁止四向击退并暂停眩晕，再播放阶段吼叫；吼叫有效等待1.5秒，设置 Phase 2、Will Burst Column、Doing First Burst Column，恢复眩晕和击退后退场，交由舞台爆柱。切换发生在 Choice 重新检查时，而不是生命刚减到349就打断当前攻击。证据：[阶段吼叫](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:32620>)。

**三发炸弹是一组不同初始条件。** Throw动画10帧、12 fps，索引6触发生成，即标称0.5秒。发射点Y先取 `min(当前Throw PointY,25.91)`。同位置生成3颗 Trobbio Bomb，X速度分别+15、-15、随机二选一±3；Rotation参数分别0、90、180。Rotation不是单纯旋转美术：炸弹进入引爆前摇时把自己的角度设成这个参数。主Boss等Throw动画完成后继续后续决策，并不阻塞等待炸弹爆炸。

炸弹有自己的16状态FSM。Init抽取计时器1–1.7秒及Bounce Speed（序列化参数为min40/max28，移植时保留原API行为或明确验证端点互换处理）；落地以Bounce Speed向上弹，撞左右墙反转X速度，并向内平移0.25避免卡墙；被针击左右时改为±12，被向下击时Y=-20；重伤/命中玩家可进入引爆。普通计时归零还不够，必须同时在X=[62,86]、Y=[15.5,22.5]范围内，才进入Antic。Antic设运动学、速度乘0.84、播放Bomb Antic，0.75秒后Explode；这期间受到伤害或命中玩家可提前引爆。Explode停速、启用Blast、关自身Collider，2秒后关闭Blast并回对象池。2秒是对象生命周期，不自动等于整个2秒都有伤害。证据：[投掷](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:2399>)、[炸弹控制](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:473>)。

**旋风的结束同时依赖时间和位置。** 普通Antic完成后还要播放Tornado Antic（4帧/15fps）。Tornado Start 开旋风伤害器与事件发送器，关普通Damage Collider，重力0.5，目标X速度依朝向为±22，时间设1.6秒，并开启方向代码13的无敌。移动时每物理步以0.6靠近目标速度，前向1.7单位射线检测地形层8，碰墙则反转实际X速度、目标速度和朝向。计时在Tornado中按秒递减，但只有计时<0且身处[66,82]才去收招。因此“旋风固定1.6秒”是错误实现。

收招先减速0.3秒，仍然可收到MULTI HIT CONNECT。接着在自身偏移(+0.75,-3.1,-0.001)和(-0.75,-3.1,-0.001)各生成一个相反朝向的地面效果，关旋风伤害器与事件发送器、恢复普通伤害Collider、关闭方向13无敌。最后播放Tornado End并恢复重力1。证据：[旋风启动](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:6043>)、[运动与位置门槛](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:5458>)、[收招及地面效果](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:6849>)。

**闪光与跳跃为什么要依赖舞台状态。** Flash Antic 先读取舞台 Flare Glitter 的Active；已有闪光覆盖时取消本次并回Choice。Flash Attack为10帧/13fps，索引4触发上升、索引5触发闪光。上升设重力0、Y速度40，速度每步乘0.825；闪光时重启Dazzle Flash，执行ScreenFlashTrobbio，并向舞台发送FLARE GLITTER。跳跃初速Y=30，等待0.25–0.3秒后决定飞行方向。第一次空中分支权重0.75继续飞、0.125投弹、0.125旋风；二阶段后续空中分支可在闪光、投弹、旋风间等权选择。这样一次Jump并不保证只有一条固定轨迹。证据：[闪光前置条件](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:3912>)、[起跳](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:9901>)、[空中选择](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:11575>)。

**眩晕与死亡要结束整个编排。** Stun Start 将Y至少修正到16.91，关闭旋风框、普通Damage Collider和事件器，取消无敌与伤害，恢复可见、非运动学刚体和Collider，重力1，赋后向6/向上20的抛起速度，眩晕计时2秒；每次受伤再扣0.25秒。ZERO HP 全局进入Death Hit，立即记录图鉴和defeatedTrobbio、广播TROBBIO KILLED、关闭攻击碰撞并开启无敌，然后才进入连续的死亡演出。最后Battle End解除镜头锁并BG OPEN，后续Faked Death/Fanning属于战后表演状态，而非第二条生命。Prefab中Stun Control只有单状态；进一步检查Library_13后，实际场景已恢复17状态的Stun Control，并且Tornado Damager是18状态而非Prefab的单状态。这说明预制体可能只是导出中的不完整层，运行场景优先。变量12/14不能直接当作普通攻击次数，尤其旧版FloatCompare引用与FSM变量类型存在历史差异，应保留绑定并以运行日志验证。证据：[眩晕](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:17344>)、[死亡](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:21854>)、[开门](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio.prefab:27053>)。

验收必须同时记录Boss与投射物状态：350/349HP阶段边界；三颗初速和Rotation；计时已经到期但炸弹在安全矩形外不能进入Antic；旋风计时到期但Boss在结束区外继续运行；Flare Glitter仍Active时闪光取消；眩晕/死亡之后旧攻击框和场地事件不会残留。对再投掷与空中选招分别保持独立随机计数，不能把所有同名事件合用一套计数。


**Trobbio 的父舞台闭环已核对。** `Library_13 / Boss Scene Trobbio` 包含完整控制器：Trapdoor Bursts 17状态、Flare Glitter 27状态、六个闪光子物体各5状态、16个地板物体各4状态，以及完整的眩晕和旋风连击控制。主Control与Prefab比较后，除了Exit 1的一条语音资源，核心动作参数相同；所以前述技能参数可以沿用，而辅助控制器必须使用场景版本。

爆柱不是Boss自行随机放特效：Boss发送ATTACK给Trapdoor Bursts，后者选择出场列和pattern；各pattern等待1.25秒后发FINAL BURST回Boss，Boss才确定最后爆点并重新出现。舞台随后等2秒回Idle。闪光也是异步过程：Flare Glitter收到FLARE GLITTER先设Active=true，等待0.5秒，选择两个布局之一；低位生成Y在16–17，高位Y在20.5–23，段间等待0.15–0.25秒，末尾再停留2秒才清除Active。这个Active是主Boss取消重复闪光的依据。如果只播放屏幕白闪而不维护这个协议，就会在场上叠加不应出现的闪光攻势。证据：[爆柱控制](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1563415>)、[闪光控制](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1590536>)。

### 从学习笔记到自己的复现代码

先建立没有美术资源的实验场：方块代表Boss，矩形/多边形标明受击框和攻击框，给每个状态显示计时与事件。苔藓之母先实现DistanceFly与俯冲的两个轴，再接撞顶与生成器；Lace先用带明确事件标记的时间轴实现两刀，再加入距离选择、前跳、反击和接管；Trobbio先把炸弹做成独立可测试对象，再接Boss选择器和舞台协议。前一个层次通过日志验收后再加下一个层次，最后替换成Sprite和特效。

每个实例都应显示“正在播放哪个动画、哪个攻击框处于激活、谁拥有移动控制”。这使三个典型错误立刻可见：等动画结束才生成本应在中途释放的攻击；受到眩晕后旧延迟仍把刀重新打开；主Boss与连击子对象同时控制玩家或身体位置。为每个错误创建一个能够稳定重现的输入序列，再修复状态生命周期。

精确的所有状态、每个动作及参数、变量初值、碰撞形状和动画事件均已展开在[完整状态参考](</Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-state-reference.md>)，无需猜测本章未逐段解释的入场/退场、舞台和接管细节。阅读一个未熟悉的状态时，先查出口，再看所有enabled动作；同状态的Wait、移动和监听通常同时执行。相邻状态共享同一动画时，后一个状态应监听现有动画，不应从头重播。对应的[原始与解码数据](</Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-data.json>)保留全部证据，便于核验或自己生成代码。
