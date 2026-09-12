## 典型 Boss 的可执行规格

### 范围与读取契约

本章的三个测试目标是 `Tut_03/Mossbone Mother`、`Bone_East_12/Lace Boss1`、`Library_13/Trobbio`。第三项使用Prefab校对主Control，用Library_13补全舞台、眩晕及旋风伤害器；Prefab与场景主Control的唯一已发现动作差别是Exit 1的一条语音资产。Lace Boss2、Lost Lace、双母配置不是本章三项的同义词。

机器完整证据：[bosses-data.json](</Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-data.json>)。人工可检索的完整状态动作展开：[bosses-state-reference.md](</Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-state-reference.md>)。这两份证据提供本章所有正常、失败、场景演出、伤害和退出分支；下面是实现约束及主要技能的审查规格，不能用简化技能表替代完整状态图。

数据结构：每案例的`fsms`是根和后代对象FSM；`external_linked_fsms`是显式本场景引用的外部对象；Trobbio额外`scene_context_fsms`为Library_13舞台全层级；`projectile_fsms`包含Trobbio Bomb；`components`保留同层级GameObject/Transform/物理/MonoBehaviour原文；`animation_library`记录clip帧数/fps/trigger事件索引。FSM内`source`和`line`可追到证据；`states[].actions`有序且显式`enabled`；`raw_action_data`保留无损序列化值。

消费规则：

1. 先按根场景创建Transform树和组件；用fileID解析场景内对象，用GUID解析外部资源。变量`stored`只是资产存储值；`var`非空时要读/写FSM同名运行变量；`var=null`表示未选变量，不是常量零。不要把历史缓存fileID当作已经完成GetOwner/FindChild后的目标。
2. 状态Enter按动作数组顺序执行，跳转后停止旧状态剩余Enter动作。动作可在Enter、Update、FixedUpdate、动画回调、碰撞回调中运行。只有`isSequence=1`时才按序列语义等待上一动作；本章大量`isSequence=0`状态是多个动作并行存活，不是“先等Wait结束再运动”。
3. disabled动作不执行。state transitions按事件字符串匹配，不能根据名字相似自行连线。全局事件、同物体其他FSM事件、向父/子广播、注册表广播要分开实现。
4. 计时器、动画监听、延迟激活和iTween应绑定状态生命周期。`resetOnExit`、`stopOnExit`、`brakeOnExit`是语义，不是注释。退出要按动作OnExit实现恢复，不能全局统一“速度归零”。
5. `SetVelocityByScale.speed`必须经实际X缩放转换；翻转缩放影响朝向和局部射线。`distance`类动作有欧氏与X专用两种。动画索引为0基；只有完整动画首次触发时间才能用index/fps估算，跨状态监听不重播同一动画。
6. `TimeManager`存储步长为2822399/141120000≈0.02秒。DistanceFlyV2、AccelerateToX与DecelerateXY每次物理步累加/相乘且Enter也调用一次；移植为每秒加速度前必须显式转换并验证轨迹。不得把0.825阻尼解释成每秒0.825。来源：[TimeManager](</Users/mars/workspace/SilksongUnity6/ProjectSettings/TimeManager.asset:7>)、[AccelerateToX](</Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/AccelerateToX.cs:33>)、[DecelerateXY](</Users/mars/workspace/SilksongUnity6/Assets/Scripts/MixedIntegrations/PlayMakerActions/DecelerateXY.cs:37>)。

### MM：Mossbone Mother，单体场景配置

**身份和常量。** HP0=120；身体伤害1；加载时invincible=true，入场应解除。主Control68状态，Stun Control17状态。场地常量LeftX46.43、RightX67.92、CentreX57.37、MaxHeight23.8；IdleTime初始2、RecoverTime初始0.75、SwoopXSpeed18。HP阈值初始化计算95%/85%/70%，本场对应114/102/84，85%只用于Double Fight路径。来源：[Tut_03](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:521388>)。

**主循环的确定性规格。**

