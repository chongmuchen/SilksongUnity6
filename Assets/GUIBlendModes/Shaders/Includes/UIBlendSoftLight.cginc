// Sprite texture with vertex tint: SoftLight.
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

    float3 inverseSource = mad((-spriteSample.xyz), input.color.xyz, float3(1.0, 1.0, 1.0));
    float4 sourceColor = spriteSample * input.color;
    // Project the captured clip interpolator after interpolation; keep the
    // original division, offset and Y flip order for GrabPass sampling.
    float2 ndcPosition = input.grabPositionCS.xy / input.grabPositionCS.ww;
    float2 grabOffset = ndcPosition + float2(1.0, 1.0);
    float grabU = grabOffset.x * 0.5;
    float grabV = mad((-grabOffset.y), 0.5, 1.0);
    float3 backgroundColor = UI_BLEND_BACKGROUND_TEXTURE.Sample(UI_BLEND_BACKGROUND_SAMPLER, float2(grabU, grabV)).xyz;
    float3 inverseBackground = (-backgroundColor) + float3(1.0, 1.0, 1.0);
    float3 screenColor = mad((-inverseBackground), inverseSource, float3(1.0, 1.0, 1.0));
    float3 backgroundContrast = backgroundColor * inverseBackground;
    float3 screenWeighted = screenColor * backgroundColor;
    outputColor.xyz = mad(backgroundContrast, sourceColor.xyz, screenWeighted);
    outputColor.w = sourceColor.w;
    return outputColor;
}
