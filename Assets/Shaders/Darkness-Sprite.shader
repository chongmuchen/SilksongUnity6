// Reconstructed from the shipped macOS 1.0.30000 Shader object.
// Object: CAB-97c196524e31277b3e0b7f35a6c7bbe0:-300255841613570315
// SHA-256: 618f61ad1d741e5727eec21e8e208f67aae969f282192e39ac7950fc0033cd22
// Evidence: recovered/macos-programs/Sprites_Darkness_Sprite__618f61ad1d74/
// All 8 retained combinations / 16 Metal stage programs are represented.
// Stereo keyword names present in metadata but absent from the retained programs:
// STEREO_INSTANCING_ON, UNITY_SINGLE_PASS_STEREO,
// STEREO_MULTIVIEW_ON, STEREO_CUBEMAP_RENDER_ON. No missing algorithms are invented.
Shader "Sprites/Darkness Sprite"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [Toggle(IS_VIGNETTE)] _ReadRToggle ("Is Vignette", Float) = 0
        [Toggle(IS_MASK_BLACKOUT)] _ReadBToggle ("Is Mask Blackout", Float) = 0
        [Toggle(IS_SCENE_BORDER)] _ReadAToggle ("Is Scene Border", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "CanUseSpriteAtlas" = "true"
            "IGNOREPROJECTOR" = "true"
            "PreviewType" = "Plane"
            "QUEUE" = "Transparent"
            "RenderType" = "Transparent"
        }
        LOD 0

        Pass
        {
            Blend One OneMinusSrcAlpha, One OneMinusSrcAlpha
            BlendOp Add, Add
            ColorMask RGBA
            Cull Off
            Lighting Off
            ZClip On
            ZTest LEqual
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
            Fog { Mode Off }
            Stencil
            {
                Ref 0
                ReadMask 255
                WriteMask 255
                Comp Always
                Pass Keep
                Fail Keep
                ZFail Keep
            }

            CGPROGRAM
            #pragma target 2.0
            #pragma vertex RecoveredDarknessVert
            #pragma fragment RecoveredDarknessFrag
            // The supplied build retains these two alternatives, not all four booleans.
            #pragma multi_compile PIXELSNAP_ON DITHERING_NOISE
            #pragma multi_compile __ IS_VIGNETTE IS_MASK_BLACKOUT IS_SCENE_BORDER

            #include "UnityCG.cginc"

            float4 _Color;
            sampler2D _MainTex;
            // Both are original global uniforms controlled by DarknessCameraEffect.
            // They must not become material Properties that shadow the global values.
            float4x4 _DarknessCameraVP;
            sampler2D _DarknessCutout;

            struct RecoveredDarknessVertexInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct RecoveredDarknessVertexOutput
            {
                float4 position : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                float4 darknessScreenPosition : TEXCOORD1;
            };

            RecoveredDarknessVertexOutput RecoveredDarknessVert(RecoveredDarknessVertexInput input)
            {
                RecoveredDarknessVertexOutput output;
                // The original vertex code uses W=1 and has no _Flip/_RendererColor inputs.
                float4 objectPosition = float4(input.vertex.xyz, 1.0);
                output.position = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, objectPosition));

                #if defined(PIXELSNAP_ON)
                    float2 halfScreen = _ScreenParams.xy * 0.5;
                    float2 pixelPosition = round((output.position.xy / output.position.w) * halfScreen);
                    output.position.xy = (pixelPosition / halfScreen) * output.position.w;
                #endif

                output.color = input.color * _Color;
                output.uv = input.uv;

                // Match the original operation grouping: combine matrices, then apply vertex.
                float4x4 darknessMVP = mul(_DarknessCameraVP, unity_ObjectToWorld);
                float4 darknessPosition = mul(darknessMVP, objectPosition);
                darknessPosition.y = darknessPosition.y * _ProjectionParams.x;
                output.darknessScreenPosition.zw = darknessPosition.zw;
                float2 projectedXY = darknessPosition.xy * 0.5;
                float halfW = darknessPosition.w * 0.5;
                output.darknessScreenPosition.xy = halfW.xx + projectedXY;
                return output;
            }

            float4 RecoveredDarknessFrag(RecoveredDarknessVertexOutput input) : SV_Target
            {
                float4 result;

                #if defined(IS_VIGNETTE)
                    // MSL 00013/00017: red channel reduces alpha by up to 80%.
                    float2 maskUV = input.darknessScreenPosition.xy / input.darknessScreenPosition.ww;
                    float redMask = tex2D(_DarknessCutout, maskUV).r;
                    float attenuation = mad(-redMask, 0.800000012, 1.0);
                    float4 tinted = tex2D(_MainTex, input.uv) * input.color;
                    result.a = attenuation * tinted.a;
                    result.rgb = result.aaa * tinted.rgb;
                #elif defined(IS_MASK_BLACKOUT)
                    // MSL 00014/00018: BOTH green and blue participate in blackout.
                    float alphaSlope = mad(input.color.a, -2.0, 1.0);
                    float2 maskUV = input.darknessScreenPosition.xy / input.darknessScreenPosition.ww;
                    float2 greenBlueMask = tex2D(_DarknessCutout, maskUV).gb;
                    float mixedAlpha = mad(greenBlueMask.y, alphaSlope, input.color.a);
                    float4 texel = tex2D(_MainTex, input.uv);
                    result.a = saturate(mad(texel.a, mixedAlpha, greenBlueMask.x));
                    float3 tintedRGB = texel.rgb * input.color.rgb;
                    result.rgb = result.aaa * tintedRGB;
                #elif defined(IS_SCENE_BORDER)
                    // MSL 00015/00019: cutout alpha attenuates the scene-border sprite.
                    float2 maskUV = input.darknessScreenPosition.xy / input.darknessScreenPosition.ww;
                    float alphaMask = tex2D(_DarknessCutout, maskUV).a;
                    float attenuation = 1.0 - alphaMask;
                    float4 tinted = tex2D(_MainTex, input.uv) * input.color;
                    result.a = attenuation * tinted.a;
                    result.rgb = result.aaa * tinted.rgb;
                #else
                    // MSL 00012/00016: ordinary premultiplied sprite without mask lookup.
                    result = tex2D(_MainTex, input.uv) * input.color;
                    result.rgb = result.aaa * result.rgb;
                #endif

                #if defined(DITHERING_NOISE)
                    // Original noise is added after premultiplication, including to alpha.
                    float noise = dot(input.position.xy, float2(0.0671105608, 0.00583714992));
                    noise = frac(noise);
                    noise = noise * 52.9829178;
                    noise = frac(noise);
                    noise = mad(noise, 0.00392156886, -0.00196078443);
                    result = noise.xxxx + result;
                #endif

                return result;
            }
            ENDCG
        }
    }
}
