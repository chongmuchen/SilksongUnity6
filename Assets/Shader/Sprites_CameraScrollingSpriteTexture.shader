// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Initial recovery: tools/shader_reconstruction/shaderlab_generator.py; refactored for readability.
// Original serialized Shader SHA256: 567bfcfe38e28b0a371d9bbfb5f8347aba384be27519be5c51d9f232fa595de2
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Sprites/CameraScrollingSpriteTexture"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _ColorTex ("Color Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
        _ScrollSpeed ("Scroll Speed", Vector) = (0, 0, 0, 0)
        _Scale ("Scale", Vector) = (1, 1, 0, 0)
    }
    SubShader
    {
        LOD 100
        Tags { "QUEUE"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Tags { "QUEUE"="Transparent" "RenderType"="Transparent" }
            Cull Off
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
#include "UnityCG.cginc"

float4 _Color;
Texture2D<float4> _ColorTex;
Texture2D<float4> _MainTex;
float4 _Scale;
float4 _ScrollSpeed;
SamplerState sampler_ColorTex;
SamplerState sampler_MainTex;

struct ScrollingSpriteVertexInput
{
    float4 positionOS : POSITION0;
    float2 uv : TEXCOORD0;
    float4 color : COLOR0;
};

struct ScrollingSpriteVertexOutput
{
    float2 spriteUV : TEXCOORD0;
    float2 colorUV : TEXCOORD1;
    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;
};

// Captured vertex: d7478f0793fe359d839d067dba6956592aea9117de331b9d0c25c3bc31f95cde.
ScrollingSpriteVertexOutput RecoveryVertex(ScrollingSpriteVertexInput input)
{
    ScrollingSpriteVertexOutput output;
    // Share the world transform: clip position uses W=1, scrolling UV retains input W.
    float4x4 objectToWorldColumns = transpose(unity_ObjectToWorld);
    float4 worldPositionBase = input.positionOS.yyyy * objectToWorldColumns[1];
    worldPositionBase = mad(objectToWorldColumns[0], input.positionOS.xxxx, worldPositionBase);
    worldPositionBase = mad(objectToWorldColumns[2], input.positionOS.zzzz, worldPositionBase);
    float2 cameraOffsetUV = mad(objectToWorldColumns[3].xy, input.positionOS.ww, worldPositionBase.xy);
    float4 worldPosition = worldPositionBase + objectToWorldColumns[3];
    // The recovered effect adds camera position to the world position.
    cameraOffsetUV = cameraOffsetUV + _WorldSpaceCameraPos.xy;
    cameraOffsetUV = mad(cameraOffsetUV, _ScrollSpeed.xy, input.uv);
    output.colorUV = cameraOffsetUV / _Scale.xy;
    output.spriteUV = input.uv;
    output.positionCS = mul(UNITY_MATRIX_VP, worldPosition);
    output.color = input.color * _Color;
    return output;
}

struct ScrollingSpriteFragmentInput
{
    float2 spriteUV : TEXCOORD0;
    float2 colorUV : TEXCOORD1;
    float4 color : COLOR0;
};

// Captured fragment: 880906e0afdff8b3a13c6f30ba01038525fd69d82773972ce1723a9fa4e821a1.
float4 RecoveryFragment(ScrollingSpriteFragmentInput input) : SV_Target0
{
    float spriteAlpha = _MainTex.Sample(sampler_MainTex, input.spriteUV).a;
    float4 colorTexture = _ColorTex.Sample(sampler_ColorTex, input.colorUV);
    float colorAlpha = colorTexture.a;
    // Preserve both alpha factors and their original multiplication order.
    float4 maskedColor = float4(spriteAlpha, spriteAlpha, spriteAlpha, colorAlpha) * colorTexture;
    maskedColor = float4(colorAlpha, colorAlpha, colorAlpha, spriteAlpha) * maskedColor;
    return maskedColor * input.color;
}
            ENDHLSL
        }
    }
}
