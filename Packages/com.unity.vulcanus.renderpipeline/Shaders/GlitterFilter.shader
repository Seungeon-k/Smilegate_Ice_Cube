Shader "Vulcanus/SpecialFX/GlitterFilter"
{
	Properties
	{
		_Range("Glitter Range", Float) = 50
		_ColorPower("Color Power", Float) = 5
		_NoiseScale("Noise Scale", Float) = 1
		_AnimSpeed("Animation Speed", Float) = 1
		_SparkleDepth("Glitter Depth", Float) = 0

		[HideInInspector]
		_RenderScale("Render Scale", Float) = 1
		[Header(Render State)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("        Src", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("        Dst", Float) = 0.0
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("    ZTest (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("    Cull (default = Front)", Float) = 1 //1 = Front
	}

	SubShader 
	{
		Tags {"Queue" = "Geometry+200" "RenderType" = "Opaque" }
		Blend[_SrcBlend][_DstBlend]
		//Blend One Zero
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
            #include "Packages/com.vulcanus.render-pipelines.vulcanus/Shaders/HLSL_functions.hlsl"
            #include "Packages/com.vulcanus.render-pipelines.vulcanus/Shaders/Vulcanus_functions.hlsl"

            TEXTURE2D(_DitherMask);
            SAMPLER(sampler_DitherMask);

			CBUFFER_START(UnityPerMaterial)
				float _Range;
				float _ColorPower = 5;
				float _NoiseScale = 1;
				float _AnimSpeed = 1;
				float _SparkleDepth = 0;
				float _RenderScale;
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
				half2 screenSpaceUV = i.vertex.xy / _ScreenParams.xy * 1 / _RenderScale;
				float sceneRawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV).r;
				float depthRatio = 1 - saturate(LinearEyeDepth(sceneRawDepth, _ZBufferParams) / _Range);
				clip(depthRatio - 0.01);

				//#if defined(SHADER_API_D3D11) || defined(SHADER_API_GLCORE) || defined(SHADER_API_GLES3)
                #if UNITY_UV_STARTS_AT_TOP
                    float depth = sceneRawDepth;
                    float4 clipSpacePosition = float4(screenSpaceUV * 2 - 1, depth, 1);
                    clipSpacePosition.y = -clipSpacePosition.y;
				#else
                    float depth = sceneRawDepth * 2 - 1;
                    float4 clipSpacePosition = float4(screenSpaceUV * 2 - 1, depth, 1);
                #endif
				float4 worldSpacePosition = mul(UNITY_MATRIX_I_VP, clipSpacePosition);
				worldSpacePosition /= worldSpacePosition.w;
				
                float3 position = worldSpacePosition.xyz;
                float3 viewDirection = worldSpacePosition.xyz - _WorldSpaceCameraPos.xyz;

				//Issue on 0 y Position
				position.y += 0.1526;

				float noiseScale = _NoiseScale * 10;
				float sparkles = snoise(position * noiseScale + (viewDirection * _SparkleDepth) - (_Time.x * _AnimSpeed));
				sparkles *= snoise(position * noiseScale + (_Time.x * _AnimSpeed));
				sparkles = smoothstep(0.5, 0.6, sparkles) * _ColorPower * (depthRatio * depthRatio);

				return float4(abs(frac(position)), 0) * sparkles;
			}

			ENDHLSL
		}
	}
	//Fallback "Diffuse"
}