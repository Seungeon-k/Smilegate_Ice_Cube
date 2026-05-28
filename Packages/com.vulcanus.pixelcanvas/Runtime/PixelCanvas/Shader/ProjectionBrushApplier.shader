Shader "Vulcanus/PixelCanvas/ProjectionBrushApplier"
{
    Properties
    {
        _MainTex ("Main Tex", 2D) = "white" {}
    }

    SubShader
    {
        Tags {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "Projection Brush"
            Blend One Zero
            ZWrite Off
            ZTest Off
            ZClip Off

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Global.hlsl"

            TEXTURE2D(_MainTex); 
            SAMPLER(sampler_MainTex);

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };
            
            struct v2f 
            {
                float4 positionCS   : SV_POSITION;
                float3 positionWS   : TEXCOORD0;
                float2 texcoord     : TEXCOORD1;
            };
            
            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                o.positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(o.positionWS);
                o.texcoord = v.texcoord;
                return o;
            }

            half4 frag (v2f i) : SV_TARGET
            {
                float4 projectedMeshTexcoord = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

                float dist = projectedMeshTexcoord.b;
                float brushThickness = _BrushThickness; //WorldSpace Thickness
                brushThickness = 0.25 * (_BrushThickness / 20);
                float brushCoef = (brushThickness * (1 - _BrushSoftness));
                float brushAlpha = saturate(1 - (dist - brushCoef) / (brushThickness - brushCoef));
                float brushMask = 1 - step(brushAlpha, 0);
                //clip(brushMask - 0.000001);

                float2 uvGrid = projectedMeshTexcoord.xy * _SeedTextureSize;
                uvGrid = frac(uvGrid);
                int uvGridCenterRatio = saturate(1 - distance(uvGrid, 0.5)) * _ToInteger;
                
                int2 seedTextureCoord = (int2)(projectedMeshTexcoord.xy * _SeedTextureSize);
                int idx = seedTextureCoord.y * _SeedTextureSize.x + seedTextureCoord.x;
                int targetUVGridCenterRatio = _RWClosestUVDistance[idx];

                //return half4((float)targetUVGridCenterRatio / _ToInteger, 0, 0, 1);

                //Just Multipling  Numbers for random Color(Debug)
                idx = (seedTextureCoord.x * 848) + (seedTextureCoord.y * 1801);
                float r = sin(idx / 10);
                float g = sin(idx / 100);
                float b = sin(idx / 1000);
                float4 uvGridColor = float4(r, g, b, 1);
                uvGridColor.rgb = uvGridColor.rgb * 0.5 + 0.5;
                uvGridColor.rgb *= projectedMeshTexcoord.a;

                float4 color = uvGridColor;

                // Shader error in 'Vulcanus/PixelCanvas/ProjectionBrushApplier': typed UAV loads are only allowed for single-component 32-bit element types at line 94 (on d3d11)
                // [Branch]
                // if (targetUVGridCenterRatio == uvGridCenterRatio)
                // {
                //     float4 drawingLayerColor = _RWDrawingLayer[seedTextureCoord];
                //     drawingLayerColor.rgb = lerp(drawingLayerColor.rgb, _BrushColor.rgb, brushMask);
                //     drawingLayerColor.a = max(drawingLayerColor.a, brushAlpha * _BrushColor.a);
                //     _RWDrawingLayer[seedTextureCoord] = drawingLayerColor;
                //     return color;
                // }
                
                // dist = min(dist, brushThickness + (brushThickness - dist));
                // float thick = brushThickness - 0.0005;
                // float softness = 0.0005;
                // float brushRange = smoothstep(thick - softness, thick + softness, dist);

                // color.rgb *= 0.3;
                // color.rgb = lerp(color.rgb, _BrushColor.rgb, brushRange);
                return color;
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}

//#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
//#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
//#include "Common.hlsl"


//float brushAlpha = projectedMeshTexcoord.b;
//float brushMask = 1 - step(brushAlpha, 0);

//idx = (seedTextureCoord.x * 848) + (seedTextureCoord.y * 1801);
//idx = (seedTextureCoord.x * 1256) + (seedTextureCoord.y * 8798);
// float r = sin(idx + 0) * 0.5 + 0.5;
// float g = sin(idx + 2) * 0.5 + 0.5;
// float b = sin(idx + 4) * 0.5 + 0.5;
// float4 uvGridColor = float4(r, g, b, 1);
//uvGridColor.rgb /= max(uvGridColor.r, max(uvGridColor.g, uvGridColor.b));

// float normalized = float(idx) / (_SeedTextureSize.x * _SeedTextureSize.y);
// float r = frac(sin(dot(float2(normalized, 78.233), float2(2.9898, 4.1414))) * 358.53);
// float g = frac(sin(dot(float2(normalized, 5.873), float2(3.989, 24.213))) * 3758.553);
// float b = frac(sin(dot(float2(normalized, 51.123), float2(6.726, 8.423))) * 75.543);
// float4 uvGridColor = float4(r, g, b, 1);


// float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
// float2 centerUV = float2(0.5, 0.5);
// float sceneRawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, centerUV).r;
// float4 clipSpacePosition = float4(screenSpaceUV * 2 - 1, sceneRawDepth, 1);
// #if UNITY_UV_STARTS_AT_TOP
//     clipSpacePosition.y = -clipSpacePosition.y;
// #endif

// float4 worldSpacePosition = mul(UNITY_MATRIX_I_VP, clipSpacePosition);
// worldSpacePosition /= worldSpacePosition.w;
//float dist = length(_RaycastPositionWS.xyz - i.positionWS.xyz);

// dist = SDFLine(mul(UNITY_MATRIX_V, float4(_PrvRaycastPositionWS.xyz, 1)).xy, mul(UNITY_MATRIX_V, float4(_RaycastPositionWS.xyz, 1)).xy, mul(UNITY_MATRIX_V, float4(i.positionWS.xyz, 1).xy));
// return half4(dist, 0, 0, 1);

// float2 centerUV = float2(0.5, 0.5);
// dist = SDFLine(centerUV, centerUV, screenSpaceUV);
                

// half3 pallate(float t, float3 a, float3 b, float3 c, float3 d)
// {
//     return a + b * cos(6.283185*(c*t+d));
// }


// half4 frag (v2f i) : SV_TARGET
// {
//     //float4 uvGrid = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);

//     float dist = SDFLine(_PrvRaycastPositionWS.xyz, _RaycastPositionWS.xyz, i.positionWS.xyz);
//     float brushThickness = _BrushThickness / 20;
//     brushThickness *= 0.5;
//     float brushCoef = (brushThickness * (1 - _BrushSoftness));
//     float brushAlpha = saturate(1 - (dist - brushCoef) / (brushThickness - brushCoef));
//     float brushMask = 1 - step(brushAlpha, 0);
//     clip(brushMask - 0.000001);

//     float2 uvGrid = i.texcoord * _SeedTextureSize;
//     uvGrid = frac(uvGrid);
//     int uvGridCenterRatio = saturate(1 - distance(uvGrid, 0.5)) * _ToInteger;

//     int2 seedTextureCoord = (int2)(i.texcoord * _SeedTextureSize);
//     int idx = seedTextureCoord.y * _SeedTextureSize.x + seedTextureCoord.x;
//     int targetUVGridCenterRatio = _RWClosestUVDistance[idx];

//     uvGrid = step(0.95, uvGrid);
//     if (targetUVGridCenterRatio == uvGridCenterRatio)
//     {
//         float4 data = _RWDrawingLayer[seedTextureCoord];
//         data.rgb = lerp(data.rgb, _BrushColor.rgb, brushMask);
//         data.a = max(data.a, brushAlpha * _BrushColor.a);
//         _RWDrawingLayer[(int2)(i.texcoord * _SeedTextureSize)] = data;
//         return half4(max(uvGrid.x, uvGrid.y), 1, 0, 1);
//     }
//     return half4(max(uvGrid.x, uvGrid.y), 0, 0, 1);
// }
