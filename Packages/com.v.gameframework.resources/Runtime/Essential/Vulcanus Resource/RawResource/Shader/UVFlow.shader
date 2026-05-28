Shader "ZAMMYSMITH/SpecialFX/UVFlow"
{
	Properties 
	{
		_MaskTex("Mask (RGB)", 2D) = "white" {}
		[HDR] _Color("Color", Color) = (1,1,1,1)
		_AlphaClip("└─Alpha clip", Range(0, 1)) = 0.0
		_XScrollSpeed("└─X Scroll Speed", Float) = 0
		_YScrollSpeed("└─Y Scroll Speed", Float) = 0

		[Header(ZTest)]
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest (default = Disable)", Float) = 4 //0 = disable

		[Header(ZWrite)]
		[Enum(Off, 0, On, 1)]_ZWrite("ZWrite (default = Disable)", Float) = 1 //0 = disable

		[Header(Cull)]
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull (default = Front)", Float) = 2 //1 = Front
	}
	SubShader
	{
		Tags{ "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"}
		Blend SrcAlpha OneMinusSrcAlpha
		//Blend One Zero
		Cull[_Cull]
		ZWrite[_ZWrite]
		ZTest[_ZTest]

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			//#pragma target 3.0
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			CBUFFER_START(UnityPerMaterial)
			float4 _MaskTex_ST;
			half4 _Color;
			half _AlphaClip;
			half _XScrollSpeed;
			half _YScrollSpeed;
			CBUFFER_END

			TEXTURE2D(_MaskTex); SAMPLER(sampler_MaskTex);

			struct appdata_t 
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f 
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MaskTex);
				o.texcoord -= half2(_XScrollSpeed, _YScrollSpeed) * _Time.y;
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half4 color = SAMPLE_TEXTURE2D(_MaskTex, sampler_MaskTex, i.texcoord); // * _Color;
				 color.a = saturate(color.a);
				// clip(color.a - _AlphaClip);
				return color;
			}
			ENDHLSL
		}
	}
}
