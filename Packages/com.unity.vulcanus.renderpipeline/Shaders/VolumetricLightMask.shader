Shader "Vulcanus/Special/VolumetricLightMask"
{
    Properties
    {
        [HDR]_LightColor("Light Color", color) = (1,1,1,1)
        _LightAngle("Light Angle(Degree)", Range(0, 120)) = 10
        _LightRange("Light Range", Range(10, 100)) = 15
        _LightSoftness("Light Softness", Range(0, 1)) = 0
        _LightPosition("LightPosition", Vector) = (0, 0, 0, 0)

        _Test("Test", Range(0, 1000)) = 100

        _MaximumDarkness("Maximum Darkness", Range(0.0, 1.0)) = 0
        [IntRange]_RaySteps("Ray Steps", Range(0, 500)) = 50
        _RayRadius("Ray Radius", Range(0.01, 1)) = 0.01

        [Header(Render State)]
        [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("       BlendOp", Float) = 0 // 0 = Add
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("        Src", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("        Dst", Float) = 0.0
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("    ZTest (default = Disable)", Float) = 0 //0 = disable
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("    Cull (default = Front)", Float) = 1 //1 = Front
    }
    SubShader 
    {
        Tags {"Queue" = "Geometry" "RenderType" = "Opaque" }
        BlendOp[_BlendOp]
        Blend[_SrcBlend][_DstBlend]
        ZTest[_ZTest]
        ZWrite Off
        Cull[_Cull]
        Pass 
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            
            CBUFFER_START(UnityPerMaterial)
                half4 _LightColor;
                half4 _LightPosition;
                half _RayRadius;
                half _LightAngle;
                half _LightRange;
                half _LightSoftness;
                half _MaximumDarkness;
                int _RaySteps;
                half _Test;
            CBUFFER_END
            
            struct vertexInput
            {
                float4 vertex : POSITION;
                float4 uvCoord : TEXCOORD0;
            };
            
            struct vertexOutput
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : POSITION1;
                float4 uvCoord : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                half lightConeRadius : TEXCOORD2;
            };
            
            vertexOutput vert(vertexInput v) 
            {
                vertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.worldPos = TransformObjectToWorld(v.vertex.xyz); 
                o.uvCoord = v.uvCoord;
                o.screenPos = ComputeScreenPos(o.vertex);

                float toRadian = 0.0174533; //PI / 180
                float radians = (_LightAngle * 0.5) * toRadian;
                o.lightConeRadius = _LightRange * tan(radians);
                
                return o;
            }

            float SdfCone(in float3 position, in float radius)
            { 
                position -= _LightPosition.xyz;
                float2 p = float2(length(position.xz) - radius, position.y + _LightRange);
                float2 e = float2(-radius, _LightRange);
                float2 d1 = p - e * clamp(dot(p, e) / dot(e, e), 0.0, 1.0);
                float2 d2 = float2(max(p.x, 0.0), -p.y);
                float d = sqrt(min(dot(d1, d1), dot(d2, d2))) * sign(max(max(d1.x, d1.y), d2.y));

                d -= _RayRadius;
                return d;
            }

            float3 normal(float3 position, float radius)
            {
                float epsilon = 0.001;
                float3 gradient = float3
                (
                    SdfCone(position + float3(epsilon, 0, 0), radius) - SdfCone(position + float3(-epsilon, 0, 0), radius),
                    SdfCone(position + float3(0, epsilon, 0), radius) - SdfCone(position + float3(0, -epsilon, 0), radius),
                    SdfCone(position + float3(0, 0, epsilon), radius) - SdfCone(position + float3(0, 0, -epsilon), radius)
                );
                return normalize(gradient);
            }

            float raycast(float3 rayOrigin, float3 rayDirection, float radius) 
            {
                int stepCount = _RaySteps;
                float t = 0.0;
                for (int i = 0; i < stepCount; i++) 
                {
                    float3 currentPosition = rayOrigin + rayDirection * t;
                    float d = SdfCone(currentPosition, radius);
                    if (d < 0.0001) 
                    {
                        return t;
                    }
                    t += d;
                }
                return 0.0;
            }

            half4 frag(vertexOutput i) : SV_Target
            {
                clip(_MaximumDarkness - 0.0001);

                half2 screenSpaceUV = i.vertex.xy / _ScreenParams.xy;
                float sceneRawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV).r;
                //sceneRawDepth = LOAD_TEXTURE2D_X(_CameraDepthTexture, screenSpaceUV).x;
                float linearEyeDepth = LinearEyeDepth(sceneRawDepth, _ZBufferParams);

                float4 clipSpacePosition = float4(screenSpaceUV * 2 - 1, sceneRawDepth, 1);
                #if UNITY_UV_STARTS_AT_TOP
                    clipSpacePosition.y = -clipSpacePosition.y;
                #endif
                
                float4 worldSpacePosition = mul(UNITY_MATRIX_I_VP, clipSpacePosition);
                worldSpacePosition /= worldSpacePosition.w;

                float3 rayDirection = (worldSpacePosition.xyz - _WorldSpaceCameraPos);
                float rayLength = length(rayDirection);
				rayDirection /= rayLength;

                float t = raycast(_WorldSpaceCameraPos, rayDirection, i.lightConeRadius);
                float coneFcactor = saturate(t);
                float3 conSurfacePosition = _WorldSpaceCameraPos + rayDirection * t;
                float3 conSurfaceNormal = normal(conSurfacePosition, i.lightConeRadius);

                float coneRangeAttenuation = 1 - (abs(conSurfacePosition.y - _LightPosition.y) / _LightRange);
                coneRangeAttenuation *= coneRangeAttenuation;
                
                float coneNormalAttenuation = abs(dot(rayDirection, conSurfaceNormal)); 
                coneNormalAttenuation = lerp(1, coneNormalAttenuation, _LightSoftness);

                float coneOcclusionMask = step(0.000001, linearEyeDepth - t);

                float coneVolumeMask = (1 - step(t, 0));
            
                float distance = length(worldSpacePosition.xyz - (_LightPosition.xyz + (float3(0, -_LightRange, 0))));
                float sphereFactor = (distance / i.lightConeRadius);
                sphereFactor -= (1 - _LightSoftness);
                sphereFactor /= _LightSoftness;
                sphereFactor = saturate(sphereFactor);
                sphereFactor =  1 - ((1 - sphereFactor) * coneNormalAttenuation * coneVolumeMask);

                //float skyAttenuation = lerp(0.1, 1, step(0.0000001, sceneRawDepth));
                float depthAttenuation = sceneRawDepth * sphereFactor;
                depthAttenuation = step(0.000001, distance);
                depthAttenuation = lerp(0.3, 1, 1 - depthAttenuation);

                half alphaFactor = coneFcactor * coneNormalAttenuation * coneRangeAttenuation * depthAttenuation * coneOcclusionMask;
                alphaFactor = 1 - alphaFactor;
                alphaFactor *= sphereFactor;
                alphaFactor *= _MaximumDarkness;

                // alphaFactor = coneFcactor * coneNormalAttenuation * coneRangeAttenuation * depthAttenuation;
                // alphaFactor = 1 - alphaFactor;

                //return half4(alphaFactor, 0, 0, 1);
                half4 color = 0;
                color.a = alphaFactor;
                return color;




                // float skyAttenuation = lerp(0.1, 1, step(0.000001, sceneRawDepth));
                // float depthAttenuation = sceneRawDepth * sphereFactor;
                // depthAttenuation = 1;
                // // //depthAttenuation = saturate(1 - length(worldSpacePosition - _LightPosition) / _LightRange);
                
                // depthAttenuation = max(saturate(1 - length(worldSpacePosition - _LightPosition) / _LightRange), 1 - sphereFactor);
                // depthAttenuation = 1 - depthAttenuation;
                // depthAttenuation *= depthAttenuation;
                // depthAttenuation = saturate(depthAttenuation);

                // depthAttenuation = length(worldSpacePosition - _LightPosition) / _LightRange;
                // depthAttenuation = lerp(0.1, 1, depthAttenuation);

                // half shadeFactor = coneFcactor * coneNormalAttenuation * coneRangeAttenuation * coneDepthMask;
                // half temp = min(depthAttenuation, 1 - shadeFactor);
                // return half4(0, 0, 0, temp);
                // return half4(temp, 0, 0, 1);

                // return half4(shadeFactor, 0, 0, 1);
                // shadeFactor = 1 - shadeFactor;
                // shadeFactor *= sphereFactor;
                // shadeFactor *= _MaximumDarkness;

                // //return half4(lerp(half3(1,1,1), half3(0, 0, 0), shadeFactor), 1);
                // half4 color = half4(0, 0, 0, shadeFactor);
                // return color;






                // half3 c = lerp(half3(0, 0, 0), _LightColor.rgb, 1 - sphereFactor);
                // return half4(c, sphereFactor);
                
                //half factor = coneFcactor * coneNormalAttenuation * coneRangeAttenuation * coneDepthmMasking;
                // float4 color = 0;
                // color.rgb = lerp(half3(0, 0, 0), _LightColor, max(factor, (1 - sphereFactor)));
                // color.a = 1 - factor;
                // color.a *= sphereFactor;
                // color.a *=  _MaximumDarkness;
                // return color;

                // float3 cameraForward = GetViewForwardDir();
                // float3 toWorld = normalize(worldSpacePosition - _WorldSpaceCameraPos);
                // float toConeDistance = length(_LightPosition - _WorldSpaceCameraPos);
                // float3 virtualSlicedConePosition = _WorldSpaceCameraPos + (toWorld * toConeDistance);
                // half coneFactor = coneSDF(virtualSlicedConePosition.xyz, _LightPosition, float2(_Vector.x, _Vector.y), _Vector.z);
                // coneFactor = saturate(coneFactor);
                // shadeFactor *= coneFactor;
            }
            ENDHLSL
        }
    }
    //Fallback "Diffuse"
}