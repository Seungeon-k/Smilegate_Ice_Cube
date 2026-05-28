Shader "Vulcanus/PixelCanvas/xbrzPixelUpscaling"
{
    Properties
    {
        _LumWeight ("Lum Weight", Range(0, 10)) = 5.0
        _ColorEqualityThreashold ("Color Equality Threashold", Range(0, 1)) = 0.1
        _RadicalDirectionThreashold ("Radical Direction Threshold", Range(0, 10)) = 2
        _StrongDirectionThreashold ("Strong Direction Threshold", Range(0, 10)) = 5
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" "RenderPipeline"="UniversalPipeline" }
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
            #include "Global.hlsl"

            static const int NONE = 0;
            static const int BLEND = 1;
            static const int STRONG = 2;

            CBUFFER_START(UnityPerMaterial)
                float4 _SeedTex_ST;
                float _LumWeight;
                float _ColorEqualityThreashold;
                float _RadicalDirectionThreashold;
                float _StrongDirectionThreashold;
            CBUFFER_END

            #define TEX(offx, offy) SAMPLE_TEXTURE2D_X(_SeedTex, sampler_SeedTex, base + texel * float2(offx, offy)).rgb

            float Dist(float3 p1, float3 p2)
            {
                float3 w = float3(0.2627, 0.6780, 0.0593);
                float3 d = p1 - p2;
                float y = dot(d, w);
                float cb = (d.b - y) * 0.5 / (1.0 - w.b);
                float cr = (d.r - y) * 0.5 / (1.0 - w.r);
                return sqrt(y*y*_LumWeight*_LumWeight + cb*cb + cr*cr);
            }

            bool Similar(float3 a, float3 b) { return Dist(a, b) < _ColorEqualityThreashold; }

            float BlendFactor(float2 pos, float2 org, float2 axis, float2 scl)
            {
                float2 vec = pos - org;
                float2 proj = axis * dot(vec, axis) / dot(axis, axis);
                float2 perp = float2(-axis.y, axis.x);
                float s = sign(dot(vec, perp));
                return smoothstep(-0.707, 0.707, s * length((vec - proj) * scl));
            }

            struct appdata { float4 vertex : POSITION; float2 uv : TEXCOORD0; };
            struct v2f { float2 uv : TEXCOORD0; float4 vertex : SV_POSITION; };

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _SeedTex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 texel = 1.0 / _SeedTextureSize.xy;
                float2 scale = _UpscaledTextureSize.xy * texel;
                float2 fracUV = frac(i.uv * _SeedTextureSize.xy) - 0.5;
                float2 base = i.uv - fracUV * texel;

                float3 NW = TEX(-1, -1);
                float3 N  = TEX( 0, -1);
                float3 NE = TEX( 1, -1);
                float3 W  = TEX(-1,  0);
                float3 C  = TEX( 0,  0);
                float3 E  = TEX( 1,  0);
                float3 SW = TEX(-1,  1);
                float3 S  = TEX( 0,  1);
                float3 SE = TEX( 1,  1);

                int4 corners = int4(NONE, NONE, NONE, NONE); // NW, NE, SW, SE

                // NE corner
                if (!((Similar(C,E) && Similar(S,SE)) || (Similar(C,S) && Similar(E,SE))))
                {
                    float d1 = Dist(SW,C) + Dist(C,NE) + Dist(TEX(0,2),SE) + Dist(SE,TEX(2,0)) + 4*Dist(S,E);
                    float d2 = Dist(W,S) + Dist(S,TEX(1,2)) + Dist(N,E) + Dist(E,TEX(2,1)) + 4*Dist(C,SE);
                    bool strongFactor = _StrongDirectionThreashold * d1 < d2;
                    corners.y = (d1 < d2 && !Similar(C,E) && !Similar(C,S)) ? (strongFactor ? STRONG : BLEND) : NONE;
                }

                // SW corner
                if (!((Similar(W,C) && Similar(SW,S)) || (Similar(W,SW) && Similar(C,S))))
                {
                    float d1 = Dist(TEX(-2,1),W) + Dist(W,N) + Dist(TEX(-1,2),S) + Dist(S,E) + 4*Dist(SW,C);
                    float d2 = Dist(TEX(-2,0),SW) + Dist(SW,TEX(0,2)) + Dist(NW,C) + Dist(C,SE) + 4*Dist(W,S);
                    bool strongFactor = _StrongDirectionThreashold * d2 < d1;
                    corners.z = (d1 > d2 && !Similar(C,W) && !Similar(C,S)) ? (strongFactor ? STRONG : BLEND) : NONE;
                }

                // NW corner
                if (!((Similar(NW,N) && Similar(W,C)) || (Similar(NW,W) && Similar(N,C))))
                {
                    float d1 = Dist(TEX(-2,0),NW) + Dist(NW,TEX(0,-2)) + Dist(SW,C) + Dist(C,NE) + 4*Dist(W,N);
                    float d2 = Dist(TEX(-2,-1),W) + Dist(W,S) + Dist(TEX(-1,-2),N) + Dist(N,E) + 4*Dist(NW,C);
                    bool strongFactor = _StrongDirectionThreashold * d1 < d2;
                    corners.x = (d1 < d2 && !Similar(C,W) && !Similar(C,N)) ? (strongFactor ? STRONG : BLEND) : NONE;
                }

                // SE corner (reordered last)
                if (!((Similar(N,NE) && Similar(C,E)) || (Similar(N,C) && Similar(NE,E))))
                {
                    float d1 = Dist(W,N) + Dist(N,TEX(1,-2)) + Dist(S,E) + Dist(E,TEX(2,-1)) + 4*Dist(C,NE);
                    float d2 = Dist(NW,C) + Dist(C,SE) + Dist(TEX(0,-2),NE) + Dist(NE,TEX(2,0)) + 4*Dist(N,E);
                    bool strongFactor = _StrongDirectionThreashold * d2 < d1;
                    corners.w = (d1 > d2 && !Similar(C,N) && !Similar(C,E)) ? (strongFactor ? STRONG : BLEND) : NONE;
                }

                float3 outCol = C;

                // NE blend
                if (corners.y)
                {
                    float dfg = Dist(E,SW); float dhc = Dist(S,NE);
                    bool lineFactor = corners.y == STRONG || !((corners.w && !Similar(C,SW)) || (corners.z && !Similar(C,NE)) || (Similar(SW,S) && Similar(S,SE) && Similar(SE,E) && Similar(E,NE) && !Similar(C,SE)));
                    float2 org = float2(0, 0.707); float2 dir = float2(1,-1);
                    if (lineFactor) 
                    {
                        bool sh = _RadicalDirectionThreashold * dfg <= dhc && !Similar(C,SW) && !Similar(W,SW);
                        bool st = _RadicalDirectionThreashold * dhc <= dfg && !Similar(C,NE) && !Similar(N,NE);
                        org.y = sh ? 0.25 : 0.5; dir.x += sh; dir.y -= st;
                    }
                    float3 mix = lerp(S, E, step(Dist(C,E), Dist(C,S)));
                    outCol = lerp(outCol, mix, BlendFactor(fracUV, org, dir, scale));
                }

                // SW blend
                if (corners.z)
                {
                    float dha = Dist(S,NW); float ddi = Dist(W,SE);
                    bool lineFactor = corners.z == STRONG || !((corners.y && !Similar(C,NW)) || (corners.x && !Similar(C,SE)) || (Similar(NW,W) && Similar(W,SW) && Similar(SW,S) && Similar(S,SE) && !Similar(C,SW)));
                    float2 org = float2(-0.707,0); float2 dir = float2(1,1);
                    if (lineFactor) 
                    {
                        bool sh = _RadicalDirectionThreashold * dha <= ddi && !Similar(C,NW) && !Similar(N,NW);
                        bool st = _RadicalDirectionThreashold * ddi <= dha && !Similar(C,SE) && !Similar(E,SE);
                        org.x = sh ? -0.25 : -0.5; dir.y += sh; dir.x += st;
                    }
                    float3 mix = lerp(S, W, step(Dist(C,W), Dist(C,S)));
                    outCol = lerp(outCol, mix, BlendFactor(fracUV, org, dir, scale));
                }

                // NW blend
                if (corners.x)
                {
                    float ddc = Dist(W,NE); float dbg = Dist(N,SW);
                    bool lineFactor = corners.x == STRONG || !((corners.z && !Similar(C,NE)) || (corners.w && !Similar(C,SW)) || (Similar(NE,N) && Similar(N,NW) && Similar(NW,W) && Similar(W,SW) && !Similar(C,NW)));
                    float2 org = float2(0,-0.707); float2 dir = float2(-1,1);
                    if (lineFactor) 
                    {
                        bool sh = _RadicalDirectionThreashold * ddc <= dbg && !Similar(C,NE) && !Similar(E,NE);
                        bool st = _RadicalDirectionThreashold * dbg <= ddc && !Similar(C,SW) && !Similar(S,SW);
                        org.y = sh ? -0.25 : -0.5; dir.x -= sh; dir.y += st;
                    }
                    float3 mix = lerp(W, N, step(Dist(C,N), Dist(C,W)));
                    outCol = lerp(outCol, mix, BlendFactor(fracUV, org, dir, scale));
                }

                // SE blend
                if (corners.w)
                {
                    float dbi = Dist(N,SE); float dfa = Dist(E,NW);
                    float2 org = float2(0.707,0); float2 dir = float2(-1,-1);
                    int lineFactor = saturate(corners.w == STRONG || !((corners.x && !Similar(C,SE)) || (corners.y && !Similar(C,NW)) || (Similar(SE,E) && Similar(E,NE) && Similar(NE,N) && Similar(N,NW) && !Similar(C,NE))));
                    if (lineFactor) 
                    {
                        bool sh = _RadicalDirectionThreashold * dbi <= dfa && !Similar(C,SE) && !Similar(S,SE);
                        bool st = _RadicalDirectionThreashold * dfa <= dbi && !Similar(C,NW) && !Similar(W,NW);
                        org.x = sh ? 0.25 : 0.5; dir.y -= sh; dir.x -= st;
                    }
                    float3 mix = lerp(E, N, step(Dist(C,N), Dist(C,E)));
                    outCol = lerp(outCol, mix, BlendFactor(fracUV, org, dir, scale));
                }

                return float4(outCol, 1);
            }
            ENDHLSL
        }
    }
}