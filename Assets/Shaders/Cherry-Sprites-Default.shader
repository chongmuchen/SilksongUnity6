// Reconstructed from the licensed GOG macOS 1.0.30000 captured Metal programs.
// Reconstructed by tools/shader_reconstruction/shaderlab_generator.py; refactored for readability.
// Original serialized Shader SHA256: 7f98c44ce99da01340773b199c0d665c6f64e8c0ae9083b0bde1166cdbc9ec8a
// Properties, render states, texture samplers, and retained variants come from the original data.
// Extra keyword combinations select a captured variant; see batch-generation-manifest.json.
Shader "Sprites/Cherry-Default"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
    }
    SubShader
    {
        Tags { "CanUseSpriteAtlas"="true" "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Tags { "CanUseSpriteAtlas"="true" "IGNOREPROJECTOR"="true" "PreviewType"="Plane" "QUEUE"="Transparent" "RenderType"="Transparent" }
            Cull Off
            ZClip On
            ZTest LEqual
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Blend One OneMinusSrcAlpha
            BlendOp Add
            ColorMask RGBA
            HLSLPROGRAM
            #pragma target 4.5
            #pragma vertex RecoveryVertex
            #pragma fragment RecoveryFragment
            #pragma multi_compile __ DITHERING_NOISE
            #pragma multi_compile __ PIXELSNAP_ON

            #include "UnityCG.cginc"

            float4 _Color;
            Texture2D<float4> _MainTex;
            SamplerState sampler_MainTex;

            struct VertexInput
            {
                float4 position : POSITION0;
                float4 color : COLOR0;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 position : SV_POSITION;
                float4 color : COLOR0;
                float2 uv : TEXCOORD0;
            };

            // Captured vertex programs: unsnapped 4c427b1893dd1578a0cd519683fa421379edda04c9eb362bf2198edee4f8c2f7;
            // pixel snapped 41cd6bd0f0343bc71996009a612b3849d5cb9991381b704b19840a5c27ca3043.
            Varyings RecoveryVertex(VertexInput input)
            {
                Varyings output;
                output.position = UnityObjectToClipPos(input.position);
                #if defined(PIXELSNAP_ON)
                    #if SHADER_API_PSSL
                        // UnityPixelSnap uses legacy floor rounding on PSSL; the recovered shader uses round.
                        float2 halfResolution = _ScreenParams.xy * 0.5;
                        float2 pixelPosition = round((output.position.xy / output.position.w) * halfResolution);
                        output.position.xy = (pixelPosition / halfResolution) * output.position.w;
                    #else
                        output.position = UnityPixelSnap(output.position);
                    #endif
                #endif
                output.color = input.color * _Color;
                output.uv = input.uv;
                return output;
            }

            #if defined(DITHERING_NOISE)
                float CalculateDitherNoise(float2 pixelPosition)
                {
                    float noise = dot(pixelPosition, float2(0.0671105608, 0.00583714992));
                    noise = frac(noise);
                    noise = noise * 52.9829178;
                    noise = frac(noise);
                    return mad(noise, 0.00392156886, -0.00196078443);
                }
            #endif

            // Captured fragment programs: plain 92b4503c90c55b3d8cf3b639c99946fdac78af98f136e539c618c82c0b1863ca;
            // dithered aa49a8f77badff32d8685abe4b0d4f1dbf12ce377e8ad082f2c18c79779f89a9.
            float4 RecoveryFragment(Varyings input) : SV_Target0
            {
                #if defined(DITHERING_NOISE)
                    float noise = CalculateDitherNoise(input.position.xy);
                #endif

                float4 color = _MainTex.Sample(sampler_MainTex, input.uv);
                color = color * input.color;
                color.rgb = color.aaa * color.rgb;

                #if defined(DITHERING_NOISE)
                    // The captured shader adds noise to alpha as well as premultiplied RGB.
                    color = noise.xxxx + color;
                #endif
                return color;
            }
            ENDHLSL
        }
    }
}
