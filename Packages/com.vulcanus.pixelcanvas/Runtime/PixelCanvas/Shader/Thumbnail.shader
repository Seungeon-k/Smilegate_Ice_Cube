Shader "Vulcanus/PixelCanvas/Thumbnail"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {} // Blit에서 source로 전달된 텍스처
        _BaseMap ("Base Tex", 2D) = "white" {}

        _TextureWidth ("Texture Width", Float) = 0
        _TextureHeight ("Texture Height", Float) = 0

        [Header(Render State)]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10
    }

    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass // Normal : Pass 0
        {
            Name "ForwardLit"
            //Tags { "LightMode" = "UniversalForward" }
            
            Blend [_BlendScr] [_BlendDst]

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Common.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
            CBUFFER_END

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };
            
            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float3 viewDirectionWS : TEXCOORD1;
            };
            
            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.normalWS = TransformObjectToWorldDir(v.normal);
                o.texcoord = v.texcoord;
                o.viewDirectionWS = normalize(GetWorldSpaceViewDir(positionWS));
                return o;
            }

            half4 frag (v2f i) : SV_TARGET
            {
                half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.texcoord);

                //Rim Light
                half rim = 1.0 - saturate(dot(i.viewDirectionWS, i.normalWS.xyz));
                rim = pow(rim, 10);
                color.rgb += rim;
                return color;
            }

            ENDHLSL
        }

        Pass // Empty : Pass 1
        {
            Name "ForwardLit"
            //Tags { "LightMode" = "UniversalForward" }
            
            BlendOp Add, Max
            Blend One Zero, SrcAlpha Zero

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Common.hlsl"

            TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseMap_ST;
            CBUFFER_END

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };
            
            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float3 viewDirectionWS : TEXCOORD1;
            };
            
            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.normalWS = TransformObjectToWorldDir(v.normal);
                o.texcoord = v.texcoord;
                o.viewDirectionWS = normalize(GetWorldSpaceViewDir(positionWS));
                return o;
            }

            half4 frag (v2f i) : SV_TARGET
            {
                //half4 color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.texcoord);
                half4 color = half4(0, 0, 0, 1);
                
                //Rim Light
                half rim = 1.0 - saturate(dot(i.viewDirectionWS, i.normalWS.xyz));
                rim = pow(rim, 1);
                color.r = rim * 0.4;
                return color;
            }

            ENDHLSL
        }

        Pass // Pass 2
        {
            // BlendOp Add
            // Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
            #include "GaussianBlur.hlsl"

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

            // Horizontal blur fragment shader
            half4 frag(v2f input) : SV_Target
            {
                float2 texelSize = float2(1.0 / _TextureWidth, 1.0 / _TextureHeight);
                float4 result = 0;
                float sigma = _BlurRadius * 0.5; // Convert radius to sigma (approximation)
            
                half4 color = GaussianBlurSingle(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), texelSize, input.texcoord, sigma, _BlurRadius);
                return color;
            }
            ENDHLSL
        }

        Pass // Pass 3
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            TEXTURE2D_X(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D_X(_BlurTex);
            SAMPLER(sampler_BlurTex);

            TEXTURE2D_X(_EmptyMark);
            SAMPLER(sampler_EmptyMark);

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
                half4 base = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.texcoord);
                half4 blurTex = SAMPLE_TEXTURE2D(_BlurTex, sampler_BlurTex, input.texcoord);

                // half2 markUV = input.uv * 4;
                // //markUV = saturate(markUV);
                // half4 emptyMarkTex = SAMPLE_TEXTURE2D(_EmptyMark, sampler_EmptyMark, markUV);
                // return emptyMarkTex;

                half4 color = 0;
                color.rgb = lerp(base.r, 0.8, (1 - blurTex.a) * base.a);
                color.a = max(base.a, blurTex.a) * 0.8;


                half dim = 1 - blurTex.a + 0.8;

                //color.a = lerp(color.a, 0.3, dim);
                

                return color;
            }
            ENDHLSL
        }

        // Pass // Pass 4
        // {
        //     HLSLPROGRAM
        //     #pragma vertex Vert
        //     #pragma fragment frab
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

        //     TEXTURE2D_X(_MainTex);
        //     SAMPLER(sampler_MainTex);

        //     float4 frag(Varyings input) : SV_Target
        //     {
        //         half4 base = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, input.uv);
        //         half4 blurTex = SAMPLE_TEXTURE2D(_BlurTex, sampler_BlurTex, input.uv);

        //         half4 color = 0;

        //         color.rgb = lerp(base.r,1, blurTex.a);
        //         color.a = max(base.a, blurTex.a) * 0.8;

        //         return color;
        //     }
            
        //     ENDHLSL
        // }

        // Pass
        // {
        //     HLSLPROGRAM
        //     #pragma vertex Vert
        //     #pragma fragment InitFrag
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
        //     #include "GaussianBlur.hlsl"
        //     ENDHLSL
        // }

        // Pass
        // {
        //     HLSLPROGRAM
        //     #pragma vertex Vert
        //     #pragma fragment JumpFrag
        //     #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
        //     #include "GaussianBlur.hlsl"
        //     ENDHLSL
        // }
    }
    //FallBack "Hidden/Universal Render Pipeline/FallbackError"
}