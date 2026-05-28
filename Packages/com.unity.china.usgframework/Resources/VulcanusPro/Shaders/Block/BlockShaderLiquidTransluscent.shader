Shader "BlockShaderLiquidTransluscent"
{
	Properties
	{
		_Color("Shallow Color",Color) = (0,1,1,1)
		_DepthColor("Depth Color",Color) = (0,0.54,0.77,1)
		_Depth("Depth",float) = 0.5
		_EdgeFade("Edge Fade",float) = 1.4

		//Spec
		_SpecColor("SpecularColor",Color) = (1,1,1,1)
		_Smoothness("Smoothness",Range(0.01,5)) = 0.09

		//Normal Map
		_BumpMap("Micro Detail", 2D) = "bump" {}
		_BumpStrength("Bump Strength",Range(0,1)) = 0.375
		_Speeds("Speeds",vector) = (0.2,0.2,-0.2,-0.2)

		_Distortion("Distortion", Range(0,100)) = 49.0

		_FoamColor("FoamColor",Color) = (1,1,1,1)
		_FoamTex("Foam Texture", 2D) = "white" {}
		_FoamSize("Fade Size",float) = 5.38

		//WaveMode
		_Amplitude("Amplitude", float) = 10.59
		_Frequency("Frequency",float) = 2.0
 		_Speed("Wave Speed", float) = 1

		//GerstnerMode
		_Steepness("Wave Steepness",float) = 1
		_WSpeed("Wave Speed", Vector) = (1.2, 1.375, 1.1, 1.5)
		_WDirectionAB("Wave1 Direction", Vector) = (0.3 ,0.85, 0.85, 0.25)
		_WDirectionCD("Wave2 Direction", Vector) = (0.1 ,0.9, 0.5, 0.5)

		//Normal Smoothing
		_Smoothing("Smoothing",range(0,1)) = 0.665

		_AlphaValue("_AlphaValue",range(0,1)) = 0.665
	}

	SubShader
	{
		// SubShader Tags define when and under which conditions a SubShader block or
		// a pass is executed.
		Tags
		{
			"Queue" = "Transparent+10"
			"IgnoreProjector" = "True"
			"RenderType" = "Transparent"
			"RenderPipeline" = "UniversalPipeline"
			"ShaderUsage" = "Creator"
			"ShaderDesignation" = "Block"
		}

		LOD 100

		ZWrite Off
		Blend SrcAlpha OneMinusSrcAlpha

		GrabPass
		{
			"_GrabTexture"

			Name "BASE"
			Tags
			{
				"LightMode" = "UniversalAlways"
			}
		}

		Pass
		{
			Tags{ "LightMode" = "UniversalForward" }
			Name "FORWARD"

			Cull Off

			// The HLSL code block. Unity SRP uses the HLSL language.
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore

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
			float  _Depth;

			//Spec
			half4 _SpecColor;
			uniform half4 _LightColor0;
			float  _Smoothness;

			sampler2D _GrabTexture;
			half4    _GrabTexture_TexelSize;
			sampler2D _CameraDepthTexture; //Fix for depth precision

			sampler2D _BumpMap;
			half4    _BumpMap_ST;

			float  _EdgeFade;
			float  _BumpStrength;
			float  _Distortion;

			half4 _FoamColor;
			sampler2D _FoamTex;
			half4 _FoamTex_ST;
			float  _FoamSize;

			float _Amplitude;
			float _Frequency;
			float _Speed;

			float  _Steepness;
			half4 _WSpeed;
			half4 _WDirectionAB;
			half4 _WDirectionCD;


			float _Smoothing;
			half4 _Speeds;
			float _AlphaValue;

			CBUFFER_END

			half3 GerstnerNormal(half2 xzVtx, half4 amp, half4 freq, half4 speed, half4 dirAB, half4 dirCD)
			{
				half3 nrml = half3(0, 2.0, 0);

				half4 AB = freq.xxyy * amp.xxyy * dirAB.xyzw;
				half4 CD = freq.zzww * amp.zzww * dirCD.xyzw;

				half4 dotABCD = freq.xyzw * half4(dot(dirAB.xy, xzVtx), dot(dirAB.zw, xzVtx), dot(dirCD.xy, xzVtx), dot(dirCD.zw, xzVtx));
				half4 TIME = _Time.yyyy * speed;

				half4 COS = cos(dotABCD + TIME);

				nrml.x -= dot(COS, half4(AB.xz, CD.xz));
				nrml.z -= dot(COS, half4(AB.yw, CD.yw));

				nrml.xz *= _Smoothing;
				nrml = normalize(nrml);

				return nrml;
			}

			half3 GerstnerOffset(half2 xzVtx, half steepness, half4 amp, half4 freq, half4 speed, half4 dirAB, half4 dirCD)
			{
				half3 offsets;

				half4 AB = steepness * amp.xxyy * dirAB.xyzw;
				half4 CD = steepness * amp.zzww * dirCD.xyzw;

				half4 dotABCD = freq.xyzw * half4(dot(dirAB.xy, xzVtx), dot(dirAB.zw, xzVtx), dot(dirCD.xy, xzVtx), dot(dirCD.zw, xzVtx));
				half4 TIME = _Time.yyyy * speed;

				half4 COS = cos(dotABCD + TIME);
				half4 SIN = sin(dotABCD + TIME);

				offsets.x = dot(COS, half4(AB.xz, CD.xz));
				offsets.z = dot(COS, half4(AB.yw, CD.yw));
				offsets.y = dot(SIN, amp);

				return offsets;
			}

			void Gerstner(out half3 offs, out half3 nrml,
				half3 vtx, half3 tileableVtx,
				half4 amplitude, half4 frequency, half steepness,
				half4 speed, half4 directionAB, half4 directionCD)
			{

				offs = GerstnerOffset(tileableVtx.xz, steepness, amplitude, frequency, speed, directionAB, directionCD);
				nrml = GerstnerNormal(tileableVtx.xz + offs.xz, amplitude, frequency, speed, directionAB, directionCD);
			}

			void displacement(inout appdata v)
			{
				half4 worldSpaceVertex = mul(unity_ObjectToWorld, (v.vertex));
				half3 offsets;
				half3 nrml;

				half3 vtxForAni = (worldSpaceVertex.xyz).xzz; // REMOVE VARIABLE
				Gerstner(
					offsets, nrml, v.vertex.xyz, vtxForAni,				// offsets, nrml will be written
					_Amplitude * 0.01,									// amplitude
					_Frequency,											// frequency
					_Steepness,											// steepness
					_WSpeed,											// speed
					_WDirectionAB,										// direction # 1, 2
					_WDirectionCD										// direction # 3, 4									
				);

				//v.vertex.xyz += offsets;
				v.normal = nrml;
			}

			inline float4 AnimateBump(float2 uv)
			{
				float4 coords;

				coords.xy = TRANSFORM_TEX(uv, _BumpMap);
				coords.zw = TRANSFORM_TEX(uv, _BumpMap) * 0.5;
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

//
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

			half DiffuseTerm(half3 normalDir, half3 lightDir)
			{
				return max(0, dot(normalDir, lightDir));
			}

			half SpecularTerm(half3 lightDir, half3 viewDir, half3 normalDir)
			{
				return dot(reflect(-lightDir, normalDir), viewDir);
			}

			half3 SpecularColor(half gloss, half3 lightDir, half3 viewDir, half3 normalDir)
			{
				float spec = pow(max(0.0, SpecularTerm(lightDir, viewDir, normalDir)), gloss * 128.0);
				return _LightColor0.rgb * spec * _SpecColor.rgb;
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
				float3 worldViewDir = normalize(GetCameraRelativePositionWS(i.worldPos));

				half4 clipPos = TransformWorldToHClip(i.worldPos);
				half4 shadowCoord = ComputeScreenPos(clipPos);
				//float3 lightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
				Light mainLight = GetMainLight(shadowCoord);
				float3 lightDir = mainLight.direction;

				//half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

				// ========================================
				// Textures
				// ========================================
				float2 offset = worldN.xz * _GrabTexture_TexelSize.xy * _Distortion;

				// Depth Distortion ===================================================
				float4 depthUV = OffsetDepth(i.depthUV, offset);
				// GrabPass Distortion ================================================
				float4 grabUV = OffsetUV(i.grabUV, offset);

				// Refraction ============================================================
				// RGB 	= Color
				// A 	= Depth
				// =======================================================================
				half4 refraction = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(grabUV));
				half4 cleanRefraction = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabUV));

#if VULCANUS_COLORSPACE_GAMMA
				refraction = GammaToLinearBeginHLSL(refraction);
				cleanRefraction = GammaToLinearBeginHLSL(cleanRefraction);
#endif

				//Depth Texture Clean
				float sceneZ = texDepth(_CameraDepthTexture, i.depthUV);
				//Depth Texture Distorted
				float distZ = texDepth(_CameraDepthTexture, depthUV);

				//Depth	
				refraction.a = saturate(_Depth / abs(distZ - depthUV.z));
				//Clean Depth
				cleanRefraction.a = saturate(_Depth / abs(sceneZ - i.depthUV.z));

				half3 finalColor = lerp(_Color.rgb * refraction.rgb, _DepthColor.rgb, 1.0 - refraction.a);

				float2 foamUV = i.foamUV;

				//Foam Texture with animation
				float foamTex = tex2D(_FoamTex, foamUV + (finalBump.xy * 0.05)).r;
				//Final Foam 
				float3 foam = 1.0 - saturate(_FoamSize * (sceneZ - depthUV.z));
				foam *= _FoamColor.rgb * foamTex * max(_LightColor0.rgb, i.ambient.rgb);

				finalColor += min(1.0, 2.0 * foam);

				float NdotL = DiffuseTerm(worldN, lightDir);

				//Specular
				half3 specColor = SpecularColor(_Smoothness, lightDir, worldViewDir, worldN);
				//Albedo
				half3 diff = finalColor * max(i.ambient, NdotL * _LightColor0.rgb) + specColor;
				//Alpha
				half alpha = saturate(_EdgeFade * (sceneZ - depthUV.z)) * _Color.a;
#if VULCANUS_COLORSPACE_GAMMA
				//diff = pow(abs(diff), 1.0 / 2.2);
				diff = GammaToLinearEndHLSL(diff);
#endif

				half4 c;

				c.rgb = lerp(cleanRefraction.rgb, diff, alpha);
				c.rgb = MixFog(c.rgb, i.fogCoord);
				c.a = _AlphaValue;

				return c;
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