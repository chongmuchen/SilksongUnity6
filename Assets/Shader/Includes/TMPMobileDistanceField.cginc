// Shared recovered mobile distance-field program.
// Interface names explain packed channels; arithmetic temporaries and operation order
// remain unchanged so check_tmp.py can verify each expanded variant token-for-token.

#if (defined(UNDERLAY_ON))

// Underlay enabled.
// Original Metal program SHA256: vertex 0a7c410bedacd740cd688b0a21280e50c2c4808143d7c2cc11d320eb669070a9; fragment 199aaa8a670eb5465a21364af81ba5d296428efc7e70c6ec319ae8a3733fcde1.
#include "UnityCG.cginc"

float4 _ClipRect;
float4 _FaceColor;
float _FaceDilate;
float _GradientScale;
Texture2D<float4> _MainTex;
float _MaskSoftnessX;
float _MaskSoftnessY;
float4 _OutlineColor;
float _OutlineSoftness;
float _OutlineWidth;
float _PerspectiveFilter;
float _ScaleRatioA;
float _ScaleRatioC;
float _ScaleX;
float _ScaleY;
float _TextureHeight;
float _TextureWidth;
float4 _UnderlayColor;
float _UnderlayDilate;
float _UnderlayOffsetX;
float _UnderlayOffsetY;
float _UnderlaySoftness;
float _VertexOffsetX;
float _VertexOffsetY;
float _WeightBold;
float _WeightNormal;
SamplerState sampler_MainTex;

struct TMPMobileDistanceFieldVertexInput
{
    float4 positionOS : POSITION0;
    float3 normalOS : NORMAL0;
    float4 vertexTint : COLOR0;
    float2 atlasUV : TEXCOORD0;
    float2 packedUVAndScale : TEXCOORD1; // x: packed secondary UV; y: signed distance scale / bold selection.
};

struct TMPMobileDistanceFieldVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 faceColor : COLOR0;
    float4 outlineBlendColor : COLOR1;
    float4 atlasAndMaskUV : TEXCOORD0; // xy: font atlas UV; zw: normalized rectangle UV.
    float4 distanceParams : TEXCOORD1; // x: distance scale; yz: outline thresholds; w: face bias.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
    float4 underlayUVAndAlpha : TEXCOORD3; // xy: shifted atlas UV; z: original vertex alpha; w: unused.
    float2 underlayScaleBias : TEXCOORD4; // x: underlay distance scale; y: distance bias.
};

