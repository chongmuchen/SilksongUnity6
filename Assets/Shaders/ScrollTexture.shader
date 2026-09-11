// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Initial recovery: tools/shader_reconstruction/shaderlab_generator.py; refactored for readability.
// Original serialized Shader SHA256: 02ab67596185d66ed7149e42371554a3b406b0b968e7b96a7e506bb3e9d71e1b
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Custom/ScrollTexture"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _SpeedX ("Flow Rate X", Float) = 1
        _SpeedY ("Flow Rate Y", Float) = 1
        [Toggle(USE_SECONDARY)] _UseSecondary ("Use Secondary", Float) = 0
        _SecondaryColor ("Secondary Color", Color) = (1, 1, 1, 1)
        _SecondaryTex ("Secondary Texture", 2D) = "white" {}
        _SecondarySpeedX ("Secondary Flow Rate X", Float) = 1
        _SecondarySpeedY ("Secondary Flow Rate Y", Float) = 1
        [Space] [Toggle(USE_OBJECT_SCALE)] _UseObjectScale ("Use Object Scale", Float) = 0
        [Space] [Toggle(USE_WORLD_OFFSET)] _UseWorldOffset ("Use World Offset", Float) = 0
        _WorldOffsetX ("World Offset X Amount", Float) = 0
        _WorldOffsetY ("World Offset Y Amount", Float) = 0
        _WorldOffsetZ ("World Offset Z Amount", Float) = 0
        [Toggle(USE_MASK)] _UseMask ("Use Mask", Float) = 0
        _MaskTex ("Mask Texture", 2D) = "white" {}
        [PerRendererData] _TintColor ("Tint Color", Color) = (1, 1, 1, 1)
        _StencilRef ("Stencil Ref", Range(0, 255)) = 255
        [Toggle(USE_COLOR_FLASH)] _UseColorFlash ("Use Color Flash", Float) = 0
        _FlashColor ("Flash Color", Color) = (1, 1, 1, 1)
        _FlashAmount ("Flash Amount", Range(0, 1)) = 0
    }
    SubShader
    {
        LOD 100
        Tags { "DisableBatching"="true" "IGNOREPROJECTOR"="true" "QUEUE"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Tags { "DisableBatching"="true" "IGNOREPROJECTOR"="true" "QUEUE"="Transparent" "RenderType"="Transparent" }
            Cull Back
            ZClip On
            ZTest LEqual
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Blend One OneMinusSrcAlpha
            BlendOp Add
            ColorMask RGBA
            Stencil
            {
                Ref [_StencilRef]
                ReadMask 255
                WriteMask 255
                Comp GEqual
                Pass Keep
                Fail Keep
                ZFail Keep
            }
            HLSLPROGRAM
#pragma target 4.5
#pragma vertex RecoveryVertex
#pragma fragment RecoveryFragment
#pragma multi_compile __ USE_COLOR_FLASH USE_MASK USE_OBJECT_SCALE
#pragma multi_compile __ USE_SECONDARY
#pragma multi_compile __ USE_WORLD_OFFSET
#pragma multi_compile_instancing
// Preserve the recovery selection order, including fallback combinations.
// USE_COLOR_FLASH, USE_MASK and USE_OBJECT_SCALE remain one multi_compile group.
// A selected program can use secondary/world-offset data even when those keywords are absent.
#if (!defined(INSTANCING_ON) && defined(USE_MASK) && !defined(USE_SECONDARY) && !defined(USE_WORLD_OFFSET))
#define RECOVERED_SCROLL_MASK 1
#elif (defined(INSTANCING_ON) && defined(USE_MASK) && !defined(USE_SECONDARY) && defined(USE_WORLD_OFFSET))
#define RECOVERED_SCROLL_INSTANCED_MASK_WORLD_OFFSET 1
#elif (defined(INSTANCING_ON) && defined(USE_MASK) && !defined(USE_SECONDARY) && !defined(USE_WORLD_OFFSET))
#define RECOVERED_SCROLL_INSTANCED_MASK 1
#elif (!defined(INSTANCING_ON) && defined(USE_MASK) && !defined(USE_SECONDARY) && defined(USE_WORLD_OFFSET))
#define RECOVERED_SCROLL_MASK_WORLD_OFFSET 1
#elif (!defined(INSTANCING_ON) && defined(USE_MASK) && defined(USE_SECONDARY))
#define RECOVERED_SCROLL_MASK_SECONDARY 1
#elif (defined(INSTANCING_ON) && defined(USE_MASK) && defined(USE_SECONDARY))
#define RECOVERED_SCROLL_INSTANCED_MASK_SECONDARY 1
#elif (defined(INSTANCING_ON) && defined(USE_OBJECT_SCALE) && defined(USE_SECONDARY)) || (defined(INSTANCING_ON) && defined(USE_OBJECT_SCALE) && defined(USE_WORLD_OFFSET)) || (defined(INSTANCING_ON) && !defined(USE_COLOR_FLASH) && !defined(USE_MASK) && defined(USE_SECONDARY) && defined(USE_WORLD_OFFSET))
#define RECOVERED_SCROLL_INSTANCED_SCALED_SECONDARY_WORLD 1
#elif (defined(INSTANCING_ON) && defined(USE_COLOR_FLASH))
#define RECOVERED_SCROLL_INSTANCED_FLASH 1
#elif (!defined(INSTANCING_ON) && defined(USE_OBJECT_SCALE) && defined(USE_SECONDARY)) || (!defined(INSTANCING_ON) && defined(USE_OBJECT_SCALE) && defined(USE_WORLD_OFFSET)) || (!defined(INSTANCING_ON) && !defined(USE_COLOR_FLASH) && !defined(USE_MASK) && defined(USE_SECONDARY) && defined(USE_WORLD_OFFSET))
#define RECOVERED_SCROLL_SCALED_SECONDARY_WORLD 1
#elif (defined(INSTANCING_ON) && !defined(USE_COLOR_FLASH) && !defined(USE_MASK) && !defined(USE_OBJECT_SCALE) && !defined(USE_SECONDARY)) || (defined(INSTANCING_ON) && defined(USE_OBJECT_SCALE) && !defined(USE_SECONDARY) && !defined(USE_WORLD_OFFSET)) || (defined(INSTANCING_ON) && !defined(USE_COLOR_FLASH) && !defined(USE_MASK) && !defined(USE_OBJECT_SCALE) && !defined(USE_WORLD_OFFSET))
#define RECOVERED_SCROLL_INSTANCED_BASE 1
#elif (!defined(INSTANCING_ON) && defined(USE_COLOR_FLASH))
#define RECOVERED_SCROLL_FLASH 1
#else
#define RECOVERED_SCROLL_BASE 1
#endif

#if defined(RECOVERED_SCROLL_MASK) || defined(RECOVERED_SCROLL_INSTANCED_MASK_WORLD_OFFSET) || defined(RECOVERED_SCROLL_INSTANCED_MASK) || defined(RECOVERED_SCROLL_MASK_WORLD_OFFSET) || defined(RECOVERED_SCROLL_MASK_SECONDARY) || defined(RECOVERED_SCROLL_INSTANCED_MASK_SECONDARY)
#define RECOVERED_SCROLL_HAS_MASK 1
#endif

#if defined(RECOVERED_SCROLL_MASK_SECONDARY) || defined(RECOVERED_SCROLL_INSTANCED_MASK_SECONDARY) || defined(RECOVERED_SCROLL_INSTANCED_SCALED_SECONDARY_WORLD) || defined(RECOVERED_SCROLL_SCALED_SECONDARY_WORLD)
#define RECOVERED_SCROLL_HAS_SECONDARY 1
#endif

#if defined(RECOVERED_SCROLL_INSTANCED_MASK_WORLD_OFFSET) || defined(RECOVERED_SCROLL_MASK_WORLD_OFFSET) || defined(RECOVERED_SCROLL_INSTANCED_SCALED_SECONDARY_WORLD) || defined(RECOVERED_SCROLL_SCALED_SECONDARY_WORLD)
#define RECOVERED_SCROLL_HAS_WORLD_OFFSET 1
#endif

#if defined(RECOVERED_SCROLL_INSTANCED_SCALED_SECONDARY_WORLD) || defined(RECOVERED_SCROLL_SCALED_SECONDARY_WORLD)
#define RECOVERED_SCROLL_USES_SCALE 1
#endif

#if defined(RECOVERED_SCROLL_INSTANCED_FLASH) || defined(RECOVERED_SCROLL_FLASH)
#define RECOVERED_SCROLL_USES_FLASH 1
#endif

// Shared declarations preserve the selected program's original order and instancing layout.
#include "UnityCG.cginc"

#if !defined(INSTANCING_ON)
float4 _Color;
#endif

#if defined(RECOVERED_SCROLL_USES_FLASH) && !defined(INSTANCING_ON)
float _FlashAmount;
float4 _FlashColor;
#endif

Texture2D<float4> _MainTex;
float4 _MainTex_ST;

#if defined(RECOVERED_SCROLL_HAS_MASK)
Texture2D<float4> _MaskTex;
float4 _MaskTex_ST;
#endif

#if defined(RECOVERED_SCROLL_USES_SCALE) && !defined(INSTANCING_ON)
float3 _ObjectScale;
#endif

#if defined(RECOVERED_SCROLL_HAS_SECONDARY) && !defined(INSTANCING_ON)
float4 _SecondaryColor;
float _SecondarySpeedX;
float _SecondarySpeedY;
#endif

#if defined(RECOVERED_SCROLL_HAS_SECONDARY)
Texture2D<float4> _SecondaryTex;
float4 _SecondaryTex_ST;
#endif

#if !defined(INSTANCING_ON)
float _SpeedX;
float _SpeedY;
float4 _TintColor;
#endif

#if defined(RECOVERED_SCROLL_HAS_WORLD_OFFSET)
float _WorldOffsetX;
float _WorldOffsetY;
float _WorldOffsetZ;
#endif

#if defined(INSTANCING_ON)
UNITY_INSTANCING_BUFFER_START(Props)
    UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
    UNITY_DEFINE_INSTANCED_PROP(float4, _TintColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _SpeedX)
    UNITY_DEFINE_INSTANCED_PROP(float, _SpeedY)
#endif

#if defined(RECOVERED_SCROLL_USES_SCALE) && defined(INSTANCING_ON)
    UNITY_DEFINE_INSTANCED_PROP(float3, _ObjectScale)
#endif

#if defined(RECOVERED_SCROLL_USES_FLASH) && defined(INSTANCING_ON)
    UNITY_DEFINE_INSTANCED_PROP(float4, _FlashColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _FlashAmount)
#endif

#if defined(INSTANCING_ON)
UNITY_INSTANCING_BUFFER_END(Props)
#endif

#if defined(RECOVERED_SCROLL_HAS_SECONDARY) && defined(INSTANCING_ON)
UNITY_INSTANCING_BUFFER_START(SecondaryProps)
    UNITY_DEFINE_INSTANCED_PROP(float4, _SecondaryColor)
    UNITY_DEFINE_INSTANCED_PROP(float, _SecondarySpeedX)
    UNITY_DEFINE_INSTANCED_PROP(float, _SecondarySpeedY)
UNITY_INSTANCING_BUFFER_END(SecondaryProps)
#endif

SamplerState sampler_MainTex;

#if defined(RECOVERED_SCROLL_HAS_MASK)
SamplerState sampler_MaskTex;
#endif

#if defined(RECOVERED_SCROLL_HAS_SECONDARY)
SamplerState sampler_SecondaryTex;
#endif

// Vertex inputs and interpolation data.
struct ScrollVertexInput
{
    float4 positionOS : POSITION0;
    float2 mainUV : TEXCOORD0;
    float4 color : COLOR0;

#if defined(INSTANCING_ON)
    uint instanceID : SV_InstanceID;
#endif

};

struct ScrollVertexOutput
{
    float2 mainUV : TEXCOORD0;

#if defined(RECOVERED_SCROLL_HAS_MASK)
    float2 maskUV : TEXCOORD1;
#endif

#if defined(RECOVERED_SCROLL_HAS_SECONDARY)
    float2 secondaryUV : TEXCOORD2;
#endif

    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;

#if defined(INSTANCING_ON)
    uint instanceID : TEXCOORD13;
#endif

};

#if defined(RECOVERED_SCROLL_MASK)
// mask.
// Captured vertex: 1ab1134ff477f911d40b31e88bf826d683777326f5f1b32e438d8e6131c2882a.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{
    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    float4 positionWork;
    uvAndPositionWork.xy = mad(float2(_SpeedX, _SpeedY), _Time.yy, input.mainUV.xy);
    output.mainUV.xy = mad(uvAndPositionWork.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    output.maskUV.xy = mad(input.mainUV.xy, _MaskTex_ST.xy, _MaskTex_ST.zw);
    uvAndPositionWork = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, uvAndPositionWork);
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, uvAndPositionWork);
    uvAndPositionWork = uvAndPositionWork + transpose(unity_ObjectToWorld)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.color = input.color * _TintColor;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_MASK_WORLD_OFFSET)
