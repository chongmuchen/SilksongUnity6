# 非普通 HealthManager 链：六类必须另行建模的对象

这些图鉴记录不能统一翻译为“具有 HP 的普通敌人”。图鉴记录位置可能是生成器、区域或首次交互奖励点；实际行为必须沿 prefab、动态组件和场景协调器继续追踪。这里给出当前源码可验证的运行时合同，完整 FSM 与场景对象引用见相应 `data/entities/*.json`。本次为静态分析，未声称已经逐帧运行验证。

## A. 给 AI 的补充实现规格

### S1. 动态受击代理：为什么静态组件表没有 HealthManager 仍能被打

`ReceivedDamage` 不是空 stub；它继承 `ReceivedDamageBase`，行为在父类实现。OnEnter 在目标上取得或动态添加 `ReceivedDamageProxy`，注册本 action；OnExit 注销。Proxy 实现 IHitResponder，有 handler 时把 HitInstance 分发给当前仍有效的 handler；防止重入；至少一个 handler 接受且没有 dontReportHit 才返回 GenericHit。它不扣 HP，不走 HealthManager 死亡。证据：[ReceivedDamage.cs:5](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/ReceivedDamage.cs:5)、[ReceivedDamageBase.cs:81](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/ReceivedDamageBase.cs:81)、[ReceivedDamageProxy.cs:38](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/ReceivedDamageProxy.cs:38)。

父类过滤：Source 必须存在；firstHitOnly 可拒绝多段后续击中；collideTag 可限制来源标签；ignoreHunterWeapon/Traps/Lava/Nail/Spikes 按 AttackType，ignoreAcid/Water 则按 Source 标签。DamageDealt 必须>0；manualTrigger 还必须 IsNailDamage。接收后写 storeGameObject/storeDamageDealt/storeDirection/storeMagnitudeMultiplier；Spell/Heavy 发 sendEventHeavy，Spikes/Lava 分别专用事件，Lightning 或 ZapDamageTicks>0 发 Lightning 事件，最后总会尝试 sendEvent。证据：[ReceivedDamageBase.cs:93](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/ReceivedDamageBase.cs:93)。

**复现合同**：受击订阅只在指定 FSM 状态有效；允许同物体多个 FSM 同时订阅；每个订阅决定事件，不假定有全局 HP。AI 不能因为 `ReceivedDamage.cs` 只有空子类就填“未实现”。

### S2. Wisp：生成器、盘旋实体、受控追踪弹体

**资产路线**：图鉴 GUID `8b17e243b0d0e724ea50adad832b7005` 在场景中可由 Wisp Flame Lantern 引用；实际生成对象是 [Wisp Fireball.prefab](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab>)。该 prefab 本体有 DamageHero、Control/Shove From Hero/Hit Effects FSM，ReceivedDamage 在运行时提供受击代理。灯笼有自己的 Idle/In Range/Summon/Asleep/Broken 等状态，不能把灯笼坐标当成所有 Wisp 的身体轨迹。生成器例：[Wisp_02.unity:1020914](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Wisp_02.unity:1020914)。

普通 Wisp 的主要路线：

| 状态 | 可验证动作 | 结束/取消 |
|---|---|---|
| Fly Start | 随机 scale 0.81–0.91；Distance 8–10，Height 4–6；DistanceFlyV2 speedMax=9、acceleration=0.4、targetsHeight=true；启用本体 Collider 与 Terrain Detector；ShoveFromWall force=20、rayLength=3 | WaitRandom 0.25–0.25 秒到 Follow Hero |
| Follow Hero | 继续盘旋/避墙；累计 Lifetime；等待 0.75–1.2 秒 | FINISHED→Request Attack；DAMAGE→Explode；Lifetime>6 的比较在**状态进入时**执行（everyFrame=false）→Dissipate |
| Request Attack | Pyre Fly 可以直接 APPROVED；不在 Attack Range→DENIED；向 Wisp Fireball Master 发 ATTACK REQUEST；0.01 秒后发 DENIED 作为兜底 | APPROVED→Fire Antic；DENIED→Follow Hero |
| Fire Antic | FireAtTarget speed=-12（先向反方向退）；DecelerateV2=0.94；播 Fire 动画，帧触发事件 FINISHED；停 Shove | FINISHED→Fire Start；DAMAGE→Explode |
| Fire Start | Collider 改 Trigger；scale=1.25；先 FireAtTarget speed=0.5；ChaseObjectWisp accelerationForce=50、speedMax=45 | NextFrameEvent→Fire |
| Fire | ChaseObjectWisp accelerationForce=32、speedMax=33；2 秒计时 | COLLIDE/WAIT/DAMAGE/HERO DAMAGED→Explode；WATER→Water |
| Explode | 关闭 Terrain Detector/Attack Detector/Haze，打开 Explosion 对象 | FINISHED→Exploding；等待 3 秒→Recycle |