TMPMobileDistanceFieldVertexOutput TMPMobileDistanceFieldVertex(TMPMobileDistanceFieldVertexInput input)
{
    TMPMobileDistanceFieldVertexOutput output;
    float2 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    float4 u_xlat5;
    float4 u_xlat6;
    float3 u_xlat7;
    float2 u_xlat8;
    float u_xlat14;
    float u_xlat21;
    bool u_xlatb21;

    // Apply glyph offsets and preserve the captured world/clip transform.
    u_xlat0.xy = input.positionOS.xy + float2(_VertexOffsetX, _VertexOffsetY);
    u_xlat1 = u_xlat0.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat1 = mad(transpose(unity_ObjectToWorld)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + transpose(unity_ObjectToWorld)[3];
    u_xlat1.xyz = mad(transpose(unity_ObjectToWorld)[3].xyz, input.positionOS.www, u_xlat1.xyz);
    u_xlat1.xyz = (-u_xlat1.xyz) + _WorldSpaceCameraPos.xyzx.xyz;
    u_xlat3 = u_xlat2.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat3 = mad(transpose(unity_MatrixVP)[0], u_xlat2.xxxx, u_xlat3);
    u_xlat3 = mad(transpose(unity_MatrixVP)[2], u_xlat2.zzzz, u_xlat3);
    u_xlat2 = mad(transpose(unity_MatrixVP)[3], u_xlat2.wwww, u_xlat3);
    output.positionCS = u_xlat2;
    output.faceColor.w = _FaceColor.w;
    u_xlat3.xyz = input.vertexTint.xyz;
    u_xlat3.w = 1.0;
    u_xlat4 = u_xlat3 * _FaceColor;
    u_xlat2.xyz = u_xlat4.www * u_xlat4.xyz;
    output.faceColor.xyz = u_xlat2.xyz;
    u_xlat5.xyz = (-u_xlat2.xyz);
    u_xlat5.w = (-u_xlat4.w);
    u_xlat6.xyz = _OutlineColor.www * _OutlineColor.xyz;
    u_xlat6.w = _OutlineColor.w;
    u_xlat5 = u_xlat5 + u_xlat6;
    u_xlat14 = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat14 = rsqrt(u_xlat14);
    u_xlat1.xyz = ((float3)(u_xlat14)) * u_xlat1.xyz;

    // View-facing scale controls distance smoothing under perspective.
    u_xlat2.x = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[0].xyz);
    u_xlat2.y = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[1].xyz);
    u_xlat2.z = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[2].xyz);
    u_xlat14 = dot(u_xlat2.xyz, u_xlat2.xyz);
    u_xlat14 = rsqrt(u_xlat14);
    u_xlat2.xyz = ((float3)(u_xlat14)) * u_xlat2.xyz;
    u_xlat14 = dot(u_xlat2.xyz, u_xlat1.xyz);

    // Derive screen-pixel size and the reciprocal soft-mask edge widths.
    u_xlat1.xy = _ScreenParams.yy * transpose(UNITY_MATRIX_P)[1].xy;
    u_xlat1.xy = mad(transpose(UNITY_MATRIX_P)[0].xy, _ScreenParams.xx, u_xlat1.xy);
    u_xlat1.xy = abs(u_xlat1.xy) * float2(_ScaleX, _ScaleY);
    u_xlat1.xy = u_xlat2.ww / u_xlat1.xy;
    u_xlat21 = dot(u_xlat1.xy, u_xlat1.xy);
    u_xlat1.xy = mad(float2(_MaskSoftnessX, _MaskSoftnessY), float2(0.25, 0.25), u_xlat1.xy);
    output.softMask.zw = float2(0.25, 0.25) / u_xlat1.xy;
    u_xlat21 = rsqrt(u_xlat21);
    u_xlat1.x = abs(input.packedUVAndScale.y) * _GradientScale;
    u_xlat21 = u_xlat21 * u_xlat1.x;
    u_xlat1.x = u_xlat21 * 1.5;
    u_xlat8.x = (-_PerspectiveFilter) + 1.0;
    u_xlat8.x = u_xlat8.x * abs(u_xlat1.x);
    u_xlat21 = mad(u_xlat21, 1.5, (-u_xlat8.x));
    u_xlat14 = mad(abs(u_xlat14), u_xlat21, u_xlat8.x);
    u_xlatb21 = transpose(UNITY_MATRIX_P)[3].w==0.0;
    u_xlat14 = (u_xlatb21) ? u_xlat14 : u_xlat1.x;
    u_xlat1.xy = float2(_FaceDilate, _OutlineSoftness) * ((float2)(_ScaleRatioA));
    u_xlat21 = mad(u_xlat1.y, u_xlat14, 1.0);
    u_xlat2.x = u_xlat14 / u_xlat21;
    u_xlat21 = _OutlineWidth * _ScaleRatioA;
    u_xlat21 = u_xlat2.x * u_xlat21;
    u_xlat8.x = min(u_xlat21, 1.0);
    u_xlat8.x = sqrt(u_xlat8.x);
    u_xlat5 = u_xlat5 * u_xlat8.xxxx;
    output.outlineBlendColor.xyz = mad(u_xlat4.xyz, u_xlat4.www, u_xlat5.xyz);
    output.outlineBlendColor.w = mad(u_xlat3.w, _FaceColor.w, u_xlat5.w);

    // Build the centered soft rectangle, retaining the captured clamp range.
    u_xlat3 = max(_ClipRect, float4(-2e+10, -2e+10, -2e+10, -2e+10));
    u_xlat3 = min(u_xlat3, float4(2e+10, 2e+10, 2e+10, 2e+10));
    u_xlat8.xy = u_xlat0.xy + (-u_xlat3.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), (-u_xlat3.xy));
    output.softMask.xy = (-u_xlat3.zw) + u_xlat0.xy;
    u_xlat0.xy = (-u_xlat3.xy) + u_xlat3.zw;
    output.atlasAndMaskUV.zw = u_xlat8.xy / u_xlat0.xy;
    output.atlasAndMaskUV.xy = input.atlasUV.xy;
    u_xlatb0 = 0.0>=input.packedUVAndScale.y;
    u_xlat0.x = u_xlatb0 ? 1.0 : float(0.0);

    // Select normal/bold glyph weight and account for face dilation.
    u_xlat7.x = (-_WeightNormal) + _WeightBold;
    u_xlat0.x = mad(u_xlat0.x, u_xlat7.x, _WeightNormal);
    u_xlat0.x = u_xlat0.x / _GradientScale;
    u_xlat0.x = mad(u_xlat1.x, 0.5, u_xlat0.x);
    u_xlat0.x = (-u_xlat0.x) + 0.5;
    u_xlat2.w = mad(u_xlat0.x, u_xlat2.x, -0.5);
    output.distanceParams.xw = u_xlat2.xw;
    output.distanceParams.y = mad((-u_xlat21), 0.5, u_xlat2.w);
    output.distanceParams.z = mad(u_xlat21, 0.5, u_xlat2.w);
    output.underlayUVAndAlpha.z = input.vertexTint.w;
    output.underlayUVAndAlpha.w = 0.0;

    // Compute shifted underlay atlas coordinates and distance scale/bias.
    u_xlat1 = float4(_UnderlaySoftness, _UnderlayDilate, _UnderlayOffsetX, _UnderlayOffsetY) * ((float4)(_ScaleRatioC));
    u_xlat7.xz = (-u_xlat1.zw) * ((float2)(_GradientScale));
    u_xlat7.xz = u_xlat7.xz / float2(_TextureWidth, _TextureHeight);
    output.underlayUVAndAlpha.xy = u_xlat7.xz + input.atlasUV.xy;
    u_xlat7.x = mad(u_xlat1.x, u_xlat14, 1.0);
    u_xlat7.x = u_xlat14 / u_xlat7.x;
    u_xlat14 = u_xlat7.x * u_xlat1.y;
    u_xlat0.x = mad(u_xlat0.x, u_xlat7.x, -0.5);
    output.underlayScaleBias.x = u_xlat7.x;
    output.underlayScaleBias.y = mad((-u_xlat14), 0.5, u_xlat0.x);
    return output;
}

