# Shader 可读性重构

2026-09-11，以 `fd1bc3a6c4368a8da50f525bf2f6b68679382d41` 为行为基线，整理 88 个 shader。原文件路径、shader 名称、材质参数、shader `.meta`、Pass/GrabPass、渲染状态和关键词声明保持不变。验证工具放在 `tools/shader_readability/`，不进入游戏运行程序集。

## 维护入口

| 范围 | 重构前 | 重构后 | 组织方式 |
| --- | ---: | ---: | --- |
| `Assets/Shaders/Sprites-Lit.shader` | 20,439 行 | 1,735 行 | 共享声明和接口，4 个顶点分支、48 个不同片元分支，保留全部 72 个片元来源 SHA |
| `Assets/Shaders/Cherry-Sprites-Default.shader` | 339 行 | 109 行 | 一个顶点/片元主体，像素对齐与噪声只在差异处条件编译 |
| `Assets/Shaders/Noise.shader`、`Assets/Shader/Unlit_Noise New.shader` | 合计 258 行 | 合计 194 行 | 语义变量名，保留时间取整、噪声哈希及颜色计算顺序；两份内容仍相同 |
| `Assets/GUIBlendModes/Shaders/` 下 84 个 shader | 合计 12,339 行 | 含共享代码 6,905 行 | 一个公共顶点 include、42 个具名片元 include；普通和 Optimized 保留各自 GrabPass/绑定 |
| 合计 | 33,375 行 | 8,943 行 | 含全部 43 个共享 include，减少约 73% |

Cherry、Noise 和 UI 的普通位置变换使用 `UnityObjectToClipPos`。Cherry 像素对齐使用 `UnityPixelSnap`，PSSL 单独保留恢复版的 `round`，避免 Unity 在该平台使用的旧式 `floor` 改变半像素边界。

UI 修改混合公式时，先打开对应 `.shader`，沿具名 include 到 `Includes/UIBlend*.cginc` 或 `Includes/UIFontBlend*.cginc`。顶点数据及资源声明统一位于 `Includes/UIBlendCommon.cginc`。背景纹理使用编译期别名，资源声明仍按原顺序排列，没有运行时的混合模式分支。

Lit 这一轮只改组织结构和接口命名。仍保留局部寄存器式数值代码，是为了让每个关键词组合的运算和编译结果可以严格对照。特别保留 64 个额外组合的旧选择规则：例如仅同时启用 `AMBIENT_LERP` 和 `COLOR_FLASH` 时沿用 ambient 程序；不能把所有效果改成独立叠加。

抖动噪声仍加到 RGBA 四通道；Noise shader 自身仍仅调制 RGB 并保留 alpha。预乘 alpha 顺序、`float` 精度、阈值、采样顺序、`mad` 和实例化布局均按原逻辑保留。其余复杂的 Water、TMP、风摆等 shader 未纳入第一批；后续完成的遮罩、部分 TMP、水面和滚动 shader 见 [第二批说明](READABILITY_SECOND.md)。

## 验证证据

环境：Unity 6000.5.4f1 / Apple M4 Pro / Metal / Gamma。新旧 shader 在独立临时项目中通过不同的 AssetDatabase 路径加载；旧版从上述 Git 提交取得，仅改 shader 内部名称以避免别名，不引用新增的公共实现。

- 全部 348 个声明的关键词组合，包括 Lit 的 64 个额外映射，各测试两套材质、纹理和变换输入：696 个 GPU 对照通过，最大像素差异 0。
- 67 个 UI shader 的真实 Camera.Render / GrabPass 对照：138 个测试通过，最大像素差异 0；包含独立抓屏观察区域，检查输出非空。
- 696 个顶点/片元编译对照全部成功；604 个 Metal 编译数据逐字节相同，包括全部 348 个片元程序和 Lit 的 256 个顶点程序。
- 其余 92 个顶点程序采用 Unity 位置 helper，浮点累加次序可能不同。所有 696 个程序的纹理采样、算术操作符、数学 intrinsic、分支和循环的 Metal 源码统计相同，资源绑定及常量布局反射一致。
- Lit 的 256 个组合预处理后，除明确的接口重命名和注释空白外，HLSL token 一致。UI 的 86 个片元分支由独立解析器验证 RGBA 表达式树、纹理/采样器/UV、采样顺序和 discard 谓词一致。

上述源码统计不是硬件指令数或 GPU 耗时测量；画面证据覆盖记录的两套输入和 Metal/Gamma 环境，不扩大到全部游戏场景、Canvas 组件集成或其他图形后端。详细范围与最终源码哈希记录在 [readability-validation.json](readability-validation.json)。完整临时结果位于 `/private/tmp/shader-readability-validation/`，可按下述步骤重建。

## 重跑检查

在项目根目录执行只读静态检查：

```sh
python3 tools/shader_readability/check_lit.py --output /private/tmp/shader-readability-validation/lit-static.json
python3 tools/shader_readability/check_ui.py --output /private/tmp/shader-readability-validation/ui-static.json
python3 tools/shader_readability/refactor_ui.py --check
```

`refactor_ui.py` 默认不带 `--check` 时会从固定恢复提交重新生成 UI 源码。今后手动修改 UI 公式后，不要直接运行写入模式覆盖修改；同步调整转换流程及对应验证基线，或者将再生成器仅留作历史重构记录。

GPU 工具依赖同级 `SilksongSource/` 中原有测试夹具。准备脚本只写独立临时项目，不改游戏工程和离线恢复资料：

```sh
python3 tools/shader_readability/prepare_validation.py
```

该脚本还会检查原有 ShaderLab 外壳、关键词声明和 shader `.meta`。每次准备都同步当前 shader/include，并写入 `candidate-manifest.json`。以下三个 Unity 进程必须依次运行；需要图形设备，不能加 `-nographics`：

```sh
/Applications/Unity/Hub/Editor/6000.5.4f1/Unity.app/Contents/MacOS/Unity -batchmode -projectPath /private/tmp/shader-readability-validation/batch-validation -force-metal -executeMethod ShaderCompileComparison.Run -logFile /private/tmp/shader-readability-validation/compiled-final.log

READABILITY_NATIVE_REFERENCE=0 RECOVERY_GPU_RESULT=gpu-verified /Applications/Unity/Hub/Editor/6000.5.4f1/Unity.app/Contents/MacOS/Unity -batchmode -projectPath /private/tmp/shader-readability-validation/batch-validation -force-metal -executeMethod BatchGpuValidation.Run -logFile /private/tmp/shader-readability-validation/gpu-verified.log

READABILITY_GRAB_RESULT=grab-verified /Applications/Unity/Hub/Editor/6000.5.4f1/Unity.app/Contents/MacOS/Unity -batchmode -projectPath /private/tmp/shader-readability-validation/batch-validation -force-metal -executeMethod GrabCameraValidation.Run -logFile /private/tmp/shader-readability-validation/grab-verified.log
```

确认三个进程成功退出后，生成汇总。汇总脚本会核对完整 case 集合、最终源码/include 哈希、两份 GPU 报告绑定的 manifest，以及静态与编译证据，拒绝把旧报告当作新结果：

```sh
python3 tools/shader_readability/summarize_validation.py
```

临时目录中的相同名称报告在重跑时会被替换。需要保留上一轮完整结果时，使用 `prepare_validation.py --work <新临时目录>`，并相应修改后续路径和 `summarize_validation.py --work`。
