#ifndef UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED
#define UNIVERSAL_SIMPLE_LIT_PASS_INCLUDED

#include "Vulcanus_Lighting.hlsl"
#include "Vulcanus_Common.hlsl"

struct VulcanusInputData
{
    float3  positionWS;
    half3   normalWS;
    half3   viewDirectionWS;
    float4  shadowCoord;
    half3   vertexLighting;
    half3   additionalVertexLighting;
    half3   bakedGI;
    float2  normalizedScreenSpaceUV;
    half4   shadowMask;
};

struct Attributes
{
    float4 positionOS    : POSITION;
    float3 normalOS      : NORMAL;
    float4 tangentOS     : TANGENT;
    float2 texcoord      : TEXCOORD0;
    float2 lightmapUV    : TEXCOORD1;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct Varyings
{
    float4 positionCS               : SV_POSITION;
    float2 uv                       : TEXCOORD0;
    DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 1);

    float3 positionWS               : TEXCOORD2;    // xyz: positionWS
    //half   dissolve                 : TEXCOORD3;
    half   objectSwapRatio          : TEXCOORD4;

#if !defined(_ULTRA_LOW_SPEC) && defined(_NORMALMAP)
    float4 normalWS                 : TEXCOORD5;    // xyz: normalWS, w: viewDirectionWS.x
    float4 tangentWS                : TEXCOORD6;    // xyz: tangentWS, w: viewDirectionWS.y
    float4 tanbitangentWS           : TEXCOORD7;    // xyz: tanbitangentWS, w: viewDirectionWS.z
#else
    float3 normalWS                 : TEXCOORD5;
    float3 viewDirectionWS          : TEXCOORD6;
#endif

    half3 vertexLight               : TEXCOORD8;    // xyz: vertex light
    half3 additionalVertexLight     : TEXCOORD9;    // xyz: additional vertex light
#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    float4 shadowCoord              : TEXCOORD10; 
#endif

    VULCANUS_FOG_COORDS(11)

    UNITY_VERTEX_INPUT_INSTANCE_ID
    UNITY_VERTEX_OUTPUT_STEREO
};

//On VertexShader
void Vulcanus_VertexLighting(float3 positionWS, half3 normalWS, float4 shadowCoord, out half3 vertexLight, out half3 additionalLight);

//On PixelShader
void InitializeInputData(Varyings input, half3 normalTS, out VulcanusInputData inputData);
half3 Vulcanus_UniversalFragmentBlinnPhong(VulcanusInputData inputData, SurfaceData surfaceData, inout half3 emission);
half3 BRDF_LightingSpecular(half3 lightColor, half3 lightDir, half3 normalWS, half3 viewDirectionWS, half3 specular, half smoothness);

///////////////////////////////////////////////////////////////////////////////
//                  Vertex and Fragment functions                            //
///////////////////////////////////////////////////////////////////////////////
Varyings LitPassVertexSimple(Attributes input)
{
    Varyings output = (Varyings)0;

    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_TRANSFER_INSTANCE_ID(input, output);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(output);

    VertexPositionInputs vertexInput;
    vertexInput.positionWS = TransformObjectToWorld(input.positionOS.xyz);

    //Dissolving
    //output.dissolve = VSDissolve(_DissolveColorThickness, input.positionOS.xyz, input.normalOS, _Dissolve);

    //Swap Object
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

    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);
    half3 viewwDirectionWS = GetWorldSpaceViewDir(vertexInput.positionWS);

    output.uv = TRANSFORM_TEX(input.texcoord, _BaseMap);
    output.uv = output.uv * _Tiling.xy + _Offset.xy;
    
    //output.uvUtility = TRANSFORM_TEX(input.texcoord, _UtilityMap);
    output.positionWS.xyz = vertexInput.positionWS;
    output.positionCS = vertexInput.positionCS;

#if !defined(_ULTRA_LOW_SPEC) && defined(_NORMALMAP)
    output.normalWS = half4(normalInput.normalWS, viewwDirectionWS.x);
    output.tangentWS = half4(normalInput.tangentWS, viewwDirectionWS.y);
    output.tanbitangentWS = half4(normalInput.bitangentWS, viewwDirectionWS.z);
#else
    output.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
    output.viewDirectionWS = viewwDirectionWS;
#endif

