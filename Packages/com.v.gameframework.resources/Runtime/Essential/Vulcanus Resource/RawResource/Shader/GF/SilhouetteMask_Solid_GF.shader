Shader "ZAMMYSMITH/SilhouetteMask_Solid_GF"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		[HDR] _SilhouetteColor("Silhouette Color", Color) = (1, 1, 1, 0.0)
		_MaskScale("MaskScale", Float) = 0
		_XScrollSpeed("X Scroll Speed", Float) = 0
		_YScrollSpeed("Y Scroll Speed", Float) = 0

		[Header(Render State)]
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("└─ZTest (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("└─Cull (default = Front)", Float) = 1 //1 = Front

		////Set to NotEqual if you want to mask by specific _StencilRef value, else set to Disable
		[Header(Stencil Masking)]
		_StencilRef("└─StencilRef", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("└─StencilComp (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.StencilOp)]_PassOperation("└─PassOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_FailOperation("└─FailOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_ZFailOperation("└─ZFailOperation (default = Keep)", Float) = 0 //0 = keep
	}

	SubShader 
	{
		Tags {"Queue" = "Geometry+204" "RenderType" = "Opaque" }
		Blend One Zero
		//Blend SrcAlpha OneMinusSrcAlpha
		ZTest[_ZTest]
		ZWrite Off
		Cull[_Cull]
//		Offset 0, -99999

		Stencil
		{
			ReadMask 1
		//	WriteMask 255*/
			Ref[_StencilRef]
			Comp[_StencilComp]
			Pass [_PassOperation]
			Fail [_FailOperation]
			ZFail [_ZFailOperation]
		}

		Pass {
			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
			#include "Vulcanus_Common.hlsl"

			CBUFFER_START(UnityPerMaterial)
				float4 _MainTex_ST;
				half4 _SilhouetteColor;
				half _MaskScale;
				half _XScrollSpeed;
				half _YScrollSpeed;
			CBUFFER_END

			TEXTURE2D_X(_MainTex);
			SAMPLER(sampler_MainTex);

			struct vertexInput
			{
				float4 positionOS : POSITION;
				float4 normalOS : NORMAL;
			};

			struct vertexOutput
			{
				float4 positionHCS : SV_POSITION;
				float4 positionSS : TEXCOORD0;
				float4 centerPositionCS : TEXCOORD1;
			};

			vertexOutput vert(vertexInput v) 
			{
				vertexOutput o = (vertexOutput)0;
				o.positionHCS = TransformObjectToHClip(v.positionOS.xyz);
				o.centerPositionCS = TransformWorldToHClip(UNITY_MATRIX_M._14_24_34);

			#if defined(UNITY_REVERSED_Z)
				o.positionHCS.z += 0.005;
			#else
				o.positionHCS.z -= 0.005;
			#endif

				return o;
			}

			half4 frag(vertexOutput i) : SV_Target
			{
				half2 screenUV = i.positionHCS.xy / _ScreenParams.xy;
				screenUV.y = 1 - screenUV.y;

				half2 localUV = (screenUV * 2.0 - 1) * i.centerPositionCS.w - i.centerPositionCS.xy;
				localUV.x *= _ScreenParams.x / _ScreenParams.y;
				localUV * -1.0 / UNITY_MATRIX_P[1][1];
				localUV.y *= -1;

				localUV.xy /= _MaskScale;
				localUV.xy += frac(half2(_XScrollSpeed, _YScrollSpeed) * _Time.y);

				half mask = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, localUV).r;
				clip(mask - 0.5);
				return half4(_SilhouetteColor.rgb, 1);
			}

			ENDHLSL
		}
	}
	//Fallback "Diffuse"
}