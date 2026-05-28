Shader "BlockShaderCommon"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}               // Keywords: !! SPECULAR BUMP SPECULAR_BUMP !! availeble for 3 keywords
		_EdgeTex("EdgeMap (RGBA)", 2D) = "block" {}         // Keywords: !! SPECULAR BUMP SPECULAR_BUMP
		//_BumpTex("BumpMap (RGBA)", 2D) = "white" {}        // Keywords: !! SPECULAR BUMP SPECULAR_BUMP
		_Roughness("Roughness", Range(0,1)) = 0

		_SpecularColor("Specular Color", Color) = (1,1,1,1) // Keywords: !! SPECULAR SPECULAR_BUMP
		_Color("Color", Color) = (1,1,1,1)
		_SpecPower("Specular Power", Range(0.1,128)) = 128  // Keywords: !! SPECULAR SPECULAR_BUMP
		
		// Blending state
		//[HideInInspector] _Surface("__surface", Float) = 0.0
		//[HideInInspector] _Blend("__blend", Float) = 0.0
		//[HideInInspector] _AlphaClip("__clip", Float) = 0.0
		//[HideInInspector] _SrcBlend("__src", Float) = 1.0
		//[HideInInspector] _DstBlend("__dst", Float) = 0.0
		//[HideInInspector] _ZWrite("__zw", Float) = 1.0
		//[HideInInspector] _Cull("__cull", Float) = 2.0
	}

	SubShader
	{
		// SubShader Tags define when and under which conditions a SubShader block or
		// a pass is executed.
					

		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"  "UniversalMaterialType" = "SimpleLit"  "ShaderModel" = "4.5" "ShaderUsage" = "Creator" "ShaderDesignation" = "Block"}
		LOD 300

		Pass
		{
			Name "ForwardLit"
			Tags { "LightMode" = "UniversalForward" }

			// Use same blending / depth states as Standard shader
			//Blend[_SrcBlend][_DstBlend]
			//ZWrite[_ZWrite]
			Cull[_Cull]


			// The HLSL code block. Unity SRP uses the HLSL language.
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

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
			//#pragma multi_compile_local __ SPECULAR BUMP SPECULAR_BUMP

			// -------------------------------------
			// Unity defined keywords
			#pragma multi_compile _ _MIXED_LIGHTING_SUBTRACTIVE
			#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile_fog
			
			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON
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
				float3 normalOS      : NORMAL;
				float4 tangentOS     : TANGENT;

				// given vertex.
				float3 texcoord           : TEXCOORD0;
				float3 texcoord1		: TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{

				// The uv variable contains the UV coordinate on the texture for the
				// given vertex.
				float3 uv           : TEXCOORD0;
				//float3 bumpUV		: TEXCOORD1;
				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

				float3 posWS                    : TEXCOORD2;    // xyz: posWS

				// normalmap
				float4 normal                   : TEXCOORD3;    // xyz: normal, w: viewDir.x
				float4 tangent                  : TEXCOORD4;    // xyz: tangent, w: viewDir.y
				float4 bitangent                : TEXCOORD5;    // xyz: bitangent, w: viewDir.z
				
				float3 bumpUV					: TEXCOORD9;

				half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

				half3 vertexLight : TEXCOORD8;
				

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord              : TEXCOORD7;
#endif

				float4 positionCS               : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO

			};
			
			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _Color;

			sampler2D _EdgeTex;
			

			

			half4 _SpecularColor;
			float _Roughness;
			float _SpecPower;
			half _Surface;





			half4 GetMainTexture(half3 uv, half2 dx, half2 dy)
			{
				half4 main_uv = GetMainUV(uv.z);
				half2 find_uv = FindUV(uv, main_uv);

				return tex2D(_MainTex, find_uv + main_uv.xy, dx, dy);
			}


			half3 GetBumpTexture(half3 uv, half2 dx, half2 dy)
			{
				half2 nor_uv = frac(uv.xy) * 0.246f + float2(0.002f, 0.002f);

//				return UnpackNormal(tex2D(_EdgeTex, nor_uv + GetBumpUV(round(uv.z)), dx, dy));
				
				half4 packednormal = tex2D(_EdgeTex, nor_uv + GetBumpUV(round(uv.z)), dx, dy);

				//return packednormal; 

				return packednormal.xyz * 2 - 1;
//
//#if defined(SHADER_API_GLES) && defined(SHADER_API_MOBILE)
//				return packednormal.xyz * 2 - 1;
//#else
//
//
//				half3 normal;
//
//				normal.xy = packednormal.wy * 2 - 1;
//				normal.z = sqrt(1 - normal.x * normal.x - normal.y * normal.y);
//				return normal;
//#endif
			}


			void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
			{
				inputData.positionWS = input.posWS;


				half3 viewDirWS = half3(input.normal.w, input.tangent.w, input.bitangent.w);
	
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


			half4 UniversalFragmentBlinnPhongBlock(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half alpha)
			{
				// To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders

				half4 shadowMask = half4(1, 1, 1, 1);


				Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

#if defined(_SCREEN_SPACE_OCCLUSION)
				AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
				mainLight.color *= aoFactor.directAmbientOcclusion;
				inputData.bakedGI *= aoFactor.indirectAmbientOcclusion;
#endif

				MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

				half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
				half3 diffuseColor = inputData.bakedGI + LightingLambert(attenuatedLightColor, mainLight.direction, inputData.normalWS);
				half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);

				uint pixelLightCount = GetAdditionalLightsCount();
				for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
				{
					Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
#if defined(_SCREEN_SPACE_OCCLUSION)
					light.color *= aoFactor.directAmbientOcclusion;
#endif
					half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
					diffuseColor += LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
					specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
				}

				half3 finalColor = diffuseColor * diffuse;


				finalColor += specularColor;


				return half4(finalColor, alpha);
			}

			// The vertex shader definition with properties defined in the Varyings 
			// structure. The type of the vert function must match the type (struct)
			// that it returns.
			Varyings vert(Attributes input)
			{
				// Declaring the output object (OUT) with the Varyings struct.
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

				output.bumpUV = input.texcoord1;

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

			// The fragment shader definition.
			half4 frag(Varyings input) : SV_Target
			{

				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
				 

				float2 uv = input.uv.xy;
				half2 dx = ddx(input.uv.xy * _MainTex_ST.x * 0.1f) * _MainTex_ST.w;
				half2 dy = ddy(input.uv.xy * _MainTex_ST.y * 0.1f) * _MainTex_ST.w;

				half4 diffuseAlpha = GetMainTexture(input.uv, dx, dy);
#if VULCANUS_COLORSPACE_GAMMA

				diffuseAlpha = GammaToLinearBeginHLSL(diffuseAlpha);
				//half3 diffuseAlphaRGB = abs(diffuseAlpha.rgb);
				//diffuseAlpha = half4(pow(diffuseAlphaRGB, 2.2), diffuseAlpha.a);
#endif
				half3 diffuse = diffuseAlpha.rgb * _Color.rgb;

				half alpha = diffuseAlpha.a * _Color.a;



				half3 normalTS = GetBumpTexture(input.bumpUV, dx, dy);
				
				half4 specular = SampleSpecularSmoothness(alpha, _SpecularColor);
				half smoothness = specular.a;
				
				
				

				InputData inputData;
				InitializeInputData(input, normalTS, inputData);

				Light mainLight = GetMainLight();
				half3 viewDirWS = half3(input.normal.w, input.tangent.w, input.bitangent.w);
				half3  vertexLighting = mainLight.direction; 
				float NdotL = saturate(dot(inputData.normalWS, normalize(vertexLighting)));
				half3  halfVector = normalize(vertexLighting  + viewDirWS );
				float NdotH = saturate(dot(inputData.normalWS , halfVector ));

				//float specularO = pow(NdotH, _SpecPower) * _Roughness * alpha;
				float specularO = pow(NdotH, _SpecPower) * _Roughness;

				specular.rgb = specular.rgb * specularO;

#if VULCANUS_COLORSPACE_GAMMA
				specular = GammaToLinearBeginHLSL(specular);
				diffuse = GammaToLinearEndHLSL(diffuse);

#endif	
				

				half4 color = UniversalFragmentBlinnPhongBlock(inputData, diffuse, specular, smoothness, alpha);
				
	

				color.rgb = MixFog(color.rgb, inputData.fogCoord);
				color.a = OutputAlpha(color.a, _Surface);

				return color;

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
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
			

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON

			// This line defines the name of the vertex shader. 
			#pragma vertex vert
			// This line defines the name of the fragment shader. 
			#pragma fragment frag

			/*#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment  */

			/*#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"*/

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
			 
			float3 _LightDirection;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _Color;


			struct Attributes
			{
				float4 positionOS   : POSITION;
				float3 normalOS     : NORMAL;

				float2 texcoord     : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{
				float2 uv           : TEXCOORD0;
				float4 positionCS   : SV_POSITION;
			};


			float4 GetShadowPositionHClip(Attributes input)
			{
				float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
				float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

#if UNITY_REVERSED_Z
				positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
				positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif

				return positionCS;
			}
			// #define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)
			half AlphaLocal(half albedoAlpha, half4 color)
			{

				half alpha = color.a;


				return alpha;
			}
			
			Varyings vert(Attributes input)
			{
				Varyings output;
				UNITY_SETUP_INSTANCE_ID(input);

				//output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
				output.uv = input.texcoord;
				output.positionCS = GetShadowPositionHClip(input);
				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{

				float2 uv = input.uv.xy;
				half2 dx = ddx(input.uv.xy * _MainTex_ST.x * 0.1f) * _MainTex_ST.w;
				half2 dy = ddy(input.uv.xy * _MainTex_ST.y * 0.1f) * _MainTex_ST.w;

				half diffuseAlpha = 1.0h;
				AlphaLocal(diffuseAlpha, _Color);

				//Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _Color, _Cutoff);
				return 0;
			}

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
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

			#pragma vertex DepthOnlyVertex
			#pragma fragment DepthOnlyFragment

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

			//--------------------------------------
			// GPU Instancing
			#pragma multi_compile_instancing
			#pragma multi_compile _ DOTS_INSTANCING_ON

			#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
			ENDHLSL
		}
	}

	SubShader
	{
		Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline"  "UniversalMaterialType" = "SimpleLit" "ShaderModel" = "2.0"}
		LOD 300

		Pass
		{
			Name "ForwardLit"
			Tags { "LightMode" = "UniversalForward" }

			// Use same blending / depth states as Standard shader
			//Blend[_SrcBlend][_DstBlend]
			//ZWrite[_ZWrite]
			Cull[_Cull]


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
			//#pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
			#pragma multi_compile _ SHADOWS_SHADOWMASK
			//#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
			//#pragma multi_compile_local __ SPECULAR BUMP SPECULAR_BUMP

			// -------------------------------------
			// Unity defined keywords
			//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			//#pragma multi_compile _ LIGHTMAP_ON
			#pragma multi_compile_fog



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
				float3 normalOS      : NORMAL;
				float4 tangentOS     : TANGENT;

				// given vertex.
				float3 texcoord           : TEXCOORD0;
				float3 texcoord1		: TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{

				// The uv variable contains the UV coordinate on the texture for the
				// given vertex.
				float3 uv           : TEXCOORD0;

				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

				float3 posWS                    : TEXCOORD2;    // xyz: posWS

				// normalmap
				float4 normal                   : TEXCOORD3;    // xyz: normal, w: viewDir.x
				float4 tangent                  : TEXCOORD4;    // xyz: tangent, w: viewDir.y
				float4 bitangent                : TEXCOORD5;    // xyz: bitangent, w: viewDir.z

				float3 bumpUV					: TEXCOORD9;

				half4 fogFactorAndVertexLight   : TEXCOORD6; // x: fogFactor, yzw: vertex light

				half3 vertexLight : TEXCOORD8;


#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
				float4 shadowCoord              : TEXCOORD7;
#endif

				float4 positionCS               : SV_POSITION;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO

			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _Color;
			sampler2D _EdgeTex;








			half4 _SpecularColor;
			float _Roughness;
			float _SpecPower;
			half _Surface;


			half4 GetMainTexture(half3 uv, half2 dx, half2 dy)
			{
				half4 main_uv = GetMainUV(uv.z);
				half2 find_uv = FindUV(uv, main_uv);

				return tex2D(_MainTex, find_uv + main_uv.xy, dx, dy);
			}


			half3 GetBumpTexture(half3 uv, half2 dx, half2 dy)
			{
				half2 nor_uv = frac(uv.xy) * 0.246f + float2(0.002f, 0.002f);

//				return UnpackNormal(tex2D(_EdgeTex, nor_uv + GetBumpUV(round(uv.z)), dx, dy));

				half4 packednormal = tex2D(_EdgeTex, nor_uv + GetBumpUV(round(uv.z)), dx, dy);
//
//#if defined(SHADER_API_GLES) && defined(SHADER_API_MOBILE)
				return packednormal.xyz * 2 - 1;
//#else
//
//
//				half3 normal;
//
//				normal.xy = packednormal.wy * 2 - 1;
//				normal.z = sqrt(1 - normal.x * normal.x - normal.y * normal.y);
//				return normal;
//#endif
			}


			void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
			{
				inputData.positionWS = input.posWS;


				half3 viewDirWS = half3(input.normal.w, input.tangent.w, input.bitangent.w);
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


			half4 UniversalFragmentBlinnPhongBlock(InputData inputData, half3 diffuse, half4 specularGloss, half smoothness, half alpha)
			{
				// To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders

				half4 shadowMask = half4(1, 1, 1, 1);


				Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

#if defined(_SCREEN_SPACE_OCCLUSION)
				AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
				mainLight.color *= aoFactor.directAmbientOcclusion;
				inputData.bakedGI *= aoFactor.indirectAmbientOcclusion;
#endif

				MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

				half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
				half3 diffuseColor = inputData.bakedGI + LightingLambert(attenuatedLightColor, mainLight.direction, inputData.normalWS);
				half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);

				uint pixelLightCount = GetAdditionalLightsCount();
				for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
				{
					Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
#if defined(_SCREEN_SPACE_OCCLUSION)
					light.color *= aoFactor.directAmbientOcclusion;
#endif
					half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
					diffuseColor += LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
					specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
				}

				half3 finalColor = diffuseColor * diffuse;


				finalColor += specularColor;


				return half4(finalColor, alpha);
			}


			// The vertex shader definition with properties defined in the Varyings 
			// structure. The type of the vert function must match the type (struct)
			// that it returns.
			Varyings vert(Attributes input)
			{
				// Declaring the output object (OUT) with the Varyings struct.
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

				output.bumpUV = input.texcoord1;

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

			// The fragment shader definition.
			half4 frag(Varyings input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

				float2 uv = input.uv.xy;
				half2 dx = ddx(input.uv.xy * _MainTex_ST.x * 0.1f) * _MainTex_ST.w;
				half2 dy = ddy(input.uv.xy * _MainTex_ST.y * 0.1f) * _MainTex_ST.w;

				half4 diffuseAlpha = GetMainTexture(input.uv, dx, dy);
#if VULCANUS_COLORSPACE_GAMMA
				diffuseAlpha = GammaToLinearBeginHLSL(diffuseAlpha);
				//half3 diffuseAlphaRGB = abs(diffuseAlpha.rgb);
				//diffuseAlpha = half4(pow(diffuseAlphaRGB, 2.2), diffuseAlpha.a);
#endif
				half3 diffuse = diffuseAlpha.rgb * _Color.rgb;

				half alpha = diffuseAlpha.a * _Color.a;

				half3 normalTS = GetBumpTexture(input.bumpUV, dx, dy);

				half4 specular = SampleSpecularSmoothness(alpha, _SpecularColor);
				half smoothness = specular.a;
			

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

				half4 color = UniversalFragmentBlinnPhongBlock(inputData, diffuse, specular, smoothness, alpha);

				color.rgb = MixFog(color.rgb, inputData.fogCoord);
				color.a = OutputAlpha(color.a, _Surface);

				return color;

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
			#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA

			/*#pragma vertex ShadowPassVertex
			#pragma fragment ShadowPassFragment

			#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"*/


			// This line defines the name of the vertex shader. 
			#pragma vertex vert
			// This line defines the name of the fragment shader. 
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"


			float3 _LightDirection;

			sampler2D _MainTex;
			float4 _MainTex_ST;
			half4 _Color;


			struct Attributes
			{
				float4 positionOS   : POSITION;
				float3 normalOS     : NORMAL;

				float2 texcoord     : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct Varyings
			{
				float2 uv           : TEXCOORD0;
				float4 positionCS   : SV_POSITION;
			};


			float4 GetShadowPositionHClip(Attributes input)
			{
				float3 positionWS = TransformObjectToWorld(input.positionOS.xyz);
				float3 normalWS = TransformObjectToWorldNormal(input.normalOS);

				float4 positionCS = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _LightDirection));

#if UNITY_REVERSED_Z
				positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#else
				positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
#endif

				return positionCS;
			}
			// #define TRANSFORM_TEX(tex,name) (tex.xy * name##_ST.xy + name##_ST.zw)
			half AlphaLocal(half albedoAlpha, half4 color)
			{

				half alpha = color.a;


				return alpha;
			}

			Varyings vert(Attributes input)
			{
				Varyings output;
				UNITY_SETUP_INSTANCE_ID(input);

				//output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
				output.uv = input.texcoord;
				output.positionCS = GetShadowPositionHClip(input);
				return output;
			}

			half4 frag(Varyings input) : SV_Target
			{

				float2 uv = input.uv.xy;
				half2 dx = ddx(input.uv.xy * _MainTex_ST.x * 0.1f) * _MainTex_ST.w;
				half2 dy = ddy(input.uv.xy * _MainTex_ST.y * 0.1f) * _MainTex_ST.w;

				half diffuseAlpha = 1.0h;
				AlphaLocal(diffuseAlpha, _Color);

				//Alpha(SampleAlbedoAlpha(input.uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap)).a, _Color, _Cutoff);
				return 0;
			}


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