#if !defined(_ULTRA_LOW_SPEC)
    OUTPUT_LIGHTMAP_UV(input.lightmapUV, unity_LightmapST, output.lightmapUV);
    OUTPUT_SH(output.normalWS.xyz, output.vertexSH);

    float4 shadowCoord;
    #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
        shadowCoord = output.shadowCoord = GetShadowCoord(vertexInput);
    #else
        shadowCoord = float4(0, 0, 0, 0);
    #endif

    //Vertex Lighting
    half3 diffuseLight = 0;
    half3 additionalDiffuseLight = 0;
    Vulcanus_VertexLighting(vertexInput.positionWS, normalInput.normalWS, shadowCoord, /*[out]*/ diffuseLight, /*[out]*/ additionalDiffuseLight);
    output.vertexLight = diffuseLight;
    output.additionalVertexLight = additionalDiffuseLight;
#else
#endif

    output.vulcanusFogCoord = VSFogDither(vertexInput.positionWS);

    return output;
}

// Used for StandardSimpleLighting shader
half4 LitPassFragmentSimple(Varyings input) : SV_Target
{
    UNITY_SETUP_INSTANCE_ID(input);
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    //Area Clipping (xMin, xMax, zMin, zMax)
    //half4 areaClipMask = step(half4(_ClippingArea.xz, -_ClippingArea.yw), half4(input.positionWS.xz, -input.positionWS.xz));
    //clip(areaClipMask - 0.000001);

    //Fog Clipping & DitherAlpha
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
    InitializeSimpleLitSurfaceData(input.uv, surfaceData);

    VulcanusInputData inputData;
    InitializeInputData(input, surfaceData.normalTS, inputData);

    half3 color = Vulcanus_UniversalFragmentBlinnPhong(inputData, surfaceData, emission);
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

    half alpha = OutputAlpha(surfaceData.alpha, _Surface);
    return half4(color, alpha);
}

///////////////////////////////////////////////////////////////////////////////
//                                functions                                  //
///////////////////////////////////////////////////////////////////////////////
void InitializeInputData(Varyings input, half3 normalTS, out VulcanusInputData inputData)
{
    inputData.positionWS = input.positionWS;

#if !defined(_ULTRA_LOW_SPEC) && defined(_NORMALMAP)
    half3 viewwDirectionWS = half3(input.normalWS.w, input.tangentWS.w, input.tanbitangentWS.w);
    inputData.normalWS = TransformTangentToWorld(normalTS,
        half3x3(input.tangentWS.xyz, input.tanbitangentWS.xyz, input.normalWS.xyz));
#else
    half3 viewwDirectionWS = input.viewDirectionWS;
    inputData.normalWS = input.normalWS;
#endif

    inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
    viewwDirectionWS = SafeNormalize(viewwDirectionWS);
    inputData.viewDirectionWS = viewwDirectionWS;

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
    inputData.shadowCoord = input.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
    inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
    inputData.shadowCoord = float4(0, 0, 0, 0);
#endif

    inputData.vertexLighting = input.vertexLight;
    inputData.additionalVertexLighting = input.additionalVertexLight;
    inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(input.positionCS);
    inputData.shadowMask = smoothstep(ShadowSDFThreasholdA, ShadowSDFThreasholdB, SAMPLE_SHADOWMASK(input.lightmapUV));
    #if defined(_SCREEN_SPACE_OCCLUSION)
        inputData.bakedGI = 1;
    #else
        inputData.bakedGI = SAMPLE_GI(input.lightmapUV, input.vertexSH, inputData.normalWS);
    #endif
}

void Vulcanus_VertexLighting(float3 positionWS, half3 normalWS, float4 shadowCoord, out half3 vertexLight, out half3 additionalLight)
{
    half4 shadowMask = half4(1, 1, 1, 1);
    half3 attenuatedLightColor = 0;
    vertexLight = 0;
    additionalLight = 0;

#if defined(_ULTRA_LOW_SPEC)
    return;
#endif

#if defined(_VERTEX_LIGHTING)
    Light mainLight = GetMainLight(shadowCoord, positionWS, shadowMask);
    attenuatedLightColor = mainLight.color * mainLight.distanceAttenuation;
    vertexLight = LightingLambert(attenuatedLightColor, mainLight.direction, normalWS);
#endif

#if defined(_ADDITIONAL_LIGHTS_VERTEX)
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, positionWS, shadowMask);
        attenuatedLightColor = light.color * light.distanceAttenuation;
        additionalLight += LightingLambert(attenuatedLightColor, light.direction, normalWS);
    }
