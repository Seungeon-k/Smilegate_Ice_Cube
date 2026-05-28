#ifndef VULCANUS_COMMON
	#define VULCANUS_COMMON

	#define VULCANUS_FOG_COORDS(IDX) half2 vulcanusFogCoord : TEXCOORD##IDX;

	static const half ShadowSDFThreasholdA = 0.5 - 0.25;
	static const half ShadowSDFThreasholdB = 0.5 + 0.25;

	static const half DitherNearPlane = 280;
	static const half DitherFarPlane = 300;
	static const half InvDitherRange = 1 / (DitherFarPlane - DitherNearPlane);

	static half ShadeDark = 1.2;
	static half ShadeBright = 1.81;
	static half Saturation = 1.12;
	static half Contrast = 1;

	static const uint DitherCellWidth = 4;
	static const uint DitherCellHalfWidth = (DitherCellWidth * 0.5);
	static const half DITHER_THRESHOLDS[] =
	{
		//9x9
		//v3,v3,v3,v2,v2,v2,v3,v3,v3,
		//v3,v3,v3,v2,v1,v2,v3,v3,v3,
		//v3,v3,v2,v2,v1,v2,v2,v3,v3,
		//v2,v2,v2,v1,v1,v1,v2,v2,v2,
		//v2,v1,v1,v1,v1,v1,v1,v1,v2,
		//v2,v2,v2,v1,v1,v1,v2,v2,v2,
		//v3,v3,v2,v2,v1,v2,v2,v3,v3,
		//v3,v3,v3,v2,v1,v2,v3,v3,v3,
		//v3,v3,v3,v2,v2,v2,v3,v3,v3,

		//9x9
		// v4,v4,v4,v4,v4,v4,v4,v4,v4,
		// v4,v4,v4,v3,v3,v3,v4,v4,v4,
		// v4,v4,v3,v2,v2,v2,v3,v4,v4,
		// v4,v3,v2,v2,v1,v2,v2,v3,v4,
		// v4,v3,v2,v1,v1,v1,v2,v3,v4,
		// v4,v3,v2,v2,v1,v2,v2,v3,v4,
		// v4,v4,v3,v2,v2,v2,v3,v4,v4,
		// v4,v4,v4,v3,v3,v3,v4,v4,v4,
		// v4,v4,v4,v4,v4,v4,v4,v4,v4,

		//8x8
		// v4,v4,v4,v4,v4,v4,v4,v4, 
		// v4,v4,v3,v3,v3,v3,v4,v4, 
		// v4,v3,v3,v2,v2,v3,v3,v4, 
		// v4,v3,v2,v1,v1,v2,v3,v4, 
		// v4,v3,v2,v1,v1,v2,v3,v4, 
		// v4,v3,v3,v2,v2,v3,v3,v4, 
		// v4,v4,v3,v3,v3,v3,v4,v4, 
		// v4,v4,v4,v4,v4,v4,v4,v4, 

		//7x7
		// v4,v4,v4,v3,v4,v4,v4, 
		// v4,v4,v3,v2,v3,v4,v4, 
		// v4,v3,v2,v1,v2,v3,v4, 
		// v2,v1,v1,v1,v1,v1,v2, 
		// v4,v3,v2,v1,v2,v3,v4, 
		// v4,v4,v3,v2,v3,v4,v4, 
		// v4,v4,v4,v3,v4,v4,v4, 
		
		//7x7
		// v4,v4,v4,v1,v4,v4,v4, 
		// v4,v4,v2,v1,v2,v4,v4, 
		// v4,v3,v2,v1,v2,v3,v4, 
		// v3,v3,v1,v1,v1,v3,v3, 
		// v4,v3,v2,v1,v2,v3,v4, 
		// v4,v4,v2,v1,v2,v4,v4, 
		// v4,v4,v4,v1,v4,v4,v4, 

		/*
			1.0 / 17.0,		9.0 / 17.0,		3.0 / 17.0,		11.0 / 17.0,
			13.0 / 17.0,	5.0 / 17.0,		15.0 / 17.0,	7.0 / 17.0,
			4.0 / 17.0,		12.0 / 17.0,	2.0 / 17.0,		10.0 / 17.0,
			16.0 / 17.0,	8.0 / 17.0,		14.0 / 17.0,	6.0 / 17.0
		*/
		0.058823529411765, 0.502941176470588, 0.17647058823529, 0.64705882352941, 
		0.76470588235294, 0.29411764705882, 0.88235294117647, 0.41176470588235, 
		0.23529411764706, 0.70588235294118, 0.11764705882353, 0.508823529411765, 
		0.504117647058824, 0.47058823529412, 0.82352941176471, 0.35294117647059,
	};

	inline void Unity_Dither_positionCS(half In, float2 positionCS, out half Out)
	{
		float2 uv = positionCS;
		int offset = (uint)(uv.y / DitherCellWidth) % 2;
		uv.x += offset * DitherCellHalfWidth;
		uint index = (uint(uv.y) % DitherCellWidth) * DitherCellWidth + uint(uv.x) % DitherCellWidth;

		half ditherThreashold = DITHER_THRESHOLDS[index];
		Out = In - ditherThreashold;
	}

	inline void Unity_Dither_float(float In, float4 ScreenPosition, out float Out)
	{
		float2 uv = ScreenPosition.xy * _ScreenParams.xy;
		uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
		Out = In - DITHER_THRESHOLDS[index];
	}

