#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Packing.hlsl"


//void Unity_Blend_LinearLight_float4(float4 Base, float4 Blend, float Opacity, out float4 Out)
//{
//	Out = Blend < 0.5 ? max(Base + (2 * Blend) - 1, 0) : min(Base + 2 * (Blend - 0.5), 1);
//	Out = lerp(Base, Out, Opacity);
//}


float invLerp(float from, float to, float value)
{
	return (value - from) / (to - from);
}

//half3 ApplyRimEffect(half4 rimColor, half rimColorPower)
//{
//    float rim = 1.0 - saturate(dot(inputData.viewDirectionWS, i.normalWS.xyz));
//    half3 rimResult = (rimColor.rgb * rimColor.a) * rimColorPower * pow(rim, _RimPower);
//    return rimResult;
//}

//
//half3 ApplyReflection(half reflectness, half smoothness)
//{
//    half3 reflectVector = reflect(-inputData.viewDirectionWS, inputData.normalWS);
//    half3 indirectSpecular = GlossyEnvironmentReflection(reflectVector, 1 - smoothness, inputData.bakedGI);
//    albedo = (albedo * (1 - reflectness)) + (indirectSpecular * reflectness);
//}


half3 CustomSampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = 1.0h)
{
#ifdef _NORMALMAP
	half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
	return UnpackNormalScale(n, scale);
#else 
	return half3(0.0h, 0.0h, 1.0h);
#endif
}

half4 SampleSpecularSmoothness(half4 specColor)
{
	half4 specularSmoothness = specColor;
    specularSmoothness.rgb *= specColor.a;
	specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);
	return specularSmoothness;
}


half4 SampleSpecularSmoothness(half2 uv, half4 specColor, TEXTURE2D_PARAM(specMap, sampler_specMap), out half4 specularMap)
{
#ifdef _SPECULARMAP
    specularMap = SAMPLE_TEXTURE2D(specMap, sampler_specMap, uv);
    half4 specularSmoothness = specularMap * specColor;
    specularSmoothness.rgb *= specColor.a;
    specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);
#else
    half4 specularSmoothness = specColor;
    specularSmoothness.rgb *= specColor.a;
    specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);
    specularMap = half4(1, 1, 1, 1);
#endif
    return specularSmoothness;
}


half3 CustomPixelBlinnPhong(InputData inputData, half3 albedo, half4 specularSmoothness, half4 specularMap)
{
    // To ensure backward compatibility we have to avoid using shadowMask i, as it is not present in older shaders
#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
    half4 shadowMask = inputData.shadowMask;
#elif !defined (LIGHTMAP_ON)
    half4 shadowMask = unity_ProbesOcclusion;
#else
    half4 shadowMask = half4(1, 1, 1, 1);
#endif

    Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

#if defined(_SCREEN_SPACE_OCCLUSION)
    AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
    mainLight.color *= aoFactor.directAmbientOcclusion;
    inputData.bakedGI *= aoFactor.indirectAmbientOcclusion;
#endif

    MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);    
    half shadowAttenuation = mainLight.shadowAttenuation * mainLight.distanceAttenuation;

    float ndotl = saturate(dot(_MainLightPosition.xyz, inputData.normalWS));
    float shadeFactor = ndotl;
    float threashold = 0.35;
    shadeFactor = clamp(shadeFactor, 0, threashold);  
    shadeFactor = invLerp(0, threashold, shadeFactor);

    //half3 ambientColor = SampleSH(inputData.normalWS) * mainLight.color;
    half3 ambientColor = inputData.bakedGI;
    //half3 attenuatedLightColor = inputData.bakedGI * mainLight.color * attenuation;
    half3 attenuatedLightColor = mainLight.color * shadowAttenuation;
    //half3 diffuse = LightingLambert(attenuatedLightColor, mainLight.direction, inputData.normalWS);
    half3 diffuseColor = mainLight.color.rgb * shadowAttenuation * shadeFactor * specularMap.rgb;
    //diffuseColor *= clamp(specularSmoothness.rgb, 0.35, 1);
    half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, specularSmoothness, specularSmoothness.a);
    //specularColor *= step(0.5, shadowAttenuation);
    
// #ifdef _ADDITIONAL_LIGHTS
//     uint pixelLightCount = GetAdditionalLightsCount();
//     for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
//     {
//         Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
//     #if defined(_SCREEN_SPACE_OCCLUSION)
//         light.color *= aoFactor.directAmbientOcclusion;
//     #endif
//         half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
//         diffuseColor += LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
//         specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularSmoothness, specularSmoothness.a);
//     }
// #elif _ADDITIONAL_LIGHTS_VERTEX
//     half vertexLightAttanuation = 1;
//     diffuseColor += inputData.vertexLighting * vertexLightAttanuation;
// #endif

    return (albedo * (ambientColor + diffuseColor)) + specularColor;
    
}