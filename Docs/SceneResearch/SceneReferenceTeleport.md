# 场景传送窗口

代码位于 `Assets/Editor/GameResearch/SceneReferenceTeleportWindow.cs`，只在 Unity 编辑器使用。
`GameManager.instance.BeginSceneTransition(...)` 放在窗口的按钮处理函数中，不需要粘贴到 Console、修改 GameManager 或给场景物体挂脚本。

## 使用

1. 等 Unity 完成编译，打开顶部菜单 **Tools → Scene Research → 场景传送**。
2. 点击 Unity 的 Play，从游戏菜单进入一个存档。工程默认从 `Pre_Menu_Loader` 启动。
3. 目标场景默认 `Bone_02`，进入位置默认 `left1`。首次保持“入场后定位到坐标”关闭，点击 **传送到目标**。如果游戏停在有“继续”按钮的暂停首页，按钮会显示 **继续游戏并传送**；点击后会通过游戏原有的继续流程恢复时间、输入和菜单，等待恢复完成再传送。
4. 需要指定位置时，勾选“入场后定位到坐标”，填写 Unity 世界坐标 X/Y，再点击传送。相同场景会直接移动角色；不同场景会先完成正常入场，再移动角色和同步相机。
5. 到达一个想反复参考的位置后，点击 **读取当前位置到目标**，窗口会记录当前场景和 X/Y。暂停游戏时也能读取。保持窗口打开，即可用“传送到目标”回到该位置。

按钮禁用时，下方会分别提示原因：Unity 编辑器顶部的 Pause（Ⅱ）需要手动取消；游戏背包需要先关闭；选项或退出确认需要先返回暂停首页；场景入场、死亡重生、菜单动画和过场需要等待结束。游戏暂停首页可以直接继续并传送。

也可以点击 **Tools → Scene Research → 执行场景传送（使用窗口设置）**，它和窗口按钮使用同一套目标设置与检查。

坐标不是屏幕像素，应该选在可站立或可通行的位置。此功能记录场景和坐标，不还原敌人、剧情或存档进度。传送过程中保持窗口打开；退出 Play Mode 或关闭窗口会停止后续坐标定位，但已开始的游戏场景切换仍由 GameManager 完成。

`Bone_02` 入口来自 `Assets/Resources/SceneTeleportMap.asset`：`left1`、`right1`、`top1`、`top2`。
场景通过 `Scenes/Bone_02` Addressables 地址加载，不要求将它加入 Build Settings。

## Mac 功能键

这个 Unity 窗口使用鼠标按钮，无需 F2/F5。实际游戏中的 F2/F5 是安装 DebugMod / QuickWarp 后的快捷键，并非原版游戏或这个 Unity 工程自带。
Mac 默认将顶行按键用于亮度、听写等系统功能；使用标准功能键时按住 **Fn（🌐）+ F2/F5**。
也可以在“系统设置 → 键盘 → 键盘快捷键 → 功能键”中启用“将 F1、F2 等键用作标准功能键”。

Apple 说明：https://support.apple.com/zh-cn/102439