struct TMPMobileDistanceFieldFragmentInput
{
    float4 faceColor : COLOR0;
    float4 atlasAndMaskUV : TEXCOORD0; // xy: font atlas UV; zw: normalized rectangle UV.
    float4 distanceParams : TEXCOORD1; // x: distance scale; yz: outline thresholds; w: face bias.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
    float4 underlayUVAndAlpha : TEXCOORD3; // xy: shifted atlas UV; z: original vertex alpha; w: unused.
    float2 underlayScaleBias : TEXCOORD4; // x: underlay distance scale; y: distance bias.
};

struct TMPMobileDistanceFieldFragmentOutput
{
    float4 color : SV_Target0;
};

TMPMobileDistanceFieldFragmentOutput TMPMobileDistanceFieldFragment(TMPMobileDistanceFieldFragmentInput input)
{
    TMPMobileDistanceFieldFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;

    // Sample the shifted underlay and composite it behind the face.
    u_xlat0.x = _MainTex.Sample(sampler_MainTex, input.underlayUVAndAlpha.xy).w;
    u_xlat0.x = mad(u_xlat0.x, input.underlayScaleBias.x, (-input.underlayScaleBias.y));
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat1.xyz = _UnderlayColor.www * _UnderlayColor.xyz;
    u_xlat1.w = _UnderlayColor.w;
    u_xlat0 = u_xlat0.xxxx * u_xlat1;

    // Evaluate the face/outline coverage from the font-atlas distance value.
    u_xlat1.x = _MainTex.Sample(sampler_MainTex, input.atlasAndMaskUV.xy).w;
    u_xlat1.x = mad(u_xlat1.x, input.distanceParams.x, (-input.distanceParams.w));
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat2 = u_xlat1.xxxx * input.faceColor;
    u_xlat1.x = mad((-input.faceColor.w), u_xlat1.x, 1.0);
    u_xlat0 = mad(u_xlat0, u_xlat1.xxxx, u_xlat2);

    // Multiply RGBA by soft rectangle coverage; this is not hard clipping.
    u_xlat1.xy = (-_ClipRect.xy) + _ClipRect.zw;
    u_xlat1.xy = u_xlat1.xy + -abs(input.softMask.xy);
    u_xlat1.xy = u_xlat1.xy * input.softMask.zw;
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.x = u_xlat1.y * u_xlat1.x;
    u_xlat0 = u_xlat0 * u_xlat1.xxxx;
    output.color = u_xlat0 * input.underlayUVAndAlpha.zzzz;
    return output;
}

