// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Initial recovery: tools/shader_reconstruction/shaderlab_generator.py; refactored for readability.
// Original serialized Shader SHA256: 7a8a5830e0aca95b462b70dae3298deb0fc60f172394eb181803498400d7bce2
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Custom/Water"
{
    Properties
    {
        _MainTex ("Tint Texture", 2D) = "white" {}
        _Color ("Tint Color", Color) = (1, 1, 1, 1)
        _BumpAmt ("Distortion", Range(0, 128)) = 10
        _BumpMap ("Normalmap", 2D) = "bump" {}
        _SpeedX ("Speed X", Float) = 1
        _SpeedY ("Speed Y", Float) = 1
        _Reflection ("Reflection Intensity", Range(0, 1)) = 1
        [Toggle(ENABLE_REFLECTION)] _EnableReflection ("Enable Screen Reflection", Float) = 0
        _ReflectionOffset ("Reflection Offset", Float) = 0
        _MaskTex ("Mask", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "QUEUE"="Transparent" "RenderType"="Opaque" }
        GrabPass
        {
            Name "BASE"
            Tags { "LIGHTMODE"="ALWAYS" }
        }
        Pass
        {
            Name "BASE"
            Tags { "LIGHTMODE"="ALWAYS" "QUEUE"="Transparent" "RenderType"="Opaque" }
            Cull Back
            ZClip On
            ZTest LEqual
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Blend One Zero
            BlendOp Add
            ColorMask RGBA
            HLSLPROGRAM
#pragma target 4.5
#pragma vertex RecoveryVertex
#pragma fragment RecoveryFragment
#include "UnityCG.cginc"

float _BumpAmt;
Texture2D<float4> _BumpMap;
float4 _BumpMap_ST;
float4 _Color;
Texture2D<float4> _GrabTexture;
float4 _GrabTexture_TexelSize;
Texture2D<float4> _MainTex;
float4 _MainTex_ST;
Texture2D<float4> _MaskTex;
float _Reflection;
float _SpeedX;
float _SpeedY;
SamplerState sampler_BumpMap;
SamplerState sampler_GrabTexture;
SamplerState sampler_MainTex;
SamplerState sampler_MaskTex;

struct WaterVertexInput
{
    float4 positionOS : POSITION0;
    float2 uv : TEXCOORD0;
};

struct WaterVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 grabPosition : TEXCOORD0;
    float2 normalUV : TEXCOORD1;
    float2 tintUV : TEXCOORD2;
    float2 reflectionUV : TEXCOORD3;
};

// Captured vertex: 78156a73a7d6b4f5f9d6a4c8ab5ff65aa37620bfc083369bfd3bdc3dc95b824d.
WaterVertexOutput RecoveryVertex(WaterVertexInput input)
{
    WaterVertexOutput output;
    // Share the world transform: clipping uses object-space W=1, normal UV retains input W.
    // Calling UnityObjectToClipPos separately could duplicate this shared matrix work.
    float4x4 objectToWorldColumns = transpose(unity_ObjectToWorld);
    float4 worldPositionBase = input.positionOS.yyyy * objectToWorldColumns[1];
    worldPositionBase = mad(objectToWorldColumns[0], input.positionOS.xxxx, worldPositionBase);
    worldPositionBase = mad(objectToWorldColumns[2], input.positionOS.zzzz, worldPositionBase);
    float4 worldPosition = worldPositionBase + objectToWorldColumns[3];
    float2 worldUV = mad(objectToWorldColumns[3].xy, input.positionOS.ww, worldPositionBase.xy);
    output.normalUV = mad(worldUV, _BumpMap_ST.xy, _BumpMap_ST.zw);
    output.positionCS = mul(UNITY_MATRIX_VP, worldPosition);

    // Preserve the captured GrabPass Y=-1 convention on every backend.
    output.grabPosition.xy = mad(output.positionCS.xy, float2(1.0, -1.0), output.positionCS.ww);
    output.grabPosition.zw = output.positionCS.zw;
    output.grabPosition.xy = output.grabPosition.xy * float2(0.5, 0.5);
    output.tintUV = mad(input.uv, _MainTex_ST.xy, _MainTex_ST.zw);
    output.reflectionUV = mad(input.uv, float2(1.0, -1.0), float2(0.0, 1.0));
    return output;
}

struct WaterFragmentInput
{
    float4 grabPosition : TEXCOORD0;
    float2 normalUV : TEXCOORD1;
    float2 tintUV : TEXCOORD2;
    float2 reflectionUV : TEXCOORD3;
};

// Captured fragment: 101432af6e0a229ab6912141f37ef8d8e8e1e2f16b6ce409d447ed169c6ba7a7.
float4 RecoveryFragment(WaterFragmentInput input) : SV_Target0
{
    float2 scrollingNormalUV = mad(float2(_SpeedX, _SpeedY), _Time.yy, input.normalUV);
    float3 packedNormalXYA = _BumpMap.Sample(sampler_BumpMap, scrollingNormalUV).xyw;
    // Fixed RGorAG decoding in float: UnpackNormal can change format and precision by platform.
    float2 normalXY = float2(packedNormalXYA.z * packedNormalXYA.x, packedNormalXYA.y);
    normalXY = mad(normalXY, float2(2.0, 2.0), float2(-1.0, -1.0));
    float2 distortionPixels = normalXY * _BumpAmt;
    float2 distortionUV = distortionPixels * _GrabTexture_TexelSize.xy;

    float reflectionBrightness = mad(distortionPixels.y, _GrabTexture_TexelSize.y, input.reflectionUV.y);
    reflectionBrightness = (-reflectionBrightness) + 1.0;
    reflectionBrightness = reflectionBrightness * _Reflection;
    float2 refractedUV = mad(distortionUV, input.grabPosition.zz, input.grabPosition.xy);
    refractedUV = refractedUV / input.grabPosition.ww;
    float4 refractedColor = _GrabTexture.Sample(sampler_GrabTexture, refractedUV);
    float4 tint = _MainTex.Sample(sampler_MainTex, input.tintUV);
    refractedColor = refractedColor * tint;
    float4 waterColor = mad(refractedColor, _Color, reflectionBrightness.xxxx);

    float2 backgroundUV = input.grabPosition.xy / input.grabPosition.ww;
    float4 backgroundColor = _GrabTexture.Sample(sampler_GrabTexture, backgroundUV);
    float4 colorDifference = waterColor + (-backgroundColor);
    float mask = _MaskTex.Sample(sampler_MaskTex, input.tintUV).r;
    return mad(mask.xxxx, colorDifference, backgroundColor);
}
            ENDHLSL
        }
    }
    SubShader
    {
        Tags { "QUEUE"="Transparent" "RenderType"="Opaque" }
        Pass
        {
            Name "BASE"
            Tags { "QUEUE"="Transparent" "RenderType"="Opaque" }
            Cull Back
            ZClip On
            ZTest LEqual
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Blend DstColor Zero
            BlendOp Add
            ColorMask RGBA
            Fog { Mode Off }
            HLSLPROGRAM
#pragma target 4.5
#pragma vertex RecoveryVertex
#pragma fragment RecoveryFragment
#include "UnityCG.cginc"

Texture2D<float4> _MainTex;
float4 _MainTex_ST;
SamplerState sampler_MainTex;

struct WaterFallbackVertexInput
{
    float3 positionOS : POSITION0;
    float3 uv : TEXCOORD0;
};

struct WaterFallbackVertexOutput
{
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
    float4 positionCS : SV_POSITION;
};

// Captured vertex: d577e32d58fff52d5d7982ab7ea8aef49062f0057794f20d49341761c5074d7b.
WaterFallbackVertexOutput RecoveryVertex(WaterFallbackVertexInput input)
{
    WaterFallbackVertexOutput output;
    output.color = float4(0.0, 0.0, 0.0, 1.0);
    output.uv = mad(input.uv.xy, _MainTex_ST.xy, _MainTex_ST.zw);
    #if defined(STEREO_CUBEMAP_RENDER_ON)
        // Keep the recovered matrix-only path; the Unity helper adds an ODS offset here.
        output.positionCS = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, float4(input.positionOS, 1.0)));
    #else
        output.positionCS = UnityObjectToClipPos(input.positionOS);
    #endif
    return output;
}

struct WaterFallbackFragmentInput
{
    float2 uv : TEXCOORD0;
};

// Captured fragment: 69f6411a500b8e824738e89c4c136fe547bb5897edca6fa5f37a6d80386b70bc.
float4 RecoveryFragment(WaterFallbackFragmentInput input) : SV_Target0
{
    return _MainTex.Sample(sampler_MainTex, input.uv);
}
            ENDHLSL
        }
    }
}
