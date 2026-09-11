// Font atlas alpha with vertex tint: LinearBurn.
// Each intermediate is a separate float value; captured operation order is preserved.
float4 UIBlendFragment(UIBlendFragmentInput input) : SV_Target0
{
    float4 outputColor;
    float fontAtlasAlpha = _MainTex.Sample(sampler_MainTex, input.uv.xy).w;
    float alphaThreshold = mad(input.color.w, fontAtlasAlpha, -0.00999999978);
    float opacity = fontAtlasAlpha * input.color.w;
    bool belowAlphaThreshold = alphaThreshold < 0.0;
    if (belowAlphaThreshold)
    {
        discard;
    }

    float3 sourceColor = input.color.xyz;
    outputColor = (-float4(sourceColor.x, sourceColor.y, sourceColor.z, opacity)) + float4(1.0, 1.0, 1.0, 1.0);
    return outputColor;
}
