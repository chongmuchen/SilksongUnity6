// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Initial recovery: tools/shader_reconstruction/shaderlab_generator.py.
// Shared declarations and stage programs retain the recovered arithmetic and keyword mapping.
// Original serialized Shader SHA256: b56d9a149dc192f04c38d21a57c156e5025f265f7cbef7f05fef2cb04634a464
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Sprites/Lit"
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
        [Space] [Toggle(AMBIENT_LERP)] _AmbientLerpEnabled ("Enable Ambient Lerp", Float) = 0
        _AmbientLerp ("Ambient Lerp", Range(0, 1)) = 1
        [Space] [Toggle(SATURATION_LERP)] _SaturationLerpEnabled ("Enable Saturation Lerp", Float) = 0
        _SaturationLerp ("Saturation Lerp", Float) = 1
        [Space] [Toggle(COLOR_FLASH)] _ColorFlashEnabled ("Enable Color Flash", Float) = 0
        _FlashColor ("Flash Color", Color) = (1, 1, 1, 1)
        _FlashAmount ("Flash Amount", Range(0, 1)) = 0
        [PerRendererData] _BlackThreadAmount ("Black Thread Amount", Range(0, 1)) = 1
        [Toggle(BLACKTHREAD)] _IsBlackThreaded ("Is Black Threaded", Float) = 0
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
            HLSLPROGRAM
#pragma target 4.5
#pragma vertex RecoveryVertex
#pragma fragment RecoveryFragment
#pragma multi_compile __ AMBIENT_LERP
#pragma multi_compile __ BLACKTHREAD
#pragma multi_compile __ COLOR_FLASH
#pragma multi_compile __ DITHERING_NOISE
#pragma multi_compile __ ETC1_EXTERNAL_ALPHA
#pragma multi_compile __ PIXELSNAP_ON
#pragma multi_compile __ SATURATION_LERP
#pragma multi_compile_instancing
// The 256 compiled keyword combinations keep the original recovery's 192 captures
// and 64 fallback selections. In particular, AMBIENT_LERP + COLOR_FLASH without
// SATURATION_LERP uses the ambient program; COLOR_FLASH + SATURATION_LERP without
// AMBIENT_LERP uses the flash program. Keep these selection rules when editing.
//
// Stage selection is independent: four vertex programs and 48 distinct fragment
// bodies (72 captured fragment hashes). Each selected program keeps float precision,
// declaration order, instancing layout, sample order, and arithmetic unchanged.

// Material and per-renderer data.
#include "UnityCG.cginc"

#if defined(ETC1_EXTERNAL_ALPHA)
Texture2D<float4> _AlphaTex;
#endif

#if defined(AMBIENT_LERP)
float _AmbientLerp;
#endif

#if defined(BLACKTHREAD)
float _BlackThreadAmount;
#endif

float4 _Color;

#if (!defined(AMBIENT_LERP) && defined(COLOR_FLASH)) || (defined(COLOR_FLASH) && defined(SATURATION_LERP))
float _FlashAmount;
float4 _FlashColor;
#endif

Texture2D<float4> _MainTex;

#if (defined(AMBIENT_LERP) && defined(SATURATION_LERP)) || (!defined(COLOR_FLASH) && defined(SATURATION_LERP))
float _SaturationLerp;
#endif

#if defined(INSTANCING_ON)
UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
    UNITY_DEFINE_INSTANCED_PROP(float4, unity_SpriteRendererColorArray)
    UNITY_DEFINE_INSTANCED_PROP(float2, unity_SpriteFlipArray)
UNITY_INSTANCING_BUFFER_END(PerDrawSprite)
#endif

#if (defined(ETC1_EXTERNAL_ALPHA)) || (!defined(INSTANCING_ON))
CBUFFER_START(UnityPerDrawSprite)
    float4 _RendererColor;
    float2 _Flip;
    float _EnableExternalAlpha;
CBUFFER_END
#endif

#if defined(ETC1_EXTERNAL_ALPHA)
SamplerState sampler_AlphaTex;
#endif

SamplerState sampler_MainTex;

// Vertex inputs and interpolation data.
struct SpriteVertexInput
{
    float4 positionOS : POSITION0;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
#if defined(INSTANCING_ON)
    uint instanceID : SV_InstanceID;
#endif
};

