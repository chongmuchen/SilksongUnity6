// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Initial recovery: tools/shader_reconstruction/shaderlab_generator.py.
// Original serialized Shader SHA256: ab0e9b41fd0b8329e7172763d6db1523034f2277e7dc70b9013566521b3341c3
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Sprites/Tiled Scrolling Masked"
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
        _SpeedX ("Flow Rate X", Float) = 1
        _SpeedY ("Flow Rate Y", Float) = 1
        _WorldOffsetX ("World Offset X Amount", Float) = 0
        _WorldOffsetY ("World Offset Y Amount", Float) = 0
        _WorldOffsetZ ("World Offset Z Amount", Float) = 0
        [Toggle(LOCAL_SPACE_X)] _UseLocalSpaceX ("Local Space X", Float) = 0
        [Toggle(LOCAL_SPACE_Y)] _UseLocalSpaceY ("Local Space Y", Float) = 0
        [PerRendererData] _FogRotation ("Fog Rotation", Float) = 0
        [Toggle(WORLD_SCALE_FLIP)] _EnableWorldScaleFlip ("Enable World Scale Flip", Float) = 1
        [Toggle(SILHOUETTE)] _EnableSilhouette ("Is Silhouette", Float) = 0
        [Toggle(HERO_MASK)] _EnableHeroMask ("Use Hero Mask", Float) = 0
        _HeroMaskTex ("Hero Mask Texture", 2D) = "white" {}
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
#pragma multi_compile __ HERO_MASK
#pragma multi_compile __ LOCAL_SPACE_X SILHOUETTE
#pragma multi_compile __ PIXELSNAP_ON
#pragma multi_compile __ WORLD_SCALE_FLIP
#pragma multi_compile_instancing
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

#if !defined(INSTANCING_ON)
float _FogRotation;
#endif

#if defined(HERO_MASK) && defined(SILHOUETTE)
Texture2D<float4> _HeroMaskTex;
float4 _HeroMaskTex_ST;
float _HeroPlayMode;
float2 _HeroWorldPos;
#endif

Texture2D<float4> _MainTex;
Texture2D<float4> _ScrollTex;
float4 _ScrollTex_ST;
float _SpeedX;
float _SpeedY;
float _WorldOffsetX;
float _WorldOffsetY;
float _WorldOffsetZ;

#if defined(INSTANCING_ON)
UNITY_INSTANCING_BUFFER_START(PerDrawSprite)
    UNITY_DEFINE_INSTANCED_PROP(float4, unity_SpriteRendererColorArray)
    UNITY_DEFINE_INSTANCED_PROP(float2, unity_SpriteFlipArray)
UNITY_INSTANCING_BUFFER_END(PerDrawSprite)
UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float, _FogRotation)
UNITY_INSTANCING_BUFFER_END(Props)
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

#if defined(HERO_MASK) && defined(SILHOUETTE)
SamplerState sampler_HeroMaskTex;
#endif

SamplerState sampler_MainTex;
SamplerState sampler_ScrollTex;

// Vertex interface.
#if defined(INSTANCING_ON)
struct MaskedVertexInput
{
    float4 positionOS : POSITION0;
    float4 color : COLOR0;
    float2 spriteUv : TEXCOORD0;
    uint instanceID : SV_InstanceID;
};
#endif

#if !defined(INSTANCING_ON)
struct MaskedVertexInput
{
    float4 positionOS : POSITION0;
    float4 color : COLOR0;
    float2 spriteUv : TEXCOORD0;
};
#endif

#if (!defined(HERO_MASK)) || (!defined(SILHOUETTE))
struct MaskedVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;
    float2 spriteUv : TEXCOORD0;
    float2 scrollUv : TEXCOORD1;
};
#endif

#if defined(HERO_MASK) && defined(SILHOUETTE)
struct MaskedVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;
    float2 spriteUv : TEXCOORD0;
    float2 scrollUv : TEXCOORD1;
    float2 heroMaskUv : TEXCOORD2;
};
#endif

// Vertex programs, shared across fragment variants.
#if (!defined(HERO_MASK) && !defined(LOCAL_SPACE_X) && !defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON)) || (!defined(HERO_MASK) && defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON)) || (!defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON))
// Captured vertex program SHA256:
// 33330cba4535be908234bf190e8965d7f1d81e365b3372c0542ccadf8ecb873d
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{

    MaskedVertexOutput output;
    float u_xlat0;
    int u_xlati0;
    float u_xlat1;
    float4 u_xlat2;
    int2 u_xlati2;
    float4 u_xlat3;
    float3 u_xlat4;
    int3 u_xlati4;
    float2 u_xlat5;
    float u_xlat8;
    float2 u_xlat9;
    float u_xlat12;
    u_xlati0 = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati4.xy = ((int2)(u_xlati0)) << int2(0x1, 0x3);
    u_xlat0 = sin(PropsArray[u_xlati0]._FogRotation);
    u_xlat1 = cos(PropsArray[u_xlati0]._FogRotation);
    u_xlat5.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati4.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat2 = u_xlat5.yyyy * transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[0], u_xlat5.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat2);
    u_xlat3 = u_xlat2 + transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat5.xy = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].xy, input.positionOS.ww, u_xlat2.xy);
    u_xlat2 = u_xlat3.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat3.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat3.zzzz, u_xlat2);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat3.wwww, u_xlat2);
    u_xlat2 = input.color * _Color;
    output.color = u_xlat2 * PerDrawSpriteArray[u_xlati4.x / 2].unity_SpriteRendererColorArray;
    u_xlat4.xz = transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[0].xy + transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[1].xy;
    u_xlat4.xz = u_xlat4.xz + transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[2].xy;
    u_xlati2.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat4.xz))) * 0xFFFFFFFFu));
    u_xlati4.xz = ((int2)(((uint2)((u_xlat4.xz<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati4.xz = (-u_xlati2.xy) + u_xlati4.xz;
    u_xlat4.xz = ((float2)(u_xlati4.xz));
    u_xlat4.xz = u_xlat4.xz * u_xlat5.xy;
    u_xlat2.z = u_xlat0;
    u_xlat2.y = u_xlat1;
    u_xlat2.x = (-u_xlat0);
    u_xlat0 = dot(u_xlat4.xz, u_xlat2.xy);
    u_xlat4.x = dot(u_xlat4.xz, u_xlat2.yz);
    u_xlat12 = dot(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat8 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].z, _WorldOffsetZ, u_xlat12);
    u_xlat8 = u_xlat8 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat8, u_xlat4.x);
    u_xlat9.y = mad(_SpeedY, u_xlat8, u_xlat0);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (!defined(HERO_MASK) && !defined(LOCAL_SPACE_X) && defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON)) || (!defined(HERO_MASK) && defined(SILHOUETTE) && defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON)) || (!defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON))