证据为 prefab 解码的状态 action：Fly Start [Wisp Fireball.prefab:1250](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:1250>)；Follow Hero [同文件:4919](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:4919>)；请求 [同文件:6981](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:6981>)；准备 [同文件:1872](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:1872>)；冲刺 [同文件:3462](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:3462>)、[同文件:2245](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:2245>)；爆炸 [同文件:2721](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:2721>)。

`ChaseObjectWisp` 不是匀速直线：OnEnter 将 speedMin 写为 0，然后每个 FixedUpdate 将 `(target+offset-self)` ClampMagnitude 到 1，再乘 accelerationForce，AddForce；随后把当前速度限制到 speedMax，若低于 speedMin 则沿原方向恢复到 speedMin；最后把 speedMin 提高到达到过的更高速度。即同一 action 的 speedMin 是运行记忆。目标方向持续更新，而达到过的速度下限会保留。证据：[ChaseObjectWisp.cs:50](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/ChaseObjectWisp.cs:50)。

Control 中多个状态的 ReceivedDamage 只给 `sendEventHeavy=DAMAGE`，普通 sendEvent 为空；父类让 Spell 和 Heavy 走这一事件。因此普通针命中可以触发另一个 Hit Effects FSM 的效果，但不能仅据 `ignoreNail=false` 推断必然销毁 Wisp。证据：[Wisp Fireball.prefab:1872](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:1872>)、[同文件:8818](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:8818>)、[ReceivedDamageBase.cs:146](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/ReceivedDamageBase.cs:146)。

DamageHero 本体序列化 damageDealt=1、hazardType=1、damagePropertyFlags=4、成功伤人回调 HERO DAMAGED。flags=4 是 Flame，而 HeroController 对正伤害的 Flame 将伤害改为 2，因此资产标称 1 并不是最终扣血保证；后续主角门禁/模式仍参与。证据：[Wisp Fireball.prefab:905](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Enemies/Wisp Fireball.prefab:905>)、[DamagePropertyFlags.cs:11](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/GlobalEnums/DamagePropertyFlags.cs:11)、[HeroController.cs:5313](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/ProjectCode/Game/02_Player/HeroController.cs:5313)。

**为何不是普通死亡链**：生命周期由 Explode/Water/Min Explode/Dissipate/End/Recycle 状态和生成器/主控消息决定，受到控制权许可才攻击。必须保留 `Wisp Fireball Master` 引用；缺失主控时 0.01 秒拒绝兜底会反复回盘旋，不能用“随机攻击”假装原逻辑。具体许可并发额度必须继续读取所属场景 Master FSM，不从单只 prefab 推断全场攻击频率。

验收：普通针与 Spell 分别命中，核对特效与爆炸是否分离；主控分别允许/拒绝攻击；冲刺命中主角后是否爆炸；Wait 2 秒是否爆炸；接水是否使用 Water 分支；Recycle 后爆炸子对象关闭并可安全重用。

### S3. Wisp Pyre Effigy：多个灯臂与独立核心血量的场景 Boss

实际核心位于 [Belltown_08.unity:653019](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:653019)，有 Summon Control、Wobble、Take Damage 三台 FSM；核心受击通过 S1 的动态代理。不能从没有 HealthManager 得出“无战斗”，也不能把图鉴记录的一个对象当成 Boss 全部构件。

可验证的复现骨架：

