Shader "Custom/Screen-Space Blit" {
	Properties {
		_MainTex ("Main Texture", 2D) = "white" {}
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		Cull Off
		ZWrite Off
		ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma target 2.0
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float4 screenPos : TEXCOORD0;
			};

			sampler2D _MainTex;

			v2f vert(appdata input)
			{
				v2f output;
				output.vertex = UnityObjectToClipPos(input.vertex);
				output.screenPos = ComputeScreenPos(output.vertex);
				return output;
			}

			fixed4 frag(v2f input) : SV_Target
			{
				return tex2Dproj(_MainTex, UNITY_PROJ_COORD(input.screenPos));
			}

			ENDCG
		}
	}

	Fallback Off
}
