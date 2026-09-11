// Shared UI blend inputs and vertex transform.
// Fragment includes preserve the captured blend equations and float precision.
#ifndef SILKSONG_UI_BLEND_COMMON_INCLUDED
#define SILKSONG_UI_BLEND_COMMON_INCLUDED

#include "UnityCG.cginc"

float4 _Color;
#if UI_BLEND_HAS_GRAB
Texture2D<float4> UI_BLEND_BACKGROUND_TEXTURE;
#endif
Texture2D<float4> _MainTex;
#if UI_BLEND_HAS_GRAB
SamplerState UI_BLEND_BACKGROUND_SAMPLER;
#endif
SamplerState sampler_MainTex;

struct UIBlendVertexInput
{
    float4 positionOS : POSITION0;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
};

struct UIBlendVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
#if UI_BLEND_HAS_GRAB
    float4 grabPositionCS : TEXCOORD1;
#endif
};

struct UIBlendFragmentInput
{
    float4 color : COLOR0;
    float2 uv : TEXCOORD0;
#if UI_BLEND_HAS_GRAB
    float4 grabPositionCS : TEXCOORD1;
#endif
};

UIBlendVertexOutput UIBlendVertex(UIBlendVertexInput input)
{
    UIBlendVertexOutput output;
    output.positionCS = UnityObjectToClipPos(input.positionOS);
    output.color = input.color * _Color;
    output.uv = input.uv;
#if UI_BLEND_HAS_GRAB
    // Keep clip coordinates interpolated exactly as the captured fragment expects.
    output.grabPositionCS = output.positionCS;
#endif
    return output;
}

#endif