#endif
}

half3 Vulcanus_UniversalFragmentBlinnPhong(VulcanusInputData inputData, SurfaceData surfaceData, inout half3 emission)
{
#if defined(_ULTRA_LOW_SPEC)
    return surfaceData.albedo;// + (inputData.bakedGI * 0.1);
#endif

// To ensure backward compatibility we have to avoid using shadowMask input, as it is not present in older shaders
    #if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
        half4 shadowMask = inputData.shadowMask;
    #elif !defined (LIGHTMAP_ON)
        half4 shadowMask = unity_ProbesOcclusion;
    #else
        half4 shadowMask = half4(1, 1, 1, 1);
    #endif

    half3 diffuseColor = 0;
    float3 specularColor = 0;
    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);
    // #if defined(_SCREEN_SPACE_OCCLUSION)
    //     AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
    //     mainLight.color *= aoFactor.directAmbientOcclusion;
    //     inputData.bakedGI *= aoFactor.indirectAmbientOcclusion;
    // #endif
    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);
    half3 attenuatedLightColor = mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);

#if defined(_VERTEX_LIGHTING)
    diffuseColor = inputData.bakedGI + (inputData.vertexLighting * (mainLight.distanceAttenuation * mainLight.shadowAttenuation));
#else
    diffuseColor = inputData.bakedGI + LightingLambert(attenuatedLightColor, mainLight.direction, inputData.normalWS);
    //diffuseColor += inputData.vertexLighting * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
#endif

#if defined(_SPECULAR_COLOR)
    specularColor += BRDF_LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, surfaceData.specular, surfaceData.smoothness);
#endif

#if defined(_ADDITIONAL_LIGHTS)
    uint pixelLightCount = GetAdditionalLightsCount();
    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
    {
        Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);

    // #if defined(_SCREEN_SPACE_OCCLUSION)
    //     light.color *= aoFactor.directAmbientOcclusion;
    // #endif

        half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
        diffuseColor += LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);

    #if defined(_SPECULAR_COLOR)
        specularColor += BRDF_LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, surfaceData.specular, surfaceData.smoothness);
    #endif
    }
#else
    diffuseColor += inputData.additionalVertexLighting;
#endif

    //Fresnel
    half3 reflectVector = reflect(inputData.viewDirectionWS, inputData.normalWS.xyz);
    half NoV = saturate(dot(inputData.normalWS.xyz, inputData.viewDirectionWS));
    //Suppressing Downward Fresnel
    half upwardCoef = saturate((inputData.normalWS.y + 0.75) * 2);
    half fresnelTerm = Pow4(1.0 - NoV);
    fresnelTerm = lerp(0, fresnelTerm, upwardCoef);
    half grazingTerm = surfaceData.smoothness * 0.7; //Make Similar to Lit Shader
    emission += grazingTerm * fresnelTerm * _BdrfFersnelRatio;

    half3 color = (surfaceData.albedo * diffuseColor + specularColor) + surfaceData.emission;
    return color;
}

//BRDF Specular
half3 BRDF_LightingSpecular(half3 lightColor, half3 lightDirectionWS, half3 normalWS, half3 viewDirectionWS, half3 specular, half smoothness)
{    
    half perceptualRoughness = 1 - smoothness;
    float roughness = perceptualRoughness * perceptualRoughness;
    float roughness2 = max(roughness * roughness, HALF_MIN);
    float normalizationTerm = roughness * 4.0h + 2.0h;

    float3 halfDirWS = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));
    float NoH = saturate(dot(normalWS, halfDirWS));
    float LoH = saturate(dot(lightDirectionWS, halfDirWS));
    float d = NoH * NoH * (roughness2 - 1) + 1.00001h;
    float LoH2 = LoH * LoH;
    float specularTerm = roughness2 / ((d * d) * max(0.1h, LoH2) * normalizationTerm);
    
    half NdotL = saturate(dot(normalWS, lightDirectionWS));
    half3 radiance = lightColor * NdotL;

//#if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
    specularTerm = specularTerm - HALF_MIN;
    specularTerm = clamp(specularTerm, 0.0, 100.0); // Prevent FP16 overflow on mobiles
//#endif

    return specular * specularTerm * radiance;
}

#endif