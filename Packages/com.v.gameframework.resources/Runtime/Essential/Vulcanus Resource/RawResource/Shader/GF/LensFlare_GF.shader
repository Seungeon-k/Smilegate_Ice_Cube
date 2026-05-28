Shader "ZAMMYSMITH/SpecialFX/LensFlare_GF"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Color", Color) = (1,1,1,1)
        
        _Distance("Distance", float) = 0
        _Scale("Scale", float) = 1

        //Render State
        [Space(20)]
        [Enum(UnityEngine.Rendering.CullMode)] _Culling("Cull Mode", Int) = 2
    }
    SubShader
    {
        //Tags { "Queue" = "Geometry+10" "RenderType" = "Opaque" "LightMode" = "UniversalForward" "ShaderUsage" = "Creator" }
        Tags
        {
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "ShaderUsage" = "Creator"
        }
        Blend One One
        ZTest Off
        ZWrite Off
        Cull Off 
        Lighting Off
 
        Pass
        {
            HLSLPROGRAM

            //Vertex, Fragment Shader   
            #pragma vertex      vert
            #pragma fragment    frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/UnityInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
 
            sampler2D _MainTex;
            sampler2D _DisplacementGuide;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _Color;
 
                float _Distance;
                float _Scale;
            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 screenPos : TEXCOORD1;
                float2 sunPositionUV : TEXCOORD2;
                half4 color : COLOR;
                half Attenuation : TEMP0;
            };

            float4 ScreenPosToClip(float2 screenPos)
            {
                float4 positionCS = float4(0, 0, 0, 1);

                screenPos = screenPos / _ScreenParams.xy;
                screenPos -= 0.5;
                screenPos *= 2;

                positionCS.xy = screenPos;
                return positionCS;
            }

            float invLerp(float from, float to, float value)
            {
                return (value - from) / (to - from);
            }

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                half3 normalizedToSunDirection = half3(0.421637, 0.7378647, 0.5270463);
                half3 sunPositionWS = normalizedToSunDirection * 1000 + _WorldSpaceCameraPos;
                half3 cameraForward = mul((half3x3)unity_CameraToWorld, half3(0, 0, 1));
                cameraForward = normalize(cameraForward);
                half3 lightToCamera = _WorldSpaceCameraPos - sunPositionWS;
                half dotResult = normalize(dot(-lightToCamera, cameraForward));

                half4 temp = ComputeScreenPos(TransformWorldToHClip(sunPositionWS));
                half2 sunPositionSS = temp.xy / temp.w * _ScreenParams.xy;
                half2 sunPositionCS = ScreenPosToClip(sunPositionSS).xy;

                half ratio = _ScreenParams.x / _ScreenParams.y;
                half2 screenCenterSS = float2(_ScreenParams.xy) / 2;
                half2 flareDirection = (screenCenterSS - sunPositionSS);
                flareDirection /= _ScreenParams.yx;

                half2 flarePositionSS = sunPositionSS + (flareDirection * (_Distance * dotResult * 2.5));
                half2 flarePositionCS = ScreenPosToClip(flarePositionSS).xy;

                half pattern = lerp(0.95, 1, (_SinTime.x + 1) * 0.5);

                half3 vertex = v.vertex.xyz * _Scale * pattern;
                vertex.y *= ratio;
                vertex.xy += flarePositionCS.xy;
                o.vertex = half4(vertex, 1);

                #if UNITY_UV_STARTS_AT_TOP
                    o.vertex.y = -o.vertex.y;
                    o.vertex.z = 1;
                #endif

                o.sunPositionUV = (sunPositionCS + 1) / 2;

                //SS Sun Clipping
                half2 xyClamp = abs(sunPositionCS.xy);
                half sunClamp = clamp(max(xyClamp.x, xyClamp.y), 0.92, 1);

                o.Attenuation = 1 - invLerp(0.92, 1, sunClamp);
                o.Attenuation *= saturate(dot(-lightToCamera, cameraForward));
                o.Attenuation *= pattern;
                return o;
            }
 
            half4 frag(v2f i) : SV_Target
            {
                float worldDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, i.sunPositionUV).r;

                #if UNITY_UV_STARTS_AT_TOP
                    worldDepth = 1 - worldDepth;
                #endif

                clip(worldDepth - 1);

                half4 col = tex2D(_MainTex, i.uv) * _Color;
                col.rgb *= i.Attenuation * worldDepth;
                return col; 
            }
            ENDHLSL
        }
    }
}