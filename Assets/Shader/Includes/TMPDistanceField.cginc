// Shared recovered distance-field program.
// Interface names explain packed channels; arithmetic temporaries and operation order
// remain unchanged so check_tmp.py can verify each expanded variant token-for-token.

#if (defined(GLOW_ON) && defined(UNDERLAY_ON))

// Glow and underlay enabled.
// Original Metal program SHA256: vertex 085e5b3b1055042e71eae85e3dba3e422326ae83db04a38e33fe9ddb3b8684c1; fragment 30f764111b4f164fda4f14611e763db499938dd7305f9ece85f004639dfd3401.
#include "UnityCG.cginc"

float4 _ClipRect;
float4x4 _EnvMatrix;
float4 _FaceColor;
float _FaceDilate;
Texture2D<float4> _FaceTex;
float _FaceUVSpeedX;
float _FaceUVSpeedY;
float4 _GlowColor;
float _GlowInner;
float _GlowOffset;
float _GlowOuter;
float _GlowPower;
float _GradientScale;
Texture2D<float4> _MainTex;
float _MaskSoftnessX;
float _MaskSoftnessY;
float4 _OutlineColor;
float _OutlineSoftness;
Texture2D<float4> _OutlineTex;
float _OutlineUVSpeedX;
float _OutlineUVSpeedY;
float _OutlineWidth;
float _PerspectiveFilter;
float _ScaleRatioA;
float _ScaleRatioB;
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
SamplerState sampler_FaceTex;
SamplerState sampler_MainTex;
SamplerState sampler_OutlineTex;

struct TMPDistanceFieldVertexInput
{
    float4 positionOS : POSITION0;
    float3 normalOS : NORMAL0;
    float4 vertexTint : COLOR0;
    float2 atlasUV : TEXCOORD0;
    float2 packedUVAndScale : TEXCOORD1; // x: packed secondary UV; y: signed distance scale / bold selection.
};

struct TMPDistanceFieldVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 vertexTint : COLOR0;
    float4 atlasAndSurfaceUV : TEXCOORD0; // xy: font atlas UV; zw: face/outline texture UV.
    float4 distanceParams : TEXCOORD1; // x: cutoff; y: distance scale; z: face threshold; w: glyph weight.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
    float3 viewDirectionEnv : TEXCOORD3;
    float4 underlayUVScaleBias : TEXCOORD4; // xy: shifted atlas UV; z: scale; w: distance bias.
    float4 underlayColor : COLOR1;
};

TMPDistanceFieldVertexOutput TMPDistanceFieldVertex(TMPDistanceFieldVertexInput input)
{
    TMPDistanceFieldVertexOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float u_xlat4;
    float3 u_xlat6;
    float2 u_xlat8;
    float u_xlat12;
    float u_xlat13;
    bool u_xlatb13;

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
    output.vertexTint = input.vertexTint;

    // Decode the packed secondary UV used by face and outline textures.
    u_xlat8.x = input.packedUVAndScale.x * 0.000244140625;
    u_xlat8.x = floor(u_xlat8.x);
    u_xlat8.y = mad((-u_xlat8.x), 4096.0, input.packedUVAndScale.x);
    output.atlasAndSurfaceUV.zw = u_xlat8.xy * float2(0.001953125, 0.001953125);
    output.atlasAndSurfaceUV.xy = input.atlasUV.xy;
    u_xlat8.x = mad((-_OutlineWidth), _ScaleRatioA, 1.0);
    u_xlat8.x = mad((-_OutlineSoftness), _ScaleRatioA, u_xlat8.x);
    u_xlat12 = mad((-_GlowOffset), _ScaleRatioB, 1.0);
    u_xlat12 = mad((-_GlowOuter), _ScaleRatioB, u_xlat12);
    u_xlat8.x = min(u_xlat12, u_xlat8.x);

    // View-facing scale controls distance smoothing under perspective.
    u_xlat2.x = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[0].xyz);
    u_xlat2.y = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[1].xyz);
    u_xlat2.z = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[2].xyz);
    u_xlat12 = dot(u_xlat2.xyz, u_xlat2.xyz);
    u_xlat12 = rsqrt(u_xlat12);
    u_xlat2.xyz = ((float3)(u_xlat12)) * u_xlat2.xyz;
    u_xlat12 = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat12 = rsqrt(u_xlat12);
    u_xlat3.xyz = ((float3)(u_xlat12)) * u_xlat1.xyz;
    u_xlat12 = dot(u_xlat2.xyz, u_xlat3.xyz);

    // Derive screen-pixel size and the reciprocal soft-mask edge widths.
    u_xlat2.xy = _ScreenParams.yy * transpose(UNITY_MATRIX_P)[1].xy;
    u_xlat2.xy = mad(transpose(UNITY_MATRIX_P)[0].xy, _ScreenParams.xx, u_xlat2.xy);
    u_xlat2.xy = abs(u_xlat2.xy) * float2(_ScaleX, _ScaleY);
    u_xlat2.xy = u_xlat2.ww / u_xlat2.xy;
    u_xlat13 = dot(u_xlat2.xy, u_xlat2.xy);
    u_xlat2.xy = mad(float2(_MaskSoftnessX, _MaskSoftnessY), float2(0.25, 0.25), u_xlat2.xy);
    output.softMask.zw = float2(0.25, 0.25) / u_xlat2.xy;
    u_xlat13 = rsqrt(u_xlat13);
    u_xlat2.x = abs(input.packedUVAndScale.y) * _GradientScale;
    u_xlat13 = u_xlat13 * u_xlat2.x;
    u_xlat2.x = u_xlat13 * 1.5;
    u_xlat6.x = (-_PerspectiveFilter) + 1.0;
    u_xlat6.x = u_xlat6.x * abs(u_xlat2.x);
    u_xlat13 = mad(u_xlat13, 1.5, (-u_xlat6.x));
    u_xlat12 = mad(abs(u_xlat12), u_xlat13, u_xlat6.x);
    u_xlatb13 = transpose(UNITY_MATRIX_P)[3].w==0.0;
    u_xlat6.x = (u_xlatb13) ? u_xlat12 : u_xlat2.x;
    u_xlat12 = 0.5 / u_xlat6.x;
    u_xlat8.x = mad(u_xlat8.x, 0.5, (-u_xlat12));
    u_xlatb13 = 0.0>=input.packedUVAndScale.y;
    u_xlat13 = u_xlatb13 ? 1.0 : float(0.0);

    // Select normal/bold glyph weight and account for face dilation.
    u_xlat2.x = (-_WeightNormal) + _WeightBold;
    u_xlat13 = mad(u_xlat13, u_xlat2.x, _WeightNormal);
    u_xlat13 = u_xlat13 / _GradientScale;
    u_xlat2.x = _FaceDilate * _ScaleRatioA;
    u_xlat6.z = mad(u_xlat2.x, 0.5, u_xlat13);
    output.distanceParams.x = u_xlat8.x + (-u_xlat6.z);
    output.distanceParams.yw = u_xlat6.xz;
    u_xlat8.x = (-u_xlat6.z) + 0.5;
    output.distanceParams.z = u_xlat12 + u_xlat8.x;

    // Build the centered soft rectangle, retaining the captured clamp range.
    u_xlat3 = max(_ClipRect, float4(-2e+10, -2e+10, -2e+10, -2e+10));
    u_xlat3 = min(u_xlat3, float4(2e+10, 2e+10, 2e+10, 2e+10));
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), (-u_xlat3.xy));
    output.softMask.xy = (-u_xlat3.zw) + u_xlat0.xy;
    u_xlat0.xyw = u_xlat1.yyy * transpose(_EnvMatrix)[1].xyz;
    u_xlat0.xyw = mad(transpose(_EnvMatrix)[0].xyz, u_xlat1.xxx, u_xlat0.xyw);
    output.viewDirectionEnv.xyz = mad(transpose(_EnvMatrix)[2].xyz, u_xlat1.zzz, u_xlat0.xyw);

    // Compute shifted underlay atlas coordinates and distance scale/bias.
    u_xlat1 = float4(_UnderlaySoftness, _UnderlayDilate, _UnderlayOffsetX, _UnderlayOffsetY) * ((float4)(_ScaleRatioC));
    u_xlat0.x = mad(u_xlat1.x, u_xlat6.x, 1.0);
    u_xlat0.x = u_xlat6.x / u_xlat0.x;
    u_xlat4 = mad(u_xlat8.x, u_xlat0.x, -0.5);
    u_xlat8.x = u_xlat0.x * u_xlat1.y;
    u_xlat1.xy = (-u_xlat1.zw) * ((float2)(_GradientScale));
    u_xlat1.xy = u_xlat1.xy / float2(_TextureWidth, _TextureHeight);
    output.underlayUVScaleBias.xy = u_xlat1.xy + input.atlasUV.xy;
    output.underlayUVScaleBias.z = u_xlat0.x;
    output.underlayUVScaleBias.w = mad((-u_xlat8.x), 0.5, u_xlat4);
    output.underlayColor.xyz = _UnderlayColor.www * _UnderlayColor.xyz;
    output.underlayColor.w = _UnderlayColor.w;
    return output;
}