// Captured vertex program SHA256:
// 5d82dc0f3867771384eb611002b42d7d5fc4e8faed3dbd95efce5e940f9b5432
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    int2 u_xlati8;
    float2 u_xlat9;
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
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat0.x = dot(u_xlat0.xy, u_xlat3.yz);
    u_xlat4 = dot(transpose(unity_ObjectToWorld)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_ObjectToWorld)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat4, u_xlat0.x);
    u_xlat9.y = mad(_SpeedY, u_xlat4, u_xlat8.x);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (!defined(HERO_MASK) && !defined(LOCAL_SPACE_X) && defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON)) || (!defined(HERO_MASK) && defined(SILHOUETTE) && defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON)) || (!defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON))
// Captured vertex program SHA256:
// ec4229682df8b9fdd5bf0ce1fd8273aed65cfddcf633832983dd938eddfade74
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{

    MaskedVertexOutput output;
    float u_xlat0;
    int u_xlati0;
    float u_xlat1;
    float4 u_xlat2;
    int2 u_xlati2;
    float4 u_xlat3;
    float3 u_xlat4;
    int3 u_xlati4;
    float2 u_xlat5;
    float u_xlat8;
    float2 u_xlat9;
    float u_xlat12;
    u_xlati0 = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati4.xy = ((int2)(u_xlati0)) << int2(0x1, 0x3);
    u_xlat0 = sin(PropsArray[u_xlati0]._FogRotation);
    u_xlat1 = cos(PropsArray[u_xlati0]._FogRotation);
    u_xlat5.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati4.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat2 = u_xlat5.yyyy * transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[0], u_xlat5.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat2);
    u_xlat3 = u_xlat2 + transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat5.xy = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].xy, input.positionOS.ww, u_xlat2.xy);
    u_xlat2 = u_xlat3.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat3.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat3.zzzz, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[3], u_xlat3.wwww, u_xlat2);
    u_xlat2.xy = u_xlat2.xy / u_xlat2.ww;
    u_xlat3.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat2.xy = u_xlat2.xy * u_xlat3.xy;
    u_xlat2.xy = round(u_xlat2.xy);
    u_xlat2.xy = u_xlat2.xy / u_xlat3.xy;
    output.positionCS.xy = u_xlat2.ww * u_xlat2.xy;
    output.positionCS.zw = u_xlat2.zw;
    u_xlat2 = input.color * _Color;
    output.color = u_xlat2 * PerDrawSpriteArray[u_xlati4.x / 2].unity_SpriteRendererColorArray;
    u_xlat4.xz = transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[0].xy + transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[1].xy;
    u_xlat4.xz = u_xlat4.xz + transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[2].xy;
    u_xlati2.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat4.xz))) * 0xFFFFFFFFu));
    u_xlati4.xz = ((int2)(((uint2)((u_xlat4.xz<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati4.xz = (-u_xlati2.xy) + u_xlati4.xz;
    u_xlat4.xz = ((float2)(u_xlati4.xz));
    u_xlat4.xz = u_xlat4.xz * u_xlat5.xy;
    u_xlat2.z = u_xlat0;
    u_xlat2.y = u_xlat1;
    u_xlat2.x = (-u_xlat0);
    u_xlat0 = dot(u_xlat4.xz, u_xlat2.xy);
    u_xlat4.x = dot(u_xlat4.xz, u_xlat2.yz);
    u_xlat12 = dot(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat8 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].z, _WorldOffsetZ, u_xlat12);
    u_xlat8 = u_xlat8 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat8, u_xlat4.x);
    u_xlat9.y = mad(_SpeedY, u_xlat8, u_xlat0);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (!defined(HERO_MASK) && !defined(LOCAL_SPACE_X) && !defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON)) || (!defined(HERO_MASK) && defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON)) || (!defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON))
// Captured vertex program SHA256:
// fe50f10bc30904c7809312a5a064bd47a19106832846d419f5a3be6eebbe7983
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    int2 u_xlati8;
    float2 u_xlat9;
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
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat0.x = dot(u_xlat0.xy, u_xlat3.yz);
    u_xlat4 = dot(transpose(unity_ObjectToWorld)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_ObjectToWorld)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat4, u_xlat0.x);
    u_xlat9.y = mad(_SpeedY, u_xlat4, u_xlat8.x);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if defined(HERO_MASK) && defined(SILHOUETTE) && defined(PIXELSNAP_ON) && !defined(INSTANCING_ON)
