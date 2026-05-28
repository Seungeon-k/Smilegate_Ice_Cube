Shader "Vulcanus/PixelCanvas/PaintBoard3dModel"
{
    Properties
    {
        _MainTex ("Main Tex (vertical strip)", 2D) = "white" {}

        _StripeThickness ("Stripe Thickness", Range(0.01, 0.5)) = 0.5
        _StripeColor ("Stripe Color", Color) = (1, 1, 0, 1)

        _IndicatorThickness ("Indicator Thickness", Range(1, 10)) = 0.5

        [Header(Render State)]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10
    }

    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend [_BlendScr] [_BlendDst], One One
            //ZWrite Off
            Cull Off

            HLSLPROGRAM

            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Common.hlsl"
            #include "Global.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _StripeColor;
                half _StripeThickness;
                half _IndicatorThickness;
            CBUFFER_END

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float3 viewDirectionWS : TEXCOORD1;
                float4 centerPositionCS : TEXCOORD2;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.normalWS = TransformObjectToWorldDir(v.normal);
                o.texcoord = v.texcoord;
                o.viewDirectionWS = normalize(GetWorldSpaceViewDir(positionWS));
                o.centerPositionCS = TransformWorldToHClip(UNITY_MATRIX_M._14_24_34);
                return o;
            }

            half4 frag (v2f i, half cullFace : VFACE) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(i);

                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                half luminance = 0.299f * color.r + 0.587f * color.g + 0.114f * color.b;
                half4 contrastColor = half4(step(luminance, 0.5f).rrr, 1);

                //Screen Strip Pattern
                half2 screenSpaceUV = i.positionCS.xy / _ScreenParams.xy;
                screenSpaceUV.y = 1 - screenSpaceUV.y;
                half2 localScreenUV = (screenSpaceUV * 2.0 - 1.0) * i.centerPositionCS.w - i.centerPositionCS.xy;
                localScreenUV.x *= _ScreenParams.x / _ScreenParams.y;
                localScreenUV *= -1.0 / UNITY_MATRIX_P[1][1];
                localScreenUV.y *= -1;
                
                float stripeMask = localScreenUV.x - (localScreenUV.y - _Time.x * 0.3);
                stripeMask /= _StripeThickness;
                stripeMask = frac(stripeMask);
                stripeMask = step(0.5h, stripeMask);

                //Partition Masking
                float timerRatio = saturate((_Time.y - _PartitionChangedTime) * 5);
                half2 partitionSize = _PartitionMax - _PartitionMin;
                half2 partitionHalfSize = partitionSize * 0.5f;
                half distance = SDFBox(i.texcoord - _PartitionMin - partitionHalfSize, partitionHalfSize);
                half partitionMask = (step(distance, 0));
                
                partitionSize = _PrvPartitionMax - _PrvPartitionMin;
                partitionHalfSize = partitionSize * 0.5f;
                distance = SDFBox(i.texcoord - _PrvPartitionMin - partitionHalfSize, partitionHalfSize);
                half prvPartitionMask = (step(distance, 0));
                partitionMask = lerp(prvPartitionMask, partitionMask, timerRatio);
                partitionMask = 1 - partitionMask;
                color.rgb = lerp(color.rgb, _StripeColor.rgb * stripeMask, partitionMask * _PartitionLock);

                //Grid
                float2 gridUV = i.texcoord * _SeedTextureSize;
                gridUV = frac(gridUV);
                gridUV = (gridUV - 0.5) * 2;
                gridUV *= gridUV;
                gridUV *= gridUV;
                gridUV *= 0.85;
                gridUV = 1 - gridUV;
                half gridRatio = (1 - saturate(gridUV.x + gridUV.y));
                color = lerp(color, contrastColor, gridRatio);

                // //Brush Indicator
                half indicatorThickness = ((1.0 / 6400) * _IndicatorThickness);
                half brushRadius = _BrushThickness * 0.5f;
                half2 preBrushUV = (int2)(_CurPosition * _SeedTextureSize) + (sign(_CurPosition) * 0.5);
                half2 curBrushUV = (int2)(_CurPosition * _SeedTextureSize) + (sign(_CurPosition) * 0.5);

                half count = 0;
                for (int idx=0 ; idx<5 ; ++idx)
                {
                    half2 offset = BRUSH_INDICATOR_OFFSET[idx] * indicatorThickness;
                    half2 uv = i.texcoord + offset;
                    half2 nUV = (int2)(uv * _SeedTextureSize) + 0.5;

                    half dist = SDFLine(preBrushUV, curBrushUV, nUV);
                    //dist = 1 - ((dist - brushRadius) / 0);
                    dist = 1 - (dist / brushRadius);
                    count += step(0.000001, dist);
                    //count += step(0.000001, 1 - (dist / brushRadius));
                }

                half brushIndicatorMask = count / 5.0;
                brushIndicatorMask = (1 - step(brushIndicatorMask, 0)) * (1 - step(1, brushIndicatorMask));
                half brushLuminance = 0.299f * _BrushColor.r + 0.587f * _BrushColor.g + 0.114f * _BrushColor.b;
                half brushContrast = step(brushLuminance, 0.5f);
                color.rgb = lerp(color.rgb, brushContrast, brushIndicatorMask * _BrushIndicatorVisible);
                color = saturate(color);

                //Special Back Face
                half alphaclip;
                cullFace = saturate(cullFace);
                Unity_Dither_positionCS(0.85, i.positionCS.xy , alphaclip);
                //color.rgb = lerp(_StripeColor.rgb * stripeMask, color.rgb, cullFace);
                clip(alphaclip + cullFace - 0.001);
                half3 cullColor = lerp(half3(0, 0, 0), _StripeColor.rgb, stripeMask);
                color.rgb = lerp(cullColor, color.rgb, cullFace);

                //Rim Light
                half rim = (1.0 - saturate(dot(i.viewDirectionWS, i.normalWS.xyz)));
                rim = pow(rim, 10);
                color.rgb = lerp(color.rgb, contrastColor.rgb, rim * cullFace);
                //color.rgb = lerp(color.rgb, 0.5, rim * cullFace);

                return color;
            }

            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}


