// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Initial recovery: tools/shader_reconstruction/shaderlab_generator.py.
// Original serialized Shader SHA256: 7f563a8f6745d90cfa48233d1bc08dcca1d6579bbf0294eee03bee9b9838d38f
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Alpha Masked/Sprites Alpha Masked - World Coords"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [Toggle] _ClampHoriz ("Clamp Alpha Horizontally", Float) = 0
        [Toggle] _ClampVert ("Clamp Alpha Vertically", Float) = 0
        [Toggle] _UseAlphaChannel ("Use Mask Alpha Channel (not RGB)", Float) = 0
        _MaskRotation ("Mask Rotation in Radians", Float) = 0
        _AlphaTex ("Alpha Mask", 2D) = "white" {}
        _ClampBorder ("Clamping Border", Float) = 0.00999999978
        [KeywordEnum(X, Y, Z)] _Axis ("Alpha Mapping Axis", Float) = 0
        _IsThisText ("Is This Text?", Float) = 0
    }
    SubShader
    {
        Tags { "CanUseSpriteAtlas"="true" "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Tags { "CanUseSpriteAtlas"="true" "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
            Cull Off
            ZClip On
            ZTest LEqual
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Blend One OneMinusSrcAlpha
            BlendOp Add
            ColorMask RGBA
            Fog { Mode Off }
            HLSLPROGRAM
#pragma target 4.5
#pragma vertex RecoveryVertex
#pragma fragment RecoveryFragment
#pragma multi_compile DUMMY _SCREEN_SPACE_UI
#pragma multi_compile __ PIXELSNAP_ON
#pragma multi_compile __ _AXIS_X
#pragma multi_compile __ _AXIS_Y
#pragma multi_compile __ _AXIS_Z
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

#if (defined(DUMMY) && defined(_SCREEN_SPACE_UI) && defined(_AXIS_X)) || (defined(DUMMY) && defined(_SCREEN_SPACE_UI) && defined(_AXIS_Y)) || (defined(DUMMY) && defined(_SCREEN_SPACE_UI) && defined(_AXIS_Z)) || (defined(_CLAMPHORIZ_ON)) || (defined(_CLAMPVERT_ON))
float _ClampBorder;
#endif

float4 _Color;
float _IsThisText;
Texture2D<float4> _MainTex;
float4 _MainTex_ST;

#if (defined(_AXIS_X)) || (defined(_AXIS_Y)) || (defined(_AXIS_Z))
float _MaskRotation;
#endif

SamplerState sampler_AlphaTex;
SamplerState sampler_MainTex;

// Vertex interface.
struct MaskedVertexInput
{
    float4 positionOS : POSITION0;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
};

struct MaskedVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;
    float2 mainUv : TEXCOORD1;
    float2 maskUv : TEXCOORD2;
};

// Vertex programs, shared across fragment variants.
#if !defined(DUMMY) && !defined(PIXELSNAP_ON) && !defined(_AXIS_X) && !defined(_AXIS_Y) && defined(_AXIS_Z)
// Captured vertex program SHA256:
// 09c6f28c3e16ab483449e59a57b5223be6a26411f8fe3ebbac1fb89961d4b423
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float2 u_xlat6;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat1 = u_xlat0.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat1 = mad(transpose(unity_MatrixVP)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_MatrixVP)[2], u_xlat0.zzzz, u_xlat1);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat0.wwww, u_xlat1);
    output.color = input.color * _Color;
    u_xlat0.x = sin(_MaskRotation);
    u_xlat1.x = cos(_MaskRotation);
    u_xlat2.z = u_xlat0.x;
    u_xlat2.y = u_xlat1.x;
    u_xlat2.x = (-u_xlat0.x);
    u_xlat6.y = dot(input.positionOS.xy, u_xlat2.xy);
    u_xlat6.x = dot(input.positionOS.xy, u_xlat2.yz);
    output.maskUv.xy = mad(u_xlat6.xy, _AlphaTex_ST.xy, _AlphaTex_ST.zw);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    return output;
}
#endif

