Shader "Hidden/NoiseAndGrain" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_NoiseTex ("Noise (RGB)", 2D) = "white" {}
	}
	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		sampler2D _NoiseTex;
		float4 _NoiseTex_TexelSize;
		float4 _MainTex_TexelSize;
		float3 _NoisePerChannel;
		float3 _NoiseTilingPerChannel;
		float3 _NoiseAmount;
		float3 _MidGrey;

		struct appdata_img2
		{
			float4 vertex : POSITION;
			float2 texcoord : TEXCOORD0;
			float2 texcoord1 : TEXCOORD1;
		};

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float2 screenUv : TEXCOORD0;
			float4 noiseUvRg : TEXCOORD1;
			float2 noiseUvB : TEXCOORD2;
		};

		float3 Overlay(float3 noise, float3 color)
		{
			color = saturate(color);
			float3 upperHalf = step(0.5, color);
			float3 result =
				upperHalf *
				(1.0 - ((1.0 - 2.0 * (color - 0.5)) * (1.0 - noise)));
			result +=
				(1.0 - upperHalf) *
				(2.0 * color) *
				noise;
			return result;
		}

		v2f vert(appdata_img2 input)
		{
			v2f output;
			output.vertex = UnityObjectToClipPos(input.vertex);
			output.screenUv = input.vertex.xy;

			#if UNITY_UV_STARTS_AT_TOP
			if (_MainTex_TexelSize.y < 0)
			{
				output.screenUv.y = 1.0 - output.screenUv.y;
			}
			#endif

			output.screenUv =
				UnityStereoTransformScreenSpaceTex(output.screenUv);

			output.noiseUvRg =
				input.texcoord.xyxy +
				input.texcoord1.xyxy *
				_NoiseTilingPerChannel.rrgg *
				_NoiseTex_TexelSize.xyxy;
			output.noiseUvB =
				input.texcoord.xy +
				input.texcoord1.xy *
				_NoiseTilingPerChannel.bb *
				_NoiseTex_TexelSize.xy;

			return output;
		}

		float NoiseIntensity(float3 color)
		{
			float2 blackWhiteCurve = Luminance(color) - _MidGrey.x;
			blackWhiteCurve =
				saturate(blackWhiteCurve * _MidGrey.yz);
			return
				_NoiseAmount.x +
				max(0.0, dot(_NoiseAmount.zy, blackWhiteCurve));
		}

		float3 SampleNoise(v2f input, float finalIntensity)
		{
			float3 noise = float3(0.0, 0.0, 0.0);
			noise +=
				(tex2D(_NoiseTex, input.noiseUvRg.xy) *
					float4(1.0, 0.0, 0.0, 0.0)).rgb;
			noise +=
				(tex2D(_NoiseTex, input.noiseUvRg.zw) *
					float4(0.0, 1.0, 0.0, 0.0)).rgb;
			noise +=
				(tex2D(_NoiseTex, input.noiseUvB) *
					float4(0.0, 0.0, 1.0, 0.0)).rgb;

			return saturate(
				lerp(
					float3(0.5, 0.5, 0.5),
					noise,
					_NoisePerChannel * finalIntensity));
		}

		float4 frag(v2f input) : SV_Target
		{
			float4 color = tex2D(_MainTex, input.screenUv);
			float finalIntensity = NoiseIntensity(color.rgb);
			float3 noise = SampleNoise(input, finalIntensity);
			return float4(Overlay(noise, color.rgb), color.a);
		}

		float4 fragOverlayBlend(v2f input) : SV_Target
		{
			float4 color = tex2D(_MainTex, input.screenUv);
			float3 noise = tex2D(_NoiseTex, input.screenUv).rgb;
			return float4(Overlay(noise, color.rgb), color.a);
		}

		float4 fragTemporaryNoise(v2f input) : SV_Target
		{
			float4 color = tex2D(_MainTex, input.screenUv);
			float finalIntensity = NoiseIntensity(color.rgb);
			float3 noise = SampleNoise(input, finalIntensity);
			return float4(noise, color.a);
		}
	ENDCG

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
			ENDCG
		}

		Pass
		{
			CGPROGRAM
				#pragma target 2.0
				#pragma vertex vert
				#pragma fragment fragOverlayBlend
			ENDCG
		}

		Pass
		{
			CGPROGRAM
				#pragma target 2.0
				#pragma vertex vert
				#pragma fragment fragTemporaryNoise
			ENDCG
		}
	}

	Fallback Off
}
