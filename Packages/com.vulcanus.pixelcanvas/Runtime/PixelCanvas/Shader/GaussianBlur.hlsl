#ifndef PIXELCANVAS_GAUSSIAN_BLUR_INCLUDED
#define PIXELCANVAS_GAUSSIAN_BLUR_INCLUDED

TEXTURE2D_X(_MainTex);
SAMPLER(sampler_MainTex);

int _TextureWidth;
int _TextureHeight;
float _BlurRadius;
float _Threshold;
float _MaxDistance;

inline float Gauss(float sigma, int x)
{
    return exp(-(x * x) / (2 * sigma * sigma));
}

inline float Gauss(float sigma, int x, bool isHalf)
{
    return Gauss(sigma, x) * (isHalf ? 0.5 : 1);
}

inline float GaussianWeightSum1D(float sigma, int radius)
{
    float sum = 0;
    #if GAUSSIAN_BLUR_UNROLL
    UNITY_UNROLL
    #endif
    for (int i = 0; i < radius * 2 + 1; i++)
    {
        sum += Gauss(sigma, i - radius);
    }
    return sum;
}

inline float GaussianWeightSum2D(float sigma, int radius)
{
    const float baseSum = GaussianWeightSum1D(sigma, radius);
    float sum = 0;
    #if GAUSSIAN_BLUR_UNROLL
    UNITY_UNROLL
    #endif
    for (int i = 0; i < radius * 2 + 1; i++)
    {
        sum += Gauss(sigma, i - radius) * baseSum;
    }
    return sum;
}

// Separable Gaussian blur function with configurable sigma and radius.
//
// The delta parameter should be (texelSize.x, 0), and (0, texelSize.y) for each passes.
//
float4 GaussianBlurSeparable(TEXTURE2D_PARAM(tex, samplerTex), float2 delta, float2 uv, float sigma, int radius)
{
    int idx = -radius;
    float4 res = 0;

    const float totalWeightRcp = rcp(GaussianWeightSum1D(sigma, radius));

    // Exploit bilinear sampling to reduce the number of texture fetches, only requiring radius + 1 fetches.
    #if GAUSSIAN_BLUR_UNROLL
    UNITY_UNROLL
    #endif
    for (int i = 0; i < radius + 1; ++i)
    {
        const int x0 = idx;
        // Sample just the center texel if the radius is an even number
        const bool isNarrow = (radius & 1) == 0 && x0 == 0;
        const int x1 = isNarrow ? x0 : x0 + 1;

        // Calculate the weights for each texel
        const float w0 = Gauss(sigma, x0, x0 == 0);
        const float w1 = Gauss(sigma, x1, x1 == 0);

        // Adjust the sampling position depending on the required weight.
        // Use bilinear sampling to fetch two texels at once.
        const float texelOffset = isNarrow ? 0 : w1 / (w0 + w1);
        const float2 sampleUV = uv + (x0 + texelOffset) * delta;
        const float weight = (w0 + w1) * totalWeightRcp;
        res += SAMPLE_TEXTURE2D(tex, samplerTex, sampleUV) * weight;

        // Step to the next sample
        UNITY_FLATTEN
        if ((radius & 1) == 1 && x1 == 0)
        {
            idx = 0;
        }
        else
        {
            idx = x1 + 1;
        }
    }
    return res;
}

// Separable Gaussian blur function with configurable sigma and radius (horizontal pass)
float4 GaussianBlurHorizontal(TEXTURE2D_PARAM(tex, samplerTex), float2 delta, float2 uv, float sigma, int radius)
{
    return GaussianBlurSeparable(TEXTURE2D_ARGS(tex, samplerTex), float2(delta.x, 0), uv, sigma, radius);
}

// Separable Gaussian blur function with configurable sigma and radius (vertical pass)
float4 GaussianBlurVertical(TEXTURE2D_PARAM(tex, samplerTex), float2 delta, float2 uv, float sigma, int radius)
{
    return GaussianBlurSeparable(TEXTURE2D_ARGS(tex, samplerTex), float2(0, delta.y), uv, sigma, radius);
}