#if !defined(DUMMY) && defined(PIXELSNAP_ON) && !defined(_AXIS_X) && !defined(_AXIS_Y) && defined(_AXIS_Z)
// Captured vertex program SHA256:
// 3ca6b2ba618f06d74223832f0be84f4c545c69fdf845a28ac8d431561f577cff
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float2 u_xlat6;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat1 = u_xlat0.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat1 = mad(transpose(unity_MatrixVP)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_MatrixVP)[2], u_xlat0.zzzz, u_xlat1);
    u_xlat0 = mad(transpose(unity_MatrixVP)[3], u_xlat0.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy / u_xlat0.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.xy;
    u_xlat0.xy = round(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy / u_xlat1.xy;
    output.positionCS.xy = u_xlat0.ww * u_xlat0.xy;
    output.positionCS.zw = u_xlat0.zw;
    output.color = input.color * _Color;
    u_xlat0.x = sin(_MaskRotation);
    u_xlat1.x = cos(_MaskRotation);
    u_xlat2.z = u_xlat0.x;
    u_xlat2.y = u_xlat1.x;
    u_xlat2.x = (-u_xlat0.x);
    u_xlat6.y = dot(input.positionOS.xy, u_xlat2.xy);
    u_xlat6.x = dot(input.positionOS.xy, u_xlat2.yz);
    output.maskUv.xy = mad(u_xlat6.xy, _AlphaTex_ST.xy, _AlphaTex_ST.zw);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    return output;
}
#endif

#if defined(DUMMY) && !defined(_SCREEN_SPACE_UI) && defined(PIXELSNAP_ON) && !defined(_AXIS_X) && !defined(_AXIS_Y) && defined(_AXIS_Z)
// Captured vertex program SHA256:
// ccbeefbdb147ef55a16ae9667d8c7fb1be3db3c9dc7dffc4d69c0582801bd42f
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
    output.color = input.color * _Color;
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

#if defined(DUMMY) && !defined(_SCREEN_SPACE_UI) && !defined(PIXELSNAP_ON) && !defined(_AXIS_X) && !defined(_AXIS_Y) && defined(_AXIS_Z)
// Captured vertex program SHA256:
// fd8cc5cd0964e8bd37837305c5fedd4c90b5b4e709d915ce2614ad974a7dfcf1
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
    output.color = input.color * _Color;
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

#if !defined(DUMMY) && defined(PIXELSNAP_ON) && !defined(_AXIS_X) && defined(_AXIS_Y)
// Captured vertex program SHA256:
// 03d657ef60cdf0b1e1e6d5629a8e5ee75319ef8d6f0325fd6c0f26f6ab70c571
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float2 u_xlat6;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat1 = u_xlat0.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat1 = mad(transpose(unity_MatrixVP)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_MatrixVP)[2], u_xlat0.zzzz, u_xlat1);
    u_xlat0 = mad(transpose(unity_MatrixVP)[3], u_xlat0.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy / u_xlat0.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.xy;
    u_xlat0.xy = round(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy / u_xlat1.xy;
    output.positionCS.xy = u_xlat0.ww * u_xlat0.xy;
    output.positionCS.zw = u_xlat0.zw;
    output.color = input.color * _Color;
    u_xlat0.x = sin(_MaskRotation);
    u_xlat1.x = cos(_MaskRotation);
    u_xlat2.z = u_xlat0.x;
    u_xlat2.y = u_xlat1.x;
    u_xlat2.x = (-u_xlat0.x);
    u_xlat6.y = dot(input.positionOS.xz, u_xlat2.xy);
    u_xlat6.x = dot(input.positionOS.xz, u_xlat2.yz);
    output.maskUv.xy = mad(u_xlat6.xy, _AlphaTex_ST.xy, _AlphaTex_ST.zw);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    return output;
}
#endif

#if !defined(DUMMY) && !defined(PIXELSNAP_ON) && !defined(_AXIS_X) && defined(_AXIS_Y)
// Captured vertex program SHA256:
// 38b95b9aaa9e97b0dbce731523fccc32bef271eddfa2d1373003ca7a48b0138d
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float2 u_xlat6;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat1 = u_xlat0.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat1 = mad(transpose(unity_MatrixVP)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_MatrixVP)[2], u_xlat0.zzzz, u_xlat1);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat0.wwww, u_xlat1);
    output.color = input.color * _Color;
    u_xlat0.x = sin(_MaskRotation);
    u_xlat1.x = cos(_MaskRotation);
    u_xlat2.z = u_xlat0.x;
    u_xlat2.y = u_xlat1.x;
    u_xlat2.x = (-u_xlat0.x);
    u_xlat6.y = dot(input.positionOS.xz, u_xlat2.xy);
    u_xlat6.x = dot(input.positionOS.xz, u_xlat2.yz);
    output.maskUv.xy = mad(u_xlat6.xy, _AlphaTex_ST.xy, _AlphaTex_ST.zw);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    return output;
}
#endif

