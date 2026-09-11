# Shader 可读性重构：第二批

2026-09-11，继续整理 23 个 shader。行为基线仍为 `fd1bc3a6c4368a8da50f525bf2f6b68679382d41`；这一批文件在第一批重构中未修改。原 shader 路径、内部名称、Properties、`.meta`、渲染状态、Pass/GrabPass 和关键词声明保持不变。

## 维护入口

| 范围 | 重构前 | 重构后 | 组织方式 |
| --- | ---: | ---: | --- |
| 两个 World Coords Alpha Masked、Sprites-TiledMasked、Sprites-TiledScrollingMasked | 28,282 行 | 2,937 行 | 共享声明和语义接口，分别选择顶点与片元实现，合并相同程序 |
| 16 个 TMP Distance Field / Mobile Distance Field | 13,568 行 | 3,020 行 | 保留 16 个 ShaderLab 外壳，两族各共享一个 include；计入两个 include 的全部行数 |
| `Assets/Shaders/ScrollTexture.shader` | 1,295 行 | 790 行 | 共享接口和声明，保留原有 12 个有序分支及实例化布局 |
| `Assets/Shaders/Water.shader` | 259 行 | 210 行 | 给世界坐标、扰动、折射、背景和遮罩计算命名，整理两个 SubShader |
| `Assets/Shader/Sprites_CameraScrollingSpriteTexture.shader` | 125 行 | 103 行 | 给滚动采样和颜色运算命名，共享世界坐标计算 |
| 合计 | 43,529 行 | 7,060 行 | 包括两个新增共享文件，减少约 84% |

两批共整理 111 个 shader。第一批的范围与证据仍保留在 [READABILITY.md](READABILITY.md)。

### 遮罩与滚动

声明和输入输出字段只保留一份，字段使用 `positionOS`、`positionCS` 等语义名称。重复的顶点、片元程序独立选择，避免同一顶点计算随每个片元变体反复出现。复杂局部运算仍保留原始计算顺序，精度、采样器顺序、常量缓冲区和实例化索引不变。

关键词之间仍按恢复版的优先顺序选择，不把互斥分支改为独立叠加。两个 World Coords shader 的强制组默认关键词 `DUMMY` 及空关键词请求单独核对；未在 pragma 中声明的布尔组合也进行了静态对照。

### TMP

桌面族的维护入口为 `Assets/Shader/Includes/TMPDistanceField.cginc`，移动族为 `Assets/Shader/Includes/TMPMobileDistanceField.cginc`。每族包含 `Assets/Shader/` 下 7 个原 shader，以及 `Assets/Resources/shaders/` 下对应的 `tmpro_sdf.shader` 或 `tmpro_sdf-mobile.shader`。材质仍引用原 shader 文件，不需要迁移。

共享实现增加了距离场、描边、软遮罩、光照、发光和底影的阶段注释，以及输入和插值字段的语义名称。投影矩阵采用 Unity 的 `UNITY_MATRIX_P` 宏；检查时展开本机 UnityCG 的真实定义。其余精度、公式、软遮罩及关键词处理保留恢复版，未整体替换成新版 TMP 实现。TMP Surface 和其他 TMP 文件不在这一批内。

### Water 与 CameraScrolling

两个 shader 都需要世界坐标和裁剪坐标，因此共享世界变换的前三列计算，随后用 `mul(UNITY_MATRIX_VP, worldPosition)` 得到裁剪坐标。保留裁剪位置使用对象空间 W=1、世界 UV 使用输入 W 的区别，避免直接调用位置 helper 时重复做世界变换。

Water 的备用 SubShader 使用 `UnityObjectToClipPos`；`STEREO_CUBEMAP_RENDER_ON` 分支保留矩阵计算，避免引入 helper 的 ODS 偏移。主 SubShader 保留固定的 GrabPass Y=-1 约定、float 精度的 RGorAG 解码、原有五次采样及反射/遮罩运算顺序；`ComputeGrabScreenPos` 和 `UnpackNormal` 的平台分支不能直接代替这些恢复行为。CameraScrolling 保留两次采样及原有 alpha 乘法顺序。

## 验证证据

环境：Unity 6000.5.4f1 / Apple M4 Pro / Metal / Gamma。旧版从固定 Git 提交生成独立资产，候选版从当前源码复制；以不同 AssetDatabase 路径加载，旧版不引用新增的共享实现。

