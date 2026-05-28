Shader "ZAMMYSMITH/SpecialFX/ShadowProjectionSurface_GF"
{
	Properties 
	{
		_Alpha("Alpha", Range(0, 1)) = 0.5

		[Header(ZTest)]
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest (default = Disable)", Float) = 0 //0 = disable

		[Header(ZWrite)]
		[Enum(Off, 0, On, 1)]_ZWrite("ZWrite (default = Disable)", Float) = 0 //0 = disable

		[Header(Cull)]
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull (default = Front)", Float) = 1 //1 = Front
	}
	SubShader
	{
		Tags{ "LightMode" = "UniversalForward" "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off
		Cull[_Cull]
		ZWrite[ZWrite]
		ZTest[_ZTest]

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 2.0

            // #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            // #pragma multi_compile _ LIGHTMAP_ON
            // #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            // #pragma multi_compile _ _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHTS_VERTEX
            // #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Vulcanus_Lighting.hlsl"

			CBUFFER_START(UnityPerMaterial)
				half _Alpha;
			CBUFFER_END

			struct appdata_t 
			{
				float4 positionOS   : POSITION;
				float3 normalOS     : NORMAL;
				float2 texcoord     : TEXCOORD0;
				float2 lightmapUV   : TEXCOORD1;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f 
			{
				float4 positionCS : SV_POSITION;
				float2 uv : TEXCOORD0;

				DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);
				
			#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    			float3 positionWS   : TEXCOORD2;
			#endif

				float3 normalWS     : TEXCOORD3;
			#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    			float4 shadowCoord  : TEXCOORD4;
			#endif
			};

			v2f vert(appdata_t v)
			{
				v2f o = (v2f)0;
				o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
				o.positionWS = TransformObjectToWorld(v.positionOS.xyz);
				o.normalWS = TransformObjectToWorldNormal(v.normalOS);

				OUTPUT_LIGHTMAP_UV(o.lightmapUV, unity_LightmapST, o.lightmapUV);
    			OUTPUT_SH(o.normalWS.xyz, o.vertexSH);
				return o;
			}

			half4 frag(v2f input) : SV_Target
			{
				#if defined(_ULTRA_LOW_SPEC)
    				return half4(0, 0, 0, 0);
				#endif

				#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
					half4 shadowMask = shadowMask = SAMPLE_SHADOWMASK(input.lightmapUV);
				#elif !defined (LIGHTMAP_ON)
					half4 shadowMask = unity_ProbesOcclusion;
				#else
					half4 shadowMask = half4(1, 1, 1, 1);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
					float4 shadowCoord = input.shadowCoord;
				#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
					float4 shadowCoord = TransformWorldToShadowCoord(input.positionWS);
				#else
					float4 shadowCoord = float4(0, 0, 0, 0);
				#endif

				
				half3 diffuseColor = 0;
				float3 specularColor = 0;
				half3 bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, input.normalWS);
				Light mainLight = GetMainLight(shadowCoord, input.positionWS, shadowMask);
				
				MixRealtimeAndBakedGI(mainLight, input.normalWS, bakedGI);
				half attenuation = 1 - (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
				return half4(0, 0, 0, attenuation * _Alpha);
			}
			ENDHLSL
		}
	}
}
