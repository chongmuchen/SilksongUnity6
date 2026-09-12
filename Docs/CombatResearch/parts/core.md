# 通用战斗运行时：AI 复现规格与人类学习指南

研究对象为本地 `SilksongUnity6` 的当前源码及项目配置；这是静态源码研究，不代表已在零售版本上逐帧验证。本章覆盖共用战斗机制，单个敌人的参数、状态、招式与场景覆盖应与个案章节合并阅读。下文的“必须”属于复现交付规格，不是来自游戏资源中的指令。所有相对源码路径均相对于 `/Users/mars/workspace/SilksongUnity6/`。

## A. 给 AI 的实现规格

### A1. 证据优先级与可实现边界

1. **当前行为事实**：以 C# 方法体、实际挂载的 MonoBehaviour、FSM 的 action 参数和场景实例覆盖共同确定。单看类名、FSM 状态名、Inspector 提示或字段名不能推出行为。
2. **资产参数事实**：必须读取 prefab 的对应组件、嵌套 prefab 覆盖、场景实例覆盖，再应用 Awake/Start/FSM 的修改。`DamageHero.damageDealt` 即使序列化为 1，Awake 仍可能用 `damageAsset.Value` 替换。证据：[DamageHero.cs:161](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageHero.cs:161)。
3. **默认值不是该怪物的配置**：`Recoil.Reset()` 的 15 速度、0.5 秒只用于组件 Reset；实际敌人要读序列化字段，不能把它套给全体。证据：[Recoil.cs:114](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/Recoil.cs:114)。
4. **旧字段不自动拥有语义**：`HealthManager.invulnerableTime` 位于 `Deprecated/Unusued Variables`，当前受击代码没有按它设置受击无敌；`AttackTypes.Piercer_OBSOLETE`、`RapidBullet_OBSOLETE` 也不能按名字替代 `SpecialTypes` 位标志。证据：[HealthManager.cs:434](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:434)、[AttackTypes.cs:18](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/AttackTypes.cs:18)。
5. **当前代码的可疑行为单列**：不能为了“像合理游戏”而悄悄修正，再称为原行为。见 A11 的源码疑点。运行时内核在 `Assets/Plugins/PlayMaker.dll`，本章直接验证的是周边 action 与调用代码；未反编译内核，不把未证明的内核事件重入优先级写成事实。

本章中 `UNKNOWN` 表示尚未证明，必须阻止“一比一复现通过”的结论；它不是让 AI 随机填值的占位符。

### A2. 最小运行时组成

敌人必须拆成下列独立但互相发事件的模块，不能将所有内容折叠成一个 `Update()` 中的距离判断。

| 模块 | 所有权与输入 | 必须保留的输出/状态 | 源码锚点 |
|---|---|---|---|
| 行为 FSM 集合 | 同物体可有 Control、Stun、特殊死亡等多个 FSM | 每台 FSM 当前状态、action 生命周期、局部/全局变量、事件 | [FSMUtility.cs:259](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/FSM/00_Core/FSMUtility.cs:259) |
| 感知器 | 子物体 Trigger、过滤层、标签、视线检测 | 在范围内、无遮挡、脱战时长 | [AlertRange.cs:80](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/AlertRange.cs:80) |
| 移动器 | FSM action、Walker/WalkerV2、Rigidbody2D | 速度、位置、朝向、地面与墙壁探测 | [ChaseObjectGround.cs:91](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/ChaseObjectGround.cs:91) |
| 受击器 | `IHitResponder` / `HealthManager` | HP、无敌/免疫、事件、死亡委托 | [HealthManager.cs:783](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:783) |
| 攻击器 | `DamageHero` 与主动攻击碰撞体 | 对主角伤害、碰撞方向、弹反/撞针反馈 | [DamageHero.cs:26](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageHero.cs:26) |
| 主角对敌攻击 | `DamageEnemies` | 每次挥击去重、多段步长、响应优先级 | [DamageEnemies.cs:676](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:676) |
| 击退器 | `Recoil` | Ready/Frozen/Recoiling、剩余时间、Sweep | [Recoil.cs:152](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/Recoil.cs:152) |
| 动画时钟 | tk2d clip、fps、帧事件、WrapMode | 帧跨越事件、完成事件、状态中的取消 | [tk2dSpriteAnimator.cs:493](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimator.cs:493) |
| 场景协调 | 战斗房间、计数器、门、阶段对象、对象池 | 激活条件、出生、战斗结束与持久化 | [HealthManager.cs:1674](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1674) |

敌人的位置、朝向、动画、受击状态和当前攻击不是同一个状态量。移动可以停而动画继续，动画可以被替换而 FSM 未直接退出，身体碰撞与攻击碰撞可以独立开关。

### A3. 时钟、物理步与执行顺序

**项目事实**：Unity 版本为 `6000.5.4f1`；重力 `(0,-60)`；速度/位置求解迭代 8/3；QueriesHitTriggers 开；QueriesStartInColliders 关；AutoSyncTransforms 开。`TimeManager` 的 Fixed Timestep 序列化为 `2822399 / 141120000` 秒，约 `0.0199999929` 秒，不能将它误看成 1/60 秒。证据：[ProjectVersion.txt:1](/Users/mars/workspace/SilksongUnity6/ProjectSettings/ProjectVersion.txt:1)、[Physics2DSettings.asset:7](/Users/mars/workspace/SilksongUnity6/ProjectSettings/Physics2DSettings.asset:7)、[TimeManager.asset:7](/Users/mars/workspace/SilksongUnity6/ProjectSettings/TimeManager.asset:7)。

**明确证明的顺序**：`CustomPlayerLoop` 在 FixedUpdate 子系统末尾追加处理器；先依注册列表调用 LateFixedUpdate，再调用 SuperLateFixedUpdate，最后递增 FixedUpdateCycle。`DamageEnemies` 属于前者，`HeroBox` 在 Awake 注册后者。因此同一个物理周期内，对敌命中响应先于主角缓冲受伤结算。证据：[CustomPlayerLoop.cs:20](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/CustomPlayerLoop.cs:20)、[CustomPlayerLoop.cs:62](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/CustomPlayerLoop.cs:62)、[HeroBox.cs:28](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/02_Player/HeroBox.cs:28)。

复现调度必须满足以下协议：