#if defined(PIXELSNAP_ON) && !defined(_AXIS_X) && !defined(_AXIS_Y) && !defined(_AXIS_Z)
// Captured vertex program SHA256:
// 5b85dd78150d96f834221ce3a86edb83548b977a99fe5be5b0d85a5fbafc44f5
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
    u_xlat0 = mad(transpose(unity_MatrixVP)[3], u_xlat0.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy / u_xlat0.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.xy;
    u_xlat0.xy = round(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy / u_xlat1.xy;
    output.positionCS.xy = u_xlat0.ww * u_xlat0.xy;
    output.positionCS.zw = u_xlat0.zw;
    output.color = input.color * _Color;
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    output.maskUv.xy = _AlphaTex_ST.zw;
    return output;
}
#endif

#if !defined(PIXELSNAP_ON) && !defined(_AXIS_X) && !defined(_AXIS_Y) && !defined(_AXIS_Z)
// Captured vertex program SHA256:
// 89645cd004dab91d994becd4e4e5edc98b6c742ff027fb9e21e65d012cc754c5
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
    output.color = input.color * _Color;
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    output.maskUv.xy = _AlphaTex_ST.zw;
    return output;
}
#endif

#if defined(DUMMY) && !defined(_SCREEN_SPACE_UI) && !defined(PIXELSNAP_ON) && !defined(_AXIS_X) && defined(_AXIS_Y)
// Captured vertex program SHA256:
// c80a8a1a8f2ac882ac7c121b0a92328c29ad86634d934ea7de9a1ca73512c0f0
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
    output.color = input.color * _Color;
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

#if defined(DUMMY) && !defined(_SCREEN_SPACE_UI) && defined(PIXELSNAP_ON) && !defined(_AXIS_X) && defined(_AXIS_Y)
// Captured vertex program SHA256:
// daf0118340996fb1b9a5758c8efae9a7c03585e07b6d8b969ed9990e6d553b4b
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
    u_xlat1 = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat8.xy = u_xlat1.xy / u_xlat1.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat8.xy = u_xlat8.xy * u_xlat1.xy;
    u_xlat8.xy = round(u_xlat8.xy);
    u_xlat8.xy = u_xlat8.xy / u_xlat1.xy;
    output.positionCS.xy = u_xlat1.ww * u_xlat8.xy;
    output.positionCS.zw = u_xlat1.zw;
    output.color = input.color * _Color;
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

#if !defined(_SCREEN_SPACE_UI) && !defined(PIXELSNAP_ON) && defined(_AXIS_X)
// Captured vertex program SHA256:
// 748bafbe5e0fc36a3e36c38884c5a335bef4d28d2ceee7338e9a5e225f704b22
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
    output.color = input.color * _Color;
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

#if !defined(DUMMY) && defined(PIXELSNAP_ON) && defined(_AXIS_X)
// Captured vertex program SHA256:
// 7673ce8f1b4111cf033ab27ae0f2e449b1a5cd9878835cffa63c6c11a7522e1d
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float2 u_xlat6;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat1 = u_xlat0.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat1 = mad(transpose(unity_MatrixVP)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_MatrixVP)[2], u_xlat0.zzzz, u_xlat1);
    u_xlat0 = mad(transpose(unity_MatrixVP)[3], u_xlat0.wwww, u_xlat1);
    u_xlat0.xy = u_xlat0.xy / u_xlat0.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat0.xy = u_xlat0.xy * u_xlat1.xy;
    u_xlat0.xy = round(u_xlat0.xy);
    u_xlat0.xy = u_xlat0.xy / u_xlat1.xy;
    output.positionCS.xy = u_xlat0.ww * u_xlat0.xy;
    output.positionCS.zw = u_xlat0.zw;
    output.color = input.color * _Color;
    u_xlat0.x = sin(_MaskRotation);
    u_xlat1.x = cos(_MaskRotation);
    u_xlat2.z = u_xlat0.x;
    u_xlat2.y = u_xlat1.x;
    u_xlat2.x = (-u_xlat0.x);
    u_xlat6.y = dot(input.positionOS.zy, u_xlat2.xy);
    u_xlat6.x = dot(input.positionOS.zy, u_xlat2.yz);
    output.maskUv.xy = mad(u_xlat6.xy, _AlphaTex_ST.xy, _AlphaTex_ST.zw);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    return output;
}
#endif