// instanced mask world offset.
// Captured vertex: 3a89c6ba5f096cc743422601164bf6a7485f6c1ce0e996ea8f75ff415a44e9a7.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{

    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    int instanceOffsets;
    float4 positionWork;
    int propertyOffset;
    float2 scrollUV;
    output.maskUV.xy = mad(input.mainUV.xy, _MaskTex_ST.xy, _MaskTex_ST.zw);
    instanceOffsets = int(input.instanceID) + unity_BaseInstanceID;
    propertyOffset = instanceOffsets * 0x3;
    instanceOffsets = instanceOffsets << 0x3;
    scrollUV.x = dot(transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[3].yxz, float3(_WorldOffsetY, _WorldOffsetX, _WorldOffsetZ));
    scrollUV.x = scrollUV.x + _Time.y;
    scrollUV.xy = mad(float2(PropsArray[propertyOffset / 3]._SpeedX, PropsArray[propertyOffset / 3]._SpeedY), scrollUV.xx, input.mainUV.xy);
    output.color = input.color * PropsArray[propertyOffset / 3]._TintColor;
    output.mainUV.xy = mad(scrollUV.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    positionWork = input.positionOS.yyyy * transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[1];
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[0], input.positionOS.xxxx, positionWork);
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, positionWork);
    uvAndPositionWork = positionWork + transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.instanceID = input.instanceID;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_MASK)