#else

// Base distance field.
// Original Metal program SHA256: vertex 3614bdafcdb4808f6cee878ac7b8c8a1d631fcff3fe3f7612fd6bd3ab4ca10b9; fragment 3b2266366c118d352e6b61c8e1d0d8e3bd107832ee4b7cce4cb42b4e66711c29.
#include "UnityCG.cginc"

float4 _ClipRect;
float4 _FaceColor;
float _FaceDilate;
float _GradientScale;
Texture2D<float4> _MainTex;
float _MaskSoftnessX;
float _MaskSoftnessY;
float4 _OutlineColor;
float _OutlineSoftness;
float _OutlineWidth;
float _PerspectiveFilter;
float _ScaleRatioA;
float _ScaleX;
float _ScaleY;
float _VertexOffsetX;
float _VertexOffsetY;
float _WeightBold;
float _WeightNormal;
SamplerState sampler_MainTex;

struct TMPMobileDistanceFieldVertexInput
{
    float4 positionOS : POSITION0;
    float3 normalOS : NORMAL0;
    float4 vertexTint : COLOR0;
    float2 atlasUV : TEXCOORD0;
    float2 packedUVAndScale : TEXCOORD1; // x: packed secondary UV; y: signed distance scale / bold selection.
};

struct TMPMobileDistanceFieldVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 faceColor : COLOR0;
    float4 outlineBlendColor : COLOR1;
    float4 atlasAndMaskUV : TEXCOORD0; // xy: font atlas UV; zw: normalized rectangle UV.
    float4 distanceParams : TEXCOORD1; // x: distance scale; yz: outline thresholds; w: face bias.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
};