/*
// float rawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV).r;
// half linearDepth = LinearEyeDepth(rawDepth, _ZBufferParams);

half depth = i.positionCS.z;
depth -= 0.95;
depth = saturate(depth);
depth /= 0.05;

//color.rgb = lerp(color.rgb, half3(0, 0, 0), depth);
*/

                // float _LineThickness = 0.03;
                // float _LineStripeScale = 100;

                // half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                // //half UVOutline = 1 - SAMPLE_TEXTURE2D(_UVOutlineTex, sampler_UVOutlineTex, i.texcoord).r;
                // half UVOutline = SAMPLE_TEXTURE2D(_UVOutlineTex, sampler_UVOutlineTex, i.texcoord).r;
                // // half UVOutline1 = 1 - SAMPLE_TEXTURE2D(_UVOutlineTex, sampler_UVOutlineTex, i.texcoord + float2(0.001, 0)).r;
                // // half UVOutline2 = 1 - SAMPLE_TEXTURE2D(_UVOutlineTex, sampler_UVOutlineTex, i.texcoord + float2(0, 0.001)).r;
                // // half UVOutline3 = 1 - SAMPLE_TEXTURE2D(_UVOutlineTex, sampler_UVOutlineTex, i.texcoord + float2(0.001, 0.001)).r;
                
                
                // float alpha = UVOutline;
                // alpha = smoothstep(1 - _Thickness - _Softness, 1 - _Thickness + _Softness, alpha);
                // alpha = step(0.1, alpha);
                
                // // half diffX = abs(ddx(UVOutline));
                // // half diffY = abs(ddy(UVOutline)); 
                // // half alpha = diffX + diffY;
                // // half t = abs(ddx(alpha));
                
                // //alpha = step(0.000001h, alpha);
                
                // half _LineStripeScale = 300;
                // half stripe = i.texcoord.x - (i.texcoord.y - _Time.x * 0.3h);
                // stripe *= _LineStripeScale;
                // stripe = frac(stripe);
                // stripe = step(0.5h, stripe);
                // alpha *= stripeMask; 

                // half luminance = 0.299h * color.r + 0.587h * color.g + 0.114h * color.b;
                // half3 lineColor = step(luminance, 0.5h);

                // return half4(lineColor, alpha);










                // half _LineStripeScale = 100;
                // half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                // half UVOutline = 1 - SAMPLE_TEXTURE2D(_UVOutlineTex, sampler_UVOutlineTex, i.texcoord).r;

                // half diffX = abs(ddx(UVOutline));
                // half diffY = abs(ddy(UVOutline)); 
                // half alpha = diffX + diffY;
                // alpha = step(0.000001h, alpha);

                // half stripe = i.texcoord.x - (i.texcoord.y - _Time.x * 0.3h);
                // stripe *= _LineStripeScale;
                // stripe = frac(stripe);
                // stripe = step(0.5h, stripe);
                // alpha *= stripe; 

                // half luminance = 0.299h * color.r + 0.587h * color.g + 0.114h * color.b;
                // half3 lineColor = step(luminance, 0.5h);
                // return half4(lineColor, alpha);

                
                // // float lineMask = saturate(1 + distance) * region;
                // // lineMask = step(1 - _LineThickness, lineMask);
                // // float stripe = i.texcoord.x - (i.texcoord.y - _Time.x);
                // // stripe *= _LineStripeScale;
                // // stripe = frac(stripe);
                // // stripe = step(0.5, stripe);
                // // // float3 lineColor = lerp(color.rgb * 0.5, _LineColor.rgb, stripe);
                // // // color.rgb = lerp(color.rgb, lineColor, lineMask);
                // // float3 lineColor = step(luminance, 0.5f);
                // // //var contrastColor = (luminance > 0.5f) ? new Color(0, 0, 0, 1) : new Color(1, 1, 1, 1);
                // // color.rgb = lerp(color.rgb, lineColor, lineMask * stripe);
                // // color.rgb *= clamp(region, 0.1, 1);
                // // // //return color;





                // float _LineThickness = 0.03;
                // float _LineStripeScale = 100;

                // float4 partition = _Partition;
                // float2 beg = partition.xy;
                // float2 end = partition.zw;
                // float2 partitionSize = partition.zw - partition.xy;
                // float2 partitionHalfSize = partitionSize * 0.5f;
                // float distance = SDFBox((i.texcoord) - beg - partitionHalfSize, partitionHalfSize);
                // float region = step(distance, 0);
                // float lineMask = saturate(1 + distance) * region;
                // lineMask = step(1 - _LineThickness, lineMask);
                // float stripe = i.texcoord.x - (i.texcoord.y - _Time.x);
                // stripe *= _LineStripeScale;
                // stripe = frac(stripe);
                // stripe = step(0.5, stripe);
                // // float3 lineColor = lerp(color.rgb * 0.5, _LineColor.rgb, stripe);
                // // color.rgb = lerp(color.rgb, lineColor, lineMask);
                // half luminance = 0.299f * color.r + 0.587f * color.g + 0.114f * color.b;
                // float3 lineColor = step(luminance, 0.5f);
                // //var contrastColor = (luminance > 0.5f) ? new Color(0, 0, 0, 1) : new Color(1, 1, 1, 1);
                // color.rgb = lerp(color.rgb, lineColor, lineMask * stripe);
                // color.rgb *= clamp(region, 0.1, 1);
                // return color;