//====================================================================================================
	inline half2 VSFogDither(half3 positionWS)
	{
		half ditherAlpha = 1;	
		half fogFactor = 0;
		#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
			half magnitude = length(positionWS - _WorldSpaceCameraPos);
			ditherAlpha = 1 - saturate((magnitude - DitherNearPlane) * InvDitherRange);
			fogFactor = saturate(magnitude * unity_FogParams.z + unity_FogParams.w);
		#endif
				
		#ifdef LOD_FADE_CROSSFADE
			ditherAlpha = min(saturate(unity_LODFade.r * 6), ditherAlpha);
		#endif
		
		return half2(ditherAlpha, fogFactor);
	}

	inline void PSFogDither(half4 positionCS, half fogDitherAlpha, half ditherAlpha)
	{
		#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
			ditherAlpha = min(fogDitherAlpha, ditherAlpha);
		#endif
		
		half fogClip;
		Unity_Dither_positionCS(ditherAlpha, positionCS.xy, fogClip);
		clip(fogClip - 0.000001);
	}

	inline void PSFogDither(half4 positionCS, half ditherAlpha)
	{
		#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
			half fogClip;
			Unity_Dither_positionCS(ditherAlpha, positionCS.xy, fogClip);
			clip(fogClip - 0.000001);
		#endif
	}

	inline half3 PSFogColor(half3 color, half fogFactor)
	{
		#if defined(FOG_LINEAR) || defined(FOG_EXP) || defined(FOG_EXP2)
			return lerp(unity_FogColor.rgb, color.rgb, fogFactor);
		#else
			return color;
		#endif
	}

	inline half VSDissolve(half4 dissolveColorThickness, half3 positionOS, half3 normalOS, half dissolveRatio)
	{
		return dissolveRatio;

		//#if !defined(_ULTRA_LOW_SPEC)
			// half dissolveThickness = dissolveColorThickness.a * 0.5;
			// float3 dissolveNormal = TransformObjectToWorldNormal(normalize(positionOS) + normalOS);
			// half temp = dot(half3(0, 1, 0), dissolveNormal);
			// temp = (temp + 1) * 0.5;
			// return dissolveRatio + lerp(-dissolveThickness, dissolveThickness, dissolveRatio) - temp;
		//#endif
	}
	
	inline half3 PSDissolve(TEXTURE2D_PARAM(tex, smp), half2 uv, half4 dissolveColorThickness, half dissolveRatio)
	{
		#if defined(_ULTRA_LOW_SPEC)
			return 0;
		#else
			half dissolveActive = 1 - step(dissolveRatio, 0);
			float noise = SAMPLE_TEXTURE2D(tex, smp, uv).g;
			half dissolveThickness = dissolveColorThickness.a * 0.5;
			
			//Apply Extra value for Visual Safty.
			clip(noise - lerp(-0.000001, 1.000001, dissolveRatio));
			half edgeFactor = smoothstep(noise - dissolveThickness, noise + dissolveThickness, dissolveRatio);
			edgeFactor = step(0.000001, edgeFactor);
			half3 emission = dissolveColorThickness.rgb * edgeFactor;
			return emission * dissolveActive;
			
			// half dissolveEdgeWidth = 20;
			// dissolveRatio = smoothstep(-dissolveThickness, dissolveThickness, dissolveRatio) * dissolveActive;
			// clip(noise - dissolveRatio - 0.000001);
			// half edgeFactor = step(noise, (dissolveEdgeWidth * dissolveRatio) + dissolveRatio);
			// half3 emission = dissolveColorThickness.rgb * edgeFactor;
			// return emission * dissolveActive;
		#endif
	}
//====================================================================================================
	inline half3 AdjustLowSpecColor(half3 viewDirectionWS, half3 normalWS, half3 bdrfFersnelRatio, half3 color)
	{
        //Shade
        half NdotL = saturate(dot(normalWS.xyz, half3(0, 1, 0)));
        NdotL = lerp(ShadeDark, ShadeBright, NdotL);
        color *= NdotL;

        //Rim Light
		{
			half rim = 1.0 - saturate(dot(viewDirectionWS, normalWS.xyz));
			rim = clamp(0, 0.8, rim);
			rim *= rim;
			rim *= rim;
			rim *= rim;
			half rimRatio = rim;
			//Suppressing Downward Normal Fresnel
			half upwardCoef = saturate((normalWS.y + 0.75) * 2);
			color = lerp(color, 0.5, rimRatio * upwardCoef * bdrfFersnelRatio);
		}

		//Saturation
		float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
		color = lerp(luma.xxx, color, Saturation);

		//Contrast
		color = (color - 0.5) * Contrast + 0.5;
		color = saturate(color);
		return color;
	}

	inline half3 LowSpecColorAdjustment(half3 color)
	{
		//Brightness
		color *= 1.3;

		//return color;

		//Saturation
		float luma = dot(color, float3(0.2126, 0.7152, 0.0722));
		color = lerp(luma.xxx, color, 1);

		//Contrast
		color = (color - 0.5) * 1.15 + 0.5;
		color = saturate(color);

		return color;
	}
#endif