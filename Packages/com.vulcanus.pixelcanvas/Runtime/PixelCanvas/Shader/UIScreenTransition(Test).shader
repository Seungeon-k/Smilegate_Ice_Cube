// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Vulcanus/UI/ScreenTransition(Test)"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        [Space(10)]
        _TransitionColor ("Transition Color", Color) = (1,1,1,1)
        [Toggle(_RANDOM_COLOR)] _RANDOM_COLOR ("Random Color(Off)", Float) = 0
        [IntRange]_PartitionXCount ("Partition X Count", Range(3, 30)) = 10
        _TransitionRatio ("Transition Ratio", Range(0.05, 1)) = 1
        _ProgressRatio ("Progress Ratio", Range(0, 1)) = 0

        [Space(10)]
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15


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
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
            #pragma shader_feature_local _ _RANDOM_COLOR

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
                float2 texcoord2 : TEXCOORD1;
                float4 worldPosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            half4 _Color;
            half _TransitionRatio;
            half4 _TransitionColor;
            half4 _TextureSampleAdd;
            float4 _ClipRect;
            half _PartitionXCount;
            half _ProgressRatio;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.texcoord2 = TRANSFORM_TEX(v.texcoord, _NoiseTex);
                OUT.color = v.color * _Color;
                return OUT;
            }

            half3 palette(in half3 a, in half3 b, in half3 c, in half3 d )
            {
                return a + b*cos( 6.283185*(_Time.x * c + d) );
            }


            float InverseLerp(float a, float b, float x)
            {
                return (x - a)/(b - a);
            }

            half4 frag(v2f IN) : SV_Target
            {                
                float partitionXCount = _PartitionXCount;
                float partitionSize = _ScreenParams.x / partitionXCount;
                float partitionYCount = _ScreenParams.y / partitionSize;

                // float2 vertex = IN.vertex.xy;
                // vertex.y -= _ScreenParams.y * 0.5;
                // float2 partitionUV = (int2)(vertex / partitionSize) / float2(partitionXCount, partitionYCount);
                // partitionUV = abs(partitionUV);
                // float2 fraction = frac(vertex.xy / partitionSize);
                // float2 distance = abs(fraction - 0.5);
                // float alpha = 0.500001 - (distance.x + distance.y);
                
                // half noise = tex2D(_NoiseTex, partitionUV).r;
                // //float uvFade = saturate(partitionUV.x + lerp(-1 - noise, 0.5 + noise, ratio));
                // //alpha -= uvFade;
                
                // float ratio = _ProgressRatio;
                // ratio = 1 - abs(ratio);
                // ratio *= (saturate(partitionUV.x + lerp(-1 - noise, 0.5 + noise, ratio)) + 1);
                
                // alpha = 0.500001 - (lerp(distance.x, 0.500001, ratio) + distance.y);
                // float mask = step(0, alpha);
                
                // if (0.5 < _ProgressRatio)
                //     clip(0.000001 - alpha);
                
                // alpha *= alpha;
                // alpha = alpha * mask;
                // alpha = step(0.000001, alpha);

                
                // color.rgb *= alpha;
                // //return half4(alpha, 0, 0, 1);
                // return color;



// //사각형====================================================================================================================
//                  float time = 5;
//                  _ProgressRatio = (_Time.z % time) / time;

//                 float2 vertex = IN.vertex.xy;
//                 vertex.y -= _ScreenParams.y * 0.5;
//                 float2 partitionUVA = (int2)(vertex / partitionSize) / float2(partitionXCount, partitionYCount);
//                 partitionUVA = abs(partitionUVA);
//                 float2 fractionA = frac(vertex.xy / partitionSize);
//                 float2 distanceA = abs(fractionA - 0.5);
//                 half noise = tex2D(_NoiseTex, partitionUVA).r;
//                 float uvFadeA = saturate(partitionUVA.x + lerp(-1, 1, _ProgressRatio));
//                 uvFadeA *= lerp(0, 1 - partitionUVA.y, uvFadeA);

//                 float ratio = _ProgressRatio * lerp(0, 3, uvFadeA) * _Multiply;// * lerp(1, 3, noise);
//                 float ratio_101 = ratio;
//                 ratio_101 -= 0.5;
//                 ratio_101 *= 2;
//                 ratio_101 = 1 - abs(ratio_101);
//                 ratio_101 = saturate(ratio_101);
                
//                 float alpha = 0.5001 - max(distanceA.x, distanceA.y);
//                 //return half4(alpha, 0, 0, 1);
//                 alpha -= ratio_101;
//                 //return half4(alpha, 0, 0, 1);

//                 if (ratio < 0.5)
//                 {
//                     alpha = step(0.000001, alpha);
//                  //   return half4(ratio_101, 0, 0, 1);
//                 }
//                 else
//                 {
//                     alpha = step(0.000001, alpha);
//                     clip(0.00001 - alpha);
//                 }

//                 #if _RANDOM_COLOR
//                     half3 col = palette(half3(0.5, 0.5, 0.5), half3(0.5, 0.5, 0.5), half3(1.0, 1.0, 1.0), half3(0.00, 0.33, 0.67));
//                     color.rgb = lerp(col, color.rgb, alpha);
//                 #else
//                     color.rgb = lerp(_TransitionColor, color.rgb, alpha);
//                 #endif
                
//                 return color;
// //====================================================================================================================

// //사각형2====================================================================================================================
//                  float time = 5;
//                  _ProgressRatio = (_Time.z % time) / time;

//                 float2 vertex = IN.vertex.xy;
//                 vertex.y -= _ScreenParams.y * 0.5;
//                 float2 partitionUVA = (int2)(vertex / partitionSize) / float2(partitionXCount, partitionYCount);
//                 partitionUVA = abs(partitionUVA);
//                 float2 fractionA = frac(vertex.xy / partitionSize);
//                 float2 distanceA = abs(fractionA - 0.5);
//                 half noise = tex2D(_NoiseTex, partitionUVA).r;
//                 float uvFadeA = saturate(partitionUVA.x + lerp(-1, 1, _ProgressRatio));
//                 uvFadeA *= lerp(0, 1 - partitionUVA.y, uvFadeA);

//                 float ratio = _ProgressRatio * lerp(0, 3, uvFadeA) * _Multiply;// * lerp(1, 3, noise);
//                 float ratio_101 = ratio;
//                 ratio_101 -= 0.5;
//                 ratio_101 *= 2;
//                 ratio_101 = 1 - abs(ratio_101);
//                 ratio_101 = saturate(ratio_101);
                
//                 //float alpha = 0.5001 - (distanceA.x + distanceA.y * ratio_101);
//                 float alpha = 0.5001 - max(distanceA.x + ratio_101 , distanceA.y);
//                  alpha -= ratio_101;

//                 if (ratio < 0.5)
//                 {
//                     alpha = step(0.000001, alpha);
//                  //   return half4(ratio_101, 0, 0, 1);
//                 }
//                 else
//                 {
//                     alpha = step(0.000001, alpha);
//                     clip(0.00001 - alpha);
//                 }

//                 #if _RANDOM_COLOR
//                     half3 col = palette(half3(0.5, 0.5, 0.5), half3(0.5, 0.5, 0.5), half3(1.0, 1.0, 1.0), half3(0.00, 0.33, 0.67));
//                     color.rgb = lerp(col, color.rgb, alpha);
//                 #else
//                     color.rgb = lerp(_TransitionColor, color.rgb, alpha);
//                 #endif
                
//                 return color;
// //====================================================================================================================

//사각형3====================================================================================================================
//                 float time = 5;
//                 _ProgressRatio = (_Time.z % time) / (time - 1);
//                 _ProgressRatio = saturate(_ProgressRatio);

//                 // float2 vertex = IN.vertex.xy;
//                 // vertex.y -= _ScreenParams.y * 0.5;
//                 // float2 partitionUVA = (int2)(vertex / partitionSize) / float2(partitionXCount, partitionYCount);
                
//                 // partitionUVA = abs(partitionUVA);
//                 // half noise = tex2D(_NoiseTex, partitionUVA).r;
//                 // return half4(partitionUVA, 0, 1);
//                 // return half4(noise, 0, 0, 1);

//                 // float2 fractionA = frac(vertex.xy / partitionSize);
//                 // float2 distanceA = abs(fractionA - 0.5);

//                 //float uvFadeA = saturate(partitionUVA.x + lerp(-1, 1, _ProgressRatio));
//                 //uvFadeA *= lerp(0, 1 - partitionUVA.y, uvFadeA);
                
//                 float2 vertex = IN.vertex.xy;
//                 vertex.x += partitionSize * 0.5;
//                 vertex.y -= _ScreenParams.y * 0.5;
//                 vertex.y = abs(vertex.y) + (partitionSize * 0.5);
//                 float2 partitionUVA = (vertex / partitionSize);
//                 partitionUVA = (int2)partitionUVA;
//                 partitionUVA /= float2(partitionXCount, partitionYCount);
//                 partitionUVA = abs(partitionUVA);
//                 float2 fractionA = frac(vertex.xy / partitionSize);
//                 //float2 distanceA = abs(fractionA - 0.5001);
//                 float2 distanceA = abs(fractionA - 0.5001);

//                 float2 vertex2 = IN.vertex.xy;
//                 vertex2.x += partitionSize * 0.5;
//                 vertex2.y += (1 - frac(partitionYCount)) * partitionSize * 0.5;
//                 float2 noiseUV = (vertex2 / partitionSize);
//                 noiseUV = (int2)noiseUV;
//                 noiseUV /= float2(partitionXCount, partitionYCount);
//                 half noise = tex2D(_NoiseTex, noiseUV).r;
//                 noise = clamp(noise, 0, 1 - _TransitionRatio);

//                 float tMin = noise;
//                 float tMax = noise + _TransitionRatio;
//                 float ratio = saturate(InverseLerp(tMin, tMax, _ProgressRatio));
//                 ratio -= 0.5;
//                 ratio *= 2;
//                 float s = sign(ratio);
//                 ratio *= ratio;
//                 ratio *= ratio;
//                 ratio *= s;
                
//                 //float alpha = abs(0.501 * ratio) - (distanceA.x * distanceA.y);
//                 float alpha = min(abs(0.501 * ratio) - distanceA.x, distanceA.y);
//                 //float alpha = min(abs(0.501 * ratio) - distanceA.x, distanceA.y);
//                 //float alpha = 0.5001 - (distanceA.x + distanceA.y * ratio);
//                 //float alpha = 0.500001 - (distanceA.x + distanceA.y) * ratio;
                
//                 //return half4(alpha, 0, 0, 1);
//                 //clip(0.000001 - (alpha * s));
//                 if (0 < ratio)
//                     clip(0.000001 - alpha);

//                 alpha = step(0.000001, alpha);


//                 half4 color = (tex2D(_MainTex, IN.texcoord * alpha) + _TextureSampleAdd) * IN.color;
                
// #ifdef UNITY_UI_CLIP_RECT
//                 color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
// #endif
                
// #ifdef UNITY_UI_ALPHACLIP
//                 clip (color.a - 0.001);
// #endif

//                 #if _RANDOM_COLOR
//                     half3 col = palette(half3(0.5, 0.5, 0.5), half3(0.5, 0.5, 0.5), half3(1.0, 1.0, 1.0), half3(0.00, 0.33, 0.67));
//                     color.rgb = lerp(col, color.rgb, alpha);
//                 #else
//                     color.rgb = lerp(_TransitionColor, color.rgb, alpha);
//                 #endif
                
//                 return color;
//====================================================================================================================

//마름모====================================================================================================================
                //  float time = 5;
                //  _ProgressRatio = (_Time.z % time) / time;

                //  half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                
                //  #ifdef UNITY_UI_CLIP_RECT
                //                  color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
                //  #endif
                                 
                //  #ifdef UNITY_UI_ALPHACLIP
                //                  clip (color.a - 0.001);
                //  #endif


                // float2 vertex = IN.vertex.xy;
                // vertex.y -= _ScreenParams.y * 0.5;
                // float2 partitionUVA = (int2)(vertex / partitionSize) / float2(partitionXCount, partitionYCount);
                // partitionUVA = abs(partitionUVA);
                // float2 fractionA = frac(vertex.xy / partitionSize);
                // float2 distanceA = abs(fractionA - 0.5);
                // half noise = tex2D(_NoiseTex, partitionUVA).r;
                // float uvFadeA = saturate(partitionUVA.x + lerp(-1, 1, _ProgressRatio));
                // uvFadeA *= lerp(0, 1 - partitionUVA.y, uvFadeA);
                
                // float ratio = _ProgressRatio * lerp(0, 3, uvFadeA); // * lerp(1, 3, noise);
                // float ratio_101 = ratio;
                // ratio_101 -= 0.5;
                // ratio_101 *= 2;
                // ratio_101 = 1 - abs(ratio_101);
                // ratio_101 = saturate(ratio_101);
                
                // float alpha = 0.5001 - (distanceA.x + distanceA.y);
                // alpha -= ratio_101;
                // //alpha = 0.5001 - (lerp(distanceA.y, 0.5001, ratio_101) + distanceA.x);
                // //float mask = step(0, alpha = 0.5001 - (lerp(distanceA.x, 0.5001, ratio_101) + distanceA.y));
                // if (ratio < 0.5)
                // {
                //     alpha = step(0.000001, alpha);
                // }
                // else
                // {
                //     alpha = step(0.000001, alpha);
                //     clip(0.00001 - alpha);
                // }

                // float2 vertexB = IN.vertex.xy;
                // vertexB.x += partitionSize * 0.5;
                // vertexB.y -= _ScreenParams.y * 0.5;
                // vertexB.y = abs(vertexB.y) + (partitionSize * 0.5);
                // float2 partitionUVB = (vertexB / partitionSize);
                // partitionUVB = abs(partitionUVB);
                // partitionUVB = (int2)partitionUVB;
                // partitionUVB /= float2(partitionXCount, partitionYCount);
                // float2 fractionB = frac(vertexB.xy / partitionSize);
                // float2 distanceB = abs(fractionB - 0.5001);
                // noise = tex2D(_NoiseTex, partitionUVB).r;
                // float uvFadeB = saturate(partitionUVB.x + lerp(-1, 1, _ProgressRatio));
                // uvFadeB *= lerp(0, 1 - partitionUVB.y, uvFadeB);

                // ratio = _ProgressRatio * lerp(0, 3, uvFadeB);// * lerp(1, 3, noise);
                // ratio_101 = ratio;
                // ratio_101 -= 0.5;
                // ratio_101 *= 2;
                // ratio_101 = 1 - abs(ratio_101);
                // ratio_101 = saturate(ratio_101);

                // float alpha2 = 0.5001 - (distanceB.x + distanceB.y);
                // alpha2 -= ratio_101;
                // if (ratio < 0.5)
                // {
                //     alpha2 = step(0.000001, alpha2);
                // }
                // else
                // {
                //     //alpha2 = step(0.000001, alpha2);
                //     clip(0.00001 - alpha2);
                // }

                // alpha = max(alpha, alpha2);

                // #if _RANDOM_COLOR
                //     half3 col = palette(half3(0.5, 0.5, 0.5), half3(0.5, 0.5, 0.5), half3(1.0, 1.0, 1.0), half3(0.00, 0.33, 0.67));
                //     color.rgb = lerp(col, color.rgb, alpha);
                // #else
                //     color.rgb = lerp(_TransitionColor, color.rgb, alpha);
                // #endif
                
                // return color;
//====================================================================================================================

//마름모2====================================================================================================================
                float time = 5;
                _ProgressRatio = (_Time.z % time) / (time - 1);
                _ProgressRatio = saturate(_ProgressRatio);

                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                
#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
#endif
                
#ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
#endif
                
                float2 vertex = IN.vertex.xy;
                vertex.y -= _ScreenParams.y * 0.5;
                float2 partitionUV = (int2)(vertex / partitionSize) / float2(partitionXCount, partitionYCount);
                partitionUV = abs(partitionUV);
                half noise = tex2D(_NoiseTex, partitionUV).r;
                half2 fraction = frac(vertex / partitionSize);
                half2 distance = abs(fraction - 0.5);
                half uvFade = saturate(partitionUV.x + lerp(-1 - noise, 0.5 + noise, _ProgressRatio));
                half alpha = 0.501 - (distance.x + distance.y);
                alpha -= uvFade;
                alpha = step(0, alpha);
                
                vertex = IN.vertex.xy;
                vertex.x += partitionSize * 0.5;
                vertex.y -= _ScreenParams.y * 0.5;
                vertex.y = abs(vertex.y) + (partitionSize * 0.5);
                partitionUV = (vertex / partitionSize);
                partitionUV = abs(partitionUV);
                partitionUV = (int2)partitionUV;
                partitionUV /= float2(partitionXCount, partitionYCount);
                noise = tex2D(_NoiseTex, partitionUV).r;
                fraction = frac(vertex / partitionSize);
                distance = abs(fraction - 0.5);
                uvFade = saturate(partitionUV.x + lerp(-1 - noise, 0.5 + noise, _ProgressRatio)) * lerp(1, 0, partitionUV.y);
                half alpha2 = 0.501 - (distance.x + distance.y);
                alpha2 -= uvFade;
                alpha2 = step(0, alpha2);

                alpha += alpha2;
                clip(alpha - 0.001);

                return color;
//====================================================================================================================




                // if (ratio < 0)
                // {
                //     ratio = 1 - abs(ratio);
                //     float uvFade = saturate(partitionUV.x + lerp(-1, 1, ratio));
                //     //ratio *= (saturate(partitionUV.x *  + lerp(-1 - noise, 0.5 + noise, ratio)) + 1);
                    
                //     uvFade = 1 - pow(2, -10 * uvFade);
                //     //uvFade *= 5;
                //     // uvFade *=  uvFade;
                //     // uvFade *=  uvFade;
                //     // uvFade *=  uvFade;
                //     // uvFade *=  uvFade;
                //     // uvFade *=  uvFade;
                //     return half4(uvFade, 0, 0, 1);
                //     // uvFade *= uvFade;
                //     //return half4(uvFade, 0, 0, 1);

                //     alpha = 0.500001 - (lerp(distance.x, 0.500001, ratio * uvFade) + distance.y);
                //     float mask = step(0, alpha);
                    
                //     if (0.5 < _ProgressRatio)
                //         clip(0.000001 - alpha);
                    
                //     //alpha *= alpha;
                //     alpha = alpha * mask;
                //     alpha = step(0.000001, alpha);
                // }
                // else
                // {
                //     float uvFade = saturate(partitionUV.x + lerp(-1, 1, ratio));
                //     //ratio *= (saturate(partitionUV.x *  + lerp(-1 - noise, 0.5 + noise, ratio)) + 1);

                //     uvFade = 1 - pow(2, -10 * uvFade);
                //     //uvFade *= 5;
                //     // uvFade *= uvFade;
                //     //return half4(uvFade, 0, 0, 1);

                //     alpha = 0.500001 - (lerp(0.500001, distance.x, saturate(ratio * uvFade)) + distance.y);
                //     float mask = step(0, alpha);
                    
                //     clip(0.000001 - alpha);
                    
                //     //alpha *= alpha;
                //     //alpha = alpha * mask;
                //     alpha = step(0.000001, alpha);
                // }

                
                //color.rgb *= alpha;
                //return half4(alpha, 0, 0, 1);
                //return color;





                // //alpha = abs(alpha);
                
                // vertex = IN.vertex.xy;
                // vertex.x += partitionSize * 0.5;
                // vertex.y -= _ScreenParams.y * 0.5;
                // vertex.y = abs(vertex.y) + (partitionSize * 0.5);
                // partitionUV = (vertex / partitionSize);
                // partitionUV = abs(partitionUV);
                // partitionUV = (int2)partitionUV;
                // partitionUV /= float2(partitionXCount, partitionYCount);
                // noise = tex2D(_NoiseTex, partitionUV).r;
                // fraction = frac(vertex.xy / partitionSize);
                // distance = abs(fraction - 0.5);
                // uvFade = saturate(partitionUV.x + lerp(-1 - noise, 0.5 + noise, _ProgressRatio)) * lerp(1, 0, partitionUV.y);
                // float alpha2 = 0.5001 - (distance.x + distance.y);
                // alpha2 -= uvFade;
                // alpha2 = step(0, alpha2);

                // alpha += alpha2;
                // clip(alpha - 0.001);
            }
        ENDCG
        }
    }
}


// if (xDistance + yDistance + IN.texcoord.x + IN.texcoord.y > _ProgressRatio * 4.0f) 
//     discard;

// float alpha3 = ((1 - _ProgressRatio)) - ((xDistance + yDistance));
// alpha3 = step(0, alpha3);
// color.a = alpha3;