Shader "Custom/Heat Effect (Masked)" {
	Properties {
		_BumpAmt ("Distortion", Range(0, 128)) = 10
		_BumpMap ("Normalmap", 2D) = "bump" {}
		[Toggle(OBJ_UVS)] _UseObjUvs ("Use Object UVs", Float) = 0
		_SpeedX ("Speed X", Float) = 1
		_SpeedY ("Speed Y", Float) = 1
		_MaskTex ("Mask", 2D) = "white" {}
	}
	//DummyShaderTextExporter
	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			float4x4 unity_ObjectToWorld;
			float4x4 unity_MatrixVP;

			struct Vertex_Stage_Input
			{
				float4 pos : POSITION;
			};

			struct Vertex_Stage_Output
			{
				float4 pos : SV_POSITION;
			};

			Vertex_Stage_Output vert(Vertex_Stage_Input input)
			{
				Vertex_Stage_Output output;
				output.pos = mul(unity_MatrixVP, mul(unity_ObjectToWorld, input.pos));
				return output;
			}

			float4 frag(Vertex_Stage_Output input) : SV_TARGET
			{
				return float4(1.0, 1.0, 1.0, 1.0); // RGBA
			}

			ENDHLSL
		}
	}
}