struct TMPDistanceFieldFragmentInput
{
    float4 vertexTint : COLOR0;
    float4 atlasAndSurfaceUV : TEXCOORD0; // xy: font atlas UV; zw: face/outline texture UV.
    float4 distanceParams : TEXCOORD1; // x: cutoff; y: distance scale; z: face threshold; w: glyph weight.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
    float4 underlayUVScaleBias : TEXCOORD4; // xy: shifted atlas UV; z: scale; w: distance bias.
    float4 underlayColor : COLOR1;
};

struct TMPDistanceFieldFragmentOutput
{
    float4 color : SV_Target0;
};

TMPDistanceFieldFragmentOutput TMPDistanceFieldFragment(TMPDistanceFieldFragmentInput input)
{
    TMPDistanceFieldFragmentOutput output;
    float4 u_xlat0;
    float3 u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float u_xlat4;
    float2 u_xlat5;
    bool u_xlatb5;
    float2 u_xlat9;
    float u_xlat13;

    // Sample animated face/outline textures and form premultiplied colors.
    u_xlat0.xy = mad(float2(_OutlineUVSpeedX, _OutlineUVSpeedY), _Time.yy, input.atlasAndSurfaceUV.zw);
    u_xlat0 = _OutlineTex.Sample(sampler_OutlineTex, u_xlat0.xy);
    u_xlat0 = u_xlat0 * _OutlineColor;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.xyz = input.vertexTint.xyz * _FaceColor.xyz;
    u_xlat2.xy = mad(float2(_FaceUVSpeedX, _FaceUVSpeedY), _Time.yy, input.atlasAndSurfaceUV.zw);
    u_xlat2 = _FaceTex.Sample(sampler_FaceTex, u_xlat2.xy);
    u_xlat1.xyz = u_xlat1.xyz * u_xlat2.xyz;
    u_xlat2.w = u_xlat2.w * _FaceColor.w;
    u_xlat2.xyz = u_xlat1.xyz * u_xlat2.www;
    u_xlat0 = u_xlat0 + (-u_xlat2);
    u_xlat1.x = _OutlineWidth * _ScaleRatioA;
    u_xlat1.x = u_xlat1.x * input.distanceParams.y;
    u_xlat5.x = min(u_xlat1.x, 1.0);
    u_xlat1.x = u_xlat1.x * 0.5;
    u_xlat5.x = sqrt(u_xlat5.x);

    // Evaluate the face/outline coverage from the font-atlas distance value.
    u_xlat9.x = _MainTex.Sample(sampler_MainTex, input.atlasAndSurfaceUV.xy).w;
    u_xlat5.y = (-u_xlat9.x) + input.distanceParams.z;
    u_xlat13 = mad(u_xlat5.y, input.distanceParams.y, u_xlat1.x);
    u_xlat13 = clamp(u_xlat13, 0.0f, 1.0f);
    u_xlat1.x = mad(u_xlat5.y, input.distanceParams.y, (-u_xlat1.x));
    u_xlat5.x = u_xlat5.x * u_xlat13;
    u_xlat0 = mad(u_xlat5.xxxx, u_xlat0, u_xlat2);
    u_xlat5.x = _OutlineSoftness * _ScaleRatioA;
    u_xlat9.xy = u_xlat5.yx * input.distanceParams.yy;
    u_xlat5.x = mad(u_xlat5.x, input.distanceParams.y, 1.0);
    u_xlat1.x = mad(u_xlat9.y, 0.5, u_xlat1.x);
    u_xlat1.x = u_xlat1.x / u_xlat5.x;
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat1.x = (-u_xlat1.x) + 1.0;
    u_xlat2 = u_xlat0 * u_xlat1.xxxx;
    u_xlat0.x = mad((-u_xlat0.w), u_xlat1.x, 1.0);

    // Sample the shifted underlay and composite it behind the face.
    u_xlat4 = _MainTex.Sample(sampler_MainTex, input.underlayUVScaleBias.xy).w;
    u_xlat4 = mad(u_xlat4, input.underlayUVScaleBias.z, (-input.underlayUVScaleBias.w));
    u_xlat4 = clamp(u_xlat4, 0.0f, 1.0f);
    u_xlat3 = ((float4)(u_xlat4)) * input.underlayColor;
    u_xlat0 = mad(u_xlat3, u_xlat0.xxxx, u_xlat2);

    // Evaluate the captured glow falloff, including its log2/exp2 power curve.
    u_xlat1.x = _GlowOffset * _ScaleRatioB;
    u_xlat1.x = u_xlat1.x * input.distanceParams.y;
    u_xlat1.x = mad((-u_xlat1.x), 0.5, u_xlat9.x);
    u_xlatb5 = u_xlat1.x>=0.0;
    u_xlat5.x = u_xlatb5 ? 1.0 : float(0.0);
    u_xlat9.x = mad(_GlowOuter, _ScaleRatioB, (-_GlowInner));
    u_xlat5.x = mad(u_xlat5.x, u_xlat9.x, _GlowInner);
    u_xlat5.x = u_xlat5.x * input.distanceParams.y;
    u_xlat9.x = mad(u_xlat5.x, 0.5, 1.0);
    u_xlat5.x = u_xlat5.x * 0.5;
    u_xlat5.x = min(u_xlat5.x, 1.0);
    u_xlat5.x = sqrt(u_xlat5.x);
    u_xlat1.x = u_xlat1.x / u_xlat9.x;
    u_xlat1.x = min(abs(u_xlat1.x), 1.0);
    u_xlat1.x = log2(u_xlat1.x);
    u_xlat1.x = u_xlat1.x * _GlowPower;
    u_xlat1.x = exp2(u_xlat1.x);
    u_xlat1.x = (-u_xlat1.x) + 1.0;
    u_xlat1.x = u_xlat5.x * u_xlat1.x;
    u_xlat1.x = dot(_GlowColor.ww, u_xlat1.xx);
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat0.xyz = mad(_GlowColor.xyz, u_xlat1.xxx, u_xlat0.xyz);

    // Multiply RGBA by soft rectangle coverage; this is not hard clipping.
    u_xlat1.xy = (-_ClipRect.xy) + _ClipRect.zw;
    u_xlat1.xy = u_xlat1.xy + -abs(input.softMask.xy);
    u_xlat1.xy = u_xlat1.xy * input.softMask.zw;
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.x = u_xlat1.y * u_xlat1.x;
    u_xlat0 = u_xlat0 * u_xlat1.xxxx;
    output.color = u_xlat0 * input.vertexTint.wwww;
    return output;
}