struct SpriteVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
};

#if !defined(PIXELSNAP_ON) && !defined(INSTANCING_ON)
// Captured vertex program SHA256:
// a7a8f8dbdb1fc1050ec9630a545df663e4ddb32d064afdb2ad2a1824c1abda4c
SpriteVertexOutput RecoveryVertex(SpriteVertexInput input)
{
    SpriteVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.xy = input.positionOS.xy * _Flip.xyxx.xy;
    u_xlat1 = u_xlat0.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat0 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat1 = u_xlat0.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat1 = mad(transpose(unity_MatrixVP)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_MatrixVP)[2], u_xlat0.zzzz, u_xlat1);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat0.wwww, u_xlat1);
    u_xlat0 = input.color * _Color;
    output.color = u_xlat0 * _RendererColor;
    output.uv.xy = input.uv.xy;
    return output;
}

#elif defined(PIXELSNAP_ON) && !defined(INSTANCING_ON)
// Captured vertex program SHA256:
// d3a26e4d330c014e743983ca784bb491e71fa72981e7bc27eff8f3e7f22efa0e
SpriteVertexOutput RecoveryVertex(SpriteVertexInput input)
{
    SpriteVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.xy = input.positionOS.xy * _Flip.xyxx.xy;
    u_xlat1 = u_xlat0.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], u_xlat0.xxxx, u_xlat1);
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
    u_xlat0 = input.color * _Color;
    output.color = u_xlat0 * _RendererColor;
    output.uv.xy = input.uv.xy;
    return output;
}

