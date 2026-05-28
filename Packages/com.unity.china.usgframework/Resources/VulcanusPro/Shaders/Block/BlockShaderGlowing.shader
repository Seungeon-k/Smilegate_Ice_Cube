Shader "BlockShaderGlowing"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_EmissionColor("EmissionColor", Color) = (1,1,1,1)
		_Emission("Emission Min, Max, Speed", Vector) = (1,1,1,1)
		//_BumpTex ("BumpMap (RGBA)", 2D) = "white" {}
		_EdgeTex("BumpMap (RGBA)", 2D) = "white" {}
		_Roughness("Roughness", Range(0,1)) = 0
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecPower("Specular Power", Range(0.1,128)) = 128
	}

	SubShader
	{
		// SubShader Tags define when and under which conditions a SubShader block or
		// a pass is executed.
		Tags
		{
			"Queue" = "Geometry"
			"RenderType" = "Opaque"
			"RenderPipeline" = "UniversalPipeline"
			"ShaderUsage" = "Creator"
			"ShaderDesignation" = "Block"
		}

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
			#pragma shader_feature_local_fragment _EMISSION
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
			#include "../Supported/HLSL/CalculateUV.hlsl"

			// The structure definition defines which variables it contains.
			// This example uses the Attributes structure as an input structure in
			// the vertex shader.
			struct Attributes
			{
				// The positionOS variable contains the vertex positions in object
				// space.
				float4 positionOS   : POSITION;
				float3 normalOS     : NORMAL;
				float4 tangentOS    : TANGENT;

				// given vertex.
				float3 texcoord     : TEXCOORD0;
				float3 texcoord1	: TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{

				// The uv variable contains the UV coordinate on the texture for the
				// given vertex.
				float3 uv           : TEXCOORD0;
				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

				float3 posWS        : TEXCOORD2;    // xyz: posWS

				// normalmap
				float4 normal       : TEXCOORD3;    // xyz: normal, w: viewDir.x
				float4 tangent      : TEXCOORD4;    // xyz: tangent, w: viewDir.y
				float4 bitangent    : TEXCOORD5;    // xyz: bitangent, w: viewDir.z

				float4 bumpUV		: TEXCOORD9;

				half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

				half3 vertexLight	: TEXCOORD8;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord              : TEXCOORD7;
#endif
				float4 positionCS               : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO

			};

			CBUFFER_START(UnityPerMaterial)
			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);
			TEXTURE2D(_EdgeTex);
			SAMPLER(sampler_EdgeTex);

			float4	_MainTex_ST;
			half	_Roughness;
			half	_Fresnel;
			half	_SpecPower;
			half4	_SpecularColor;
			half4	_Color;
			half4	_EmissionColor;
			half4	_Emission;
			half	_GlobalValue;
			CBUFFER_END

			void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
			{
				inputData.positionWS = input.posWS;

				half3 viewDirWS = half3(input.normal.w, input.tangent.w, input.bitangent.w);
				inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangent.xyz, input.bitangent.xyz, input.normal.xyz));

				half3x3 tangentToWorld = half3x3(input.tangent.xyz, input.bitangent.xyz, input.normal.xyz);
				inputData.tangentToWorld = tangentToWorld;
    
				inputData.normalWS = TransformTangentToWorld(normalTS, tangentToWorld);

				inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
				viewDirWS = SafeNormalize(viewDirWS);

				inputData.viewDirectionWS = viewDirWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
				inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
				inputData.shadowCoord = float4(0, 0, 0, 0);
