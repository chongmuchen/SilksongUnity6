// Font atlas alpha with vertex tint: PinLight.
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

    // Project the captured clip interpolator after interpolation; keep the
    // original division, offset and Y flip order for GrabPass sampling.
    float2 ndcPosition = input.grabPositionCS.xy / input.grabPositionCS.ww;
    float2 grabOffset = ndcPosition + float2(1.0, 1.0);
    float grabU = grabOffset.x * 0.5;
    float grabV = mad((-grabOffset.y), 0.5, 1.0);
    float3 backgroundColor = UI_BLEND_BACKGROUND_TEXTURE.Sample(UI_BLEND_BACKGROUND_SAMPLER, float2(grabU, grabV)).xyz;
    float3 sourceMidpointOffset = input.color.xyz + float3(-0.5, -0.5, -0.5);
    float3 doubledSourceOffset = sourceMidpointOffset + sourceMidpointOffset;
    float3 lightBranch = max(backgroundColor, doubledSourceOffset);
    float3 doubledSource = input.color.xyz + input.color.xyz;
    float3 darkBranch = min(backgroundColor, doubledSource);
    bool3 sourceAboveMidpoint = (float3(0.5, 0.5, 0.5) < input.color.xyz);
    outputColor.x = (sourceAboveMidpoint.x) ? lightBranch.x : darkBranch.x;
    outputColor.y = (sourceAboveMidpoint.y) ? lightBranch.y : darkBranch.y;
    outputColor.z = (sourceAboveMidpoint.z) ? lightBranch.z : darkBranch.z;
    return outputColor;
}
