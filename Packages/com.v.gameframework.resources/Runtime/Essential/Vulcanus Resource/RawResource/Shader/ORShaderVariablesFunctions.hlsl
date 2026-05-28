#ifndef OR_UNIVERSAL_PIPELINE_CORE_INCLUDED
#define OR_UNIVERSAL_PIPELINE_CORE_INCLUDED
#if !defined(UNITY_CG_INCLUDED) 
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
// Structs
struct ORVertexPositionInputs
{
    float3 positionWS; // World space position
    float3 positionVS; // View space position
    float4 positionCS; // Homogeneous clip space position
    float4 positionNDC;// Homogeneous normalized device coordinates
};

struct ORVertexNormalInputs
{
    real sign;
    real3 tangentWS;
    real3 bitangentWS;
    float3 normalWS;
};

ORVertexNormalInputs ORGetVertexNormalInputs(float3 normalOS, float4 tangentOS)
{
    ORVertexNormalInputs tbn;
    // mikkts space compliant. only normalize when extracting normal at frag.
    tbn.sign = real(tangentOS.w) * GetOddNegativeScale();
    tbn.normalWS = TransformObjectToWorldNormal(normalOS);
    tbn.tangentWS = real3(TransformObjectToWorldDir(tangentOS.xyz));
    tbn.bitangentWS = real3(cross(tbn.normalWS, float3(tbn.tangentWS))) * tbn.sign;
    return tbn;
}
#endif

/////////////////////////// 
///
///     common functions
///
/////////////////////////// 
void ORDimmedColor(inout float3 Color, float gDimmedWeight, float lDimmedWeight)
{
    //dimmed by juhan
    float3 dimmedCol = (0.299f * Color.r) + (0.587f * Color.g) + (0.114f * Color.b);
    Color = lerp(Color,dimmedCol, saturate(gDimmedWeight - lDimmedWeight));
    //end dimmed
    
}

#endif