// Captured vertex program SHA256:
// 791971212dda41483e52af41772d4a08a4f21b2b852a7ccc585168c881e13b20
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    float2 u_xlat9;
    int2 u_xlati9;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[3].xyxy, input.positionOS.wwww, u_xlat0.xyxy);
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    u_xlat1 = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat1.xy = u_xlat1.xy / u_xlat1.ww;
    u_xlat2.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat1.xy = u_xlat1.xy * u_xlat2.xy;
    u_xlat1.xy = round(u_xlat1.xy);
    u_xlat1.xy = u_xlat1.xy / u_xlat2.xy;
    output.positionCS.xy = u_xlat1.ww * u_xlat1.xy;
    output.positionCS.zw = u_xlat1.zw;
    u_xlat1 = input.color * _Color;
    output.color = u_xlat1 * _RendererColor;
    u_xlat1.xy = transpose(unity_ObjectToWorld)[0].xy + transpose(unity_ObjectToWorld)[1].xy;
    u_xlat1.xy = u_xlat1.xy + transpose(unity_ObjectToWorld)[2].xy;
    u_xlati9.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati1.xy = (-u_xlati9.xy) + u_xlati1.xy;
    u_xlat1.xy = ((float2)(u_xlati1.xy));
    u_xlat0.xy = u_xlat0.xy * u_xlat1.xy;
    u_xlat8.xy = u_xlat0.zw + (-_HeroWorldPos.xyxx.xy);
    u_xlat1.x = sin(_FogRotation);
    u_xlat2.x = cos(_FogRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat1.x = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat0.x = dot(u_xlat0.xy, u_xlat3.yz);
    u_xlat4 = dot(transpose(unity_ObjectToWorld)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_ObjectToWorld)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat4, u_xlat0.x);
    u_xlat9.y = mad(_SpeedY, u_xlat4, u_xlat1.x);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    u_xlat0.xy = float2(0.5, 0.5) / _HeroMaskTex_ST.xy;
    u_xlat0.xy = u_xlat0.xy + u_xlat8.xy;
    u_xlat0.xy = u_xlat0.xy + (-_HeroMaskTex_ST.zw);
    output.heroMaskUv.xy = u_xlat0.xy * _HeroMaskTex_ST.xy;
    return output;
}
#endif

