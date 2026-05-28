Shader "ZAMMYSMITH/SpecialFX/LavaFlow"
{
	Properties
	{
		[HideInInspector][KeywordEnum(Opaque, Transaprent)] _Surface("Surface Type",Float) = 0
        [HideInInspector][Toggle(_ReceiveSilhouette)] _ReceiveSilhouette("Receive Silhouette", Float) = 1.0


		_MainTex ("Main Texture", 2D) = "white" {}
		//_Noise ("Nose Texture", 2D) = "white" {}
		[HDR] _Color("Color", Color) = (0,0,0)

		[Header(Lava Coef)]
		_Speed("└─Speed", Range(0.0, 100)) = 0
		//_DisplacementPower ("└─Displacement Power", Float)  = 1.5
		//_AdditionalHeight ("└─Additional Height", Float)  = 0
		//_BloomRange("└─BloomRange", Range(0.0, 1)) = 0
		_IntersectionThresholdMax("└─Intersection Threshold Max", Range(0.001, 1)) = 1
		_NoisePower("└─Noise Power", Vector) = (0, 0, 0, 0)

		[Header(Clip Masking)]
        [NoScaleOffset] _DitherMask("└─Clip Mask", 2D) = "white" {}

		[Header(Dissolve)]
		[HDR] _DissolveColorThickness("└Dissolve Color Thickness", Color) = (0, 5, 5, 0.2)
		_Dissolve("└─Dissolve", Range(0.0, 1.0)) = 0

		[Header(Render State)]
		[Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("└─ZTest (default = Disable)", Float) = 0 //0 = disable
		[Enum(Off, 0, On, 1)]_ZWrite("└─ZWrite (default = On)", Float) = 1 //0 = On
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("└─Cull (default = Front)", Float) = 1 //1 = Front 

		[Header(Stencil State)]
		_StencilRef("└─StencilRef", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("└─StencilComp (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.StencilOp)]_PassOperation("└─PassOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_FailOperation("└─FailOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_ZFailOperation("└─ZFailOperation (default = Keep)", Float) = 0 //0 = keep
	}

	SubShader
	{
		Tags {"Queue" = "Geometry+501" "RenderType" = "Opaque" }
		//Blend SrcAlpha OneMinusSrcAlpha
		Blend One Zero
		ZTest[_ZTest]
		ZWrite[_ZWrite]
		Cull[_Cull]
		Stencil
		{
			Ref[_StencilRef]
			Comp[_StencilComp]
			Pass [_PassOperation]
			Fail [_FailOperation]
			ZFail [_ZFailOperation]
		}
		
		Pass
		{
			HLSLPROGRAM

			#pragma multi_compile_fog
			#pragma skip_variants FOG_EXP FOG_EXP2
			#pragma multi_compile _ _ULTRA_LOW_SPEC
			//#pragma multi_compile_vertex _ LOD_FADE_CROSSFADE 

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
			#include "Packages/com.v.gameframework.resources/Runtime/Essential/Vulcanus Resource/RawResource/Shader/GF/Vulcanus_Common.hlsl" 

			TEXTURE2D(_MainTex);         SAMPLER(sampler_MainTex);
			TEXTURE2D(_DitherMask);         SAMPLER(sampler_DitherMask);

			CBUFFER_START(UnityPerMaterial)
				float4 _Color;
				half4 _MainTex_ST;
				half4 _DitherMask_ST;
				half4 _DissolveColorThickness;
				half4 _NoisePower;
				//half _DisplacementPower;
				//half _AdditionalHeight;
				half _Speed;
				//half _BloomRange;
				half _Dissolve;
				half _IntersectionThresholdMax;
			CBUFFER_END

			struct appdata
			{
				float4 positionOS 	: POSITION;
				float3 normalOS 	: NORMAL0;
				float4 uv 		: TEXCOORD0;
			};

			struct v2f
			{
				float4 positionCS 	: SV_POSITION;
				float4 uv 		: TEXCOORD0;
				float4 screenPos	: TEXCOORD1;
				VULCANUS_FOG_COORDS(2)
				half dissolve		: TEXCOORD3;
			};

			v2f vert(appdata v) 
			{
				v2f o;
				// half displ = tex2Dlod(_MainTex, half4(frac(v.mainUV.xy + _Time.x*0.5), 0, 0)).r;
				// displ = displ + _AdditionalHeight;
				// displ *= step(0.001, v.positionOS.y);

				half3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
				//positionWS += half3(0, 1, 0 ) * displ * _DisplacementPower;

                o.positionCS = TransformWorldToHClip(positionWS);
				o.screenPos = ComputeScreenPos(o.positionCS);
				o.uv = v.uv;
				o.dissolve = VSDissolve(_DissolveColorThickness, v.positionOS.xyz, v.normalOS, _Dissolve);
				o.vulcanusFogCoord = VSFogDither(positionWS);
				return o;
			}

			void Unity_Remap_float4(float4 In, float2 InMinMax, float2 OutMinMax, out float4 Out)
			{
				Out = OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
			}

			half4 frag(v2f i) : SV_Target
			{
				PSFogDither(i.positionCS, i.vulcanusFogCoord.x);

#if !defined(_ULTRA_LOW_SPEC)
				//Dissolving
				half3 emission = PSDissolve(TEXTURE2D_ARGS(_DitherMask, sampler_DitherMask), i.uv.xy, _DissolveColorThickness, i.dissolve);
				
				float noise = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.xy).r;
				float4 remapResult = 0;
				Unity_Remap_float4(half4(noise.xxx, 1), half2(-1, 1), _NoisePower.xy, remapResult);
				remapResult.a = 1;
				
				float2 mainUV_ST = i.uv.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float speed = _Time.y * _Speed;
				remapResult += speed;
				
				half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, mainUV_ST.xy + remapResult.xy) * _Color;

				float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
				float rawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV).r;
				half linearDepth = LinearEyeDepth(rawDepth, _ZBufferParams);
				half diff = saturate(_IntersectionThresholdMax * (linearDepth - i.screenPos.w));
				color = lerp(color * 0.5, color, diff);

				color.rgb += emission.rgb;
#else
				half4 color =  SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv.xy) * _Color;
#endif
				
				color.rgb = PSFogColor(color.rgb, i.vulcanusFogCoord.y);
				color.a = 1;
				return color;
			}
			ENDHLSL
		}
	}
}



// float2 unity_gradientNoise_dir(float2 p)
// {
// 	p = p % 289;
// 	float x = (34 * p.x + 1) * p.x % 289 + p.y;
// 	x = (34 * x + 1) * x % 289;
// 	x = frac(x / 41) * 2 - 1;
// 	return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
// }

// float unity_gradientNoise(float2 p)
// {
// 	float2 ip = floor(p);
// 	float2 fp = frac(p);
// 	float d00 = dot(unity_gradientNoise_dir(ip), fp);
// 	float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
// 	float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
// 	float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
// 	fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
// 	return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
// }

// void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
// {
// 	Out = unity_gradientNoise(UV * Scale) + 0.5;
// }

