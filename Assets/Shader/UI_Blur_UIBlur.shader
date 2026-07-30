Shader "UI/Blur/UIBlur" {
	Properties {
		_TintColor ("Tint Color", Vector) = (1,1,1,0.2)
		_Size ("Spacing", Range(0, 200)) = 5
		_Vibrancy ("Vibrancy", Range(0, 2)) = 0.2
		[HideInInspector] _StencilComp ("Stencil Comparison", Float) = 8
		[HideInInspector] _Stencil ("Stencil ID", Float) = 0
		[HideInInspector] _StencilOp ("Stencil Operation", Float) = 0
		[HideInInspector] _StencilWriteMask ("Stencil Write Mask", Float) = 255
		[HideInInspector] _StencilReadMask ("Stencil Read Mask", Float) = 255
		[Toggle(BLUR_PLANE)] _IsBlurPlane ("Is Scene Blur Plane", Float) = 0
		[Toggle(USE_MASK)] _UseMask ("Use Mask", Float) = 0
		_MaskLerp ("Mask Lerp", Range(0, 1)) = 1
		_Mask ("Mask", 2D) = "white" {}
	}
	SubShader
	{
		Tags
		{
			"Queue"="Transparent"
			"IgnoreProjector"="True"
			"RenderType"="Transparent"
		}

		Stencil
		{
			Ref [_Stencil]
			Comp [_StencilComp]
			Pass [_StencilOp]
			ReadMask [_StencilReadMask]
			WriteMask [_StencilWriteMask]
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
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
			};

			fixed4 _TintColor;

			v2f vert(appdata input)
			{
				v2f output;
				output.vertex = UnityObjectToClipPos(input.vertex);
				return output;
			}

			fixed4 frag(v2f input) : SV_Target
			{
				return _TintColor;
			}
			ENDCG
		}
	}
}
