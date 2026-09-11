// Sprite texture with vertex tint: Exclusion.
// Each intermediate is a separate float value; captured operation order is preserved.
float4 UIBlendFragment(UIBlendFragmentInput input) : SV_Target0
{
    float4 outputColor;
    float4 spriteSample = _MainTex.Sample(sampler_MainTex, input.uv.xy);
    float alphaThreshold = mad(spriteSample.w, input.color.w, -0.00999999978);
    bool belowAlphaThreshold = alphaThreshold < 0.0;
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
    float3 colorSum = mad(spriteSample.xyz, input.color.xyz, backgroundColor);
    float4 sourceColor = spriteSample * input.color;
    float twiceProductR = dot(sourceColor.xx, backgroundColor.xx);
    outputColor.x = (-twiceProductR) + colorSum.x;
    float twiceProductG = dot(sourceColor.yy, backgroundColor.yy);
    float twiceProductB = dot(sourceColor.zz, backgroundColor.zz);
    outputColor.w = sourceColor.w;
    outputColor.yz = (-float2(twiceProductG, twiceProductB)) + colorSum.yz;
    return outputColor;
}
