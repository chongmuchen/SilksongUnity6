Shader "Custom/LavaBase" {
	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		_Speed ("Flow Rate", Float) = 1
		_OffsetZ ("Offset Z", Float) = 1
		[Toggle(FLOW_Y)] _EnableFlowY ("Flows along Y axis", Float) = 0
		[Toggle(FLIP_DIR_SCALE)] _FlipDirectionWithScale ("Flip Direction With Scale", Float) = 0
		[Toggle(USE_MASK)] _UseMask ("Use Mask", Float) = 0
		_MaskTex ("Mask Texture", 2D) = "white" {}
		[PerRendererData] _TintColor ("Tint Color", Vector) = (1,1,1,1)
		[PerRendererData] _OffsetFlow ("Offset Flow", Float) = 1
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

			struct Fragment_Stage_Input
			{
				float2 uv : TEXCOORD0;
			};

			float4 frag(Fragment_Stage_Input input) : SV_TARGET
			{
				return _MainTex.Sample(sampler_MainTex, input.uv.xy);
			}

			ENDHLSL
		}
	}
}