# 典型 Boss 研究交付索引

- [给 AI 的复现规格](</Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-ai.md>)：独立的实现契约、状态选择、时序、空间参数、碰撞、中断与验收。
- [给人的学习文章](</Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-human.md>)：独立讲解苔藓之母、Lace第一战、Trobbio的系统设计及复现步骤。
- [完整状态参考](</Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-state-reference.md>)：共享附表，按FSM/状态展开全部有序动作、参数、启用状态、迁移、变量、动画事件和碰撞数据。
- [无损证据和解码JSON](</Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-data.json>)；[静态检查摘要](</Users/mars/workspace/SilksongUnity6/Docs/CombatResearch/parts/bosses-qa.json>)。

范围：Mossbone Mother在Tut_03；Lace Boss1在Bone_East_12；Trobbio在Library_13，并对比其Prefab。主、子、显式引用及舞台FSM共61份记录、858状态记录、3805动作记录；Trobbio主FSM同时保存Prefab/场景证据，因此记录数不代表去重后的独立状态数量。未知动作参数为0，非空目标状态悬空数为0。验证为静态资源和源码核对，未声明已执行Unity完整对战。
