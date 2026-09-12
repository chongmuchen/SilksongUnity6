# 典型小怪：精确规格与学习案例

<!-- AI_SPEC_START -->

## AI 精确规格：范围、证据和读取约定

本节分析三个实际存在于 `Assets/Scenes/Hornet` 的实例：`Tut_02/MossBone Fly`、`Ant_04/Bone Hunter`、`Mosstown_01/Pilgrim Moss Spitter`。它们都具有对应的 Enemy Journal Record，场景上的 `HealthManager`、`Control` 和 `tk2dSpriteAnimator.library` 提供交叉证据。分析对象是本地工程当前序列化版本，不能自动推广成所有发行版本、所有房间实例的唯一参数。

精确数据附件是 [mobs-data.json](/Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/mobs-data.json)。包含三个主 FSM 共 168 个状态、Bone Hunter 的离屏 FSM 2 个状态、两种 Grass Ball 各 5 个状态；每个动作保留顺序、enabled、全部已解码参数；另含相关 GameObject/Transform/Collider2D/Rigidbody2D/伤害组件、三个动画库的帧数/事件、GUID→路径映射。**这份 JSON 是规格组成部分，不是可选参考。** 下面的状态表给出全部边，正文解释容易误实现的地方。未进行 Unity 实际战斗回放，所以静态证明和运行实测必须区分。

实现时遵守以下约定。

1. `{"var":"名字","stored":...}` 表示读取/写入 FSM 变量；不能每次读取 stored 当作常量。`var:null` 表示 PlayMaker 的 `IsNone`，例如某动作只写 y，x 的 IsNone 表示保留原 x，绝不是写入 0。`{"owner":"self"}` 表示状态机所属对象。
2. 状态内动作按原顺序进入，各自有 OnEnter/OnUpdate/OnFixedUpdate/OnExit；`sequence=0` 不等于依次等每个动作完成。一个动作发送有效转移事件后，不能继续把余下动作当同一状态的正常流程执行。禁用动作保留在数据中用于审计，但不能运行。
3. 空转移目标（表中的 `∅`）按未绑定边保留，不能自行补目标。它们的具体 PlayMaker DLL 处理属于运行依赖；复现时至少应记录事件，禁止猜成死亡、取消回 Idle 或随机跳转。
4. 动画时长是 `frames/fps` 的正常速度名义值；帧事件时点为从 0 起的帧号/fps，落在渲染帧上交付。`Once` 到帧数才触发完成，见 [tk2dSpriteAnimator.cs:566](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimator.cs:566)。动画帧与物理帧不能混淆。
5. `SetVelocityByScale(speed)` 在 localScale.x>0 时 vx=speed，否则 vx=-speed；不是 speed×完整缩放数值。三个敌人的未翻转美术朝左，负 speed 是向前。依据 [SetVelocityByScale.cs:50](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/SetVelocityByScale.cs:50)。
6. 场景层级缩放必须作用于范围和多边形顶点；触发器中的“英雄在范围内”来自碰撞体重叠，不是把英雄当无尺寸点做中心距离比较。`AlertRange.lineOfSight=2` 从父节点到英雄做 Terrain 层线段检测，`0` 无视线检测。依据 [AlertRange.cs:105](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/AlertRange.cs:105)。
7. 世界重力为 `(0,-60)`，来自 [Physics2DSettings.asset:7](/Users/mars/workspace/SilksongUnity6/ProjectSettings/Physics2DSettings.asset:7)。本地固定步约 0.02 秒，由 [TimeManager.asset:7](/Users/mars/workspace/SilksongUnity6/ProjectSettings/TimeManager.asset:7) 的有理时间值决定。`DecelerateXY(0.8)` 表示每次进入及 FixedUpdate 乘 0.8；不是每秒减少 0.8。保留进入时那一次乘法，见 [DecelerateXY.cs:35](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/DecelerateXY.cs:35)。

### M01：MossBone Fly——上方追踪、垂直钻击、撞地回弹

**身份与基础值。** [Tut_02.unity:45955](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:45955) 是名称证据，GameObject 2632，Control component 9893。初始 HP=12（[790355](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:790355)），本体接触伤害=1（[911721](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:911721)），mass=1、gravityScale=0、冻结旋转（[105077](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:105077)）。本体 box offset=(-0.02508545,-0.19830704)，size=(0.94898224,1.4700012)；Recoil speed=15、duration=0.15 秒。死亡/受击资源由健康组件及其 effects 组件处理，不能把 `Drill Collide` 当受伤状态。

**几何。** Alert Range 为半径 0.5 的圆乘 xy=15.608528，世界半径约 7.804264；Attack Range 的局部 box 经 scale=(12.2,15.60853) 后宽约 2.0590、高约 3.8976，中心在自身下方约 5.8554。也就是“玩家在狭窄的下方走廊”，与追踪目标 y+6 很接近。Enemy Blocker 是局部位置(0,-0.28)、scale=1.12、radius=0.5 的实体圆。依据场景 [86636](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:86636)、[120637](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:120637)、[91756](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:91756)。这些尺寸是几何换算，不是新的原版配置项。

**主循环精确行为。**

| 状态 | 进入/持续行为 | 退出条件 |
|---|---|---|
| Initiate | Can Hear=NOT z_Deaf；取得 Self/Hero；按名字查两个 range、Blocker、Land Effect | Start Alert=true→Get Above，否则 FINISHED→Idle；本实例 Start Alert=false |
| Idle | 播 Fly；IdleBuzzV3 wait=0.75..1、speedMax=2、accelerationMin/Max=5/15、roam x/y=1.5/0.75；FaceDirection 用 TurnToFly，转身间隔0.5秒 | 可见英雄 AND Alert Range→Startle；TOOK DAMAGE也→Startle；Needolin内区→Pray，外区可ALERT |
| Startle | 面向 Hero；v=(0,0)；播 Startle 5帧/12fps | 完成约0.4167秒→Get Above |
| Get Above | Range Out Timer=0；播 Chase；面向 Hero（转身TurnToChase）；目标=Hero+(0,6)，AddForce=ClampMagnitude(差向量,1)×18，速度向量总长限制5.5 | 可见 AND Attack Range→Attack Antic；脱离可攻击条件的累计时间>8→Range Out；顶/左右实体接触→Bonk?；Needolin→Pray |
| Attack Antic | 播 Antic；进入时vy=12；每物理步向量乘0.8；等待0.6秒 | FINISHED→Drill |
| Drill | v=(0,-20)只设一次；播 Drill；关闭Enemy Blocker；监听碰撞；计时0.6秒 | 任意Collision2d Enter→Drill Collide；未碰撞到0.6秒→Drill End |
| Drill Collide | 播 Drill Bounce；v=(0,14)；重新开Blocker和Land Effect；vy每步乘0.85；反馈音效/震屏 | 动画4/12≈0.3333秒→Drill Recover |
| Drill Recover | 播 Fly、面向Hero；开Blocker；vy每步乘0.85；等待0.7秒 | FINISHED→Get Above；外层Needolin条件可→Pray |
| Drill End | 向量每步乘0.85；播Drill End | 6/12=0.5秒→Get Above |
| Range Out | 播Chase End | 完成→Idle；从当前位置重新建立游荡中心 |
| Bonk? / Bonk Frame | Difference=Hero.y-Self.y；若>-2，立即FINISHED；否则设vy=-4；Bonk Frame等下一帧 | 回Get Above，避免每一帧保持在贴顶判定里 |

以上关键状态源码定位：[Get Above:801568](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:801568)、[Attack Antic:802179](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802179)、[Drill:802463](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802463)、[Drill Collide:802847](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802847)。动画库入口由场景 [781198](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:781198) 引用，具体 [MossBone Fly Anim.prefab:229](</Users/mars/workspace/SilksongUnity6/Assets/Animations/Hornet Enemies/MossBone Fly Anim.prefab:229>) 定义回弹片段。

**不能省略的细节。** 脱战计时检查的是 `NOT(Can See Hero AND In Attack Range)`，不是 `NOT In Alert Range`，也没有在每次重新看见英雄时把计时器清零；仅进入 Get Above 时重置。原文本甚至读取 In Alert Range 却没用于这个布尔合取，这是可观察事实。Drill 在发起后不再追踪英雄横向位置；0.6秒最多产生12单位垂直位移（无碰撞、无外力的计算值）。Get Above 的移动使用 AddForce 而非设置朝向速度；近目标1单位内力随距离缩小，见 [ChaseObjectV2.cs:59](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/ChaseObjectV2.cs:59)。IdleBuzz 的加速度先除2000，再每固定步加到速度，并在超出游荡边界且仍向外运动时将该轴速度除1.125；参见 [IdleBuzzV3.cs:85](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/IdleBuzzV3.cs:85)。因此不能套一个“标准转向/加速度模型”替代。

**打断与终止。** `TOOK DAMAGE` 只有 Idle 的明确状态边；其他阶段仍可能被 Recoil 改速度，但不能凭经验添加“受击→Idle”。`EXTRACT` 是真正全局转移：任意状态→Extract；先模拟死亡反馈，清速度，关闭本体 collider，设为kinematic，贴到 Hero 的 `Tool Effects/Extract Point`，x偏移为朝向scale×0.25、y偏移0.25、z固定0.003；EXTRACT FINISH→Kill Dir，正scale angle=0，负scale angle=180，最后 InstaDeath。Needolin 的 Pray 是小范围游荡而非完全静止；参数wait=0.5..0.75、speed=2、accel=5..10、roam=(0.25,0.25)。`Still In Range?` 在图中保留但本主FSM无入边，不能随意插进普通循环。

**实现伪代码（核心）。**

```text
GetAbove.enter: rangeOutTimer = 0
GetAbove.fixed:
    d = hero.position + (0,6) - self.position
    rigidbody.addForce(clampMagnitude(d,1) * 18)
    velocity = clampMagnitude(velocity,5.5)
GetAbove.update, 按原动作顺序:
    canSee = lineOfSight.canSeeHero
    attackInside = attackRange.isHeroInRange()
    if canSee and attackInside: event(ATTACK); return if transitioned
    if not(canSee and attackInside): rangeOutTimer += dt
    if rangeOutTimer > 8: event(RANGE_OUT)
AttackAntic.enter: play(Antic); velocity.y=12; timer=0.6
AttackAntic.fixed: velocity *= 0.8
Drill.enter: velocity=(0,-20); blocker=false; timer=0.6
Drill.collisionEnter: event(COLLIDE)
Drill.timerExpired: event(END)
DrillCollide.enter: velocity=(0,14); blocker=true; play(Drill Bounce)
DrillCollide.fixed / DrillRecover.fixed: velocity.y *= 0.85
anyState.EXTRACT: changeState(Extract)
```

### M02：Bone Hunter——有限记忆选招、动画分段攻击与地形约束

**实例与入口。** [Ant_04.unity:34947](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:34947)，GameObject 2041，主Control 8121，114状态。HP=75、mass=1、gravityScale=2、Recoil基础速度10/持续0.15；`Camping=true`、`Ambusher=false`、`z Respawner=false`、`Chieftain Battle=false`。初始动画index=43指向Camp Idle Side。实际启动链为 `Pause→Respawn Setup→Opponent?→Init→Camp Idle`。Opponent?把 Current Target=Hero；仅外部指定Opponent时覆盖。Init按默认动画名还支持Chieftain Battle/Crowd Stamp/Guard/Dash Entry/Jump In Entry/Stadium Jump In，这些是场景配置分支，不是本普通营地实例的随机战斗招式。Init把Unalert Range解除父子关系，使它留在营地；脱战检查因此基于营地区域。见 [Init:684728](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:684728)。