```text
每个渲染帧：
  保留本帧真实 dt、scaled dt、timeScale、累积物理时间
  对应 Unity 的每个固定周期：
    运行 FixedUpdate 驱动的 action / recoil / multi-hit 步数递减
    按引擎物理顺序模拟、收集碰撞/Trigger 进入与停留
    执行注册的 LateFixedUpdate（包含 DamageEnemies）
    执行注册的 SuperLateFixedUpdate（包含 HeroBox）
    FixedUpdateCycle += 1
  运行 Update 时钟 action、HealthManager 计时、感知延迟
  LateUpdate 更新 tk2d 动画，并派发跨越的动画帧事件/完成事件
```

其中普通 MonoBehaviour 之间的完整先后顺序、PlayMaker 内核的事件队列重入、同优先级物理接触枚举顺序必须通过实际运行记录补证。上述协议没有声称这些未观测顺序已知。`Recoil` 用 fixedDeltaTime；`HealthManager` 的连续命中计时用 deltaTime；`Wait/WaitRandom` 默认用 deltaTime，但 realTime=true 时改用不受 timeScale 影响的时钟；tk2d 默认在 LateUpdate 用 deltaTime，可改用 unscaledDeltaTime。证据：[Recoil.cs:255](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/Recoil.cs:255)、[HealthManager.cs:745](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:745)、[Wait.cs:45](/Users/mars/workspace/SilksongUnity6/Assets/PlayMaker/Actions/Time/Wait.cs:45)、[tk2dSpriteAnimator.cs:657](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimator.cs:657)。

**验收不能只用“固定 60 FPS”**：至少检查 30/60/120 渲染 FPS、相同约 50 Hz 物理步；若帧率改变了攻击触发时间，先查 Update/FixedUpdate 混用，而不是调整招式参数。

### A4. 感知和追踪

`AlertRange` 继承 `TrackTriggerObjects`。范围形状由实际 Collider2D 决定，不等于“距敌人小于一个半径”。父类按碰撞层、包含标签、排除标签筛选，按 GameObject 去重，并在首次对象进入/最后对象退出时更改 inside 状态；初始化时还会做 Overlap，避免主角初始就在区域内却没有 Enter 事件。证据：[TrackTriggerObjects.cs:66](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/04_World_Environment/TrackTriggerObjects.cs:66)、[TrackTriggerObjects.cs:116](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/04_World_Environment/TrackTriggerObjects.cs:116)、[TrackTriggerObjects.cs:168](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/04_World_Environment/TrackTriggerObjects.cs:168)。

`lineOfSight` 枚举：None=0，Self=1，Parent=2。Parent 在当前 parent 不存在时使用初始化缓存 parent。只有主角在范围内时，FixedUpdate 才更新视线；视线为探测点到 Hero transform 的 LineCast，mask=256，未撞到才视为可见。`IsHeroInRange()` 要求范围内且视线通过，除非根本未开启视线。证据：[AlertRange.cs:103](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/AlertRange.cs:103)。

`countUnalertTime=true` 时，进入有效感知把计时清零；否则 Update 累加到最多 100 秒。父 HealthManager 的 `TookDamage` 也会清零脱战时长。禁用组件清除 `haveLineOfSight/isHeroInRange`。证据：[AlertRange.cs:49](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/AlertRange.cs:49)、[AlertRange.cs:85](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/AlertRange.cs:85)。

`CheckAlertRange` 是带稳定持续时间的开关检测：进入状态或结果翻转时，将 timer 设为当前结果对应的 InRangeDelay/OutOfRangeDelay；everyFrame=true 才等待；当 timer<=0 才写 storeResult 并发 InRangeEvent/OutOfRangeEvent。延迟期间再次翻转会重新计时。尽管 OnPreprocess 设置 `HandleFixedUpdate=true`，具体持续逻辑写在 **OnUpdate**，使用 deltaTime，不能按名字误搬到 FixedUpdate。证据：[CheckAlertRange.cs:47](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/FSM/01_Project_Actions/Hollow_Knight/CheckAlertRange.cs:47)。

### A5. 移动复现：必须复现所用 action 的公式

`ChaseObjectGround` 的算法如下，`a` 是**每次 DoChase 调用直接加给速度的量**，源码没有乘 dt：

```text
targetX = target.position.x + xOffset
若 self.x < targetX - turnRange：vx += acceleration；movingRight = true
否则若 self.x > targetX + turnRange：vx -= acceleration；movingRight = false
否则若 !snapTo：按保留的 movingRight 继续加/减 acceleration
vx = clamp(vx, -speedMax, speedMax)
vy 保持原值
```

OnEnter 立即执行一次，unless onlyOnStateEntry=true 后 Finish；持续 action 在 OnFixedUpdate 执行。反向动画由速度变号条件触发，并不等同于 transform 朝向自动改变。证据：[ChaseObjectGround.cs:62](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/ChaseObjectGround.cs:62)、[ChaseObjectGround.cs:91](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/ChaseObjectGround.cs:91)。例如若配置 a=0.2，则大约 50 次调用/秒对应约 10 单位/秒²，但这只是换算示例，不是任何敌人的参数。

`SetVelocity2d` 中 None 的轴保持当前值；显式 0 的轴则清零。vector 可先替换整个向量，x/y 再覆盖各轴；Space.Self 用 TransformDirection。该 action 有 OnEnter、OnUpdate、OnFixedUpdate 三个调用入口，everyFrame=false 进入后 Finish。证据：[SetVelocity2d.cs:48](/Users/mars/workspace/SilksongUnity6/Assets/PlayMaker/Actions/Physics2D/SetVelocity2d.cs:48)、[SetVelocity2d.cs:78](/Users/mars/workspace/SilksongUnity6/Assets/PlayMaker/Actions/Physics2D/SetVelocity2d.cs:78)。

`Walker` 是有状态移动器：Walking 中依序判断墙、转向主角、前方缺地面，然后才随机休息。墙/地面 Sweep mask=33024；转身先要求脚下存在地面；TurnStopMovement 决定转身期间清 vx 还是保留/反向；等待转身动画停止后重新 Walking。不能用每帧 `faceHero()` 代替，否则会消除背后攻击窗口和悬崖规则。证据：[Walker.cs:398](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/11_Actors_Quests/Walker.cs:398)、[Walker.cs:436](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/11_Actors_Quests/Walker.cs:436)。

`WalkerV2` 还有 WalkSpeed/RunSpeed、AggroRange、StartleAnim、转身后的 TurnAggroCooldown。面对方向=`sign(localScale.x)*rightDirection`；默认 rightDirection=-1，不能统一假设 scale.x>0 就朝右。它和 Walker 是不同实现，不能混合字段。证据：[WalkerV2.cs:24](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/WalkerV2.cs:24)、[WalkerV2.cs:319](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/WalkerV2.cs:319)、[WalkerV2.cs:367](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/WalkerV2.cs:367)。