TMPMobileDistanceFieldVertexOutput TMPMobileDistanceFieldVertex(TMPMobileDistanceFieldVertexInput input)
{
    TMPMobileDistanceFieldVertexOutput output;
    float2 u_xlat0;
    bool u_xlatb0;
    float4 u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float4 u_xlat4;
    float u_xlat5;
    float2 u_xlat6;
    float u_xlat10;
    float u_xlat15;
    bool u_xlatb15;

    // Apply glyph offsets and preserve the captured world/clip transform.
    u_xlat0.xy = input.positionOS.xy + float2(_VertexOffsetX, _VertexOffsetY);
    u_xlat1 = u_xlat0.yyyy * transpose(unity_ObjectToWorld)[1];
    u_xlat1 = mad(transpose(unity_ObjectToWorld)[0], u_xlat0.xxxx, u_xlat1);
    u_xlat1 = mad(transpose(unity_ObjectToWorld)[2], input.positionOS.zzzz, u_xlat1);
    u_xlat2 = u_xlat1 + transpose(unity_ObjectToWorld)[3];
    u_xlat1.xyz = mad(transpose(unity_ObjectToWorld)[3].xyz, input.positionOS.www, u_xlat1.xyz);
    u_xlat1.xyz = (-u_xlat1.xyz) + _WorldSpaceCameraPos.xyzx.xyz;
    u_xlat3 = u_xlat2.yyyy * transpose(unity_MatrixVP)[1];
    u_xlat3 = mad(transpose(unity_MatrixVP)[0], u_xlat2.xxxx, u_xlat3);
    u_xlat3 = mad(transpose(unity_MatrixVP)[2], u_xlat2.zzzz, u_xlat3);
    u_xlat2 = mad(transpose(unity_MatrixVP)[3], u_xlat2.wwww, u_xlat3);
    output.positionCS = u_xlat2;
    u_xlat3 = input.vertexTint * _FaceColor;
    u_xlat3.xyz = u_xlat3.www * u_xlat3.xyz;
    output.faceColor = u_xlat3;
    u_xlat10 = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat10 = rsqrt(u_xlat10);
    u_xlat1.xyz = ((float3)(u_xlat10)) * u_xlat1.xyz;

    // View-facing scale controls distance smoothing under perspective.
    u_xlat2.x = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[0].xyz);
    u_xlat2.y = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[1].xyz);
    u_xlat2.z = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[2].xyz);
    u_xlat10 = dot(u_xlat2.xyz, u_xlat2.xyz);
    u_xlat10 = rsqrt(u_xlat10);
    u_xlat2.xyz = ((float3)(u_xlat10)) * u_xlat2.xyz;
    u_xlat10 = dot(u_xlat2.xyz, u_xlat1.xyz);

    // Derive screen-pixel size and the reciprocal soft-mask edge widths.
    u_xlat1.xy = _ScreenParams.yy * transpose(UNITY_MATRIX_P)[1].xy;
    u_xlat1.xy = mad(transpose(UNITY_MATRIX_P)[0].xy, _ScreenParams.xx, u_xlat1.xy);
    u_xlat1.xy = abs(u_xlat1.xy) * float2(_ScaleX, _ScaleY);
    u_xlat1.xy = u_xlat2.ww / u_xlat1.xy;
    u_xlat15 = dot(u_xlat1.xy, u_xlat1.xy);
    u_xlat1.xy = mad(float2(_MaskSoftnessX, _MaskSoftnessY), float2(0.25, 0.25), u_xlat1.xy);
    output.softMask.zw = float2(0.25, 0.25) / u_xlat1.xy;
    u_xlat15 = rsqrt(u_xlat15);
    u_xlat1.x = abs(input.packedUVAndScale.y) * _GradientScale;
    u_xlat15 = u_xlat15 * u_xlat1.x;
    u_xlat1.x = u_xlat15 * 1.5;
    u_xlat6.x = (-_PerspectiveFilter) + 1.0;
    u_xlat6.x = u_xlat6.x * abs(u_xlat1.x);
    u_xlat15 = mad(u_xlat15, 1.5, (-u_xlat6.x));
    u_xlat10 = mad(abs(u_xlat10), u_xlat15, u_xlat6.x);
    u_xlatb15 = transpose(UNITY_MATRIX_P)[3].w==0.0;
    u_xlat10 = (u_xlatb15) ? u_xlat10 : u_xlat1.x;
    u_xlat1.xy = float2(_FaceDilate, _OutlineSoftness) * ((float2)(_ScaleRatioA));
    u_xlat15 = mad(u_xlat1.y, u_xlat10, 1.0);
    u_xlat2.x = u_xlat10 / u_xlat15;
    u_xlat10 = _OutlineWidth * _ScaleRatioA;
    u_xlat10 = u_xlat2.x * u_xlat10;
    u_xlat15 = min(u_xlat10, 1.0);
    u_xlat15 = sqrt(u_xlat15);
    u_xlat4.w = input.vertexTint.w * _OutlineColor.w;
    u_xlat4.xyz = u_xlat4.www * _OutlineColor.xyz;
    u_xlat4 = (-u_xlat3) + u_xlat4;
    output.outlineBlendColor = mad(((float4)(u_xlat15)), u_xlat4, u_xlat3);

    // Build the centered soft rectangle, retaining the captured clamp range.
    u_xlat3 = max(_ClipRect, float4(-2e+10, -2e+10, -2e+10, -2e+10));
    u_xlat3 = min(u_xlat3, float4(2e+10, 2e+10, 2e+10, 2e+10));
    u_xlat6.xy = u_xlat0.xy + (-u_xlat3.xy);
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), (-u_xlat3.xy));
    output.softMask.xy = (-u_xlat3.zw) + u_xlat0.xy;
    u_xlat0.xy = (-u_xlat3.xy) + u_xlat3.zw;
    output.atlasAndMaskUV.zw = u_xlat6.xy / u_xlat0.xy;
    output.atlasAndMaskUV.xy = input.atlasUV.xy;
    u_xlatb0 = 0.0>=input.packedUVAndScale.y;
    u_xlat0.x = u_xlatb0 ? 1.0 : float(0.0);

    // Select normal/bold glyph weight and account for face dilation.
    u_xlat5 = (-_WeightNormal) + _WeightBold;
    u_xlat0.x = mad(u_xlat0.x, u_xlat5, _WeightNormal);
    u_xlat0.x = u_xlat0.x / _GradientScale;
    u_xlat0.x = mad(u_xlat1.x, 0.5, u_xlat0.x);
    u_xlat0.x = (-u_xlat0.x) + 0.5;
    u_xlat2.w = mad(u_xlat0.x, u_xlat2.x, -0.5);
    output.distanceParams.xw = u_xlat2.xw;
    output.distanceParams.y = mad((-u_xlat10), 0.5, u_xlat2.w);
    output.distanceParams.z = mad(u_xlat10, 0.5, u_xlat2.w);
    return output;
}