#elif (!defined(GLOW_ON) && !defined(UNDERLAY_ON))

// Base distance field.
// Original Metal program SHA256: vertex 40482df73e2ae1fec766b588c03e0ec53741720cadd21f76de9995ed730508e2; fragment 2cbedfae1d0eb84cb75f8d7017c54cef162677c88823dce77195923b65ae786e.
#include "UnityCG.cginc"

float4 _ClipRect;
float4x4 _EnvMatrix;
float4 _FaceColor;
float _FaceDilate;
Texture2D<float4> _FaceTex;
float _FaceUVSpeedX;
float _FaceUVSpeedY;
float _GradientScale;
Texture2D<float4> _MainTex;
float _MaskSoftnessX;
float _MaskSoftnessY;
float4 _OutlineColor;
float _OutlineSoftness;
Texture2D<float4> _OutlineTex;
float _OutlineUVSpeedX;
float _OutlineUVSpeedY;
float _OutlineWidth;
float _PerspectiveFilter;
float _ScaleRatioA;
float _ScaleX;
float _ScaleY;
float _VertexOffsetX;
float _VertexOffsetY;
float _WeightBold;
float _WeightNormal;
SamplerState sampler_FaceTex;
SamplerState sampler_MainTex;
SamplerState sampler_OutlineTex;

struct TMPDistanceFieldVertexInput
{
    float4 positionOS : POSITION0;
    float3 normalOS : NORMAL0;
    float4 vertexTint : COLOR0;
    float2 atlasUV : TEXCOORD0;
    float2 packedUVAndScale : TEXCOORD1; // x: packed secondary UV; y: signed distance scale / bold selection.
};

struct TMPDistanceFieldVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 vertexTint : COLOR0;
    float4 atlasAndSurfaceUV : TEXCOORD0; // xy: font atlas UV; zw: face/outline texture UV.
    float4 distanceParams : TEXCOORD1; // x: cutoff; y: distance scale; z: face threshold; w: glyph weight.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
    float3 viewDirectionEnv : TEXCOORD3;
};

TMPDistanceFieldVertexOutput TMPDistanceFieldVertex(TMPDistanceFieldVertexInput input)
{
    TMPDistanceFieldVertexOutput output;
    float3 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float3 u_xlat6;
    float2 u_xlat8;
    bool u_xlatb8;
    float u_xlat12;
    bool u_xlatb12;
    float u_xlat13;

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
    output.vertexTint = input.vertexTint;

    // Decode the packed secondary UV used by face and outline textures.
    u_xlat8.x = input.packedUVAndScale.x * 0.000244140625;
    u_xlat8.x = floor(u_xlat8.x);
    u_xlat8.y = mad((-u_xlat8.x), 4096.0, input.packedUVAndScale.x);
    output.atlasAndSurfaceUV.zw = u_xlat8.xy * float2(0.001953125, 0.001953125);
    output.atlasAndSurfaceUV.xy = input.atlasUV.xy;

    // View-facing scale controls distance smoothing under perspective.
    u_xlat2.x = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[0].xyz);
    u_xlat2.y = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[1].xyz);
    u_xlat2.z = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[2].xyz);
    u_xlat8.x = dot(u_xlat2.xyz, u_xlat2.xyz);
    u_xlat8.x = rsqrt(u_xlat8.x);
    u_xlat2.xyz = u_xlat8.xxx * u_xlat2.xyz;
    u_xlat8.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat8.x = rsqrt(u_xlat8.x);
    u_xlat3.xyz = u_xlat8.xxx * u_xlat1.xyz;
    u_xlat8.x = dot(u_xlat2.xyz, u_xlat3.xyz);

    // Derive screen-pixel size and the reciprocal soft-mask edge widths.
    u_xlat2.xy = _ScreenParams.yy * transpose(UNITY_MATRIX_P)[1].xy;
    u_xlat2.xy = mad(transpose(UNITY_MATRIX_P)[0].xy, _ScreenParams.xx, u_xlat2.xy);
    u_xlat2.xy = abs(u_xlat2.xy) * float2(_ScaleX, _ScaleY);
    u_xlat2.xy = u_xlat2.ww / u_xlat2.xy;
    u_xlat12 = dot(u_xlat2.xy, u_xlat2.xy);
    u_xlat2.xy = mad(float2(_MaskSoftnessX, _MaskSoftnessY), float2(0.25, 0.25), u_xlat2.xy);
    output.softMask.zw = float2(0.25, 0.25) / u_xlat2.xy;
    u_xlat12 = rsqrt(u_xlat12);
    u_xlat13 = abs(input.packedUVAndScale.y) * _GradientScale;
    u_xlat12 = u_xlat12 * u_xlat13;
    u_xlat13 = u_xlat12 * 1.5;
    u_xlat2.x = (-_PerspectiveFilter) + 1.0;
    u_xlat2.x = abs(u_xlat13) * u_xlat2.x;
    u_xlat12 = mad(u_xlat12, 1.5, (-u_xlat2.x));
    u_xlat8.x = mad(abs(u_xlat8.x), u_xlat12, u_xlat2.x);
    u_xlatb12 = transpose(UNITY_MATRIX_P)[3].w==0.0;
    u_xlat6.x = (u_xlatb12) ? u_xlat8.x : u_xlat13;
    u_xlatb8 = 0.0>=input.packedUVAndScale.y;
    u_xlat8.x = u_xlatb8 ? 1.0 : float(0.0);

    // Select normal/bold glyph weight and account for face dilation.
    u_xlat12 = (-_WeightNormal) + _WeightBold;
    u_xlat8.x = mad(u_xlat8.x, u_xlat12, _WeightNormal);
    u_xlat8.x = u_xlat8.x / _GradientScale;
    u_xlat12 = _FaceDilate * _ScaleRatioA;
    u_xlat6.z = mad(u_xlat12, 0.5, u_xlat8.x);
    output.distanceParams.yw = u_xlat6.xz;
    u_xlat8.x = 0.5 / u_xlat6.x;
    u_xlat12 = mad((-_OutlineWidth), _ScaleRatioA, 1.0);
    u_xlat12 = mad((-_OutlineSoftness), _ScaleRatioA, u_xlat12);
    u_xlat12 = mad(u_xlat12, 0.5, (-u_xlat8.x));
    output.distanceParams.x = (-u_xlat6.z) + u_xlat12;
    u_xlat12 = (-u_xlat6.z) + 0.5;
    output.distanceParams.z = u_xlat8.x + u_xlat12;

    // Build the centered soft rectangle, retaining the captured clamp range.
    u_xlat2 = max(_ClipRect, float4(-2e+10, -2e+10, -2e+10, -2e+10));
    u_xlat2 = min(u_xlat2, float4(2e+10, 2e+10, 2e+10, 2e+10));
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), (-u_xlat2.xy));
    output.softMask.xy = (-u_xlat2.zw) + u_xlat0.xy;
    u_xlat0.xyz = u_xlat1.yyy * transpose(_EnvMatrix)[1].xyz;
    u_xlat0.xyz = mad(transpose(_EnvMatrix)[0].xyz, u_xlat1.xxx, u_xlat0.xyz);
    output.viewDirectionEnv.xyz = mad(transpose(_EnvMatrix)[2].xyz, u_xlat1.zzz, u_xlat0.xyz);
    return output;
}

