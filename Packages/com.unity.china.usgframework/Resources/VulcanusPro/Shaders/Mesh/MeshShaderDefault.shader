Shader "MeshShaderDefault"
{
	Properties
	{
        _Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Texture", 2D) = "white" {}
		_NormalTex("Normalmap", 2D) = "bump" {}
		_Roughness("Roughness", Range(0,1)) = 0
		_SpecularColor("Specular Color", Color) = (1,1,1,1)
		_SpecPower("Specular Power", Range(10,128)) = 128
	}
	SubShader
	{
		Tags { "Queue" = "Geometry" "RenderType" = "Opaque" "ShaderUsage"="Creator" }
        LOD 200
		Cull[_Cull]

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_instancing
			#pragma multi_compile_fog

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile __ _SHADOWS_SOFT
			#pragma multi_compile_local __ VULCANUS_COLORSPACE_GAMMA _SHADER_USAGE_CREATOR


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "../Supported/HLSL/GammaToLinear.hlsl"

			CBUFFER_START(UnityPerMaterial)

			sampler2D _MainTex;
			sampler2D _NormalTex;
			float4 _MainTex_ST;
			half4 _Color;
			half4 _SpecularColor;
			half _SpecPower;
			half _Roughness;

			CBUFFER_END

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float3 posWS : TEXCOORD6;    
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD1;
				float fogCoord : TEXCOORD2;
				float4 shadowCoord : TEXCOORD3;
				float3 tangent : TEXCOORD4;
				float3 biTangent : TEXCOORD5;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			half4 SampleSpecularSmoothness(half alpha, half4 specColor)
			{
				half4 specularSmoothness = half4(0.0h, 0.0h, 0.0h, 1.0h);
				specularSmoothness = specColor;
				specularSmoothness.a = exp2(10 * 0 + 1);
				return specularSmoothness;
			}

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = TransformObjectToWorldNormal(v.normal);
				//o.viewDir = normalize(_WorldSpaceCameraPos.xyz - TransformObjectToWorld(v.vertex.xyz));				
				o.fogCoord = ComputeFogFactor(o.vertex.z);

				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				o.viewDir = GetWorldSpaceViewDir(vertexInput.positionWS);

				o.posWS.xyz = vertexInput.positionWS;
				o.shadowCoord = GetShadowCoord(vertexInput);

				o.tangent = TransformObjectToWorldDir(v.tangent.xyz);
				o.biTangent = cross(o.normal, o.tangent) * v.tangent.w;

				return o;
			}
			
			float3 UnpackDefaultNormal(float4 packednormal)
			{
				return packednormal.xyz * 2 - 1;
			} 

			half4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);

				float4 color;
				
				float4 c = tex2D(_MainTex, i.uv);
				

#if VULCANUS_COLORSPACE_GAMMA
				c = GammaToLinearBeginHLSL(c);
				
#endif

				color.xyz = c.rgb * _Color.rgb;
				color.w = c.a;

				half4 shadowMask = half4(1, 1, 1, 1);

				Light mainLight = GetMainLight(i.shadowCoord, i.posWS, shadowMask);
				float3 normalTS = UnpackDefaultNormal(tex2D(_NormalTex, i.uv)); // UnpackNormal(tex2D(_NormalTex, i.uv));
				
				float3x3 tangentToWorld = float3x3(i.tangent, i.biTangent, i.normal);
				float3 normalWS = normalize(mul(normalTS, tangentToWorld));

				float ndotl = saturate(dot(normalize(mainLight.direction), normalWS));
				half3 ambient = SampleSH(i.normal);
				color.xyz *= _MainLightColor.rgb * (ndotl * mainLight.shadowAttenuation + ambient);

				half4 specularColor = SampleSpecularSmoothness(color.a, _SpecularColor);
				half smoothness = specularColor.a;

				half3 halfVector = normalize(mainLight.direction + i.viewDir);
				float ndoth = saturate(dot(normalWS, halfVector));
				float specular = pow(ndoth, _SpecPower) * _Roughness *c.a ;
				specularColor.rgb = specularColor.rgb  *specular;
#if VULCANUS_COLORSPACE_GAMMA
				//specularColor = GammaToLinearBeginHLSL(specularColor);
				// 0.1 is magic number.
				specularColor.rgb = GammaToLinearBeginHLSL(specularColor.rgb) *0.1;

#endif

				uint pixelLightCount = GetAdditionalLightsCount();				
				for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
				{
					Light light = GetAdditionalLight(lightIndex, i.posWS, shadowMask);
					half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
					color.xyz += LightingLambert(attenuatedLightColor, light.direction, normalWS);
					specularColor.rgb += LightingSpecular(attenuatedLightColor, light.direction, normalWS, i.viewDir, specularColor, smoothness);
				}

				color.xyz += specularColor.rgb;

				clip(color.w - (1.0 / 255));


#if VULCANUS_COLORSPACE_GAMMA
				color = GammaToLinearEndHLSL(color);
				
#endif

				color.xyz = MixFog(color.rgb, i.fogCoord);

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

    Fallback "Diffuse"
}
