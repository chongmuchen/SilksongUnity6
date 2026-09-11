// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Recovered by shaderlab_generator.py; readable source: tools/shader_readability/refactor_ui.py.
// Original serialized Shader SHA256: 6cdcecb7a553fa3795bd611eaed0017bdd51252705360d9aabeae5c5ca61831c
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "UI/BlendModes/LinearBurn"
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
#define UI_BLEND_BACKGROUND_TEXTURE _GrabTexture
#define UI_BLEND_BACKGROUND_SAMPLER sampler_GrabTexture
#include "Assets/GUIBlendModes/Shaders/Includes/UIBlendCommon.cginc"

#if (1)
            // Original Metal program SHA256: vertex e8a9390e720e488a88e40250c1ba00023b6a0912c1a9c492b33e4eeae6773cf0; fragment 2d33929dfc3ffba08063f6a8cc3c0d5131cf32ab5acd54d499d80b47a1011340.
#include "Assets/GUIBlendModes/Shaders/Includes/UIBlendLinearBurn.cginc"

#endif

            ENDHLSL
        }
    }
    Fallback "UI/Default"
}
