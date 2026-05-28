// Shader "Vulcanus/XBRZ3_Upscaling"
// {
//     Properties
//     {
//         [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
//     }
//     SubShader
//     {
//         Tags
//         {
//             "Queue" = "Transparent"
//             "RenderPipeline" = "UniversalPipeline"
//             "IgnoreProjector" = "True"
//             "RenderType" = "Transparent"
//             "PreviewType" = "Plane"
//             "ShaderUsage" = "Creator"
//         }

//         Pass
//         { 
//             HLSLPROGRAM
//             #pragma vertex vert
//             #pragma fragment frag
//             // make fog work
//             #pragma multi_compile_fog

//             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//             #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

//             struct appdata
//             {
//                 float4 vertex : POSITION;
//                 float2 uv : TEXCOORD0;
//             };

//             struct v2f
//             {
//                 float2 uv : TEXCOORD0;
//                 float4 vertex : SV_POSITION;
//             };

//             TEXTURE2D_X(_MainTex);
//             SAMPLER(sampler_MainTex); 
            
//             CBUFFER_START(UnityPerMaterial)
//                 float4 _MainTex_ST; 
//             CBUFFER_END

//             const static float filter[] = {
//                 1/16.0f, 1/8.0f, 1/16.0f, 
//                 1/8.0f, 1/4.0f, 1/8.0f, 
//                 1/16.0f, 1/8.0f, 1/16.0f, 
//             };

//             struct Kernel_4X4
//             {
//                 half4 b, c;
//                 half4 e, f, g, h;
//                 half4 i, j, k, l;
//                 half4 n, o;
//             };

//             const static uint scale = 3;
//             const static uint2 originSize = uint2(64, 64);
//             const static uint2 scaledSize = originSize * scale;

//             const static double luminanceWeight = 1;
//             const static double equalColorTolerance = 30;
//             const static double dominantDirectionThreshold = 3.6;
//             const static double steepDirectionThreshold = 2.2;

//             v2f vert (appdata v)
//             {
//                 v2f o;
//                 o.vertex = TransformObjectToHClip(v.vertex); 
//                 o.uv = TRANSFORM_TEX(v.uv, _MainTex);
//                 return o;
//             }

//             half4 frag (v2f input) : SV_Target
//             {
//             //    half4 col = tex2D(_MainTex, i.uv);

//                 uint2 nUV = (input.uv * 64); 

//                 half4 col = 0;

//                 float eqColorThres = equalColorTolerance * equalColorTolerance;
//                 Kernel_4X4 ker4;
//                 ker4.b = src[nUV sM1 + x];
//                 ker4.c = src[sM1 + xP1];

//                 ker4.e = src[s0 + xM1];
//                 ker4.f = src[s0 + x];
//                 ker4.g = src[s0 + xP1];
//                 ker4.h = src[s0 + xP2];

//                 ker4.i = src[sP1 + xM1];
//                 ker4.j = src[sP1 + x];
//                 ker4.k = src[sP1 + xP1];
//                 ker4.l = src[sP1 + xP2];

//                 ker4.n = src[sP2 + x];
//                 ker4.o = src[sP2 + xP1];


//                 // for (int x=-1 ; x<2 ; ++x)
//                 // {
//                 //     for (int y=-1 ; y<2 ; ++y)
//                 //     {
//                 //         col += LOAD_TEXTURE2D_X(_MainTex, nUV + uint2(x, y)) * filter[((x + 1) * 3) + (y + 1)];
//                 //         //half4 col = SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, input.uv); 
//                 //     }
//                 // }

//                 //col = GetLinearToSRGB(col);
//                 return col;
//             } 
//             ENDHLSL
//         }
//     }
// }

// Shader "Vulcanus/XBRZ3_Upscaling"
// {
//     Properties
//     {
//         [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
//         _THRESHOLD ("Threashold", Range(0, 1)) = 0.1
//         _UPSCALE ("Upscale", float) = 3.0

//         _LINE_THICKNESS0 ("Line Thickness 0", Range(0, 3)) = 0.4
//         _LINE_THICKNESS1 ("Line Thickness 1", Range(0, 3)) = 0.3
//     }
//     SubShader
//     {
//         Tags
//         {
//             "Queue" = "Transparent"
//             "RenderPipeline" = "UniversalPipeline"
//             "IgnoreProjector" = "True"
//             "RenderType" = "Transparent"
//             "PreviewType" = "Plane"
//             "ShaderUsage" = "Creator"
//         }

