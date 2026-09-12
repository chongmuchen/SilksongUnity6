# Trobbio 板图内容

用途：为可编辑 Figma 战斗逻辑图提供短标签与连线说明。依据已有双文档整理，不新增运行验证结论；下述“大节点”是教学折叠，不冒充原 FSM 的单个状态。

## 板头与组织

**标题：Trobbio｜主控、炸弹、舞台并行运作**

**副标题：Library_13 · 700 HP · 主 FSM 144 状态 · 阶段只在 Choice 检查**

三条横向泳道：① Boss 主控；② 炸弹 ×3（独立 FSM）；③ 舞台控制（Trapdoor Bursts / Flare Glitter）。主控内部用实线；跨泳道的生成、发送事件、写回值用虚线；条件判断用菱形。主控上方放三个选招池小卡。红色窄条单列 STUN / ZERO HP 中断。

板内角注：**秒数为游戏时间；帧号从 0 起；场地坐标来自 Library_13。**

## 选招区：节点与连线

| ID | 图内短标签 | 连线 / 说明 |
|---|---|---|
| C0 | Choice\n按顺序短路 | 小字：演奏 → 首次攻击 → 玩家死亡 → 阶段检查 → 首轮爆柱标志 → 阶段池 |
| C1 | 首次攻击？ | 是 → 首次池；否 → 后续检查。不是开局同时开放 P1 池。 |
| C2 | 尚未 P2\n且 HP < 350？ | 是 → 阶段吼叫；否 → 后续选招。旁注：350 不切换；349 在下次 Choice 切换。 |
| C3 | 阶段吼叫\n等待 1.5 秒 | 设 Phase2 / WillBurstColumn / DoingFirstBurstColumn；恢复眩晕与击退后 → 退场支路。 |
| C4 | 首轮爆柱标志？ | DoingFirstBurstColumn=true → 强制 TORNADO；否则 → 当前阶段池。 |

为了不把顺序画反，C1 的“否”连线旁保留小标签“先处理 HornetDead”；C0 的演奏与玩家死亡只做旁路标记，不展开非战斗演出。

| 池卡 | 图内内容 |
|---|---|
| 首次池 | 旋风 / 投弹 / 跳跃\n权重 1 / 1 / 1\n连续上限全 1 · 遗漏阈值 5 / 5 / 4 |
| P1 池 | 旋风 / 投弹 / 闪光 / 跳跃 / 退场\n权重 1 / 1 / 1 / 1 / 0.75\n连续上限全 1 · 遗漏阈值 5 / 5 / 4 / 3 / 4 |
| P2 池 | 旋风 / 投弹 / 闪光 / 跳跃 / 爆柱\n权重全 1\n连续上限全 1 · 遗漏阈值 5 / 5 / 4 / 4 / 4 |

池卡共用脚注：**每个选择器独立记忆；权重不是固定最终概率。再投弹 / 空中选招另有选择器。**

## Boss 主控泳道

| ID | 图内短标签 | 连线 / 说明 |
|---|---|---|
| M1 | 投弹 Throw\n10 帧 / 12 fps | 动画帧 6 → 虚线生成 B0；动画完成后主控继续 Fall? / 后续决策，不等待炸弹。 |
| M2 | 旋风起手\nTornado Antic 4 帧 / 15 fps | 普通 Antic 后进入；→ M3。 |
| M3 | 旋风运行\nTimer=1.6 · 目标 vx=±22 | 小字：每物理步速度趋近量 0.6；碰墙反向；开旋风框，关普通伤害框。→ M4。 |
| M4 | Timer < 0\nAND x ∈ [66,82]？ | 否 → M3；是 → M5。强调 AND。 |
| M5 | 减速 0.3 秒\n双向地面效果 → 收招 | 关闭旋风框 / 事件器，恢复普通框与重力；后续回主控循环（折叠）。 |
| M6 | 闪光前置检查\nFlare Active？ | 是 → 取消并回 Choice；否 → Flash Attack。 |
| M7 | Flash Attack\n帧 4 上升 · 帧 5 闪光 | 10 帧 / 13 fps；帧 5 → 虚线 FLARE GLITTER 给 S4；动画结束后主控继续。 |
| M8 | 跳跃 / 空中再选招 | vy=30；等待 0.25–0.3 秒后选方向；空中还可转投弹 / 旋风 / 闪光。不要画成唯一落地出口。 |
| M9 | 退场 / 爆柱支路 | 按 WillBurstColumn 等条件选择舞台攻击或重入；P1 的 EXIT 不等于必然爆柱。 |
| M10 | BC Attack\n发送 ATTACK\n等待 FINAL BURST | M9 的爆柱支路 → M10；M10 虚线 ATTACK → S0；S2 虚线 FINAL BURST 返回 M10。 |
| M11 | 接收 Final Burst 对象\n确定最后爆点 → 重新入场 | 只有收到 FINAL BURST 后进入；后续回主控循环（折叠）。 |

