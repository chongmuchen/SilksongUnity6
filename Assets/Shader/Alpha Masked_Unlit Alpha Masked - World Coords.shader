// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Initial recovery: tools/shader_reconstruction/shaderlab_generator.py.
// Original serialized Shader SHA256: 1fefcf9ef359ad2ef1565b20d7acf32a88acd3df0c1ce8b0a2791084bb593888
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Alpha Masked/Unlit Alpha Masked - World Coords"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle] _ClampHoriz ("Clamp Alpha Horizontally", Float) = 0
        [Toggle] _ClampVert ("Clamp Alpha Vertically", Float) = 0
        [Toggle] _UseAlphaChannel ("Use Mask Alpha Channel (not RGB)", Float) = 0
        _MaskRotation ("Mask Rotation in Radians", Float) = 0
        _AlphaTex ("Alpha Mask", 2D) = "white" {}
        _ClampBorder ("Clamping Border", Float) = 0.00999999978
        [KeywordEnum(X, Y, Z)] _Axis ("Alpha Mapping Axis", Float) = 0
    }
    SubShader
    {
        Tags { "IGNOREPROJECTOR"="true" "QUEUE"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Tags { "IGNOREPROJECTOR"="true" "QUEUE"="Transparent" "RenderType"="Transparent" }
            Cull Back
            ZClip On
            ZTest LEqual
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Blend SrcAlpha OneMinusSrcAlpha
            BlendOp Add
            ColorMask RGBA
            HLSLPROGRAM
#pragma target 4.5
#pragma vertex RecoveryVertex
#pragma fragment RecoveryFragment
#pragma multi_compile DUMMY _AXIS_Z
#pragma multi_compile __ _AXIS_X
#pragma multi_compile __ _AXIS_Y
#pragma multi_compile __ _CLAMPHORIZ_ON
#pragma multi_compile __ _CLAMPVERT_ON
#pragma multi_compile __ _USEALPHACHANNEL_ON
// Shared declarations and independent stage selection preserve the recovered programs.
// Keep pragma option order, especially forced DUMMY/axis groups and their defaults.
// Conditions preserve the original first-matching branch, including extra keyword
// combinations and an empty keyword set; features must not be independently stacked.
// Float precision, declaration/CBUFFER layout, sampling and arithmetic remain unchanged.
// Reproduce with tools/shader_readability/refactor_masks.py; verify with check_masks.py.

// Material and per-renderer data.
#include "UnityCG.cginc"
Texture2D<float4> _AlphaTex;
float4 _AlphaTex_ST;

#if (defined(DUMMY) && defined(_AXIS_Z) && !defined(_AXIS_X) && !defined(_AXIS_Y)) || (defined(_CLAMPHORIZ_ON)) || (defined(_CLAMPVERT_ON))
float _ClampBorder;
#endif

Texture2D<float4> _MainTex;
float4 _MainTex_ST;

#if (defined(_AXIS_Z)) || (defined(_AXIS_X)) || (defined(_AXIS_Y))
float _MaskRotation;
#endif

SamplerState sampler_AlphaTex;
SamplerState sampler_MainTex;

// Vertex interface.
struct MaskedVertexInput
{
    float4 positionOS : POSITION0;
    float4 uv : TEXCOORD0;
};

struct MaskedVertexOutput
{
    float4 positionCS : SV_POSITION;
    float2 mainUv : TEXCOORD1;
    float2 maskUv : TEXCOORD2;
};

// Vertex programs, shared across fragment variants.
#if !defined(_AXIS_Z) && !defined(_AXIS_X) && !defined(_AXIS_Y)
// Captured vertex program SHA256:
// 2271d2e390cc874654b96407f6c8bb6a91ae131cc5e12178bd08a618fe4a8751
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat1 = u_xlat0.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat1 = mad(transpose(unity_MatrixVP)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_MatrixVP)[2], u_xlat0.zzzz, u_xlat1);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat0.wwww, u_xlat1);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    output.maskUv.xy = _AlphaTex_ST.zw;
    return output;
}
#endif