struct TMPDistanceFieldFragmentInput
{
    float4 vertexTint : COLOR0;
    float4 atlasAndSurfaceUV : TEXCOORD0; // xy: font atlas UV; zw: face/outline texture UV.
    float4 distanceParams : TEXCOORD1; // x: cutoff; y: distance scale; z: face threshold; w: glyph weight.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
};

struct TMPDistanceFieldFragmentOutput
{
    float4 color : SV_Target0;
};

TMPDistanceFieldFragmentOutput TMPDistanceFieldFragment(TMPDistanceFieldFragmentInput input)
{
    TMPDistanceFieldFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float3 u_xlat2;
    float4 u_xlat3;
    float u_xlat4;
    bool u_xlatb4;
    float2 u_xlat8;
    float u_xlat12;

    // Evaluate the face/outline coverage from the font-atlas distance value.
    u_xlat0.x = _MainTex.Sample(sampler_MainTex, input.atlasAndSurfaceUV.xy).w;
    u_xlat4 = u_xlat0.x + (-input.distanceParams.x);
    u_xlat0.x = (-u_xlat0.x) + input.distanceParams.z;
    u_xlatb4 = u_xlat4<0.0;
    if(((int(u_xlatb4) * int(0xffffffffu)))!=0){discard;}
    u_xlat4 = _OutlineWidth * _ScaleRatioA;
    u_xlat4 = u_xlat4 * input.distanceParams.y;
    u_xlat8.x = min(u_xlat4, 1.0);
    u_xlat4 = u_xlat4 * 0.5;
    u_xlat8.x = sqrt(u_xlat8.x);
    u_xlat12 = mad(u_xlat0.x, input.distanceParams.y, u_xlat4);
    u_xlat12 = clamp(u_xlat12, 0.0f, 1.0f);
    u_xlat0.x = mad(u_xlat0.x, input.distanceParams.y, (-u_xlat4));
    u_xlat4 = u_xlat8.x * u_xlat12;

    // Sample animated face/outline textures and form premultiplied colors.
    u_xlat8.xy = mad(float2(_OutlineUVSpeedX, _OutlineUVSpeedY), _Time.yy, input.atlasAndSurfaceUV.zw);
    u_xlat1 = _OutlineTex.Sample(sampler_OutlineTex, u_xlat8.xy);
    u_xlat1 = u_xlat1 * _OutlineColor;
    u_xlat1.xyz = u_xlat1.www * u_xlat1.xyz;
    u_xlat2.xyz = input.vertexTint.xyz * _FaceColor.xyz;
    u_xlat8.xy = mad(float2(_FaceUVSpeedX, _FaceUVSpeedY), _Time.yy, input.atlasAndSurfaceUV.zw);
    u_xlat3 = _FaceTex.Sample(sampler_FaceTex, u_xlat8.xy);
    u_xlat2.xyz = u_xlat2.xyz * u_xlat3.xyz;
    u_xlat3.w = u_xlat3.w * _FaceColor.w;
    u_xlat3.xyz = u_xlat2.xyz * u_xlat3.www;
    u_xlat1 = u_xlat1 + (-u_xlat3);
    u_xlat1 = mad(((float4)(u_xlat4)), u_xlat1, u_xlat3);
    u_xlat4 = _OutlineSoftness * _ScaleRatioA;
    u_xlat8.x = u_xlat4 * input.distanceParams.y;
    u_xlat4 = mad(u_xlat4, input.distanceParams.y, 1.0);
    u_xlat0.x = mad(u_xlat8.x, 0.5, u_xlat0.x);
    u_xlat0.x = u_xlat0.x / u_xlat4;
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat0.x = (-u_xlat0.x) + 1.0;
    u_xlat0 = u_xlat0.xxxx * u_xlat1;

    // Multiply RGBA by soft rectangle coverage; this is not hard clipping.
    u_xlat1.xy = (-_ClipRect.xy) + _ClipRect.zw;
    u_xlat1.xy = u_xlat1.xy + -abs(input.softMask.xy);
    u_xlat1.xy = u_xlat1.xy * input.softMask.zw;
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.x = u_xlat1.y * u_xlat1.x;
    u_xlat0 = u_xlat0 * u_xlat1.xxxx;
    output.color = u_xlat0 * input.vertexTint.wwww;
    return output;
}

#elif (!defined(GLOW_ON) && defined(UNDERLAY_ON))

// Underlay enabled.
// Original Metal program SHA256: vertex a46bcbe2699f5abf9c16b74f1104419bba4f1fb773494ebffa6966b772c96607; fragment 7c54a05c073787b85e403568afe61d72b825ce57fdf2f7cc7aede9ddf51b45e1.
#include "UnityCG.cginc"

