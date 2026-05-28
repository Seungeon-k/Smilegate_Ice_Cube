Shader "Vulcanus/PixelCanvas/UVOutline"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15

        _LineStripeScale ("Line Stripe Scale", Float) = 100
        _Thickness ("Line Thickness", Range(0.0001, 1)) = 0.9
        _Softness ("Line Softness", Range(0, 1)) = 0.1

        _SDFThickness ("SDF Thickness", Range(0.000001, 1)) = 0.5
        _SDFSoftness ("SDF Softness", Range(0, 1)) = 0.1

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "UV Outline"
            HLSLPROGRAM
            
            #pragma exclude_renderers gles gles3 glcore 
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 4.5

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Global.hlsl"
            #include "Common.hlsl"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                half4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            TEXTURE2D_X(_MainTex);
            SAMPLER(sampler_MainTex);
            half4 _Color;
            half4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            half _LineStripeScale;             
            half _Thickness;
            half _Softness;
            half _SDFThickness;
            half _SDFSoftness;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = TransformObjectToHClip(OUT.worldPosition);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                //OUT.texcoord.xy = lerp(_Partition.xy, _Partition.zw, OUT.texcoord.xy);

                OUT.color = v.color * _Color;
                return OUT;
            }

            half4 frag(v2f IN) : SV_Target
            {
                half4 color = (SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                half4 seedColor = SAMPLE_TEXTURE2D_X(_SeedTex, sampler_SeedTex, IN.texcoord) + _TextureSampleAdd;
                half luminance = 0.299h * seedColor.r + 0.587h * seedColor.g + 0.114h * seedColor.b;

                float alpha = color.r;
                alpha = smoothstep(1 - _SDFThickness - _SDFSoftness, 1 - _SDFThickness + _SDFSoftness, alpha);
                //alpha = step(0.0001h, alpha);
                //return half4(alpha, 0, 0, 1);

                //Partition Masking
                half2 beg = _PartitionMin;
                half2 end = _PartitionMax;
                half2 partitionSize = end - beg;
                half2 partitionHalfSize = partitionSize * 0.5f;
                half distance = SDFBox(IN.texcoord - beg - partitionHalfSize, partitionHalfSize);
                half region = step(distance, 0);

                half stripe = IN.texcoord.x - (IN.texcoord.y - _Time.x * 0.3h);
                stripe *= _LineStripeScale;
                stripe = frac(stripe);
                stripe = step(0.5h, stripe);
                alpha *= stripe * region; 

                half3 lineColor = step(luminance, 0.5h);
                return half4(lineColor, alpha);
                
                // //Origin Source
                // half diffX = abs(ddx(color.a));
                // half diffY = abs(ddy(color.a));
                // half alpha = diffX + diffY;
                // alpha = step(0.0001h, alpha);
                
                // half stripe = IN.texcoord.x - (IN.texcoord.y - _Time.x * 0.3h);
                // stripe *= _LineStripeScale;
                // stripe = frac(stripe);
                // stripe = step(0.5h, stripe);
                // alpha *= stripe; 

                // half3 lineColor = step(luminance, 0.5h);

                // return half4(lineColor, alpha);



//                 float a = color.r;

//                 float2 gradient = float2(ddx(a), ddy(a));

//                 float gradientLength = length(gradient);

//                 float pixelsFromEdge = (a - 0.5f + _Thickness) / gradientLength;

//                 float t = smoothstep(0, 1, pixelsFromEdge + 0.5f);
// return half4(t, 0, 0, 1);


                // float distAlphaMask = baseColor.a; 
                // if ( OUTLINE &&
                //     (distAlphaMask >= OUTLINE_MIN_VALUE0 ) &&
                //     (distAlphaMask <= OUTLINE_MAX_VALUE1 ) )
                //     {
                //     fl o a t o F a c t o r = 1 . 0 ;
                //     i f ( di st Al p h aM a s k <= OUTLINE MIN VALUE1 )
                //     {
                //     o F a c t o r = s m o ot h st e p ( OUTLINE MIN VALUE0 ,
                //     OUTLINE MIN VALUE1 ,
                //     di st Al p h aM a s k ) ;
                //     }
                //     e l s e
                //     {
                //     o F a c t o r = s m o ot h st e p ( OUTLINE MAX VALUE1 ,
                //     OUTLINE MAX VALUE0 ,
                //     di st Al p h aM a s k ) ;
                //     }
                //     b a s e C ol o r = l e r p ( b a s eC ol o r , OUTLINE COLOR , o F a c t o r ) ;
                //     }
                //     i f ( SOFT EDGES ) {
                //     b a s e C ol o r . a ∗= s m o ot h st e p ( SOFT EDGE MIN ,
                //     SOFT EDGE MAX ,
                //     di st Al p h aM a s k ) ;
                //     } e l s e {
                //     b a s e C ol o r . a = di st Al p h aM a s k >= 0 . 5 ;
                //     } i f ( OUTER GLOW ) {
                //     f l o a t 4 gl owT e x el =
                //     tex2D ( B a s eT e xt u r e S am pl e r ,
                //     i . ba seTe xC o o r d . xy+GLOW UV OFFSET ) ;
                //     f l o a t 4 glowc = OUTER GLOW COLOR ∗ s m o ot h st e p (
                //     OUTER GLOW MIN DVALUE,
                //     OUTER GLOW MAX DVALUE,
                //     gl owT e x el . a ) ;
                //     b a s e C ol o r = l e r p ( glowc , b a s eC ol o r , mskUsed ) ;
                //     }




//                 float sdf = color;
//                 //sdf *= 4;
//                 //sdf *= 2;
//                 sdf = saturate(sdf);

//                 // if (0.9 < sdf )
//                 //     return half4(0, 0, 1, 1);
//                 // else if (0.8 < sdf )
//                 //     return half4(0, 1, 0, 1);
//                 // else if (0.7 < sdf )
//                 //     return half4(0, 1, 1, 1);
//                 // else if (0.6 < sdf )
//                 //     return half4(1, 0, 1, 1);
//                 // else if (0.5 < sdf )
//                 //     return half4(1, 1, 0, 1);

//                 // return half4(sdf, 0, 0, 1);

//                 // sdf -= 1 - _Thickness;

//                 // sdf = step(0, sdf);


//                 sdf = smoothstep(1 - _Thickness - _Softness, 1 - _Thickness + _Softness, sdf);
// //                sdf = smoothstep(0.5 - _Thickness - _Softness, 0.5 - _Thickness + _Softness, sdf);
//                 //sdf = smoothstep(0.5 - _Softness, 0.5 + _Softness, sdf);
//                 //sdf = smoothstep(1 - _Thickness, 1 - _Thickness, sdf);
//                 sdf = abs(sdf);
//                 return half4(sdf, 0, 0, 1);
                    
            }
        ENDHLSL
        }
    }
}