1. `Set HP` 读取 BL/BR/TL/TR 四个灯臂的 `wisp_brazier_arm` FSM 变量 HP，汇总到 Lanterns Total HP，乘 0.5 得 Lanterns Half HP；`Count Lantern HP` 会先清总值再重算。灯臂初始 HP 必须从各实例或模板覆盖读取，不能把核心 250 套给每个灯臂。证据：[Belltown_08.unity:658598](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:658598)、[同文件:658942](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:658942)。
2. P1/P2 将 Summon Time 分别设为 2.5/2 秒。这只是间隔参数变更；阶段条件仍以 Set Summon Time 的分支和四臂状态为准。证据：[同文件:655801](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:655801)。
3. 核心 Take Damage 初始 `Init` 没有 action，只等待 `CORE DAMAGE READY` 才进 Idle。Idle 启用核心 CircleCollider，注册 ReceivedDamage，写 Damage Dealt，并在本状态每秒将 Hit Cooldown Timer 减 1、clamp -5..5。核心 FSM 的 HP 序列化初值 250；这不是 HealthManager.hp。证据：[同文件:685614](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:685614)、[同文件:686791](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:686791)。
4. DAMAGED→Increment Hit Total?。若 Hit Cooldown Timer>0，发 FINISHED 跳去 Hit；否则 Total Times Hit+1，并将 Timer=0.5。Hit 状态用 IntOperator 的 subtraction 让 HP-=Damage Dealt；HP<=0 或 Total Times Hit>29 都发 BREAK。这里有“伤害累计”和“有效命中次数累计”两条通路，而且命中次数有冷却。证据：[同文件:686852](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:686852)、[同文件:685847](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:685847)。
5. Recover 暂关核心 CircleCollider，Wait 0.1 秒回 Idle；Break 向自身发 FINAL BREAK。注意 Timer 的递减 action 只存在于 Idle，不能把 0.5 秒计数冷却默认为全状态全局时钟。证据：[同文件:686598](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:686598)、[同文件:686700](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:686700)。
6. Summon Control 的 Final Hit 发图鉴记录，保存 defeatedWispPyreEffigy，关闭 Song Region/Flame Wave Damager，发 `WISPS END`；接着 Deactivate Pods 逐个关闭四个 Pod 碰撞体与可视对象/绳，再进入 Body Burn/Body Burst/Core Land/Core Steam/Core Explode/Activate Collectable/End 等结算。不能直接 Destroy Boss 来替代该流程。证据：[同文件:656978](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:656978)、[同文件:664097](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Belltown_08.unity:664097)。

**AI 必须另外载入**：四灯臂模板与实例变量、Summon Control 全状态、主控的 Wisp 请求协议、Flame Wave 与子弹 prefab。此小节是非 HealthManager 结构补充，不把未逐招展开的整场 Effigy 战斗声称已用本节完全描述。对应 [Wisp_Pyre_Effigy.json](/Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/data/entities/Wisp_Pyre_Effigy.json) 保存解码状态与 action 参数。

验收：核心未收到 CORE DAMAGE READY 前不接受这台 FSM 的受击；改变四臂 HP 后汇总一致；30 次计数门槛与纯伤害归零分别可进入 FINAL BREAK；短间隔连击不会错误地每下都增加 Total Times Hit；结算时召唤物、火浪和 Pod 均按各自动作清理。

### S4. Maggots：区域附着、抽丝与清除

它是区域系统，不是每只蛆都有 HealthManager。图鉴引用可在 Surface Water Region 的 MaggotRegion 上：例如 [Abyss_05.unity:937647](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Abyss_05.unity:937647)。战斗影响由 MaggotRegion/UnMaggotRegion 和 HeroController 状态构成。

**激活**：overrideActive 开启则用其值；否则检查当前 map zone 是否在 mapZoneMask。有效时订阅 SurfaceWaterRegion.HeroEntered/HeroExited/CorpseEntered。证据：[MaggotRegion.cs:79](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/MaggotRegion.cs:79)。

**进入**：登记 inside region，发 MaggotCheck。装备 MaggotCharm 且 MaggotCharmHits<3 时先增长护符计时，暂不 StartHeroMaggoted；否则立即附着。附着后标记 SilkSpool.Maggot 使用、阻止丝恢复、开启 TakeSilk 协程、设置主角 isMaggoted=true 和状态暗角。护符阶段一旦 MaggotCharmHits>=3 会结束护盾并开始附着。证据：[MaggotRegion.cs:131](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/MaggotRegion.cs:131)、[MaggotRegion.cs:278](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/MaggotRegion.cs:278)。

