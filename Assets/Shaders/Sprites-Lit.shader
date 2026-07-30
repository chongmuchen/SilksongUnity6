Shader "Sprites/Lit" {
	Properties {
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Tint", Vector) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[HideInInspector] _RendererColor ("RendererColor", Vector) = (1,1,1,1)
		[HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
		[PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
		[PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
		[Space] [Toggle(AMBIENT_LERP)] _AmbientLerpEnabled ("Enable Ambient Lerp", Float) = 0
		_AmbientLerp ("Ambient Lerp", Range(0, 1)) = 1
		[Space] [Toggle(SATURATION_LERP)] _SaturationLerpEnabled ("Enable Saturation Lerp", Float) = 0
		_SaturationLerp ("Saturation Lerp", Float) = 1
		[Space] [Toggle(COLOR_FLASH)] _ColorFlashEnabled ("Enable Color Flash", Float) = 0
		_FlashColor ("Flash Color", Vector) = (1,1,1,1)
		_FlashAmount ("Flash Amount", Range(0, 1)) = 0
		[PerRendererData] _BlackThreadAmount ("Black Thread Amount", Range(0, 1)) = 1
		[Toggle(BLACKTHREAD)] _IsBlackThreaded ("Is Black Threaded", Float) = 0
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
			#pragma multi_compile _ ETC1_EXTERNAL_ALPHA
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
			sampler2D _AlphaTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed4 _RendererColor;
			float4 _Flip;
			half _EnableExternalAlpha;

			v2f vert(appdata input)
			{
				v2f output;
				input.vertex.xy *= _Flip.xy;
				output.vertex = UnityObjectToClipPos(input.vertex);
				output.uv = TRANSFORM_TEX(input.uv, _MainTex);
				output.color =
					input.color * _Color * _RendererColor;

				#ifdef PIXELSNAP_ON
				output.vertex = UnityPixelSnap(output.vertex);
				#endif

				return output;
			}

			fixed4 frag(v2f input) : SV_Target
			{
				fixed4 color = tex2D(_MainTex, input.uv);

				#ifdef ETC1_EXTERNAL_ALPHA
				fixed externalAlpha =
					tex2D(_AlphaTex, input.uv).r;
				color.a = lerp(
					color.a,
					externalAlpha,
					_EnableExternalAlpha);
				#endif

				return color * input.color;
			}
			ENDCG
		}
	}

	Fallback "Sprites/Default"
}
