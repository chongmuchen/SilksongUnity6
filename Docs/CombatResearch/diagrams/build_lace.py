"""Build the editable Lace Boss1 board from locally verified research."""
from board_style import Board, C

b = Board('02-lace')
b.header('02', 'Lace 第一战｜读招、距离与反击',
         '先选招，再调整距离；动画事件决定每一刀何时生效。',
         'LACE BOSS1\nHP 250 · Bone_East_12')

# A. Selection graph; only the documented primary branches are expanded.
b.panel(56, 260, 910, 510, 'A', '选招：半血先查特殊技，再看距离',
        '保留短路顺序；墙边、退场与演奏分支折叠。')

def box(x, y, w, h, title, sub='', tone='teal', title_size=23, sub_size=20):
    b.rect(x, y, w, h, C[tone+'bg'], r=14)
    top = y+15 if sub else y+(h-title_size*1.3)/2
    b.text(x+w/2, top, title, title_size, C[tone], 600, 'center')
    if sub:
        b.text(x+w/2, y+49, sub, sub_size, C['muted'], 400, 'center')

box(83, 369, 148, 84, '待机观察', '0.75 s / 受伤', sub_size=18)
b.diamond(350, 411, 184, 92, 'HP ≤ 125？', '半血门槛')
b.diamond(589, 411, 190, 92, '计数 ≤ 0？', '仅低血量检查')
box(754, 369, 186, 84, '准备十字斩', '先调位置', 'purple')
b.arrow([(231,411),(258,411)])
b.arrow([(442,411),(494,411)])
b.text(467,379,'是',19,C['teal'],500,'center')
b.arrow([(684,411),(754,411)],C['purple'])
b.text(718,379,'是',19,C['purple'],500,'center')

b.diamond(230, 588, 188, 96, '距离 ≤ 6？', '欧氏距离')
b.arrow([(350,457),(350,503),(230,503),(230,540)])
b.text(88,476,'否：计数不变',19,C['muted'])
b.path('M 220,489 L 341,489',C['line'],1.5)
b.arrow([(589,457),(589,503),(350,503)])
b.text(445,474,'否：计数 −1',19,C['muted'])

box(370, 548, 235, 90, '近距候选', '后撤 / 连斩 / 冲刺', sub_size=20)
box(665, 548, 275, 90, '远距选招 → 前跳', '先保存招式，再调整距离', title_size=22, sub_size=20)
b.arrow([(324,588),(370,588)])
b.text(347,549,'≤6',18,C['teal'],500,'center')
b.arrow([(230,636),(230,658),(802,658),(802,638)])
b.text(256,632,'>6',19,C['teal'],500)
# Both candidate paths eventually execute a selected move; this is a collapsed route.
box(369, 690, 571, 49, '执行招式 → 收招 / 后续路由', tone='green', title_size=22)
b.arrow([(488,638),(488,690)],C['green'])
b.arrow([(940,593),(950,593),(950,714),(940,714)],C['green'])
b.text(88,686,'先选，再接近',21,C['ink'],600)
b.text(88,719,'前跳不重新抽招',19,C['muted'])
# CrossSlash is a separate, higher-priority route. The label avoids implying a direct attack.
b.arrow([(847,453),(847,480)],C['purple'])
b.text(847,482,'计数重设 2–4',19,C['purple'],500,'center')

# B. Counter trigger and its two distinct exits.
b.panel(990, 260, 554, 510, 'B', '反击：等玩家触发',
        '进入姿态 ≠ 已经释放反击连段。')
b.rect(1016, 354, 502, 108, C['amberbg'], r=15)
b.text(1267,365,'距离 < 6 ＋ 已有反击标记',23,C['amber'],600,'center')
b.text(1267,399,'Counter Pause > 0.25',23,C['ink'],500,'center')
b.text(1267,433,'缓动值门槛，不是 0.25 秒计时器',18,C['muted'],400,'center')
b.arrow([(1267,462),(1267,486)],C['amber'])
box(1084,486,366,61,'反击姿态 · 0.75 s',tone='amber',title_size=24)
b.arrow([(1267,547),(1267,563)],C['amber'])
b.diamond(1267,602,230,78,'BLOCKED HIT？')
b.arrow([(1152,602),(1125,602),(1125,680)],C['red'])
b.arrow([(1382,602),(1410,602),(1410,680)],C['green'])
b.text(1125,632,'收到格挡事件',19,C['red'],500,'center')
b.text(1410,632,'0.75 s 到期',19,C['green'],500,'center')
box(1016,680,228,54,'触发反击连段',tone='red',title_size=22)
box(1275,680,243,54,'姿态自然收招',tone='green',title_size=22)
b.text(1267,740,'方向性无敌；姿态退出自动恢复',19,C['muted'],400,'center')

