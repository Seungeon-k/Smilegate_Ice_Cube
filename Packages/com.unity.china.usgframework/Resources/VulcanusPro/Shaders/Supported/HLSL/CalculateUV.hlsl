#ifndef CUSTOM_CALCULATE_UV_INCLUDED
#define CUSTOM_CALCULATE_UV_INCLUDED


void GetMainUV_float(float z, out float4 main_uv)
{
    half tile = round(z / 1000);
    half max = round((z - (tile * 1000)) / 100);
    half id = round(z - (tile * 1000 + max * 100));
    half value = 1.0f / max;
    main_uv = half4(fmod(id, max) * value, floor(id / max) * value, tile, value);
}

void GetMainUV_half(half z, out half4 main_uv)
{
    half tile = round(z / 1000);
    half max = round((z - (tile * 1000)) / 100);
    half id = round(z - (tile * 1000 + max * 100));
    half value = 1.0f / max;
    main_uv = float4(fmod(id, max) * value, floor(id / max) * value, tile, value);
}

void FindUV_float(float3 uv, float4 main_uv, out float2 find_uv)
{
    float2 uvTile = uv.xy * main_uv.z;
    find_uv = frac(uvTile) * (main_uv.w - 0.004f) + float2(0.002f, 0.002f);

}

void FindUV_half(half3 uv, half4 main_uv, out half2 find_uv)
{
    half2 uvTile = uv.xy * main_uv.z;
    find_uv = frac(uvTile) * (main_uv.w - 0.004f) + float2(0.002f, 0.002f);

}


half4 GetMainUV(half z)
{
    half tile = round(z / 1000);
    half max = round((z - (tile * 1000)) / 100);
    half id = round(z - (tile * 1000 + max * 100));
    half value = 1.0f / max;

    return half4(fmod(id, max) * value, floor(id / max) * value, tile, value);
}

half2 FindUV(half3 uv, half4 main_uv)
{
    half2 uvTile = uv.xy * main_uv.z;
    half2 find_uv = frac(uvTile) * (main_uv.w - 0.004f) + float2(0.002f, 0.002f);

    return find_uv;
}

half2 GetBumpUV(half z)
{
    return half2(fmod(z, 4.0f), floor(z / 4.0f)) * 0.25f;
}

inline float4 OffsetUV(float4 uv, float2 offset)
{
#ifdef UNITY_Z_0_FAR_FROM_CLIPSPACE
    uv.xy = offset * UNITY_Z_0_FAR_FROM_CLIPSPACE(uv.z) + uv.xy;
#else
    uv.xy = (offset * uv.z + uv.xy) / uv.w;
#endif
    return uv;
}

#endif