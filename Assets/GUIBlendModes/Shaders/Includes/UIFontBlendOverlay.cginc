// Font atlas alpha with vertex tint: Overlay.
// Each intermediate is a separate float value; captured operation order is preserved.
float4 UIBlendFragment(UIBlendFragmentInput input) : SV_Target0
{
    float4 outputColor;
    float fontAtlasAlpha = _MainTex.Sample(sampler_MainTex, input.uv.xy).w;
    float alphaThreshold = mad(input.color.w, fontAtlasAlpha, -0.00999999978);
    float opacity = fontAtlasAlpha * input.color.w;
    outputColor.w = opacity;
    bool belowAlphaThreshold = alphaThreshold < 0.0;
    if (belowAlphaThreshold)
    {
        discard;
    }

    float3 inverseSource = (-input.color.xyz) + float3(1.0, 1.0, 1.0);
    // Project the captured clip interpolator after interpolation; keep the
    // original division, offset and Y flip order for GrabPass sampling.
    float2 ndcPosition = input.grabPositionCS.xy / input.grabPositionCS.ww;
    float2 grabOffset = ndcPosition + float2(1.0, 1.0);
    float grabU = grabOffset.x * 0.5;
    float grabV = mad((-grabOffset.y), 0.5, 1.0);
    float3 backgroundColor = UI_BLEND_BACKGROUND_TEXTURE.Sample(UI_BLEND_BACKGROUND_SAMPLER, float2(grabU, grabV)).xyz;
    float3 backgroundMidpointOffset = backgroundColor + float3(-0.5, -0.5, -0.5);
    float3 doubledInverseBackground = mad((-backgroundMidpointOffset), float3(2.0, 2.0, 2.0), float3(1.0, 1.0, 1.0));
    float3 screenBlend = mad((-doubledInverseBackground), inverseSource, float3(1.0, 1.0, 1.0));
    float multiplyBlendR = dot(input.color.xx, backgroundColor.xx);
    bool3 backgroundAboveMidpoint = (float3(0.5, 0.5, 0.5) < backgroundColor);
    outputColor.x = (backgroundAboveMidpoint.x) ? screenBlend.x : multiplyBlendR;
    float multiplyBlendG = dot(input.color.yy, backgroundColor.yy);
    float multiplyBlendB = dot(input.color.zz, backgroundColor.zz);
    outputColor.y = (backgroundAboveMidpoint.y) ? screenBlend.y : multiplyBlendG;
    outputColor.z = (backgroundAboveMidpoint.z) ? screenBlend.z : multiplyBlendB;
    return outputColor;
}