**感知与碰撞。** Close Range 世界宽10.7、高4.2468262，中心相对根约(0,-0.3680557)；Far Range宽29.3156、同高；Above Range宽9.2、同高、中心y≈3.6919442。Close/Above无需视线，Far需要父节点视线。Wake Range宽16.6、高5.8246684且需要视线。尺寸来自各Transform×Box，完整偏移和引用见JSON，不能以“距离5以内”替换矩形。根实体碰撞盒宽1.1714287、高3.1205046、offset=(0.06113434,-0.8047477)，身体伤害另用子节点Body Damager宽1.0722351、高2.1843958。攻击hitbox是多个独立多边形，所有本实例DamageHero.damageDealt=1；攻击不应靠放大本体碰撞盒实现。

**决策顺序。** Camp Idle的WAKE、TOOK DAMAGE、HORNET CAGED、CAGE SPRUNG均进Startle。Idle停住、面向Current Target，等待随机0.2..0.4秒，再Check Range；Idle受击立即Check Range。Check Range按动作顺序检查：Chieftain分支→离地FALL→Needolin SING→Close→Far→Above→无条件发FAR。由于Range检查可在OnEnter发事件，重叠范围必须保留这套优先顺序。最后的无条件FAR是现存启用动作，不能因为有三个范围就想当然地在都不命中时Idle。

**有限记忆选招。**

| 上下文 | 按数组顺序的候选 | 权重 | 连续最多 | 最久未选阈值 |
|---|---|---|---|---|
| Close Range | EVADE / SLASH / JUMP / BLOCK | 1 / 1 / 1 / 1 | 2 / 2 / 2 / 1 | 全4 |
| Above Range | EVADE / SLASH / JUMP / BLOCK | 全1 | 全1 | 全4 |
| Far Range | CHASE / GDASH / JUMP | 全1 | 全2 | 全4 |

三个决策共用命名相同的Ct/Ms变量，因此历史跨这些状态保留。算法不是“每招永远25%”：先加权采样，再扫描候选的missed计数；有达到阈值的项则强制选它，多个同时超限时**数组最后一项优先**；否则若抽中项连续次数达到上限，继续抽。选中时其他候选连续计数归零，所有候选missed+1，再把选中missed=0；100次循环保护最后发events[0]。准确代码在 [SendRandomEventV3.cs:31](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/SendRandomEventV3.cs:31)，配置在 [Close Range:686633](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:686633)。

**三连斩必须按一条动画的事件切段。** T Slash Antic先停住、锁朝向、播Slash Antic，7帧/12fps≈0.5833秒。随后Triple Slash动画14帧/24fps连续播放，**后续状态仅监听，不重播**。其触发帧为0基索引1、7、8、12、13。见 [Bone Hunter Anim.prefab:1371](</Users/mars/workspace/SilksongUnity6/Assets/Animations/Hornet Enemies/Bone Hunter Anim.prefab:1371>) 和 [Triple Slash 1:687748](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:687748)。

| 相对于Triple Slash动画开始 | 子状态 | 移动和有效命中盒 |
|---|---|---|
| 0..1/24秒 | Triple Slash 1 | 开TripleSlashHit 1，向前速度25；开Enemy Clasher；退出恢复原启用值 |
| 1/24..7/24秒 | Triple Slash 2 | 无三连专用hitbox，vx每物理步×0.78 |
| 7/24..8/24秒 | Triple Slash 3 | 开TripleSlashHit 2，重新向前速度25 |
| 8/24..12/24秒 | Triple Slash 4 | 无三连专用hitbox，vx每步×0.78 |
| 12/24秒 | End Slash? | 脚前地面射线2单位无命中，或已经背对Hero→CANCEL到Recover；否则立即进5 |
| 12/24..14/24秒 | Triple Slash 5 | 开TripleSlashHit 3，向前速度30；此状态只等动画完成，13号帧事件不是再加第四次攻击 |
| 后续4/12秒 | Triple Slash Recover | 播Slash Recover；关Clasher；vx×0.78；退出刹停x，完成回Idle |

各攻击/间隔段同时从Ray Pt Slash=(−1.31,−1.98)向下投2单位射线检测Terrain，布尔经反转后在无地面时将vx置0。序列继续，但前冲受抑制；End Slash?再决定是否砍第三刀。完整多边形点数组见JSON的 `TripleSlashHit 1/2/3`，源分别位于场景 [91344](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:91344)、[92050](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:92050)、[90803](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:90803)。其中1和2命中窗各约41.7ms，是一帧24fps，不是几百毫秒全动画有效。

**其他普通战斗模块。**

| 模块 | 精确核心动作与回路 |
|---|---|
| 后撤 | Evade Antic→Evade：反向30速度持续0.1秒；Evade Skid减速；Evade End按距离/随机历史继续斩、冲刺、跳跃或Idle。EDGE可提前转Evade Edge；本实例EnemyEdgeControl.notifyFSM=0，不能假称一定由此组件发送EDGE |
| 格挡 | Block设HealthManager.invincible=true，`InvincibleFromDirection=0`，离状态恢复；持续0.75秒、速度向量×0.8；BLOCKED HIT→Block Hit，TOOK DAMAGE/计时结束→Block End，离地→Jump Fall；Block Hit后撤15速度、vx×0.8、动画2/12秒后Check Range |
| 地面冲刺 | GDash Antic8/12≈0.6667秒；GDash向前42、0.25秒、打开Dash Stab Hit与DashCollider，关根实体collider；理论无阻位移10.5。后接DashSlash Antic3/12=0.25秒且vx×0.75；GDash Slash恢复根collider，关DashCollider，向前30且vx×0.8，开DashSlashHit1/20秒；Dash Slash开SlashHit3、停x，1/18秒；再恢复链 |
| 跳跃 | Jump Dir检查方向/墙/地形，Jump L/R给Target X；Jump Aim令Jump X=clamp((TargetX−SelfX)×1.5,−15,15)；Jump Launch把vy设Jump Height=36；Jump Rise持续保持vx，vy<0→ADash?，提前着地→Land |
| 下斜俯冲 | 本图ADash?的ADASH边实际指向Dive Antic。该状态关重力、锁定目标+(0,-0.25)角度、减速0.78、播ADash Antic7/12秒；Air Dive把角度按朝向钳到215..245或295..325度，以速度45每帧写入；换Body Damager AirDive及AirDiveStab Hit；LAND由3条、距离0.2的持续地面射线产生→Dive Slash1；Wall L/R只保留外部布尔接口，见下方限制 |
| 俯冲落地斩 | Air Dive Slash6帧/20fps，事件帧1和2：Hit1有效0..0.05秒，Hit2有效0.05..0.1秒，剩余0.1..0.3秒为Recover；进入斩恢复gravityScale=2，vx×0.8；完成Idle |

定位：[Block:701118](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701118)、[GDash:691387](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:691387)、[Air Dive:707466](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:707466)。ADash?内除了75%/25%旧随机动作，还有更早的无条件ADASH发送；不要只读取最后一个RandomEvent就宣布“普通实例空中冲刺概率75%”。保留动作原顺序和早先事件的转移结果。

**俯冲墙分支的实际可达性。** Air Dive的CheckCollisionSideEnter与CheckCollisionSide均disabled；启用的BoolTestMulti读取Wall L/Wall R，但两个变量初值false，主FSM内唯一写入来自上述禁用动作。因此本普通实例未证明会自主检测撞墙并进入Wall L/R。精确复现只保留这些分支与外部写变量接口，不自行增加实时墙碰撞检测。LAND则确由启用的CheckIsCharacterGrounded（3条射线，0.2距离，每帧）产生。

**受击、边界和变体。** 控制器不是所有状态统一受击中断，普通斩击/冲刺状态没有TOOK DAMAGE边。HealthManager/Recoil/动画替换仍可能影响动作；`Tk2dPlayAnimationWithEvents.OnUpdate`发现当前动画被替换，会发配置的触发/完成事件，见 [该类:104](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/Tk2dPlayAnimationWithEvents.cs:104)。ZERO HP全局→Death，普通死亡依赖HealthManager死亡流程；仅z Respawner=true时串到Die/Respawn Ready/Start Respawn。OFFSCREEN全局→Offscreen Return→Reset；辅助Detect Offscreen以世界y<-10为条件。EnemyEdgeControl在边界外每物理步向外vx×0.85，越过额外1单位硬置vx=0，边界位置来自场景edgeL/edgeR，不能当任意平台边缘自动检测。当前对象FindChild("Enemy Clasher")没有匹配的子节点，JSON中这项必须保留“查找可能为空”的情况，不能伪造该对象的碰撞形状。

**伪代码（决策、三连）。**

```text
chooseV3(events, weights, ct[], max[], missed[], missedMax[]):
    repeat:
        candidate = weightedRandom(weights)  // 先消耗一次RNG
        forced = 最后一个满足 missed[i]>=missedMax[i] 的索引
        if forced存在: pick=forced; nextCt=1; break
        if ct[candidate]<max[candidate]: pick=candidate; nextCt=ct[pick]+1; break
        if attempts>100: send(events[0]); return
    for each candidate i: ct[i]=0; missed[i]++
    ct[pick]=nextCt; missed[pick]=0; send(events[pick])

Triple1.enter: play("Triple Slash"); enable(hit1, restoreOnExit); vx=forward*25
animation.frame1: Triple1→Triple2  // hit1自动恢复
animation.frame7: Triple2→Triple3; enable(hit2, restoreOnExit); vx=forward*25
animation.frame8: Triple3→Triple4
animation.frame12:
    if rayDownMisses or not facingHero: →TripleRecover
    else: →Triple5; enable(hit3, restoreOnExit); vx=forward*30
animation.completeFrame14: →TripleRecover
TripleRecover.enter: play("Slash Recover"); decelerationX=0.78
TripleRecover.exit: vx=0; →Idle
```

### M03：Pilgrim Moss Spitter——弹道预瞄、后跳选点、近身喷吐判定

**实例与初值。** [Mosstown_01.unity:23246](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:23246)，GameObject1358，Control6867，36状态；HP=20，本体damage=1，gravityScale=1，mass=1；初始localScale.x=-1。Praying=true、Quick Wake=true、Sniper=false。Pause等一帧→Init；Init按名字绑定Shot Point、Spit Effect、Spit Burst Damager并关喷吐伤害。因Praying=true，进Black Thread?→Spawn Silk→Pray；Wake或Attack范围命中→Possess，而Quick Wake跳过长演出到Pray End Q，1帧/12fps后Patrol。Slow Wake分支保留，不能强行让所有实例都跳过。

**范围与优先顺序。** Escape Range宽17、高5.2063885、中心(0,1.2005243)；Attack Range宽17、高8.809097、中心(0,-0.08913636)；都没有LOS要求。两者宽度相同而高度/中心不同；同一水平线上重叠很大，必须按Patrol的动作顺序先ESCAPE再ATTACK。射击点Shot Point=(-2.13,0)，近墙备用Shot Wall Check=(-0.425,0)，翻转后随根反射。Patrol速度2，Walk/Turn，turnDelay=0.5秒；有效离地检查是GroundDistance=2的3条射线（0.2版本在此状态被禁用）。来源 [Patrol:457070](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:457070)。

**发射序列。** Spit Antic锁朝向、停x、播Spit Antic并等待0.3秒；**进入前摇时**采样Hero.x与Self.x，计算：

```text
SpitX = clamp(1.1 * (heroX_at_antic - selfX_at_antic) + uniform(-1,1), -15,15)
```

它不读取Hero.vx，不跟踪前摇期间的新位置。GetXDistance的绝对差<20会发送CANCEL，但本状态CANCEL边目标空白，不能擅自将其解读为“20以内不吐”。Needolin可能转Sing Antic；离地→Fall。NEXT→In Wall?，从Shot Wall Check按已序列化射线方向/空间投2单位Terrain；无墙从Shot Point生成，有墙改从Shot Wall Check生成。BlackThread状态选择Grass Ball BlackThread Variant，否则Grass Ball。见 [Spit Antic:457578](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:457578)、[Nml Spit:461851](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461851)。