// instanced mask.
// Captured vertex: 715f6194044c793a5bf60c4507d085fe5f4957ef9d99994ac97d55f54df62d08.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{

    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    int instanceOffsets;
    float4 positionWork;
    int propertyOffset;
    float2 scrollUV;
    output.maskUV.xy = mad(input.mainUV.xy, _MaskTex_ST.xy, _MaskTex_ST.zw);
    instanceOffsets = int(input.instanceID) + unity_BaseInstanceID;
    propertyOffset = instanceOffsets * 0x3;
    instanceOffsets = instanceOffsets << 0x3;
    scrollUV.xy = mad(float2(PropsArray[propertyOffset / 3]._SpeedX, PropsArray[propertyOffset / 3]._SpeedY), _Time.yy, input.mainUV.xy);
    output.color = input.color * PropsArray[propertyOffset / 3]._TintColor;
    output.mainUV.xy = mad(scrollUV.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    positionWork = input.positionOS.yyyy * transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[1];
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[0], input.positionOS.xxxx, positionWork);
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, positionWork);
    uvAndPositionWork = positionWork + transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.instanceID = input.instanceID;
    return output;
}

#elif defined(RECOVERED_SCROLL_MASK_WORLD_OFFSET)
// mask world offset.
// Captured vertex: 827e5583dc3d8e0c11b1d5c3ba10955ec62186c5e900e4e959ef2c607111fb5c.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{
    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    float4 positionWork;
    uvAndPositionWork.x = dot(transpose(unity_ObjectToWorld)[3].yxz, float3(_WorldOffsetY, _WorldOffsetX, _WorldOffsetZ));
    uvAndPositionWork.x = uvAndPositionWork.x + _Time.y;
    uvAndPositionWork.xy = mad(float2(_SpeedX, _SpeedY), uvAndPositionWork.xx, input.mainUV.xy);
    output.mainUV.xy = mad(uvAndPositionWork.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    output.maskUV.xy = mad(input.mainUV.xy, _MaskTex_ST.xy, _MaskTex_ST.zw);
    uvAndPositionWork = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, uvAndPositionWork);
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, uvAndPositionWork);
    uvAndPositionWork = uvAndPositionWork + transpose(unity_ObjectToWorld)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.color = input.color * _TintColor;
    return output;
}