#if !defined(DUMMY) && defined(_AXIS_Z) && !defined(_AXIS_X) && !defined(_AXIS_Y)
// Captured vertex program SHA256:
// baabd11ff33ea3973bd6f2614c7f12cf9317c2229599b581565c7d8474bfb6cc
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float3 u_xlat3;
    float2 u_xlat8;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat0.xy = mad(transpose(unity_ObjectToWorld)[3].xy, input.positionOS.ww, u_xlat0.xy);
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat1.x = sin(_MaskRotation);
    u_xlat2.x = cos(_MaskRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat8.y = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.yz);
    output.maskUv.xy = mad(u_xlat8.xy, _AlphaTex_ST.xy, _AlphaTex_ST.zw);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    return output;
}
#endif

#if !defined(_AXIS_X) && defined(_AXIS_Y)
// Captured vertex program SHA256:
// 2b5e4fe85a556e0b4444d2932136c96f71b255022dd2f4aee981385bda743b6e
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float3 u_xlat3;
    float2 u_xlat8;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat0.xy = mad(transpose(unity_ObjectToWorld)[3].xz, input.positionOS.ww, u_xlat0.xz);
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat1.x = sin(_MaskRotation);
    u_xlat2.x = cos(_MaskRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat8.y = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.yz);
    output.maskUv.xy = mad(u_xlat8.xy, _AlphaTex_ST.xy, _AlphaTex_ST.zw);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    return output;
}
#endif

#if (defined(_AXIS_X)) || (defined(DUMMY) && defined(_AXIS_Z) && !defined(_AXIS_Y))
// Captured vertex program SHA256:
// a5a7f15702b1e4f2eb43e132f54110e4ac1e0d20f19c1ab229f4bcfb775d4ef8
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float3 u_xlat3;
    float2 u_xlat8;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat0.xy = mad(transpose(unity_ObjectToWorld)[3].zy, input.positionOS.ww, u_xlat0.zy);
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat1.x = sin(_MaskRotation);
    u_xlat2.x = cos(_MaskRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat8.y = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.yz);
    output.maskUv.xy = mad(u_xlat8.xy, _AlphaTex_ST.xy, _AlphaTex_ST.zw);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    return output;
}
#endif

// Fragment interface.
struct MaskedFragmentInput
{
    float2 mainUv : TEXCOORD1;
    float2 maskUv : TEXCOORD2;
};

struct MaskedFragmentOutput
{
    float4 color : SV_Target0;
};

// Fragment programs, shared across vertex variants.
#if (!defined(DUMMY) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_Z) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_X) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_Y) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// 74fa1cc7680d4595797f6dfa188bcff53ba1e25f2dca7137dc7de59c048e435e
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float2 u_xlat0;
    float4 u_xlat1;
    float2 u_xlat2;
    u_xlat0.x = (-_ClampBorder) + 1.0;
    u_xlat2.xy = max(input.maskUv.xy, ((float2)(_ClampBorder)));
    u_xlat0.xy = min(u_xlat0.xx, u_xlat2.xy);
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, u_xlat0.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    output.color.w = u_xlat0.x * u_xlat1.w;
    output.color.xyz = u_xlat1.xyz;
    return output;
}
#endif

#if (!defined(DUMMY) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_Z) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_X) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_Y) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// 81117e781640228f663054aa1364c1b84b62b06d0f8faffb7d53c46f984b2f70
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float u_xlat0;
    float4 u_xlat1;
    u_xlat0 = _AlphaTex.Sample(sampler_AlphaTex, input.maskUv.xy).w;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    output.color.w = u_xlat0 * u_xlat1.w;
    output.color.xyz = u_xlat1.xyz;
    return output;
}
#endif