选择器输出连接对应技能；阶段吼叫连接 M9。M10 → M11 的箭头必须写 **FINAL BURST**，不要用固定计时替代。

## 炸弹泳道

| ID | 图内短标签 | 连线 / 说明 |
|---|---|---|
| B0 | 同点生成 3 颗\nvx：+15 / −15 / 二选一 ±3\nRotation：0° / 90° / 180° | 从 M1 的“帧 6，约 0.5 秒”虚线进入；Y=min(ThrowPointY,25.91)。三颗分别独立运行 B1–B4。 |
| B1 | Air：飞行 / 反弹\nTimer 初值 1–1.7 秒 | Timer 只在 Air 递减；落地向上弹、碰墙反转 vx。→ B2。 |
| B2 | Timer < 0\nAND x ∈ [62,86]\nAND y ∈ [15.5,22.5]？ | 否 → B1；是 → B3。这是普通进入引爆前摇的条件。 |
| B3 | Antic 0.75 秒\n设运动学 · 应用 Rotation | 计时完成 → B4；受伤 / 命中玩家 / 重击可提前 → B4。 |
| B4 | Explode\n开 Blast · 关根 Collider\n2 秒后回池 | 回池时关 Blast；角注：2 秒是回收等待，不表示全程都有伤害。 |

另从 Air 到 Explode 画红色旁路“重击等提前引爆事件”，与普通 B2 条件区分；不要画成所有事件都必须通过计时和矩形。

## 舞台泳道

| ID | 图内短标签 | 连线 / 说明 |
|---|---|---|
| S0 | Trapdoor Bursts\n接收 ATTACK | 来自 M10；→ S1。 |
| S1 | 选择出口列与爆柱 pattern\n触发各列 | → S2。 |
| S2 | pattern 等待 1.25 秒\n写回 Final Burst 对象\n发送 FINAL BURST | 虚线返回 M10 / M11；舞台自身继续 → S3。 |
| S3 | 舞台等待 2 秒 → Idle | Boss 已可继续重入，不等待舞台回 Idle 才推进。 |
| S4 | Flare Glitter\nActive=true · 等待 0.5 秒 | 来自 M7 的 FLARE GLITTER；→ S5。 |
| S5 | 选择 2 种布局之一\n分段发射 · 间隔 0.15–0.25 秒 | 小字：低位 Y=16–17；高位 Y=20.5–23。→ S6。 |
| S6 | 末尾等待 2 秒\nActive=false → Idle | S4–S6 的 Active 用虚线“读取 Active”连接 M6，表示门控，不是事件跳转。 |

## 易误画点（建议板底保留四条）

1. **350 ≠ 二阶段**：严格 HP<350，并在 Choice 检查；不能画成受伤瞬间强制打断。
2. **计时 AND 位置**：旋风收招与炸弹普通引爆都需要两个门槛；不能画成到秒数就结束。
3. **投弹是异步生成**：Boss 不等三颗炸弹爆炸；舞台握手也不等于 Boss 自己倒计时。
4. **事件与读值分开**：ATTACK / FINAL BURST / FLARE GLITTER 是发送事件；Flare Active 是跨控制器读值。

制作注记：Bounce Speed 原配置 min40/max28，有待按原 API 验证端点行为，本简图不写成“均匀 28–40”。STUN / ZERO HP 可用红色全局中断条注明“退出攻击、关闭伤害框 / 事件器并进入眩晕或死亡”，不要连接成正常招式轮换；Faked Death 属于战后表演。辅助舞台控制器使用 Library_13 场景版本，不能用 Prefab 中单状态的占位控制器替换。

## 来源（板脚可用短链接）

- [AI 规格 · Trobbio](/Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-ai.md:108)：Choice 顺序、选择器表、技能、炸弹与舞台协议。
- [人读解释 · Trobbio](/Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-human.md:64)：三层控制与时间 / 位置门槛。
- [完整状态参考](/Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-state-reference.md)：折叠节点需要展开时的原始状态名与动作。
