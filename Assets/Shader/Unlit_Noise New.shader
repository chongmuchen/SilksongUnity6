// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Reconstructed by tools/shader_reconstruction/shaderlab_generator.py; refactored for readability.
// Original serialized Shader SHA256: a65fca4427c09b67593eb8b696e24c58ccbfa76db8b712ee76b456ce13115910
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Unlit/Noise New"
{
    Properties
    {
        _MainTex ("Sprite Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseColor ("Noise Color", Vector) = (1, 1, 1, 1)
        _NoiseStrength ("Noise Strength", Float) = 0.5
        _TimeSnap ("Time Snap", Float) = 0.5
    }
    SubShader
    {
        LOD 100
        Tags { "RenderType"="Opaque" }
        Pass
        {
            Tags { "RenderType"="Opaque" }
            Cull Back
            ZClip On
            ZTest LEqual
            ZWrite On
            Offset 0, 0
            AlphaToMask Off
            Blend One Zero
            BlendOp Add
            ColorMask RGBA
            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex RecoveryVertex
            #pragma fragment RecoveryFragment

            #include "UnityCG.cginc"

            Texture2D<float4> _MainTex;
            Texture2D<float4> _NoiseTex;
            SamplerState sampler_MainTex;
            SamplerState sampler_NoiseTex;
            float4 _NoiseColor;
            float _NoiseStrength;
            float _TimeSnap;

            struct VertexInput
            {
                float4 position : POSITION0;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                float4 position : SV_POSITION;
            };

            // Captured vertex program: 61592c8aa19fff65c9fdc95331afa338916ce0fa6e5852e26a2378e2075dd421.
            Varyings RecoveryVertex(VertexInput input)
            {
                Varyings output;
                output.uv = input.uv;
                output.position = UnityObjectToClipPos(input.position);
                return output;
            }

            // Captured fragment program: 4d7614fa3fd0290933088eb6cf261ae151cca7ef8e4def27f49977d774bfd75e.
            float4 RecoveryFragment(Varyings input) : SV_Target0
            {
                // Keep the captured time channels, rounding, hash constants and operation order.
                float2 snappedTime = _Time.zx / _TimeSnap;
                snappedTime = round(snappedTime);
                snappedTime = snappedTime * _TimeSnap;
                float phaseX = dot(snappedTime, float2(127.099998, 311.700012));
                float phaseY = dot(snappedTime, float2(269.5, 183.300003));
                float2 noiseOffset;
                noiseOffset.y = sin(phaseY);
                noiseOffset.x = sin(phaseX);
                noiseOffset = noiseOffset * float2(43758.5469, 43758.5469);
                noiseOffset = frac(noiseOffset);
                noiseOffset = mad(noiseOffset, float2(2.0, 2.0), float2(-1.0, -1.0));
                float2 noiseUV = mad(noiseOffset, float2(162.184998, 162.184998), input.uv);

                float noise = _NoiseTex.Sample(sampler_NoiseTex, noiseUV).r;
                noise = noise + -0.5;
                noise = noise * _NoiseStrength;
                float3 noiseTint = mad(_NoiseColor.rgb, noise.xxx, float3(1.0, 1.0, 1.0));
                float4 color = _MainTex.Sample(sampler_MainTex, input.uv);
                color.rgb = noiseTint * color.rgb;
                color.rgb = clamp(color.rgb, 0.0f, 1.0f);
                return color;
            }
            ENDHLSL
        }
    }
}