float4 _ClipRect;
float4x4 _EnvMatrix;
float4 _FaceColor;
float _FaceDilate;
Texture2D<float4> _FaceTex;
float _FaceUVSpeedX;
float _FaceUVSpeedY;
float _GradientScale;
Texture2D<float4> _MainTex;
float _MaskSoftnessX;
float _MaskSoftnessY;
float4 _OutlineColor;
float _OutlineSoftness;
Texture2D<float4> _OutlineTex;
float _OutlineUVSpeedX;
float _OutlineUVSpeedY;
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
SamplerState sampler_FaceTex;
SamplerState sampler_MainTex;
SamplerState sampler_OutlineTex;

struct TMPDistanceFieldVertexInput
{
    float4 positionOS : POSITION0;
    float3 normalOS : NORMAL0;
    float4 vertexTint : COLOR0;
    float2 atlasUV : TEXCOORD0;
    float2 packedUVAndScale : TEXCOORD1; // x: packed secondary UV; y: signed distance scale / bold selection.
};

struct TMPDistanceFieldVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 vertexTint : COLOR0;
    float4 atlasAndSurfaceUV : TEXCOORD0; // xy: font atlas UV; zw: face/outline texture UV.
    float4 distanceParams : TEXCOORD1; // x: cutoff; y: distance scale; z: face threshold; w: glyph weight.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
    float3 viewDirectionEnv : TEXCOORD3;
    float4 underlayUVScaleBias : TEXCOORD4; // xy: shifted atlas UV; z: scale; w: distance bias.
    float4 underlayColor : COLOR1;
};

TMPDistanceFieldVertexOutput TMPDistanceFieldVertex(TMPDistanceFieldVertexInput input)
{
    TMPDistanceFieldVertexOutput output;
    float3 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float u_xlat4;
    float3 u_xlat6;
    float2 u_xlat8;
    bool u_xlatb8;
    float u_xlat12;
    bool u_xlatb12;
    float u_xlat13;

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
    output.vertexTint = input.vertexTint;

    // Decode the packed secondary UV used by face and outline textures.
    u_xlat8.x = input.packedUVAndScale.x * 0.000244140625;
    u_xlat8.x = floor(u_xlat8.x);
    u_xlat8.y = mad((-u_xlat8.x), 4096.0, input.packedUVAndScale.x);
    output.atlasAndSurfaceUV.zw = u_xlat8.xy * float2(0.001953125, 0.001953125);
    output.atlasAndSurfaceUV.xy = input.atlasUV.xy;

    // View-facing scale controls distance smoothing under perspective.
    u_xlat2.x = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[0].xyz);
    u_xlat2.y = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[1].xyz);
    u_xlat2.z = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[2].xyz);
    u_xlat8.x = dot(u_xlat2.xyz, u_xlat2.xyz);
    u_xlat8.x = rsqrt(u_xlat8.x);
    u_xlat2.xyz = u_xlat8.xxx * u_xlat2.xyz;
    u_xlat8.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat8.x = rsqrt(u_xlat8.x);
    u_xlat3.xyz = u_xlat8.xxx * u_xlat1.xyz;
    u_xlat8.x = dot(u_xlat2.xyz, u_xlat3.xyz);

    // Derive screen-pixel size and the reciprocal soft-mask edge widths.
    u_xlat2.xy = _ScreenParams.yy * transpose(UNITY_MATRIX_P)[1].xy;
    u_xlat2.xy = mad(transpose(UNITY_MATRIX_P)[0].xy, _ScreenParams.xx, u_xlat2.xy);
    u_xlat2.xy = abs(u_xlat2.xy) * float2(_ScaleX, _ScaleY);
    u_xlat2.xy = u_xlat2.ww / u_xlat2.xy;
    u_xlat12 = dot(u_xlat2.xy, u_xlat2.xy);
    u_xlat2.xy = mad(float2(_MaskSoftnessX, _MaskSoftnessY), float2(0.25, 0.25), u_xlat2.xy);
    output.softMask.zw = float2(0.25, 0.25) / u_xlat2.xy;
    u_xlat12 = rsqrt(u_xlat12);
    u_xlat13 = abs(input.packedUVAndScale.y) * _GradientScale;
    u_xlat12 = u_xlat12 * u_xlat13;
    u_xlat13 = u_xlat12 * 1.5;
    u_xlat2.x = (-_PerspectiveFilter) + 1.0;
    u_xlat2.x = abs(u_xlat13) * u_xlat2.x;
    u_xlat12 = mad(u_xlat12, 1.5, (-u_xlat2.x));
    u_xlat8.x = mad(abs(u_xlat8.x), u_xlat12, u_xlat2.x);
    u_xlatb12 = transpose(UNITY_MATRIX_P)[3].w==0.0;
    u_xlat6.x = (u_xlatb12) ? u_xlat8.x : u_xlat13;
    u_xlatb8 = 0.0>=input.packedUVAndScale.y;
    u_xlat8.x = u_xlatb8 ? 1.0 : float(0.0);

    // Select normal/bold glyph weight and account for face dilation.
    u_xlat12 = (-_WeightNormal) + _WeightBold;
    u_xlat8.x = mad(u_xlat8.x, u_xlat12, _WeightNormal);
    u_xlat8.x = u_xlat8.x / _GradientScale;
    u_xlat12 = _FaceDilate * _ScaleRatioA;
    u_xlat6.z = mad(u_xlat12, 0.5, u_xlat8.x);
    output.distanceParams.yw = u_xlat6.xz;
    u_xlat8.x = 0.5 / u_xlat6.x;
    u_xlat12 = mad((-_OutlineWidth), _ScaleRatioA, 1.0);
    u_xlat12 = mad((-_OutlineSoftness), _ScaleRatioA, u_xlat12);
    u_xlat12 = mad(u_xlat12, 0.5, (-u_xlat8.x));
    output.distanceParams.x = (-u_xlat6.z) + u_xlat12;
    u_xlat12 = (-u_xlat6.z) + 0.5;
    output.distanceParams.z = u_xlat8.x + u_xlat12;

    // Build the centered soft rectangle, retaining the captured clamp range.
    u_xlat3 = max(_ClipRect, float4(-2e+10, -2e+10, -2e+10, -2e+10));
    u_xlat3 = min(u_xlat3, float4(2e+10, 2e+10, 2e+10, 2e+10));
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), (-u_xlat3.xy));
    output.softMask.xy = (-u_xlat3.zw) + u_xlat0.xy;
    u_xlat0.xyz = u_xlat1.yyy * transpose(_EnvMatrix)[1].xyz;
    u_xlat0.xyz = mad(transpose(_EnvMatrix)[0].xyz, u_xlat1.xxx, u_xlat0.xyz);
    output.viewDirectionEnv.xyz = mad(transpose(_EnvMatrix)[2].xyz, u_xlat1.zzz, u_xlat0.xyz);

    // Compute shifted underlay atlas coordinates and distance scale/bias.
    u_xlat1 = float4(_UnderlaySoftness, _UnderlayDilate, _UnderlayOffsetX, _UnderlayOffsetY) * ((float4)(_ScaleRatioC));
    u_xlat0.x = mad(u_xlat1.x, u_xlat6.x, 1.0);
    u_xlat0.x = u_xlat6.x / u_xlat0.x;
    u_xlat4 = mad(u_xlat12, u_xlat0.x, -0.5);
    u_xlat8.x = u_xlat0.x * u_xlat1.y;
    u_xlat1.xy = (-u_xlat1.zw) * ((float2)(_GradientScale));
    u_xlat1.xy = u_xlat1.xy / float2(_TextureWidth, _TextureHeight);
    output.underlayUVScaleBias.xy = u_xlat1.xy + input.atlasUV.xy;
    output.underlayUVScaleBias.z = u_xlat0.x;
    output.underlayUVScaleBias.w = mad((-u_xlat8.x), 0.5, u_xlat4);
    output.underlayColor.xyz = _UnderlayColor.www * _UnderlayColor.xyz;
    output.underlayColor.w = _UnderlayColor.w;
    return output;
}