//         Pass
//         { 
//             HLSLPROGRAM

//             //anti aliasing scaling, smaller value make lines more blurry
//             #define AA_SCALE (_UPSCALE * 1.0)

//             #pragma vertex vert
//             #pragma fragment frag

//             #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
//             #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

//             struct appdata
//             {
//                 float4 vertex : POSITION;
//                 float2 uv : TEXCOORD0;
//             };

//             struct v2f
//             {
//                 float2 uv : TEXCOORD0;
//                 float4 vertex : SV_POSITION;
//             };

//             TEXTURE2D_X(_MainTex);
//             SAMPLER(sampler_MainTex); 
            
//             CBUFFER_START(UnityPerMaterial)
//                 float4 _MainTex_ST; 
//                 int _SeedTextureSizeX;
//                 int _SeedTextureSizeY;
//                 float _THRESHOLD;
//                 float _UPSCALE;
//                 float _LINE_THICKNESS0;
//                 float _LINE_THICKNESS1;
//             CBUFFER_END

//             //draw diagonal line connecting 2 pixels if within threshold
//             bool diag(inout float4 color, float2 uv, float2 p1, float2 p2, float lineThickness) 
//             {
//                 float4 v1 = LOAD_TEXTURE2D_X(_MainTex, (int2)(uv + p1));
//                 float4 v2 = LOAD_TEXTURE2D_X(_MainTex, (int2)(uv + p2));

//                 //float4 v1 = SAMPLE_TEXTURE2D_X(_MainTex, sampler_LinearClamp, (uv + p1) / 64);
//                 //float4 v2 = SAMPLE_TEXTURE2D_X(_MainTex, sampler_LinearClamp, (uv + p2) / 64);

//                 if (length(v1-v2) < _THRESHOLD) 
//                 {
//                     float2 dir = p2 - p1;
//                     dir = normalize(float2(dir.x, -dir.y));
//                     float2 lp = uv - (floor(uv + p1) + 0.5);

//                     float l = clamp(((lineThickness - dot(lp, dir)) * AA_SCALE), 0.0, 1.0);
//                     color = lerp(color, v1, l);
//                     return true;
//                 }
//                 return false;
//             }

//             v2f vert (appdata v)
//             {
//                 v2f o;
//                 o.vertex = TransformObjectToHClip(v.vertex); 
//                 o.uv = TRANSFORM_TEX(v.uv, _MainTex);
//                 return o;
//             }

//             float4 frag (v2f input) : SV_Target
//             {
//                 //start with nearest pixel as 'background'
//                 // uint2 fragCoord = (input.uv * 192.0); 
//                 // float2 ip = fragCoord / UPSCALE;
//                 //float2 ip = input.uv * 64.0;
//                 //float2 ip = input.uv * 192 / 3.0;
//                 //float2 ip = input.uv * float2(_SeedTextureSizeX, _SeedTextureSizeY);
//                 float2 ip = input.uv * float2(64.0f, 64.0f);
//                 float4 col = LOAD_TEXTURE2D_X(_MainTex, (int2)ip); 

//                 //half4 col = SAMPLE_TEXTURE2D_X(_MainTex, sampler_LinearClamp, ip / 64);
//                 //half4 col = SAMPLE_TEXTURE2D_X(_MainTex, sampler_PointClamp, input.uv);

//                 // float4 c = LOAD_TEXTURE2D_X(_MainTex, uv);
//                 // float4 l = LOAD_TEXTURE2D_X(_MainTex, uv + uint2(-1, 0));
//                 // float4 r = LOAD_TEXTURE2D_X(_MainTex, uv + uint2(-1, 0));
//                 // float4 u = LOAD_TEXTURE2D_X(_MainTex, uv + uint2(-1, 0));
//                 // float4 d = LOAD_TEXTURE2D_X(_MainTex, uv + uint2(-1, 0));
//                 // float4 ld = LOAD_TEXTURE2D_X(_MainTex, uv + uint2(-1, 0));
//                 // float4 lu = LOAD_TEXTURE2D_X(_MainTex, uv + uint2(-1, 0));
//                 // float4 rd = LOAD_TEXTURE2D_X(_MainTex, uv + uint2(-1, 0));
//                 // float4 ru = LOAD_TEXTURE2D_X(_MainTex, uv + uint2(-1, 0));

