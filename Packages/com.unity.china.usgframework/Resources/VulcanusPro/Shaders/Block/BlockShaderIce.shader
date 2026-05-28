Shader "BlockShaderIce"
{
	Properties
	{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_BumpTex("BumpMap (RGBA)", 2D) = "white" {}
		_GrabTexture_G("GrabTexture", 2D) = "white" {}
		_RefScale("Scale", float) = 0.2
		_LerpScale("LerpScale", Range(0,1)) = 0.5
	}

	SubShader
	{
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
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_instancing
			#pragma multi_compile_fog

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile __ _SHADOWS_SOFT

			#pragma multi_compile_local __ SPECULAR
			#pragma multi_compile_local __ VULCANUS_COLORSPACE_GAMMA _SHADER_USAGE_CREATOR _SHADER_DESIGNATION_BLOCK

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
				float4 uv : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				half4 color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float4 uv	: TEXCOORD0;
				float3 viewDir : TEXCOORD1;
				float fogCoord : TEXCOORD2;
				float4 shadowCoord : TEXCOORD3;
				float3 tangent : TEXCOORD4;
				float3 biTangent : TEXCOORD5;
				float3 bumpUV : TEXCOORD6;
				float4 grabUV : TEXCOORD7;
				half4 color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)

			sampler2D _MainTex;
			sampler2D _BumpTex;
			sampler2D _GrabTexture_G;

			float4 _MainTex_ST;
			half4 _Color;
			float _RefScale;
			float _Roughness;
			float _SpecPower;
			float _LerpScale;
			half4 _SpecularColor;

			CBUFFER_END

			inline float texDepth(sampler2D _Depth, float4 uv)
			{
				//return LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_Depth, UNITY_PROJ_COORD(uv)));
				float z = SAMPLE_DEPTH_TEXTURE_PROJ(_Depth, UNITY_PROJ_COORD(uv));
				return 1.0 / (_ZBufferParams.z * z + _ZBufferParams.w);
			}

			float3 GetBumpTexture(float3 uv, float2 dx, float2 dy)
			{
				float2 nor_uv = frac(uv.xy) * 0.246f + float2(0.002f, 0.002f);

				return UnpackNormal(tex2D(_BumpTex, nor_uv + GetBumpUV(round(uv.z)), dx, dy));
			}

//			half3 UnpackNormalBlend(half4 n1, half4 n2, half scale)
//			{
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
//			}

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				//o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv = v.uv;
				o.normal = TransformObjectToWorldNormal(v.normal);
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - TransformObjectToWorld(v.vertex.xyz));

				o.fogCoord = ComputeFogFactor(o.vertex.z);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				o.shadowCoord = GetShadowCoord(vertexInput);

				o.tangent = TransformObjectToWorldDir(v.tangent.xyz);
				o.biTangent = cross(o.normal, o.tangent) * v.tangent.w;
				o.bumpUV = v.uv1.xyz;
				o.grabUV = ComputeGrabScreenPos(o.vertex);
				o.color = v.color;

				return o;
			}

			float3 UnpackDefaultNormal(float4 packednormal)
			{
				return packednormal.xyz * 2 - 1;
			}

			half4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);

				half3 normal = UnpackDefaultNormal(tex2D(_BumpTex, i.bumpUV.xy));
				half3 r = tex2Dproj(_GrabTexture_G, UNITY_PROJ_COORD(OffsetUV(i.grabUV, normal.xy * _RefScale))).rgb;
				half3 c = tex2D(_MainTex, i.uv.xy).rgb;
#if VULCANUS_COLORSPACE_GAMMA
				r = GammaToLinearBeginHLSL(r);
				c = GammaToLinearBeginHLSL(c);
				//r = pow(abs(r), 2.2);
				//c = pow(abs(c), 2.2);
#endif
				half4 color;
				color.rgb = lerp(r, c, _LerpScale) * _Color.rgb;// *saturate(IN.color.rgb);

				Light mainLight = GetMainLight(i.shadowCoord);
				float3x3 tangentToWorld = float3x3(i.tangent, i.biTangent, i.normal);
				float3 normalWS = normalize(mul(normal, tangentToWorld));

				float ndotl = saturate(dot(normalize(_MainLightPosition.xyz), normalWS));
				half3 ambient = SampleSH(i.normal);

				color.rgb *= _MainLightColor.rgb * (ndotl * mainLight.shadowAttenuation + ambient);
				//c.rgb *= s.Albedo * (atten * 2);
				color.a   = 1;

#if VULCANUS_COLORSPACE_GAMMA
				color.rgb = GammaToLinearEndHLSL(color.rgb);
				//color.rgb = pow(abs(color.rgb), 1.0 / 2.2);
#endif
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