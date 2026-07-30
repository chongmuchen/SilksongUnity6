Shader "UI/Blur/UIBlur Camera" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Size ("Spacing", Range(0, 200)) = 5
		_Vibrancy ("Vibrancy", Range(0, 2)) = 0.2
		[Toggle(USE_MASK)] _UseMask ("Use Mask", Float) = 0
		_MaskLerp ("Mask Lerp", Range(0, 1)) = 1
		_Mask ("Mask", 2D) = "white" {}
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 200
		Cull Off
		ZWrite Off
		ZTest Always

		CGINCLUDE
		#include "UnityCG.cginc"

		sampler2D _MainTex;
		float4 _MainTex_TexelSize;
		sampler2D _Mask;
		float4 _Mask_ST;
		half _Size;
		half _Vibrancy;
		half _MaskLerp;

		half MaskedBlurAmount(float2 uv)
		{
			#if defined(USE_MASK)
				float2 maskUv = uv * _Mask_ST.xy + _Mask_ST.zw;
				return lerp(1.0h, saturate(tex2D(_Mask, maskUv).r), saturate(_MaskLerp));
			#else
				return 1.0h;
			#endif
		}

		half4 SampleGaussian(v2f_img input, float2 direction, half radiusScale)
		{
			float2 offset = direction * _MainTex_TexelSize.xy * _Size * radiusScale;
			offset *= MaskedBlurAmount(input.uv);

			half4 color = tex2D(_MainTex, input.uv) * 0.40262h;
			color += tex2D(_MainTex, input.uv + offset * 1.3846154) * 0.24420h;
			color += tex2D(_MainTex, input.uv - offset * 1.3846154) * 0.24420h;
			color += tex2D(_MainTex, input.uv + offset * 3.2307692) * 0.05449h;
			color += tex2D(_MainTex, input.uv - offset * 3.2307692) * 0.05449h;
			return color;
		}

		half4 fragPrepare(v2f_img input) : SV_Target
		{
			half4 color = tex2D(_MainTex, input.uv);
			half luminance = dot(color.rgb, half3(0.2126h, 0.7152h, 0.0722h));
			color.rgb = lerp(luminance.xxx, color.rgb, 1.0h + _Vibrancy);
			return color;
		}

		half4 fragHorizontalNear(v2f_img input) : SV_Target
		{
			return SampleGaussian(input, float2(1.0, 0.0), 0.5h);
		}

		half4 fragVerticalNear(v2f_img input) : SV_Target
		{
			return SampleGaussian(input, float2(0.0, 1.0), 0.5h);
		}

		half4 fragHorizontalFar(v2f_img input) : SV_Target
		{
			return SampleGaussian(input, float2(1.0, 0.0), 1.0h);
		}

		half4 fragVerticalFar(v2f_img input) : SV_Target
		{
			return SampleGaussian(input, float2(0.0, 1.0), 1.0h);
		}
		ENDCG

		// CameraBlurPlane and DisplayFrozenCamera call these passes by index.
		Pass
		{
			Name "PREPARE"
			CGPROGRAM
			#pragma target 2.0
			#pragma vertex vert_img
			#pragma fragment fragPrepare
			ENDCG
		}

		Pass
		{
			Name "BLUR_HORIZONTAL_NEAR"
			CGPROGRAM
			#pragma target 2.0
			#pragma vertex vert_img
			#pragma fragment fragHorizontalNear
			#pragma multi_compile_local __ USE_MASK
			ENDCG
		}

		Pass
		{
			Name "BLUR_VERTICAL_NEAR"
			CGPROGRAM
			#pragma target 2.0
			#pragma vertex vert_img
			#pragma fragment fragVerticalNear
			#pragma multi_compile_local __ USE_MASK
			ENDCG
		}

		Pass
		{
			Name "BLUR_HORIZONTAL_FAR"
			CGPROGRAM
			#pragma target 2.0
			#pragma vertex vert_img
			#pragma fragment fragHorizontalFar
			#pragma multi_compile_local __ USE_MASK
			ENDCG
		}

		Pass
		{
			Name "BLUR_VERTICAL_FAR"
			CGPROGRAM
			#pragma target 2.0
			#pragma vertex vert_img
			#pragma fragment fragVerticalFar
			#pragma multi_compile_local __ USE_MASK
			ENDCG
		}
	}

	Fallback Off
}