#if defined(HERO_MASK) && defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && !defined(INSTANCING_ON)
// Captured vertex program SHA256:
// a3957908f5a66a2e65d3e635885e66614468bb17fe7826767ada74a7a06a74db
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    int2 u_xlati1;
    float4 u_xlat2;
    float3 u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    float2 u_xlat9;
    int2 u_xlati9;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[3].xyxy, input.positionOS.wwww, u_xlat0.xyxy);
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat1 = input.color * _Color;
    output.color = u_xlat1 * _RendererColor;
    u_xlat1.xy = transpose(unity_ObjectToWorld)[0].xy + transpose(unity_ObjectToWorld)[1].xy;
    u_xlat1.xy = u_xlat1.xy + transpose(unity_ObjectToWorld)[2].xy;
    u_xlati9.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat1.xy))) * 0xFFFFFFFFu));
    u_xlati1.xy = ((int2)(((uint2)((u_xlat1.xy<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati1.xy = (-u_xlati9.xy) + u_xlati1.xy;
    u_xlat1.xy = ((float2)(u_xlati1.xy));
    u_xlat0.xy = u_xlat0.xy * u_xlat1.xy;
    u_xlat8.xy = u_xlat0.zw + (-_HeroWorldPos.xyxx.xy);
    u_xlat1.x = sin(_FogRotation);
    u_xlat2.x = cos(_FogRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat1.x = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat0.x = dot(u_xlat0.xy, u_xlat3.yz);
    u_xlat4 = dot(transpose(unity_ObjectToWorld)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_ObjectToWorld)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat4, u_xlat0.x);
    u_xlat9.y = mad(_SpeedY, u_xlat4, u_xlat1.x);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    u_xlat0.xy = float2(0.5, 0.5) / _HeroMaskTex_ST.xy;
    u_xlat0.xy = u_xlat0.xy + u_xlat8.xy;
    u_xlat0.xy = u_xlat0.xy + (-_HeroMaskTex_ST.zw);
    output.heroMaskUv.xy = u_xlat0.xy * _HeroMaskTex_ST.xy;
    return output;
}
#endif

#if defined(HERO_MASK) && defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && defined(INSTANCING_ON)
// Captured vertex program SHA256:
// aea8db2e3ed41e71bd11ad3d7d7876194d276792f16be560c0bb9af7801fd395
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{

    MaskedVertexOutput output;
    float2 u_xlat0;
    int u_xlati0;
    float u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    float3 u_xlat5;
    int3 u_xlati5;
    float2 u_xlat6;
    int2 u_xlati6;
    float u_xlat10;
    float2 u_xlat12;
    float u_xlat15;
    u_xlati0 = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati5.xy = ((int2)(u_xlati0)) << int2(0x1, 0x3);
    u_xlat0.x = sin(PropsArray[u_xlati0]._FogRotation);
    u_xlat1 = cos(PropsArray[u_xlati0]._FogRotation);
    u_xlat6.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati5.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat2 = u_xlat6.yyyy * transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[0], u_xlat6.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat2);
    u_xlat3 = u_xlat2 + transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].xyxy, input.positionOS.wwww, u_xlat2.xyxy);
    u_xlat4 = u_xlat3.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat4 = mad(transpose(unity_MatrixVP)[0], u_xlat3.xxxx, u_xlat4);
    u_xlat4 = mad(transpose(unity_MatrixVP)[2], u_xlat3.zzzz, u_xlat4);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat3.wwww, u_xlat4);
    u_xlat3 = input.color * _Color;
    output.color = u_xlat3 * PerDrawSpriteArray[u_xlati5.x / 2].unity_SpriteRendererColorArray;
    u_xlat5.xz = transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[0].xy + transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[1].xy;
    u_xlat5.xz = u_xlat5.xz + transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[2].xy;
    u_xlati6.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat5.xz))) * 0xFFFFFFFFu));
    u_xlati5.xz = ((int2)(((uint2)((u_xlat5.xz<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati5.xz = (-u_xlati6.xy) + u_xlati5.xz;
    u_xlat5.xz = ((float2)(u_xlati5.xz));
    u_xlat5.xz = u_xlat5.xz * u_xlat2.xy;
    u_xlat6.xy = u_xlat2.zw + (-_HeroWorldPos.xyxx.xy);
    u_xlat2.z = u_xlat0.x;
    u_xlat2.y = u_xlat1;
    u_xlat2.x = (-u_xlat0.x);
    u_xlat0.x = dot(u_xlat5.xz, u_xlat2.xy);
    u_xlat5.x = dot(u_xlat5.xz, u_xlat2.yz);
    u_xlat15 = dot(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat10 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].z, _WorldOffsetZ, u_xlat15);
    u_xlat10 = u_xlat10 + _Time.y;
    u_xlat12.x = mad(_SpeedX, u_xlat10, u_xlat5.x);
    u_xlat12.y = mad(_SpeedY, u_xlat10, u_xlat0.x);
    output.scrollUv.xy = mad(u_xlat12.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    u_xlat0.xy = float2(0.5, 0.5) / _HeroMaskTex_ST.xy;
    u_xlat0.xy = u_xlat0.xy + u_xlat6.xy;
    u_xlat0.xy = u_xlat0.xy + (-_HeroMaskTex_ST.zw);
    output.heroMaskUv.xy = u_xlat0.xy * _HeroMaskTex_ST.xy;
    return output;
}
#endif

#if defined(HERO_MASK) && defined(SILHOUETTE) && defined(PIXELSNAP_ON) && defined(INSTANCING_ON)
// Captured vertex program SHA256:
// e8ea54dd0f6e797055c465abb54006b5bc55ec1a8df17e2f4e6a02948481fa04
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{

    MaskedVertexOutput output;
    float2 u_xlat0;
    int u_xlati0;
    float u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    float3 u_xlat5;
    int3 u_xlati5;
    float2 u_xlat6;
    int2 u_xlati6;
    float u_xlat10;
    float2 u_xlat12;
    float u_xlat15;
    u_xlati0 = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati5.xy = ((int2)(u_xlati0)) << int2(0x1, 0x3);
    u_xlat0.x = sin(PropsArray[u_xlati0]._FogRotation);
    u_xlat1 = cos(PropsArray[u_xlati0]._FogRotation);
    u_xlat6.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati5.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat2 = u_xlat6.yyyy * transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[0], u_xlat6.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat2);
    u_xlat3 = u_xlat2 + transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].xyxy, input.positionOS.wwww, u_xlat2.xyxy);
    u_xlat4 = u_xlat3.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat4 = mad(transpose(unity_MatrixVP)[0], u_xlat3.xxxx, u_xlat4);
    u_xlat4 = mad(transpose(unity_MatrixVP)[2], u_xlat3.zzzz, u_xlat4);
    u_xlat3 = mad(transpose(unity_MatrixVP)[3], u_xlat3.wwww, u_xlat4);
    u_xlat6.xy = u_xlat3.xy / u_xlat3.ww;
    u_xlat3.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat6.xy = u_xlat6.xy * u_xlat3.xy;
    u_xlat6.xy = round(u_xlat6.xy);
    u_xlat6.xy = u_xlat6.xy / u_xlat3.xy;
    output.positionCS.xy = u_xlat3.ww * u_xlat6.xy;
    output.positionCS.zw = u_xlat3.zw;
    u_xlat3 = input.color * _Color;
    output.color = u_xlat3 * PerDrawSpriteArray[u_xlati5.x / 2].unity_SpriteRendererColorArray;
    u_xlat5.xz = transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[0].xy + transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[1].xy;
    u_xlat5.xz = u_xlat5.xz + transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[2].xy;
    u_xlati6.xy = ((int2)(((uint2)((float2(0.0, 0.0)<u_xlat5.xz))) * 0xFFFFFFFFu));
    u_xlati5.xz = ((int2)(((uint2)((u_xlat5.xz<float2(0.0, 0.0)))) * 0xFFFFFFFFu));
    u_xlati5.xz = (-u_xlati6.xy) + u_xlati5.xz;
    u_xlat5.xz = ((float2)(u_xlati5.xz));
    u_xlat5.xz = u_xlat5.xz * u_xlat2.xy;
    u_xlat6.xy = u_xlat2.zw + (-_HeroWorldPos.xyxx.xy);
    u_xlat2.z = u_xlat0.x;
    u_xlat2.y = u_xlat1;
    u_xlat2.x = (-u_xlat0.x);
    u_xlat0.x = dot(u_xlat5.xz, u_xlat2.xy);
    u_xlat5.x = dot(u_xlat5.xz, u_xlat2.yz);
    u_xlat15 = dot(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat10 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].z, _WorldOffsetZ, u_xlat15);
    u_xlat10 = u_xlat10 + _Time.y;
    u_xlat12.x = mad(_SpeedX, u_xlat10, u_xlat5.x);
    u_xlat12.y = mad(_SpeedY, u_xlat10, u_xlat0.x);
    output.scrollUv.xy = mad(u_xlat12.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    u_xlat0.xy = float2(0.5, 0.5) / _HeroMaskTex_ST.xy;
    u_xlat0.xy = u_xlat0.xy + u_xlat6.xy;
    u_xlat0.xy = u_xlat0.xy + (-_HeroMaskTex_ST.zw);
    output.heroMaskUv.xy = u_xlat0.xy * _HeroMaskTex_ST.xy;
    return output;
}
#endif

#if (!defined(HERO_MASK) && !defined(LOCAL_SPACE_X) && !defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON)) || (!defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON))
// Captured vertex program SHA256:
// 174dc4b04810fb97828393a7e5e35daa0793a2c703e66e2361b98c1662f49961
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float3 u_xlat3;
    float u_xlat4;
    float u_xlat8;
    float2 u_xlat9;
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
    u_xlat8 = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat0.x = dot(u_xlat0.xy, u_xlat3.yz);
    u_xlat4 = dot(transpose(unity_ObjectToWorld)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_ObjectToWorld)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat4, u_xlat0.x);
    u_xlat9.y = mad(_SpeedY, u_xlat4, u_xlat8);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (!defined(HERO_MASK) && !defined(LOCAL_SPACE_X) && defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON)) || (!defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON))
