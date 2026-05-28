Shader "BlockShaderLiquidOpaque"
{
	Properties
	{
		_DepthColor("Depth Color",Color) = (0,0.54,0.77,1) 
		_Depth("Depth",float) = 0.5

		//Texture
		_Brightness("Brightness",Range(0.5,5.0)) = 1.3
		[MainTexture] _MainMap("Main Texture", 2D) = "white" {} 

		//Normal Map
		_BumpMap("Micro Detail", 2D) = "bump" {}
		_BumpStrength("Bump Strength",Range(0,1)) = 0.375
		_Speeds("Speeds",vector) = (0.2,0.2,-0.2,-0.2)

		_Distortion("Distortion", Range(0, 0.1)) = 0.03

		_FoamColor("FoamColor",Color) = (1,1,1,1)
		_FoamTex("Foam Texture", 2D) = "white" {}
		_FoamSize("Fade Size",float) = 5.38

		//WaveMode
		_Amplitude("Amplitude", float) = 10.59
		_Frequency("Frequency",float) = 2.0
		_Speed("Wave Speed", float) = 1

		//Normal Smoothing
		_Smoothing("Smoothing",range(0,1)) = 0.665
	}

	SubShader
	{
		// SubShader Tags define when and under which conditions a SubShader block or
		// a pass is executed.
		Tags
		{
			"Queue" = "Transparent-1"
			"IgnoreProjector" = "True"
			"RenderType" = "Opaque"
			"RenderPipeline" = "UniversalPipeline"
			"UniversalMaterialType" = "SimpleLit"
			"ShaderUsage" = "Creator"
			"ShaderDesignation" = "Block"
		}

		LOD 100

		Pass
		{
			Tags{ "LightMode" = "UniversalForward" }

			// Use same blending / depth states as Standard shader
			Cull Off

			// The HLSL code block. Unity SRP uses the HLSL language.
			HLSLPROGRAM
			//#pragma exclude_renderers gles gles3 glcore

			// -------------------------------------
			// Material Keywords
			#pragma shader_feature_local_fragment _ALPHATEST_ON
			#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
			//#pragma shader_feature_local_fragment _ _SPECGLOSSMAP _SPECULAR_COLOR
			//#pragma shader_feature_local _ _SPECULAR_COLOR
			//#pragma shader_feature_local_fragment _GLOSSINESS_FROM_BASE_ALPHA
			//#pragma shader_feature_local _NORMALMAP
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
			//#pragma multi_compile_instancing
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
			//#include "HLSLSupport.cginc"
			#include "BlockShared.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "../Supported/HLSL/GammaToLinear.hlsl"
			#include "../Supported/HLSL/CalculateUV.hlsl"

			struct appdata
			{
				float4 vertex	: POSITION;
				float3 normal 	: NORMAL;
				float4 tangent 	: TANGENT;
				float2 texcoord : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex	: SV_POSITION;
				half3 ambient	: COLOR;

				half4 tspace0	: TEXCOORD0; // tangent.x, bitangent.x, normal.x
				half4 tspace1	: TEXCOORD1; // tangent.y, bitangent.y, normal.y
				half4 tspace2	: TEXCOORD2; // tangent.z, bitangent.z, normal.z

				float3 worldPos : TEXCOORD3;
				float4 grabUV 	: TEXCOORD4;
				float4 depthUV	: TEXCOORD5;
				float4 animUV	: TEXCOORD6;

				float fogCoord	: TEXCOORD7;
				float2 foamUV	: TEXCOORD8;

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			
			half4 _Color;
			half4 _DepthColor;
			half  _Depth;
			half  _Brightness;
			uniform half4 _LightColor0;

			sampler2D _MainMap;
			half4 _MainMap_ST;
			sampler2D _CameraDepthTexture; //Fix for depth precision

			sampler2D _BumpMap;
			half4    _BumpMap_ST;

			half  _BumpStrength;
			half  _Distortion;

			half4 _FoamColor;
			sampler2D _FoamTex;
			half4 _FoamTex_ST;
			half  _FoamSize;

			half _Amplitude;
			half _Frequency;
			half _Speed;

			half _Smoothing;
			half4 _Speeds;

			CBUFFER_END

			void Wave(out half3 offs, out half3 nrml, half3 vtx, half4 tileableVtx, half amplitude, half frequency, half s)
			{
				float4 v0 = tileableVtx;
				float4 v1 = v0 + float4(0.05, 0, 0, 0);
				float4 v2 = v0 + float4(0, 0, 0.05, 0);

				float speed = s * _Time.y;
				amplitude *= 0.01;

				v0.y += sin(speed + (v0.x * frequency)) * amplitude;
				v1.y += sin(speed + (v1.x * frequency)) * amplitude;
				v2.y += sin(speed + (v2.x * frequency)) * amplitude;

				v0.y -= cos(speed + (v0.z * frequency)) * amplitude;
				v1.y -= cos(speed + (v1.z * frequency)) * amplitude;
				v2.y -= cos(speed + (v2.z * frequency)) * amplitude;

				v1.y -= (v1.y - v0.y) * (1 - _Smoothing);
				v2.y -= (v2.y - v0.y) * (1 - _Smoothing);

				float3 vna = cross((v2 - v0).xyz, (v1 - v0).xyz);

				float4 vn = mul(float4x4(unity_WorldToObject), float4(vna, 0));
				nrml = normalize(vn).xyz;
				offs = mul(float4x4(unity_WorldToObject), v0).xyz;
			}

			void displacement(inout appdata v)
			{
				half4 worldSpaceVertex = mul(unity_ObjectToWorld, (v.vertex));
				half3 offsets;
				half3 nrml;

				Wave(
					offsets, nrml, v.vertex.xyz, worldSpaceVertex,
					_Amplitude,
					_Frequency,
					_Speed
				);

				v.normal = nrml;
			}

			inline float4 AnimateBump(float2 uv)
			{
				float4 coords;

				coords.xy = TRANSFORM_TEX(uv, _BumpMap);
				coords.zw = TRANSFORM_TEX(uv, _BumpMap) * 0.5f;
				coords += frac(_Speeds * _Time.x);

				return coords;
			}

			inline float texDepth(sampler2D _Depth, float4 uv)
			{
				//return LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_Depth, UNITY_PROJ_COORD(uv)));
				float z = SAMPLE_DEPTH_TEXTURE_PROJ(_Depth, UNITY_PROJ_COORD(uv));
				return 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);
			}

			half3 UnpackNormalBlend(half4 n1, half4 n2, half scale)
			{

				
				half3 normal = normalize((n1.xyz * 2 - 1) + (n2.xyz * 2 - 1));
#if (SHADER_TARGET >= 30)
				normal.xy *= scale;
#endif
				return normal;

//#if defined(UNITY_NO_DXT5nm)
//				half3 normal = normalize((n1.xyz * 2 - 1) + (n2.xyz * 2 - 1));
//#if (SHADER_TARGET >= 30)
//				normal.xy *= scale;
//#endif
//				return normal;
//#else
//				half3 normal;
//				normal.xy = (n1.wy * 2 - 1) + (n2.wy * 2 - 1);
//#if (SHADER_TARGET >= 30)
//				normal.xy *= scale;
//#endif
//				normal.z = sqrt(1.0 - saturate(dot(normal.xy, normal.xy)));
//				return normalize(normal);
//#endif
			}

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				displacement(v);
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.grabUV = ComputeGrabScreenPos(o.vertex);
				o.depthUV = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.depthUV.z);

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				half3 worldNormal = TransformObjectToWorldNormal(v.normal);
				half3 worldTangent = TransformObjectToWorldNormal(v.tangent.xyz);
				half3 worldBinormal = cross(worldTangent, worldNormal);

				o.tspace0 = half4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.tspace1 = half4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.tspace2 = half4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);
				o.worldPos = worldPos.xyz;

				real4 SHCoefficients[7];
				SHCoefficients[0] = unity_SHAr;
				SHCoefficients[1] = unity_SHAg;
				SHCoefficients[2] = unity_SHAb;
				SHCoefficients[3] = unity_SHBr;
				SHCoefficients[4] = unity_SHBg;
				SHCoefficients[5] = unity_SHBb;
				SHCoefficients[6] = unity_SHC;

				o.ambient = SampleSH9(SHCoefficients, worldNormal);
				o.animUV = AnimateBump(v.texcoord);
				o.foamUV = TRANSFORM_TEX(v.texcoord, _FoamTex);

				o.fogCoord = ComputeFogFactor(o.vertex.z);
				//UNITY_TRANSFER_FOG(o, o.vertex);

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

				half4 n1 = tex2D(_BumpMap, i.animUV.xy);
				half4 n2 = tex2D(_BumpMap, i.animUV.zw);


				half3 finalBump = UnpackNormalBlend(n1, n2, _BumpStrength);
				half3 worldN = WorldNormal(i.tspace0.xyz, i.tspace1.xyz, i.tspace2.xyz, finalBump);

				float2 offset = worldN.xz * _Distortion * _MainMap_ST.xy;

				float4 depthUV = OffsetDepth(i.depthUV, offset);
				float4 grabUV = OffsetUV(i.grabUV, offset);

				half4 refraction = tex2D(_MainMap, i.animUV.xy + offset);
				float sceneZ = texDepth(_CameraDepthTexture, i.depthUV);
				float distZ = texDepth(_CameraDepthTexture, depthUV);
#if VULCANUS_COLORSPACE_GAMMA
				refraction = GammaToLinearBeginHLSL(refraction);			
#endif

				refraction.a = saturate(_Depth / abs(sceneZ - depthUV.z));
				half3 finalColor = lerp(_DepthColor.rgb, refraction.rgb, 1.0 - refraction.a);

				float2 foamUV = i.foamUV;
				half foamTex = tex2D(_FoamTex, foamUV + (finalBump.xy * 0.05)).r;
				half3 foam = 1.0 - saturate(_FoamSize * (sceneZ - depthUV.z));
				foam *= _FoamColor.rgb * foamTex * max(_LightColor0.rgb, i.ambient.rgb);
				finalColor += min(1.0, 2.0 * foam);
#if VULCANUS_COLORSPACE_GAMMA
				//finalColor.rgb = pow(abs(finalColor.rgb), 1.0 / 2.2);
				finalColor.rgb = GammaToLinearEndHLSL(finalColor.rgb);
#endif

				half4 c;
				c.rgb = finalColor.rgb * _Brightness;
				//UNITY_APPLY_FOG(i.fogCoord, c);
				c.rgb = MixFog(c.rgb, i.fogCoord);
				c.a = 1;

				return c;
				//return half4(1, 1, 1, 1);
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
}