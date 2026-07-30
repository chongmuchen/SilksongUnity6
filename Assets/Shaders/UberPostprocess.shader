Shader "Hidden/UberPostprocess" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		ZTest Always
		Cull Off
		ZWrite Off
		Blend Off

		Pass
		{
			CGPROGRAM
			#pragma target 2.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_local _ COLOR_CURVES_ENABLED
			#pragma multi_compile_local _ NOISE_ENABLED
			#pragma multi_compile_local _ BRIGHTNESS_EFFECT_ENABLED
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			sampler2D _MainTex;
			sampler2D _RgbTex;
			sampler2D _NoiseTex;
			float4 _MainTex_TexelSize;
			half _Saturation;
			half _NoiseStrength;
			half _TimeSnap;
			half4 _NoiseColor;
			half _Brightness;
			half _Contrast;

			v2f vert(appdata_img input)
			{
				v2f output;
				output.vertex = UnityObjectToClipPos(input.vertex);
				output.uv = input.texcoord;

				#if UNITY_UV_STARTS_AT_TOP
				if (_MainTex_TexelSize.y < 0)
				{
					output.uv.y = 1.0 - output.uv.y;
				}
				#endif

				output.uv =
					UnityStereoTransformScreenSpaceTex(output.uv);
				return output;
			}

			half3 ApplyColorCurves(half3 color)
			{
				half red =
					tex2D(
						_RgbTex,
						half2(saturate(color.r), 0.125)).r;
				half green =
					tex2D(
						_RgbTex,
						half2(saturate(color.g), 0.375)).g;
				half blue =
					tex2D(
						_RgbTex,
						half2(saturate(color.b), 0.625)).b;
				half3 corrected = half3(red, green, blue);
				half luminance = Luminance(corrected);
				return lerp(
					luminance.xxx,
					corrected,
					_Saturation);
			}

			half3 ApplyNoise(half3 color, float2 uv)
			{
				half safeTimeSnap = max(abs(_TimeSnap), 0.0001);
				half snappedTime =
					floor(_Time.y / safeTimeSnap) *
					safeTimeSnap;
				float2 noiseUv =
					uv + float2(snappedTime, snappedTime);
				half3 noise =
					tex2D(_NoiseTex, noiseUv).rgb - 0.5;
				return
					color +
					noise *
					_NoiseColor.rgb *
					(_NoiseStrength * _NoiseColor.a);
			}

			half3 ApplyBrightnessAndContrast(half3 color)
			{
				return
					((color - 0.5) * _Contrast + 0.5) *
					_Brightness;
			}

			half4 frag(v2f input) : SV_Target
			{
				half4 color = tex2D(_MainTex, input.uv);

				#ifdef COLOR_CURVES_ENABLED
				color.rgb = ApplyColorCurves(color.rgb);
				#endif

				#ifdef NOISE_ENABLED
				color.rgb = ApplyNoise(color.rgb, input.uv);
				#endif

				#ifdef BRIGHTNESS_EFFECT_ENABLED
				color.rgb =
					ApplyBrightnessAndContrast(color.rgb);
				#endif

				return color;
			}
			ENDCG
		}
	}

	Fallback Off
}
