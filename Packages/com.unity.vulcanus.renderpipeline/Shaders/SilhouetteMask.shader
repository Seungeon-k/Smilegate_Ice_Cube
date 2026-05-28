Shader "Vulcanus/SilhouetteMask"
{
	Properties
	{
		[HDR] _SilhouetteColor("Silhouette Color", Color) = (1, 1, 1, 0.0)
		_LineThickness("Line Thickness", Float) = 0

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
		ZTest[_ZTest]
		ZWrite Off
		Cull[_Cull]

		Stencil
		{
			ReadMask 1
		//	WriteMask 255
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

			CBUFFER_START(UnityPerMaterial)
				half4 _SilhouetteColor;
				half _LineThickness;
			CBUFFER_END

			struct vertexInput
			{
				float4 positionOS : POSITION;
				float4 normalOS : NORMAL;
			};

			struct vertexOutput
			{
				float4 positionCS : SV_POSITION;
			};

			vertexOutput vert(vertexInput v) 
			{
				vertexOutput o;
				
				// v.positionOS.xyz += v.normalOS * _LineThickness * 0.01;
				// o.positionCS = TransformObjectToHClip(v.positionOS);
				o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				float3 normalWS = TransformObjectToWorldNormal(v.normalOS.xyz);
				float3 normalCS = mul((float3x3)UNITY_MATRIX_VP, normalize(normalWS));

				float3 cameraDirection = mul((float3x3)unity_CameraToWorld, float3(0, 0, 1));
				cameraDirection = normalize(cameraDirection);

				// half depthMultiplyFactor = dot(normalWS, cameraDirection);
				float2 offset = normalize(normalCS.xy) / _ScreenParams.xy * _LineThickness * o.positionCS.w;
				o.positionCS.xy += offset;

			#if defined(UNITY_REVERSED_Z)
				o.positionCS.z += 0.005;
			#else
				o.positionCS.z -= 0.005;
			#endif

				return o;
			}

			half4 frag(vertexOutput i) : SV_Target
			{
				half4 color = _SilhouetteColor;
				return color;
			}

			ENDHLSL
		}
	}
	//Fallback "Diffuse"
}