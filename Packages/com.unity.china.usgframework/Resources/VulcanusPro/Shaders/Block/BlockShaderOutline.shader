Shader "BlockShaderOutline"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_Thickness("Thickness", Range(0, 0.5)) = 0.1
	}

	SubShader
	{
		// SubShader Tags define when and under which conditions a SubShader block or
		// a pass is executed.
		Tags 
		{
			"RenderType" = "Transparent"
			"RenderPipeline" = "UniversalPipeline"
			"UniversalMaterialType" = "SimpleLit"
			"ShaderUsage" = "Creator"
			"Queue" = "Transparent+10"
			"ShaderDesignation" = "Block"
			"DisableBatching" = "True"
		}

		LOD 300

		Pass
		{
			// Use same blending / depth states as Standard shader
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			//Offset - 1, -1
			Blend SrcAlpha OneMinusSrcAlpha

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
			#pragma multi_compile_local __ VULCANUS_COLORSPACE_GAMMA _SHADER_USAGE_CREATOR _SHADER_DESIGNATION_BLOCK


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

			struct appdata
			{
				float4 vertex	: POSITION;
				float2 uv		: TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex	: SV_POSITION;
				float2 uv		: TEXCOORD0;
				float4 local	: TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			half4 _MainTex_ST;
			half4 _Color;
			float _Thickness;
			CBUFFER_END

			float FillFunc(float3 local)
			{
				// a block's size is 1 on each edge.
				const float complement = 0.5 - _Thickness;
				float3 dist = float3(0.5, 0.5, 0.5) - clamp(abs(frac(local) - float3(0.5, 0.5, 0.5)), 0, _Thickness);
				float3 d = (clamp(dist, complement, 0.5) - complement) / _Thickness;
				return clamp(d.x + d.y + d.z - 1, 0, 1);
			}

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//o.local =  mul(unity_ObjectToWorld , v.vertex);
				o.local = v.vertex;
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

				float4 col;
				col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _Color;
				col.a = col.a * FillFunc(i.local.xyz);
#if VULCANUS_COLORSPACE_GAMMA
				//col.rgb = pow(abs(col.rgb), 2.2);
				//col.rgb = pow(abs(col.rgb), 1.0 / 2.2);
				col.rgb = GammaToLinearBeginHLSL(col.rgb);
				col.rgb = GammaToLinearEndHLSL(col.rgb);
#endif

				return col;
			}
			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}

			ZWrite On
			ZTest LEqual
			ColorMask 0
			Cull[_Cull]

			HLSLPROGRAM
			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			//#pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
			ENDHLSL
		}

		Pass
		{
			Name "DepthOnly"
			Tags{"LightMode" = "DepthOnly"}

			ZWrite On
			ColorMask 0
			Cull[_Cull]

			HLSLPROGRAM
			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			//#pragma multi_compile _ DOTS_INSTANCING_ON

			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
			ENDHLSL
		}
	}
	
	SubShader
	{
		Tags
		{
			"RenderType" = "Transparent"
			"RenderPipeline" = "UniversalPipeline"
			"UniversalMaterialType" = "SimpleLit"
			"ShaderUsage" = "Creator"
			"Queue" = "Transparent+10"
			"ShaderDesignation" = "Block"
			"DisableBatching" = "True"
		}

		LOD 300

		Pass
		{
			// Use same blending / depth states as Standard shader
			Cull Off
			Lighting Off
			ZWrite Off
			Fog { Mode Off }
			//Offset - 1, -1
			Blend SrcAlpha OneMinusSrcAlpha

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
			#pragma multi_compile_local __ VULCANUS_COLORSPACE_GAMMA _SHADER_USAGE_CREATOR _SHADER_DESIGNATION_BLOCK


			#pragma shader_feature_local _RECEIVE_SHADOWS_OFF

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
			
			// This line defines the name of the vertex shader. 
			#pragma vertex vert
			// This line defines the name of the fragment shader. 
			#pragma fragment frag

			//#pragma multi_compile _ DOTS_INSTANCING_ON
			#define BUMP_SCALE_NOT_SUPPORTED 1

			// The Core.hlsl file contains definitions of frequently used HLSL
			// macros and functions, and also contains #include references to other
			// HLSL files (for example, Common.hlsl, SpaceTransforms.hlsl, etc.).
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"       
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "../Supported/HLSL/GammaToLinear.hlsl"

			struct appdata
			{
				float4 vertex	: POSITION;
				float2 uv		: TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex	: SV_POSITION;
				float2 uv		: TEXCOORD0;
				float4 local	: TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			half4 _MainTex_ST;
			half4 _Color;
			float _Thickness;
			CBUFFER_END

			float FillFunc(float3 local)
			{
				// a block's size is 1 on each edge.
				const float complement = 0.5 - _Thickness;
				float3 dist = float3(0.5, 0.5, 0.5) - clamp(abs(frac(local) - float3(0.5, 0.5, 0.5)), 0, _Thickness);
				float3 d = (clamp(dist, complement, 0.5) - complement) / _Thickness;
				return clamp(d.x + d.y + d.z - 1, 0, 1);
			}

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				//o.local =  mul(unity_ObjectToWorld , v.vertex);
				o.local = v.vertex;
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

				float4 col;
				col = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv) * _Color;
				col.a = col.a * FillFunc(i.local.xyz);

#if VULCANUS_COLORSPACE_GAMMA
				//col.rgb = pow(abs(col.rgb), 2.2);
				//col.rgb = pow(abs(col.rgb), 1.0 / 2.2);
				col.rgb = GammaToLinearBeginHLSL(col.rgb);
				col.rgb = GammaToLinearEndHLSL(col.rgb);
#endif

				return col;
			}
			ENDHLSL


		}

		Pass
		{
			Name "ShadowCaster"
			Tags{"LightMode" = "ShadowCaster"}

			ZWrite On
			ZTest LEqual
			ColorMask 0
			Cull[_Cull]

			HLSLPROGRAM
			#pragma only_renderers d3d9 d3d11 glcore gles gles3 metal n3ds wiiu vulkan
			#pragma target 2.0

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			//#pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
			ENDHLSL
		}

		Pass
		{
			Name "DepthOnly"
			Tags{"LightMode" = "DepthOnly"}

			ZWrite On
			ColorMask 0
			Cull[_Cull]

			HLSLPROGRAM
			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			//#pragma multi_compile _ DOTS_INSTANCING_ON

			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
			ENDHLSL
		}

	}
}