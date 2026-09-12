# 丝之歌战斗逻辑研究

两份主文档：

- [AI 复现规格](/Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/丝之歌战斗逻辑_AI复现规格.md)：运行时合同、明确参数、状态边、伪代码、数据结构和验收条件。
- [人类学习版](/Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/丝之歌战斗逻辑_人类学习版.md)：因果解释、六个完整案例、逐步复现练习，并保留独立实现需要的精确参考。

覆盖本工程主图鉴237条记录；扫描1,638个场景/Prefab。六个深入案例为MossBone Fly、Bone Hunter、Pilgrim Moss Spitter、Mossbone Mother、Lace第一战与Trobbio；另详解Wisp、Effigy、Maggots、Sand Centipede、Lifeblood Fly、Void Tendrils的特殊机制。

数据附件属于文档组成部分。把资料交给另一个AI或同学时，请保留整个目录；只复制正文会失去精确动作和碰撞参数。`parts/`是正文组成稿及案例原始证据，不必按文件顺序学习。

| 文件 | 用途 |
|---|---|
| `data/catalog.json` | 237条记录、所有已索引场景实例、未匹配对象、来源哈希 |
| `data/entities/*.json` | 每条记录一个完整规范样本：FSM、动作参数、组件/碰撞与位置 |
| `data/action_index.json` | 主图鉴675种、连同补充对象共682种动作类型的源码候选或DLL依赖 |
| `data/unmapped/*.json` | 初次未匹配集合的41个规范对象完整数据；包括真实敌人变体、Boss部件、机关与尸体，不是额外41种敌人 |
| `parts/mobs-data.json` | 三小怪的动画、碰撞与六台主/辅助FSM |
| `parts/bosses-data.json` | 三Boss的完整动作、动画与舞台上下文 |
| `parts/bosses-state-reference.md` | 人可以阅读的Boss全状态/动作表 |
| `data/validation.json` | 全量数据的静态结构检查 |
| `data/document-validation.json` | 文档链接、源行号和状态图校验 |
| `data/known-gaps.json` | 恢复工程中3处启用MissingAction的准确位置 |
| `tools/` | 可重复运行的只读提取器与文档生成/验证工具 |

本成果是基于当前恢复工程的静态研究，未进行全部敌人实战回放；零解码未知不代表零运行时缺口。具体场景变体、外部绑定、MissingAction和历史变量类型的限制已写入两份正文。未修改游戏资源或代码。

更新命令见两份正文末尾。当前本地文件链接使用用户工程的绝对路径；移动到另一台机器时需更换根路径，JSON中的source字段保留项目相对路径。