### A6. 主角命中敌人的完整处理合同

#### A6.1 输入 `HitInstance`

复现器至少保留以下字段，禁用的系统也必须有明确默认值：Source、IsFirstHit、AttackType、DamageDealt、DamageScalingLevel、IsUsingNeedleDamageMult、RepresentingTool、StunDamage、CanWeakHit、Direction、CircleDirection、MoveDirection、MagnitudeMultiplier、Multiplier、SpecialType、IgnoreInvulnerable、NonLethal、HitEffectsType、SilkGeneration、PoisonDamageTicks、ZapDamageTicks、CriticalHit、HunterCombo、NailElement/NailImbuement、IsNailTag。Source 应为有效对象引用，因为多条路径直接访问 Source.GetComponent。证据：[HitInstance.cs:23](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HitInstance.cs:23)、[HealthManager.cs:957](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:957)。

Direction 是角度：0°右、90°上、180°左、270°下。`DirectionUtils` 的基数方向是 Right=0/Up=1/Left=2/Down=3，使用 RoundToInt(degrees/90) 和正模；`HitInstance.HitDirection` 却是 Left=0/Right=1/Up=2/Down=3。这两个枚举**不可直接强转**。CircleDirection 用源到目标的 atan2；MoveDirection 取源 Rigidbody2D（或父刚体）速度主轴。证据：[DirectionUtils.cs:6](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/12_Utilities/DirectionUtils.cs:6)、[HitInstance.cs:7](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HitInstance.cs:7)、[HitInstance.cs:125](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HitInstance.cs:125)。

#### A6.2 `DamageEnemies` 采集、去重与多段

- Trigger Enter 先排除 HERO_BOX、PLAYER、ENEMY_ATTACK、CORPSE、ATTACK_DETECTOR 等层，记录 enteredColliders 和 frameQueue；Exit 只移出 enteredColliders。每次 LateFixedUpdate 合并本步新进入与持续重叠的碰撞体。证据：[DamageEnemies.cs:584](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:584)、[DamageEnemies.cs:676](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:676)。
- 普通攻击使用 damagedColliders 防止同一碰撞体持续重叠反复攻击；响应器还用 hitsResponded、damagePrevented 去重。一个敌人多 Hurtbox 不应当凭碰撞体数量重复扣血。HitTaker 从命中物体向父层找 IHitResponder，默认最多遍历 3 层；遇到禁止向上回应的 responder 或 Rigidbody2D 就停止。证据：[DamageEnemies.cs:734](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:734)、[HitTaker.cs:45](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HitTaker.cs:45)。
- multiHitter 的冷却是 **stepsPerHit 个物理步**，不是秒。OnFixedUpdate 将 stepsToNextHit--，到期时清除 PreventDamage，重新评估；成功才设置下一段步长。`isFirstHit=false` 的后续段可选择不同特效与 `damageMultPerHit`，数组耗尽时重复最后元素。证据：[DamageEnemies.cs:663](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:663)、[DamageEnemies.cs:705](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:705)、[DamageEnemies.cs:1064](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:1064)。
- 响应缓冲按 HitPriority **降序**；同优先级插到已有同组之后；处理时先检查 HasBeenDamaged，再调用 responder.Hit。None 不记录命中。Invincible 可以算 DidHit/DidHitEnemy，但枚举隐式转换只让 DamageEnemy 消耗 charges；非显式 struct 构造的默认不要混淆。证据：[DamageEnemies.cs:32](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:32)、[DamageEnemies.cs:785](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:785)、[DamageEnemies.cs:1259](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:1259)、[IHitResponder.cs:31](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/IHitResponder.cs:31)。
- StartDamage 重置本轮命中标记/多段计数；EndDamage 清空重叠集合、已伤碰撞体和 hitCounts，并只发一次 EndedDamage。组件禁用会 EndDamage 并清集合。这是一次“攻击生命周期”的边界，不能用动画 clip 名变化代替。证据：[DamageEnemies.cs:631](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:631)、[DamageEnemies.cs:1370](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageEnemies.cs:1370)。

#### A6.3 `HealthManager.Hit` 的顺序

```text
if isDead: return None
if evasionByHitRemaining > 0: return None
if HitEffectsType != LagHit && DamageDealt <= 0 && !CanWeakHit: return None
Send(Source, "DEALT DAMAGE")
dir = cardinal(GetActualDirection(target))
if IsBlockingByDirection(dir, AttackType, SpecialType):
  Invincible(hit)
  return Invincible
TakeDamage(hit)
return DamageEnemy
```

证据：[HealthManager.cs:783](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:783)。注意最后一行即使 TakeDamage 内部因类型免疫而 return，Hit 仍返回 DamageEnemy；这属于当前源码事实，不能把“返回 DamageEnemy”直接解释为 HP 必然下降。

#### A6.4 防御、方向盾与免疫

`IsBlockingByDirection` 首先检查 invincible；为 false 则不会进入防御，不受 invincibleFromDirection 单独影响。Lava/Coal 绕过此防御；Spell/SharpShadow/Explosion 对 `Spell Vulnerable` 标签绕过；`piercable || invincibleFromDirection!=0` 时，Explosion/Lightning/带 Piercer 标记的攻击绕过。`invincibleFromDirection=0` 表示全向。其余值按下表匹配的是**攻击行进方向**，不是敌人朝向。证据：[HealthManager.cs:1933](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1933)。

| 攻击基数方向 | 会被拦住的 invincibleFromDirection 值 |
|---|---|
| 0：向右 | 1、5、8、10、12、13 |
| 1：向上 | 2、5、6、7、8、9、13 |
| 2：向左 | 3、6、9、11、12、13 |
| 3：向下 | 4、7、8、9、10、11、12 |

`IgnoreInvulnerable` **没有出现在 IsBlockingByDirection 调用的绕过条件中**，不能把它实现为“无视全部盾”。它传给 NonFatalHit/Die 的 ignoreEvasion 参数。证据同上及 [HealthManager.cs:1431](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1431)。

防御成立时：记录上次击中方向/类型；通知伤害来源 Tink/Bounce；给自身 `BLOCKED HIT`；在没有 active NonBouncer 时给 Source `HIT LANDED`；除非 preventInvincibleAttackBlock，给 Source `ATTACK BLOCKED`；invincibleRecoil 可触发击退。Tink 特效/HIT 和部分方向事件受 0.1 秒 tinkTimer 限制，但该计时不是完整防御判定的间隔。证据：[HealthManager.cs:808](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:808)。

