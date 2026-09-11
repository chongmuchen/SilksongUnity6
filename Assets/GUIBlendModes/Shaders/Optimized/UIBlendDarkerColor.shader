// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Recovered by shaderlab_generator.py; readable source: tools/shader_readability/refactor_ui.py.
// Original serialized Shader SHA256: 94f23f9283bf2bf210370b571415d853a5d72db0cde7db5c76a4ae858ffa2688
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "UI/BlendModes/Optimized/DarkerColor"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15
    }
    SubShader
    {
        Tags { "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
        GrabPass
        {
            "_GUIBlendingSharedGT"
        }
        Pass
        {
            Tags { "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
            Cull Off
            ZClip On
            ZTest [unity_GUIZTestMode]
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add
            ColorMask [_ColorMask]
            Stencil
            {
                Ref [_Stencil]
                ReadMask [_StencilReadMask]
                WriteMask [_StencilWriteMask]
                Comp [_StencilComp]
                Pass [_StencilOp]
                Fail Keep
                ZFail Keep
            }
            Fog { Mode Off }
            HLSLPROGRAM
#pragma target 4.5
#pragma vertex UIBlendVertex
#pragma fragment UIBlendFragment

#define UI_BLEND_HAS_GRAB 1
#define UI_BLEND_BACKGROUND_TEXTURE _GUIBlendingSharedGT
#define UI_BLEND_BACKGROUND_SAMPLER sampler_GUIBlendingSharedGT
#include "Assets/GUIBlendModes/Shaders/Includes/UIBlendCommon.cginc"

#if (1)
            // Original Metal program SHA256: vertex e8a9390e720e488a88e40250c1ba00023b6a0912c1a9c492b33e4eeae6773cf0; fragment a0ee9b37c7e4529a37fb0a117a3a7c7680c6892147e5170a08133d45ed72ed2b.
#include "Assets/GUIBlendModes/Shaders/Includes/UIBlendDarkerColor.cginc"

#endif

            ENDHLSL
        }
    }
    Fallback "UI/Default"
}