#elif defined(RECOVERED_SCROLL_MASK_SECONDARY)
// mask secondary.
// Captured vertex: 7408ec9e7cc8690737035b286261057c1482c7264d14cb5952c00653ad1637ad.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{
    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    float4 positionWork;
    uvAndPositionWork.xy = mad(float2(_SpeedX, _SpeedY), _Time.yy, input.mainUV.xy);
    output.mainUV.xy = mad(uvAndPositionWork.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    output.maskUV.xy = mad(input.mainUV.xy, _MaskTex_ST.xy, _MaskTex_ST.zw);
    uvAndPositionWork.xy = mad(float2(_SecondarySpeedX, _SecondarySpeedY), _Time.yy, input.mainUV.xy);
    output.secondaryUV.xy = mad(uvAndPositionWork.xy, _SecondaryTex_ST.xy, _SecondaryTex_ST.zw);
    uvAndPositionWork = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, uvAndPositionWork);
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, uvAndPositionWork);
    uvAndPositionWork = uvAndPositionWork + transpose(unity_ObjectToWorld)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.color = input.color * _TintColor;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_MASK_SECONDARY)
// instanced mask secondary.
// Captured vertex: 980439b28be4d6d2a09ba54e0300dde2dc60ec9f5b973c1c35052e178a5a1fa2.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{

    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    int3 instanceOffsets;
    float4 positionWork;
    float2 secondaryUV;
    int propertyOffset;
    output.maskUV.xy = mad(input.mainUV.xy, _MaskTex_ST.xy, _MaskTex_ST.zw);
    instanceOffsets.x = int(input.instanceID) + unity_BaseInstanceID;
    propertyOffset = instanceOffsets.x * 0x3;
    instanceOffsets.xz = instanceOffsets.xx << int2(0x3, 0x1);
    positionWork.xy = mad(float2(PropsArray[propertyOffset / 3]._SpeedX, PropsArray[propertyOffset / 3]._SpeedY), _Time.yy, input.mainUV.xy);
    output.color = input.color * PropsArray[propertyOffset / 3]._TintColor;
    output.mainUV.xy = mad(positionWork.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    secondaryUV.xy = mad(float2(SecondaryPropsArray[instanceOffsets.z / 2]._SecondarySpeedX, SecondaryPropsArray[instanceOffsets.z / 2]._SecondarySpeedY), _Time.yy, input.mainUV.xy);
    output.secondaryUV.xy = mad(secondaryUV.xy, _SecondaryTex_ST.xy, _SecondaryTex_ST.zw);
    positionWork = input.positionOS.yyyy * transpose(unity_Builtins0Array[instanceOffsets.x / 8].unity_ObjectToWorldArray)[1];
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets.x / 8].unity_ObjectToWorldArray)[0], input.positionOS.xxxx, positionWork);
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets.x / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, positionWork);
    uvAndPositionWork = positionWork + transpose(unity_Builtins0Array[instanceOffsets.x / 8].unity_ObjectToWorldArray)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.instanceID = input.instanceID;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_SCALED_SECONDARY_WORLD)