**Spit进入时子弹已生成，立即令其gravityScale=1、v=(SpitX,19)，同时开Spit Effect及Spit Burst Damager。** 不要等动画SPIT TRIGGER才生成子弹：这个事件实际负责关闭嘴边近身伤害！Spit动画5帧/12fps，第2帧即约0.1667秒发SPIT TRIGGER→Wait For Spit Anim，立刻关Burst；剩余动画等到5/12≈0.4167秒后Recover；Recover再次确保Burst关闭，等待0.1秒→Patrol。Wait For Spit Anim遇动画被中断也FINISHED，可防止嘴边伤害永久开启。依据 [Spit:458203](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:458203)、[Wait For Spit Anim:462459](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462459)、[动画:216](</Users/mars/workspace/SilksongUnity6/Assets/Animations/Hornet Enemies/Pilgrim Moss Spitter Anim.prefab:216>)。Burst本体局部position=(-1.43,-0.25)，box offset=(0.095238864,-0.20696115)，size=(1.6095222,0.9536352)，damage=1。

无碰撞且同高回落的连续物理近似：vy=19、g=60，顶点时间19/60≈0.3167秒，最高上升19²/120≈3.0083；回到发射高度约0.6333秒，水平位移约SpitX×0.6333。实际命中必须由Unity离散物理和地形决定，不能把这些派生值当额外配置。

**后撤并非固定vx向后跳。** Escape Antic先执行右向墙面射线和是否落地检查，再清Sniper，面向Hero，播放Antic。GetGroundPointClampedToEdge先尝试身后6单位落点：MinJumpDistance=2、ReductionDistance=1、MaxGroundDistance=1.5、GroundRayHeight=1.2。它会先做横向射线截短距离，然后向下探测并以每次1单位缩短；成功点还校正本体底部偏移及两侧支撑。6单位尝试失败→Attempt Larger Jump从8单位起重新搜索；仍失败→Walljump Antic。等待确认地面后才真正跃起。普通Jump Away用 `CalculateProjectileVelocity(FireAngle=60°)` 计算能到Ground Point的速度，**该源码使用碰撞盒中心作为起点**。重现原算法时保留 [CalculateProjectileVelocity.cs:72](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/CalculateProjectileVelocity.cs:72) 的计算式，不要以教科书另一种球速公式替换。Walljump改为随机朝向速度[-6,-2]、vy=20。Jump Air等待底部碰撞→Land，落地v=0，播Land3/12=0.25秒，**直接→Spit Antic**，所以后跳接吐是脚本承诺，不是再次随机选招。

**精确移植与推断边界。** RayCast2dV2的space=1使用TransformDirection，Unity的这个变换不包含负缩放；未旋转时In Wall?配置direction=(-1,0)仍向世界左，而Escape Antic的direction=(1,0)向世界右。因此“检测前方/后方墙”只能视为设计意图描述，精确复制应保留原方向/空间/TransformDirection语义，不得自动跟着scale翻转。来源 [RayCast2dV2.cs:146](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/RayCast2dV2.cs:146)。另外Spit的Burst开启动作resetOnExit=false，关闭动作在Wait For Spit Anim和Recover；若直接走FALL边，Fall自身未关闭Burst。这是静态图可见的异常路径风险，本文未声称已验证实际游戏是否会出现，也不擅自加一个统一退出关闭来改写原逻辑。

**固定点炮台变体。** Sniper=true时Patrol→Snipe Extra Recover，额外等1秒再Snipe；Snipe监听Escape、Attack、Wake的END、TOOK DAMAGE和FALL，低于Init HP也逃跑。这个分支与普通Patrol的0.1秒Recover并存。Needolin路线为Sing Antic→`Needolin `（原状态名末尾有一个空格）→Sing End→Patrol；要精确保留名称空格，不能在导入器trim后丢失边。

**子弹生命周期也属于战斗逻辑。** Grass Ball 的资源虽然在 `Enemies/Fungus 1 + 2` 旧文件夹，本实例Nml Spit/Wall Spit明确以GUID `1ed5211dd278ce149b6c6489d880eb88` 引用，黑丝变体GUID为 `86caddc9c5f6835409e4758429ab8b6a`；因此这是当前活跃依赖，不能按旧路径排除。其完整5状态：Init→Scale Up→Idle→Break→Recycle。初始恢复dynamic、启用circle、scale=(1,1)，等下一帧；Scale Up从0.5到1用0.1秒tween并开渲染/粒子；Idle遇Terrain层8、Hero Spell/Nail Attack层17的指定触发条件，或PROJECTILE BREAK/HERO DAMAGED→Break；Break清速度、关碰撞/渲染、设kinematic，播放爆裂并等1秒回池。prefab原重力0.07会被Spit覆盖成1；只照prefab读出0.07会得到完全错误的弹道。代码/资源：[Grass Ball.prefab:227](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:227>)、[393](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:393>)。dataVersion=1内联字节参数已解码，JSON包括两种子弹全部动作与物理组件。

**伪代码（完整一次后跳—射击）。**

```text
Patrol.update:
    if needolinInner after configuredDelay: →SingAntic
    if Sniper: →SnipeExtraRecover
    walk(2, turnDelay=0.5)
    if escapeRange.overlapsHero: →EscapeAntic
    else if attackRange.overlapsHero: →SpitAntic
EscapeAntic.enter:
    if configuredRightRayHitsWall: →WalljumpAntic
    if not grounded(0.2): →Fall
    Sniper=false; faceHero; play(Antic)
    found,groundPoint = findGroundBehind(6,minimum=2,step=1)
    if not found: →AttemptLargerJump  // 从8开始再找
WaitForGround.update: if grounded(0.2): →JumpAway
JumpAway.enter: v=originalBallisticFunction(colliderCenter, groundPoint,g=60,angle=60)
JumpAway.nextFrame: →JumpAir
JumpAir.bottomCollision: →Land
Land.animationComplete: →SpitAntic
SpitAntic.enter: SpitX=clamp((hero.x-self.x)*1.1+rng(-1,1),-15,15); timer=0.3
SpitAntic.timer: →InWall?→NmlSpit/WallSpit  // 这里从池生成Projectile
Spit.enter: projectile.v=(SpitX,19); projectile.gravityScale=1; burst.enabled=true
Spit.animationFrame2: burst.enabled=false; →WaitForSpitAnim
Spit.animationCompleteFrame5: →Recover
Recover.enter: burst.enabled=false; wait(0.1); →Patrol
```

### 三例共有的 Needolin、黑丝与外部依赖

Needolin不是无条件无限眩晕。EnemySingControl普通singDuration随机4..6.75秒，装备MusicianCharmTool时6.5..8秒；到时发送SING DURATION END；退出后EnemySingDuration给3..5秒冷却。来源 [EnemySingControl.cs:135](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/EnemySingControl.cs:135)、[EnemySingDuration.cs:19](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/EnemySingDuration.cs:19)。强制歌唱/BlackThread分支不同，不能把普通时长无条件覆盖。三个根对象都有BlackThreadState，其初始force/startThreaded和HP倍数已在JSON结构段保留；本文具体战斗时长与伤害针对上述普通实例配置，黑丝世界中的HP、选择子弹和歌唱可用性必须再经过该组件处理。

HealthManager、Recoil、DamageHero、事件接收器和Unity/PlayMaker生命周期是必需运行依赖；子状态没有显式死亡边不意味着不可杀死。当前场景的HealthManager damageScaling、免疫标志、反弹标志与BlackThread字段均可从JSON准确重建；不能仅用HP和ContactDamage替代整套组件。所有攻击退出清理都要执行OnExit，包括受击、死亡、回池和外部事件造成的退出。

### 可执行验收场景（给自动化实现者）

固定随机流、固定物理时间，测试驱动提供`forceState`、`setRangeOverlap`、`setRayHit`、`emitAnimationFrame`、`stepUpdate`、`stepFixed`、`emitCollision`、`assertState`、`assertVelocity`、`assertEnabled`。这是验收接口约定，不宣称原工程已有同名API。浮点时间容忍一个渲染帧，几何误差容忍1e-4；状态序列和伤害开关不得放宽。以下每行可直接转成参数化测试。

| ID | 设置/操作 | 必须满足 |
|---|---|---|
| M01-A | Idle；Alert=true、LOS=false，推进1秒 | 不因普通视觉进入Startle；令LOS=true则进入Startle |
| M01-B | Get Above；可见且Attack Range=true | 进入Attack Antic；vy先12；0.6秒后Drill；v=(0,-20)；Blocker关闭 |
| M01-C | Drill进入0.2秒时Terrain碰撞 | Drill Collide；v.y先14；Blocker重新开；4/12秒后Recover；0.7秒后Get Above |
| M01-D | Drill无碰撞0.6秒 | Drill End而非Collide；播放6/12秒后Get Above |
| M01-E | Get Above；全程不满足可攻击合取 | timer累计8秒尚未greaterThan；>8秒Range Out；不是检测Alert圆来代替 |
| M01-F | 任意攻击状态发EXTRACT | collider=false、kinematic=true、清速度；EXTRACT FINISH按scale决定0/180死亡方向 |
| M02-A | 强制Close Range，Ct Block=1且无missed超限；RNG先抽BLOCK再SLASH | 第一次应重抽，最终SLASH；不能连续BLOCK；missed全更新 |
| M02-B | Close Range；Ms Evade=4、Ms Block=4 | 强制选数组后面的BLOCK；验证不是取第一个超时项 |
| M02-C | 从T Slash Antic开始；地面充足、始终面对Hero；推进动画到1/7/8/12/14帧 | hit1→无→hit2→无→hit3→无；动画只开始一次；无第四刀 |
| M02-D | Triple Slash4结束前令脚前射线无地面或玩家换到背后 | 第三刀被取消，直接Recover；此前刀段也不能无视脚前无地面继续推进 |
| M02-E | Block进入，之后BLOCKED HIT | invincible离Block时恢复；Block Hit后退15，2/12秒后Check Range |
| M02-F | GDash无阻，0.25秒 | vx恒向前42，约10.5位移；根collider关、DashCollider开；后续恢复为相反 |
| M02-G | Air Dive地面命中 | 恢复gScale=2；Air Dive Slash帧0..1开Hit1、1..2开Hit2、2..6恢复，不把冲刺hitbox遗留 |
| M03-A | Patrol同时Escape/Attack=true | ESCAPE优先；不发射；模拟后跳着地后必须进入Spit Antic |
| M03-B | Spit Antic进入hero.x-self.x=10，固定RNG=0；前摇中英雄移动到另侧 | SpitX=11；发射仍vx=11而非重新瞄准；vy=19、gScale=1 |
| M03-C | Spit进入后推进0/2/5帧 | 0帧子弹已经存在且Burst开；2帧Burst关；5帧进Recover；0.1秒后Patrol |
| M03-D | 正常Shot Point前有墙，备用点可用 | 同一子弹改从Shot Wall Check生成；不直接把Shot Point塞进墙里 |
| M03-E | 6单位落点搜索失败，8单位有落脚；然后两个都失败 | 第一种走普通弹道后跳；第二种走Walljump，vy=20、朝向速度绝对值2..6 |
| M03-F | 子弹碰Terrain/收到HERO DAMAGED，然后等1秒再重用 | Break立即失去碰撞能力，1秒回池；再Init恢复动态/碰撞，不能保留上次kinematic与失活状态 |

### 全部状态和转移索引

以下由精确JSON生成；`∅`表示原数据空目标，`—`表示无显式状态边。动作参数、顺序、启用标记在同名JSON的`fsms[].states[]`，不是省略成“播放对应动画”的黑盒。场景演出/复活分支也完整列出，但并非全部能由普通交战入口到达。