另有独立的攻击类型免疫：Nail→immuneToNailAttacks，Acid→ignoreAcid，RuinsWater→ignoreWater/immuneToWater，Hunter→immuneToHunterWeapon，Spikes→immuneToSpikes，Explosion→immuneToExplosions（全命中时发 `BLOCKED EXPLOSION`），Coal/Trap/Lava 各自免疫。`immuneToBeams` 虽声明，却未出现在当前 IsImmuneTo switch，不能自行补一个 NailBeam 分支。证据：[HealthManager.cs:1355](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1355)。

`EnemyTypes.Armoured` 也不直接代表减伤公式：当前 TakeDamage 中它参与给丝条件；真正防御看上述字段/action。证据：[HealthManager.cs:1111](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1111)。

#### A6.5 成功受击、伤害公式与事件

顺序必须保留：

1. 类型免疫检查；命中效果可能受 BlackThreadState 修改。
2. 根据伤害来源等级取得 DamageScalingConfig 倍率，先 RoundToInt。
3. 处理 RapidBullet/RapidBomb/RapidStorm，之后再处理 CriticalHit。
4. 发 `TOOK HEAVY DAMAGE`（若 Heavy）、`HIT`；若无 active NonBouncer 给 Source `HIT LANDED`、`DEALT ACTUAL DAMAGE`；自身 `TOOK DAMAGE`、通常 `SING DURATION END`；配置 sendHitTo 时转发 `HIT`；弱击/Spell/Explosion 各有事件。
5. 触发 Recoil，然后命中特效、丝资源等。
6. `finalDamage = RoundToInt(DamageDealt * Multiplier)`；damageOverride=true 改为 1；然后应用作弊覆盖；将自己或 sendDamageTo.hp 减 finalDamage，最低 -1000。
7. NonLethal 在本体 hp<=0 时将本体 hp 拉到 1；毒/电 ticks 加入 TagDamageTaker。
8. 若本体 hp>0：触发 C# TookDamage，NonFatalHit，再 ApplyStunDamage；否则进入死亡。

证据：[HealthManager.cs:947](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:947)、[HealthManager.cs:1056](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1056)、[HealthManager.cs:1288](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1288)。

等级索引：针伤使用 PlayerData.nailUpgrades；有 RepresentingTool 用 ToolKitUpgrades；否则用 DamageScalingLevel-1。level<0→1 倍；0/1/2/3/≥4 对应 Level1/2/3/4/5Mult。证据：[HealthManager.cs:55](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:55)、[HealthManager.cs:939](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:939)。

连续命中衰减：

| 标记 | 连击窗口（每次命中刷新） | 伤害规则 |
|---|---:|---|
| RapidBullet | 0.15 秒 | 第 n 次，n>1 时整数除以 n，最低 1 |
| RapidBomb | 2 秒 | 第 n 次，n>1 时整数除以 n，最低 1 |
| RapidStorm | 0.6 秒 | 前 4 次不降；第 5 次整数除 3；第 6 次起除 4；最低 1 |

计时到零则该计数归零，使用 Update 的 deltaTime。证据：[HealthManager.cs:963](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:963)、[HealthManager.cs:745](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:745)。

`Stun` 独立于 HP：Awake 查找同物体名为 `Stun Control` 或 `Stun` 的 FSM；对非致命成功伤害，将 float 变量 `Stun Damage` 写入本次 StunDamage，然后发 `STUN DAMAGE`。**阈值、累计、自然衰减、冷却与眩晕招式取消必须读取该怪物的 Stun FSM**，HealthManager 不统一累计这些数值。证据：[HealthManager.cs:636](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:636)、[HealthManager.cs:1450](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1450)。

普通 NonFatalHit 在没有 alternateHitAnimation 时把 evasionByHitRemaining 设为 0；有替代动画就播放它，不在此方法增加无敌时间。因此不能默认每次受击都有 0.2 秒或 0.5 秒敌人 i-frame。各敌人额外受击保护若存在，需要从独立 FSM/组件证明。证据：[HealthManager.cs:1431](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1431)。

### A7. 击退与硬直合同

`Recoil` 三状态 Ready/Frozen/Recoiling；`IsRecoiling` 属性把 Frozen 也算 true，而 `GetIsRecoiling()` 只认 Recoiling，调用方选哪个会改变行为。证据：[Recoil.cs:81](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/Recoil.cs:81)、[Recoil.cs:312](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/Recoil.cs:312)。

```text
newSpeed = recoilSpeedBase * attackMagnitude * product(recoilMultipliers)
if 当前不为 Ready:
  remainingStrength = recoilSpeed * (timeRemaining / recoilDuration)
  if newSpeed < remainingStrength: 忽略本次击退
if FreezeInPlace:
  若 SkipFreezingByController: 触发 OnHandleFreeze，状态回 Ready
  否则 Frozen、velocity=0、发 FREEZE IN PLACE、timeRemaining=duration
else:
  按四个 Is*Blocked 拒绝指定方向
  水平方向发 RECOIL HORIZONTAL
  发 HIT LEFT / HIT RIGHT / HIT DOWN / HIT UP，然后 RECOIL
  取得 Collider2D（本体不足再查子物体）
  state=Recoiling；Sweep(collider, direction, 3)
  speed=newSpeed；timeRemaining=duration
```

证据：[Recoil.cs:152](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/Recoil.cs:152)、[Recoil.cs:234](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/Recoil.cs:234)。

每个物理步 Frozen 强制 velocity=0；Recoiling 用 Sweep 检测 `speed*fixedDeltaTime`，mask=256，按裁剪距离直接加 body.position 或 Translate。撞到地形后停止 Sweep 位移，但剩余硬直继续计时；到时 CancelRecoil→Ready，触发 OnCancelRecoil 和 `RECOIL END`。这不是 Rigidbody.AddForce，不是指数速度衰减；减弱公式只用于“是否用新击退覆盖旧击退”。证据：[Recoil.cs:260](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/Recoil.cs:260)。

移动组件是否暂停/继续由监听事件或读 IsRecoiling 的控制器决定。不得以“存在 Recoil 组件”推断怪物一定中断当前攻击。

### A8. 敌人如何伤到主角

