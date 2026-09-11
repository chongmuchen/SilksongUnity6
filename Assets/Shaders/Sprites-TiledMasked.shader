// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Initial recovery: tools/shader_reconstruction/shaderlab_generator.py.
// Original serialized Shader SHA256: 408a5b1958f240fd90490e10cbd5f03c0136bc7e31c0b5e766bdc66e6ce1d30a
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Sprites/Tiled Masked"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
        [HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
        _ScrollTex ("Texture", 2D) = "white" {}
        [PerRendererData] _FogRotation ("Fog Rotation", Float) = 0
        [Toggle(WORLD_SCALE_FLIP)] _EnableWorldScaleFlip ("Enable World Scale Flip", Float) = 1
        [Toggle(SILHOUETTE)] _EnableSilhouette ("Is Silhouette", Float) = 0
    }
    SubShader
    {
        Tags { "CanUseSpriteAtlas"="true" "DisableBatching"="true" "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Tags { "CanUseSpriteAtlas"="true" "DisableBatching"="true" "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
            Cull Off
            ZClip On
            ZTest LEqual
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Blend One OneMinusSrcAlpha
            BlendOp Add
            ColorMask RGBA
            HLSLPROGRAM
#pragma target 4.5
#pragma vertex RecoveryVertex
#pragma fragment RecoveryFragment
#pragma multi_compile __ DITHERING_NOISE
#pragma multi_compile __ ETC1_EXTERNAL_ALPHA
#pragma multi_compile __ PIXELSNAP_ON
#pragma multi_compile __ WORLD_SCALE_FLIP
// Shared declarations and independent stage selection preserve the recovered programs.
// Keep pragma option order, especially forced DUMMY/axis groups and their defaults.
// Conditions preserve the original first-matching branch, including extra keyword
// combinations and an empty keyword set; features must not be independently stacked.
// Float precision, declaration/CBUFFER layout, sampling and arithmetic remain unchanged.
// Reproduce with tools/shader_readability/refactor_masks.py; verify with check_masks.py.

// Material and per-renderer data.
#include "UnityCG.cginc"

#if defined(ETC1_EXTERNAL_ALPHA)
Texture2D<float4> _AlphaTex;
#endif

float4 _Color;
float _FogRotation;
Texture2D<float4> _MainTex;
Texture2D<float4> _ScrollTex;
float4 _ScrollTex_ST;
CBUFFER_START(UnityPerDrawSprite)
    float4 _RendererColor;
    float2 _Flip;
    float _EnableExternalAlpha;
CBUFFER_END

#if defined(ETC1_EXTERNAL_ALPHA)
SamplerState sampler_AlphaTex;
#endif

SamplerState sampler_MainTex;
SamplerState sampler_ScrollTex;

// Vertex interface.
struct MaskedVertexInput
{
    float4 positionOS : POSITION0;
    float4 color : COLOR0;
    float2 spriteUv : TEXCOORD0;
};

struct MaskedVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;
    float2 spriteUv : TEXCOORD0;
    float2 scrollUv : TEXCOORD1;
};

// Vertex programs, shared across fragment variants.
#if defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP)
// Captured vertex program SHA256:
// 2dffb3439cf7c8d98ef9094ff6b86736e40195914fb0832e53dcfdcbbdbddb72
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
    u_xlat1 = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat8.xy = u_xlat1.xy / u_xlat1.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat8.xy = u_xlat8.xy * u_xlat1.xy;
    u_xlat8.xy = round(u_xlat8.xy);
    u_xlat8.xy = u_xlat8.xy / u_xlat1.xy;
    output.positionCS.xy = u_xlat1.ww * u_xlat8.xy;
    output.positionCS.zw = u_xlat1.zw;
    u_xlat1 = input.color * _Color;
    output.color = u_xlat1 * _RendererColor;
    u_xlat1.x = sin(_FogRotation);
    u_xlat2.x = cos(_FogRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat8.y = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.yz);
    output.scrollUv.xy = mad(u_xlat8.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if !defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP)
// Captured vertex program SHA256:
// b41aa9dd816507bd816cb7d74cf6b08ab8d3e9be84f6e70595dfff81010b0ada
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    float2 u_xlat8;
    int2 u_xlati8;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat0.xy = mad(transpose(unity_ObjectToWorld)[3].xy, input.positionOS.ww, u_xlat0.xy);
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat1 = input.color * _Color;
    output.color = u_xlat1 * _RendererColor;
    u_xlat8.xy = transpose(unity_ObjectToWorld)[0].xy + transpose(unity_ObjectToWorld)[1].xy;
    u_xlat8.xy = u_xlat8.xy + transpose(unity_ObjectToWorld)[2].xy;
    u_xlati1.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat8.xy))) * 0xFFFFFFFFu));
    u_xlati8.xy = ((int2)(((uint2)((u_xlat8.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati8.xy = (-u_xlati1.xy) + u_xlati8.xy;
    u_xlat8.xy = ((float2)(u_xlati8.xy));
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat1.x = sin(_FogRotation);
    u_xlat2.x = cos(_FogRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat8.y = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.yz);
    output.scrollUv.xy = mad(u_xlat8.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP)
// Captured vertex program SHA256:
// ba7e6bcee2c68d55850eac652257090ea881c7e4f9388b9a8c324b42e7aa16da
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    float2 u_xlat8;
    int2 u_xlati8;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat0.xy = mad(transpose(unity_ObjectToWorld)[3].xy, input.positionOS.ww, u_xlat0.xy);
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    u_xlat1 = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat8.xy = u_xlat1.xy / u_xlat1.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat8.xy = u_xlat8.xy * u_xlat1.xy;
    u_xlat8.xy = round(u_xlat8.xy);
    u_xlat8.xy = u_xlat8.xy / u_xlat1.xy;
    output.positionCS.xy = u_xlat1.ww * u_xlat8.xy;
    output.positionCS.zw = u_xlat1.zw;
    u_xlat1 = input.color * _Color;
    output.color = u_xlat1 * _RendererColor;
    u_xlat8.xy = transpose(unity_ObjectToWorld)[0].xy + transpose(unity_ObjectToWorld)[1].xy;
    u_xlat8.xy = u_xlat8.xy + transpose(unity_ObjectToWorld)[2].xy;
    u_xlati1.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat8.xy))) * 0xFFFFFFFFu));
    u_xlati8.xy = ((int2)(((uint2)((u_xlat8.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati8.xy = (-u_xlati1.xy) + u_xlati8.xy;
    u_xlat8.xy = ((float2)(u_xlati8.xy));
    u_xlat0.xy = u_xlat8.xy * u_xlat0.xy;
    u_xlat1.x = sin(_FogRotation);
    u_xlat2.x = cos(_FogRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat8.y = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.yz);
    output.scrollUv.xy = mad(u_xlat8.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if !defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP)
// Captured vertex program SHA256:
// bd6703a1ae3c1d8cf807ce0b01a67757a60b4efeec494edd8131e66a09d4f66e
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
    u_xlat1 = input.color * _Color;
    output.color = u_xlat1 * _RendererColor;
    u_xlat1.x = sin(_FogRotation);
    u_xlat2.x = cos(_FogRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat8.y = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.yz);
    output.scrollUv.xy = mad(u_xlat8.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

// Fragment interface.
struct MaskedFragmentInput
{
    float4 color : COLOR0;
    float2 spriteUv : TEXCOORD0;
    float2 scrollUv : TEXCOORD1;
};

struct MaskedFragmentOutput
{
    float4 color : SV_Target0;
};

// Fragment programs, shared across vertex variants.
#if !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 001e632eb975959f823420c0bc8d307c652e55b482e08dfae5e7c82957c60c6f
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.spriteUv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).wxyz;
    u_xlat0.x = u_xlat0.x + (-u_xlat1.x);
    u_xlat1.x = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.x);
    u_xlat0 = u_xlat1 * input.color.wxyz;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat0 = u_xlat0 * u_xlat1.wxyz;
    output.color.xyz = u_xlat0.xxx * u_xlat0.yzw;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

#if !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 3e3b76cf4a711e23c60e239e9fefefeb3936823cfb2c6b76b0b0ca473f148b77
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy);
    u_xlat0 = u_xlat0.wxyz * input.color.wxyz;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat0 = u_xlat0 * u_xlat1.wxyz;
    output.color.xyz = u_xlat0.xxx * u_xlat0.yzw;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

#if defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 4e122f45757dc279ed74c433a11d1ac5f81a50e905f0d064cecdde1dc29cf0c9
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input, float4 positionSS : SV_POSITION)
{
    MaskedFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy);
    u_xlat1 = u_xlat1.wxyz * input.color.wxyz;
    u_xlat2 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat1 = u_xlat1.yzwx * u_xlat2;
    u_xlat1.xyz = u_xlat1.www * u_xlat1.xyz;
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}
#endif

#if defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 93dfb571babbc1fa3218dd540b495f3afc6888ba95befc2ffc963cbb9724c5f0
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input, float4 positionSS : SV_POSITION)
{
    MaskedFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat3 = _AlphaTex.Sample(sampler_AlphaTex, input.spriteUv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).wxyz;
    u_xlat3 = u_xlat3 + (-u_xlat1.x);
    u_xlat1.x = mad(_EnableExternalAlpha, u_xlat3, u_xlat1.x);
    u_xlat1 = u_xlat1 * input.color.wxyz;
    u_xlat2 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat1 = u_xlat1.yzwx * u_xlat2;
    u_xlat1.xyz = u_xlat1.www * u_xlat1.xyz;
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}
#endif

            ENDHLSL
        }
    }
}