#elif !defined(PIXELSNAP_ON) && defined(INSTANCING_ON)
// Captured vertex program SHA256:
// 49cd15cea5f31dd5df9ff6867ff574f6ddd205c2ae3bce335834772c8a06cd8c
SpriteVertexOutput RecoveryVertex(SpriteVertexInput input)
{

    SpriteVertexOutput output;
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float2 u_xlat6;
    u_xlati0.x = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati0.xy = u_xlati0.xx << int2(0x1, 0x3);
    u_xlat6.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati0.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat1 = u_xlat6.yyyy * transpose(unity_Builtins0Array[u_xlati0.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat1 = mad(transpose(unity_Builtins0Array[u_xlati0.y / 8].unity_ObjectToWorldArray)[0], u_xlat6.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_Builtins0Array[u_xlati0.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat1);
    u_xlat1 = u_xlat1 + transpose(unity_Builtins0Array[u_xlati0.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat1 = input.color * _Color;
    output.color = u_xlat1 * PerDrawSpriteArray[u_xlati0.x / 2].unity_SpriteRendererColorArray;
    output.uv.xy = input.uv.xy;
    return output;
}

#elif defined(PIXELSNAP_ON) && defined(INSTANCING_ON)
// Captured vertex program SHA256:
// e8e2bc531786dc0b0354961857192908a8245df6a1e38239eadd993c86e9c384
SpriteVertexOutput RecoveryVertex(SpriteVertexInput input)
{

    SpriteVertexOutput output;
    int2 u_xlati0;
    float4 u_xlat1;
    float4 u_xlat2;
    float2 u_xlat3;
    float2 u_xlat6;
    u_xlati0.x = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati0.xy = u_xlati0.xx << int2(0x1, 0x3);
    u_xlat6.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati0.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat1 = u_xlat6.yyyy * transpose(unity_Builtins0Array[u_xlati0.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat1 = mad(transpose(unity_Builtins0Array[u_xlati0.y / 8].unity_ObjectToWorldArray)[0], u_xlat6.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_Builtins0Array[u_xlati0.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat1);
    u_xlat1 = u_xlat1 + transpose(unity_Builtins0Array[u_xlati0.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    u_xlat1 = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat3.xy = u_xlat1.xy / u_xlat1.ww;
    u_xlat1.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat3.xy = u_xlat3.xy * u_xlat1.xy;
    u_xlat3.xy = round(u_xlat3.xy);
    u_xlat3.xy = u_xlat3.xy / u_xlat1.xy;
    output.positionCS.xy = u_xlat1.ww * u_xlat3.xy;
    output.positionCS.zw = u_xlat1.zw;
    u_xlat1 = input.color * _Color;
    output.color = u_xlat1 * PerDrawSpriteArray[u_xlati0.x / 2].unity_SpriteRendererColorArray;
    output.uv.xy = input.uv.xy;
    return output;
}

#endif

// Fragment inputs and render target.
struct SpriteFragmentInput
{
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
};

struct SpriteFragmentOutput
{
    float4 color : SV_Target0;
};

#if !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 1b294446dfef6f6085d0e8d0155d73a115457c4ba436c207b7be93170b0b9e2c
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color.w = u_xlat0.w;
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    output.color.xyz = u_xlat0.xyz + u_xlat0.xyz;
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// c4e6495c43415e266c517157e4aed3154cb8626577592effb5bc9d8dc939d04e
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color.w = u_xlat0.w;
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 94584ebeb7de4380b10232c10d59cbc6b0ddf12635b8e3be63b4b9ceabddc224
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    float u_xlat6;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color.w = u_xlat0.w;
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = u_xlat0.xyz + u_xlat0.xyz;
    u_xlat6 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = mad(u_xlat6, 0.850000024, -0.5);
    u_xlat6 = mad(u_xlat6, 1.35000002, 0.5);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat0.xyz = mad((-u_xlat0.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat6)));
    output.color.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat0.xyz, u_xlat1.xyz);
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 989bf065122780f51e65a162a6f703a051e2e1f7004421b94660857ebdd0f10d
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    float u_xlat6;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color.w = u_xlat0.w;
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    u_xlat0.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat6 = dot(u_xlat0.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = mad(u_xlat6, 0.850000024, -0.5);
    u_xlat6 = mad(u_xlat6, 1.35000002, 0.5);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat1.xyz = (-u_xlat0.xyz) + ((float3)(u_xlat6));
    output.color.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 671d3c58d88c3421f5249fac30dea6d287fc801908405a8747949659e6ccda62
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat0.xyz = u_xlat0.xyz + u_xlat0.xyz;
    u_xlat1.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_FlashAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.w = u_xlat0.w;
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 58b8d9cc843449083a07bbc0ca9438515b8222078bf77ca223096c9757b4e436
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    float u_xlat7;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = u_xlat0.xyz + u_xlat0.xyz;
    u_xlat7 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat7 = clamp(u_xlat7, 0.0f, 1.0f);
    u_xlat7 = mad(u_xlat7, 0.850000024, -0.5);
    u_xlat7 = mad(u_xlat7, 1.35000002, 0.5);
    u_xlat7 = max(u_xlat7, 0.0);
    u_xlat0.xyz = mad((-u_xlat0.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat7)));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat0.xyz, u_xlat1.xyz);
    u_xlat1.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_FlashAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.w = u_xlat0.w;
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// b9188c2917c4810a1ef0f026d044840654bdb1148c460127953781bf9c3e6d71
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat1 = u_xlat1 * input.color;
    u_xlat2.xyz = u_xlat1.www * u_xlat1.xyz;
    u_xlat2.xyz = u_xlat2.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = u_xlat2.xyz + u_xlat2.xyz;
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 52af2c4cce8190bd21faf361e3449393e9ea3be3d8546d1f294741b9ad9fb6d5
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat3;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat1 = u_xlat1 * input.color;
    u_xlat3.xyz = u_xlat1.www * u_xlat1.xyz;
    u_xlat2.xyz = u_xlat3.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat3.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat3.xyz);
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// c11667f6654bda1975d0f5a9559b2cc2e921f1c4c5ba144760f1900843d1f6f9
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float3 u_xlat1;
    float3 u_xlat2;
    float u_xlat10;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = u_xlat1.xyz + u_xlat1.xyz;
    u_xlat10 = dot(u_xlat2.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat1.xyz = mad((-u_xlat1.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat10)));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat2.xyz);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// c22ffa924bdc19f7fab1affffbdf88d1a92efe70b99d5123ed6e10780f4122a5
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float3 u_xlat1;
    float3 u_xlat2;
    float u_xlat10;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat2.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat1.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat10 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat2.xyz = (-u_xlat1.xyz) + ((float3)(u_xlat10));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 5db7eebf67ec0730c1e4469fc049d1d21f675e0414cfd4f2ecfd2b7a0877fcd9
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat3;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat1 = u_xlat1 * input.color;
    u_xlat3.xyz = u_xlat1.www * u_xlat1.xyz;
    u_xlat3.xyz = u_xlat3.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat3.xyz = u_xlat3.xyz + u_xlat3.xyz;
    u_xlat2.xyz = mad(_FlashColor.xyz, u_xlat1.www, (-u_xlat3.xyz));
    u_xlat1.xyz = mad(((float3)(_FlashAmount)), u_xlat2.xyz, u_xlat3.xyz);
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// b6726d0b825b08f005e272e48f52a057f1244e373a71c265dcf1083062290ea5
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float3 u_xlat1;
    float3 u_xlat2;
    float u_xlat10;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = u_xlat1.xyz + u_xlat1.xyz;
    u_xlat10 = dot(u_xlat2.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat1.xyz = mad((-u_xlat1.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat10)));
    u_xlat1.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat2.xyz);
    u_xlat2.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat1.xyz));
    u_xlat0.xyz = mad(((float3)(_FlashAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 0495c75f46e985c773cc7221bbe13e2f1f2f4cf8eefa6690007bb57fa8abad1c
// db7b89caa5dfa829945bdd74e1a140404d2f1f0a9ba23c7497450090ad412d80
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color.w = u_xlat0.w;
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    output.color.xyz = u_xlat0.xyz + u_xlat0.xyz;
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 5115d617156789fa09869d7d93e8cafc3c1b90bbbd8846aa8f1b2d38c42a10fe
// 8e5388912913ab199b00040d26cd775647eb381c84eeeeb8ebe1739b0b478939
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color.w = u_xlat0.w;
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 7e9dc683eb3e0712ae8b32772a4b9a8fa56df9e60b202b4b3d4f351a02a808da
// 92f67409fe2bf938ed730fbb217ca756702610096d1c47c8d492f637204f34cc
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color.w = u_xlat0.w;
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = u_xlat0.xyz + u_xlat0.xyz;
    u_xlat6 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = mad(u_xlat6, 0.850000024, -0.5);
    u_xlat6 = mad(u_xlat6, 1.35000002, 0.5);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat0.xyz = mad((-u_xlat0.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat6)));
    output.color.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat0.xyz, u_xlat1.xyz);
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 3209a1eb69f933a5cf71778c08217a64ad1eae1505d991a2e4b5da3668575fd5
// 3ab3093ba1bf03b5e97db1187090810166c82b471e6b3d5023bef5270ae0cf15
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color.w = u_xlat0.w;
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    u_xlat0.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat6 = dot(u_xlat0.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = mad(u_xlat6, 0.850000024, -0.5);
    u_xlat6 = mad(u_xlat6, 1.35000002, 0.5);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat1.xyz = (-u_xlat0.xyz) + ((float3)(u_xlat6));
    output.color.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 401269e788d05c5e22889b397e21b971d8376b02c26fb9e3d38647660deeaca7
// ad90c8e324870ba32236f6936fe44933510a0b1c373d337a4e6cdaf19d7009b0
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat0.xyz = u_xlat0.xyz + u_xlat0.xyz;
    u_xlat1.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_FlashAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.w = u_xlat0.w;
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 09f00c0e322bfffec966e90cd14e4c13136b0684d3f77ad6ffe0917ccf4e864c
// c5f053d36cd7c80865edaf04cd3b7f71c6bb4c65b75103d45a9833f172b8df89
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat7;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = u_xlat0.xyz + u_xlat0.xyz;
    u_xlat7 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat7 = clamp(u_xlat7, 0.0f, 1.0f);
    u_xlat7 = mad(u_xlat7, 0.850000024, -0.5);
    u_xlat7 = mad(u_xlat7, 1.35000002, 0.5);
    u_xlat7 = max(u_xlat7, 0.0);
    u_xlat0.xyz = mad((-u_xlat0.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat7)));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat0.xyz, u_xlat1.xyz);
    u_xlat1.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_FlashAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.w = u_xlat0.w;
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// bbd16842037f12c8f37ab585db3301d358f5c89d4e44f7ed85eb880c308dcc95
// cfdb184758909ac38fd0eaf38c142f6ba28753e9f08dd71f8ce6b202a351a672
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat2.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat2.x = u_xlat2.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat2.x, u_xlat1.w);
    u_xlat1 = u_xlat1 * input.color;
    u_xlat2.xyz = u_xlat1.www * u_xlat1.xyz;
    u_xlat2.xyz = u_xlat2.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = u_xlat2.xyz + u_xlat2.xyz;
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 06fcefafbee9359f5df7aa9d114f7b575a9a4c4ba10209d627a0476c5a6cadac
// 9f90948baa5026e54115e837ee0c10ebe5d39a1585c20d301f0a5d3e87c95d28
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat3;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat3.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat3.x = u_xlat3.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat3.x, u_xlat1.w);
    u_xlat1 = u_xlat1 * input.color;
    u_xlat3.xyz = u_xlat1.www * u_xlat1.xyz;
    u_xlat2.xyz = u_xlat3.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat3.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat3.xyz);
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 7b03e065fca52e48f4efd1b0e78242e26dc54ef05c179f5f3a303a45ec4d6789
// e335597995e8e8f0e1e303f75979f3ee8cb6eb5fd6b6728bc6825189e988303f
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float u_xlat10;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = u_xlat1.xyz + u_xlat1.xyz;
    u_xlat10 = dot(u_xlat2.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat1.xyz = mad((-u_xlat1.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat10)));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat2.xyz);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 41c79d9312d4a42e1aa97a187097d463b9ec98b64cdcc91440eec5c714fb6d67