#if defined(DUMMY) && !defined(_SCREEN_SPACE_UI) && defined(PIXELSNAP_ON) && defined(_AXIS_X)
// Captured vertex program SHA256:
// c3000e838894404bf5a6fbfb57b195c45b9299b0f618482408f71b44b11e0b65
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
    u_xlat1 = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat8.xy = u_xlat1.xy / u_xlat1.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat8.xy = u_xlat8.xy * u_xlat1.xy;
    u_xlat8.xy = round(u_xlat8.xy);
    u_xlat8.xy = u_xlat8.xy / u_xlat1.xy;
    output.positionCS.xy = u_xlat1.ww * u_xlat8.xy;
    output.positionCS.zw = u_xlat1.zw;
    output.color = input.color * _Color;
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

#if (defined(DUMMY) && defined(_SCREEN_SPACE_UI) && defined(_AXIS_X)) || (defined(_SCREEN_SPACE_UI) && !defined(PIXELSNAP_ON) && defined(_AXIS_X)) || (defined(DUMMY) && defined(_SCREEN_SPACE_UI) && defined(_AXIS_Y)) || (defined(DUMMY) && defined(_SCREEN_SPACE_UI) && defined(_AXIS_Z))
// Captured vertex program SHA256:
// cbe77b93ce10eed5d3341ecd5ffbb44b4eef7453c4d2739f4e42a369a45ded89
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float2 u_xlat6;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat1 = u_xlat0.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat1 = mad(transpose(unity_MatrixVP)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_MatrixVP)[2], u_xlat0.zzzz, u_xlat1);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat0.wwww, u_xlat1);
    output.color = input.color * _Color;
    u_xlat0.x = sin(_MaskRotation);
    u_xlat1.x = cos(_MaskRotation);
    u_xlat2.z = u_xlat0.x;
    u_xlat2.y = u_xlat1.x;
    u_xlat2.x = (-u_xlat0.x);
    u_xlat6.y = dot(input.positionOS.zy, u_xlat2.xy);
    u_xlat6.x = dot(input.positionOS.zy, u_xlat2.yz);
    output.maskUv.xy = mad(u_xlat6.xy, _AlphaTex_ST.xy, _AlphaTex_ST.zw);
    output.mainUv.xy = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    return output;
}
#endif

// Fragment interface.
struct MaskedFragmentInput
{
    float4 color : COLOR0;
    float2 mainUv : TEXCOORD1;
    float2 maskUv : TEXCOORD2;
};

struct MaskedFragmentOutput
{
    float4 color : SV_Target0;
};

// Fragment programs, shared across vertex variants.
#if (!defined(DUMMY) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_SCREEN_SPACE_UI) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_X) && !defined(_AXIS_Y) && !defined(_AXIS_Z) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// 0482a89c7b4399454d59fd7ff0ce4d7bf7a61c2d3dbcf71cc3e1e3c26663136b
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
    u_xlat2 = u_xlat1.w * input.color.w;
    u_xlat1.xyz = u_xlat1.xyz + ((float3)(_IsThisText));
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    u_xlat1.xyz = u_xlat1.xyz * input.color.xyz;
    u_xlat0.x = u_xlat0.x * u_xlat2;
    output.color.xyz = u_xlat0.xxx * u_xlat1.xyz;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

#if (!defined(DUMMY) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_SCREEN_SPACE_UI) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_X) && !defined(_AXIS_Y) && !defined(_AXIS_Z) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// 5d9351d9b1fc66b19c046d301628e9dda1e89248bf25e8ff3279d45aafb0de13
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
    u_xlat2 = u_xlat1.w * input.color.w;
    u_xlat1.xyz = u_xlat1.xyz + ((float3)(_IsThisText));
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    u_xlat1.xyz = u_xlat1.xyz * input.color.xyz;
    u_xlat0.x = u_xlat0.x * u_xlat2;
    output.color.xyz = u_xlat0.xxx * u_xlat1.xyz;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

#if (!defined(DUMMY) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_SCREEN_SPACE_UI) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_X) && !defined(_AXIS_Y) && !defined(_AXIS_Z) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// a4dcfe7cad80ca38a7a2a3982d0bdd49095cc0d8d6cf088654d4618b90de7f7e
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float4 u_xlat0;
    float u_xlat1;
    float u_xlat6;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    u_xlat0.xyz = u_xlat0.xyz + ((float3)(_IsThisText));
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat6 = u_xlat0.w * input.color.w;
    u_xlat0.xyz = u_xlat0.xyz * input.color.xyz;
    u_xlat1 = _AlphaTex.Sample(sampler_AlphaTex, input.maskUv.xy).x;
    u_xlat6 = u_xlat6 * u_xlat1;
    output.color.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    output.color.w = u_xlat6;
    return output;
}
#endif