#### MossBone Fly / Control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:800909>) | `ALERT`→`Startle`；`TOOK DAMAGE`→`Startle`；`NEEDOLIN`→`Pray`；`DEAF`→`∅` | 8/8 |
| [Initiate](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:801348>) | `FINISHED`→`Idle`；`ALERT`→`Get Above` | 9/9 |
| [Get Above](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:801568>) | `ATTACK`→`Attack Antic`；`RANGE OUT`→`Range Out`；`BONK`→`Bonk?`；`NEEDOLIN`→`Pray` | 14/15 |
| [Attack Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802179>) | `FINISHED`→`Drill` | 7/7 |
| [Drill](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802463>) | `COLLIDE`→`Drill Collide`；`END`→`Drill End` | 6/6 |
| [Drill End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802727>) | `FINISHED`→`Get Above` | 3/3 |
| [Drill Collide](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802847>) | `FINISHED`→`Drill Recover` | 7/7 |
| [Startle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803155>) | `FINISHED`→`Get Above` | 4/4 |
| [Drill Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803370>) | `FINISHED`→`Get Above`；`NEEDOLIN`→`Pray` | 7/8 |
| [Range Out](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803669>) | `FINISHED`→`Idle` | 2/2 |
| [Still In Range?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803771>) | `ALERT`→`Get Above`；`FINISHED`→`Idle` | 5/5 |
| [Bonk?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803992>) | `FINISHED`→`Bonk Frame` | 5/5 |
| [Pray](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:804223>) | `END`→`Pray End`；`SING DURATION END`→`Pray End` | 4/4 |
| [Pray End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:804501>) | `FINISHED`→`Get Above` | 1/1 |
| [Bonk Frame](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:804584>) | `FINISHED`→`Get Above` | 1/1 |
| [Extract](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:804649>) | `EXTRACT FINISH`→`Kill Dir` | 11/11 |
| [Extract Kill](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:805119>) | — | 1/1 |
| [Kill Dir](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:805189>) | `FINISHED`→`Extract Kill` | 3/3 |

启动：`Initiate`；全局边：`EXTRACT`→`Extract`。

#### Bone Hunter / Control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Init](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:684728>) | `FINISHED`→`∅`；`AMBUSH`→`Ambush Ready`；`CAMP`→`Camp Idle`；`COMBAT`→`Set Opponent`；`CROWD`→`Crowd Idle`；`GUARD`→`Guard Idle`；`DASH ENTRY`→`Dash Entry Ready`；`JUMP IN`→`Jump In Ready`；`STADIUM JUMP IN`→`Jump In Setup` | 26/26 |
| [Ambush Ready](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:685498>) | `WAKE`→`Ambush Antic`；`BATTLE START`→`Battle Ambush Antic`；`RESPAWN`→`Ambush Antic` | 7/7 |
| [Ambush Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:685765>) | `FINISHED`→`Dig Out` | 4/4 |
| [Dig Out](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:685910>) | `FINISHED`→`Dig Out 2` | 7/7 |
| [Activate](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:686153>) | `FINISHED`→`Recover` | 4/4 |
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:686328>) | `FINISHED`→`Check Range`；`TOOK DAMAGE`→`Check Range`；`UNALERT`→`Dig In 1` | 7/7 |
| [Close Range](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:686633>) | `EVADE`→`Evade Antic`；`SLASH`→`T Slash Antic`；`JUMP`→`Jump Dir`；`BLOCK`→`Block` | 1/1 |
| [Far Range](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:686883>) | `CHASE`→`Chase`；`GDASH`→`GDash Antic`；`JUMP`→`Jump Dir` | 3/4 |
| [Above Range](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:687306>) | `EVADE`→`Evade Antic`；`SLASH`→`T Slash Antic`；`JUMP`→`Jump Dir`；`BLOCK`→`Block` | 1/1 |
| [T Slash Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:687556>) | `FINISHED`→`Triple Slash 1` | 5/5 |
| [Triple Slash 1](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:687748>) | `FINISHED`→`Triple Slash 2` | 8/8 |
| [Evade Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688152>) | `FINISHED`→`Evade` | 2/2 |
| [Evade](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688271>) | `FINISHED`→`Evade Skid`；`EDGE`→`Evade Edge` | 5/6 |
| [Evade Skid](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688496>) | `FINISHED`→`Evade End` | 2/2 |
| [Dig Out 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688605>) | `FINISHED`→`Activate` | 3/3 |
| [Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688758>) | `FINISHED`→`Idle` | 1/1 |
| [Evade End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688841>) | `END`→`Idle`；`GDASH`→`GDash Antic`；`SLASH`→`T Slash Antic`；`JUMP`→`Jump Dir`；`COMBAT`→`Combat Choice` | 3/3 |
| [Dash Slash Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689065>) | `FINISHED`→`Long Slash Recover?` | 2/2 |
| [Jump Dir](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689167>) | `L`→`Jump L`；`R`→`Jump R`；`CANCEL`→`Check Range` | 4/4 |
| [Jump L](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689512>) | `FINISHED`→`Jump Aim` | 1/1 |
| [Jump R](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689591>) | `FINISHED`→`Jump Aim` | 1/1 |
| [Jump Aim](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689670>) | `FINISHED`→`Jump Antic` | 4/4 |
| [Jump Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689838>) | `FINISHED`→`Jump Launch` | 3/3 |
| [Jump Launch](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689990>) | `FINISHED`→`Jump Rise` | 4/4 |
| [Jump Rise](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:690175>) | `FINISHED`→`ADash?`；`LAND`→`Land` | 4/5 |
| [Jump Fall](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:690449>) | `LAND`→`Land` | 4/4 |
| [Land](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:690626>) | `FINISHED`→`Idle` | 6/6 |
| [GDash Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:690885>) | `FINISHED`→`GDash`；`EVADE`→`GDash Away` | 5/6 |
| [Dash Slash](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:691233>) | `FINISHED`→`Dash Slash Recover` | 4/4 |
| [GDash](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:691387>) | `FINISHED`→`DashSlash Antic`；`EDGE`→`DashSlash Antic` | 11/11 |
| [GDash Slash](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:691739>) | `FINISHED`→`Dash Slash` | 8/8 |
| [ADash?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692036>) | `FALL`→`Jump Fall`；`ADASH`→`Dive Antic`；`RANGE OUT`→`ADash Range Out` | 4/4 |
| [ADash Range Out](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692343>) | `FINISHED`→`Jump Fall` | 2/2 |
| [ADash Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692438>) | `FINISHED`→`ADash Clamp` | 5/5 |
| [ADash](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692641>) | `FINISHED`→`ADash Effect` | 10/10 |
| [ADash Fall](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692993>) | `LAND`→`Land` | 7/7 |
| [Check Side](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:693286>) | `LAND`→`Skid`；`FINISHED`→`ADash Fall`；`WALL L`→`Wall L`；`WALL R`→`Wall R` | 6/6 |
| [Skid](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:693565>) | `FINISHED`→`Idle` | 7/7 |
| [Wall L](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:693875>) | `FINISHED`→`Walljump`；`CANCEL`→`ADash CanCollide` | 9/9 |
| [Wall R](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:694297>) | `FINISHED`→`Walljump`；`CANCEL`→`ADash CanCollide` | 9/9 |
| [Walljump](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:694719>) | `FINISHED`→`Jump Fall` | 4/4 |
| [Check Range](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:694886>) | `SING`→`Sing`；`CLOSE`→`Close Range`；`FAR`→`Far Range`；`ABOVE`→`Above Range`；`FINISHED`→`Idle`；`COMBAT`→`Combat Choice`；`FALL`→`Jump Fall` | 9/10 |
| [Chase](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:695405>) | `JUMP`→`Jump Dir`；`SLASH`→`T Slash Antic`；`CLOSE`→`Close Range`；`ABOVE`→`Above Range` | 8/9 |
| [Camp Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:695890>) | `TOOK DAMAGE`→`Startle`；`WAKE`→`Startle`；`HORNET CAGED`→`Startle`；`CAGE SPRUNG`→`Startle` | 4/4 |
| [Startle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696144>) | `FINISHED`→`Idle` | 6/6 |
| [Reset](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696436>) | `FINISHED`→`Ambush Ready` | 3/3 |
| [Pause](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696620>) | `FINISHED`→`Respawn Setup` | 2/2 |
| [Sing](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696703>) | `CANCEL`→`Sing End`；`SING DURATION END`→`Sing End` | 3/3 |
| [Sing End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696911>) | `FINISHED`→`Idle` | 1/1 |
| [Death](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696994>) | `RESPAWN`→`Die` | 3/3 |
| [DashSlash Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697168>) | `FINISHED`→`GDash Slash` | 3/3 |
| [ADash Clamp](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697296>) | `L`→`Clamp L`；`R`→`Clamp R` | 1/1 |
| [Clamp L](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697416>) | `FINISHED`→`ADash` | 2/2 |
| [Clamp R](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697545>) | `FINISHED`→`ADash` | 2/2 |
| [Set Opponent](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697674>) | `FINISHED`→`Idle` | 3/3 |
| [Combat Choice](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697796>) | `EVADE`→`Evade Antic`；`CHASE`→`Combat Chase`；`SLASH`→`T Slash Antic`；`ADASH`→`Chief Jump`；`GDASH`→`GDash Centre`；`CENTRE`→`Centre Choice`；`COMBAT END`→`End Combat`；`UNALERT`→`Dig In 1` | 5/5 |
| [Combat Chase](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698223>) | `FINISHED`→`Combat Choice` | 4/4 |
| [Chief Jump](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698390>) | `L`→`Jump L`；`R`→`Jump R` | 3/3 |
| [Evade Edge](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698589>) | `FINISHED`→`Evade Skid` | 1/1 |
| [Centre Choice](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698661>) | `CHASE`→`Combat Chase`；`GDASH`→`GDash Centre` | 1/1 |
| [GDash Centre](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698794>) | `FINISHED`→`GDash` | 3/3 |
| [End Combat](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698946>) | `FINISHED`→`Combat End Idle` | 6/6 |
| [Combat End Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699173>) | `FINISHED`→`Idle`；`TOOK DAMAGE`→`Idle` | 3/3 |
| [Crowd Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699323>) | `BATTLE START`→`Enter Idle`；`BEAT`→`Beat Pause` | 3/3 |
| [Enter Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699447>) | `FINISHED`→`Enter Antic` | 0/2 |
| [Enter Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699552>) | `FINISHED`→`Enter Leap` | 3/3 |
| [Enter Leap](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699706>) | `FINISHED`→`Enter Fall` | 9/9 |
| [Enter Fall](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700041>) | `LAND`→`Enter Land` | 7/7 |
| [Enter Land](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700336>) | `FINISHED`→`Idle` | 2/2 |
| [Dig In 1](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700452>) | `FINISHED`→`Dig In 2`；`NO DIG`→`Unalert To Guard` | 4/4 |
| [Dig In 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700589>) | `FINISHED`→`Reset` | 5/5 |
| [Beat Pause](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700788>) | `FINISHED`→`Do Beat`；`BATTLE START`→`Enter Idle` | 1/1 |
| [Do Beat](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700877>) | `FINISHED`→`Crowd Idle` | 1/1 |
| [Battle Ambush Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700956>) | `FINISHED`→`Dig Out` | 5/5 |
| [Block](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701118>) | `BLOCKED HIT`→`Block Hit`；`TOOK DAMAGE`→`Block End`；`FINISHED`→`Block End`；`FALL`→`Jump Fall` | 7/7 |
| [Block End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701437>) | `FINISHED`→`Idle` | 2/2 |
| [Block Hit](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701554>) | `FINISHED`→`Check Range` | 4/5 |
| [ADash CanCollide](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701747>) | `END`→`ADash Fall`；`COLLIDE`→`Check Side` | 4/4 |
| [Guard Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701936>) | `TOOK DAMAGE`→`Startle`；`BLOCKED HIT`→`Block Hit`；`WAKE`→`Startle` | 4/4 |
| [Unalert To Guard](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702187>) | `FINISHED`→`Guard Idle` | 2/2 |
| [ADash Effect](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702309>) | `FINISHED`→`ADash CanCollide` | 1/1 |
| [Offscreen Return](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702397>) | `FINISHED`→`Reset` | 2/4 |
| [Die](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702555>) | `FINISHED`→`Respawn Ready` | 10/10 |
| [Respawn Ready](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702850>) | `RESPAWN`→`Start Respawn` | 0/0 |
| [Start Respawn](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702911>) | `FINISHED`→`Respawn Antic` | 3/3 |
| [Respawn Setup](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703064>) | `FINISHED`→`Opponent?` | 4/4 |
| [Respawn Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703207>) | `FINISHED`→`Dig Out` | 3/3 |
| [Dash Entry Ready](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703318>) | `BATTLE START`→`Dash Entry Activate` | 8/8 |
| [Dash Entry Activate](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703545>) | `FINISHED`→`GDash` | 4/4 |
| [Long Slash Recover?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703688>) | `FINISHED`→`Idle`；`TOOK DAMAGE`→`Idle` | 5/5 |
| [GDash Away](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703862>) | `FINISHED`→`GDash` | 3/3 |
| [Jump In](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704014>) | `FINISHED`→`Jump In Activate`；`EVADE`→`Jump In Alt` | 8/8 |
| [Jump In Activate](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704263>) | `FINISHED`→`Jump Fall 2` | 1/1 |
| [Jump In Ready](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704343>) | `BATTLE START`→`Jump In` | 7/7 |
| [Jump Fall 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704553>) | `LAND`→`Land 2` | 3/3 |
| [Land 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704712>) | `FINISHED`→`Wait For Hero` | 4/4 |
| [Wait For Hero](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704909>) | `WAKE`→`Startle`；`TOOK DAMAGE`→`Startle` | 3/3 |
| [Jump In Alt](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:705099>) | `FINISHED`→`Jump In Activate` | 7/7 |
| [Triple Slash 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:705309>) | `FINISHED`→`Triple Slash 3` | 5/5 |
| [Triple Slash 3](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:705598>) | `FINISHED`→`Triple Slash 4` | 8/8 |
| [Triple Slash 4](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:705995>) | `FINISHED`→`End Slash?` | 5/5 |
| [Triple Slash 5](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:706284>) | `FINISHED`→`Triple Slash Recover` | 8/8 |
| [Triple Slash Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:706681>) | `FINISHED`→`Idle` | 6/6 |
| [End Slash?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:706996>) | `FINISHED`→`Triple Slash 5`；`CANCEL`→`Triple Slash Recover` | 2/2 |
| [Dive Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:707241>) | `FINISHED`→`Air Dive` | 6/6 |
| [Air Dive](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:707466>) | `LAND`→`Dive Slash 1`；`WALL L`→`Wall L`；`WALL R`→`Wall R` | 14/16 |
| [Dive Slash 1](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708137>) | `FINISHED`→`Dive Slash 2` | 6/6 |
| [Dive Slash 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708415>) | `FINISHED`→`Dive Slash Recover` | 3/3 |
| [Dive Slash Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708544>) | `FINISHED`→`Idle` | 1/1 |
| [Opponent?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708620>) | `FINISHED`→`Init` | 3/3 |
| [Jump In Setup](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708736>) | `FINISHED`→`Jump In 2` | 10/10 |
| [Jump In 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:709119>) | `FINISHED`→`Jump In End` | 15/16 |
| [Jump In End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:709694>) | `FINISHED`→`Jump Fall` | 4/4 |
| [Jump Fall 3](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:709869>) | `LAND`→`Land` | 5/5 |

