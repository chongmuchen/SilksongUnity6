// Reconstructed from the shipped macOS 1.0.30000 Shader object, not the dummy export.
// Object: CAB-da509b36c85b4b85fb18500ca8d550f9:2384169666666017007
// SHA-256: 01126dd65a54794ab58166845964c69cfb229300210518b23261d117d84c79b3
// Evidence: recovered/macos-programs/Sprites_Default_Mix_Channels__01126dd65a54/
// All 8 keyword combinations / 16 retained Metal stage programs are represented.
// The build also lists these keyword names, but supplies no executable variants:
// INSTANCING_ON, STEREO_INSTANCING_ON, UNITY_SINGLE_PASS_STEREO,
// STEREO_MULTIVIEW_ON, STEREO_CUBEMAP_RENDER_ON. Their algorithms are not invented here.
Shader "Sprites/Default Mix Channels"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1, 1, 1, 1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1, 1, 1, 1)
        [HideInInspector] _Flip ("Flip", Vector) = (1, 1, 1, 1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
        _JustAlphaLerp ("Just Alpha Lerp", Float) = 0
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
            // ParsedForm render state: src=1, dst=6 for both RGB and alpha.
            // Each destination channel is attenuated by its corresponding source channel.
            Blend One OneMinusSrcColor, One OneMinusSrcColor
            BlendOp Add, Add
            ColorMask RGBA
            Cull Off
            Lighting Off
            ZClip On
            ZTest LEqual
            ZWrite Off
            Offset 0, 0
            AlphaToMask Off
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
            #pragma vertex RecoveredMixVert
            #pragma fragment RecoveredMixFrag
            #pragma multi_compile __ PIXELSNAP_ON
            #pragma multi_compile __ ETC1_EXTERNAL_ALPHA
            #pragma multi_compile __ DITHERING_NOISE

            #include "UnityCG.cginc"

            // Original MSL uses float precision throughout, including SpriteRenderer color.
            float4 _Color;
            CBUFFER_START(UnityPerDrawSprite)
                float4 _RendererColor;
                float2 _Flip;
                float _EnableExternalAlpha;
            CBUFFER_END

            sampler2D _MainTex;
            sampler2D _AlphaTex;
            float _JustAlphaLerp;
            // This is a global uniform in the original program, not a material property.
            // DarknessCameraEffect controls it before and after rendering the mask camera.
            float _PreviewLerp;

            struct RecoveredMixVertexInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct RecoveredMixVertexOutput
            {
                float4 position : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            RecoveredMixVertexOutput RecoveredMixVert(RecoveredMixVertexInput input)
            {
                RecoveredMixVertexOutput output;
                // Metal subprograms 00002..00005: sprite XY flip, object-to-world, VP.
                float4 objectPosition = float4(input.vertex.xy * _Flip, input.vertex.z, 1.0);
                output.position = mul(UNITY_MATRIX_VP, mul(unity_ObjectToWorld, objectPosition));

                #if defined(PIXELSNAP_ON)
                    // Metal subprograms 00006..00009: rint maps to HLSL round.
                    float2 halfScreen = _ScreenParams.xy * 0.5;
                    float2 pixelPosition = round((output.position.xy / output.position.w) * halfScreen);
                    output.position.xy = (pixelPosition / halfScreen) * output.position.w;
                #endif

                output.color = (input.color * _Color) * _RendererColor;
                // The original uses raw sprite UV, with no _MainTex_ST transform.
                output.uv = input.uv;
                return output;
            }

            float4 RecoveredMixFrag(RecoveredMixVertexOutput input) : SV_Target
            {
                // Metal subprograms 00012..00019. Texture RGB is deliberately unused.
                float textureAlpha = tex2D(_MainTex, input.uv).a;
                #if defined(ETC1_EXTERNAL_ALPHA)
                    float externalAlpha = tex2D(_AlphaTex, input.uv).r;
                    textureAlpha = mad(_EnableExternalAlpha, externalAlpha - textureAlpha, textureAlpha);
                #endif

                // Keep the original arithmetic sequence, including unrestricted lerp factors.
                float4 u_xlat0 = float4(1.0, 1.0, 1.0, textureAlpha) * input.color;
                float4 u_xlat1;
                u_xlat1.xyz = u_xlat0.www * u_xlat0.xyz;
                u_xlat0.x = 0.0;
                u_xlat1.w = 1.0 - _PreviewLerp;
                u_xlat0 = u_xlat0.xxxw - u_xlat1;
                u_xlat0 = mad(_JustAlphaLerp, u_xlat0, u_xlat1);
                u_xlat1.xyz = mad(u_xlat0.www, float3(0.0, 0.200000003, 0.200000003), -u_xlat0.xyz);
                u_xlat1.xyz = mad(_JustAlphaLerp, u_xlat1.xyz, u_xlat0.xyz);
                u_xlat1.w = u_xlat0.w;
                u_xlat0 = u_xlat0 - u_xlat1;
                u_xlat0 = mad(_PreviewLerp, u_xlat0, u_xlat1);

                #if defined(DITHERING_NOISE)
                    // Original interleaved gradient noise is added to ALL FOUR channels.
                    float noise = dot(input.position.xy, float2(0.0671105608, 0.00583714992));
                    noise = frac(noise);
                    noise = noise * 52.9829178;
                    noise = frac(noise);
                    noise = mad(noise, 0.00392156886, -0.00196078443);
                    u_xlat0 = u_xlat0 + noise.xxxx;
                #endif

                return u_xlat0;
            }
            ENDCG
        }
    }
}