**抽丝**：稳定阶段每 0.5 秒 `insideHero.TakeSilk(1)`；重入保留 lastSilkTime。初次等待公式为 `remaining=0.5-(now-lastSilkTime)`；remaining>0 时等 remaining；remaining 位于 (-1,0] 时立即进入下一次扣丝；remaining<=-1 时重置 lastSilkTime 并等 0.5 秒。因此离开再立即进入不是无条件赠送一段全新 0.5 秒保护。证据：[MaggotRegion.cs:215](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/MaggotRegion.cs:215)。

**离开**：停止抽丝，解除区域暗角与丝恢复阻止，移出 inside 集合；这里没有直接 `SetIsMaggoted(false)`。附着状态的清除由 UnMaggotRegion 完成：在非活跃 MaggotRegion 的水/AlertRange 中，主角已附着才开始；连续停留 2 秒后清附着，途中退出就停止协程。证据：[MaggotRegion.cs:158](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/MaggotRegion.cs:158)、[UnMaggotRegion.cs:41](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/UnMaggotRegion.cs:41)、[UnMaggotRegion.cs:117](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/UnMaggotRegion.cs:117)。

**击杀图鉴**：ReportExplosion 在激活区域内调用 maggotJournalRecord.Get(maggotJournalRecordAmount 的随机值)；ReportLightningExplosion 用 lightningKillAmount（类默认 3–4，实际实例可覆盖），再播放粒子。没有在这里逐只减 HP 或把整个水域永久杀死。证据：[MaggotRegion.cs:296](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/MaggotRegion.cs:296)。

验收：区域不激活无附着；持续站水每 0.5 秒扣 1 丝；短暂出入保持扣丝时序；离水恢复丝能力而 attached flag 不被此方法立刻清掉；清洗不足 2 秒离开无清除；爆炸记数来自区域配置，不凭粒子个数计数。

### S5. Sand Centipede：成组出没的环境攻击器

**避免错误同名关联**：`SandCentipede.cs` 控制背景/出没展示：等待随机 waitTime，在 minPos/maxPos 线段随机位置且镜头范围内出现，随机翻转与动画，按动画长度隐藏；该类不实现 IHitResponder，也没有伤害/图鉴逻辑。真正带 Sand Centipede 图鉴的实例使用 `RangeAttacker`，如 [Coral_02.unity:1232982](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Coral_02.unity:1232982)。证据：[SandCentipede.cs:58](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/SandCentipede.cs:58)。

**控制层**：RangeAttackGroup 对 groupRange 内所有对象取位置，每个 FixedUpdate 判断各 attacker origin 到任一目标是否在 attackerAppearRadius 内，向该 attacker 写组 bitmask 的 inside 状态；多个组的 mask 合并为 insideMask!=0，所以离开某一组不一定代表完全不应出现。证据：[RangeAttackGroup.cs:134](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/RangeAttackGroup.cs:134)、[RangeAttacker.cs:338](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/RangeAttacker.cs:338)。

**单体状态顺序**：触发 inside==targetInsideState 且 appearChance 抽签通过→启动 Anim；随机翻转（dontFlipX 可禁）；等 appearDelay；显示、isOut=true、播 appearAnim；出现动画完成后启用自身 Collider（要求在 Hero plane）；播 loopAnim；至少 minLoopTime；若仍触发则保持；离开后等 disappearDelay，期间重新触发则取消撤回；否则关 Collider，播 disappearAnim，隐藏、isOut=false。若 explosionDisappear=true，跳过普通撤回延迟。完整方法还含演奏分支与主角死亡时序，不能把 minLoopTime 当“到点就自动缩回”。证据：[RangeAttacker.cs:324](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/RangeAttacker.cs:324)、[RangeAttacker.cs:385](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/RangeAttacker.cs:385)。

上述 Coral_02 实例参数：appearChance=1、appearDelay=0–0.1 秒、appearAnim=Up、loopAnim=Loop、minLoopTime=0.3–0.5 秒、disappearDelay=0.1–0.4 秒、disappearAnim=Down、journalAmountPerKill=5–8、customDamageEventRegister=`CENTIPEDE DAMAGE`。这些是该序列化实例事实，不自动代表所有沙蜈蚣变体。证据：[Coral_02.unity:1232982](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Coral_02.unity:1232982)。