struct TMPMobileDistanceFieldFragmentInput
{
    float4 faceColor : COLOR0;
    float4 atlasAndMaskUV : TEXCOORD0; // xy: font atlas UV; zw: normalized rectangle UV.
    float4 distanceParams : TEXCOORD1; // x: distance scale; yz: outline thresholds; w: face bias.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
};

struct TMPMobileDistanceFieldFragmentOutput
{
    float4 color : SV_Target0;
};

TMPMobileDistanceFieldFragmentOutput TMPMobileDistanceFieldFragment(TMPMobileDistanceFieldFragmentInput input)
{
    TMPMobileDistanceFieldFragmentOutput output;
    float2 u_xlat0;
    float4 u_xlat1;
    float u_xlat2;

    // Multiply RGBA by soft rectangle coverage; this is not hard clipping.
    u_xlat0.xy = (-_ClipRect.xy) + _ClipRect.zw;
    u_xlat0.xy = u_xlat0.xy + -abs(input.softMask.xy);
    u_xlat0.xy = u_xlat0.xy * input.softMask.zw;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat0.x = u_xlat0.y * u_xlat0.x;

    // Evaluate the face/outline coverage from the font-atlas distance value.
    u_xlat2 = _MainTex.Sample(sampler_MainTex, input.atlasAndMaskUV.xy).w;
    u_xlat2 = mad(u_xlat2, input.distanceParams.x, (-input.distanceParams.w));
    u_xlat2 = clamp(u_xlat2, 0.0f, 1.0f);
    u_xlat1 = ((float4)(u_xlat2)) * input.faceColor;
    output.color = u_xlat0.xxxx * u_xlat1;
    return output;
}

#endif
