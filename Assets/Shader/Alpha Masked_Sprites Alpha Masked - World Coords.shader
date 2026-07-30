Shader "Alpha Masked/Sprites Alpha Masked - World Coords" {
	Properties {
		[PerRendererData] _MainTex ("Texture", 2D) = "white" {}
		_Color ("Tint", Vector) = (1,1,1,1)
		[MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
		[Toggle] _ClampHoriz ("Clamp Alpha Horizontally", Float) = 0
		[Toggle] _ClampVert ("Clamp Alpha Vertically", Float) = 0
		[Toggle] _UseAlphaChannel ("Use Mask Alpha Channel (not RGB)", Float) = 0
		_MaskRotation ("Mask Rotation in Radians", Float) = 0
		_AlphaTex ("Alpha Mask", 2D) = "white" {}
		_ClampBorder ("Clamping Border", Float) = 0.01
		[KeywordEnum(X, Y, Z)] _Axis ("Alpha Mapping Axis", Float) = 0
		_IsThisText ("Is This Text?", Float) = 0
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
	Fallback "Unlit/Texture"
}