**伤主角**：RangeAttackGroup 的 custom trigger 要求 anyAttackerActive 且碰撞对象 layer=20；调用主角 CanTakeDamageIgnoreInvul，计算向 sinkTarget 的 LastDamageSinkDirection，发自定义 register 事件，并 CancelAttack/CancelDownspike。单 RangeAttacker 也提供同类入口。最终伤害/下沉/位移由 `CENTIPEDE DAMAGE` 的消费者负责，不能只拿 DamageHero.damageDealt。证据：[RangeAttackGroup.cs:229](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/RangeAttackGroup.cs:229)、[RangeAttacker.cs:653](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/RangeAttacker.cs:653)。

**对爆炸/切碎响应**：可接受 AttackType.Explosion、Explosion 标签或 Tool 的 Shredding 标记。组控制器将碰撞半径/近似半径额外加 2 后，找范围内 attacker 调 ReactToExplosion；单体要求在 Hero plane，然后置 explosionDisappear，按 journalAmountPerKill 逐次 RecordKill 并出特效。它是“打散并缩回”的生命周期，不是普通 HP=0→尸体。证据：[RangeAttackGroup.cs:249](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/RangeAttackGroup.cs:249)、[RangeAttacker.cs:606](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/RangeAttacker.cs:606)。

验收：仍在触发范围内超过 minLoopTime 不自动消失；撤回延迟期间重入要继续停留；爆炸按范围影响多个 attacker；普通针与 Shredding 工具区分；CENTIPEDE DAMAGE 消费者收到方向，主角当前攻击被取消；纯展示 SandCentipede 对象不被误计为战斗个体。

### S6. Lifeblood Fly：可击破的资源生物

图鉴入口实际 prefab 是 [Health Flyer.prefab:699](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Items/Health Flyer.prefab:699>)，组件是 `HealthFlyer : IHitResponder`，不是 HealthManager。它的状态为 alive/landed，加出生保护时间，无可累减的 HP。

OnEnable：scale 随机 1.35–1.5；activateTime=now+0.25 秒；alive=true、landed=false；gravityScale=1，播 fallAnim。底部碰撞使 DoLand 播 landAnim；landAnim 完成→StartFly，gravityScale=0，给 Fly Behaviour 发 FLY，播 flyAnim/飞行音。证据：[HealthFlyer.cs:81](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HealthFlyer.cs:81)、[HealthFlyer.cs:251](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HealthFlyer.cs:251)。

Hit：activateTime 前或 !alive 返回 None；否则立即 alive=false，生成尸体/溅射、图鉴 Get；不按 DamageDealt 累计。IsNailDamage、Spell、NailBeam、Generic 设置“给蓝血”flag；其他类型也会先变成不存活，但没有这条蓝血协程。统一隐藏 Renderer，返回 GenericHit。证据：[HealthFlyer.cs:146](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HealthFlyer.cs:146)。

蓝血协程等待 1.2 秒后 AddBlueHealthQueued 并隐藏对象；同时订阅 UnloadingLevel，使卸载时也可执行已排队的奖励。距离主角>40 的处理会提前 SetActive(false)，协程是否随后继续取决于引擎对象失活语义，奖励卸载兜底需要一起验证，不能删掉监听。证据：[HealthFlyer.cs:116](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HealthFlyer.cs:116)。

Fly Behaviour 以 Idle 等 FLY，Flip Out 随机初速度 5–8，deceleration=0.9，速度模长<=1→Fly Away；Fly Away 启用 DistanceFly（distance=30、speedMax=6、acceleration=0.05），StartBounce、ShoveFromWall force=10/rayLength=2；DistanceFlySmooth action 存在但 disabled，不能按它的数值移植。`RandomFloatV2` 的角度序列化 min=120、max=60，需保留原 action 的处理，不能擅自交换后当成资产事实。证据：[Health Flyer.prefab:973](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Items/Health Flyer.prefab:973>)、[同文件:1208](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Items/Health Flyer.prefab:1208>)。

验收：出生后 0.25 秒内攻击无效；保护后一次合法 Hit 即击破，不受多段重复奖励；落地动画结束才无重力飞行；使用不同 AttackType 测奖励分支；在 1.2 秒奖励等待期间切场，确保不会丢或重复给蓝血。该对象没有攻击主角招式，不应填造近战/远程/HP 参数。

