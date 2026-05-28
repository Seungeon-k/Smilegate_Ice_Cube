#ifndef COMMON_INCLUDED
    #define COMMON_INCLUDED

    static const half v1 = 0.01;
    static const half v2 = 0.30;
    static const half v3 = 0.60;
    static const half v4 = 0.90;
    static const half DitherCellWidth = 4;
    static const half DitherCellHalfWidth = (int)(DitherCellWidth * 0.5);
    static const half DITHER_THRESHOLDS[] =
    {
        /*
            1.0 / 17.0,     9.0 / 17.0,     3.0 / 17.0,     11.0 / 17.0,
            13.0 / 17.0,    5.0 / 17.0,     15.0 / 17.0,    7.0 / 17.0,
            4.0 / 17.0,     12.0 / 17.0,    2.0 / 17.0,     10.0 / 17.0,
            16.0 / 17.0,    8.0 / 17.0,     14.0 / 17.0,    6.0 / 17.0
        */
        0.058823529411765, 0.502941176470588, 0.17647058823529, 0.64705882352941, 
        0.76470588235294, 0.29411764705882, 0.88235294117647, 0.41176470588235, 
        0.23529411764706, 0.70588235294118, 0.11764705882353, 0.508823529411765, 
        0.504117647058824, 0.47058823529412, 0.82352941176471, 0.35294117647059,
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
    };
    void Unity_Dither_positionCS(half In, float2 positionCS, out half Out)
    {
        float2 uv = positionCS;
        uint offset = (uint)(uv.y / DitherCellWidth) % 2;
        uv.x += offset * DitherCellHalfWidth;
        uint index = (uint(uv.y) % DitherCellWidth) * DitherCellWidth + uint(uv.x) % DitherCellWidth;
        half ditherThreashold = DITHER_THRESHOLDS[index];
        Out = In - ditherThreashold;
    }

    // sRGB -> Linear
    float3 ToLinear(float3 color)
    {
        return pow(color, 2.2);
    }

    // Linear -> sRGB
    float3 ToGamma(float3 color)
    {
        return pow(color, 1.0 / 2.2);
    }

    float SDFCircle(float2 p, float radius) 
    {
        return length(p) - radius;
    }

    float SDFRing(half2 uv, half radius, half thickness, half softness)
    {
        float2 coords = uv;
        float magnitude = length(coords);
                    
        float factor = 1 - abs(magnitude - radius) / thickness;
        factor /= softness;
        factor = saturate(factor);
        return factor;
    }

    half SDFBox(half2 p, half2 b)
    {
        half2 d = abs(p) - b;
        return length(max(d, 0.0)) + min(max(d.x, d.y), 0.0);
    }

    float SDFLine(float2 beg, float2 end, float2 coord)
    {
        float2 toLine = end - beg;
        float2 toPos = coord - beg;
        float h = saturate(dot(toPos, toLine) / dot(toLine, toLine));
        float dist = length(toPos - (toLine * h));
        return dist;
    }

    float SDFLine(float3 beg, float3 end, float3 coord)
    {
        float3 toLine = end - beg;
        float3 toPos = coord - beg;
        float h = saturate(dot(toPos, toLine) / dot(toLine, toLine));
        float dist = length(toPos - (toLine * h));
        return dist;
    }

#endif // COMMON_INCLUDED