// instanced scaled secondary world.
// Captured vertex: 164cd638913d0504046c849a8d87b5e30c280d95e0d035775dc347b703da0364.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{

    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    int3 instanceOffsets;
    float4 positionWork;
    float2 scrollUV;
    float2 mainScrollUV;
    float scrollTime;
    instanceOffsets.x = int(input.instanceID) + unity_BaseInstanceID;
    instanceOffsets.xyz = instanceOffsets.xxx << int3(0x3, 0x2, 0x1);
    scrollTime = dot(transpose(unity_Builtins0Array[instanceOffsets.x / 8].unity_ObjectToWorldArray)[3].yxz, float3(_WorldOffsetY, _WorldOffsetX, _WorldOffsetZ));
    scrollTime = scrollTime + _Time.y;
    positionWork.xy = input.mainUV.xy * PropsArray[instanceOffsets.y / 4]._ObjectScale.xyzx.xy;
    mainScrollUV.xy = mad(float2(PropsArray[instanceOffsets.y / 4]._SpeedX, PropsArray[instanceOffsets.y / 4]._SpeedY), ((float2)(scrollTime)), positionWork.xy);
    scrollUV.xy = mad(float2(SecondaryPropsArray[instanceOffsets.z / 2]._SecondarySpeedX, SecondaryPropsArray[instanceOffsets.z / 2]._SecondarySpeedY), ((float2)(scrollTime)), positionWork.xy);
    output.secondaryUV.xy = mad(scrollUV.xy, _SecondaryTex_ST.xy, _SecondaryTex_ST.zw);
    output.mainUV.xy = mad(mainScrollUV.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    positionWork = input.positionOS.yyyy * transpose(unity_Builtins0Array[instanceOffsets.x / 8].unity_ObjectToWorldArray)[1];
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets.x / 8].unity_ObjectToWorldArray)[0], input.positionOS.xxxx, positionWork);
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets.x / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, positionWork);
    positionWork = positionWork + transpose(unity_Builtins0Array[instanceOffsets.x / 8].unity_ObjectToWorldArray)[3];
    output.color = input.color * PropsArray[instanceOffsets.y / 4]._TintColor;
    uvAndPositionWork = positionWork.yyyy * transpose(unity_MatrixVP)[1];
    uvAndPositionWork = mad(transpose(unity_MatrixVP)[0], positionWork.xxxx, uvAndPositionWork);
    uvAndPositionWork = mad(transpose(unity_MatrixVP)[2], positionWork.zzzz, uvAndPositionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], positionWork.wwww, uvAndPositionWork);
    output.instanceID = input.instanceID;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_FLASH)
// instanced flash.
// Captured vertex: 172a51091ecf59a0254b3d817e6f2aadec093e8b0da2fe7a4dad78c680df552a.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{

    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    int instanceOffsets;
    float4 positionWork;
    int propertyOffset;
    float2 scrollUV;
    instanceOffsets = int(input.instanceID) + unity_BaseInstanceID;
    propertyOffset = instanceOffsets * 0x5;
    instanceOffsets = instanceOffsets << 0x3;
    scrollUV.xy = mad(float2(PropsArray[propertyOffset / 5]._SpeedX, PropsArray[propertyOffset / 5]._SpeedY), _Time.yy, input.mainUV.xy);
    output.color = input.color * PropsArray[propertyOffset / 5]._TintColor;
    output.mainUV.xy = mad(scrollUV.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    positionWork = input.positionOS.yyyy * transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[1];
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[0], input.positionOS.xxxx, positionWork);
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, positionWork);
    uvAndPositionWork = positionWork + transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.instanceID = input.instanceID;
    return output;
}