启动：`Pause`；全局边：`ZERO HP`→`Death`；`OFFSCREEN`→`Offscreen Return`。

#### Bone Hunter / Detect Offscreen

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:630791>) | `OFFSCREEN`→`Offscreen` | 1/1 |
| [Offscreen](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:630899>) | `FINISHED`→`Idle` | 2/2 |

启动：`Idle`；全局边：无。

#### Pilgrim Moss Spitter / Control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Pause](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:455756>) | `FINISHED`→`Init` | 1/1 |
| [Init](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:455821>) | `FINISHED`→`Patrol`；`PRAY`→`Black Thread?`；`SNIPE`→`Snipe` | 8/8 |
| [Spawn Silk](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456057>) | `FINISHED`→`Pray` | 3/3 |
| [Pray](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456247>) | `WAKE`→`Possess` | 8/8 |
| [Possess](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456555>) | `FINISHED`→`Possess Shake`；`QUICK`→`Pray End Q` | 3/3 |
| [Possess Shake](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456704>) | `FINISHED`→`Pray End` | 1/1 |
| [Pray End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456815>) | `FINISHED`→`Patrol` | 2/2 |
| [Pray End Q](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456926>) | `FINISHED`→`Patrol` | 3/3 |
| [Patrol](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:457070>) | `ATTACK`→`Spit Antic`；`ESCAPE`→`Escape Antic`；`SNIPE`→`Snipe Extra Recover`；`NEEDOLIN`→`Sing Antic`；`FALL`→`Fall` | 8/9 |
| [Spit Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:457578>) | `NEXT`→`In Wall?`；`CANCEL`→`∅`；`FALL`→`Fall`；`NEEDOLIN`→`Sing Antic` | 17/17 |
| [Spit](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:458203>) | `FINISHED`→`Recover`；`FALL`→`Fall`；`SPIT TRIGGER`→`Wait For Spit Anim` | 7/7 |
| [Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:458522>) | `NEXT`→`Patrol`；`FALL`→`Fall` | 4/4 |
| [Escape Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:458707>) | `FINISHED`→`Wait For Ground`；`CANCEL`→`Attempt Larger Jump`；`IN AIR`→`Fall`；`WALL`→`Walljump Antic` | 9/9 |
| [Jump Away](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:459198>) | `FINISHED`→`Jump Air` | 6/8 |
| [Jump Air](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:459508>) | `LAND`→`Land` | 1/1 |
| [Land](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:459625>) | `FINISHED`→`Spit Antic` | 3/3 |
| [Snipe](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:459803>) | `ATTACK`→`Spit Antic`；`ESCAPE`→`Escape Antic`；`TOOK DAMAGE`→`Escape Antic`；`END`→`Snipe End`；`FALL`→`Fall` | 5/5 |
| [Snipe Extra Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460151>) | `FINISHED`→`Snipe`；`FALL`→`Fall`；`TOOK DAMAGE`→`Escape Antic` | 3/3 |
| [Spit Instead?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460318>) | `ATTACK`→`Spit Antic`；`FINISHED`→`Patrol` | 1/1 |
| [Attempt Larger Jump](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460447>) | `FINISHED`→`Wait For Ground`；`CANCEL`→`Walljump Antic` | 3/3 |
| [Jump Cancel Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460621>) | `FINISHED`→`Spit Instead?` | 1/1 |
| [Not Grounded](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460694>) | `FINISHED`→`Patrol` | 1/1 |
| ['Needolin '](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460759>) | `END`→`Sing End`；`SING DURATION END`→`Sing End` | 3/3 |
| [Walljump Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460970>) | `FINISHED`→`Wait For Ground 2` | 1/1 |
| [Walljump](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461053>) | `FINISHED`→`Jump Air` | 5/5 |
| [Snipe End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461254>) | `FINISHED`→`Patrol` | 0/0 |
| [Wait For Ground](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461315>) | `FINISHED`→`Jump Away` | 1/1 |
| [Wait For Ground 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461427>) | `FINISHED`→`Walljump` | 1/1 |
| [Fall](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461539>) | `FINISHED`→`Jump Air` | 2/2 |
| [In Wall?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461644>) | `SPIT`→`Nml Spit`；`WALL`→`Wall Spit` | 1/1 |
| [Nml Spit](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461851>) | `FINISHED`→`Spit` | 3/3 |
| [Wall Spit](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462010>) | `FINISHED`→`Spit` | 3/3 |
| [Black Thread?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462169>) | `FINISHED`→`Spawn Silk` | 2/2 |
| [Sing Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462260>) | `FINISHED`→`Needolin ` | 2/2 |
| [Sing End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462376>) | `FINISHED`→`Patrol` | 1/1 |
| [Wait For Spit Anim](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462459>) | `FINISHED`→`Recover` | 2/2 |

启动：`Pause`；全局边：无。

#### Grass Ball / grass ball control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:257>) | `TERRAIN`→`Break`；`PROJECTILE BREAK`→`Break`；`HERO DAMAGED`→`Break` | 3/3 |
| [Break](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:393>) | `FINISHED`→`Recycle` | 12/12 |
| [Init](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:660>) | `FINISHED`→`Scale Up` | 5/5 |
| [Recycle](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:777>) | — | 1/1 |
| [Scale Up](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:831>) | `FINISHED`→`Idle` | 6/6 |

启动：`Init`；全局边：无。

#### Grass Ball BlackThread Variant / grass ball control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:257>) | `TERRAIN`→`Break`；`PROJECTILE BREAK`→`Break`；`HERO DAMAGED`→`Break` | 3/3 |
| [Break](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:393>) | `FINISHED`→`Recycle` | 12/12 |
| [Init](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:660>) | `FINISHED`→`Scale Up` | 5/5 |
| [Recycle](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:777>) | — | 1/1 |
| [Scale Up](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:831>) | `FINISHED`→`Idle` | 6/6 |

启动：`Init`；全局边：无。


<!-- AI_SPEC_END -->

<!-- HUMAN_GUIDE_START -->

## 人类学习版：从三个小怪理解可复现的战斗

这三个案例分别训练三种能力：MossBone Fly教你把“靠近”和“攻击承诺”分开；Bone Hunter教你把决策、动画、有效命中窗分开；Pilgrim Moss Spitter教你把感知、选落点、弹道和近身伤害分开。学习时不要先写一个大Update，根据玩家距离随时换速度。先搭好身体、伤害体、感知体，再记录“进入状态时做一次什么、状态期间持续做什么、什么事件让它结束”。

所有数值取自本地工程的三个具体实例，并非靠录像目测。对应源文件与全部参数、碰撞多边形、动画帧事件在 [mobs-data.json](/Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/mobs-data.json)。想复现普通循环可以跟随以下步骤；想连同每条演出、脱战、歌唱和复活路线重建，使用本节后附的状态与验收数据。静态解码已经完成，但尚未做原项目运行轨迹对照，不能把表中计算值说成帧录像测量值。

### 第一课：MossBone Fly为何像是在“瞄准头顶”

它有一个很宽的警戒圆，也有一个狭窄的攻击矩形。警戒圆半径约7.80；攻击矩形在怪物下方约5.86单位，宽约2.06、高约3.90。这比“和玩家距离小于6就攻击”准确得多：玩家在侧面很近时，它还会继续寻找上方位置；玩家位于下方狭窄通道时才开始蓄力。飞行目标一直是玩家上方6单位，但只是用力推着身体靠过去，不会瞬移到目标。

先实现警戒前的游荡：以进入Idle时的位置为中心，x范围1.5、y范围0.75，速度每轴最多2；每0.75..1秒换一次小加速度。实现时原代码把加速度5..15先除2000，按固定物理帧累加；不要看到“15”就直接用15单位每秒平方。然后接入视线：只有玩家在警戒圆内并且无遮挡，才播放0.4167秒的惊动动画进入追踪。Idle被击中同样会惊动。

进入Get Above后，用目标差向量限长1，再乘18施加力，总速度限长5.5。玩家在攻击矩形内且可见时，进入0.6秒前摇。前摇不继续追踪：它先把y速度设为12并快速减速，看起来会有一点上提。前摇结束把速度设为(0,-20)，进入钻击。这里是攻击承诺点：玩家之后跑开，它也不会像导弹一样转弯追踪。

钻击有两种不同的结尾。没有撞到东西，0.6秒后播0.5秒收招再寻找头顶；撞到东西则向上弹14，播0.3333秒回弹，再等待0.7秒恢复。回弹/恢复每个物理帧把y速度乘0.85。攻击前关闭的Enemy Blocker在撞地后重新开启。复现时必须同时做好这条碰撞体开关，不能只让动画看起来像撞地。

这只怪的身体接触伤害为1、HP=12，没有额外钻头武器盒；钻击的危险主要来自身体沿竖直线路快速移动。用独立触发器做警戒和攻击条件，用实体碰撞做落地，两者职责分开。若让攻击范围触发器也报告“撞地”，它会在开始钻击时莫名提前回弹。