struct TMPDistanceFieldFragmentInput
{
    float4 vertexTint : COLOR0;
    float4 atlasAndSurfaceUV : TEXCOORD0; // xy: font atlas UV; zw: face/outline texture UV.
    float4 distanceParams : TEXCOORD1; // x: cutoff; y: distance scale; z: face threshold; w: glyph weight.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
    float4 underlayUVScaleBias : TEXCOORD4; // xy: shifted atlas UV; z: scale; w: distance bias.
    float4 underlayColor : COLOR1;
};

struct TMPDistanceFieldFragmentOutput
{
    float4 color : SV_Target0;
};

TMPDistanceFieldFragmentOutput TMPDistanceFieldFragment(TMPDistanceFieldFragmentInput input)
{
    TMPDistanceFieldFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float u_xlat3;
    float u_xlat4;
    float u_xlat7;
    float u_xlat10;

    // Sample animated face/outline textures and form premultiplied colors.
    u_xlat0.xy = mad(float2(_OutlineUVSpeedX, _OutlineUVSpeedY), _Time.yy, input.atlasAndSurfaceUV.zw);
    u_xlat0 = _OutlineTex.Sample(sampler_OutlineTex, u_xlat0.xy);
    u_xlat0 = u_xlat0 * _OutlineColor;
    u_xlat0.xyz = u_xlat0.www * u_xlat0.xyz;
    u_xlat1.xyz = input.vertexTint.xyz * _FaceColor.xyz;
    u_xlat2.xy = mad(float2(_FaceUVSpeedX, _FaceUVSpeedY), _Time.yy, input.atlasAndSurfaceUV.zw);
    u_xlat2 = _FaceTex.Sample(sampler_FaceTex, u_xlat2.xy);
    u_xlat1.xyz = u_xlat1.xyz * u_xlat2.xyz;
    u_xlat2.w = u_xlat2.w * _FaceColor.w;
    u_xlat2.xyz = u_xlat1.xyz * u_xlat2.www;
    u_xlat0 = u_xlat0 + (-u_xlat2);
    u_xlat1.x = _OutlineWidth * _ScaleRatioA;
    u_xlat1.x = u_xlat1.x * input.distanceParams.y;
    u_xlat4 = min(u_xlat1.x, 1.0);
    u_xlat1.x = u_xlat1.x * 0.5;
    u_xlat4 = sqrt(u_xlat4);

    // Evaluate the face/outline coverage from the font-atlas distance value.
    u_xlat7 = _MainTex.Sample(sampler_MainTex, input.atlasAndSurfaceUV.xy).w;
    u_xlat7 = (-u_xlat7) + input.distanceParams.z;
    u_xlat10 = mad(u_xlat7, input.distanceParams.y, u_xlat1.x);
    u_xlat10 = clamp(u_xlat10, 0.0f, 1.0f);
    u_xlat1.x = mad(u_xlat7, input.distanceParams.y, (-u_xlat1.x));
    u_xlat4 = u_xlat4 * u_xlat10;
    u_xlat0 = mad(((float4)(u_xlat4)), u_xlat0, u_xlat2);
    u_xlat4 = _OutlineSoftness * _ScaleRatioA;
    u_xlat7 = u_xlat4 * input.distanceParams.y;
    u_xlat4 = mad(u_xlat4, input.distanceParams.y, 1.0);
    u_xlat1.x = mad(u_xlat7, 0.5, u_xlat1.x);
    u_xlat1.x = u_xlat1.x / u_xlat4;
    u_xlat1.x = clamp(u_xlat1.x, 0.0f, 1.0f);
    u_xlat1.x = (-u_xlat1.x) + 1.0;
    u_xlat2 = u_xlat0 * u_xlat1.xxxx;
    u_xlat0.x = mad((-u_xlat0.w), u_xlat1.x, 1.0);

    // Sample the shifted underlay and composite it behind the face.
    u_xlat3 = _MainTex.Sample(sampler_MainTex, input.underlayUVScaleBias.xy).w;
    u_xlat3 = mad(u_xlat3, input.underlayUVScaleBias.z, (-input.underlayUVScaleBias.w));
    u_xlat3 = clamp(u_xlat3, 0.0f, 1.0f);
    u_xlat1 = ((float4)(u_xlat3)) * input.underlayColor;
    u_xlat0 = mad(u_xlat1, u_xlat0.xxxx, u_xlat2);

    // Multiply RGBA by soft rectangle coverage; this is not hard clipping.
    u_xlat1.xy = (-_ClipRect.xy) + _ClipRect.zw;
    u_xlat1.xy = u_xlat1.xy + -abs(input.softMask.xy);
    u_xlat1.xy = u_xlat1.xy * input.softMask.zw;
    u_xlat1.xy = clamp(u_xlat1.xy, 0.0f, 1.0f);
    u_xlat1.x = u_xlat1.y * u_xlat1.x;
    u_xlat0 = u_xlat0 * u_xlat1.xxxx;
    output.color = u_xlat0 * input.vertexTint.wwww;
    return output;
}

#else

// Glow enabled.
// Original Metal program SHA256: vertex f412afe1ae1a396879f681452ab4d06aff6989542a248cfe082ea7d622b0f268; fragment 26a75d1d15465b448d501353517b75fa15fee884241403750ddfa22482f99887.
#include "UnityCG.cginc"

