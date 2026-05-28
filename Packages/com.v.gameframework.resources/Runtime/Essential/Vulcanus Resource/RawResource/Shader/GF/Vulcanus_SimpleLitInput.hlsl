#ifndef UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_INPUT_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4 _BaseMap_ST;
    float4 _Tiling;
    float4 _Offset;
    half4 _BaseColor;
    half4 _SpecColor;
    half4 _MaskColor;
    half4 _RimColor;
    half4 _SubRimColor;
    half4 _Dyeing_Color_R;
    half4 _Dyeing_Color_G;
    half4 _Dyeing_Color_B;
    half4 _Dyeing_Color_A;
    half4 _DissolveColorThickness;
    half4 _SSClipVariables;
    half _SwapObjectRatio;
    half _SwapObjectSign;
    half _MeshXBounds;
    half _Smoothness;
    half _EmissionPower;
    half _Cutoff;
    half _Surface;
    half _BdrfFersnelRatio;
    half _RimPower;
    half _SubRimPower;
    half _Dissolve;
    half _DitherAlpha;
CBUFFER_END

#ifdef UNITY_DOTS_INSTANCING_ENABLED
    UNITY_DOTS_INSTANCING_START(MaterialPropertyMetadata)
        UNITY_DOTS_INSTANCED_PROP(float4, _Tiling)
        UNITY_DOTS_INSTANCED_PROP(float4, _Offset)
        UNITY_DOTS_INSTANCED_PROP(half4, _BaseColor)
        UNITY_DOTS_INSTANCED_PROP(half4, _SpecColor)
        UNITY_DOTS_INSTANCED_PROP(half4, _MaskColor)
        UNITY_DOTS_INSTANCED_PROP(half4, _RimColor)
        UNITY_DOTS_INSTANCED_PROP(half4, _SubRimColor)
        UNITY_DOTS_INSTANCED_PROP(half4, _Dyeing_Color_R)
        UNITY_DOTS_INSTANCED_PROP(half4, _Dyeing_Color_G)
        UNITY_DOTS_INSTANCED_PROP(half4, _Dyeing_Color_B)
        UNITY_DOTS_INSTANCED_PROP(half4, _Dyeing_Color_A)
        UNITY_DOTS_INSTANCED_PROP(half4, _DissolveColorThickness)
        UNITY_DOTS_INSTANCED_PROP(half4, _SSClipVariables)
        UNITY_DOTS_INSTANCED_PROP(half, _SwapObjectRatio)
        UNITY_DOTS_INSTANCED_PROP(half, _SwapObjectSign)
        UNITY_DOTS_INSTANCED_PROP(half, _MeshXBounds)
        UNITY_DOTS_INSTANCED_PROP(half, _Smoothness)
        UNITY_DOTS_INSTANCED_PROP(half, _EmissionPower)
        UNITY_DOTS_INSTANCED_PROP(half , _Cutoff)
        UNITY_DOTS_INSTANCED_PROP(half , _Surface)
        UNITY_DOTS_INSTANCED_PROP(half , _BdrfFersnelRatio)
        UNITY_DOTS_INSTANCED_PROP(half , _RimPower)
        UNITY_DOTS_INSTANCED_PROP(half , _SubRimPower)
        UNITY_DOTS_INSTANCED_PROP(half , _Dissolve)
        UNITY_DOTS_INSTANCED_PROP(half , _DitherAlpha)
    UNITY_DOTS_INSTANCING_END(MaterialPropertyMetadata)

    #define _Tiling                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata__Tiling)
    #define _Offset                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4, Metadata__Offset)
    #define _BaseColor              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__BaseColor)
    #define _SpecColor              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__SpecColor)
    #define _MaskColor              UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__MaskColor)
    #define _RimColor               UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__RimColor)
    #define _SubRimColor            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__SubRimColor)
    #define _Dyeing_Color_R         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__Dyeing_Color_R)
    #define _Dyeing_Color_G         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__Dyeing_Color_G)
    #define _Dyeing_Color_B         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__Dyeing_Color_B)
    #define _Dyeing_Color_A         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__Dyeing_Color_A)
    #define _DissolveColorThickness UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__DissolveColorThickness)
    #define _SSClipVariables        UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half4 , Metadata__SSClipVariables)
    #define _SwapObjectRatio        UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__SwapObjectRatio)
    #define _SwapObjectSign         UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__SwapObjectSign)
    #define _MeshXBounds            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__MeshXBounds)
    #define _Smoothness             UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__Smoothness)
    #define _EmissionPower          UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__EmissionPower)
    #define _Cutoff                 UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__Cutoff)
    #define _Surface                UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__Surface)
    #define _BdrfFersnelRatio       UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__BdrfFersnelRatio)
    #define _RimPower               UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__RimPower)
    #define _SubRimPower            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__SubRimPower)
    #define _Dissolve               UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__Dissolve)
    #define _DitherAlpha            UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(half  , Metadata__DitherAlpha)