```text
Idle:
  每帧 Face Hero; 维持DistanceFly(distance12, vmax6/axis, accel0.375/tick,
                               targetHeight=HeroY+6, MaxHeight23.8)
  Timer += dt; Timer>=IdleTime -> Check First Idle
  TOOK DAMAGE -> Dmg Response(wait U[0.25,0.4]) -> Check First Idle
  NEEDOLIN -> Sing Antic; Double Fight -> Idle D
Check First Idle:
  若IdleTime>1.5: IdleTime=1.5; -> Move Choice
Move Choice:
  Timer=0; 演奏检查; Double Fight检查; HP=currentHP
  HP>HP_P2 -> Swoop Antic
  否则 RandomV2(events=[SLAM,SWOOP], weights=[1,1], maxStreak=[1,2])
  SLAM -> Reduce Idle Time 2 -> Slam Antic
  SWOOP -> Swoop Antic
```

RandomV2的初始连续计数为CtSlam0、CtSwoop2；不能全设0。DropType中CtRock初始1、CtCrawler0。原始权重不是最终长期出现频率。精确选择算法见工程SendRandomEventV2，不替换为单次加权抽样。来源：[Move Choice](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Tut_03.unity:522594>)。

|状态序列|Enter/运动/碰撞|退出条件|
|---|---|---|
|Swoop Antic|Antic动画；阻尼0.75；抖动X/Y0.1|0.4s|
|Swoop|向下20射线到地形8，height=hitY+2.2；speed=18×scaleX；vx=-1.3speed；每tick向speed靠近abs(0.1speed)；纵向iTweenMoveBy到height，duration0.5/easeType14；阻断上/下击退|0.9s|
|Swoop Extend|保留速度；读SelfX/HeroX|SelfX≤46.43或≥67.92或abs(HeroX-SelfX)>2|
|Swoop Return|Charge Recover动画；vx*=0.95；恢复上下击退|0.5s|
|Swoop Recover|若Spawned直接Crawler Idle，否则Fly；vy每tick步长0.1趋近6；vx*=0.95|0.65s或TOOK DAMAGE→Idle|
|Slam Antic|IdleTime=2.25；Antic；阻尼0.9|0.4s→Set Antic Dir|
|Set Antic Dir→Slam Antic 2|单体vector=(0,-8)；RoofAntic；阻尼0.9|0.3s|
|Fly Up|vy=25；vx*=0.85|顶部/左右碰撞、vy≈0±0.1、或1s保底→Slam|
|Slam|播放Smash，立即FINISHED|立即Drop Type；不要等待整段Smash|
|Drop Type|HP>84→Rock；否则RandomV2 Rock/Crawler等权，上限1/1|Rock或2nd Crawler|
|Rock→Anim End|向Stals及后代FALL|当前Smash动画完成→Slam Wait|
|Slam Wait→Slam RePos|Fly等待0.5；随后vy=-10|本地SelfY<1→Slam Recover|
|Slam Recover|DistanceFly(10,6,0.375,height7,无maxHeight)|RecoverTime或TOOK DAMAGE→Idle|
|2nd Crawler→Crawler|已首召时先第二生成器SPAWN；然后第一生成器SPAWN；Spawned=true；DoneFirstSpawn=true|Reduce Idle Time|
|Reduce Idle Time→Anim End 2|IdleTime=.5；RecoverTime=.25|当前动画完成→Crawler Idle，召唤标志清零提前收招|
|Crawler Idle|DistanceFly(10,6,.5,height8,max23.8)|1s或Spawned=false→Slam Recover；TOOK DAMAGE→Swoop Antic|

