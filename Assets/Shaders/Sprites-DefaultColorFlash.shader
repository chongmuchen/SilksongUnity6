Shader "Sprites/Default-ColorFlash" {
	Properties {
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
	//DummyShaderTextExporter
	SubShader{
		Tags { "RenderType"="Opaque" }
		LOD 200

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4x4 unity_ObjectToWorld;
			float4x4 unity_MatrixVP;
			float4 _MainTex_ST;

			struct Vertex_Stage_Input
			{
				float4 pos : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct Vertex_Stage_Output
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			Vertex_Stage_Output vert(Vertex_Stage_Input input)
			{
				Vertex_Stage_Output output;
				output.uv = (input.uv.xy * _MainTex_ST.xy) + _MainTex_ST.zw;
				output.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, input.pos));
				return output;
			}

			Texture2D<float4> _MainTex;
			SamplerState sampler_MainTex;
			float4 _Color;

			struct Fragment_Stage_Input
			{
				float2 uv : TEXCOORD0;
			};

			float4 frag(Fragment_Stage_Input input) : SV_TARGET
			{
				return _MainTex.Sample(sampler_MainTex, input.uv.xy) * _Color;
			}

			ENDHLSL
		}
	}
}