#elif defined(RECOVERED_SCROLL_SCALED_SECONDARY_WORLD)
// scaled secondary world.
// Captured vertex: 41f8c29e890d152650f41811231f500e4ffe0efdcf63d11f6a3c891f7d1a064d.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{
    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    float4 positionWork;
    float2 secondaryUV;
    uvAndPositionWork.x = dot(transpose(unity_ObjectToWorld)[3].yxz, float3(_WorldOffsetY, _WorldOffsetX, _WorldOffsetZ));
    uvAndPositionWork.x = uvAndPositionWork.x + _Time.y;
    secondaryUV.xy = input.mainUV.xy * _ObjectScale.xyzx.xy;
    positionWork.xy = mad(float2(_SpeedX, _SpeedY), uvAndPositionWork.xx, secondaryUV.xy);
    uvAndPositionWork.xy = mad(float2(_SecondarySpeedX, _SecondarySpeedY), uvAndPositionWork.xx, secondaryUV.xy);
    output.secondaryUV.xy = mad(uvAndPositionWork.xy, _SecondaryTex_ST.xy, _SecondaryTex_ST.zw);
    output.mainUV.xy = mad(positionWork.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    uvAndPositionWork = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, uvAndPositionWork);
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, uvAndPositionWork);
    uvAndPositionWork = uvAndPositionWork + transpose(unity_ObjectToWorld)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.color = input.color * _TintColor;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_BASE)
// instanced base.
// Captured vertex: 97ee9eb6b9b1c63c9f692452a7f6251e4f5d3c07eae5b9c4dc829fef018110d4.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{

    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    int instanceOffsets;
    float4 positionWork;
    int propertyOffset;
    float2 scrollUV;
    instanceOffsets = int(input.instanceID) + unity_BaseInstanceID;
    propertyOffset = instanceOffsets * 0x3;
    instanceOffsets = instanceOffsets << 0x3;
    scrollUV.xy = mad(float2(PropsArray[propertyOffset / 3]._SpeedX, PropsArray[propertyOffset / 3]._SpeedY), _Time.yy, input.mainUV.xy);
    output.color = input.color * PropsArray[propertyOffset / 3]._TintColor;
    output.mainUV.xy = mad(scrollUV.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    positionWork = input.positionOS.yyyy * transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[1];
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[0], input.positionOS.xxxx, positionWork);
    positionWork = mad(transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[2], input.positionOS.zzzz, positionWork);
    uvAndPositionWork = positionWork + transpose(unity_Builtins0Array[instanceOffsets / 8].unity_ObjectToWorldArray)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.instanceID = input.instanceID;
    return output;
}

#elif defined(RECOVERED_SCROLL_FLASH) || defined(RECOVERED_SCROLL_BASE)
// flash, base.
// Captured vertex: be5aadff7a14c4d17d3fa9313f3fa91bd2d8ec9a159e39cb9f6ed5b63ba07666.
// Captured vertex: e8116f3e8b37b7937560afe68c71aeb896c85a78887b6dd070713519ebd725a0.
ScrollVertexOutput RecoveryVertex(ScrollVertexInput input)
{
    ScrollVertexOutput output;
    float4 uvAndPositionWork;
    float4 positionWork;
    uvAndPositionWork.xy = mad(float2(_SpeedX, _SpeedY), _Time.yy, input.mainUV.xy);
    output.mainUV.xy = mad(uvAndPositionWork.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    uvAndPositionWork = input.positionOS.yyyy * transpose(unity_ObjectToWorld)[1];
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[0], input.positionOS.xxxx, uvAndPositionWork);
    uvAndPositionWork = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, uvAndPositionWork);
    uvAndPositionWork = uvAndPositionWork + transpose(unity_ObjectToWorld)[3];
    positionWork = uvAndPositionWork.yyyy * transpose(unity_MatrixVP)[1];
    positionWork = mad(transpose(unity_MatrixVP)[0], uvAndPositionWork.xxxx, positionWork);
    positionWork = mad(transpose(unity_MatrixVP)[2], uvAndPositionWork.zzzz, positionWork);
    output.positionCS = mad(transpose(unity_MatrixVP)[3], uvAndPositionWork.wwww, positionWork);
    output.color = input.color * _TintColor;
    return output;
}

