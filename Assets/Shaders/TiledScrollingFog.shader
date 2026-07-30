Shader "Custom/Tiled Scrolling Fog" {
	Properties {
		[PerRendererData] _Color ("Color", Vector) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		[PerRendererData] _SpeedX ("Flow Rate X", Float) = 1
		[PerRendererData] _SpeedY ("Flow Rate Y", Float) = 1
		_WorldOffsetX ("World Offset X Amount", Float) = 0
		_WorldOffsetY ("World Offset Y Amount", Float) = 0
		_WorldOffsetZ ("World Offset Z Amount", Float) = 0
		[PerRendererData] _FogRotation ("Fog Rotation", Float) = 1
		[Toggle(USE_HERO_MASK)] _UseHeroMask ("Use Screen Space Hero Mask", Float) = 0
		_HeroMaskTex ("Mask Texture", 2D) = "white" {}
		[Toggle(USE_OBJ_MASK)] _UseObjMask ("Use Object UV Mask", Float) = 0
		_ObjMaskTex ("Mask Texture", 2D) = "white" {}
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