// Captured vertex program SHA256:
// 2a5e2c6426a7313ecf9c01ff1b2015b4e37b97648f83c908cee985aa2b1fc9c9
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float3 u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    float2 u_xlat9;
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
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat0.x = dot(u_xlat0.xy, u_xlat3.yz);
    u_xlat4 = dot(transpose(unity_ObjectToWorld)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_ObjectToWorld)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat4, u_xlat0.x);
    u_xlat9.y = mad(_SpeedY, u_xlat4, u_xlat8.x);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (!defined(HERO_MASK) && !defined(LOCAL_SPACE_X) && !defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON)) || (!defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON))
// Captured vertex program SHA256:
// 3d2b66d09ee9d1476a0ce0abb3981171800c8a437d4110d5862a8b27ba8662a5
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{

    MaskedVertexOutput output;
    float u_xlat0;
    int u_xlati0;
    float u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float u_xlat4;
    int2 u_xlati4;
    float2 u_xlat5;
    float2 u_xlat8;
    u_xlati0 = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati4.xy = ((int2)(u_xlati0)) << int2(0x1, 0x3);
    u_xlat0 = sin(PropsArray[u_xlati0]._FogRotation);
    u_xlat1 = cos(PropsArray[u_xlati0]._FogRotation);
    u_xlat5.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati4.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat2 = u_xlat5.yyyy * transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[0], u_xlat5.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat2);
    u_xlat3 = u_xlat2 + transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat5.xy = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].xy, input.positionOS.ww, u_xlat2.xy);
    u_xlat2 = u_xlat3.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat3.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat3.zzzz, u_xlat2);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat3.wwww, u_xlat2);
    u_xlat2 = input.color * _Color;
    output.color = u_xlat2 * PerDrawSpriteArray[u_xlati4.x / 2].unity_SpriteRendererColorArray;
    u_xlat4 = dot(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat2.z = u_xlat0;
    u_xlat2.y = u_xlat1;
    u_xlat2.x = (-u_xlat0);
    u_xlat0 = dot(u_xlat5.xy, u_xlat2.xy);
    u_xlat8.x = dot(u_xlat5.xy, u_xlat2.yz);
    u_xlat8.x = mad(_SpeedX, u_xlat4, u_xlat8.x);
    u_xlat8.y = mad(_SpeedY, u_xlat4, u_xlat0);
    output.scrollUv.xy = mad(u_xlat8.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (!defined(HERO_MASK) && !defined(LOCAL_SPACE_X) && defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON)) || (!defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON))
// Captured vertex program SHA256:
// bb692ccc3e2d64adef042ddf8dbc9cf4bfa9613e154c7a4abb9e5fced2f16498
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{

    MaskedVertexOutput output;
    float u_xlat0;
    int u_xlati0;
    float u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float u_xlat4;
    int2 u_xlati4;
    float2 u_xlat5;
    float2 u_xlat8;
    u_xlati0 = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati4.xy = ((int2)(u_xlati0)) << int2(0x1, 0x3);
    u_xlat0 = sin(PropsArray[u_xlati0]._FogRotation);
    u_xlat1 = cos(PropsArray[u_xlati0]._FogRotation);
    u_xlat5.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati4.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat2 = u_xlat5.yyyy * transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[0], u_xlat5.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat2);
    u_xlat3 = u_xlat2 + transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat5.xy = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].xy, input.positionOS.ww, u_xlat2.xy);
    u_xlat2 = u_xlat3.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat3.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat3.zzzz, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[3], u_xlat3.wwww, u_xlat2);
    u_xlat2.xy = u_xlat2.xy / u_xlat2.ww;
    u_xlat3.xy = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat2.xy = u_xlat2.xy * u_xlat3.xy;
    u_xlat2.xy = round(u_xlat2.xy);
    u_xlat2.xy = u_xlat2.xy / u_xlat3.xy;
    output.positionCS.xy = u_xlat2.ww * u_xlat2.xy;
    output.positionCS.zw = u_xlat2.zw;
    u_xlat2 = input.color * _Color;
    output.color = u_xlat2 * PerDrawSpriteArray[u_xlati4.x / 2].unity_SpriteRendererColorArray;
    u_xlat4 = dot(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_Builtins0Array[u_xlati4.y / 8].unity_ObjectToWorldArray)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat2.z = u_xlat0;
    u_xlat2.y = u_xlat1;
    u_xlat2.x = (-u_xlat0);
    u_xlat0 = dot(u_xlat5.xy, u_xlat2.xy);
    u_xlat8.x = dot(u_xlat5.xy, u_xlat2.yz);
    u_xlat8.x = mad(_SpeedX, u_xlat4, u_xlat8.x);
    u_xlat8.y = mad(_SpeedY, u_xlat4, u_xlat0);
    output.scrollUv.xy = mad(u_xlat8.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && defined(INSTANCING_ON)) || (!defined(HERO_MASK) && defined(LOCAL_SPACE_X) && !defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON))
// Captured vertex program SHA256:
// 080aa54de7be81c7523e4712ff4fd770ddd9376501c0996cb169b141b4930f9e
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{

    MaskedVertexOutput output;
    float u_xlat0;
    int u_xlati0;
    float u_xlat1;
    float3 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    float u_xlat5;
    int2 u_xlati5;
    float2 u_xlat10;
    u_xlati0 = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati5.xy = ((int2)(u_xlati0)) << int2(0x1, 0x3);
    u_xlat0 = sin(PropsArray[u_xlati0]._FogRotation);
    u_xlat1 = cos(PropsArray[u_xlati0]._FogRotation);
    u_xlat2.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati5.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat3 = u_xlat2.yyyy * transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat3 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[0], u_xlat2.xxxx, u_xlat3);
    u_xlat3 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat3);
    u_xlat4 = u_xlat3 + transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat2.z = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].y, input.positionOS.w, u_xlat3.y);
    u_xlat3 = u_xlat4.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat3 = mad(transpose(unity_MatrixVP)[0], u_xlat4.xxxx, u_xlat3);
    u_xlat3 = mad(transpose(unity_MatrixVP)[2], u_xlat4.zzzz, u_xlat3);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat4.wwww, u_xlat3);
    u_xlat3 = input.color * _Color;
    output.color = u_xlat3 * PerDrawSpriteArray[u_xlati5.x / 2].unity_SpriteRendererColorArray;
    u_xlat5 = dot(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat5 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].z, _WorldOffsetZ, u_xlat5);
    u_xlat5 = u_xlat5 + _Time.y;
    u_xlat3.z = u_xlat0;
    u_xlat3.y = u_xlat1;
    u_xlat3.x = (-u_xlat0);
    u_xlat0 = dot(u_xlat2.xz, u_xlat3.xy);
    u_xlat10.x = dot(u_xlat2.xz, u_xlat3.yz);
    u_xlat10.x = mad(_SpeedX, u_xlat5, u_xlat10.x);
    u_xlat10.y = mad(_SpeedY, u_xlat5, u_xlat0);
    output.scrollUv.xy = mad(u_xlat10.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && defined(PIXELSNAP_ON) && defined(INSTANCING_ON)) || (!defined(HERO_MASK) && defined(LOCAL_SPACE_X) && defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && defined(INSTANCING_ON))