`DamageHero.OnTriggerEnter2D` 本身主要处理 clash/tink；扣血入口由主角 `HeroBox.OnTriggerEnter/Stay` 检查命中对象的 DamageHero。持续重叠会持续提供候选，但主角受伤门禁决定何时真正扣血。若对象挂旧 `damages_hero` FSM，HeroBox 有兼容读取 damageDealt/hazardType 的路径。证据：[DamageHero.cs:305](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageHero.cs:305)、[HeroBox.cs:41](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/02_Player/HeroBox.cs:41)。

候选接受条件：DamageHero 存在，`Time.timeAsDouble >= damageAllowedTime`，启用时读取 damageDealt，禁用按 0；正伤害进入缓冲。`SetCooldown` 只把 damageAllowedTime 向更远的未来延长，负数/0 无效。damageDealt=0 且 forceParry 时仍可能形成弹反候选。证据：[DamageHero.cs:141](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageHero.cs:141)、[DamageHero.cs:545](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageHero.cs:545)、[HeroBox.cs:78](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/02_Player/HeroBox.cs:78)。

HeroBox 对 hazardType<=ENEMY 的候选缓冲到 SuperLateFixedUpdate；其他类型立即处理。同一批中的 damageDealt 取较大值，但来源/类型/方向/flags 被后来的候选覆盖，不能简单解释成“选出完整的最高伤害那次 hit”。默认碰撞方向比较伤害物体 x 与主角 x，可由 OverrideCollisionSide 或 InvertCollisionSide 改写。证据：[HeroBox.cs:100](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/02_Player/HeroBox.cs:100)。

普通敌人/爆炸命中的 HeroController 门禁至少包括：CanTakeDamage、damageMode、shadowDashing、evading 与来源层、whipLashing 与层 11、downspikeInvulnerabilitySteps（除非 noBounceCooldown）、parryInvulnTimer、parrying/parryAttack。CanTakeDamage 又检查过场、受击无敌、recoiling、死亡、hazardDeath、外部 HeroInvincibilitySource 等。不能让敌人攻击直接调用 `hero.hp -= damage`。证据：[HeroController.cs:5371](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/02_Player/HeroController.cs:5371)、[HeroController.cs:11217](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/02_Player/HeroController.cs:11217)。

主角受伤成功后的 DamageHero 回调可向 HeroDamagedFSM 发事件、写 bool、写命中对象，再调用 OnDamagedHero UnityEvent。敌人“撞中后退后/结束突进”常依赖这些回调，不应只保留扣血。证据：[DamageHero.cs:508](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/DamageHero.cs:508)。

### A9. HP 归零不是统一销毁

`Die()` 如果已经 isDead，或 preventDeathAfterHero 且主角已死，会直接 return；否则取消延迟命中。随后给 zeroHPEventOverride 或本物体发送 `ZERO HP`，取消 BlackThreadState 攻击；Lava 还发 `LAVA DEATH`。**hasSpecialDeath=true 时在这里执行 NonFatalHit/掉落后提前 return，不设置 isDead、不自动清零 DamageHero、不直接发 FATAL DAMAGE。**Boss 阶段切换、假死、死亡动画、最终结算必须读它的 ZERO HP 消费者。证据：[HealthManager.cs:1564](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1564)、[HealthManager.cs:1649](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1649)。

普通死亡继续发 `FATAL DAMAGE`，设置 isDead=true，若本体有 DamageHero 则 damageDealt=0，扣减 BattleScene 普通/大敌计数，发 KILLED 给指定对象，触发 OnDeath，交给 EnemyDeathEffects 生成尸体/关闭对象等。Splatter 走特殊关闭分支。子攻击对象是否一并关停需要个案 FSM/层级证据，HealthManager 这里只直接清本体缓存的 DamageHero。证据：[HealthManager.cs:1667](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1667)。

`sendDamageTo` 将扣血写到另一 HealthManager，但随后的 NonLethal/hp>0/死亡分支仍读本体 hp；不能自行改成全都操作接收者。多部位 Boss 必须追踪其另有的同步组件和 FSM。证据：[HealthManager.cs:1302](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1302)。

### A10. PlayMaker 与动画合同

#### 并发 action 和消息目标

同一状态中的 Wait 不是让后面的 action 睡眠；官方本地 Wait 注释明确说其他 action 继续运行并可先发事件。Finish 是 action 生命周期结束，并非把整个敌人停住。必须读取每个 action 的 OnEnter/OnUpdate/OnFixedUpdate/OnExit；不能只把状态表翻译成顺序脚本。证据：[Wait.cs:7](/Users/mars/workspace/SilksongUnity6/Assets/PlayMaker/Actions/Time/Wait.cs:7)。

`FSMUtility.SendEventToGameObject` 对同物体的全部 PlayMakerFSM 依列表顺序调用 Fsm.Event；默认不递归子物体，只有 isRecursive=true 才递归。`HIT`/`ZERO HP` 是广播给该物体 FSM 集合；向另一对象、指定 FSM、全局广播和向父转发必须保留目标类型。证据：[FSMUtility.cs:251](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/FSM/00_Core/FSMUtility.cs:251)。

**移植规范**：每次进入状态生成 generation/token；action 持有自己的完成状态/计时和所订阅的回调；状态退出执行 OnExit 并撤销订阅/定时器。长延迟回调只可影响原始 token 或明确标为跨状态的对象。这个 token 是建议的复现结构，不是宣称原 PlayMaker 内核已有同名字段。若要与 DLL 的同帧重入行为逐帧一致，必须以事件 trace 对齐。

#### 随机选择并非独立抽签

| Action | 选择及记忆规则 | 源码 |
|---|---|---|
| WaitRandom | OnEnter 抽一次 time∈[min,max]，该次状态使用这一份；不每帧重新抽 | [WaitRandom.cs:32](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/WaitRandom.cs:32) |
| SendRandomEventV2 | 按 weights 抽；若该招连续 trackingInt 达 eventMax 则重抽；选中项计数+1，其他计数清零；循环防护约 1000 次 | [SendRandomEventV2.cs:28](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/SendRandomEventV2.cs:28) |
| SendRandomEventV3 | 加入 trackingIntsMissed/missedMax；扫描遗漏达到阈值的项，若多项满足取数组中最后一项，强制释放；否则执行连续上限；其他遗漏计数+1，选中项遗漏归零；超过 100 次循环退到 events[0] | [SendRandomEventV3.cs:33](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/SendRandomEventV3.cs:33) |
| SendRandomEventFair | 使用 TrackingArray 时，中选项恢复基础概率，所有未中项乘 MissedMultiplier；没有 TrackingArray 时直接基础权重抽 | [SendRandomEventFair.cs:39](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/SendRandomEventFair.cs:39) |

