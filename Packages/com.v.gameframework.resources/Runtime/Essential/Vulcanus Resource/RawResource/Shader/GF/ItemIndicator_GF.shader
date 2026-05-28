//
Shader "ZAMMYSMITH/SpecialFX/ItemIndicator_GF"
{
    Properties
    {
        [MainColor][HDR] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _Cutoff("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        _XScrollSpeed("X Scroll Speed", Float) = 0
        _YScrollSpeed("Y Scroll Speed", Float) = 0

        [Header(Blend State)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("        Src", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("        Dst", Float) = 0.0

        [Header(Render State)]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("        Cull (default = Back)", Float) = 2 //2 = Back
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("        ZTest (default = LessEqual)", Float) = 4 //4 = LessEqual
        [Enum(Off, 0, On, 1)]_ZWrite("        ZWrite (default = On)", Float) = 1 //0 = On
    }

    SubShader
    {
        Tags { "Queue" = "Geometry+197" "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "2.0"}
        LOD 300

        Pass
        {
            Name "DefaultWorld_ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            Blend[_SrcBlend][_DstBlend]
            ZTest[_ZTest]
            ZWrite [_ZWrite]
            Cull[_Cull]

            HLSLPROGRAM
            //#pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            // -------------------------------------

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            //#include "HLSL_functions.hlsl"
            //#include "Vulcanus_functions.hlsl"

            CBUFFER_START(UnityPerMaterial)
                half4   _BaseColor;
                half    _XScrollSpeed;
                half    _YScrollSpeed;
                half    _Cutoff;
            CBUFFER_END

            struct appdata
            {
                float4 positionOS    : POSITION;
                float3 normalOS      : NORMAL;
                float4 tangentOS     : TANGENT;
                float2 uv            : TEXCOORD0;
                float2 lightmapUV    : TEXCOORD1;
            };

            struct v2f
            {
                float4 position             : SV_POSITION;
                float4 positionCS           : TEXCOORD0;
                float4 centerPositionCS     : TEXCOORD1;
                float3 positionWS           : TEXCOORD2;    // xyz: positionWS
                float3 normalWS             : TEXCOORD3;
            };

            ///////////////////////////////////////////////////////////////////////////////
            //                           Vertex functions                                //
            ///////////////////////////////////////////////////////////////////////////////
            v2f vert(appdata i)
            {
                v2f o = (v2f)0;

                o.positionWS = TransformObjectToWorld(i.positionOS.xyz);
                o.position = TransformWorldToHClip(o.positionWS);
                o.positionCS = o.position;
                o.centerPositionCS = TransformWorldToHClip(UNITY_MATRIX_M._14_24_34);
                o.normalWS = NormalizeNormalPerVertex(TransformObjectToWorldNormal(i.normalOS));

                return o;
            }

            ///////////////////////////////////////////////////////////////////////////////
            //                            Pixel functions                                //
            ///////////////////////////////////////////////////////////////////////////////
            half4 frag(v2f i) : SV_Target
            {               
                half2 screenUV = i.position.xy / _ScreenParams.xy;
                #if UNITY_UV_STARTS_AT_TOP
                    //screenUV.y = 1 - screenUV.y;
                #endif
                half2 localScreenUV = (screenUV * 2.0 - 1.0) * i.centerPositionCS.w - i.centerPositionCS.xy;

                // Adjust for aspect ratio and FOV
                localScreenUV.x *= _ScreenParams.x / _ScreenParams.y;
                localScreenUV *= -1.0 / UNITY_MATRIX_P[1][1];
                localScreenUV.y *= -1;

                half stripeMask = localScreenUV.x - (localScreenUV.y - _Time.x * 10);
                stripeMask *= 3;
                stripeMask = frac(stripeMask);
                stripeMask = step(0.5h, stripeMask);
                
                float rawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, screenUV).r;
                half linearDepth = LinearEyeDepth(rawDepth, _ZBufferParams);
                half occlusionMask = clamp((linearDepth - i.position.w), 0.2, 1);
                occlusionMask = 1 - step(0.5, occlusionMask);
                
                half NdotL = saturate(dot(i.normalWS, _MainLightPosition.xyz));
                NdotL += 0.3;
                NdotL = saturate(NdotL);

                half4 color = 1;
                color.rgb = lerp(_BaseColor.rgb, _BaseColor.rgb * 3.5, occlusionMask) * NdotL;
                half3 spriteColor = half3(0, 0, 0);
                color.rgb = lerp(color.rgb, spriteColor, stripeMask);
                color.a = clamp(1 - occlusionMask, 0.5, 1);
                return color;
            }

            ENDHLSL
        }

    }
}



//float3 scale = float3(length(float3(unity_ObjectToWorld._m00, unity_ObjectToWorld._m10, unity_ObjectToWorld._m20)),
//    length(float3(unity_ObjectToWorld._m01, unity_ObjectToWorld._m11, unity_ObjectToWorld._m21)),
//    length(float3(unity_ObjectToWorld._m02, unity_ObjectToWorld._m12, unity_ObjectToWorld._m22)));
//float3 positionOS = i.positionOS.xyz * scale;