// Captured vertex program SHA256:
// 0974d60d2c57190f110221185a52d8257ebf2f434922520bf6680340211a026b
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{

    MaskedVertexOutput output;
    float u_xlat0;
    int u_xlati0;
    float u_xlat1;
    float3 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    float u_xlat5;
    int2 u_xlati5;
    float2 u_xlat6;
    float3 u_xlat7;
    float2 u_xlat10;
    u_xlati0 = int(input.instanceID) + unity_BaseInstanceID;
    u_xlati5.xy = ((int2)(u_xlati0)) << int2(0x1, 0x3);
    u_xlat0 = sin(PropsArray[u_xlati0]._FogRotation);
    u_xlat1 = cos(PropsArray[u_xlati0]._FogRotation);
    u_xlat2.xy = input.positionOS.xy * PerDrawSpriteArray[u_xlati5.x / 2].unity_SpriteFlipArray.xyxx.xy;
    u_xlat3 = u_xlat2.yyyy * transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[1];
    u_xlat3 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[0], u_xlat2.xxxx, u_xlat3);
    u_xlat3 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, u_xlat3);
    u_xlat4 = u_xlat3 + transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3];
    u_xlat2.z = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].y, input.positionOS.w, u_xlat3.y);
    u_xlat3 = u_xlat4.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat3 = mad(transpose(unity_MatrixVP)[0], u_xlat4.xxxx, u_xlat3);
    u_xlat3 = mad(transpose(unity_MatrixVP)[2], u_xlat4.zzzz, u_xlat3);
    u_xlat3 = mad(transpose(unity_MatrixVP)[3], u_xlat4.wwww, u_xlat3);
    u_xlat6.xy = u_xlat3.xy / u_xlat3.ww;
    u_xlat7.xz = _ScreenParams.xy * float2(0.5, 0.5);
    u_xlat6.xy = u_xlat6.xy * u_xlat7.xz;
    u_xlat6.xy = round(u_xlat6.xy);
    u_xlat6.xy = u_xlat6.xy / u_xlat7.xz;
    output.positionCS.xy = u_xlat3.ww * u_xlat6.xy;
    output.positionCS.zw = u_xlat3.zw;
    u_xlat3 = input.color * _Color;
    output.color = u_xlat3 * PerDrawSpriteArray[u_xlati5.x / 2].unity_SpriteRendererColorArray;
    u_xlat5 = dot(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat5 = mad(transpose(unity_Builtins0Array[u_xlati5.y / 8].unity_ObjectToWorldArray)[3].z, _WorldOffsetZ, u_xlat5);
    u_xlat5 = u_xlat5 + _Time.y;
    u_xlat3.z = u_xlat0;
    u_xlat3.y = u_xlat1;
    u_xlat3.x = (-u_xlat0);
    u_xlat0 = dot(u_xlat2.xz, u_xlat3.xy);
    u_xlat10.x = dot(u_xlat2.xz, u_xlat3.yz);
    u_xlat10.x = mad(_SpeedX, u_xlat5, u_xlat10.x);
    u_xlat10.y = mad(_SpeedY, u_xlat5, u_xlat0);
    output.scrollUv.xy = mad(u_xlat10.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && defined(PIXELSNAP_ON) && !defined(INSTANCING_ON)) || (!defined(HERO_MASK) && defined(LOCAL_SPACE_X) && defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON))
// Captured vertex program SHA256:
// 5c20616c02083a0e4202c9a2f1f1f4fabec1cd79dda203490d534d63919838ff
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float3 u_xlat3;
    float u_xlat4;
    float2 u_xlat8;
    float2 u_xlat9;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat0.y = mad(transpose(unity_ObjectToWorld)[3].y, input.positionOS.w, u_xlat0.y);
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
    u_xlat0.x = input.positionOS.x;
    u_xlat1.x = sin(_FogRotation);
    u_xlat2.x = cos(_FogRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat8.x = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat0.x = dot(u_xlat0.xy, u_xlat3.yz);
    u_xlat4 = dot(transpose(unity_ObjectToWorld)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_ObjectToWorld)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat4, u_xlat0.x);
    u_xlat9.y = mad(_SpeedY, u_xlat4, u_xlat8.x);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

