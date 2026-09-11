// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Recovered by shaderlab_generator.py; readable source: tools/shader_readability/refactor_ui.py.
// Original serialized Shader SHA256: 2ce4fa20695ce8765fc92c5ff9f4f23fcccb3b8b726a30418eb273ea50fccf1a
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "UI/BlendModes/Optimized/LinearDodge"
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
        LOD 950
        Tags { "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Tags { "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
            Cull Off
            ZClip On
            ZTest [unity_GUIZTestMode]
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Blend One One
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

#define UI_BLEND_HAS_GRAB 0
#include "Assets/GUIBlendModes/Shaders/Includes/UIBlendCommon.cginc"

#if (1)
            // Original Metal program SHA256: vertex 4c427b1893dd1578a0cd519683fa421379edda04c9eb362bf2198edee4f8c2f7; fragment 4c2d667ece8853a140a2f74065806fb8ac80f65404f882b175118af65bae5a20.
#include "Assets/GUIBlendModes/Shaders/Includes/UIBlendTint.cginc"

#endif

            ENDHLSL
        }
    }
    Fallback "Sprites/Approximate Linear Dodge"
}
