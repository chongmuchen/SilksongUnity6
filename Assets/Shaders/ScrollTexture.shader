Shader "Custom/ScrollTexture" {
	Properties {
		_Color ("Color", Vector) = (1,1,1,1)
		_MainTex ("Texture", 2D) = "white" {}
		_SpeedX ("Flow Rate X", Float) = 1
		_SpeedY ("Flow Rate Y", Float) = 1
		[Toggle(USE_SECONDARY)] _UseSecondary ("Use Secondary", Float) = 0
		_SecondaryColor ("Secondary Color", Vector) = (1,1,1,1)
		_SecondaryTex ("Secondary Texture", 2D) = "white" {}
		_SecondarySpeedX ("Secondary Flow Rate X", Float) = 1
		_SecondarySpeedY ("Secondary Flow Rate Y", Float) = 1
		[Space] [Toggle(USE_OBJECT_SCALE)] _UseObjectScale ("Use Object Scale", Float) = 0
		[Space] [Toggle(USE_WORLD_OFFSET)] _UseWorldOffset ("Use World Offset", Float) = 0
		_WorldOffsetX ("World Offset X Amount", Float) = 0
		_WorldOffsetY ("World Offset Y Amount", Float) = 0
		_WorldOffsetZ ("World Offset Z Amount", Float) = 0
		[Toggle(USE_MASK)] _UseMask ("Use Mask", Float) = 0
		_MaskTex ("Mask Texture", 2D) = "white" {}
		[PerRendererData] _TintColor ("Tint Color", Vector) = (1,1,1,1)
		_StencilRef ("Stencil Ref", Range(0, 255)) = 255
		[Toggle(USE_COLOR_FLASH)] _UseColorFlash ("Use Color Flash", Float) = 0
		_FlashColor ("Flash Color", Vector) = (1,1,1,1)
		_FlashAmount ("Flash Amount", Range(0, 1)) = 0
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