**受击和生命终止。** 主全局STUN→Stun Start；ZERO HP→End；EXTRACT→Get Dir→Extract。Stun Start设置2秒计时和击退2；Stunned每秒-1；Stun Damage额外-0.1；Stun Recover播放Recover、恢复击退5并发STUN CONTROL START。不能从`Stun Combo=8`推断八击必晕，Stun Control的连击比较动作disabled；累计是Stun Damage数值，非无条件+1。旧版FloatCompare内联值含`stored15`且引用`Stun Hit Max`，FSM变量表声明int10；严格工程复现应保留原动作类型与迁移/变量绑定行为，不能偷偷改成字面15或未经运行验证认定十次普通命中。Extract期间取消伤害、移动0.2秒到抽取点，EXTRACT FINISH扣20 HP并重新打开伤害。上述是静态证据；眩晕跨类型历史变量的运行时绑定需日志验证。

**MM验收集。** MM01：HP120/115选招只俯冲；MM02：HP114可撞顶；MM03：HP85撞顶后只落石、HP84可召唤；MM04：俯冲地面只采样一次、0.9秒后延长只按边界/水平关系；MM05：首召1生成器，次召2生成器；MM06：Idle受击经过0.25–0.4秒推进选招；MM07：眩晕受击扣0.1计时且清理旧运动；MM08：场景内死亡/抽取互斥，不残留伤害框。以状态日志、速度、碰撞激活记录比对，不凭动画外观判定通过。

### LC1：Lace Boss1，距离与反击控制

HP0=250；RageHP=125；欧氏近距阈值6；前跳目标水平距离Charge16/JSlash12/Combo9.25；LandY7.598696、落地X范围[81,107]、CentreX93.78、Gravity2。身体及普通刀伤害1，MultiHit DamageHero0。Control132、根Stun17，并有MultiHit7、Cross Slash5、hero damager6、Check Death2、熔岩/镜头等辅助FSM。来源：[Bone_East_12 Control](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Bone_East_12.unity:406652>)。

```text
Idle -> CrossSlash? via ATTACK(0.75s), TOOK DAMAGE, animationComplete
Idle -> Counter Antic if Distance<6 && WillCounter && CounterPause>.25
Idle -> Evade2 if OutOfFightRange; -> SingAntic if performance event
CrossSlash?: HP>125 -> DistanceCheck（不修改CtCrossSlash，立即结束本次检查）
             HP<=125 && CtCrossSlash<=0 -> CrossSlashAim
             HP<=125 && CtCrossSlash>0 -> CtCrossSlash-- -> DistanceCheck
DistanceCheck: EuclideanDistance<=6 -> Close; otherwise Far
Close: WallRange先行J SLASH; RandomV3 [EVADE,COMBO,J SLASH], weight1/1/1,
       max2/2/2, missed4/4/4，初始tracking全0
       实际迁移 J SLASH -> Charge Antic（保留源图，禁止按名称修正）
Far: Hops=0; WallRange先行J SLASH; RandomV3 [COMBO,CHARGE,J SLASH],
     weight1/1/1, max2/1/2, missed4/4/4 -> HopTo对应目标距离
HopCheck: XDistance<=TargetDistance -> HopEnd -> savedNextEvent
          WallRange true -> HopAntic（在Hops检查之前）
          非墙范围 Hops>3 -> HopEnd; 否则HopAntic
HopAntic: Hops++; ForwardHop到trigger -> Hop(vx=24*scaleX)
Hop -> trigger -> HopRecover -> HopCheck
```

近距V3的missedMax资源多存一个末尾5，trackingIntsMissed只有3项；原实现按tracking长度遍历，所以该额外项不构成第四技能。多项同时达到遗漏上限时，代码循环最后满足项覆盖之前项；最大连续次数、遗漏计数、100次重试退路均见[SendRandomEventV3](</Users/mars/workspace/SilksongUnity6/Assets/Scripts/ThirdParty/HutongGames/PlayMaker/Actions/SendRandomEventV3.cs:35>)。

