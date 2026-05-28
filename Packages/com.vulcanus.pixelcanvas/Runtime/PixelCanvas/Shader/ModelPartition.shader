Shader "Vulcanus/PixelCanvas/ModelPartition"
{
    Properties
    {
        _MainTex ("Main Tex (vertical strip)", 2D) = "white" {}

        _StripeThickness ("Stripe Thickness", Range(0.01, 0.5)) = 0.5
        _StripeColor ("Stripe Color", Color) = (1, 1, 0, 1)

        _Thickness ("Thickness", Range(0.000001, 1)) = 0.5
        _Softness ("Line Softness", Range(0, 1)) = 0.1

        [Header(Render State)]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10
    }

    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend [_BlendScr] [_BlendDst], One One
            ZWrite On
            Cull Off
            //ZWrite Off

            HLSLPROGRAM

            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
			#include "Global.hlsl"
            #include "Common.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _StripeColor;
                half _StripeThickness;
                half _Thickness;
                half _Softness;
            CBUFFER_END

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float2 texcoord : TEXCOORD0;
                float4 positionSS : TEXCOORD1; 
                float4 objectPositionSS : TEXCOORD2; 
            
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                
                //v.vertex.z *= _DisappearRatio;
                //v.vertex.xyz += forward * (1 - _DisappearRatio);

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.texcoord = v.texcoord;


                half3 objectPositionWS = UNITY_MATRIX_M._14_24_34;
                half4 objectPositionCS = TransformWorldToHClip(objectPositionWS);
                o.objectPositionSS = ComputeScreenPos(objectPositionCS);
                o.positionSS = ComputeScreenPos(o.positionCS);
                return o;
            }

            half4 frag (v2f i, float cullFace : VFACE) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(i);

                //Screen Strip Pattern
				half2 screenSpaceUV = i.positionCS.xy / _ScreenParams.xy;

				screenSpaceUV.x *= _ScreenParams.x / _ScreenParams.y; //(x, y Ratio)
                float stripeMask = (screenSpaceUV.x - screenSpaceUV.y) + _Time.x * 0.3h;
                stripeMask /= _StripeThickness;
                stripeMask = frac(stripeMask);
                stripeMask = step(0.5h, stripeMask);

                //Partition Masking
                half2 beg = _PartitionMin;
                half2 end = _PartitionMax;
                half2 partitionSize = end - beg;
                half2 partitionHalfSize = partitionSize * 0.5f;
                half distance = SDFBox((i.texcoord) - beg - partitionHalfSize, partitionHalfSize);
                half partitionMask = 1 - step(distance, 0);
                half4 color = half4(_StripeColor.rgb * stripeMask, partitionMask * _PartitionLock);
                color.a = 0;

                return color;
            }

            ENDHLSL
        }
    }
}

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