// 715818e20d97e0f2f05629932b744b63455832c3e6e48139a753425da5f1acc9
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float u_xlat10;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat2.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat1.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat10 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat2.xyz = (-u_xlat1.xyz) + ((float3)(u_xlat10));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 73ccbf7c269328edd44fbec5f22281fec42065e99c5f22f2b5152e412fe80626
// a3e9d354f9a7770f201f27ad22e0b1c751d18c2221c65e5053cd4416b7ffc872
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = u_xlat1.xyz + u_xlat1.xyz;
    u_xlat2.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat1.xyz));
    u_xlat0.xyz = mad(((float3)(_FlashAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA)
// Captured fragment program SHA256:
// 90b1cc34469f1f82527990d18a7afda85c93fea089a3a259bdfec75bd8000477
// 94d9fc48f952bf0ecf4d64de746c9e62dae0a9302871f0083e62e63ba8b91e97
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float u_xlat10;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = u_xlat1.xyz + u_xlat1.xyz;
    u_xlat10 = dot(u_xlat2.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat1.xyz = mad((-u_xlat1.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat10)));
    u_xlat1.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat2.xyz);
    u_xlat2.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat1.xyz));
    u_xlat0.xyz = mad(((float3)(_FlashAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 242260458899f0610bed31a719127a8013ce2d51c1774724c97b59a2d171fce2
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    output.color.xyz = u_xlat0.xyz + u_xlat0.xyz;
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    output.color.w = u_xlat0.w;
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// a0c45f4274fca4c3c391ac85a1ccaf0069e1a538e2e3d3c3fa5f28d4fb79d65b
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    output.color.w = u_xlat0.w;
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// fea14a2417833163039ef1a20bb9a5fda2f880daede6c45561caf435a1f0263b
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    float u_xlat6;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    output.color.w = u_xlat0.w;
    u_xlat1.xyz = u_xlat0.xyz + u_xlat0.xyz;
    u_xlat6 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = mad(u_xlat6, 0.850000024, -0.5);
    u_xlat6 = mad(u_xlat6, 1.35000002, 0.5);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat0.xyz = mad((-u_xlat0.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat6)));
    output.color.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat0.xyz, u_xlat1.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 4c3c1497c44161ba11c80580334f38f191eb95b6bb3ae02ad8a01a1a283ff05b
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    float u_xlat6;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    output.color.w = u_xlat0.w;
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    u_xlat0.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat6 = dot(u_xlat0.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = mad(u_xlat6, 0.850000024, -0.5);
    u_xlat6 = mad(u_xlat6, 1.35000002, 0.5);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat1.xyz = (-u_xlat0.xyz) + ((float3)(u_xlat6));
    output.color.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// b1d32099e40be931d507d45efe791685a4f1914cd755b75c5be3ea6ef07801bd
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    u_xlat0.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat1.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_FlashAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    output.color.w = u_xlat0.w;
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// a3c03ca36d6c9b1a06b7d03098354090b64a34568c2f46e776e78b03fa943857
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    u_xlat0.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat1.x = dot(u_xlat0.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat1.x = mad(u_xlat1.x, 0.850000024, -0.5);
    u_xlat1.x = mad(u_xlat1.x, 1.35000002, 0.5);
    u_xlat1.x = max(u_xlat1.x, 0.0);
    u_xlat1.xyz = (-u_xlat0.xyz) + u_xlat1.xxx;
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat1.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_FlashAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    output.color.w = u_xlat0.w;
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// b0e55c1886247645a0121ae3dbf6501a590de2d92219f9d1252129b3ff6fe267
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat3;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat1 = u_xlat1 * input.color;
    u_xlat3.xyz = u_xlat1.www * u_xlat1.xyz;
    u_xlat3.x = dot(u_xlat3.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat3.x = clamp(u_xlat3.x, 0.0f, 1.0f);
    u_xlat2.xyz = mad(u_xlat1.xyz, u_xlat1.www, (-u_xlat3.xxx));
    u_xlat3.xyz = mad(((float3)(_SaturationLerp)), u_xlat2.xyz, u_xlat3.xxx);
    u_xlat3.xyz = u_xlat3.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = u_xlat3.xyz + u_xlat3.xyz;
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 80d4f52e17ebc6bb9233ad58b2fe9a8c63db01b46e98d2f5c37f91195de04f37
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat3;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat1 = u_xlat1 * input.color;
    u_xlat3.xyz = u_xlat1.www * u_xlat1.xyz;
    u_xlat3.x = dot(u_xlat3.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat3.x = clamp(u_xlat3.x, 0.0f, 1.0f);
    u_xlat2.xyz = mad(u_xlat1.xyz, u_xlat1.www, (-u_xlat3.xxx));
    u_xlat3.xyz = mad(((float3)(_SaturationLerp)), u_xlat2.xyz, u_xlat3.xxx);
    u_xlat2.xyz = u_xlat3.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat3.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat3.xyz);
    u_xlat1.xyz = clamp(u_xlat1.xyz, 0.0f, 1.0f);
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// c1c30ea873533da17cddf884c994b2aecb5523876c503c9cba85c2fd7b3e05eb
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float3 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat4;
    float u_xlat10;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat4.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat4.xyz, u_xlat1.xxx);
    u_xlat1.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = u_xlat1.xyz + u_xlat1.xyz;
    u_xlat10 = dot(u_xlat2.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat1.xyz = mad((-u_xlat1.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat10)));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat2.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 16b0cbf5a099cf27fe74dc34674e565397ae43a3290385b068b123d508941d05
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float3 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat4;
    float u_xlat10;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat4.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat4.xyz, u_xlat1.xxx);
    u_xlat2.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat1.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat10 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat2.xyz = (-u_xlat1.xyz) + ((float3)(u_xlat10));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 8c73884da3e433895852f366d846c221ab54683540eb9fc484bac7cc79c899c9
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float3 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat4;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat4.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat4.xyz, u_xlat1.xxx);
    u_xlat2.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat1.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat2.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat1.xyz));
    u_xlat0.xyz = mad(((float3)(_FlashAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(COLOR_FLASH) && defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 5b34a242102c754260c5d58176cba96547823262bbbbe978ceccbbf6b97b0d37
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float3 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat4;
    float u_xlat10;
    u_xlat0 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0 = u_xlat0 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat4.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat4.xyz, u_xlat1.xxx);
    u_xlat2.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat1.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat10 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat2.xyz = (-u_xlat1.xyz) + ((float3)(u_xlat10));
    u_xlat1.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat2.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat1.xyz));
    u_xlat0.xyz = mad(((float3)(_FlashAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 39c6e900dc20ed639da4734fc939f97b4727a2a7c9a3c7e76e76ebe8c5fc9b83
// 4725acb5d47187846e3e355538de3466e64ed7c09abe566bd981db708a02e25e
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    output.color.w = u_xlat0.w;
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    output.color.xyz = u_xlat0.xyz + u_xlat0.xyz;
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 6b4a38c85d697fc0dda0f9be26f745eac6d200fae4f73650c53e06f19e30ae8e
// c0c0e1ce435e826124050e9226f19b96678adf3341764b65c0a71872c54b297f
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    output.color.w = u_xlat0.w;
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 3e310f3b823715df733caa5f95fac7465ef8bf9f0430718a75b8acadd1c17994
// af66043e4e104be9d801bfb2377ce1ef4b7e1f54831dc84c6087d7e4206b60bd
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    output.color.w = u_xlat0.w;
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat0.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = u_xlat0.xyz + u_xlat0.xyz;
    u_xlat6 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = mad(u_xlat6, 0.850000024, -0.5);
    u_xlat6 = mad(u_xlat6, 1.35000002, 0.5);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat0.xyz = mad((-u_xlat0.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat6)));
    output.color.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat0.xyz, u_xlat1.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 33f17713364313fab5d3cb170e496a7ac0a53ce688d39eab766aa6a9f83a438f
// 63d0e0b161c7ede5d134527bc78005243558d5a4996732bf2a9f7797dbe3ea75
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat6;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    output.color.w = u_xlat0.w;
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    u_xlat0.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat6 = dot(u_xlat0.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat6 = clamp(u_xlat6, 0.0f, 1.0f);
    u_xlat6 = mad(u_xlat6, 0.850000024, -0.5);
    u_xlat6 = mad(u_xlat6, 1.35000002, 0.5);
    u_xlat6 = max(u_xlat6, 0.0);
    u_xlat1.xyz = (-u_xlat0.xyz) + ((float3)(u_xlat6));
    output.color.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 170974ee6039d10ae428d6aa0d5ac952113d9ab56b43b169dcca8d36b8181aee
// 233d6de8b5b2bfff4bff2a91dd0a0b442e5de7609787744d85e3abb78099732d
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    u_xlat0.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat1.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_FlashAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    output.color.w = u_xlat0.w;
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(COLOR_FLASH) && !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 409070763f026f23537ae37858e4c944432ab91c632fd046628ba6079c290fb9
// ccd6a64f20d59857d87108e1b8fc0085ec731c1d23b4e4237156e20b7265abff
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input)
{
    SpriteFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat0.xyz = mad(((float3)(_SaturationLerp)), u_xlat0.xyz, u_xlat1.xxx);
    u_xlat1.xyz = u_xlat0.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat1.xyz = mad(u_xlat1.xyz, float3(2.0, 2.0, 2.0), (-u_xlat0.xyz));
    u_xlat0.xyz = mad(((float3)(_AmbientLerp)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat1.x = dot(u_xlat0.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat1.x = mad(u_xlat1.x, 0.850000024, -0.5);
    u_xlat1.x = mad(u_xlat1.x, 1.35000002, 0.5);
    u_xlat1.x = max(u_xlat1.x, 0.0);
    u_xlat1.xyz = (-u_xlat0.xyz) + u_xlat1.xxx;
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat0.xyz);
    u_xlat1.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat0.xyz));
    output.color.xyz = mad(((float3)(_FlashAmount)), u_xlat1.xyz, u_xlat0.xyz);
    output.color.xyz = clamp(output.color.xyz, 0.0f, 1.0f);
    output.color.w = u_xlat0.w;
    return output;
}

#elif !defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 5ae99b8ae139d4d9b09b654d370f9b66db02f2aec2d209f56178b46140d88579
// e1dc76b8e2b9f0fa9865bd4aca5496812083122a6253d1e06d760004b508ec1e
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat3;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat3.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat3.xyz, u_xlat1.xxx);
    u_xlat1.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat0.xyz = u_xlat1.xyz + u_xlat1.xyz;
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 188221b1e5539866cd818afb2f602b5c7d50f0763a7f95096829129a90b0cf1b
// 7b8090ef92232d1d0f4bfa845b095b5c66a364272f3844b057a2b6ef89217a35
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat4;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat4.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat4.xyz, u_xlat1.xxx);
    u_xlat2.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat1.xyz));
    u_xlat0.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif !defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 0cc4c8dbfc2e1087da6b31cecec95e7affdc221352251ecac21cad86d876ab8d