|攻击|必须复现的阶段和参数|
|---|---|
|Charge|Antic前向-32、vx*=.825、.2s且退出刹车；Break vx=0等.6s；Charge前向80、vx*=.89、.3s、ChargeHit开且resetOnExit；Recover动画、vx*=.875、退出刹车→WillCounter?。|
|Combo Slash|28帧/24fps；trigger索引14/15/20/21分别开启刀1/关闭刀1/开启刀2/关闭刀2；每次开启前向速度30；每刀附加.041s关闭；中间及尾段vx*=.8；尾段等动画完成并退出刹车。|
|Rising Slash→Downstab|起手.65s；Rising Slash5帧/18fps，起速前向60/Y87、重力0、阻尼.825；trigger2/3/4切换两CircleSlash。Downstab Antic完整动画后起速前向45/Y-45并开DownstabHit；LAND由地面3射线、底碰撞、vy>-.1、1s保底触发；墙检测走Wallcling。正常LAND恢复Y=LandY和Gravity2，vx*=.8直到收招动画结束。|
|Evade|面朝玩家后相对-30速度，Evade动画trigger后收招；后续随机Combo/Charge/JSlash或待执行CrossSlash，不能总是回Idle。|
|Counter|WillCounter?权重.33空事件/.66 FINISHED，未提前跳走则WillCounter=true；Idle内还须距离<6、CounterPause缓动值>.25。Antic动画后按scale符号设方向9/8；Stance方向性无敌.75s、resetOnExit；BLOCKED HIT→CounterHit动画+FreezeMoment(4)→RapidSlashCharge前向19且身体damage0。|
|RapidSlash|Charge阶段玩家层20碰撞进入CollideToMultihit；Loop持续.65s、重启MultiHit并开PolygonCollider、vx*=.75；MULTI HIT CONNECT进入HeroFacing/Multihitting；End恢复身体damage1。多段玩家牵引和伤害按子FSM，不添加普通身体每帧伤害。|
|CrossSlash|仅HP≤125；Aim要求XDistance≥6且朝向朝场地内侧，不满足走后撤重试；Antic .9s，计数随机整数2–4包含上端，禁眩晕、recoil0；CrossSlash隐藏主渲染/碰撞、kinematic=true，向子对象ATTACK START并等待.8s；后续FinishMultihit/SlashSlam恢复重力/碰撞/Renderer，定位CSExitPoint，恢复recoil15与眩晕控制。|

**中断。** STUN全局清空两CircleSlash、两ComboSlash、ChargeHit、DownstabHit、MultiHit Collider、RapidSlashEffect、CrossSlashEnergy、LeapBurst，发玩家WOUND END。启动后向6/向上23抛起，重力2，眩晕2秒，受伤额外扣.25秒。熔岩走LAVA DAMAGE及专门FSM，不把Boss销毁。Check Death单独读取生命完成死亡，不要人为加一条不存在的Control全局ZERO HP覆盖接管过程。方向无敌代码8/9不能猜含义，复用[HealthManager]对应方向判定或逐向命中验证。

**LC验收集。** LC01距离6为Close，6+ε为Far；LC02Close的J SLASH确实到ChargeAntic；LC03固定动画时间轴两段有效窗，不因FSM切换重新播放整个Combo Slash；LC04Charge累计0.8s起手后才开刀；LC05不击中CounterStance时.75s结束，BLOCKED HIT才触发反击；LC06HP126不十字斩，125可；LC07CrossSlash之后所有被关闭Renderer/Collider恢复；LC08在每个攻击的有效帧前后注入STUN，检测所有子伤害体关闭与玩家WOUND解除；LC09同一种技能的近/远池按源tracking变量共享关系记忆，不能只存一个全局lastAttack。

### TR：Trobbio 与舞台、炸弹协议

HP0=700，Phase2阈值350，严格`HP<350`且`Phase2=false`触发；场景源Library_13，Prefab可复核主Control，但Prefab的单状态Stun/TornadoDamager不足以复现。本章数据中`scene_context_fsms`提供完整舞台层级。主Control144；舞台Trapdoor Bursts17、Flare Glitter27、6个Flare子对象各5、16个地板各4、Stun17、Tornado Damager18。碰撞形状和DamageHero原文保留在components，场景子碰撞的最终值需以Library_13为准。来源：[Library_13舞台](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1563415>)。