#endif

				inputData.fogCoord = input.fogFactorAndVertexLight.x;
				inputData.vertexLighting = input.fogFactorAndVertexLight.yzw;
				inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
				inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
				inputData.shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);

				inputData.positionCS = input.positionCS;
			}

			half4 SampleSpecularSmoothness(half alpha, half4 specColor)
			{
				half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
				specularSmoothness = specColor;
				specularSmoothness.a = exp2(10 * 0 + 1);
				return specularSmoothness;
			}

			half4 GetMainTexture(half3 uv, half2 dx, half2 dy)
			{
				half4 main_uv = GetMainUV(uv.z);
				half2 find_uv = FindUV(uv, main_uv);

				return SAMPLE_TEXTURE2D_GRAD(_MainTex, sampler_MainTex, find_uv + main_uv.xy, dx, dy);
			}

			half3 GetBumpTexture(half3 uv, half2 dx, half2 dy)
			{
				half2 nor_uv = frac(uv.xy) * 0.246f + float2(0.002f, 0.002f);

				half4 packednormal = SAMPLE_TEXTURE2D_GRAD(_EdgeTex, sampler_EdgeTex, nor_uv + GetBumpUV(round(uv.z)), dx, dy);

				return packednormal.xyz * 2 - 1; 

				//return UnpackNormal(SAMPLE_TEXTURE2D_GRAD(_EdgeTex, sampler_EdgeTex, nor_uv + GetBumpUV(round(uv.z)), dx, dy));
			}

			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
				VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
				half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
				half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);
				half fogFactor = ComputeFogFactor(vertexInput.positionCS.z);

				output.uv = input.texcoord;
				output.posWS.xyz = vertexInput.positionWS;
				output.positionCS = vertexInput.positionCS;

				half value = (_Emission.y - _Emission.x) * sin(frac(_Time.y * _Emission.z) * 3.14) + _Emission.x;
				output.bumpUV = float4(input.texcoord1.xyz, value);

				// normalmap
				output.normal = half4(normalInput.normalWS, viewDirWS.x);
				output.tangent = half4(normalInput.tangentWS, viewDirWS.y);
				output.bitangent = half4(normalInput.bitangentWS, viewDirWS.z);

				//OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
				OUTPUT_SH(output.normal.xyz, output.vertexSH);

				output.fogFactorAndVertexLight = half4(fogFactor, vertexLight);
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				output.shadowCoord = GetShadowCoord(vertexInput);
#endif
				output.vertexLight = vertexLight;

				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				half2 dx = ddx(input.uv.xy * _MainTex_ST.x * 0.8) * 1024;
				half2 dy = ddy(input.uv.xy * _MainTex_ST.y * 0.8) * 1024;

				float2 uv = input.uv.xy;
				half4 diffuseAlpha = GetMainTexture(input.uv, dx, dy);
#if VULCANUS_COLORSPACE_GAMMA
				//half3 diffuseAlphaRGB = abs(diffuseAlpha.rgb);
				//diffuseAlpha = half4(pow(diffuseAlphaRGB, 2.2), diffuseAlpha.a);
				diffuseAlpha = GammaToLinearBeginHLSL(diffuseAlpha);
#endif
				half3 diffuse = diffuseAlpha.rgb * _Color.rgb;

				half alpha = diffuseAlpha.a * _Color.a;

				half3 normalTS = GetBumpTexture(input.bumpUV.xyz, dx, dy);

				half4 specular = SampleSpecularSmoothness(alpha, _SpecularColor);
				half smoothness = specular.a;
				//half smoothness = exp2(10 * _Roughness + 1);;
				half3 emission = ((diffuseAlpha.rbg * diffuseAlpha.a) * _EmissionColor.rgb) * input.bumpUV.w;

				InputData inputData;
				InitializeInputData(input, normalTS, inputData);

				Light mainLight = GetMainLight();
				half3 viewDirWS = half3(input.normal.w, input.tangent.w, input.bitangent.w);
				half3  vertexLighting = mainLight.direction;
				float NdotL = saturate(dot(inputData.normalWS, normalize(vertexLighting)));
				half3  halfVector = normalize(vertexLighting + viewDirWS);
				float NdotH = saturate(dot(inputData.normalWS, halfVector));

				//float specularO = pow(NdotH, _SpecPower) * _Roughness * alpha;
				float specularO = pow(NdotH, _SpecPower) * _Roughness;
				specular.rgb = specular.rgb * specularO;

#if VULCANUS_COLORSPACE_GAMMA
				specular = GammaToLinearBeginHLSL(specular);
				diffuse = GammaToLinearEndHLSL(diffuse);
#endif

				half4 color = UniversalFragmentBlinnPhong(inputData, diffuse, specular, smoothness, emission, alpha, normalTS);



				color.rgb = MixFog(color.rgb, inputData.fogCoord);
				color.a = color.a;

				return color;
			}
			ENDHLSL
		}

		Pass
		{
			Name "ShadowCaster"
			Tags {"LightMode" = "ShadowCaster"}

			ZWrite On
			ZTest LEqual
			ColorMask 0
			Cull[_Cull]

			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			//#pragma multi_compile _ DOTS_INSTANCING_ON

			#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment  

			#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
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