#if (!defined(DUMMY) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_SCREEN_SPACE_UI) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_X) && !defined(_AXIS_Y) && !defined(_AXIS_Z) && defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// c63925f24132aa442c4bcce65960c0902cf9b0e9cf2d00ac3a68cda246449bd3
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
    u_xlat2.x = u_xlat1.w * input.color.w;
    u_xlat1.xyz = u_xlat1.xyz + ((float3)(_IsThisText));
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    u_xlat1.xyz = u_xlat1.xyz * input.color.xyz;
    u_xlat0.x = u_xlat0.x * u_xlat2.x;
    output.color.xyz = u_xlat0.xxx * u_xlat1.xyz;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

#if (!defined(DUMMY) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_SCREEN_SPACE_UI) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_X) && !defined(_AXIS_Y) && !defined(_AXIS_Z) && defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// d3a32af08c0a4f080ab5d79803434d6e159de9df09baa6c20a78d283eea89180
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
    u_xlat2 = u_xlat1.w * input.color.w;
    u_xlat1.xyz = u_xlat1.xyz + ((float3)(_IsThisText));
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    u_xlat1.xyz = u_xlat1.xyz * input.color.xyz;
    u_xlat0.x = u_xlat0.x * u_xlat2;
    output.color.xyz = u_xlat0.xxx * u_xlat1.xyz;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

#if (!defined(DUMMY) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_SCREEN_SPACE_UI) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_X) && !defined(_AXIS_Y) && !defined(_AXIS_Z) && !defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && !defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// e62462f18d6645be5c904fad22a4a3598cbe2bbdc552760766b5eb427c63303b
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
    u_xlat2 = u_xlat1.w * input.color.w;
    u_xlat1.xyz = u_xlat1.xyz + ((float3)(_IsThisText));
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    u_xlat1.xyz = u_xlat1.xyz * input.color.xyz;
    u_xlat0.x = u_xlat0.x * u_xlat2;
    output.color.xyz = u_xlat0.xxx * u_xlat1.xyz;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

#if (!defined(DUMMY) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_SCREEN_SPACE_UI) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON)) || (!defined(_AXIS_X) && !defined(_AXIS_Y) && !defined(_AXIS_Z) && !defined(_CLAMPHORIZ_ON) && !defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// e9a40f26ca62c3fc996db869b567e1dccde38bd1ca343420cc13c7e5d2f2bc72
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float4 u_xlat0;
    float u_xlat1;
    float u_xlat6;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.mainUv.xy);
    u_xlat0.xyz = u_xlat0.xyz + ((float3)(_IsThisText));
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat6 = u_xlat0.w * input.color.w;
    u_xlat0.xyz = u_xlat0.xyz * input.color.xyz;
    u_xlat1 = _AlphaTex.Sample(sampler_AlphaTex, input.maskUv.xy).w;
    u_xlat6 = u_xlat6 * u_xlat1;
    output.color.xyz = ((float3)(u_xlat6)) * u_xlat0.xyz;
    output.color.w = u_xlat6;
    return output;
}
#endif

#if (defined(DUMMY) && defined(_SCREEN_SPACE_UI) && defined(_AXIS_X)) || (defined(DUMMY) && defined(_SCREEN_SPACE_UI) && defined(_AXIS_Y)) || (defined(DUMMY) && defined(_SCREEN_SPACE_UI) && defined(_AXIS_Z)) || (defined(_CLAMPHORIZ_ON) && defined(_CLAMPVERT_ON) && defined(_USEALPHACHANNEL_ON))
// Captured fragment program SHA256:
// ea3d45cf1d8505050e4c842217e482004274ee1ba4a7d9e5912f035de49dec71
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
    u_xlat2.x = u_xlat1.w * input.color.w;
    u_xlat1.xyz = u_xlat1.xyz + ((float3)(_IsThisText));
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    u_xlat1.xyz = u_xlat1.xyz * input.color.xyz;
    u_xlat0.x = u_xlat0.x * u_xlat2.x;
    output.color.xyz = u_xlat0.xxx * u_xlat1.xyz;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

            ENDHLSL
        }
    }
    Fallback "Unlit/Texture"
}
