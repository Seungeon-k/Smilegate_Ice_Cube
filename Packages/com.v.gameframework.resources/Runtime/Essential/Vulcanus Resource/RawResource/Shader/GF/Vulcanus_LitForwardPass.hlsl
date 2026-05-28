#ifndef UNIVERSAL_FORWARD_LIT_PASS_INCLUDED
#define UNIVERSAL_FORWARD_LIT_PASS_INCLUDED

#include "Vulcanus_Lighting.hlsl"
#include "Vulcanus_Common.hlsl"

// GLES2 has limited amount of interpolators
#if defined(_PARALLAXMAP) && !defined(SHADER_API_GLES)
#define REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR
#endif

#if (defined(_NORMALMAP) || (defined(_PARALLAXMAP) && !defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR))) || defined(_DETAIL)
#define REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR
#endif

// keep this file in sync with LitGBufferPass.hlsl

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 texcoord     : TEXCOORD0;
    float2 lightmapUV   : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float2 uv                           : TEXCOORD0;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    float3 positionWS                   : TEXCOORD2;
#endif

    float3 normalWS                     : TEXCOORD3;
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    float4 tangentWS                    : TEXCOORD4; // xyz: tangent, w: sign
#endif
    half3 viewDirWS                     : TEXCOORD5; // xyz: viewDir

    half3 vertexLight                   : TEXCOORD6; // vertex light

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord                  : TEXCOORD7;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    float3 viewDirTS                    : TEXCOORD8;
#endif

    VULCANUS_FOG_COORDS(9)

    half objectSwapRatio                : TEXCOORD11;
    //half dissolve                       : TEXCOORD12;

    float4 positionCS                   : SV_POSITION;
    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData);
half3 Vulcanus_UniversalFragmentPBR(InputData inputData, SurfaceData surfaceData);

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////
Varyings LitPassVertex(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput;
    vertexInput.positionWS = TransformObjectToWorld(input.positionOS.xyz);

    //output.dissolve = VSDissolve(_DissolveColorThickness, input.positionOS.xyz, input.normalOS, _Dissolve);

    if (0 != _SwapObjectSign)
    {
        //_SwapObjectRatio = (_SinTime.w + 1)  * 0.5;
        half additive = 0.1;
        half radius = (_MeshXBounds + additive) * 0.5;
        output.objectSwapRatio = length(input.positionOS.xz) / radius;
        //output.objectSwapRatio = ((input.positionOS.x * input.positionOS.x) + (input.positionOS.z * input.positionOS.z)) / (radius * radius);
        //output.objectSwapRatio = (input.positionOS.x / _MeshXBounds) + 0.5;
        output.objectSwapRatio = _SwapObjectSign * (_SwapObjectRatio -  output.objectSwapRatio);
    }

    vertexInput.positionVS = TransformWorldToView(vertexInput.positionWS);
    vertexInput.positionCS = TransformWorldToHClip(vertexInput.positionWS);
    float4 ndc = vertexInput.positionCS * 0.5f;
    vertexInput.positionNDC.xy = float2(ndc.x, ndc.y * _ProjectionParams.x) + ndc.w;
    vertexInput.positionNDC.zw = vertexInput.positionCS.zw;

    // normalWS and tangentWS already normalize.
    // this is required to avoid skewing the direction during interpolation
    // also required for per-vertex lighting and SH evaluation
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half3 viewDirWS = GetWorldSpaceViewDir(vertexInput.positionWS);
    half3 vertexLight = VertexLighting(vertexInput.positionWS, normalInput.normalWS);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.uv = output.uv * _Tiling.xy + _Offset.xy;
    
    // already normalized from normal transform to WS.
    output.normalWS = normalInput.normalWS;
    output.viewDirWS = viewDirWS;
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR) || defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    real sign = input.tangentOS.w * GetOddNegativeScale();
    half4 tangentWS = half4(normalInput.tangentWS.xyz, sign);
#endif
#if defined(REQUIRES_WORLD_SPACE_TANGENT_INTERPOLATOR)
    output.tangentWS = tangentWS;
#endif

#if defined(REQUIRES_TANGENT_SPACE_VIEW_DIR_INTERPOLATOR)
    half3 viewDirTS = GetViewDirectionTangentSpace(tangentWS, output.normalWS, viewDirWS);
    output.viewDirTS = viewDirTS;
#endif

    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    
    #if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    output.positionWS = vertexInput.positionWS;
    #endif
    
    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    output.shadowCoord = GetShadowCoord(vertexInput);
    #endif
    
    output.positionCS = vertexInput.positionCS;
    output.vulcanusFogCoord = VSFogDither(vertexInput.positionWS);

    return output;
}