//                 //draw anti aliased diagonal lines of surrounding pixels as 'foreground'
//                 if (diag(col, ip, float2(-1,0), float2(0,-1), _LINE_THICKNESS0))
//                 {
//                     //diag(col, ip, float2(-1,0), float2(1,-1), _LINE_THICKNESS1);
//                     //diag(col, ip, float2(-1,1), float2(0,-1), _LINE_THICKNESS1);
//                 }
                
//                 if (diag(col, ip, float2(-1,0), float2(0,1), _LINE_THICKNESS0))
//                 {
//                     //diag(col, ip, float2(0,1), float2(-1,-1), _LINE_THICKNESS1);
//                     //diag(col, ip, float2(-1,0), float2(1,1), _LINE_THICKNESS1);
//                 }

//                 if (diag(col, ip, float2(1,0), float2(0,1), _LINE_THICKNESS0))
//                 {
//                     //diag(col, ip, float2(-1,1), float2(1,0), _LINE_THICKNESS1);
//                     //diag(col, ip, float2(1,-1), float2(0,1), _LINE_THICKNESS1);
//                 }

//                 if (diag(col, ip, float2(1,0), float2(0,-1), _LINE_THICKNESS0))
//                 {
//                     //diag(col, ip, float2(1,1), float2(0,-1), _LINE_THICKNESS1);
//                     //diag(col, ip, float2(1,0), float2(-1,-1), _LINE_THICKNESS1);
//                 }

//                 // float4 c = LOAD_TEXTURE2D_X(_MainTex, ip);
//                 // float4 l = LOAD_TEXTURE2D_X(_MainTex, ip + uint2(1, -1));
//                 // if (c.r == l.r && c.g == l.g && c.b == l.b)
//                 // {
//                 //     col = lerp(col, l, 0.3);
//                 // }

//                 // if (frac(input.uv * 192.0).x < 0.08)
//                 //     return 0.5;
//                 // else if(frac(input.uv * 192.0).y < 0.08)
//                 //     return 0.5;

//                 return col;
//             } 
//             ENDHLSL
//         }
//     }
// }

