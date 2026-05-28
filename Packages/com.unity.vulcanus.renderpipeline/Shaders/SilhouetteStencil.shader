Shader "Vulcanus/SilhouetteStencil"
{
	Properties
	{
		[Header(Render State)]
		[Enum(None,0,Alpha,1,Red,8,Green,4,Blue,2,RGB,14,RGBA,15)] _ColorMask("└─Color Mask", Int) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("└─ZTest (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("└─Cull (default = Front)", Float) = 1 //1 = Front

		//Set to NotEqual if you want to mask by specific _StencilRef value, else set to Disable
		[Header(Stencil Masking)]
		_StencilRef("└─StencilRef", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("└─StencilComp (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.StencilOp)]_PassOperation("└─PassOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_FailOperation("└─FailOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_ZFailOperation("└─ZFailOperation (default = Keep)", Float) = 0 //0 = keep
	}

	SubShader 
	{
		Tags {"Queue" = "Geometry" "RenderType" = "Opaque" }
		Blend One Zero
		ZTest[_ZTest]
		ZWrite Off
		Cull[_Cull]
		ColorMask[_ColorMask]

		Stencil
		{
			ReadMask 1
			//WriteMask 255
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

				o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				//float3 normalWS = TransformObjectToWorldNormal(v.normalOS.xyz);
				//float3 normalCS = mul((float3x3)UNITY_MATRIX_VP, normalize(normalWS));

				// float3 cameraDirection = mul((float3x3)unity_CameraToWorld, float3(0, 0, 1));
				// cameraDirection = normalize(cameraDirection);

				// half depthMultiplyFactor = dot(normalWS, cameraDirection);
				// float2 offset = normalize(normalCS.xy) / _ScreenParams.xy * o.positionCS.w;
				// o.positionCS.xy += offset;

				////o.vertex = TransformObjectToHClip(v.vertex.xyz);
				return o;
			}

			half4 frag(vertexOutput i) : SV_Target
			{
				return half4(0, 0, 0, 1);
			}

			ENDHLSL
		}
	}
}