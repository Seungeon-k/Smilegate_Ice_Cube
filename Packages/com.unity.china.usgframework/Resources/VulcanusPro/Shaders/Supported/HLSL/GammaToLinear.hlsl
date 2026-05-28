#ifndef CUSTOM_GAMMATOLINEAR_INCLUDED
#define CUSTOM_GAMMATOLINEAR_INCLUDED


void GammaToLinearBegin_float(float4 col, out float4 color)
{
    float3 diffuseAlphaRGB = abs(col.rgb);
    color = float4(pow(diffuseAlphaRGB, 2.2), col.a);


}


void GammaToLinearBegin_half(half4 col, out half4 color)
{
    half3 diffuseAlphaRGB = abs(col.rgb);
    color = half4(pow(diffuseAlphaRGB, 2.2), col.a);


}

half4 GammaToLinearBeginHLSL(half4 col)
{
    half3 diffuseAlphaRGB = abs(col.rgb);
    return half4(pow(diffuseAlphaRGB, 2.2), col.a);
}

half3 GammaToLinearBeginHLSL(half3 col)
{
    half3 diffuseAlphaRGB = abs(col.rgb);
    return pow(diffuseAlphaRGB, 2.2);
}

void GammaToLinearEnd_float(float4 col, out float4 color)
{
    float gammaInv = 1 / 2.2;
    color = pow(abs(col), float4(gammaInv, gammaInv, gammaInv, 1));
}

void GammaToLinearEnd_half(half4 col, out half4 color)
{
    half gammaInv = 1 / 2.2;
    color = pow(abs(col), half4(gammaInv, gammaInv, gammaInv, 1));
}

half4 GammaToLinearEndHLSL(half4 col)
{
    half gammaInv = 1 / 2.2;
    return pow(abs(col), half4(gammaInv, gammaInv, gammaInv, 1));
}

half3 GammaToLinearEndHLSL(half3 col)
{
    half gammaInv = 1 / 2.2;
    return pow(abs(col), half3(gammaInv, gammaInv, gammaInv));
}


void GammaToLinearUnfackNormal_half(half4 packednormal, out half3 normal)
{
    normal = packednormal.xyz * 2 - 1;


}

void GammaToLinearUnfackNormal_float(float4 packednormal, out float3 normal)
{
    normal = packednormal.xyz * 2 - 1;


}

half3 GammaToLinearUnfackNormalHLSL(half4 packednormal)
{
    half3 unpackednormal = packednormal.xyz * 2 - 1;
    return unpackednormal;
}
 


#endif