Shader "Vulcanus/PixelCanvas/XBRZ3_Upscaling"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        _THRESHOLD ("Threashold", float) = 0.001
        _UPSCALE ("Upscale", float) = 3.0

        _LINE_THICKNESS0 ("Line Thickness 0", float) = 0.4
        _LINE_THICKNESS1 ("Line Thickness 1", float) = 0.3
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "ShaderUsage" = "Creator"
        }

        Pass
        { 
            HLSLPROGRAM

            //anti aliasing scaling, smaller value make lines more blurry
            #define AA_SCALE (11.0)
            
            //line thickness
            float LINE_THICKNESS;

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            TEXTURE2D_X(_MainTex);
            SAMPLER(sampler_MainTex); 
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST; 
                int _SeedTextureSizeX;
                int _SeedTextureSizeY;
                float _THRESHOLD;
                float _UPSCALE;
                float _LINE_THICKNESS0;
                float _LINE_THICKNESS1;
            CBUFFER_END

            float4 SampleLinear(TEXTURE2D_PARAM(ShadowMap, sampler_ShadowMap), float2 shadowCoord, float2 texelSize)
            {
                float2 pixelPos = shadowCoord.xy / texelSize + float2(0.5, 0.5);
                float2 fracPart = frac(pixelPos);
                float2 uvCenter = float2((pixelPos - fracPart) * texelSize);
                float4 blTexel = SAMPLE_TEXTURE2D_X(ShadowMap, sampler_ShadowMap, uvCenter); 
                float4 brTexel = SAMPLE_TEXTURE2D_X(ShadowMap, sampler_ShadowMap, uvCenter + float2(texelSize.x, 0));
                float4 tlTexel = SAMPLE_TEXTURE2D_X(ShadowMap, sampler_ShadowMap, uvCenter + float2(0, texelSize.y));
                float4 trTexel = SAMPLE_TEXTURE2D_X(ShadowMap, sampler_ShadowMap, uvCenter + texelSize);
                float4 mixA = lerp(blTexel, tlTexel, fracPart.y);
                float4 mixB = lerp(brTexel, trTexel, fracPart.y);
                return lerp(mixA, mixB, fracPart.x);
            }

            bool eq(float4 col1, float4 col2) 
            {
                float4 dif = col1 - col2;
                float length_squared = dif.r * dif.r + dif.g * dif.g + dif.b * dif.b + dif.a * dif.a;
                return length_squared < _THRESHOLD * _THRESHOLD;
            }

            //draw diagonal line connecting 2 pixels if within threshold
            float4 diag(float4 sum, float2 uv, float2 point1, float2 point2, float4 color1, float4 color2, float LINE_THICKNESS) 
            {
                if (eq(color1, color2)) 
                {
                    float2 dir = point2 - point1;
                    float2 lp = uv - (floor(uv + point1) + 0.5);
                    dir = normalize(float2(dir.x, -dir.y));
                    float l = clamp((LINE_THICKNESS - dot(lp, dir)) * _UPSCALE, 0.0, 1.0);
                    sum = lerp(sum, color1, l);
                }
                return sum;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex); 
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f input) : SV_Target
            {
                
                float TEXTURE_PIXEL_SIZE = 1;
                
                float2 texelSize = float2(1/192.0, 1/192.0);
                float2 ip = input.uv * float2(64, 64);
                //ip = input.uv * (1.0 / TEXTURE_PIXEL_SIZE);
                //return SampleLinear(_MainTex, sampler_MainTex, input.uv, texelSize);

                /*
                    lu	u	ru
                    l	c	r
                    ld	d	rd
                */

                // float4 c = SampleLinear(_MainTex, sampler_MainTex, input.uv, texelSize);
                // float4 l = SampleLinear(_MainTex, sampler_MainTex, input.uv + float2(-texelSize.x,0), texelSize);
                // float4 d = SampleLinear(_MainTex, sampler_MainTex, input.uv + float2(0,-texelSize.y), texelSize);
                // float4 r = SampleLinear(_MainTex, sampler_MainTex, input.uv + float2(texelSize.x,0), texelSize);
                // float4 u = SampleLinear(_MainTex, sampler_MainTex, input.uv + float2(0,texelSize.y), texelSize);
                float4 c = LOAD_TEXTURE2D_X(_MainTex, ip);
                float4 l = LOAD_TEXTURE2D_X(_MainTex, ip + int2(-1,0));
                float4 d = LOAD_TEXTURE2D_X(_MainTex, ip + int2(0,-1));
                float4 r = LOAD_TEXTURE2D_X(_MainTex, ip + int2(1,0));
                float4 u = LOAD_TEXTURE2D_X(_MainTex, ip + int2(0,1));
                // float4 ld = SampleLinear(_MainTex, sampler_MainTex, input.uv + float2(-texelSize.x,-texelSize.y), texelSize);
                // float4 lu = SampleLinear(_MainTex, sampler_MainTex, input.uv + float2(-texelSize.x,texelSize.y), texelSize);
                // float4 rd = SampleLinear(_MainTex, sampler_MainTex, input.uv + float2(texelSize.x,-texelSize.y), texelSize);
                // float4 ru = SampleLinear(_MainTex, sampler_MainTex, input.uv + float2(texelSize.x,texelSize.y), texelSize);
                float4 ld = LOAD_TEXTURE2D_X(_MainTex, ip + int2(-1,-1));
                float4 lu = LOAD_TEXTURE2D_X(_MainTex, ip + int2(-1,1));
                float4 rd = LOAD_TEXTURE2D_X(_MainTex, ip + int2(1,-1));
                float4 ru = LOAD_TEXTURE2D_X(_MainTex, ip + int2(1,1));

                float4 s = c;

                if (eq(ld, c) == false) 
                    s = diag(s, ip, float2(-1, 0), float2(0, -1), l, d, _LINE_THICKNESS0);
                if (eq(lu, c) == false) 
                    s = diag(s, ip, float2(-1, 0), float2(0, 1), l, u, _LINE_THICKNESS0);
                if (eq(rd, c) == false) 
                    s = diag(s, ip, float2(1, 0), float2(0, -1), r, d, _LINE_THICKNESS0);
                if (eq(ru, c) == false) 
                    s = diag(s, ip, float2(1, 0), float2(0, 1), r, u, _LINE_THICKNESS0);

                float4 f = c;
                f = diag(f, ip, float2(-1, 0), float2(0, -1), l, d, _LINE_THICKNESS0);
                f = diag(f, ip, float2(-1, 0), float2(0, 1), l, u, _LINE_THICKNESS0);
                f = diag(f, ip, float2(1, 0), float2(0, -1), r, d, _LINE_THICKNESS0);
                f = diag(f, ip, float2(1, 0), float2(0, 1), r, u, _LINE_THICKNESS0);
                
                half4 col = (s+f) / 2.0;

                return col;
            } 
            ENDHLSL
        }
    }
}