实现必须保存 RNG 状态或每次抽样结果及 action 调用次序；同时保存连续计数/遗漏计数/动态权重。只固定随机种子而忽略 V2/V3 的拒绝重抽次数，无法对齐后续序列。演示项目可采用独立战斗 RNG 避免特效抽样扰动，但它属于移植设计；本地源码中多处使用 UnityEngine.Random，逐调用复刻需记录原始调用流。

#### 动画决定事件时间

tk2d 使用 `clipTime += dt * clipFps`，Once 到 `frames.Length` 完成；离散帧号按时间取整数，并处理从 previousFrame 到新帧跨越的帧事件。必须在掉帧跨过多个关键帧时仍处理区间内事件，不能只检查当前显示帧。Loop、LoopSection、PingPong 有不同索引公式；复现时需记录 wrapMode 和 loopStart。证据：[tk2dSpriteAnimator.cs:493](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimator.cs:493)、[tk2dSpriteAnimator.cs:626](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/TeamCherry/TeamCherry.TK2D/tk2dSpriteAnimator.cs:626)。

`Tk2dPlayAnimationWithEvents` 进入时选择 expectedClip，绑定 AnimationEventTriggered/AnimationCompleted；帧事件把 eventInt/eventInfo/eventFloat 放到 Fsm.EventData，再发配置事件；完成把 clip id 放 IntData。退出时解除回调。若 clip 不存在，会发配置 trigger/complete 并 Finish；若播放中 currentClip 被其他系统替换，OnUpdate 也发两种事件并 Finish。**缺失动画会让攻击立刻越过准备阶段，不能当作动画不影响逻辑。**证据：[Tk2dPlayAnimationWithEvents.cs:55](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/Tk2dPlayAnimationWithEvents.cs:55)、[Tk2dPlayAnimationWithEvents.cs:96](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/Tk2dPlayAnimationWithEvents.cs:96)。

每个招式必须导出：clip 名、fps、帧数、loopStart、wrapMode、触发帧索引、事件载荷、启用/禁用的攻击碰撞体、生成物体/弹道、速度改变及受击取消方式。`某动画有 12 帧` 不能单独推出攻击持续 0.2 秒；必须有 fps 和变速来源。

### A11. 必须保留的源码疑点与未知项

| 项 | 当前代码/数据可验证事实 | 复现处理 |
|---|---|---|
| HealthManager invulnerableTime | Deprecated 字段，当前 NonFatalHit 没有用它设置 i-frame | 不给所有敌人添加统一受击无敌 |
| HealthManager immuneToBeams | 字段存在，IsImmuneTo 未读取 | 分别标记“配置存在”和“本方法未生效”，查实际 Beam 入口 |
| IsImmuneTo 与 HitResponse | TakeDamage 可因免疫 return；外层 Hit 仍返回 DamageEnemy | 记录 response 与 HP delta 两个字段 |
| sendDamageTo | 扣血目标和后续死亡条件可不是同一对象 | 查个案同步，不擅自修正 |
| ChaseObjectGround snap | DoSnap 把 rb vx=0，但随后 DoChase 又把之前局部 linearVelocity 写回 | 原样模式保留；修复模式单列；不能仅凭 snapTo 名称声明速度停住 |
| FairConditional 条件 | conditionArray 只在 null/长度变化时从条件变量生成，不每次 OnEnter 重算 | 动态 phase 条件是否生效需要实测 |
| FairConditional 无外部 tracking | 读取 selfTrackingArray，但本方法未写回；本地数组本次计算后可丢失 | 不宣称必然有持久的遗漏加权 |
| Physics2D layer matrix | 当前序列化字符串包含 `/f`、`+`、`)`、`(` 等非标准十六进制字符 | 核验 Unity 实际加载后的矩阵；不要把此字符串当已验证的 32×32 掩码 |
| PlayMaker DLL 内核 | 本章未反编译队列及 reentrant transition 内部 | 用运行 trace 补证，再承诺同帧一致 |

前三项与 sendDamageTo 的证据见 A6/A9；snap 见 [ChaseObjectGround.cs:155](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/ChaseObjectGround.cs:155)；FairConditional 见 [SendRandomEventFairConditional.cs:43](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/SendRandomEventFairConditional.cs:43)；矩阵见 [Physics2DSettings.asset:56](/Users/mars/workspace/SilksongUnity6/ProjectSettings/Physics2DSettings.asset:56)。

这张表是静态审计结果，不等同于宣布零售游戏有同样缺陷；迁移/导出过程可能改变了内容。本章检查的主战斗类有完整方法体，没有证据把它们整体叫作 stub。

### A12. AI 实现时的数据合同

```yaml
enemy_spec:
  identity:
    asset_guid: required
    prefab_path: required
    scene_path_and_instance_id: required_for_instance
    source_revision_or_hash: required
  provenance:
    confidence: source_verified | asset_verified | runtime_verified | inferred | unknown
    sources: [{path: string, line: integer, field_or_method: string}]
  body:
    position: [x, y]
    facing_rule: explicit_formula
    rigidbody: {body_type: required, gravity_scale: required, drag: required, constraints: required}
    colliders: [{id: string, shape: required, offset: required, size_or_points: required, layer: required, trigger: boolean}]
  health:
    hp: required
    scaling: required
    invincible: boolean
    invincible_from_direction: integer
    special_death: boolean
    send_damage_to: nullable_object_ref
  sensors:
    - {collider_ref: string, filters: required, los_mode: integer, mask: integer, in_delay: number, out_delay: number}
  fsms:
    - name: string
      initial_state: string
      variables: [{name: string, type: string, value: any, binding: literal | local | global | object_ref}]
      states:
        - name: string
          actions: [{type: string, phase: string, enabled: boolean, parameters: object, source: object}]
          transitions: [{event: string, target: string, guard_if_any: string}]
  animations:
    - {clip: string, fps: number, frames: integer, wrap_mode: integer, loop_start: integer, events: []}
  attacks:
    - id: string
      decision_guards: []
      entry_sampling: []
      telegraph: {entry_action: string, exit_event: string}
      active: {hitbox_refs: [], trajectory: string, exit_event: string}
      recovery: {movement_policy: string, exit_event: string}
      cancel_on: [{event: string, destination: string, cleanup: []}]
      spawned_objects: []
      random_memory: {consecutive: [], missed: [], weights: []}
  unknowns: []
```