#if (defined(LOCAL_SPACE_X) && !defined(SILHOUETTE) && !defined(PIXELSNAP_ON) && !defined(INSTANCING_ON)) || (!defined(HERO_MASK) && defined(LOCAL_SPACE_X) && !defined(PIXELSNAP_ON) && !defined(WORLD_SCALE_FLIP) && !defined(INSTANCING_ON))
// Captured vertex program SHA256:
// 5d6e727653a50567b13af2220b1fdd6997d64953258a37bb9426bdd8598911e5
MaskedVertexOutput RecoveryVertex(MaskedVertexInput input)
{
    MaskedVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float3 u_xlat3;
    float u_xlat4;
    float u_xlat8;
    float2 u_xlat9;
    u_xlat0 = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, u_xlat0);
    u_xlat0 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat0);
    u_xlat1 = u_xlat0 + transpose(unity_ObjectToWorld)[3];
    u_xlat0.y = mad(transpose(unity_ObjectToWorld)[3].y, input.positionOS.w, u_xlat0.y);
    u_xlat2 = u_xlat1.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat2 = mad(transpose(unity_MatrixVP)[0], u_xlat1.xxxx, u_xlat2);
    u_xlat2 = mad(transpose(unity_MatrixVP)[2], u_xlat1.zzzz, u_xlat2);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], u_xlat1.wwww, u_xlat2);
    u_xlat1 = input.color * _Color;
    output.color = u_xlat1 * _RendererColor;
    u_xlat0.x = input.positionOS.x;
    u_xlat1.x = sin(_FogRotation);
    u_xlat2.x = cos(_FogRotation);
    u_xlat3.z = u_xlat1.x;
    u_xlat3.y = u_xlat2.x;
    u_xlat3.x = (-u_xlat1.x);
    u_xlat8 = dot(u_xlat0.xy, u_xlat3.xy);
    u_xlat0.x = dot(u_xlat0.xy, u_xlat3.yz);
    u_xlat4 = dot(transpose(unity_ObjectToWorld)[3].yx, float2(_WorldOffsetY, _WorldOffsetX));
    u_xlat4 = mad(transpose(unity_ObjectToWorld)[3].z, _WorldOffsetZ, u_xlat4);
    u_xlat4 = u_xlat4 + _Time.y;
    u_xlat9.x = mad(_SpeedX, u_xlat4, u_xlat0.x);
    u_xlat9.y = mad(_SpeedY, u_xlat4, u_xlat8);
    output.scrollUv.xy = mad(u_xlat9.xy, _ScrollTex_ST.xy, _ScrollTex_ST.zw);
    output.spriteUv.xy = input.spriteUv.xy;
    return output;
}
#endif

// Fragment interface.
#if (!defined(HERO_MASK)) || (!defined(SILHOUETTE))
struct MaskedFragmentInput
{
    float4 color : COLOR0;
    float2 spriteUv : TEXCOORD0;
    float2 scrollUv : TEXCOORD1;
};
#endif

#if defined(HERO_MASK) && defined(SILHOUETTE)
struct MaskedFragmentInput
{
    float4 color : COLOR0;
    float2 spriteUv : TEXCOORD0;
    float2 scrollUv : TEXCOORD1;
    float2 heroMaskUv : TEXCOORD2;
};
#endif

struct MaskedFragmentOutput
{
    float4 color : SV_Target0;
};

// Fragment programs, shared across vertex variants.
#if defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(HERO_MASK) && defined(SILHOUETTE) && defined(WORLD_SCALE_FLIP)
// Captured fragment program SHA256:
// 3b07299bc834e8bfccbc94bc275f27fb197848702d5f78bbe5480d7395ed4ec5
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input, float4 positionSS : SV_POSITION)
{
    MaskedFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float u_xlat2;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat2 = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).w;
    u_xlat2 = u_xlat2 * input.color.w;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat1 = ((float4)(u_xlat2)) * u_xlat1;
    u_xlat1.xyz = u_xlat1.www * u_xlat1.xyz;
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}
#endif

#if !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(HERO_MASK) && defined(SILHOUETTE) && defined(WORLD_SCALE_FLIP)
// Captured fragment program SHA256:
// 27304665186d6850ed313b3713167d7bdc48abd6656c3bb3226312cb75e9d291
// 3dc23f118442d4b7c6df534f66246a5aea7d620da571e21428f7be3836b6c4d8
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float u_xlat2;
    u_xlat0.x = _AlphaTex.Sample(sampler_AlphaTex, input.spriteUv.xy).x;
    u_xlat2 = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).w;
    u_xlat0.x = (-u_xlat2) + u_xlat0.x;
    u_xlat0.x = mad(_EnableExternalAlpha, u_xlat0.x, u_xlat2);
    u_xlat0.x = u_xlat0.x * input.color.w;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat0 = u_xlat0.xxxx * u_xlat1.wxyz;
    output.color.xyz = u_xlat0.xxx * u_xlat0.yzw;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

#if !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(HERO_MASK) && defined(SILHOUETTE) && defined(WORLD_SCALE_FLIP)
// Captured fragment program SHA256:
// 85c163842d79f1bf1d8762814c895ae2f4297b2748a8ae704088b576f231099f
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    u_xlat0.x = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).w;
    u_xlat0.x = u_xlat0.x * input.color.w;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat0 = u_xlat0.xxxx * u_xlat1.wxyz;
    output.color.xyz = u_xlat0.xxx * u_xlat0.yzw;
    output.color.w = u_xlat0.x;
    return output;
}
#endif

#if defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(HERO_MASK) && defined(SILHOUETTE) && defined(WORLD_SCALE_FLIP)
// Captured fragment program SHA256:
// d6bf33df7c75cb31f53fdd0873be2e17af18db0c1d70fe97fc063e7c0d82b3a7
// e3a8dba9b9a2917be957652922043a497889953848fef199996845cad2b95ecf
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input, float4 positionSS : SV_POSITION)
{
    MaskedFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float u_xlat0;
    float4 u_xlat1;
    float u_xlat2;
    float u_xlat4;
    u_xlat0 = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = u_xlat0 * 52.9829178;
    u_xlat0 = frac(u_xlat0);
    u_xlat0 = mad(u_xlat0, 0.00392156886, -0.00196078443);
    u_xlat2 = _AlphaTex.Sample(sampler_AlphaTex, input.spriteUv.xy).x;
    u_xlat4 = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).w;
    u_xlat2 = (-u_xlat4) + u_xlat2;
    u_xlat2 = mad(_EnableExternalAlpha, u_xlat2, u_xlat4);
    u_xlat2 = u_xlat2 * input.color.w;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat1 = ((float4)(u_xlat2)) * u_xlat1;
    u_xlat1.xyz = u_xlat1.www * u_xlat1.xyz;
    output.color = ((float4)(u_xlat0)) + u_xlat1;
    return output;
}
#endif