### S7. Void Tendrils：图鉴授予点与环境触须要分开

图鉴记录 GUID `6c25ddb396f8b2d40b8e1b65d737da10` 在 [Abyss_08.unity:648893](/Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Abyss_08.unity:648893) 的 `Inspect Region - Void Tendrils` 上。该对象是 BasicNPC，talkText=Inspect/WEAVE_DARK，giveOnFirstTalkItems 列表包含此图鉴记录，搭配 PersistentIntItem。BasicNPC 在首次对话结束时对这些 SavedItem 调 Get，再更新 talkState。这里没有一次打败触须的 HealthManager 死亡。证据：[BasicNPC.cs:108](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/BasicNPC.cs:108)。

另一个明确相关的运行时类 `AbyssWaterTendrils` 控制环境显隐：Start 缓存世界位置与半径平方，每个 Update 共享一次主角位置/HasWhiteFlower；`ShouldAppear = distance² <= appearRadius² && (!HasWhiteFlower || distance² >= flowerDisappearRadius²)`。状态传给 Animator 的 ShouldAppear bool；从未出现到出现且当前 CullCompletely 时改 AlwaysAnimate，并随机翻转 x。证据：[AbyssWaterTendrils.cs:41](/Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/AbyssWaterTendrils.cs:41)。

**边界**：该脚本只证明距离/白花驱动动画出现，不直接实现 HP、DamageHero 或图鉴奖励。实际环境伤害必须继续追到该实例的 Animator、子 Collider 和 AbyssWater；不能从相似名字把 Inspect Region 与所有水中触须强行合为一个可击杀实体。

验收：首次调查授予图鉴，重复调查不重复走首次奖励；无白花时在 appearRadius 内出现；带白花进入 flowerDisappearRadius 内不出现；注意 `<` 与 `<=` 的边界差异；移动该物体时 worldPos 是 Start 缓存值，若设计允许动态搬动需保持这一事实或明确记录修复。

## B. 给人学习的补充说明

### 用“责任链”取代“一个怪物就是一个血条”

这六类对象展示了三种很不同的战斗设计。

**Wisp 是带主控许可的攻击物。**它有等待、盘旋、前摇和追踪，但没有必要维护普通 HP。针击可能只是反馈，特定攻击触发爆炸；它向场景主控申请攻击，避免所有火焰同时无节制扑来。学习重点是单个行为与群体节奏如何分工。实现时先做 Request/Approved/Denied，再做 Fire 的转向公式，最后接生成器。

**Effigy 是场景构件组成的 Boss。**四个灯臂 HP 决定召唤阶段，核心用另一台 FSM 的 HP 和命中次数判断终局，结算要关闭火浪、四个 Pod、召唤物并发放记录。你可以把它画成“导演 + 四个灯臂 + 核心受击器 + 火焰子弹”的对象图，再给每条连线标事件名。这样才不会错误地用一个 HealthManager 试图替代整场战斗。

**Maggots、Sand Centipede、Void Tendrils 让场地参与战斗。**Maggots 的威胁是持续消耗丝与附着，离开与清洗是两个步骤；沙蜈蚣根据区域里的位置成组冒出，爆炸清除的是局部活动威胁并记图鉴；虚空触须的图鉴取得甚至来自调查交互。学习它们时，先写“主角状态如何改变”和“区域如何恢复”，再考虑画面里有多少个生物。

**Lifeblood Fly 是可攻击的资源。**它没有攻击主角的招式，却需要出生保护、落地转飞行、一次性击破、延迟奖励和切场兜底。它说明 IHitResponder 的意义是“响应命中”，并不等于“敌人扣血”。

最容易复现错的五处是：把图鉴引用点当成怪物身体；把动态添加的 ReceivedDamageProxy 漏掉；把一帧事件和动画结束混为一谈；把区域记数当成逐只击杀；把 DamageHero 资产的 1 点伤害直接当成最终值，而漏掉 Flame 等标记。阅读完整案例时，先在纸上写出 **感知者、受击者、伤人者、记图鉴者、销毁者** 分别是哪一个对象，再连接它们的事件。五个角色可以是同一对象，也可以完全不同。