**Choice的短路顺序。** Reset ExtraPoses→演奏检查→若DoingFirstAttack则等权[Tornado,Bomb,Jump]→HornetDead→更新BelowP2HP→首次进入二阶段→DoingFirstBurstColumn则Tornado→若Phase2则P2随机→P1随机。每个随机动作实例拥有自己的tracking状态。V4 activeBool空变量表示启用，不能把stored0当false；否则P1选择器会永远不执行。

|选择器|事件|权重|最大连续次数|遗漏上限|
|---|---|---|---|---|
|首次|TORNADO/BOMB THROW/JUMP|1/1/1|1/1/1|5/5/4|
|P1|TORNADO/BOMB THROW/DAZZLE FLASH/JUMP/EXIT|1/1/1/1/.75|1/1/1/1/1|5/5/4/3/4|
|P2|TORNADO/BOMB THROW/DAZZLE FLASH/JUMP/BURST COLUMNS|1/1/1/1/1|1/1/1/1/1|5/5/4/4/4|
|Rethrow?|FINISHED/BOMB THROW|.66/.33|2/1|1/2|
|Jump Attack1|FINISHED/BOMB THROW/TORNADO|.75/.125/.125|2/1/1|1/6/6|
|Jump Attack2 P2|DAZZLE FLASH/BOMB THROW/TORNADO|.1/.1/.1|1/1/1|4/3/3|
|Jump Attack2 fallback|FINISHED/BOMB THROW/TORNADO/DAZZLE FLASH|.75/.125/.125/.2|1/1/1/1|1/5/5/5|

V4每次选中事件后清掉其他连续次数、增加其他遗漏次数、清掉选中事件遗漏；有达到遗漏上限者强制优先，多项冲突由后面的满足项覆盖；连续次数超限时重抽，循环>100次使用events[0]退路。数组在首次Enter初始化，状态再次进入不清零。来源：[SendRandomEventV4](</Users/mars/workspace/SilksongUnity6/Assets/Scripts/Assembly-CSharp/HutongGames/PlayMaker/Actions/SendRandomEventV4.cs:46>)。

**技能事务。**

|技能|生命周期|
|---|---|
|Throw|Throw10帧/12fps，索引6触发；Y=min(ThrowPointY,25.91)；spawn3×TrobbioBomb，设置XVelocity与刚体vx=+15/-15/randomEither(-3,+3)，Rotation=0/90/180；等当前动画complete→Fall?。|
|Tornado|普通Antic→TornadoAntic4帧/15fps→Start开TornadoDamager/EventSender、关DamageCollider、Gravity.5、Time1.6、targetVx=±22、方向13无敌；每tick以.6趋近target，前向1.7射线terrain8碰墙反转速度/朝向；time<0且X∈[66,82]才结束→Slow .3s/vx*=.9→Shoot生成两地面效果，关闭旋风框恢复普通框及无敌→End动画/Gravity1。|
|Flash|FlareGlitter.Control.Active为真时取消→Choice；Antic→FlashAttack10帧/13fps：trigger4上升(重力0,Y40,阻尼.825)，trigger5真正FlashBurst并发送FLARE GLITTER，动画结束→Fall。|
|Jump|Y30、waitU[.25,.3]→FlyDir；后续空中池可能改成投弹/旋风/闪光，不能硬编码成一次跳跃后落地。|
|Exit/Entry|退入舞台后随机EntryX∈[61.5,86.3]，与当前X差<10重试；Retry/RetryFrame避免死循环；根据WillBurstColumn和BombFlurry?选择舞台攻击/重入。|
|Phase transition|Choice检查HP<350；Antic阻断四向击退且STUN CONTROL STOP，PhaseRoar等1.5s并设Phase2/WillBurstColumn/DoingFirstBurstColumn，End恢复击退和眩晕→Exit1。|