// Used in Standard (Physically Based) shader
half4 LitPassFragment(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    //Area Clipping (xMin, xMax, zMin, zMax)
    //half4 areaClipMask = step(half4(_ClippingArea.xz, -_ClippingArea.yw), half4(input.positionWS.xz, -input.positionWS.xz));
    //clip(areaClipMask - 0.000001);

    //FogDither & DitherAlpha
    PSFogDither(input.positionCS, input.vulcanusFogCoord.x, _DitherAlpha);

    //Swap Object
    clip(input.objectSwapRatio);

    //ScreenSpace Clipping
    [branch] if (_SSClipVariables.w == 1)
    {
        float2 ditherUV = (_SSClipVariables.xy - input.positionCS.xy) / _SSClipVariables.z + 0.5;
        half ditherFactor = SAMPLE_TEXTURE2D(_UtilityMap, sampler_UtilityMap, ditherUV).r;
        clip((ditherFactor - _Cutoff) * _SSClipVariables.w);
    }

    half3 emission = 0;

    //Dissolving
    emission += PSDissolve(TEXTURE2D_ARGS(_UtilityMap, sampler_UtilityMap), input.uv, _DissolveColorThickness, _Dissolve);

    SurfaceData surfaceData;
    InitializeStandardLitSurfaceData(input.uv, surfaceData);

    InputData inputData = (InputData)0;
    InitializeInputData(input, surfaceData.normalTS, inputData);

    half4 color = 0;
    color.rgb = Vulcanus_UniversalFragmentPBR(inputData, surfaceData);
    color.rgb *= _BaseColor.rgb;

    #if defined(_ULTRA_LOW_SPEC)
        color.rgb = AdjustLowSpecColor(inputData.viewDirectionWS, inputData.normalWS, surfaceData.smoothness, color.rgb);
    #endif

    //Rim Light
    [branch] if (0 < _RimColor.a)
    {
        half rim = 1.0 - saturate(dot(inputData.viewDirectionWS, inputData.normalWS.xyz));
        half3 rimRatio = pow(rim, _RimPower) * _RimColor.a;
        color.rgb = lerp(color.rgb, _RimColor.rgb, rimRatio);
    }

    //Sub Rim Light
    [branch] if (0 < _SubRimColor.a)
    {
        half rim = 1.0 - saturate(dot(inputData.viewDirectionWS, inputData.normalWS.xyz));
        half3 rimRatio = pow(rim, _SubRimPower) * _SubRimColor.a;
        color.rgb = lerp(color.rgb, _SubRimColor.rgb, rimRatio);
    }

    //Apply Emission
    color.rgb += emission;
    
    color.rgb = PSFogColor(color.rgb, input.vulcanusFogCoord.y);
    color.a = OutputAlpha(surfaceData.alpha, _Surface);
    return color;
}

void InitializeInputData(Varyings input, half3 normalTS, out InputData inputData)
{
    inputData = (InputData)0;

#if defined(REQUIRES_WORLD_SPACE_POS_INTERPOLATOR)
    inputData.positionWS = input.positionWS;
#endif

    half3 viewDirWS = SafeNormalize(input.viewDirWS);
#if !defined(_ULTRA_LOW_SPEC) && defined(_NORMALMAP)
    float sgn = input.tangentWS.w;      // should be either +1 or -1
    float3 bitangent = sgn * cross(input.normalWS.xyz, input.tangentWS.xyz);
    inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(input.tangentWS.xyz, bitangent.xyz, input.normalWS.xyz));
#else
    inputData.normalWS = input.normalWS;
#endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    inputData.viewDirectionWS = viewDirWS;

#if !defined(_ULTRA_LOW_SPEC)
    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        inputData.shadowCoord = input.shadowCoord;
    #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
        inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
    #else
        inputData.shadowCoord = float4(0, 0, 0, 0);
    #endif
#endif

    inputData.vertexLighting = input.vertexLight;
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = smoothstep(ShadowSDFThreasholdA, ShadowSDFThreasholdB, SAMPLE_SHADOWMASK(input.lightmapUV));
    #if defined(_SCREEN_SPACE_OCCLUSION)
        inputData.bakedGI = 1;
    #else
        inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
    #endif
}

///////////////////////////////////////////////////////////////////////////////
//                                functions                                  //
///////////////////////////////////////////////////////////////////////////////
half3 Vulcanus_UniversalFragmentPBR(InputData inputData, SurfaceData surfaceData)
{
#if defined(_ULTRA_LOW_SPEC)
    return surfaceData.albedo;
#endif

#if defined(_SPECULARHIGHLIGHTS_OFF)
    bool specularHighlightsOff = true;
#else
    bool specularHighlightsOff = false;
#endif

    BRDFData brdfData;

    // NOTE: can modify alpha
    InitializeBRDFData(surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.alpha, brdfData);

    BRDFData brdfDataClearCoat = (BRDFData)0;
#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
    // base brdfData is modified here, rely on the compiler to eliminate dead computation by InitializeBRDFData()
    InitializeBRDFDataClearCoat(surfaceData.clearCoatMask, surfaceData.clearCoatSmoothness, brdfData, brdfDataClearCoat);
#endif

    // To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders
#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    half4 shadowMask = inputData.shadowMask;
#elif !defined (LIGHTMAP_ON)
    half4 shadowMask = unity_ProbesOcclusion;
#else
    half4 shadowMask = half4(1, 1, 1, 1);
#endif

    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

    // #if defined(_SCREEN_SPACE_OCCLUSION)
    //     AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
    //     mainLight.color *= aoFactor.directAmbientOcclusion;
    //     surfaceData.occlusion = min(surfaceData.occlusion, aoFactor.indirectAmbientOcclusion);
    // #endif

    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);
    half3 color = GlobalIllumination(brdfData, inputData.bakedGI, _BdrfFersnelRatio, surfaceData.occlusion,
                                     inputData.normalWS, inputData.viewDirectionWS);
    color += LightingPhysicallyBased(brdfData, brdfDataClearCoat,
                                     mainLight,
                                     inputData.normalWS, inputData.viewDirectionWS,
                                     surfaceData.clearCoatMask, specularHighlightsOff);

#ifdef _ADDITIONAL_LIGHTS
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
        // #if defined(_SCREEN_SPACE_OCCLUSION)
        //     light.color *= aoFactor.directAmbientOcclusion;
        // #endif
        color += LightingPhysicallyBased(brdfData, brdfDataClearCoat,
                                         light,
                                         inputData.normalWS, inputData.viewDirectionWS,
                                         surfaceData.clearCoatMask, specularHighlightsOff);
    }
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
    color += inputData.vertexLighting * brdfData.diffuse;
#endif

    color += surfaceData.emission;

    return color;
}

#endif
