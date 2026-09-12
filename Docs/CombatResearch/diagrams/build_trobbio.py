"""Generate the editable Trobbio board from the reviewed research notes."""
from board_style import Board, C

b = Board('03-trobbio', 1600, 1400)
b.header('03', 'Trobbio｜三个控制器的协作',
         '主控继续选招，炸弹独立飞行；舞台通过事件回报最后爆点',
         'Library_13\n700 HP · 主 FSM 144 状态')

# A — Three separate selectors plus the strict phase boundary.
b.panel(56, 260, 1488, 245, 'A', '选招有记忆，阶段检查有顺序')
b.card(80, 326, 294, 155, '首次：仅 3 招',
       '旋风 / 投弹 / 跳跃\n权重 1 / 1 / 1\n先于阶段检查', 'teal', 24, 21)
b.card(388, 326, 340, 155, 'P1：五项候选',
       '旋风 / 投弹 / 闪光\n跳跃 / 退场\n前四项权重 1；退场 0.75', 'teal', 24, 21)
b.card(742, 326, 340, 155, 'P2：退场项换成爆柱',
       '旋风 / 投弹 / 闪光\n跳跃 / 爆柱\n五项权重均为 1', 'teal', 24, 21)
b.card(1096, 326, 424, 155, 'HP < 350 且尚未 P2',
       '下次 Choice → 吼叫 1.5 秒\n→ 退场／爆柱支路\n350 不切换；当前招式不中断', 'amber', 24, 21)

# B — Three object lanes; eight macro nodes, with cross-object event paths.
b.panel(56, 530, 980, 755, 'B', '一次投弹与一次爆柱：跨对象如何接力')
b.text(80, 594, '每个选择器独立记忆；投弹、空中再选招可再次使用同类招式。', 21, C['muted'])

for x, w, title, tone in [(80, 264, 'Boss 主控', 'teal'),
                          (398, 264, '炸弹 ×3', 'purple'),
                          (716, 292, '舞台控制', 'purple')]:
    b.rect(x, 637, w, 34, C[tone+'bg'], r=8)
    b.text(x+w/2, 639, title, 22, C[tone], 600, 'center')

b.card(80, 688, 264, 130, '投弹 Throw',
       '帧 6：约 0.5 秒生成\n动画结束，主控继续', 'amber', 24, 21)
b.card(398, 688, 264, 130, '3 颗独立炸弹',
       'vx：+15 / −15 / ±3\n角度：0° / 90° / 180°', 'purple', 24, 21)
b.text(748, 718, '异步控制器', 22, C['purple'], 600)
b.text(748, 753, '收到请求才启动\n有自己的状态与计时', 21, C['muted'], lineheight=31)

b.card(80, 890, 264, 120, 'BC Attack',
       '发送 ATTACK\n等待 FINAL BURST', 'teal', 24, 21)
b.card(398, 890, 264, 120, 'Air：飞行 / 反弹',
       'Timer 初值 1–1.7 秒\n普通引爆：见右图', 'purple', 23, 21)
b.card(716, 890, 292, 120, 'Trapdoor Bursts',
       '选择出口列与爆柱模式\n触发各列', 'purple', 24, 21)

b.card(80, 1120, 264, 120, '确定最后爆点',
       '接收 Final Burst 对象\n→ 重新入场', 'green', 23, 21)
b.card(398, 1120, 264, 120, 'Antic → Explode',
       '前摇 0.75 秒，可提前\n开 Blast；2 秒后回池', 'red', 24, 21)
b.card(716, 1090, 292, 120, '等待 1.25 秒',
       '写回 Final Burst 对象\n发送 FINAL BURST', 'purple', 24, 21)
b.text(738, 1224, '舞台再等 2 秒 → Idle', 21, C['muted'])

# Dashed messages can cross solid lifecycle paths without joining them.
b.arrow([(344, 758), (398, 758)], C['purple'], True)
b.text(371, 725, '生成', 18, C['purple'], 600, 'center')
b.arrow([(530, 818), (530, 890)], C['purple'])
b.text(410, 838, '各自运行', 18, C['purple'])
b.arrow([(530, 1010), (530, 1120)], C['purple'])
b.text(542, 1072, '条件满足', 18, C['purple'])
b.arrow([(862, 1010), (862, 1090)], C['purple'])