一个容易误读的地方是脱战：程序累计“不同时满足可见和攻击范围”的时间，累计超过8秒才退回Idle。它不是离开警戒圆即复位，也不是每次重新看见玩家就重置计时。歌唱、提取和碰顶还有额外分支：歌唱进入较小的悬停范围；提取是能从任何状态抢占的终止流程；碰顶先向下脱离，再至少隔一帧重新追踪。复现时把这些当明确事件，不要添加自己想象的受击硬直。

最小练习顺序是：在空房间放一个不移动的玩家，让它完成“警戒—飞到上方—蓄力—钻击—撞地—恢复”；再在前摇中横向移走，确认钻击不追踪；最后移走地板，确认走到Drill End而非碰撞回弹。只要这三组结果不同且符合数值，核心机制就已经成立。完整源码入口：[Tut_02 Control](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:800892)。

### 第二课：Bone Hunter的复杂来自几层规则叠加

Bone Hunter有114个状态，但不是114个招式。大量状态是“在营地坐着”“从地下出现”“成为观众”“跟首领打”“听歌”“离屏回收”“复活”等入口和演出。先只看这个Ant_04普通营地实例：HP75、重力系数2、身体伤害1。开场坐着，玩家靠近或攻击唤醒；之后Idle随机等0.2..0.4秒，按近、远、上方区域决定选哪组动作。

近身可以后撤、三连斩、跳跃或格挡；远处可以追赶、地面冲刺或跳跃。初始权重都相同，但程序记住“这招连续用了几次”“这招有几次没用”。近身连用最多2次，格挡最多1次；4次没选中便会强制补选。玩家因此感觉变化多，又不会连续五次吃同一招。学习实现时只写四个随机25%会丢失这种节奏。必须建立Ct和Ms两组计数，并让相同动作在近/远等不同决策里共享计数；同时保留数组顺序，因为多个动作都逾期时源码优先后面的一个。

三连斩尤其适合学习动画如何驱动命中。前摇Slash Antic持续7/12秒，约0.5833秒。真正的Triple Slash只是一条14帧、24fps的动画，但控制状态把它拆成五段：第一刀、间隔、第二刀、间隔、第三刀。第一刀只在第0帧到第1帧之间有hitbox，第二刀在第7到8帧，第三刀在第12帧到动画结束。中间并不是持续的大范围伤害。第1、7、8、12帧的事件让状态切换；后续状态只监听当前动画，不把动画从头播放。

可以先画三种颜色的多边形测试碰撞框：红色是Hit1、蓝色是Hit2、绿色是Hit3。每次只启用当前那一个。第一刀向前速度25；间隔速度每物理步乘0.78；第二刀再把前冲速度恢复25；第三刀用30。所有这些多边形在附件中有真实顶点，直接导入即可；不要把身体矩形当刀光范围。退出刀段就关闭该hitbox，受击或死亡造成退出也一样处理。

第三刀还有两个门槛：面前脚下没有地面，或玩家已经绕到背后，就取消第三刀进入恢复。这使怪物对地形和玩家绕背产生反应，但没有把整个连段变成随时任意转向。对玩家来说，第一刀的前摇是识别窗口，两刀间隔是绕位机会；对程序来说，这分别是动画事件和明确的射线/朝向测试。这是设计解释，实际规则仍按源码表实现。

格挡也应与受击分开。Block打开无敌标志，最多0.75秒；被BLOCKED HIT事件打到后，用Block Hit动画后退15速度，约0.1667秒后重新选招。退出Block恢复无敌标志，不能在Block End还残留无敌。别把“持盾视觉”直接理解为永久前方无敌：本实例动作的InvincibleFromDirection=0，具体可挡攻击仍由健康系统判定。

地面冲刺是另一条清晰的时间线：0.6667秒前摇，速度42前冲0.25秒；随后0.25秒减速准备，再接两段短斩。前冲时它把普通实体碰撞盒换成DashCollider，并开启Dash Stab Hit；进入斩击时再换回。这里最常见的复现错误是让旧碰撞体和新碰撞体同时生效，导致贴墙卡死、重复伤害或位移过短。

跳跃不是单纯抛物线演出。先决定落点方向，x速度=到目标x差的1.5倍并限制在±15，y起速36。到下降阶段，若进入下方攻击范围，会转空中前摇后俯冲。俯冲速度45、角度按朝向钳制在向下约45..75度范围，落地再接两个短伤害窗。俯冲落地检测是启用的3条地面射线；墙边分支则读取默认false的Wall L/R变量，当前普通实例负责写这些变量的碰撞动作被禁用。所以不能看见Wall L/R状态就自动加一套撞墙判断，只保留外部写变量接口来测试该分支。普通图中的ADASH事件实际上跳去Dive Antic；旧的水平ADash分支仍在图里，但不能只因为名字存在就混成同一招。认清“当前能走到哪条边”比只统计状态名称更重要。

复现练习先固定随机流，让前三次选择可预期：例如斩、后撤、格挡。随后加计数限制，再让玩家绕背、把怪物推到平台边缘、由测试驱动写入Wall L/R来验证保留的墙分支，逐项核对：第三刀是否取消、后退是否被边界制动、冲刺碰撞盒是否恢复。最后才接营地唤醒、脱战、歌唱和复活。附件保留全部114状态，不需要把演出功能删掉，分层实现即可。入口：[Ant_04 Control](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:684711)。

### 第三课：Pilgrim Moss Spitter先决定距离，再决定吐在哪里

这只怪HP20、身体伤害1、重力系数1。它并不是看到玩家就一直开炮：同高度靠近时常先逃，因为Escape Range与Attack Range同样宽17，但纵向位置/高度不同，而且程序先检查Escape。先把这两个矩形画在编辑器中，移动玩家上下位置，就能直观看到哪些地方触发后跳，哪些地方允许吐弹。少了范围形状，行为就会与原版完全不同。

后跳的第一步是选落点。它从身后6单位开始找地面；碰到墙会缩短距离，没有地面则每次缩短1，最短2。如果这条搜索失败，改从8单位重新找；还是失败才进入墙跳式后备动作。找到落点后等自己确实落地，再按60度发射角计算跳跃初速度。这里的“后跳6单位”是希望找地的位置，不是保证飞行距离6，也不是硬编码后退速度。墙跳后备才直接用随机2..6的水平速度和y速度20。

最值得保留的一条承诺是：**它后跳落地后直接吐弹**。Land停住并播0.25秒落地动画，接Spit Antic，不重新随机决策。如果你的复现后跳落地后还走来走去等玩家靠近，会丢掉这个反击节奏。

吐弹前摇0.3秒。进入前摇就记下玩家x坐标，算 `(玩家x−自己x)×1.1`，再加[-1,1]随机扰动，限制在[-15,15]；这个结果是子弹vx。玩家在前摇中移动不会更新这个值。发射时vy固定19、重力为60，因此子弹上抛到约3单位高度再落下。它没有追踪速度预判，但1.1的距离系数和扰动给出可变化的落点。复现时要将“采样时点”固定在前摇开始，不要每帧重算，亦不要按发射时玩家的位置再瞄准一次。

复制墙面检测时还有一个源码细节：它使用TransformDirection，方向不会自动随着负x缩放反射；当前In Wall?配置世界左向，Escape Antic配置世界右向。先精确保留源码，再单独决定自己的游戏是否要改成始终检测面向方向。

射击动画里的SPIT TRIGGER名字很容易误导。真实逻辑在进入Spit时已经生成并发射子弹，同时启用嘴边的Spit Burst Damager。动画第2帧、约0.1667秒发生SPIT TRIGGER，它的工作是**关闭嘴边短程伤害**，并继续等动画结束！把它当成“发射子弹事件”会把整次远程攻击延后，还可能让近身伤害从未出现。Spit总动画5/12秒，随后Recover等0.1秒再巡逻。

还要处理贴墙发射。正常生成点在嘴前2.13单位，可能伸进墙里；发射前从备用点检测到墙，就把生成位置改成只前移0.425的点。子弹本身是独立五状态对象：恢复动态/碰撞→0.1秒放大→飞行→命中后立即关闭碰撞→1秒后回池。子弹prefab默认重力0.07，但发射动作会改成1。只复制prefab默认值，子弹就会像漂浮孢子而不是原来那条上抛弧线。

学习测试可以从站桩发射开始：在前摇开始固定玩家右侧10单位，随机值设0，预期vx=11；前摇中突然换到左边，发射仍应向右。再验证嘴边伤害只持续到第2帧；最后加平台边缘和墙，验证后跳找点及备用发射点。这些行为全部稳定后再接开场祈祷、快速唤醒、Sniper固定点变体和Needolin路线。入口：[Mosstown_01 Control](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:455739)。

### 普通敌人的行为原型应如何归纳

分类时按“决策与运动机制”而非外形归类。以上三个有完整证据的原型分别是：区域警戒后追踪有偏移目标的飞行攻击者；带有限历史的多招近战者；带安全落点搜索与弹道发射的远程者。把它们拆成可组合模块后，普通敌人的研究目录可使用下列维度；这是分析框架，不声称每个名字都已经逐一核实。

| 维度 | 要记录的选择 | 会决定什么 |
|---|---|---|
| 休眠/唤醒 | 巡逻、原地等待、埋伏、祈祷、范围或事件唤醒 | 玩家何时真正进入战斗 |
| 目标与感知 | Hero/另一敌人、圆/矩形/视线、近远高低范围的优先顺序 | 它“知道”玩家在哪里以及该选什么 |
| 运动 | 地面速度、加力飞行、悬停、固定速度冲刺、弹道跳跃、贴墙 | 轨迹能否被躲避和预测 |
| 攻击承诺 | 前摇锁朝向、锁位置、持续跟踪、分段重新判断 | 玩家移动何时能影响敌人 |
| 伤害载体 | 本体、分离武器盒、短程爆发、子弹、地面危险物 | 什么空间/时间真正造成伤害 |
| 决策记忆 | 固定循环、随机权重、连续限制、未选补偿、阶段阈值 | 战斗节奏是否能公平地变化 |
| 中断 | 受击、格挡命中、歌唱、提取、死亡、跌落、离屏 | 不同系统如何竞争控制权 |
| 场景约束 | 营地固定范围、边界、落脚搜索、墙面与台阶 | 同一种怪在不同房间为什么表现不同 |

把每个新敌人填成“感知—选择—前摇—有效窗—收招—返回决策”的可追踪记录，再补完整异常路径。对于一个状态，能回答“谁触发、读什么、写什么、何时结束、退出恢复什么”，才足够复现。只写“靠近后冲刺、受伤后退”还不是战斗逻辑规格。

### 学习练习的逐项验收

下面把上面的三堂练习写成可直接交给测试驱动的操作与预期。固定随机值；动画事件按本章从0起的帧号推进；时间允许一个渲染帧误差，但状态与命中盒不能对错混用。

