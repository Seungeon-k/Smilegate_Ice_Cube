Shader "ZAMMYSMITH/SpecialFX/DarkFilter_GF"
{
	Properties
	{
		[HDR]_Color("Color (default = 1,1,1,1)", color) = (1,1,1,1)
		[NoScaleOffset] _SkyboxMap ("Cubemap(HDR)", Cube) = "grey" {}
		_MaximumDarkness("Maximum Darkness", Range(0.0, 1.0)) = 0
		_StartRange("Start Range", Range(0.0, 50.0)) = 30
		_EndRange("End Range", Range(0.0, 10.0)) = 5
		_Position("Position", Vector) = (0, 0, 0, 0)

		[Header(Render State)]
		[Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("       BlendOp", Float) = 0 // 0 = Add
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("        Src", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("        Dst", Float) = 0.0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("    ZTest (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("    Cull (default = Front)", Float) = 1 //1 = Front
	}

	SubShader 
	{
		Tags {"Queue" = "Geometry" "RenderType" = "Opaque" }
		BlendOp[_BlendOp]
		Blend[_SrcBlend][_DstBlend]
		ZTest[_ZTest]
		ZWrite Off
		Cull[_Cull]

		Pass 
		{
			HLSLPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "HLSL_functions.hlsl"
            #include "Vulcanus_functions.hlsl"

			TEXTURECUBE(_SkyboxMap);
            SAMPLER(sampler_SkyboxMap);

			CBUFFER_START(UnityPerMaterial)
				half4 _Color;
				half _MaximumDarkness;
				half _StartRange;
				half _EndRange;
				half4 _Position;
			CBUFFER_END

			struct vertexInput
			{
				float4 vertex : POSITION;
				float4 uvCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 vertex : SV_POSITION;
				float3 worldPos : POSITION1;
				float4 uvCoord : TEXCOORD0;
				float4 screenPos : TEXCOORD1;
			};

			vertexOutput vert(vertexInput v) 
			{
				vertexOutput o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.worldPos = TransformObjectToWorld(v.vertex.xyz); 
				o.uvCoord = v.uvCoord;
				o.screenPos = ComputeScreenPos(float4(v.vertex.xyz, 1));
				return o;
			}

			half4 frag(vertexOutput i) : SV_Target
			{
				clip(_MaximumDarkness * _Color.a - 0.0001);

				half2 screenSpaceUV = i.vertex.xy / _ScreenParams.xy;
				float sceneRawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV).r;

                float4 clipSpacePosition;
				#if defined(SHADER_API_D3D11) || defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3)
                    float depth = sceneRawDepth * 2 - 1;
					clipSpacePosition = float4(screenSpaceUV * 2 - 1, depth, 1);
                #elif defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL)
                    float depth = sceneRawDepth;
					clipSpacePosition = float4(screenSpaceUV * 2 - 1, depth, 1);
					clipSpacePosition.y = -clipSpacePosition.y;
                #endif

				// depth = 1 - depth;
				// depth *= depth;
				// depth *= depth;
				// depth *= depth;
				// depth *= depth;
				// depth *= depth;
				// depth *= depth;
				// return half4(depth, depth, depth, depth);

				float4 worldSpacePosition = mul(UNITY_MATRIX_I_VP, clipSpacePosition);
				worldSpacePosition /= worldSpacePosition.w;

				float distance = length(worldSpacePosition - _Position);
				distance = max(0, distance - _StartRange);
				distance = saturate(distance / _EndRange);
				distance = clamp(distance, 0, _MaximumDarkness);
				// distance *= distance;
				// distance *= distance;
				distance *= _Color.a;

				float4 col = 0;
				#if defined(SHADER_API_D3D11) || defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3)
					col = SAMPLE_TEXTURECUBE(_SkyboxMap, sampler_SkyboxMap, worldSpacePosition.xyz - _WorldSpaceCameraPos);
                #elif defined(SHADER_API_VULKAN) || defined(SHADER_API_METAL)
					col = SAMPLE_TEXTURECUBE(_SkyboxMap, sampler_SkyboxMap, _WorldSpaceCameraPos - worldSpacePosition.xyz);
                #endif

				return half4(col.rgb * _Color.rgb, distance);
			}

			ENDHLSL
		}
	}
	//Fallback "Diffuse"
}