Shader "Hidden/FastBloom" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Bloom ("Bloom (RGB)", 2D) = "black" {}
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 200
		Cull Off
		ZWrite Off
		ZTest Always

		CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;

		fixed4 fragCopy(v2f_img input) : SV_Target
		{
			return tex2D(_MainTex, input.uv);
		}
		ENDCG

		Pass
		{
			Name "COMPOSITE_COPY"
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment fragCopy
			#pragma target 2.0
			ENDCG
		}

		Pass
		{
			Name "DOWNSAMPLE_COPY"
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment fragCopy
			#pragma target 2.0
			ENDCG
		}

		Pass
		{
			Name "STANDARD_BLUR_HORIZONTAL_COPY"
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment fragCopy
			#pragma target 2.0
			ENDCG
		}

		Pass
		{
			Name "STANDARD_BLUR_VERTICAL_COPY"
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment fragCopy
			#pragma target 2.0
			ENDCG
		}

		Pass
		{
			Name "SGX_BLUR_HORIZONTAL_COPY"
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment fragCopy
			#pragma target 2.0
			ENDCG
		}

		Pass
		{
			Name "SGX_BLUR_VERTICAL_COPY"
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment fragCopy
			#pragma target 2.0
			ENDCG
		}
	}
	Fallback Off
}