该 schema 为建议的移植格式，不声称是 Unity 的现有格式。引用必须能回到可读字段/方法；拿不到数值就用 null 与 unknown 原因，不能用 0 伪装已知。启用状态、对象路径和 FSM 变量绑定都必须保存；同名 action 中的字面量 0 与绑定到名为 X 的变量不可混为一谈。

### A13. 复现验收：可执行场景矩阵

最小 trace 字段：`renderFrame, fixedCycle, scaledTime, unscaledTime, objectId, fsmName, previousState, event, nextState, actionIndex, actionType, rngDraw, variablesChanged, position, velocity, animationClip, animationFrame, hitboxEnabled, incomingHit, response, hpBefore, hpAfter, recoilState`。这是建议的验证设施；本次没有修改游戏添加日志，也没有声称已经跑过以下测试。

| ID | 固定输入/操作 | 判定通过条件 |
|---|---|---|
| CORE-01 初始化范围 | 主角出生时已处于 AlertRange | 初始化 Overlap 后可检测；不必先出再进 |
| CORE-02 视线 | 同样距离，一次隔墙一次无遮挡 | 开启视线的怪物仅无遮挡触发；None 模式仅依范围 |
| CORE-03 稳定延迟 | 在范围边界内外切换，停留不足 In/OutDelay | timer 翻转重置；不会累计多次短暂进入为一次完整警觉 |
| CORE-04 同击多 Hurtbox | 单次攻击同一步覆盖同一 responder 的多个碰撞体 | 按去重规则一次 HP 变化；有明确多部位设计者另验 |
| CORE-05 多段周期 | 目标持续重叠，multiHitter，stepsPerHit=N | 后续段间隔按物理步 N；不是按渲染帧 N |
| CORE-06 防御四向 | 相同伤害从四方向打 invincibleFromDirection 指定值 | 与 A6.4 的方向矩阵一致；HP 变化与 block 事件一致 |
| CORE-07 防御绕过 | 对 directional invincible 分别用 Nail/Explosion/Lightning/Piercer | 绕过条件完全按 A6.4；类型免疫仍独立生效 |
| CORE-08 无敌误解 | 普通怪连收两次独立合法 hit，不设额外 FSM 保护 | 不凭 invulnerableTime 引入固定 i-frame |
| CORE-09 连击衰减 | RapidBullet 连续输入，跨 0.15 秒窗口对照 | 计数与整除、最低 1、到期归零均匹配 |
| CORE-10 攻击与身体同帧 | 主角攻击命中敌人的同时身体接触 | trace 先处理 DamageEnemies，再 HeroBox；后者使用届时实际状态 |
| CORE-11 击退撞墙 | 已知速度/时长的 recoil 朝紧邻墙施加 | 位移裁剪，计时仍走；RECOIL END 只在结束时出现 |
| CORE-12 击退重入 | 强 recoil 剩余时间内插入弱 recoil | 弱于 remainingStrength 被忽略；强击可更新 |
| CORE-13 Stun | 保持 HP>0，输入已知 StunDamage | Stun Damage 变量和 STUN DAMAGE 发送匹配；阈值由个案 FSM 判定 |
| CORE-14 特殊死亡 | hasSpecialDeath Boss HP 打到零 | 先 ZERO HP；由 Boss FSM 进入阶段/死亡；不自动当普通怪禁用 |
| CORE-15 动画事件掉帧 | 人为跨越若干动画帧，区间有攻击事件 | 跨越区间事件按序发出，不漏 active/start/end |
| CORE-16 动画被替换 | 受击导致 expectedClip 被替换 | 对 WithEvents action，trigger/complete 回退及退出解绑匹配 |
| CORE-17 随机记忆 | 固定 RNG 流，连续多次进入选择状态 | 连续上限、missed 保底、权重恢复和调用次数完全一致 |
| CORE-18 状态取消 | 攻击 active 中强制 HIT/STUN/ZERO HP | 对应 FSM 指定取消路径，子攻击对象/残留回调按清理合同执行 |
| CORE-19 场景覆盖 | 同 prefab 放到两个覆盖参数不同的实例 | 数值按实例覆盖；不会两只都读 prefab 基础值 |

验收分三层：结构等价（状态/事件/参数齐全）、行为等价（指定输入下决策、路径、伤害结果一致）、时序等价（有原运行 trace 的前提下逐帧对齐）。只有静态源码和资产时，能够交付前两层的实现依据及待验证项，不能伪称已完成第三层。允许误差必须作为验收配置明确写下；严格同逻辑事件顺序应零误差，位置/时间容差由对照实验设定，不预先捏造“原版容差”。

## B. 给人学习的解释

### B1. 学习一只怪物，先画出四条同时运行的线

第一条是**决策线**：它此刻巡逻、警觉、选择招式、前摇、出招还是后摇。第二条是**运动线**：身体速度是谁写的，重力是否仍开着，遇墙是否停止。第三条是**命中线**：身体碰触是否伤人、武器判定何时打开、主角打中哪一块会扣血。第四条是**事件线**：动画到了关键帧、受击、眩晕和 HP 归零把哪些系统唤醒。

这四条线通过事件协作。你看到怪物“抬手然后冲过来”，往往对应 FSM 开始一个动画，同时 Wait 计时、距离检测继续；到动画帧事件才开武器判定或改速度。它被针打中时，HealthManager 先发 HIT/TOOK DAMAGE，Recoil 再发击退事件，Stun FSM 另算眩晕。要复现的是这个协作过程。源码入口见 [HealthManager.cs:1056](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/03_Combat/HealthManager.cs:1056) 和 [Tk2dPlayAnimationWithEvents.cs:117](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/Tk2dPlayAnimationWithEvents.cs:117)。

### B2. “看见主角”也有完整规则

不要先写一个距离小于 10 的 if。先找到子物体上的警戒碰撞形状，看它是否要求主角标签，是否有视线遮挡，是否从父节点发射线，再看进入多久才触发警觉。`CheckAlertRange` 的延迟要求结果连续保持；主角反复擦边不等于一直在范围内。受伤还能清零脱战计时，这解释了某些怪物明明暂时看不见你，仍然保持战斗。

练习时画三个区域：身体 Hurtbox、攻击 Hitbox、警戒 Sensor。让它们使用不同颜色。只改变 Sensor 大小，应该改变发现距离而不改变武器攻击距离；只改变 Hitbox，应该改变招式命中范围而不改变何时发现你。若三个都变化，说明实现把不同职责混在了一起。对应规则见 A4。

### B3. 前摇、攻击有效期、后摇必须能量化

每个招式写成一张“时间—动作表”：

