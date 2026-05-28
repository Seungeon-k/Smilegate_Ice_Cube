//
Shader "MeshShaderCharacter"
{
	Properties {
		_MainTex			("Albedo", 2D)					= "white" {}
		//_TorchColor			("TorchColor", Color)			= (1,1,1,1)
		//_World_EnvLight_ForTorch ("World_EnvLight_ForTorch", Float ) = 0
		_TorchLightColor("TorchLightColor", Color) = (1, 1, 1, 0.0)
		_TorchLightLevel("TorchLightLevel", Range(0, 1.0)) = 1
		_RimColor_OutSide("Rim Color OutSide", Color) = (1, 1, 1, 0.0)
		_RimPower("Rim Power", Range(0.5, 8.0)) = 3.5
		_RimColorPower("Rim Color Power", Range(1.0, 5.0)) = 1.0
		_RimLightMode("Rim Light Mode", Float) = 0 // 0 : None, 1: Rim
		_SunLightValue("SunLightValue", Float) = 0
		_EnvLight("EnvLight",Float) = 0

		[Header(Sub RimLight)]
		_Sub_RimColor_OutSide("Sub_Rim Color", Color) = (1, 1, 1, 0.0)
		_Sub_RimPower("Sub_Rim Power", Range(0.5, 8.0)) = 3.5
		_Sub_RimColorPower("Sub_Rim Color Power", Range(1.0, 5.0)) = 1.0
		_Sub_RimLightMode("Sub_Rim Light Mode", Range(0,1)) = 0 // 0 : None, 1: Rim
		//
	}

	SubShader {
		Tags { "Queue" = "Geometry+100" "RenderType" = "Opaque+100" "ShaderUsage"="Creator"}

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#pragma multi_compile _FOG_ON __
			#pragma multi_compile _SHADOW_OFF _SHADOW_ON
#ifdef _SHADOW_ON
			#pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
#endif
			#pragma multi_compile_fog

			#pragma multi_compile_local __ VULCANUS_COLORSPACE_GAMMA _SHADER_USAGE_CREATOR


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "../Supported/HLSL/GammaToLinear.hlsl"

			CBUFFER_START(UnityPerMaterial)

			sampler2D	_MainTex;
			float4 _MainTex_ST;

			float _SunLightValue;
			float _TorchLightLevel;
			float _EmissiveLevel;
			float _EnvLight;
			half4 _TorchLightColor;
			float _MinEnvAtten;
			float _SunLightMin;
			half4 _RimColor_OutSide, _Sub_RimColor_OutSide;
			float _RimColorPower, _Sub_RimColorPower;
			half _RimPower, _Sub_RimPower;
			half _RimLightMode, _Sub_RimLightMode;

			CBUFFER_END

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float fogCoord : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 viewDir : TEXCOORD2;
				float4 shadowCoord : TEXCOORD3;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
#if _FOG_ON
				o.fogCoord = ComputeFogFactor(o.vertex.z);
#else
				o.fogCoord = 0; 
#endif
				o.normal = TransformObjectToWorldNormal(v.normal);
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - TransformObjectToWorld(v.vertex.xyz));
#ifdef _SHADOW_ON
				VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
				o.shadowCoord = GetShadowCoord(vertexInput);
#else
				o.shadowCoord = float4(0, 0, 0, 0); 
#endif
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half4 color;

				half4 c = tex2D(_MainTex, i.uv);
#if VULCANUS_COLORSPACE_GAMMA
				//half3 diffuseAlphaRGB = abs(c.rgb);
				//c = half4(pow(diffuseAlphaRGB, 2.2), c.a);
				c = GammaToLinearBeginHLSL(c);
#endif


				color.w = c.a;

				clip(color.w - (1.0 / 255));

				float Sunpower = clamp(_EnvLight, _MinEnvAtten, 1.0) * max(_SunLightMin, _SunLightValue);
				half3 col_1 = _TorchLightColor.rgb * _TorchLightLevel;
				half3 col_2 = Sunpower;
				half3 col_biome = max(col_1, col_2);

				color.xyz = c.rgb * col_biome;

#ifdef _SHADOW_ON
				Light mainLight = GetMainLight(i.shadowCoord);
				float ndotl = saturate(dot(_MainLightPosition.xyz, i.normal));
				half3 ambient = SampleSH(i.normal);
				color.xyz *= _MainLightColor.rgb * (ndotl * mainLight.shadowAttenuation * mainLight.distanceAttenuation + ambient);
#endif
				float3 emission = c.rgb * UNITY_LIGHTMODEL_AMBIENT.rgb * col_biome;
				emission += c.rgb * 0.2f;
				
				// Rim Light
				float rim = 0;
				half3 rimResult = 0;
				if (_RimLightMode == 1)
				{
					rim = 1.0 - saturate(dot(i.viewDir, i.normal));
					rimResult = _RimColor_OutSide.rgb * _RimColorPower * pow(rim, _RimPower);
				}
				//Sub rim light
				if (_Sub_RimLightMode == 1)
				{
					rim = 1.0 - saturate(dot(i.viewDir, i.normal));
					rimResult = _Sub_RimColor_OutSide.rgb * _Sub_RimColorPower * pow(rim, _Sub_RimPower);
				}
				emission += rimResult;

#if VULCANUS_COLORSPACE_GAMMA
				//half gammaInv = 1 / 2.2;
				//color = pow(abs(color), half4(gammaInv, gammaInv, gammaInv, 1));
				color = GammaToLinearEndHLSL(color);
#endif

				color.xyz += emission;
#if _FOG_ON
				color.xyz = MixFog(color, i.fogCoord);
#endif
				return color;
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

	Fallback "Mobile/VertexLit"
}
