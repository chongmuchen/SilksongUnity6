Shader "Sprites/Default-ColorFlash"
{
	Properties
	{
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Vector) = (1,1,1,1)
		_FlashColor ("Flash Color", Vector) = (1,1,1,1)
		_FlashAmount ("Flash Amount", Range(0, 1)) = 0
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[Toggle(IS_CHARACTER)] _IsCharacter ("Is Character", Float) = 0
		[PerRendererData] _CharacterTintColor ("Character Tint Color", Vector) = (1,1,1,1)
		[Toggle(IS_HERO)] _IsHero ("Is Hero", Float) = 0
		[Toggle(CAN_DESATURATE)] _CanDesaturate ("Can Desaturate", Float) = 0
		_Desaturation ("Desaturation", Range(-2, 2)) = 0
		[Toggle(CAN_LERP_AMBIENT)] _CanLerpAmbient ("Can Lerp Ambient", Float) = 0
		_AmbientLerp ("Ambient Lerp", Range(0, 1)) = 1
		[PerRendererData] _BlackThreadAmount ("Black Thread Amount", Range(0, 1)) = 1
		[Space] [Toggle(MASKING_SPRITE)] _IsMaskingSprite ("Masking Sprite", Float) = 0
		[Toggle(LOCAL_SPACE_X)] _UseLocalSpaceX ("Local Space X", Float) = 0
		[Toggle(LOCAL_SPACE_Y)] _UseLocalSpaceY ("Local Space Y", Float) = 0
		_ScrollTexA ("Texture A", 2D) = "white" {}
		_SpeedXA ("Tex A Flow Rate X", Float) = 1
		_SpeedYA ("Tex A Flow Rate Y", Float) = 1
		_ScrollTexB ("Texture B", 2D) = "white" {}
		_SpeedXB ("Tex B Flow Rate X", Float) = 1
		_SpeedYB ("Tex B Flow Rate Y", Float) = 1
		[Space] [IntRange] _StencilRef ("Stencil Reference", Range(0, 255)) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)] _StencilComp ("Stencil Comparison", Range(0, 255)) = 8
		[Toggle(BLACKTHREAD)] _IsBlackThreaded ("Is Black Threaded", Float) = 0
		[Toggle(CAN_HUESHIFT)] _CanHueShift ("Can Hue Shift", Float) = 0
		_HueShift ("Hue Shift", Range(-1, 1)) = 0
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
			fixed4 _FlashColor;
			half _FlashAmount;

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
				fixed4 color = tex2D(_MainTex, input.uv) * input.color;
				color.rgb = lerp(
					color.rgb,
					_FlashColor.rgb,
					saturate(_FlashAmount));
				return color;
			}
			ENDCG
		}
	}
}
