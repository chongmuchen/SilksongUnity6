Shader "Hollow Knight/Light Blur" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurInfo ("Blur Info", Vector) = (0.00052083336,0.0009259259,0,0)
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
			Name "COPY_HORIZONTAL"
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment fragCopy
			#pragma target 2.0
			ENDCG
		}

		Pass
		{
			Name "COPY_VERTICAL"
			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment fragCopy
			#pragma target 2.0
			ENDCG
		}
	}
	Fallback Off
}
