// Sprite texture with vertex tint: HardLight.
// Each intermediate is a separate float value; captured operation order is preserved.
float4 UIBlendFragment(UIBlendFragmentInput input) : SV_Target0
{
    float4 outputColor;
    float4 spriteSample = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    float4 alphaAndMidpointOffsets = mad(spriteSample.wxyz, input.color.wxyz, float4(-0.00999999978, -0.5, -0.5, -0.5));
    float4 sourceAlphaRGB = spriteSample.wxyz * input.color.wxyz;
    bool belowAlphaThreshold = alphaAndMidpointOffsets.x < 0.0;
    float3 doubledInverseSource = mad((-alphaAndMidpointOffsets.yzw), float3(2.0, 2.0, 2.0), float3(1.0, 1.0, 1.0));
    if (belowAlphaThreshold)
    {
        discard;
    }

    // Project the captured clip interpolator after interpolation; keep the
    // original division, offset and Y flip order for GrabPass sampling.
    float2 ndcPosition = input.grabPositionCS.xy / input.grabPositionCS.ww;
    float2 grabOffset = ndcPosition + float2(1.0, 1.0);
    float grabU = grabOffset.x * 0.5;
    float grabV = mad((-grabOffset.y), 0.5, 1.0);
    float3 backgroundColor = UI_BLEND_BACKGROUND_TEXTURE.Sample(UI_BLEND_BACKGROUND_SAMPLER, float2(grabU, grabV)).xyz;
    float3 inverseBackground = (-backgroundColor) + float3(1.0, 1.0, 1.0);
    float3 screenBlend = mad((-inverseBackground), doubledInverseSource, float3(1.0, 1.0, 1.0));
    float multiplyBlendR = dot(backgroundColor.xx, sourceAlphaRGB.yy);
    bool3 sourceAboveMidpoint = (float3(0.5, 0.5, 0.5) < sourceAlphaRGB.yzw);
    outputColor.x = (sourceAboveMidpoint.x) ? screenBlend.x : multiplyBlendR;
    float multiplyBlendG = dot(backgroundColor.yy, sourceAlphaRGB.zz);
    float multiplyBlendB = dot(backgroundColor.zz, sourceAlphaRGB.ww);
    outputColor.w = sourceAlphaRGB.x;
    outputColor.y = (sourceAboveMidpoint.y) ? screenBlend.y : multiplyBlendG;
    outputColor.z = (sourceAboveMidpoint.z) ? screenBlend.z : multiplyBlendB;
    return outputColor;
}