float4 _ClipRect;
float4x4 _EnvMatrix;
float4 _FaceColor;
float _FaceDilate;
Texture2D<float4> _FaceTex;
float _FaceUVSpeedX;
float _FaceUVSpeedY;
float4 _GlowColor;
float _GlowInner;
float _GlowOffset;
float _GlowOuter;
float _GlowPower;
float _GradientScale;
Texture2D<float4> _MainTex;
float _MaskSoftnessX;
float _MaskSoftnessY;
float4 _OutlineColor;
float _OutlineSoftness;
Texture2D<float4> _OutlineTex;
float _OutlineUVSpeedX;
float _OutlineUVSpeedY;
float _OutlineWidth;
float _PerspectiveFilter;
float _ScaleRatioA;
float _ScaleRatioB;
float _ScaleX;
float _ScaleY;
float _VertexOffsetX;
float _VertexOffsetY;
float _WeightBold;
float _WeightNormal;
SamplerState sampler_FaceTex;
SamplerState sampler_MainTex;
SamplerState sampler_OutlineTex;

struct TMPDistanceFieldVertexInput
{
    float4 positionOS : POSITION0;
    float3 normalOS : NORMAL0;
    float4 vertexTint : COLOR0;
    float2 atlasUV : TEXCOORD0;
    float2 packedUVAndScale : TEXCOORD1; // x: packed secondary UV; y: signed distance scale / bold selection.
};

struct TMPDistanceFieldVertexOutput
{
    float4 positionCS : SV_POSITION;
    float4 vertexTint : COLOR0;
    float4 atlasAndSurfaceUV : TEXCOORD0; // xy: font atlas UV; zw: face/outline texture UV.
    float4 distanceParams : TEXCOORD1; // x: cutoff; y: distance scale; z: face threshold; w: glyph weight.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
    float3 viewDirectionEnv : TEXCOORD3;
};

TMPDistanceFieldVertexOutput TMPDistanceFieldVertex(TMPDistanceFieldVertexInput input)
{
    TMPDistanceFieldVertexOutput output;
    float3 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float4 u_xlat3;
    float3 u_xlat6;
    float2 u_xlat8;
    bool u_xlatb8;
    float u_xlat12;
    bool u_xlatb12;
    float u_xlat13;

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
    output.vertexTint = input.vertexTint;

    // Decode the packed secondary UV used by face and outline textures.
    u_xlat8.x = input.packedUVAndScale.x * 0.000244140625;
    u_xlat8.x = floor(u_xlat8.x);
    u_xlat8.y = mad((-u_xlat8.x), 4096.0, input.packedUVAndScale.x);
    output.atlasAndSurfaceUV.zw = u_xlat8.xy * float2(0.001953125, 0.001953125);
    output.atlasAndSurfaceUV.xy = input.atlasUV.xy;

    // View-facing scale controls distance smoothing under perspective.
    u_xlat2.x = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[0].xyz);
    u_xlat2.y = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[1].xyz);
    u_xlat2.z = dot(input.normalOS.xyz, transpose(unity_WorldToObject)[2].xyz);
    u_xlat8.x = dot(u_xlat2.xyz, u_xlat2.xyz);
    u_xlat8.x = rsqrt(u_xlat8.x);
    u_xlat2.xyz = u_xlat8.xxx * u_xlat2.xyz;
    u_xlat8.x = dot(u_xlat1.xyz, u_xlat1.xyz);
    u_xlat8.x = rsqrt(u_xlat8.x);
    u_xlat3.xyz = u_xlat8.xxx * u_xlat1.xyz;
    u_xlat8.x = dot(u_xlat2.xyz, u_xlat3.xyz);

    // Derive screen-pixel size and the reciprocal soft-mask edge widths.
    u_xlat2.xy = _ScreenParams.yy * transpose(UNITY_MATRIX_P)[1].xy;
    u_xlat2.xy = mad(transpose(UNITY_MATRIX_P)[0].xy, _ScreenParams.xx, u_xlat2.xy);
    u_xlat2.xy = abs(u_xlat2.xy) * float2(_ScaleX, _ScaleY);
    u_xlat2.xy = u_xlat2.ww / u_xlat2.xy;
    u_xlat12 = dot(u_xlat2.xy, u_xlat2.xy);
    u_xlat2.xy = mad(float2(_MaskSoftnessX, _MaskSoftnessY), float2(0.25, 0.25), u_xlat2.xy);
    output.softMask.zw = float2(0.25, 0.25) / u_xlat2.xy;
    u_xlat12 = rsqrt(u_xlat12);
    u_xlat13 = abs(input.packedUVAndScale.y) * _GradientScale;
    u_xlat12 = u_xlat12 * u_xlat13;
    u_xlat13 = u_xlat12 * 1.5;
    u_xlat2.x = (-_PerspectiveFilter) + 1.0;
    u_xlat2.x = abs(u_xlat13) * u_xlat2.x;
    u_xlat12 = mad(u_xlat12, 1.5, (-u_xlat2.x));
    u_xlat8.x = mad(abs(u_xlat8.x), u_xlat12, u_xlat2.x);
    u_xlatb12 = transpose(UNITY_MATRIX_P)[3].w==0.0;
    u_xlat6.x = (u_xlatb12) ? u_xlat8.x : u_xlat13;
    u_xlatb8 = 0.0>=input.packedUVAndScale.y;
    u_xlat8.x = u_xlatb8 ? 1.0 : float(0.0);

    // Select normal/bold glyph weight and account for face dilation.
    u_xlat12 = (-_WeightNormal) + _WeightBold;
    u_xlat8.x = mad(u_xlat8.x, u_xlat12, _WeightNormal);
    u_xlat8.x = u_xlat8.x / _GradientScale;
    u_xlat12 = _FaceDilate * _ScaleRatioA;
    u_xlat6.z = mad(u_xlat12, 0.5, u_xlat8.x);
    output.distanceParams.yw = u_xlat6.xz;
    u_xlat8.x = 0.5 / u_xlat6.x;
    u_xlat12 = mad((-_OutlineWidth), _ScaleRatioA, 1.0);
    u_xlat12 = mad((-_OutlineSoftness), _ScaleRatioA, u_xlat12);
    u_xlat13 = mad((-_GlowOffset), _ScaleRatioB, 1.0);
    u_xlat13 = mad((-_GlowOuter), _ScaleRatioB, u_xlat13);
    u_xlat12 = min(u_xlat12, u_xlat13);
    u_xlat12 = mad(u_xlat12, 0.5, (-u_xlat8.x));
    output.distanceParams.x = (-u_xlat6.z) + u_xlat12;
    u_xlat12 = (-u_xlat6.z) + 0.5;
    output.distanceParams.z = u_xlat8.x + u_xlat12;

    // Build the centered soft rectangle, retaining the captured clamp range.
    u_xlat2 = max(_ClipRect, float4(-2e+10, -2e+10, -2e+10, -2e+10));
    u_xlat2 = min(u_xlat2, float4(2e+10, 2e+10, 2e+10, 2e+10));
    u_xlat0.xy = mad(u_xlat0.xy, float2(2.0, 2.0), (-u_xlat2.xy));
    output.softMask.xy = (-u_xlat2.zw) + u_xlat0.xy;
    u_xlat0.xyz = u_xlat1.yyy * transpose(_EnvMatrix)[1].xyz;
    u_xlat0.xyz = mad(transpose(_EnvMatrix)[0].xyz, u_xlat1.xxx, u_xlat0.xyz);
    output.viewDirectionEnv.xyz = mad(transpose(_EnvMatrix)[2].xyz, u_xlat1.zzz, u_xlat0.xyz);
    return output;
}