// bff88a6887bfd3f43e778dee0191ffbddf585d0863f0491c824bac7544ad94d8
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat4;
    float u_xlat10;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat4.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat4.xyz, u_xlat1.xxx);
    u_xlat1.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = u_xlat1.xyz + u_xlat1.xyz;
    u_xlat10 = dot(u_xlat2.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat1.xyz = mad((-u_xlat1.xyz), float3(2.0, 2.0, 2.0), ((float3)(u_xlat10)));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat1.xyz, u_xlat2.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && !defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 240202c9fe9add13ea3b2d26a357f77eb9a2efd6c2ff0fdc78af53e2afd4dae7
// 37c7a3c27a95e3155328fdf7e18a754b82e39e591effb8c18d5375f431183848
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat4;
    float u_xlat10;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat4.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat4.xyz, u_xlat1.xxx);
    u_xlat2.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat1.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat10 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat2.xyz = (-u_xlat1.xyz) + ((float3)(u_xlat10));
    u_xlat0.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif defined(AMBIENT_LERP) && !defined(BLACKTHREAD) && defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 4423fda3bd7697574248596886e8bf76315de0654b559a2487117b6c75972f18
// dd73a09932f253548c34dda562903ba0219f43974c08caf0906f543fc7339ac1
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat4;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat4.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat4.xyz, u_xlat1.xxx);
    u_xlat2.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat1.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat2.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat1.xyz));
    u_xlat0.xyz = mad(((float3)(_FlashAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#elif defined(AMBIENT_LERP) && defined(BLACKTHREAD) && defined(COLOR_FLASH) && defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(SATURATION_LERP)
// Captured fragment program SHA256:
// 65af04a958153d231b555ce0befd97f9607da8bfd1ac4929b57138e9512969cc
// be944e13cf3442d997b3da48ab38e68f15b7e0bd9ef9ccc7fbdb6ff061f2dffe
SpriteFragmentOutput RecoveryFragment(SpriteFragmentInput input, float4 positionSS : SV_POSITION)
{
    SpriteFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float3 u_xlat4;
    float u_xlat10;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.uv.xy).x;
    u_xlat1 = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    u_xlat0.x = u_xlat0.x + (-u_xlat1.w);
    u_xlat1.w = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat1.w);
    u_xlat0 = u_xlat1 * input.color;
    u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat4.xyz = mad(u_xlat0.xyz, u_xlat0.www, (-u_xlat1.xxx));
    u_xlat1.xyz = mad(((float3)(_SaturationLerp)), u_xlat4.xyz, u_xlat1.xxx);
    u_xlat2.xyz = u_xlat1.xyz * glstate_lightmodel_ambient.xyz;
    u_xlat2.xyz = mad(u_xlat2.xyz, float3(2.0, 2.0, 2.0), (-u_xlat1.xyz));
    u_xlat1.xyz = mad(((float3)(_AmbientLerp)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat10 = dot(u_xlat1.xyz, float3(0.219999999, 0.707000017, 0.0710000023));
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat10 = mad(u_xlat10, 0.850000024, -0.5);
    u_xlat10 = mad(u_xlat10, 1.35000002, 0.5);
    u_xlat10 = max(u_xlat10, 0.0);
    u_xlat2.xyz = (-u_xlat1.xyz) + ((float3)(u_xlat10));
    u_xlat1.xyz = mad(((float3)(_BlackThreadAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat2.xyz = mad(_FlashColor.xyz, u_xlat0.www, (-u_xlat1.xyz));
    u_xlat0.xyz = mad(((float3)(_FlashAmount)), u_xlat2.xyz, u_xlat1.xyz);
    u_xlat0.xyz = clamp(u_xlat0.xyz, 0.0f, 1.0f);
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}

#endif

            ENDHLSL
        }
    }
    Fallback "Sprites/Diffuse"
}