#endif

TEXTURE2D(_UberMap);            SAMPLER(sampler_UberMap);
TEXTURE2D(_DyeingMaskMap);      SAMPLER(sampler_DyeingMaskMap);
TEXTURE2D(_UtilityMap);         SAMPLER(sampler_UtilityMap);

inline void InitializeSimpleLitSurfaceData(float2 uv, out SurfaceData outSurfaceData)
{
    half4 albedoAlpha = SampleAlbedoAlpha(uv, TEXTURE2D_ARGS(_BaseMap, sampler_BaseMap));
    //albedoAlpha.rgb *= _BaseColor.rgb;
    albedoAlpha.a *= _BaseColor.a;
    AlphaDiscard(albedoAlpha.a, _Cutoff);    
    
    //Vulcanus Uber Map
    half3 specular = 0;
    half smoothness = _Smoothness;
    half emissionPower = 0;

#if !defined(_ULTRA_LOW_SPEC)
    //#if defined(_UBERMAP)
        half4 uberData = SAMPLE_TEXTURE2D(_UberMap, sampler_UberMap, uv);
        specular = uberData.r * _SpecColor.rgb;
        smoothness = uberData.g * _Smoothness;
        smoothness = max(smoothness, 0.0001);
        emissionPower = uberData.b * _EmissionPower;
    // #else
    //     specular = _SpecColor.rgb;
    //     smoothness = _Smoothness;
    //     smoothness = max(smoothness, 0.0001);
    //     emissionPower = _EmissionPower;
    // #endif
#endif

    //Dyeing Mask
//#ifdef _DYEINGMASK
    float4 dyeingMask = SAMPLE_TEXTURE2D(_DyeingMaskMap, sampler_DyeingMaskMap, uv);
    float maskSum = step(0.000001, dot(dyeingMask, 1));
    float3 noTintColor = saturate(1 - maskSum);
    
    float4 colorMaskWeight = dyeingMask * max(float4(_Dyeing_Color_R.a, _Dyeing_Color_G.a, _Dyeing_Color_B.a, _Dyeing_Color_A.a), 0.01); // 0.01 for Safty 
    float maskWeightSum = max(dot(colorMaskWeight, 1), 0.000001);
    float4 colorWeightRatio = colorMaskWeight / maskWeightSum;
    
    half3 dyeingColor = 0;
    dyeingColor += _Dyeing_Color_R.rgb * colorWeightRatio.r;
    dyeingColor += _Dyeing_Color_G.rgb * colorWeightRatio.g;
    dyeingColor += _Dyeing_Color_B.rgb * colorWeightRatio.b;
    dyeingColor += _Dyeing_Color_A.rgb * colorWeightRatio.a;
    albedoAlpha.rgb *= (dyeingColor + noTintColor);
//#endif

    //Mask Coloring
#if _ALBEDO_ALPHA_MASKCOLOR
    half albedoAlphaMaskColorRatio = albedoAlpha.a * _MaskColor.a;
    albedoAlpha.rgb = lerp(albedoAlpha.rgb, _MaskColor.rgb, albedoAlphaMaskColorRatio);
    albedoAlpha.a = _BaseColor.a;
#else
    #ifdef _ALPHAPREMULTIPLY_ON
    albedoAlpha.rgb *= albedoAlpha.a;
    #endif
#endif

#if !defined(_ULTRA_LOW_SPEC)
    half3 normalTS = SampleNormal(uv, TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap));
#else
    half3 normalTS = half3(0, 0, 1);
#endif

    outSurfaceData = (SurfaceData)0;
    outSurfaceData.albedo = albedoAlpha.rgb;
    outSurfaceData.specular = specular;
    outSurfaceData.metallic = 0.0; // unused
    outSurfaceData.smoothness = smoothness;
    outSurfaceData.normalTS = normalTS;
    outSurfaceData.emission = albedoAlpha.rgb * emissionPower;
    outSurfaceData.occlusion = 1.0; // unused
    outSurfaceData.alpha = albedoAlpha.a;
    outSurfaceData.clearCoatMask = 0.0h; // unused
    outSurfaceData.clearCoatSmoothness = 0.0h; // unused
}

#endif
