Shader "BlockShaderTransluscent"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}               // Keywords: !! SPECULAR BUMP SPECULAR_BUMP !! availeble for 3 keywords
		_EdgeTex("EdgeMap (RGBA)", 2D) = "white" {}         // Keywords: !! SPECULAR BUMP SPECULAR_BUMP
		//_BumpTex ("BumpMap (RGBA)", 2D) = "white" {}        // Keywords: !! SPECULAR BUMP SPECULAR_BUMP
		_Roughness("Roughness", Range(0,1)) = 0
		_SpecularColor("Specular Color", Color) = (1,1,1,1) // Keywords: !! SPECULAR SPECULAR_BUMP
		_Color("Color", Color) = (1,1,1,1)
		_SpecPower("Specular Power", Range(0.1,128)) = 128  // Keywords: !! SPECULAR SPECULAR_BUMP
	}

	SubShader
	{
		// SubShader Tags define when and under which conditions a SubShader block or
		// a pass is executed.
		Tags 
		{
			"Queue" = "Transparent"
			"RenderType" = "Transparent"
			"RenderPipeline" = "UniversalPipeline"
			"ShaderUsage" = "Creator"
			"ShaderDesignation" = "Block"
		}

		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile_instancing
			#pragma multi_compile_fog

			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
			#pragma multi_compile __ _SHADOWS_SOFT
			#pragma multi_compile_local __ VULCANUS_COLORSPACE_GAMMA _SHADER_USAGE_CREATOR _SHADER_DESIGNATION_BLOCK


			#include "BlockShared.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "../Supported/HLSL/GammaToLinear.hlsl"
			#include "../Supported/HLSL/CalculateUV.hlsl"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 uv : TEXCOORD0;
				float4 uv1 : TEXCOORD1;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
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
				half4 color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			CBUFFER_START(UnityPerMaterial)

			sampler2D _MainTex;
			sampler2D _EdgeTex;

			float4 _MainTex_ST;
			float  _Roughness;
			float  _Fresnel;
			float  _SpecPower;
			half4 _SpecularColor;
			half4 _Color;
			half _Surface;

			CBUFFER_END

			half4 GetMainTexture(half3 uv, half2 dx, half2 dy)
			{
				half4 main_uv = GetMainUV(uv.z);
				half2 find_uv = FindUV(uv, main_uv);

				return tex2D(_MainTex, find_uv + main_uv.xy, dx, dy);
			}

			half3 GetBumpTexture(half3 uv, half2 dx, half2 dy)
			{
				half2 nor_uv = frac(uv.xy) * 0.246f + float2(0.002f, 0.002f);

				half4 packednormal = tex2D(_EdgeTex, nor_uv + GetBumpUV(round(uv.z)), dx, dy);
				return packednormal.xyz * 2 - 1;

//				return UnpackNormal(tex2D(_EdgeTex, nor_uv + GetBumpUV(round(uv.z)), dx, dy));
			}

			v2f vert(appdata v)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

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
				o.color = v.color;

				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);

				float4 color;

				half2 dx = ddx(i.uv.xy * _MainTex_ST.x * 0.1f) * _MainTex_ST.w;
				half2 dy = ddy(i.uv.xy * _MainTex_ST.y * 0.1f) * _MainTex_ST.w;

				half4 c = GetMainTexture(i.uv.xyz, dx, dy);
				half3 e = GetBumpTexture(i.bumpUV, dx, dy);

#if VULCANUS_COLORSPACE_GAMMA
				//c.rgb = pow(abs(c.rgb), 2.2);
				//e.rgb = pow(abs(e.rgb), 2.2);
				c.rgb = GammaToLinearBeginHLSL(c.rgb);
#endif

				color.rgb = c.rgb * saturate(i.color.rgb * 2.0f);
				color.a = c.a;

				if (c.a < 0.2)
				{
					discard;
				}

				Light mainLight = GetMainLight(i.shadowCoord);
				//float3 normalTS = UnpackNormal(tex2D(_EdgeTex, i.uv));
				float3x3 tangentToWorld = float3x3(i.tangent, i.biTangent, i.normal);
				float3 normalWS = normalize(mul(e, tangentToWorld));

				float ndotl = saturate(dot(normalize(_MainLightPosition.xyz), normalWS));
				half3 ambient = SampleSH(i.normal);
				color.rgb *= _MainLightColor.rgb * (ndotl * mainLight.shadowAttenuation + ambient);
#if VULCANUS_COLORSPACE_GAMMA
				//color.rgb = pow(abs(color.rgb), 1.0 / 2.2);
				color.rgb = GammaToLinearEndHLSL(color.rgb);
#endif

				half3 halfVector = normalize(_MainLightPosition.xyz + i.viewDir);
				float ndoth = saturate(dot(normalWS, halfVector));
				float specular = pow(ndoth, _SpecPower) * _Roughness * c.a;
				color.rgb += (specular * _SpecularColor.rgb);

				//fixed stepFactor = step(0.1, s.Alpha);

				clip(color.a - (1.0 / 255));

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
			#pragma exclude_renderers gles gles3 glcore
			#pragma target 4.5

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