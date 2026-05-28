#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
#include "Global.hlsl"

struct appdata
{
    float4 vertex : POSITION;
    float4 color : COLOR;
    float2 uv : TEXCOORD0;
};

struct v2f
{
    float4 vertex : SV_POSITION;
    float4 color : COLOR;
    float2 uv : TEXCOORD0;
};


TEXTURE2D_X(_MainTex);
SAMPLER(sampler_MainTex);

v2f vert (appdata v)
{
    v2f o;
    o.vertex = TransformObjectToHClip(v.vertex.xyz);
    o.color = v.color * _BrushColor; 
    o.uv = v.uv;
    return o;
}

float Line(float2 beg, float2 end, float2 coord)
{
    float2 toLine = end - beg;
    float2 toPos = coord - beg;
    float h = saturate(dot(toPos, toLine) / dot(toLine, toLine));
    float dist = length(toPos - (toLine * h));
    return dist;
}