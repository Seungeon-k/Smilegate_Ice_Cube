Shader "ParticleShaderAlphaBlended" 
{
	Properties
	{
		_TintColor("Tint Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex("Particle Texture", 2D) = "white" {}
		_InvFade("Soft Particles Factor", Range(0.01,3.0)) = 1.0
	}

	Category
	{
		Tags 
		{ 
			"Queue" = "Transparent"
			"IgnoreProjector" = "True"
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "Transparent"
			"PreviewType" = "Plane"
			"ShaderUsage" = "Creator" 
		}

		Blend SrcAlpha OneMinusSrcAlpha
		ColorMask RGB
		Cull Off Lighting Off ZWrite Off

		SubShader 
		{
			Pass 
			{
				// The HLSL code block. Unity SRP uses the HLSL language.
				HLSLPROGRAM
				#pragma exclude_renderers gles gles3 glcore

				// -------------------------------------
				// Material Keywords
				#pragma shader_feature_local_fragment _ALPHATEST_ON
				#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
				//#pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
				//#pragma shader_feature_local _ _SPECULAR_COLOR
				#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
				#pragma shader_feature_local _NORMALMAP

				#pragma multi_compile_local __ VULCANUS_COLORSPACE_GAMMA _SHADER_USAGE_CREATOR


				//#pragma shader_feature_local _RECEIVE_SHADOWS_OFF

				// -------------------------------------
				// Universal Pipeline keywords
				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
				#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
				#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
				#pragma multi_compile_fragment _ _SHADOWS_SOFT
				//#pragma multi_compile_fragment _ _SPECULAR_COLOR
				//#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
				#pragma multi_compile _ SHADOWS_SHADOWMASK
				//#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION

				// -------------------------------------
				// Unity defined keywords
				//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
				//#pragma multi_compile _ LIGHTMAP_ON
				#pragma multi_compile_fog

				//--------------------------------------
				// GPU Instancing
				#pragma multi_compile_instancing
				//#pragma multi_compile _ DOTS_INSTANCING_ON
				#define BUMP_SCALE_NOT_SUPPORTED 1

				// This line defines the name of the vertex shader. 
				#pragma vertex vert
				// This line defines the name of the fragment shader. 
				#pragma fragment frag

				#define BUMP_SCALE_NOT_SUPPORTED 1

				// The Core.hlsl file contains definitions of frequently used HLSL
				// macros and functions, and also contains #include references to other
				// HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
				#include "../Supported/HLSL/GammaToLinear.hlsl"

				CBUFFER_START(UnityPerMaterial)

				sampler2D _MainTex;
				half4 _TintColor;
				float4 _MainTex_ST;

				CBUFFER_END

				struct appdata_t
				{
					float4 vertex : POSITION;
					half4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					half4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					//UNITY_FOG_COORDS(1)
					float fogCoord : TEXCOORD1;
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				v2f vert(appdata_t v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					//o.vertex = UnityObjectToClipPos(v.vertex);
					o.vertex = TransformObjectToHClip(v.vertex.xyz);
					#ifdef SOFTPARTICLES_ON
					o.projPos = ComputeScreenPos(o.vertex);
					COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color * _TintColor;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					//UNITY_TRANSFER_FOG(o,o.vertex);
					o.fogCoord = ComputeFogFactor(o.vertex.z);
					return o;
				}

				//UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
				float _InvFade;

				half4 frag(v2f i) : SV_Target
				{
					#ifdef SOFTPARTICLES_ON
					float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float partZ = i.projPos.z;
					float fade = saturate(_InvFade * (sceneZ - partZ));
					i.color.a *= fade;
					#endif

					half4 col = tex2D(_MainTex, i.texcoord);
#if VULCANUS_COLORSPACE_GAMMA
					col = GammaToLinearBeginHLSL(col);
					
#endif

					col = 2.0f * i.color * col;
					col.a = saturate(col.a); // alpha should not have double-brightness applied to it, but we can't fix that legacy behavior without breaking everyone's effects, so instead clamp the output to get sensible HDR behavior (case 967476)

#if VULCANUS_COLORSPACE_GAMMA
					col = GammaToLinearEndHLSL(col);
					
#endif

					col.rgb = MixFog(col.rgb, i.fogCoord);
					//UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDHLSL
			}
		}

		SubShader
		{
			Pass
			{
				// The HLSL code block. Unity SRP uses the HLSL language.
				HLSLPROGRAM
				#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal n3ds wiiu vulkan
				#pragma target 2.0

				// -------------------------------------
				// Material Keywords
				#pragma shader_feature_local_fragment _ALPHATEST_ON
				#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
				//#pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
				//#pragma shader_feature_local _ _SPECULAR_COLOR
				#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
				#pragma shader_feature_local _NORMALMAP

				//#pragma shader_feature_local _RECEIVE_SHADOWS_OFF

				// -------------------------------------
				// Universal Pipeline keywords
				#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
				#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
				#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
				#pragma multi_compile_fragment _ _SHADOWS_SOFT
				//#pragma multi_compile_fragment _ _SPECULAR_COLOR
				//#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
				#pragma multi_compile _ SHADOWS_SHADOWMASK
				//#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION

				// -------------------------------------
				// Unity defined keywords
				//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
				//#pragma multi_compile _ LIGHTMAP_ON
				#pragma multi_compile_fog

				//--------------------------------------
				// GPU Instancing
				#pragma multi_compile_instancing
				//#pragma multi_compile _ DOTS_INSTANCING_ON
				#define BUMP_SCALE_NOT_SUPPORTED 1

				// This line defines the name of the vertex shader. 
				#pragma vertex vert
				// This line defines the name of the fragment shader. 
				#pragma fragment frag

				#define BUMP_SCALE_NOT_SUPPORTED 1

				// The Core.hlsl file contains definitions of frequently used HLSL
				// macros and functions, and also contains #include references to other
				// HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

				CBUFFER_START(UnityPerMaterial)

				sampler2D _MainTex;
				half4 _TintColor;
				float4 _MainTex_ST;

				CBUFFER_END

				struct appdata_t
				{
					float4 vertex : POSITION;
					half4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					half4 color : COLOR;
					float2 texcoord : TEXCOORD0;
					//UNITY_FOG_COORDS(1)
					float fogCoord : TEXCOORD1;
					#ifdef SOFTPARTICLES_ON
					float4 projPos : TEXCOORD2;
					#endif
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				v2f vert(appdata_t v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
					//o.vertex = UnityObjectToClipPos(v.vertex);
					o.vertex = TransformObjectToHClip(v.vertex.xyz);
					#ifdef SOFTPARTICLES_ON
					o.projPos = ComputeScreenPos(o.vertex);
					COMPUTE_EYEDEPTH(o.projPos.z);
					#endif
					o.color = v.color * _TintColor;
					o.texcoord = TRANSFORM_TEX(v.texcoord,_MainTex);
					//UNITY_TRANSFER_FOG(o,o.vertex);
					o.fogCoord = ComputeFogFactor(o.vertex.z);
					return o;
				}

				//UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
				float _InvFade;

				half4 frag(v2f i) : SV_Target
				{
					#ifdef SOFTPARTICLES_ON
					float sceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)));
					float partZ = i.projPos.z;
					float fade = saturate(_InvFade * (sceneZ - partZ));
					i.color.a *= fade;
					#endif

					half4 col = 2.0f * i.color * tex2D(_MainTex, i.texcoord);
					col.a = saturate(col.a); // alpha should not have double-brightness applied to it, but we can't fix that legacy behavior without breaking everyone's effects, so instead clamp the output to get sensible HDR behavior (case 967476)

					col.rgb = MixFog(col.rgb, i.fogCoord);
					//UNITY_APPLY_FOG(i.fogCoord, col);
					return col;
				}
				ENDHLSL
			}
		}
	}
	Fallback "VertexLit"
}