#endif

// Fragment inputs and output.
struct ScrollFragmentInput
{
    float2 mainUV : TEXCOORD0;

#if defined(RECOVERED_SCROLL_HAS_MASK)
    float2 maskUV : TEXCOORD1;
#endif

#if defined(RECOVERED_SCROLL_HAS_SECONDARY)
    float2 secondaryUV : TEXCOORD2;
#endif

    float4 color : COLOR0;

#if defined(INSTANCING_ON)
    nointerpolation uint instanceID : TEXCOORD13;
#endif

};

struct ScrollFragmentOutput
{
    float4 color : SV_Target0;
};

#if defined(RECOVERED_SCROLL_MASK) || defined(RECOVERED_SCROLL_MASK_WORLD_OFFSET)
// mask, mask world offset.
// Captured fragment: 11b4b85c8b46cdc5dd456bf2f87be2b91145e2deada3eea34ada1ec10f7985ef.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    float sampleWork;
    float maskedAlpha;
    colorWork = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    colorWork = colorWork * _Color;
    colorWork = colorWork * input.color;
    sampleWork = _MaskTex.Sample(sampler_MaskTex, input.maskUV.xy).x;
    maskedAlpha = colorWork.w * sampleWork;
    output.color.xyz = ((float3)(maskedAlpha)) * colorWork.xyz;
    output.color.w = maskedAlpha;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_MASK_WORLD_OFFSET) || defined(RECOVERED_SCROLL_INSTANCED_MASK)
// instanced mask world offset, instanced mask.
// Captured fragment: 2aec5dd8a76273af8ea778bb5d500f67d945fd199733217328d952e9245f1a00.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    int propertyOffset;
    float4 sampleWork;
    float maskedAlpha;
    propertyOffset = int(input.instanceID) + unity_BaseInstanceID;
    propertyOffset = propertyOffset * 0x3;
    sampleWork = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    colorWork = sampleWork * PropsArray[propertyOffset / 3]._Color;
    colorWork = colorWork * input.color;
    sampleWork.x = _MaskTex.Sample(sampler_MaskTex, input.maskUV.xy).x;
    maskedAlpha = colorWork.w * sampleWork.x;
    output.color.xyz = ((float3)(maskedAlpha)) * colorWork.xyz;
    output.color.w = maskedAlpha;
    return output;
}

#elif defined(RECOVERED_SCROLL_MASK_SECONDARY)
// mask secondary.
// Captured fragment: c1d090420f7aa55519317500bbbe47198a38b177e2275fcdbac3c09c0054d5da.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    float4 sampleWork;
    float maskedAlpha;
    colorWork = _SecondaryTex.Sample(sampler_SecondaryTex, input.secondaryUV.xy);
    colorWork = colorWork * _SecondaryColor;
    colorWork = colorWork * input.color;
    sampleWork = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    sampleWork = sampleWork * _Color;
    colorWork = mad(sampleWork, input.color, colorWork);
    sampleWork.x = _MaskTex.Sample(sampler_MaskTex, input.maskUV.xy).x;
    maskedAlpha = colorWork.w * sampleWork.x;
    output.color.xyz = ((float3)(maskedAlpha)) * colorWork.xyz;
    output.color.w = maskedAlpha;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_MASK_SECONDARY)
// instanced mask secondary.
// Captured fragment: 3888e172f9c23709af84615cf62b7331ab463f3d8e7c79de1ded88f3561898c3.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    float4 sampleWork;
    int instanceOffsets;
    float4 primarySample;
    int secondaryOffset;
    float maskedAlpha;
    colorWork = _SecondaryTex.Sample(sampler_SecondaryTex, input.secondaryUV.xy);
    instanceOffsets = int(input.instanceID) + unity_BaseInstanceID;
    secondaryOffset = instanceOffsets << 0x1;
    instanceOffsets = instanceOffsets * 0x3;
    colorWork = colorWork * SecondaryPropsArray[secondaryOffset / 2]._SecondaryColor;
    colorWork = colorWork * input.color;
    primarySample = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    sampleWork = primarySample * PropsArray[instanceOffsets / 3]._Color;
    colorWork = mad(sampleWork, input.color, colorWork);
    sampleWork.x = _MaskTex.Sample(sampler_MaskTex, input.maskUV.xy).x;
    maskedAlpha = colorWork.w * sampleWork.x;
    output.color.xyz = ((float3)(maskedAlpha)) * colorWork.xyz;
    output.color.w = maskedAlpha;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_SCALED_SECONDARY_WORLD)
