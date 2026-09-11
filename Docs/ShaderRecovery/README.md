# Shader 恢复维护说明

2026-09-09，根据 GOG macOS 1.0.30000 发布包保留的 Metal 程序重建了项目的 167 个 Shader，保留原文件路径和 `.meta` GUID。1,181 个 Material 的参数、关键词和引用已核对，无需修改。

恢复代码已包含在 Git 提交 `c8d3683ff`（恢复shader）中，修改前版本可从其父提交读取。使用 Git 查看差异和回退，不另存项目内文件备份。

## 已完成的验证

验证环境为 Unity 6000.5.4f1 / Apple M4 Pro / Metal / Gamma。原程序对照的 2,278 个测试、16 个默认关键词补测、186 组真实 GrabPass 对照均通过；主项目的 167 个 Shader、1,181 个材质和 216 个材质状态编译检查通过。

这些结果不代表 Windows 等其他图形后端、完整游戏场景或 Canvas / RectMask2D 组件集成均已验证。

## 后续修改需注意

- 这是从发布程序重建的 HLSL/ShaderLab，原作者的注释、宏组织和已裁剪的变体无法原样恢复。
- 11 个 Pass 额外生成的 258 个关键词组合使用最接近的原包保留程序；原包实际保留的 1,139 组均已对应并验证。现有材质默认关键词检查无待处理项。
- 保留强制关键词组的原程序顺序：ChainWind 和 TMP Surface 的 ForwardAdd 默认 `POINT`，两种 TMP Surface 的 ShadowCaster 默认 `SHADOWS_DEPTH`。按字母重新排序可能改变空关键词请求的行为。
- FastBlur / MobileBloom 固定采样循环的权重数组和 `[unroll]` 应保留，后者用于绕过该 Unity 版本的编译器问题。
- `Sprites-Screen` 与 `Sprites-VividLight` 原包内部名称相同，但实现不同，不能按名称合并。
- `tmpro_sdf 3.shader` 中未解析的 `TMProOld/Mobile/Distance Field` Fallback 原包已有；当前主 SubShader 已验证，勿将其误认作新丢失的数据。

## 离线分析资料

原始提取数据、转换工具和详细报告仍保留在工作区中与本项目同级的 `SilksongSource/`，不重复放入此 Git 项目：

- `recovered/macos-programs/`：原始程序及序列化数据。
- `recovered/batch-unity-shaders/batch-generation-manifest.json`：Shader 文件注释所指的逐 Pass 来源及变体映射清单。
- `tools/shader_reconstruction/`、`tools/material_audit/`：转换和检查工具。
- `analysis/`、`batch-validation/`、`grab-validation/`：详细检查与验证资料。

这些离线资料不参与项目运行或正常打包。

## 2026-09-11 可读性重构

已整理 Cherry、Sprites/Lit、两份 Noise 和 GUIBlendModes 的 84 个 Shader，共 88 个。维护入口、验证方法和边界见 [可读性重构说明](READABILITY.md)，最终文件哈希与验证汇总见 [readability-validation.json](readability-validation.json)。

这些文件现在是维护源码；不要直接用旧的离线 `apply_all_shaders.py` 覆盖，否则会丢失重构。UI 的共享实现位于 `Assets/GUIBlendModes/Shaders/Includes/`，正常导入和打包需要连同这些 include 及其 `.meta` 一起保留。
