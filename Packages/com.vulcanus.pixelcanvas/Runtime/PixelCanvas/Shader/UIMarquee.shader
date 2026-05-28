
Shader "Vulcanus/PixelCanvas/Marquee"
{
    Properties
    { 
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {}

        [Header(Blend State)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("└─Src", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("└─Dst", Float) = 0.0
        [Header(Render State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("└─Cull", Float) = 2.0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("└─ZTest", Float) = 4.0
        [Enum(Off,0,On,1)] _ZWrite("└─ZWrite", Float) = 1.0

        _BlinkTime("Blink Time", Range(0.1, 2)) = 1.0
        [IntRange] _BlinkCount("Blink Count", Range(1, 5)) = 2.0
        [IntRange] _PatternThickness("Pattern Thickness", Range(0, 100)) = 1.0
        [IntRange] _BoarderThickness("Boarder Thickness", Range(0, 100)) = 1.0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline" "IgnoreProjector" = "True"}
        
        Pass
        {
            Cull Back
            ZWrite Off
            Blend[_SrcBlend][_DstBlend]
            ZTest[_ZTest]
            ZWrite[_ZWrite]
            Cull[_Cull]
            
            HLSLPROGRAM
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            //#pragma prefer_hlslcc gles
            //#pragma exclude_renderers d3d11_9x  
            #pragma target 4.5
            #pragma vertex vert
            #pragma fragment frag
            
            CBUFFER_START(UnityPerMaterial)
                float4 _RectSize;
                int _PatternThickness;
                int _BoarderThickness;
                int _BlinkCount;
                half _BlinkTime;
                half _EventTime;
            CBUFFER_END
            
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 positionSS : TEXCOORD0;
                float4 centerPositionSS : TEXCOORD1;
                float2 uv : TEXCOORD2;
                half pulseRatio : TEXCOORD3;
            }; 

            TEXTURE2D(_MainTex);    SAMPLER(sampler_MainTex);

            float3 sdgCircle(float2 p,  float r) 
            {
                float d = length(p);
                return float3(d-r, p/d);
            }

            float SDFBox(float2 p, float2 b)
            {
                float2 d = abs(p)-b;
                return length(max(d,0.0)) + min(max(d.x,d.y),0.0);
            }

            half3 SDFColoring(float sdf)
            {
                float3 col = (sdf > 0.0) ? float3(0.9, 0.6, 0.3) : float3(0.65, 0.85, 1.0);
              //  col *= 1.0 - exp(-6.0*abs(sdf));
                col *= 0.8 + 0.2 * cos(150.0*sdf);
               // col = lerp(col, float3(1, 1, 1), 1.0 - smoothstep(0.0, 0.01, abs(sdf)));
                return col;
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.positionCS = TransformObjectToHClip(v.vertex.xyz);
                o.positionSS = ComputeScreenPos(o.positionCS);  
                o.centerPositionSS = ComputeScreenPos(TransformWorldToHClip(UNITY_MATRIX_M._14_24_34));
                o.uv = v.uv;

                float elapsedTime = _Time.y - _EventTime;
                elapsedTime /= _BlinkTime;
                elapsedTime = saturate(elapsedTime);
                o.pulseRatio = 1 - (cos(elapsedTime * radians(360) * ((_BlinkCount - 1) + 0.5)) + 1) * 0.5;

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                //Checker Pattern
                float2 screenSpaceUV = i.positionCS / _ScreenParams.xy;
                float aspect = _ScreenParams.x / _ScreenParams.y;
                screenSpaceUV.x *= aspect;
                screenSpaceUV *= _PatternThickness;
                screenSpaceUV += (_Time.y);
                float2 grid = floor(screenSpaceUV);
                float checkerMask = fmod(grid.x + grid.y, 2.0);
                half3 checkerColor = (checkerMask == 0) ? half3(0, 0, 0) : half3(1, 1, 1);
                
                // _RectSize;
                // _ScreenParams;

                // float2 center = i.centerPositionSS * _ScreenParams.xy;
                // float2 min = i.positionCS.xy - center;
                // min /= _RectSize;
                // return half4(min, 0, 1);
                // return half4(i.positionSS.xy, 0, 1);
                // return half4(i.positionCS.xy, 0, 1);


                // float2 centeredUV = i.uv - 0.5;
                // //centeredUV *= 100;
                // //centeredUV.y *= 0.5;
                // //centeredUV = frac(centeredUV);
                // //centeredUV = step(0.5, centeredUV);
                // half angleRad = atan2(centeredUV.y, centeredUV.x);
                // half angleDeg = degrees(angleRad);
                // angleDeg = (angleDeg + 360.0 + _Time.w) % 360.0; // 음수 각도를 0~360으로 정규화
                // half normalizedAngle = angleDeg / 360.0;
                // half stripeMask = normalizedAngle * 30;
                // stripeMask = frac(stripeMask);
                // stripeMask = step(0.5, stripeMask);

                //Boarder Line
                float2 nUV = i.uv * _RectSize;
                half2 minBoarder = step(nUV - _BoarderThickness, 0);
                half2 maxBoarder = step((_RectSize -_BoarderThickness) - nUV, 0);
                half alpha = saturate(minBoarder.x + minBoarder.y + maxBoarder.x + maxBoarder.y);
                return half4(checkerColor, alpha * i.pulseRatio);
                //return half4(stripeMask.xxx, alpha);

                
                
                // _ScreenParams.xy;
                // i.positionCS;
                // i.uv;

                //float2 uv = i.uv - 0.5;

//                 float2 nUV = uv * rectSize;
//                 uv = abs(abs(nUV) - (rectSize * 0.5));

//                 float d = min(uv.x, uv.y);
//                  d *= 10;
//                  d = frac(d);
//                 return half4(d, 0, 0, 1);
//                 return half4(uv, 0, 1);
//                 d = step(_BoarderThickness, d);
//                 d = 1 - d;
                
                // float2 texelSize = 1 / _RectSize;
                // float lineTexelSize = texelSize * (int)_BoarderThickness;
                //float2 uv = i.uv;
                // uv -= 0.5;
                // uv *= 2;
                // uv.x /= 2;
                // uv = abs(uv);
                // float2 nUV = uv * _RectSize;
                // float sdf = SDFBox(nUV, (int)_BoarderThickness);

                // //sdf = abs(frac(sdf));

                // return half4(sdf, 0, 0, 1);
                
//                 return half4(SDFColoring(sdf), 1);
            }
            
            ENDHLSL
        }
    }
}