- 23 个 shader，加一个仅用于测试的 Water 备用 SubShader 包装资产，共 24 个测试资产、613 组关键词请求。每组使用两套材质、纹理和变换输入：1,226 个 GPU 对照通过，最大像素差异 0。
- Water 真实 Camera.Render / GrabPass 的两个对照通过，最大像素差异 0；使用独立的抓屏观察区域检查抓屏结果。
- 1,226 个顶点/片元编译对照全部成功，其中 1,223 个 Metal 编译数据逐字节相同，包括全部 613 个片元程序。三个不同的顶点程序分别来自 Water 的两个 SubShader 和 CameraScrolling，位置矩阵运算的浮点累加形式发生变化。
- 全部 1,226 个编译程序的纹理采样、算术操作符、数学 intrinsic、分支、循环源码统计相同，资源绑定及常量布局反射一致。
- 四个遮罩 shader 的 912 个布尔赋值在预处理后，除明确的接口重命名、注释和空白外，HLSL token 一致；同时核对 528 个声明组合及两个额外空关键词请求。
- TMP 的 48 个关键词组合展开项目 include 和真实 UnityCG 后，除明确接口重命名外，HLSL token 一致。ScrollTexture 的 64 个布尔赋值一致；Water 的两个片元程序和 CameraScrolling 的片元程序由独立解析器验证表达式树与有序采样一致。

Metal 源码统计不是硬件指令数或 GPU 耗时测量。画面对照覆盖记录的两套输入，不代表全部游戏场景、Canvas 组件集成、立体渲染或其他图形后端均已验证。文件哈希、完整测试数量及证据哈希见 [readability-second-validation.json](readability-second-validation.json)。

## 重跑检查

在项目根目录执行以下静态检查，仅 `--output` 指定的报告会写入：

```sh
python3 -B tools/shader_readability/check_masks.py --output /private/tmp/shader-readability-second/masks-static.json
python3 -B tools/shader_readability/check_tmp.py --output /private/tmp/shader-readability-second/tmp-static.json
python3 -B tools/shader_readability/check_scroll_water.py --output /private/tmp/shader-readability-second/scroll-water-static.json
```

`refactor_masks.py` 和 `refactor_tmp.py` 是这一轮的再生成记录；前者的只读验证使用 `check_masks.py`，后者另支持 `--check` 检查生成结果。以后手改算法时不要直接运行写入模式覆盖源码；先同步转换流程与验证基线，或保留再生成器作为历史工具。

准备独立验证项目，依赖同级 `SilksongSource/` 中原有的测试夹具：

```sh
python3 -B tools/shader_readability/prepare_validation.py --batch second --work /private/tmp/shader-readability-second
```

准备脚本检查 ShaderLab 外壳、关键词声明和原 shader `.meta`，复制两个 TMP include，并为通常不生效的 Water 第二个 SubShader 生成独立测试包装文件。包装文件只放在临时验证工程中。不要将第一批和第二批指向同一个临时目录。

以下三个 Unity 进程必须依次成功运行。需要图形设备，不能加 `-nographics`：

```sh
READABILITY_NATIVE_REFERENCE=0 RECOVERY_GPU_RESULT=gpu-verified /Applications/Unity/Hub/Editor/6000.5.4f1/Unity.app/Contents/MacOS/Unity -batchmode -projectPath /private/tmp/shader-readability-second/batch-validation -force-metal -executeMethod BatchGpuValidation.Run -logFile /private/tmp/shader-readability-second/gpu-verified.log

/Applications/Unity/Hub/Editor/6000.5.4f1/Unity.app/Contents/MacOS/Unity -batchmode -projectPath /private/tmp/shader-readability-second/batch-validation -force-metal -executeMethod ShaderCompileComparison.Run -logFile /private/tmp/shader-readability-second/compiled-final.log

READABILITY_GRAB_RESULT=grab-verified /Applications/Unity/Hub/Editor/6000.5.4f1/Unity.app/Contents/MacOS/Unity -batchmode -projectPath /private/tmp/shader-readability-second/batch-validation -force-metal -executeMethod GrabCameraValidation.Run -logFile /private/tmp/shader-readability-second/grab-verified.log

python3 -B tools/shader_readability/summarize_validation.py --work /private/tmp/shader-readability-second
```

汇总脚本核对完整 case 集合、当前源码和临时副本哈希、静态报告、编译结果及 GPU 报告绑定的 manifest，防止修改源码后误用旧结果。重跑会覆盖同名临时报告；需要保留时，为 `--work` 和后续 Unity 命令使用新的目录。