| ID | 设置/操作 | 必须满足 |
|---|---|---|
| M01-A | Idle；Alert=true、LOS=false，推进1秒 | 不因普通视觉进入Startle；令LOS=true则进入Startle |
| M01-B | Get Above；可见且Attack Range=true | 进入Attack Antic；vy先12；0.6秒后Drill；v=(0,-20)；Blocker关闭 |
| M01-C | Drill进入0.2秒时Terrain碰撞 | Drill Collide；v.y先14；Blocker重新开；4/12秒后Recover；0.7秒后Get Above |
| M01-D | Drill无碰撞0.6秒 | Drill End而非Collide；播放6/12秒后Get Above |
| M01-E | Get Above；全程不满足可攻击合取 | timer累计8秒尚未greaterThan；>8秒Range Out；不是检测Alert圆来代替 |
| M01-F | 任意攻击状态发EXTRACT | collider=false、kinematic=true、清速度；EXTRACT FINISH按scale决定0/180死亡方向 |
| M02-A | 强制Close Range，Ct Block=1且无missed超限；RNG先抽BLOCK再SLASH | 第一次应重抽，最终SLASH；不能连续BLOCK；missed全更新 |
| M02-B | Close Range；Ms Evade=4、Ms Block=4 | 强制选数组后面的BLOCK；验证不是取第一个超时项 |
| M02-C | 从T Slash Antic开始；地面充足、始终面对Hero；推进动画到1/7/8/12/14帧 | hit1→无→hit2→无→hit3→无；动画只开始一次；无第四刀 |
| M02-D | Triple Slash4结束前令脚前射线无地面或玩家换到背后 | 第三刀被取消，直接Recover；此前刀段也不能无视脚前无地面继续推进 |
| M02-E | Block进入，之后BLOCKED HIT | invincible离Block时恢复；Block Hit后退15，2/12秒后Check Range |
| M02-F | GDash无阻，0.25秒 | vx恒向前42，约10.5位移；根collider关、DashCollider开；后续恢复为相反 |
| M02-G | Air Dive地面命中 | 恢复gScale=2；Air Dive Slash帧0..1开Hit1、1..2开Hit2、2..6恢复，不把冲刺hitbox遗留 |
| M03-A | Patrol同时Escape/Attack=true | ESCAPE优先；不发射；模拟后跳着地后必须进入Spit Antic |
| M03-B | Spit Antic进入hero.x-self.x=10，固定RNG=0；前摇中英雄移动到另侧 | SpitX=11；发射仍vx=11而非重新瞄准；vy=19、gScale=1 |
| M03-C | Spit进入后推进0/2/5帧 | 0帧子弹已经存在且Burst开；2帧Burst关；5帧进Recover；0.1秒后Patrol |
| M03-D | 正常Shot Point前有墙，备用点可用 | 同一子弹改从Shot Wall Check生成；不直接把Shot Point塞进墙里 |
| M03-E | 6单位落点搜索失败，8单位有落脚；然后两个都失败 | 第一种走普通弹道后跳；第二种走Walljump，vy=20、朝向速度绝对值2..6 |
| M03-F | 子弹碰Terrain/收到HERO DAMAGED，然后等1秒再重用 | Break立即失去碰撞能力，1秒回池；再Init恢复动态/碰撞，不能保留上次kinematic与失活状态 |

### 人类阅读用完整状态索引

为了让本学习版可以单独使用，以下保留三个实例及子弹的完整状态边。学习时按状态名检索本节解释，落地时对照同名 JSON 参数和源码；空目标不代表已分析者替你补好了规则。

#### MossBone Fly / Control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:800909>) | `ALERT`→`Startle`；`TOOK DAMAGE`→`Startle`；`NEEDOLIN`→`Pray`；`DEAF`→`∅` | 8/8 |
| [Initiate](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:801348>) | `FINISHED`→`Idle`；`ALERT`→`Get Above` | 9/9 |
| [Get Above](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:801568>) | `ATTACK`→`Attack Antic`；`RANGE OUT`→`Range Out`；`BONK`→`Bonk?`；`NEEDOLIN`→`Pray` | 14/15 |
| [Attack Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802179>) | `FINISHED`→`Drill` | 7/7 |
| [Drill](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802463>) | `COLLIDE`→`Drill Collide`；`END`→`Drill End` | 6/6 |
| [Drill End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802727>) | `FINISHED`→`Get Above` | 3/3 |
| [Drill Collide](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:802847>) | `FINISHED`→`Drill Recover` | 7/7 |
| [Startle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803155>) | `FINISHED`→`Get Above` | 4/4 |
| [Drill Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803370>) | `FINISHED`→`Get Above`；`NEEDOLIN`→`Pray` | 7/8 |
| [Range Out](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803669>) | `FINISHED`→`Idle` | 2/2 |
| [Still In Range?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803771>) | `ALERT`→`Get Above`；`FINISHED`→`Idle` | 5/5 |
| [Bonk?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:803992>) | `FINISHED`→`Bonk Frame` | 5/5 |
| [Pray](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:804223>) | `END`→`Pray End`；`SING DURATION END`→`Pray End` | 4/4 |
| [Pray End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:804501>) | `FINISHED`→`Get Above` | 1/1 |
| [Bonk Frame](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:804584>) | `FINISHED`→`Get Above` | 1/1 |
| [Extract](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:804649>) | `EXTRACT FINISH`→`Kill Dir` | 11/11 |
| [Extract Kill](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:805119>) | — | 1/1 |
| [Kill Dir](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_02.unity:805189>) | `FINISHED`→`Extract Kill` | 3/3 |

启动：`Initiate`；全局边：`EXTRACT`→`Extract`。

#### Bone Hunter / Control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Init](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:684728>) | `FINISHED`→`∅`；`AMBUSH`→`Ambush Ready`；`CAMP`→`Camp Idle`；`COMBAT`→`Set Opponent`；`CROWD`→`Crowd Idle`；`GUARD`→`Guard Idle`；`DASH ENTRY`→`Dash Entry Ready`；`JUMP IN`→`Jump In Ready`；`STADIUM JUMP IN`→`Jump In Setup` | 26/26 |
| [Ambush Ready](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:685498>) | `WAKE`→`Ambush Antic`；`BATTLE START`→`Battle Ambush Antic`；`RESPAWN`→`Ambush Antic` | 7/7 |
| [Ambush Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:685765>) | `FINISHED`→`Dig Out` | 4/4 |
| [Dig Out](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:685910>) | `FINISHED`→`Dig Out 2` | 7/7 |
| [Activate](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:686153>) | `FINISHED`→`Recover` | 4/4 |
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:686328>) | `FINISHED`→`Check Range`；`TOOK DAMAGE`→`Check Range`；`UNALERT`→`Dig In 1` | 7/7 |
| [Close Range](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:686633>) | `EVADE`→`Evade Antic`；`SLASH`→`T Slash Antic`；`JUMP`→`Jump Dir`；`BLOCK`→`Block` | 1/1 |
| [Far Range](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:686883>) | `CHASE`→`Chase`；`GDASH`→`GDash Antic`；`JUMP`→`Jump Dir` | 3/4 |
| [Above Range](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:687306>) | `EVADE`→`Evade Antic`；`SLASH`→`T Slash Antic`；`JUMP`→`Jump Dir`；`BLOCK`→`Block` | 1/1 |
| [T Slash Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:687556>) | `FINISHED`→`Triple Slash 1` | 5/5 |
| [Triple Slash 1](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:687748>) | `FINISHED`→`Triple Slash 2` | 8/8 |
| [Evade Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688152>) | `FINISHED`→`Evade` | 2/2 |
| [Evade](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688271>) | `FINISHED`→`Evade Skid`；`EDGE`→`Evade Edge` | 5/6 |
| [Evade Skid](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688496>) | `FINISHED`→`Evade End` | 2/2 |
| [Dig Out 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688605>) | `FINISHED`→`Activate` | 3/3 |
| [Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688758>) | `FINISHED`→`Idle` | 1/1 |
| [Evade End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:688841>) | `END`→`Idle`；`GDASH`→`GDash Antic`；`SLASH`→`T Slash Antic`；`JUMP`→`Jump Dir`；`COMBAT`→`Combat Choice` | 3/3 |
| [Dash Slash Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689065>) | `FINISHED`→`Long Slash Recover?` | 2/2 |
| [Jump Dir](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689167>) | `L`→`Jump L`；`R`→`Jump R`；`CANCEL`→`Check Range` | 4/4 |
| [Jump L](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689512>) | `FINISHED`→`Jump Aim` | 1/1 |
| [Jump R](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689591>) | `FINISHED`→`Jump Aim` | 1/1 |
| [Jump Aim](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689670>) | `FINISHED`→`Jump Antic` | 4/4 |
| [Jump Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689838>) | `FINISHED`→`Jump Launch` | 3/3 |
| [Jump Launch](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:689990>) | `FINISHED`→`Jump Rise` | 4/4 |
| [Jump Rise](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:690175>) | `FINISHED`→`ADash?`；`LAND`→`Land` | 4/5 |
| [Jump Fall](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:690449>) | `LAND`→`Land` | 4/4 |
| [Land](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:690626>) | `FINISHED`→`Idle` | 6/6 |
| [GDash Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:690885>) | `FINISHED`→`GDash`；`EVADE`→`GDash Away` | 5/6 |
| [Dash Slash](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:691233>) | `FINISHED`→`Dash Slash Recover` | 4/4 |
| [GDash](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:691387>) | `FINISHED`→`DashSlash Antic`；`EDGE`→`DashSlash Antic` | 11/11 |
| [GDash Slash](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:691739>) | `FINISHED`→`Dash Slash` | 8/8 |
| [ADash?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692036>) | `FALL`→`Jump Fall`；`ADASH`→`Dive Antic`；`RANGE OUT`→`ADash Range Out` | 4/4 |
| [ADash Range Out](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692343>) | `FINISHED`→`Jump Fall` | 2/2 |
| [ADash Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692438>) | `FINISHED`→`ADash Clamp` | 5/5 |
| [ADash](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692641>) | `FINISHED`→`ADash Effect` | 10/10 |
| [ADash Fall](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:692993>) | `LAND`→`Land` | 7/7 |
| [Check Side](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:693286>) | `LAND`→`Skid`；`FINISHED`→`ADash Fall`；`WALL L`→`Wall L`；`WALL R`→`Wall R` | 6/6 |
| [Skid](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:693565>) | `FINISHED`→`Idle` | 7/7 |
| [Wall L](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:693875>) | `FINISHED`→`Walljump`；`CANCEL`→`ADash CanCollide` | 9/9 |
| [Wall R](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:694297>) | `FINISHED`→`Walljump`；`CANCEL`→`ADash CanCollide` | 9/9 |
| [Walljump](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:694719>) | `FINISHED`→`Jump Fall` | 4/4 |
| [Check Range](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:694886>) | `SING`→`Sing`；`CLOSE`→`Close Range`；`FAR`→`Far Range`；`ABOVE`→`Above Range`；`FINISHED`→`Idle`；`COMBAT`→`Combat Choice`；`FALL`→`Jump Fall` | 9/10 |
| [Chase](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:695405>) | `JUMP`→`Jump Dir`；`SLASH`→`T Slash Antic`；`CLOSE`→`Close Range`；`ABOVE`→`Above Range` | 8/9 |
| [Camp Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:695890>) | `TOOK DAMAGE`→`Startle`；`WAKE`→`Startle`；`HORNET CAGED`→`Startle`；`CAGE SPRUNG`→`Startle` | 4/4 |
| [Startle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696144>) | `FINISHED`→`Idle` | 6/6 |
| [Reset](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696436>) | `FINISHED`→`Ambush Ready` | 3/3 |
| [Pause](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696620>) | `FINISHED`→`Respawn Setup` | 2/2 |
| [Sing](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696703>) | `CANCEL`→`Sing End`；`SING DURATION END`→`Sing End` | 3/3 |
| [Sing End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696911>) | `FINISHED`→`Idle` | 1/1 |
| [Death](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:696994>) | `RESPAWN`→`Die` | 3/3 |
| [DashSlash Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697168>) | `FINISHED`→`GDash Slash` | 3/3 |
| [ADash Clamp](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697296>) | `L`→`Clamp L`；`R`→`Clamp R` | 1/1 |
| [Clamp L](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697416>) | `FINISHED`→`ADash` | 2/2 |
| [Clamp R](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697545>) | `FINISHED`→`ADash` | 2/2 |
| [Set Opponent](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697674>) | `FINISHED`→`Idle` | 3/3 |
| [Combat Choice](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:697796>) | `EVADE`→`Evade Antic`；`CHASE`→`Combat Chase`；`SLASH`→`T Slash Antic`；`ADASH`→`Chief Jump`；`GDASH`→`GDash Centre`；`CENTRE`→`Centre Choice`；`COMBAT END`→`End Combat`；`UNALERT`→`Dig In 1` | 5/5 |
| [Combat Chase](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698223>) | `FINISHED`→`Combat Choice` | 4/4 |
| [Chief Jump](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698390>) | `L`→`Jump L`；`R`→`Jump R` | 3/3 |
| [Evade Edge](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698589>) | `FINISHED`→`Evade Skid` | 1/1 |
| [Centre Choice](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698661>) | `CHASE`→`Combat Chase`；`GDASH`→`GDash Centre` | 1/1 |
| [GDash Centre](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698794>) | `FINISHED`→`GDash` | 3/3 |
| [End Combat](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:698946>) | `FINISHED`→`Combat End Idle` | 6/6 |
| [Combat End Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699173>) | `FINISHED`→`Idle`；`TOOK DAMAGE`→`Idle` | 3/3 |
| [Crowd Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699323>) | `BATTLE START`→`Enter Idle`；`BEAT`→`Beat Pause` | 3/3 |
| [Enter Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699447>) | `FINISHED`→`Enter Antic` | 0/2 |
| [Enter Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699552>) | `FINISHED`→`Enter Leap` | 3/3 |
| [Enter Leap](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:699706>) | `FINISHED`→`Enter Fall` | 9/9 |
| [Enter Fall](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700041>) | `LAND`→`Enter Land` | 7/7 |
| [Enter Land](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700336>) | `FINISHED`→`Idle` | 2/2 |
| [Dig In 1](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700452>) | `FINISHED`→`Dig In 2`；`NO DIG`→`Unalert To Guard` | 4/4 |
| [Dig In 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700589>) | `FINISHED`→`Reset` | 5/5 |
| [Beat Pause](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700788>) | `FINISHED`→`Do Beat`；`BATTLE START`→`Enter Idle` | 1/1 |
| [Do Beat](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700877>) | `FINISHED`→`Crowd Idle` | 1/1 |
| [Battle Ambush Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:700956>) | `FINISHED`→`Dig Out` | 5/5 |
| [Block](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701118>) | `BLOCKED HIT`→`Block Hit`；`TOOK DAMAGE`→`Block End`；`FINISHED`→`Block End`；`FALL`→`Jump Fall` | 7/7 |
| [Block End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701437>) | `FINISHED`→`Idle` | 2/2 |
| [Block Hit](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701554>) | `FINISHED`→`Check Range` | 4/5 |
| [ADash CanCollide](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701747>) | `END`→`ADash Fall`；`COLLIDE`→`Check Side` | 4/4 |
| [Guard Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:701936>) | `TOOK DAMAGE`→`Startle`；`BLOCKED HIT`→`Block Hit`；`WAKE`→`Startle` | 4/4 |
| [Unalert To Guard](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702187>) | `FINISHED`→`Guard Idle` | 2/2 |
| [ADash Effect](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702309>) | `FINISHED`→`ADash CanCollide` | 1/1 |
| [Offscreen Return](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702397>) | `FINISHED`→`Reset` | 2/4 |
| [Die](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702555>) | `FINISHED`→`Respawn Ready` | 10/10 |
| [Respawn Ready](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702850>) | `RESPAWN`→`Start Respawn` | 0/0 |
| [Start Respawn](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:702911>) | `FINISHED`→`Respawn Antic` | 3/3 |
| [Respawn Setup](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703064>) | `FINISHED`→`Opponent?` | 4/4 |
| [Respawn Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703207>) | `FINISHED`→`Dig Out` | 3/3 |
| [Dash Entry Ready](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703318>) | `BATTLE START`→`Dash Entry Activate` | 8/8 |
| [Dash Entry Activate](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703545>) | `FINISHED`→`GDash` | 4/4 |
| [Long Slash Recover?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703688>) | `FINISHED`→`Idle`；`TOOK DAMAGE`→`Idle` | 5/5 |
| [GDash Away](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:703862>) | `FINISHED`→`GDash` | 3/3 |
| [Jump In](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704014>) | `FINISHED`→`Jump In Activate`；`EVADE`→`Jump In Alt` | 8/8 |
| [Jump In Activate](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704263>) | `FINISHED`→`Jump Fall 2` | 1/1 |
| [Jump In Ready](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704343>) | `BATTLE START`→`Jump In` | 7/7 |
| [Jump Fall 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704553>) | `LAND`→`Land 2` | 3/3 |
| [Land 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704712>) | `FINISHED`→`Wait For Hero` | 4/4 |
| [Wait For Hero](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:704909>) | `WAKE`→`Startle`；`TOOK DAMAGE`→`Startle` | 3/3 |
| [Jump In Alt](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:705099>) | `FINISHED`→`Jump In Activate` | 7/7 |
| [Triple Slash 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:705309>) | `FINISHED`→`Triple Slash 3` | 5/5 |
| [Triple Slash 3](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:705598>) | `FINISHED`→`Triple Slash 4` | 8/8 |
| [Triple Slash 4](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:705995>) | `FINISHED`→`End Slash?` | 5/5 |
| [Triple Slash 5](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:706284>) | `FINISHED`→`Triple Slash Recover` | 8/8 |
| [Triple Slash Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:706681>) | `FINISHED`→`Idle` | 6/6 |
| [End Slash?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:706996>) | `FINISHED`→`Triple Slash 5`；`CANCEL`→`Triple Slash Recover` | 2/2 |
| [Dive Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:707241>) | `FINISHED`→`Air Dive` | 6/6 |
| [Air Dive](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:707466>) | `LAND`→`Dive Slash 1`；`WALL L`→`Wall L`；`WALL R`→`Wall R` | 14/16 |
| [Dive Slash 1](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708137>) | `FINISHED`→`Dive Slash 2` | 6/6 |
| [Dive Slash 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708415>) | `FINISHED`→`Dive Slash Recover` | 3/3 |
| [Dive Slash Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708544>) | `FINISHED`→`Idle` | 1/1 |
| [Opponent?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708620>) | `FINISHED`→`Init` | 3/3 |
| [Jump In Setup](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:708736>) | `FINISHED`→`Jump In 2` | 10/10 |
| [Jump In 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:709119>) | `FINISHED`→`Jump In End` | 15/16 |
| [Jump In End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:709694>) | `FINISHED`→`Jump Fall` | 4/4 |
| [Jump Fall 3](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:709869>) | `LAND`→`Land` | 5/5 |

