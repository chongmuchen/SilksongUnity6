Shader "Hidden/ColorCorrectionCurvesSimple" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "" {}
		_RgbTex ("_RgbTex (RGB)", 2D) = "" {}
	}
	CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		sampler2D _RgbTex;
		float4 _MainTex_TexelSize;
		half _Saturation;

		struct v2f
		{
			float4 vertex : SV_POSITION;
			float2 uv : TEXCOORD0;
		};

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

			output.uv = UnityStereoTransformScreenSpaceTex(output.uv);
			return output;
		}

		half4 frag(v2f input) : SV_Target
		{
			half4 color = tex2D(_MainTex, input.uv);
			half red = tex2D(_RgbTex, half2(saturate(color.r), 0.125)).r;
			half green = tex2D(_RgbTex, half2(saturate(color.g), 0.375)).g;
			half blue = tex2D(_RgbTex, half2(saturate(color.b), 0.625)).b;
			half3 corrected = half3(red, green, blue);
			half luminance = Luminance(corrected);
			corrected = lerp(luminance.xxx, corrected, _Saturation);
			return half4(corrected, color.a);
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
	}

	Fallback Off
}