#if (!defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SILHOUETTE)) || (!defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(HERO_MASK) && !defined(WORLD_SCALE_FLIP))
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

#if (defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SILHOUETTE)) || (defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(HERO_MASK) && !defined(WORLD_SCALE_FLIP))
// Captured fragment program SHA256:
// 4d40f51ccf58a1ffbac37133d438ecec2b45501852390f6899a69b6493985dbb
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

#if (defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(SILHOUETTE)) || (defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && !defined(HERO_MASK) && !defined(WORLD_SCALE_FLIP))
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

#if (!defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(SILHOUETTE)) || (!defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && !defined(HERO_MASK) && !defined(WORLD_SCALE_FLIP))
// Captured fragment program SHA256:
// 001e632eb975959f823420c0bc8d307c652e55b482e08dfae5e7c82957c60c6f
// e245bb6ae23597ae82709a5b27fbee3757097c77f98ef62b06d18cc5bbc61325
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

#if !defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(HERO_MASK) && defined(SILHOUETTE)
// Captured fragment program SHA256:
// 2a7b378051f94f096aa02d793bcfdf00ee385aa3f21a01c50a8e554f2703613c
// 875667f89b2f54fc802aa10ca1ca71f374c29e189ea0cfe340ed04b6a1e59083
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    bool u_xlatb1;
    float u_xlat2;
    u_xlat0.x = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).w;
    u_xlat2 = _AlphaTex.Sample(sampler_AlphaTex, input.spriteUv.xy).x;
    u_xlat2 = (-u_xlat0.x) + u_xlat2;
    u_xlat0.x = mad(_EnableExternalAlpha, u_xlat2, u_xlat0.x);
    u_xlat0.x = u_xlat0.x * input.color.w;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat0 = u_xlat0.xxxx * u_xlat1;
    u_xlatb1 = float(0.0)!=_HeroPlayMode;
    if(u_xlatb1){
        u_xlat1.x = _HeroMaskTex.Sample(sampler_HeroMaskTex, input.heroMaskUv.xy).x;
        u_xlat0.w = u_xlat0.w * u_xlat1.x;
    }
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color = u_xlat0;
    return output;
}
#endif

#if !defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(HERO_MASK) && defined(SILHOUETTE)
// Captured fragment program SHA256:
// a0369fc6a6021a9ea26ab87fba81b8ff950b352a3971b85affa1ae8939488991
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input)
{
    MaskedFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    bool u_xlatb1;
    u_xlat0.x = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).w;
    u_xlat0.x = u_xlat0.x * input.color.w;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat0 = u_xlat0.xxxx * u_xlat1;
    u_xlatb1 = float(0.0)!=_HeroPlayMode;
    if(u_xlatb1){
        u_xlat1.x = _HeroMaskTex.Sample(sampler_HeroMaskTex, input.heroMaskUv.xy).x;
        u_xlat0.w = u_xlat0.w * u_xlat1.x;
    }
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    output.color = u_xlat0;
    return output;
}
#endif

#if defined(DITHERING_NOISE) && defined(ETC1_EXTERNAL_ALPHA) && defined(HERO_MASK) && defined(SILHOUETTE)
// Captured fragment program SHA256:
// 02b9aacb6080010c31b7fef4f708480326bd5e0a1d0363e10efffe562585312a
// cbb7ab612aecfa61138965d123e4d7a2281c0f8ffada13ddfb3d82c2ad2c8d00
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input, float4 positionSS : SV_POSITION)
{
    MaskedFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    bool u_xlatb1;
    float u_xlat2;
    u_xlat0.x = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).w;
    u_xlat2 = _AlphaTex.Sample(sampler_AlphaTex, input.spriteUv.xy).x;
    u_xlat2 = (-u_xlat0.x) + u_xlat2;
    u_xlat0.x = mad(_EnableExternalAlpha, u_xlat2, u_xlat0.x);
    u_xlat0.x = u_xlat0.x * input.color.w;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat0 = u_xlat0.xxxx * u_xlat1;
    u_xlatb1 = float(0.0)!=_HeroPlayMode;
    if(u_xlatb1){
        u_xlat1.x = _HeroMaskTex.Sample(sampler_HeroMaskTex, input.heroMaskUv.xy).x;
        u_xlat0.w = u_xlat0.w * u_xlat1.x;
    }
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.x = dot(fragmentCoord.xy, float2(0.0671105608, 0.00583714992));
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * 52.9829178;
    u_xlat1.x = frac(u_xlat1.x);
    u_xlat1.x = mad(u_xlat1.x, 0.00392156886, -0.00196078443);
    output.color = u_xlat0 + u_xlat1.xxxx;
    return output;
}
#endif

#if defined(DITHERING_NOISE) && !defined(ETC1_EXTERNAL_ALPHA) && defined(HERO_MASK) && defined(SILHOUETTE)
// Captured fragment program SHA256:
// e2955824757558c55946e9f037257f0736c71056579dfbf666f826d579d028df
MaskedFragmentOutput RecoveryFragment(MaskedFragmentInput input, float4 positionSS : SV_POSITION)
{
    MaskedFragmentOutput output;
    float4 fragmentCoord = float4(positionSS.xyz, 1.0/positionSS.w);
    float4 u_xlat0;
    float4 u_xlat1;
    bool u_xlatb1;
    u_xlat0.x = _MainTex.Sample(sampler_MainTex, input.spriteUv.xy).w;
    u_xlat0.x = u_xlat0.x * input.color.w;
    u_xlat1 = _ScrollTex.Sample(sampler_ScrollTex, input.scrollUv.xy);
    u_xlat0 = u_xlat0.xxxx * u_xlat1;
    u_xlatb1 = float(0.0)!=_HeroPlayMode;
    if(u_xlatb1){
        u_xlat1.x = _HeroMaskTex.Sample(sampler_HeroMaskTex, input.heroMaskUv.xy).x;
        u_xlat0.w = u_xlat0.w * u_xlat1.x;
    }
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
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
}