**炸弹独立FSM。** Init→Fling→Air；Air的Wall L/Wall R反转X并向场内平移±.25，Floor把Y设BounceSpeed；TINK LEFT/RIGHT把X设-12/+12，TINK DOWN把Y设-20，TINK UP复用Floor。Timer初值U[1,1.7]，只在Air递减；普通引爆必须Timer<0且X在[62,86]、Y在[15.5,22.5]，其他位置保留飞行。Antic持续.75、kinematic、阻尼.84、Root旋转为Rotation，受伤/命中玩家/重击可提前Explode。Explode停速、启用Blast、关闭RootCollider；2s后Recycle关闭Blast并RecycleSelf。对象池再激活必须重置Timer、速度、旋转、碰撞、子Blast与历史事件。序列化BounceSpeed RandomFloat参数min40/max28是倒序端点，禁止擅自声称这是均匀[28,40]而不核对API实现。来源：[Trobbio Bomb](</Users/mars/workspace/SilksongUnity6/Assets/Prefabs/Hornet Bosses/Trobbio Bomb.prefab:473>)。

**舞台协议。** `BC Attack`向Trapdoor Bursts发送ATTACK并等待FINAL BURST；舞台会选择Trobbio出口所在列及爆柱pattern、向各列发送起爆事件，pattern状态等1.25s后将Final Burst对象写回Boss并发FINAL BURST，然后2s回Idle。Flare Glitter收到FLARE GLITTER先Active=true、等.5s、选择两个pattern之一；低位Y范围16–17，高位20.5–23；按pattern顺序发射，各段间隔U[.15,.25]，末尾Active Pause等2s才回Idle并清Active。六个子闪光对象自己的碰撞生命周期不能省略。所有列、位置与射击action参数见完整状态参考，不能仅随机在地面生成火柱代替。来源：[Trapdoor Bursts](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1563432>)、[Flare Glitter](</Users/mars/workspace/SilksongUnity6/Assets/Scenes/Hornet/Library_13.unity:1590752>)。

**中断和结束。** Stun Start保证Y≥16.91、关闭攻击框/旋风事件器、无敌false、DamageHero关、Renderer/Collider开、kinematic=false、Gravity1、后向6/Y20抛起，StunTimer2，每次受伤再-.25；需要用场景17状态Stun Control，不能用Prefab单状态版本。主全局ZERO HP→Death Hit立即记录战败、关闭攻击框并开启无敌，后续死亡演出直到Battle End开门；Faked Death不是新增战斗阶段。完整退出演出可以简化美术，但门开启、奖励、伤害关闭和保存写入的顺序必须保留。

**TR验收集。** TR01：HP350留P1，349在下次Choice切换；TR02：第一次技能不可为Flash/Exit；TR03：同一选择器不连续同招，但Rethrow可合法再投；TR04：三弹速度/Rotation正确，动画.5s才spawn；TR05：炸弹时间/矩形共同决定Antic，重击立即转Explode；TR06：旋风1.6s之后仍在区外不能收，入区后收；TR07：FlareActive禁止重复Flash；TR08：PhaseRoar结束的爆柱握手能收到FINAL BURST并重新入场；TR09：STUN/ZERO HP清掉所有主动伤害器、冻结旧计时器与延迟事件，玩家不被残留连击锁定；TR10：对象池复用20轮之后Timer/Blast不泄漏。

### 复现验证证据要求

输出日志至少包括：gameTime、fixedTick、对象ID、FSM/旧状态/新状态/事件、选招随机输入与计数器、HP与阶段、position/velocity、gravity/kinematic、hurtbox/hitbox active、invincibility direction、动画clip/frame。用相同初始条件与伪随机序列驱动两实现；先比事件序列与激活窗口，再比位置轨迹。公开演示视频只可补充外观和节奏，不能替代本章明确给出的参数或证明未验证的运行时迁移行为。当前交付是静态可审计规格与复现方法，不声称已在Unity实际打完全部Boss并通过对照录像。
