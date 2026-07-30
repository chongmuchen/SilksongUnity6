Shader "Sprites/Darkness Sprite" {
	Properties {
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Vector) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[Toggle(IS_VIGNETTE)] _ReadRToggle ("Is Vignette", Float) = 0
		[Toggle(IS_MASK_BLACKOUT)] _ReadBToggle ("Is Mask Blackout", Float) = 0
		[Toggle(IS_SCENE_BORDER)] _ReadAToggle ("Is Scene Border", Float) = 0
	}
	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		Pass
		{
			CGPROGRAM
			#pragma target 2.0
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma shader_feature_local _ IS_VIGNETTE IS_MASK_BLACKOUT IS_SCENE_BORDER
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				fixed4 color : COLOR;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;

			v2f vert(appdata input)
			{
				v2f output;
				output.vertex = UnityObjectToClipPos(input.vertex);
				output.uv = TRANSFORM_TEX(input.uv, _MainTex);
				output.color = input.color * _Color;

				#ifdef PIXELSNAP_ON
				output.vertex = UnityPixelSnap(output.vertex);
				#endif

				return output;
			}

			fixed4 frag(v2f input) : SV_Target
			{
				fixed4 maskTexture = tex2D(_MainTex, input.uv);
				fixed mask = maskTexture.a;

				#if defined(IS_VIGNETTE)
				mask = maskTexture.r;
				#elif defined(IS_MASK_BLACKOUT)
				mask = maskTexture.b;
				#elif defined(IS_SCENE_BORDER)
				mask = maskTexture.a;
				#endif

				return fixed4(input.color.rgb, input.color.a * mask);
			}
			ENDCG
		}
	}

	Fallback "Sprites/Default"
}