// Single pass Gaussian blur function with configurable sigma and radius.
//
// The delta parameter should be the texel size for the input texture.
float4 GaussianBlurSingle(TEXTURE2D_PARAM(tex, samplerTex), float2 delta, float2 uv, float sigma, int radius)
{
    float4 res = 0;

    const float totalWeightRcp = rcp(GaussianWeightSum2D(sigma, radius));

    int idxY = -radius;
    #if GAUSSIAN_BLUR_UNROLL
    UNITY_UNROLL
    #endif
    for (int i = 0; i < radius + 1; ++i)
    {
        const int y0 = idxY;
        // Narrow state represents a flag where a single pixel is sampled instead of two
        const bool isNarrowY = (radius & 1) == 0 && y0 == 0 || // Even radius means center texel is sampled alone
            (radius & 1) == 1 && y0 == radius; // Odd radius means rightmost center is sampled alone
        const int y1 = isNarrowY ? y0 : y0 + 1;

        int idxX = -radius;

        #if GAUSSIAN_BLUR_UNROLL
        UNITY_UNROLL
        #endif
        for (int j = 0; j < radius + 1; ++j)
        {
            const int x0 = idxX;
            const bool isNarrowX = (radius & 1) == 0 && x0 == 0 || (radius & 1) == 1 && x0 == radius;
            const int x1 = isNarrowX ? x0 : x0 + 1;

            // Weights in both directions
            const float wx0 = Gauss(sigma, x0, isNarrowX);
            const float wx1 = Gauss(sigma, x1, isNarrowX);
            const float wy0 = Gauss(sigma, y0, isNarrowY);
            const float wy1 = Gauss(sigma, y1, isNarrowY);

            // Adjust the sampling position depending on the required weight.
            // Use bilinear sampling to fetch four texels at once if possible.
            const float2 texelOffset = float2(isNarrowX ? 0 : wx1 / (wx0 + wx1), isNarrowY ? 0 : wy1 / (wy0 + wy1));
            const float2 sampleUV = uv + (float2(x0, y0) + texelOffset) * delta;

            // Sum the weights of four texels, and normalize
            const float weight = ((wx0 + wx1) * wy0 + (wx0 + wx1) * wy1) * totalWeightRcp;
            res += SAMPLE_TEXTURE2D(tex, samplerTex, sampleUV) * weight;

            // Step to the next sample
            idxX = x1 + 1;
        }

        // Step to the next sample
        idxY = y1 + 1;
    }
    return res;
}


float4 InitFrag(Varyings input) : SV_Target
{
    float alpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.texcoord).a;
    float isInside = step(_Threshold, alpha);
    return float4(input.texcoord, isInside ? 0 : 1, 1); // UV와 경계 여부 저장
}

// Pass 2: 점프 거리 전파 (예: 8픽셀)
float4 JumpFrag(Varyings input) : SV_Target
{
    float2 texelSize = float2(1.0 / 128.0, 1.0 / 128.0); // 텍스처 해상도에 맞게 조정
    float alpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.texcoord).a;
    float isInside = step(_Threshold, alpha); // 1 if inside (alpha >= threshold), 0 if outside

    float _MaxDistance = 1;
    float minDist = _MaxDistance;
    float foundBoundary = 0.0;

    // 9x9 kernel to find nearest boundary
    for (int y = -4; y <= 4; y++)
    {
        for (int x = -4; x <= 4; x++)
        {
            float2 offset = float2(x, y) * texelSize;
            float sampleAlpha = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.texcoord + offset).a;
            float sampleIsInside = step(_Threshold, sampleAlpha);

            // Check if this pixel is on the opposite side of the boundary
            if (sampleIsInside != isInside)
            {
                float dist = length(float2(x, y) * texelSize); // Distance in texel units
                minDist = min(minDist, dist);
                foundBoundary = 1.0;
            }
        }
    }

    // If no boundary found within range, set to max distance
    minDist = foundBoundary ? minDist : _MaxDistance;

    // Signed distance: negative inside, positive outside
    float signedDist = lerp(minDist, -minDist, isInside);
    // Normalize to [0, 1] range for visualization
    float normalizedDist = (signedDist + _MaxDistance) / (2.0 * _MaxDistance);
    normalizedDist = abs(normalizedDist);
    return float4(normalizedDist.xxx, 1.0);
    
    // float2 texelSize = float2(1.0 / 128.0, 1.0 / 128.0);
    // float minDist = 1e10;
    // float2 closestUV = input.uv;

    // for (int y = -1; y <= 1; y++)
    // {
    //     for (int x = -1; x <= 1; x++)
    //     {
    //         float2 offset = float2(x, y) * texelSize * 8.0; // 8픽셀 점프
    //         float4 data = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv + offset);
    //         float dist = length(data.xy - input.uv);
    //         if (dist < minDist)
    //         {
    //             minDist = dist;
    //             closestUV = data.xy;
    //         }
    //     }
    // }
    // return float4(closestUV, minDist, 1);
}

#endif