| 时点 | 决策 | 身体运动 | 判定 | 可中断性 |
|---|---|---|---|---|
| 进入准备状态 | 采样距离/朝向/随机项 | 停、缓行或保持，需要实证 | 武器通常关闭，需读实际配置 | 受击/眩晕/死亡各看转移 |
| 准备动画关键事件 | 转到攻击或修改当前状态 | 设速度/发射弹体/起跳 | 打开指定 Hitbox | 可能仍可眩晕 |
| 攻击结束条件 | 落地、碰墙、动画结束或距离完成 | 停止或衔接下一段 | 关闭旧 Hitbox | 不能让旧回调重新打开 |
| 恢复状态完成 | 回到选择/巡逻 | 按该状态指定恢复 | 身体接触可能仍存在 | 决定玩家反击窗口 |

表里的“通常/可能”只用于教你观察，个案规格必须用精确规则替换。关键事件如果来自动画第 k 帧，要记录 fps；若来自 Wait，要记录时钟；若来自落地，要记录检测 Collider 和 mask。没有这些信息，所谓“0.3 秒前摇”可能只是错把画面估计当成内部时间。

### B4. 受伤、后退、眩晕和无敌是四件不同的事

**受伤**是 HP 变化和事件。**后退**是 Recoil 的位置位移。**眩晕**是另一个 FSM 决定的状态。**无敌/盾**是对命中方向和攻击类型的过滤。它们可以任意组合：有的敌人扣血而不移动；有的盾挡住伤害却会后退；有的连续吃针，直到 Stun FSM 过阈值才倒地。

本地普通 NonFatalHit 没有统一设置受击无敌。你若给每只怪物加 0.5 秒 i-frame，会让多段攻击、爆炸叠加和连击难度全部改变。反过来，如果省略 DamageEnemies 对一次挥击的去重，同一把针连续贴着敌人会在每个物理步扣血；画面看起来很像，战斗完全不一样。源码依据见 A6.2/A6.5。

方向盾也容易写反。原代码的方向 0 指“攻击向右行进”，通常是从目标左边打进来，不是“目标的右侧”。而且 HitInstance 自己另一个方向枚举把 Left 设成 0。先用四向测试画箭头，再实现盾表，可以避免大量“只有横向格挡不对”的问题。

### B5. 为什么照着动画播，还是不像原来

因为动画还会发逻辑事件。tk2d 动画到关键帧，把整型/字符串/浮点载荷放进 FSM.EventData，然后事件推动招式。切换动画也会触发 WithEvents action 的回退事件。缺少动画资源时，这个 action 甚至会立即发事件并结束。因此灰盒原型即使没有美术，也要做一个拥有 fps、帧数、事件帧和完成回调的“逻辑动画时钟”。

另一个常见问题是移动公式。`ChaseObjectGround` 每次调用直接给 vx 加 acceleration，没有乘 deltaTime。把它改成通常课本里的 a*dt，数值相同而实际加速会慢约一个物理频率倍。这里应忠实读取公式，再决定是保留旧单位还是明确换算，不要边移植边无声改义。对应代码与疑点见 A5/A11。

### B6. 为什么 Boss 的随机招式有节奏

V2 会限制同一招连续出现几次；V3 还会保证久未出现的招式获得一次强制机会；Fair 则逐步增加未被选中招式的权重。因此“从三招里等概率抽一个”不能复现体验。玩家会感到某招刚出过后较少再来，或者长时间没出现的招式快要来了，这可能来自可量化的计数器。

学习时同时记录招式序列和计数：本轮连续计数、每招遗漏次数、动态权重。给主角一条固定运动轨迹，跑相同随机输入两次，若第二次不同，先查计数是否重置、事件是否多调用一次、特效是否消耗了同一随机源。具体动作规则见 A10。

### B7. HP 打空后，先问是谁接管了控制

普通小怪的死亡可以走统一路径：isDead、接触伤害清零、房间计数减少、尸体/掉落、对象失活。特殊死亡的 Boss 在 `ZERO HP` 后把控制权交回 FSM，本次 Die 甚至不设置 isDead。它可以开下一阶段、倒地说话、生成另外一个对象，再由具体状态做最终结算。

因此做 Boss 复现时，终局验收至少包括：HP=0 时当前招式怎样取消、已有弹体是否消失、阶段触发在哪个事件、接触伤害何时关闭、房间门何时解锁、重新进入场景是否复活。只看“死亡动画播放完”不足以证明完成。源码合同见 A9；每个 Boss 的具体答案由个案和场景 FSM 填入。

### B8. 推荐的实际学习路径

1. 从一只使用 Walker 的地面小怪开始，做出身体、警戒、转身、墙壁和悬崖规则。先验证移动与发现距离。
2. 接入主角攻击，验证单挥击去重、HP、四向击退和普通死亡。把伤害事件 trace 打出来。
3. 再选一只有明确前摇/后摇的近战怪，把招式写成 B3 的时间表，逐条转成 FSM/action。
4. 再做弹射/飞行或带护甲的敌人，练习独立弹体生命周期、方向盾和目标采样。
5. 最后做多招 Boss，加入选择记忆、Stun FSM、阶段与场景协调。

每一步只用该敌人的真实参数。可以临时用方框替代贴图，但必须保留原判定形状、运动参数与动画逻辑时钟。完成以后，用 A13 场景矩阵与原运行记录对照；没有运行记录的部分写“源码实现完成，逐帧验证待做”，这比把观感接近当成一比一复现更有价值。

### B9. 每只怪物的学习笔记模板

```text
身份：prefab / scene / 实例覆盖 / 实际组件
进入战斗：激活条件、范围形状、视线、稳定延迟
平时移动：控制器、公式、速度单位、朝向约定、墙/边缘处理
决策点：什么时候重新选招；哪些距离和阶段变量在此刻采样
每个招式：准备 → 有效 → 恢复；每段入场动作、结束条件、碰撞体和运动
命中交互：身体/武器伤害、弹反、下劈反弹、盾、免疫
受击交互：HP、击退、眩晕累计、中断/不打断、特殊受击动画
阶段/死亡：ZERO HP 的消费者、阶段参数变更、清理和结算
随机：基础权重、连续限制、遗漏规则、记忆重置
证据：每个数字/条件对应源码行或资产字段
验证：输入轨迹、事件 trace、已通过项、UNKNOWN
```

这份笔记与 AI 数据合同表达相同事实：人类版解释因果和观察方法，AI 版约束字段、执行顺序和边界条件。两者都应能指导实现，并且都必须诚实保留当前证据尚不能证明的部分。
