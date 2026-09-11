// Font atlas alpha with vertex tint: VividLight.
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
    float3 inverseBackground = (-backgroundColor) + float3(1.0, 1.0, 1.0);
    float3 burnDenominator = input.color.xyz + input.color.xyz;
    float3 burnRatio = inverseBackground / burnDenominator;
    float3 burnBranch = (-burnRatio) + float3(1.0, 1.0, 1.0);
    float3 sourceMidpointOffset = input.color.xyz + float3(-0.5, -0.5, -0.5);
    float3 dodgeDenominator = mad((-sourceMidpointOffset), float3(2.0, 2.0, 2.0), float3(1.0, 1.0, 1.0));
    float3 dodgeBranch = backgroundColor / dodgeDenominator;
    bool3 sourceAboveMidpoint = (float3(0.5, 0.5, 0.5) < input.color.xyz);
    outputColor.x = (sourceAboveMidpoint.x) ? dodgeBranch.x : burnBranch.x;
    outputColor.y = (sourceAboveMidpoint.y) ? dodgeBranch.y : burnBranch.y;
    outputColor.z = (sourceAboveMidpoint.z) ? dodgeBranch.z : burnBranch.z;
    return outputColor;
}