#if (!defined(DUMMY) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_Z) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_X) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_Y) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// 9d4dc58a7abe542b1ac6dda864020d8c801f9264ded18d9658fbec68cd0a3d91
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float2 u_xlat0;
    float4 u_xlat1;
    float u_xlat2;
    u_xlat0.x = (-_ClampBorder) + 1.0;
    u_xlat2 = max(input.maskUv.y, _ClampBorder);
    u_xlat0.y = min(u_xlat0.x, u_xlat2);
    u_xlat0.x = input.maskUv.x;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, u_xlat0.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    output.color.w = u_xlat0.x * u_xlat1.w;
    output.color.xyz = u_xlat1.xyz;
    return output;
}
#endif

#if (!defined(DUMMY) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_Z) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_X) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_Y) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// a20f01a758b9b72edf66f3ccfbbb8f895b51063276837db608b845a2df8e9fa8
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float2 u_xlat0;
    float4 u_xlat1;
    float2 u_xlat2;
    u_xlat0.x = (-_ClampBorder) + 1.0;
    u_xlat2.xy = max(input.maskUv.xy, ((float2)(_ClampBorder)));
    u_xlat0.xy = min(u_xlat0.xx, u_xlat2.xy);
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, u_xlat0.xy).w;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    output.color.w = u_xlat0.x * u_xlat1.w;
    output.color.xyz = u_xlat1.xyz;
    return output;
}
#endif

#if (!defined(DUMMY) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_Z) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_X) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_Y) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// b3fb5d24b03bde9e846a7746f133bd90fba8465b09b5f4b08b5034200d4bf27a
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float u_xlat0;
    float4 u_xlat1;
    u_xlat0 = _AlphaTex.Sample(sampler_AlphaTex, input.maskUv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    output.color.w = u_xlat0 * u_xlat1.w;
    output.color.xyz = u_xlat1.xyz;
    return output;
}
#endif

#if (!defined(DUMMY) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_Z) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_X) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_Y) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// e7f810f6b55c8e3a3db4c30d1473d5114cbb316decdebd9a15fe8aafb51773d0
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float2 u_xlat0;
    float4 u_xlat1;
    float u_xlat2;
    u_xlat0.x = (-_ClampBorder) + 1.0;
    u_xlat2 = max(input.maskUv.y, _ClampBorder);
    u_xlat0.y = min(u_xlat0.x, u_xlat2);
    u_xlat0.x = input.maskUv.x;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, u_xlat0.xy).w;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    output.color.w = u_xlat0.x * u_xlat1.w;
    output.color.xyz = u_xlat1.xyz;
    return output;
}
#endif

#if (!defined(DUMMY) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_Z) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_X) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (defined(_AXIS_Y) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// e88c27e0f8c3073fd32bd4a697b7cdfd6d0a6982a219c1779d77537fe9153d7b
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float2 u_xlat0;
    float4 u_xlat1;
    float u_xlat2;
    u_xlat0.x = (-_ClampBorder) + 1.0;
    u_xlat2 = max(input.maskUv.x, _ClampBorder);
    u_xlat0.x = min(u_xlat0.x, u_xlat2);
    u_xlat0.y = input.maskUv.y;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, u_xlat0.xy).w;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    output.color.w = u_xlat0.x * u_xlat1.w;
    output.color.xyz = u_xlat1.xyz;
    return output;
}
#endif

#if (defined(DUMMY) && defined(_AXIS_Z) && !defined(_AXIS_X) && !defined(_AXIS_Y)) || (defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// fce33d32b4d17e2643e0788c02b5684e412a91fba9a660eca68837a8ce581025
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float2 u_xlat0;
    float4 u_xlat1;
    float u_xlat2;
    u_xlat0.x = (-_ClampBorder) + 1.0;
    u_xlat2 = max(input.maskUv.x, _ClampBorder);
    u_xlat0.x = min(u_xlat0.x, u_xlat2);
    u_xlat0.y = input.maskUv.y;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, u_xlat0.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    output.color.w = u_xlat0.x * u_xlat1.w;
    output.color.xyz = u_xlat1.xyz;
    return output;
}
#endif

            ENDHLSL
        }
    }
    Fallback "Unlit/Texture"
}