// instanced scaled secondary world.
// Captured fragment: 95d868211a26799dfcc2d1b0d537f0f9453a4c573b918c23030e24cca2d7bd2a.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    float4 sampleWork;
    int2 instanceOffsets;
    float4 primarySample;
    colorWork = _SecondaryTex.Sample(sampler_SecondaryTex, input.secondaryUV.xy);
    instanceOffsets.x = int(input.instanceID) + unity_BaseInstanceID;
    instanceOffsets.xy = instanceOffsets.xx << int2(0x2, 0x1);
    colorWork = colorWork * SecondaryPropsArray[instanceOffsets.y / 2]._SecondaryColor;
    colorWork = colorWork * input.color;
    primarySample = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    sampleWork = primarySample * PropsArray[instanceOffsets.x / 4]._Color;
    colorWork = mad(sampleWork, input.color, colorWork);
    output.color.xyz = colorWork.www * colorWork.xyz;
    output.color.w = colorWork.w;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_FLASH)
// instanced flash.
// Captured fragment: cd51f01c76627b11d6d9d1d405c0c49c9cd161a20244cffc1617a5ac13875378.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    int instanceOffsets;
    float3 flashDifference;
    colorWork = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    instanceOffsets = int(input.instanceID) + unity_BaseInstanceID;
    instanceOffsets = instanceOffsets * 0x5;
    colorWork = colorWork * PropsArray[instanceOffsets / 5]._Color;
    flashDifference.xyz = mad((-colorWork.xyz), input.color.xyz, PropsArray[instanceOffsets / 5]._FlashColor.xyz);
    colorWork = colorWork * input.color;
    colorWork.xyz = mad(((float3)(PropsArray[instanceOffsets / 5]._FlashAmount)), flashDifference.xyz, colorWork.xyz);
    output.color.xyz = colorWork.www * colorWork.xyz;
    output.color.w = colorWork.w;
    return output;
}

#elif defined(RECOVERED_SCROLL_SCALED_SECONDARY_WORLD)
// scaled secondary world.
// Captured fragment: 4e0eb74b2ebf586f32ae04c7132903f4238391cdfe41af2e27f477e4c76d7658.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    float4 sampleWork;
    colorWork = _SecondaryTex.Sample(sampler_SecondaryTex, input.secondaryUV.xy);
    colorWork = colorWork * _SecondaryColor;
    colorWork = colorWork * input.color;
    sampleWork = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    sampleWork = sampleWork * _Color;
    colorWork = mad(sampleWork, input.color, colorWork);
    output.color.xyz = colorWork.www * colorWork.xyz;
    output.color.w = colorWork.w;
    return output;
}

#elif defined(RECOVERED_SCROLL_INSTANCED_BASE)
// instanced base.
// Captured fragment: 866f9bb1cdbce42fb148356f0066e8908943cda3cb2cacc7827d72895381c930.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    int propertyOffset;
    float4 sampleWork;
    propertyOffset = int(input.instanceID) + unity_BaseInstanceID;
    propertyOffset = propertyOffset * 0x3;
    sampleWork = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    colorWork = sampleWork * PropsArray[propertyOffset / 3]._Color;
    colorWork = colorWork * input.color;
    output.color.xyz = colorWork.www * colorWork.xyz;
    output.color.w = colorWork.w;
    return output;
}

#elif defined(RECOVERED_SCROLL_FLASH)
// flash.
// Captured fragment: 1f232d6bf2108c4235edebaa7915e2f62d8ce7e77db6c5ec84789836cab38857.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    float3 sampleWork;
    colorWork = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    colorWork = colorWork * _Color;
    sampleWork.xyz = mad((-colorWork.xyz), input.color.xyz, _FlashColor.xyz);
    colorWork = colorWork * input.color;
    colorWork.xyz = mad(((float3)(_FlashAmount)), sampleWork.xyz, colorWork.xyz);
    output.color.xyz = colorWork.www * colorWork.xyz;
    output.color.w = colorWork.w;
    return output;
}

#elif defined(RECOVERED_SCROLL_BASE)
// base.
// Captured fragment: 9e2d10ad6e777c3f5d967fde7b7d654066b5ccda7c4c2e8d010771816b3f38ff.
ScrollFragmentOutput RecoveryFragment(ScrollFragmentInput input)
{
    ScrollFragmentOutput output;
    float4 colorWork;
    colorWork = _MainTex.Sample(sampler_MainTex, input.mainUV.xy);
    colorWork = colorWork * _Color;
    colorWork = colorWork * input.color;
    output.color.xyz = colorWork.www * colorWork.xyz;
    output.color.w = colorWork.w;
    return output;
}

#endif

            ENDHLSL
        }
    }
}
