

Shader "Vulcanus/PixelCanvas/JumpFlood"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {} // Blit에서 source로 전달된 텍스처
        _TextureWidth ("Texture Width", Float) = 0
        _TextureHeight ("Texture Height", Float) = 0

        [Header(Render State)]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10
    }

    SubShader
    {
        Tags {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Pass //0
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            int _TextureWidth;
            int _TextureHeight;
            #define _TextureSize float2(_TextureWidth, _TextureHeight)
            
            TEXTURE2D_X(_MainTex);
            SAMPLER(sampler_MainTex);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.texcoord = v.texcoord;
                return o;
            }

            half4 frag(v2f input) : SV_Target
            {
                float4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.texcoord);
                
                //float lum = dot(color.rgb, float3(0.299,0.587,0.114));
                //float lerpRatio = 1 - step(lum, 0);
                //float lerpRatio = 1 - step(color.a, 0);
                float lerpRatio = 1 - step(color.r, 0);

                float4 empty = float4(0, 0, 0, 0);
                float4 notEmpty = float4(input.texcoord, 0.0, 0.0);
                return lerp(empty, notEmpty, lerpRatio);
            }
            ENDHLSL
        }

        Pass //1
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
            
            int _MaxLevel;
            int _Level;
            int _TextureWidth;
            int _TextureHeight;
            #define _TextureSize float2(_TextureWidth, _TextureHeight)

            TEXTURE2D_X(_MainTex);
            SAMPLER(sampler_MainTex);

            float4 load0(int2 p) 
            {
                float2 uv = (float2(p)-0.5) / _TextureSize;
                return SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, uv);
            }
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.texcoord = v.texcoord;
                return o;
            }

            float4 frag(v2f input) : SV_Target
            {
                int2 idxUV = input.texcoord * _TextureSize;

                // JFA step (MaxLevel = (int)log2(math.max(width, height)))
                int stepwidth = int(exp2(_MaxLevel - _Level) + 0.5);
                float shortest_dist = 999999;
                float2 shortest_coord = float2(0, 0);

                int2 tc = int2(idxUV + 0.5);
                float2 center = float2(tc);
                for (int y = -1; y <= 1; ++y) 
                {
                    for (int x = -1; x <= 1; ++x) 
                    {
                        int2 fc = tc + int2(x,y) * stepwidth;
                        float2 ntc = load0(fc).xy * _TextureSize;
                        
                        float d = length(ntc - center);
                        if ((ntc.x != 0.0) && (ntc.y != 0.0) && (d < shortest_dist)) 
                        {
                            shortest_dist = d;
                            shortest_coord = ntc / _TextureSize;
                        }
                    }
                }
                return float4(shortest_coord, 0, 0);
            }
            ENDHLSL
        }

        Pass //2
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
            
            int _TextureWidth;
            int _TextureHeight;
            #define _TextureSize float2(_TextureWidth, _TextureHeight)

            TEXTURE2D_X(_MainTex);
            SAMPLER(sampler_MainTex);

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.texcoord = v.texcoord;
                return o;
            }
            
            float4 frag(v2f input) : SV_Target
            {
                float2 aspect = float2(_TextureSize.x / _TextureSize.y, 1.0); 
                int2 idxUV = input.texcoord * _TextureSize;
                
                float2 nearest = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.texcoord).xy;
                float2 p = ((nearest * 2.0) - 1.0) * aspect;    
                
                float2 uv = input.texcoord;
                uv = (uv * 2.0 - 1.0) * aspect;
                float d = length(uv - p);
                
                // convert d to Gamma Color Space
                d = pow(d, 1.0 / 2.2);

                float3 n = float3(normalize(uv - p), 0.0) * 0.5 + 0.5;
                
                return float4(d, n.xy, 1.0);
            }
            ENDHLSL
        }

    }
}