struct TMPDistanceFieldFragmentInput
{
    float4 vertexTint : COLOR0;
    float4 atlasAndSurfaceUV : TEXCOORD0; // xy: font atlas UV; zw: face/outline texture UV.
    float4 distanceParams : TEXCOORD1; // x: cutoff; y: distance scale; z: face threshold; w: glyph weight.
    float4 softMask : TEXCOORD2; // xy: centered rectangle position; zw: reciprocal soft-edge width.
};

struct TMPDistanceFieldFragmentOutput
{
    float4 color : SV_Target0;
};

TMPDistanceFieldFragmentOutput TMPDistanceFieldFragment(TMPDistanceFieldFragmentInput input)
{
    TMPDistanceFieldFragmentOutput output;
    float4 u_xlat0;
    float4 u_xlat1;
    float4 u_xlat2;
    float3 u_xlat3;
    bool u_xlatb3;
    float u_xlat6;
    float u_xlat9;

    // Evaluate the face/outline coverage from the font-atlas distance value.
    u_xlat0.x = _MainTex.Sample(sampler_MainTex, input.atlasAndSurfaceUV.xy).w;
    u_xlat3.x = u_xlat0.x + (-input.distanceParams.x);
    u_xlat0.x = (-u_xlat0.x) + input.distanceParams.z;
    u_xlatb3 = u_xlat3.x<0.0;
    if(((int(u_xlatb3) * int(0xffffffffu)))!=0){discard;}

    // Sample animated face/outline textures and form premultiplied colors.
    u_xlat3.xy = mad(float2(_OutlineUVSpeedX, _OutlineUVSpeedY), _Time.yy, input.atlasAndSurfaceUV.zw);
    u_xlat1 = _OutlineTex.Sample(sampler_OutlineTex, u_xlat3.xy);
    u_xlat1 = u_xlat1 * _OutlineColor;
    u_xlat1.xyz = u_xlat1.www * u_xlat1.xyz;
    u_xlat3.xyz = input.vertexTint.xyz * _FaceColor.xyz;
    u_xlat2.xy = mad(float2(_FaceUVSpeedX, _FaceUVSpeedY), _Time.yy, input.atlasAndSurfaceUV.zw);
    u_xlat2 = _FaceTex.Sample(sampler_FaceTex, u_xlat2.xy);
    u_xlat3.xyz = u_xlat3.xyz * u_xlat2.xyz;
    u_xlat2.w = u_xlat2.w * _FaceColor.w;
    u_xlat2.xyz = u_xlat3.xyz * u_xlat2.www;
    u_xlat1 = u_xlat1 + (-u_xlat2);
    u_xlat3.x = _OutlineWidth * _ScaleRatioA;
    u_xlat3.x = u_xlat3.x * input.distanceParams.y;
    u_xlat6 = min(u_xlat3.x, 1.0);
    u_xlat3.x = u_xlat3.x * 0.5;
    u_xlat6 = sqrt(u_xlat6);
    u_xlat9 = mad(u_xlat0.x, input.distanceParams.y, u_xlat3.x);
    u_xlat9 = clamp(u_xlat9, 0.0f, 1.0f);
    u_xlat3.x = mad(u_xlat0.x, input.distanceParams.y, (-u_xlat3.x));
    u_xlat6 = u_xlat6 * u_xlat9;
    u_xlat1 = mad(((float4)(u_xlat6)), u_xlat1, u_xlat2);
    u_xlat0.z = _OutlineSoftness * _ScaleRatioA;
    u_xlat0.xw = u_xlat0.xz * input.distanceParams.yy;
    u_xlat6 = mad(u_xlat0.z, input.distanceParams.y, 1.0);
    u_xlat3.x = mad(u_xlat0.w, 0.5, u_xlat3.x);
    u_xlat3.x = u_xlat3.x / u_xlat6;
    u_xlat3.x = clamp(u_xlat3.x, 0.0f, 1.0f);
    u_xlat3.x = (-u_xlat3.x) + 1.0;
    u_xlat1 = u_xlat3.xxxx * u_xlat1;

    // Evaluate the captured glow falloff, including its log2/exp2 power curve.
    u_xlat3.x = _GlowOffset * _ScaleRatioB;
    u_xlat3.x = u_xlat3.x * input.distanceParams.y;
    u_xlat0.x = mad((-u_xlat3.x), 0.5, u_xlat0.x);
    u_xlatb3 = u_xlat0.x>=0.0;
    u_xlat3.x = u_xlatb3 ? 1.0 : float(0.0);
    u_xlat6 = mad(_GlowOuter, _ScaleRatioB, (-_GlowInner));
    u_xlat3.x = mad(u_xlat3.x, u_xlat6, _GlowInner);
    u_xlat3.x = u_xlat3.x * input.distanceParams.y;
    u_xlat6 = mad(u_xlat3.x, 0.5, 1.0);
    u_xlat3.x = u_xlat3.x * 0.5;
    u_xlat3.x = min(u_xlat3.x, 1.0);
    u_xlat3.x = sqrt(u_xlat3.x);
    u_xlat0.x = u_xlat0.x / u_xlat6;
    u_xlat0.x = min(abs(u_xlat0.x), 1.0);
    u_xlat0.x = log2(u_xlat0.x);
    u_xlat0.x = u_xlat0.x * _GlowPower;
    u_xlat0.x = exp2(u_xlat0.x);
    u_xlat0.x = (-u_xlat0.x) + 1.0;
    u_xlat0.x = u_xlat3.x * u_xlat0.x;
    u_xlat0.x = dot(_GlowColor.ww, u_xlat0.xx);
    u_xlat0.x = clamp(u_xlat0.x, 0.0f, 1.0f);
    u_xlat1.xyz = mad(_GlowColor.xyz, u_xlat0.xxx, u_xlat1.xyz);

    // Multiply RGBA by soft rectangle coverage; this is not hard clipping.
    u_xlat0.xy = (-_ClipRect.xy) + _ClipRect.zw;
    u_xlat0.xy = u_xlat0.xy + -abs(input.softMask.xy);
    u_xlat0.xy = u_xlat0.xy * input.softMask.zw;
    u_xlat0.xy = clamp(u_xlat0.xy, 0.0f, 1.0f);
    u_xlat0.x = u_xlat0.y * u_xlat0.x;
    u_xlat0 = u_xlat0.xxxx * u_xlat1;
    output.color = u_xlat0 * input.vertexTint.wwww;
    return output;
}

#endif