# The folded continuation is explicitly optional, not Throw -> BC unconditionally.
b.arrow([(102, 818), (102, 890)], C['muted'])
b.text(118, 835, '后续可选爆柱支路', 18, C['muted'])

b.arrow([(344, 948), (371, 948), (371, 866), (862, 866), (862, 890)], C['purple'], True)
b.text(709, 832, 'ATTACK', 22, C['purple'], 600)
b.arrow([(716, 1150), (690, 1150), (690, 1057), (212, 1057), (212, 1120)], C['purple'], True)
b.text(275, 1023, 'FINAL BURST', 21, C['purple'], 600)

# Bridge the message crossings so they do not look like branching junctions.
b.rect(525, 857, 10, 18, C['paper'], r=0)
b.path('M 530,850 L 530,881', C['purple'], 3)
b.rect(525, 1048, 10, 18, C['paper'], r=0)
b.path('M 530,1040 L 530,1073', C['purple'], 3)
b.text(80, 1257, '收招 / 选招已折叠；2 秒为回收等待，非伤害窗；虚线交叉不连接。', 18, C['muted'])

# C — A timeline/position AND gate for the tornado.
b.panel(1060, 530, 484, 355, 'C', '旋风：时间 AND 位置')
b.text(1084, 594, 'Timer 从 1.6 秒递减', 22, C['muted'])
b.rect(1084, 636, 436, 58, C['tealbg'], r=12)
b.text(1302, 651, 'Timer < 0  AND  x ∈ [66,82]', 22, C['teal'], 600, 'center')
b.text(1084, 707, '都满足才收招，否则继续旋风', 22, C['ink'])
b.rect(1098, 756, 408, 48, C['bg'], C['line'], r=5)
b.rect(1190, 756, 224, 48, C['greenbg'], C['green'], r=0)
b.text(1302, 765, '可收招区域', 22, C['green'], 600, 'center')
b.path('M 1190,806 L 1190,817 M 1414,806 L 1414,817', C['muted'], 2)
b.text(1190, 817, '66', 21, C['muted'], align='center')
b.text(1414, 817, '82', 21, C['muted'], align='center')
b.text(1084, 854, '世界 x 坐标 · 示意非比例', 18, C['muted'])

# D — Ordinary bomb detonation is gated by time plus a world-space rectangle.
b.panel(1060, 910, 484, 375, 'D', '炸弹：普通引爆门槛')
b.text(1084, 974, 'Timer < 0  AND  位于矩形内', 22, C['muted'])
b.rect(1098, 1025, 408, 180, C['bg'], C['line'], r=5)
b.rect(1190, 1049, 252, 119, C['amberbg'], C['amber'], r=0)
b.text(1316, 1092, '普通引爆区域', 22, C['amber'], 600, 'center')
b.path('M 1179,1049 L 1190,1049 M 1179,1168 L 1190,1168 M 1190,1168 L 1190,1179 M 1442,1168 L 1442,1179', C['muted'], 2)
b.text(1167, 1034, '22.5', 21, C['muted'], align='right')
b.text(1167, 1153, '15.5', 21, C['muted'], align='right')
b.text(1190, 1179, '62', 21, C['muted'], align='center')
b.text(1442, 1179, '86', 21, C['muted'], align='center')
b.text(1113, 1087, 'y', 21, C['muted'])
b.text(1475, 1179, 'x', 21, C['muted'])
b.text(1084, 1218, '区外继续飞行；区内进入 0.75 秒前摇', 21, C['ink'])
b.text(1084, 1255, '世界坐标 · 示意非比例 · 特殊命中可提前引爆', 18, C['muted'])

b.footer('来源：Library_13 / Trobbio、Trobbio Bomb · bosses-ai.md TR / bosses-human.md Trobbio',
         'STUN / ZERO HP 中断攻击并清理伤害框与事件器 · 图中时间为游戏时间 · 动画帧从 0 起')
b.save()