# C. Proportional known intervals; recovery is intentionally not given a fixed timer.
b.panel(56,795,1488,230,'C','冲刺：0.2 + 0.6 + 0.3 秒',
        '先后撤、再停顿；0.8 秒时才打开 Charge Hit。')
xs = [84,294,924,1239]
for xx, label in zip(xs,['0.0 s','0.2 s','0.8 s','1.1 s']):
    b.text(xx,889,label,19,C['muted'],400,'center' if xx>84 else 'left')
for x,w,tone,label in [(84,210,'amber','后撤 · 0.2 s'),(294,630,'amber','停顿 · 0.6 s'),(924,315,'red','攻击 · 0.3 s')]:
    b.rect(x,919,w,47,C[tone+'bg'],r=0)
    b.rect(x,962,w,5,C[tone],r=0)
    b.text(x+w/2,928,label,23,C[tone],600,'center')
b.rect(1258,919,260,47,C['greenbg'],r=8)
b.text(1388,928,'动画收招',23,C['green'],600,'center')
b.arrow([(1242,943),(1256,943)],C['green'],sw=2)
b.text(189,968,'初速 −32 · 逐步减速',18,C['ink'],400,'center')
b.text(609,968,'水平速度 = 0',21,C['ink'],400,'center')
b.text(1081,968,'初速 +80 · 逐步减速',20,C['ink'],400,'center')
b.text(1388,968,'等动画结束 · 退出刹车',19,C['ink'],400,'center')
b.text(84,998,'速度方向相对朝向；阻尼按物理步生效。',18,C['muted'])
b.text(1518,998,'有效框仅在红色攻击段打开',18,C['red'],500,'right')

# D. Animation event timing. Thin active bands have the actual .041-s timer width.
b.panel(56,1050,1488,240,'D','连斩：四个动画事件，两个短刀窗',
        'Combo Slash · 28 帧 / 24 fps · 帧索引从 0 开始')
origin, end = 98, 1470
step = (end-origin)/28
b.rect(origin,1196,end-origin,6,C['line'],r=3)
for frame in [0,7,14,15,20,21,27]:
    xx = origin+frame*step
    b.path(f'M {xx},1189 L {xx},1210',C['muted'],1.5)
for frame in [14,20]:
    b.rect(origin+frame*step,1188,.041*24*step,21,C['red'],r=3)
# Event labels are staggered to keep adjacent frames legible.
for frame,px,desc in [(14,714,'帧 14 · 第一刀开'),(20,1045,'帧 20 · 第二刀开')]:
    xx=origin+frame*step
    b.text(px,1153,desc,22,C['red'],600,'center')
    b.path(f'M {px},1181 L {xx},1181 L {xx},1188',C['red'],2)
for frame,desc in [(15,'帧 15 · 第一刀关'),(21,'帧 21 · 第二刀关')]:
    xx=origin+frame*step
    b.path(f'M {xx},1209 L {xx},1225',C['green'],2)
    b.text(xx,1225,desc,21,C['green'],600,'center')
b.text(340,1160,'起手 / 预告',23,C['amber'],500,'center')
b.text(98,1218,'0',18,C['muted'])
b.text(1470,1225,'动画完成',21,C['green'],500,'right')
b.text(82,1262,'每刀另设 0.041 s 自动关闭；状态退出也会关刀。',18,C['muted'])
b.text(1518,1262,'事件索引 ≠ 显示器帧数',18,C['muted'],400,'right')

b.footer('源：Bone_East_12 / Control · Lace Anim / Combo Slash · 本地战斗研究资料',
         '关键分支折叠图 · HP > 125 不扣十字斩计数 · 远距先选招再前跳 · 非录像实测')
b.texts[-1]['size']=18
b.texts[-1]['lineheight']=25.2
b.save()