启动：`Pause`；全局边：`ZERO HP`→`Death`；`OFFSCREEN`→`Offscreen Return`。

#### Bone Hunter / Detect Offscreen

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:630791>) | `OFFSCREEN`→`Offscreen` | 1/1 |
| [Offscreen](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Ant_04.unity:630899>) | `FINISHED`→`Idle` | 2/2 |

启动：`Idle`；全局边：无。

#### Pilgrim Moss Spitter / Control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Pause](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:455756>) | `FINISHED`→`Init` | 1/1 |
| [Init](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:455821>) | `FINISHED`→`Patrol`；`PRAY`→`Black Thread?`；`SNIPE`→`Snipe` | 8/8 |
| [Spawn Silk](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456057>) | `FINISHED`→`Pray` | 3/3 |
| [Pray](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456247>) | `WAKE`→`Possess` | 8/8 |
| [Possess](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456555>) | `FINISHED`→`Possess Shake`；`QUICK`→`Pray End Q` | 3/3 |
| [Possess Shake](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456704>) | `FINISHED`→`Pray End` | 1/1 |
| [Pray End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456815>) | `FINISHED`→`Patrol` | 2/2 |
| [Pray End Q](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:456926>) | `FINISHED`→`Patrol` | 3/3 |
| [Patrol](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:457070>) | `ATTACK`→`Spit Antic`；`ESCAPE`→`Escape Antic`；`SNIPE`→`Snipe Extra Recover`；`NEEDOLIN`→`Sing Antic`；`FALL`→`Fall` | 8/9 |
| [Spit Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:457578>) | `NEXT`→`In Wall?`；`CANCEL`→`∅`；`FALL`→`Fall`；`NEEDOLIN`→`Sing Antic` | 17/17 |
| [Spit](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:458203>) | `FINISHED`→`Recover`；`FALL`→`Fall`；`SPIT TRIGGER`→`Wait For Spit Anim` | 7/7 |
| [Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:458522>) | `NEXT`→`Patrol`；`FALL`→`Fall` | 4/4 |
| [Escape Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:458707>) | `FINISHED`→`Wait For Ground`；`CANCEL`→`Attempt Larger Jump`；`IN AIR`→`Fall`；`WALL`→`Walljump Antic` | 9/9 |
| [Jump Away](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:459198>) | `FINISHED`→`Jump Air` | 6/8 |
| [Jump Air](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:459508>) | `LAND`→`Land` | 1/1 |
| [Land](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:459625>) | `FINISHED`→`Spit Antic` | 3/3 |
| [Snipe](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:459803>) | `ATTACK`→`Spit Antic`；`ESCAPE`→`Escape Antic`；`TOOK DAMAGE`→`Escape Antic`；`END`→`Snipe End`；`FALL`→`Fall` | 5/5 |
| [Snipe Extra Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460151>) | `FINISHED`→`Snipe`；`FALL`→`Fall`；`TOOK DAMAGE`→`Escape Antic` | 3/3 |
| [Spit Instead?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460318>) | `ATTACK`→`Spit Antic`；`FINISHED`→`Patrol` | 1/1 |
| [Attempt Larger Jump](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460447>) | `FINISHED`→`Wait For Ground`；`CANCEL`→`Walljump Antic` | 3/3 |
| [Jump Cancel Recover](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460621>) | `FINISHED`→`Spit Instead?` | 1/1 |
| [Not Grounded](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460694>) | `FINISHED`→`Patrol` | 1/1 |
| ['Needolin '](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460759>) | `END`→`Sing End`；`SING DURATION END`→`Sing End` | 3/3 |
| [Walljump Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:460970>) | `FINISHED`→`Wait For Ground 2` | 1/1 |
| [Walljump](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461053>) | `FINISHED`→`Jump Air` | 5/5 |
| [Snipe End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461254>) | `FINISHED`→`Patrol` | 0/0 |
| [Wait For Ground](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461315>) | `FINISHED`→`Jump Away` | 1/1 |
| [Wait For Ground 2](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461427>) | `FINISHED`→`Walljump` | 1/1 |
| [Fall](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461539>) | `FINISHED`→`Jump Air` | 2/2 |
| [In Wall?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461644>) | `SPIT`→`Nml Spit`；`WALL`→`Wall Spit` | 1/1 |
| [Nml Spit](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:461851>) | `FINISHED`→`Spit` | 3/3 |
| [Wall Spit](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462010>) | `FINISHED`→`Spit` | 3/3 |
| [Black Thread?](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462169>) | `FINISHED`→`Spawn Silk` | 2/2 |
| [Sing Antic](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462260>) | `FINISHED`→`Needolin ` | 2/2 |
| [Sing End](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462376>) | `FINISHED`→`Patrol` | 1/1 |
| [Wait For Spit Anim](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Mosstown_01.unity:462459>) | `FINISHED`→`Recover` | 2/2 |

启动：`Pause`；全局边：无。

#### Grass Ball / grass ball control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:257>) | `TERRAIN`→`Break`；`PROJECTILE BREAK`→`Break`；`HERO DAMAGED`→`Break` | 3/3 |
| [Break](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:393>) | `FINISHED`→`Recycle` | 12/12 |
| [Init](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:660>) | `FINISHED`→`Scale Up` | 5/5 |
| [Recycle](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:777>) | — | 1/1 |
| [Scale Up](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball.prefab:831>) | `FINISHED`→`Idle` | 6/6 |

启动：`Init`；全局边：无。

#### Grass Ball BlackThread Variant / grass ball control

| 状态（源码行） | 按原顺序的事件→目标 | 启用/全部动作 |
|---|---|---|
| [Idle](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:257>) | `TERRAIN`→`Break`；`PROJECTILE BREAK`→`Break`；`HERO DAMAGED`→`Break` | 3/3 |
| [Break](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:393>) | `FINISHED`→`Recycle` | 12/12 |
| [Init](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:660>) | `FINISHED`→`Scale Up` | 5/5 |
| [Recycle](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:777>) | — | 1/1 |
| [Scale Up](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Enemies/Fungus 1 + 2/Grass Ball BlackThread Variant.prefab:831>) | `FINISHED`→`Idle` | 6/6 |

启动：`Init`；全局边：无。


<!-- HUMAN_GUIDE_END -->
