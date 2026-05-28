Shader "Vulcanus/Vulcanus_Particle"
{
    Properties
    {
        [NoScaleOffset] _ControlMap ("Control Map", 2D) = "white" {}

        [KeywordEnum(Opaque, Transparent)] _SurfaceType("Surface Type",Float) = 0
        [Toggle(_SOFT_PARTICLES)] _SOFT_PARTICLES("Soft Particles", Float) = 0.0
        [Toggle(_ALPHA_CUTOFF)] _AlphaCutoff("Enable Alpha Cutoff", Float) = 0.0
        _CutoffCoef("└─Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [Header(Blend State)]
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("└─Src", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("└─Dst", Float) = 0.0

        [Header(Render State)]
        [Enum(UnityEngine.Rendering.CullMode)] _Cull("└─Cull", Float) = 2.0
        [Enum(UnityEngine.Rendering.CompareFunction)] _ZTest("└─ZTest", Float) = 1.0
        [Enum(Off,0,On,1)] _ZWrite("└─ZWrite", Float) = 1.0

        // [Header(Blend State)]
        // [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("└─src", Float) = 1.0
        // [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("└─dst", Float) = 0.0
        // [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendAlpha("└─srcA", Float) = 1.0
        // [Enum(UnityEngine.Rendering.BlendMode)] _DstBlendAlpha("└─dstA", Float) = 0.0
    }
    
    SubShader
    {
        Name "Vulcaus Particle"
        Tags 
        { 
            "RenderPipeline"="UniversalPipeline" 
            "Queue"="Transparent" 
            "RenderType"="Transparent" 
            "LightMode"="UniversalForward" 
        }
        Blend[_SrcBlend][_DstBlend]
        //Blend[_SrcBlend][_DstBlend], [_SrcBlendAlpha][_DstBlendAlpha]
        ZTest[_ZTest]
        ZWrite[_ZWrite]
        Cull[_Cull]
        //AlphaToMask[_AlphaToMask]
        Pass
        {
            HLSLPROGRAM

            #pragma shader_feature_local_fragment _SURFACETYPE_OPAUQE _SURFACETYPE_TRANSPARENT
            #pragma shader_feature_local_fragment _SOFT_PARTICLES
            #pragma shader_feature_local_fragment _ALPHA_CUTOFF
            
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            #pragma multi_compile_instancing

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.vulcanus.render-pipelines.vulcanus/Shaders/Vulcanus_Lighting.hlsl"
            #include "Packages/com.vulcanus.render-pipelines.vulcanus/Shaders/HLSL_functions.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/Particles/ParticlesInput.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Particles.hlsl"

            TEXTURE2D(_ControlMap);    SAMPLER(sampler_ControlMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _ControlMap_ST;
                half _CutoffCoef;
            CBUFFER_END

#ifdef UNITY_DOTS_INSTANCING_ENABLED
            UNITY_INSTANCING_BUFFER_START(MyProps)
                UNITY_DOTS_INSTANCED_PROP(float4, _ControlMap_ST)
            UNITY_INSTANCING_BUFFER_END(MyProps)

            #define _ControlMap_ST     UNITY_ACCESS_DOTS_INSTANCED_PROP_FROM_MACRO(float4 , Metadata__ControlMap_ST)
#endif

            struct appdata
            {
                float4 positionOS   : POSITION;
                half4 color         : COLOR;
                half4 uv0           : TEXCOORD0;
                half4 uv1           : TEXCOORD1;
                half4 uv2           : TEXCOORD2;
            };
            struct v2f 
            {
                float4 positionCS   : SV_POSITION;
                half4 color         : COLOR;
                half4 uv0           : TEXCOORD0;
                half4 uv1           : TEXCOORD1;
                half4 uv2           : TEXCOORD2;
                half4 projection    : TEXCOORD3;
                half  fogFactor     : TEXCOORD4;
            };

            v2f vert (appdata v)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
                o.color = v.color;
                o.uv0 = v.uv0;
                o.uv1 = v.uv1;
                o.uv2 = v.uv2;
                o.fogFactor = ComputeFogFactor(o.positionCS.z);
                o.projection = ComputeScreenPos(o.positionCS);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                half4 controlMap = SAMPLE_TEXTURE2D(_ControlMap, sampler_ControlMap, i.uv0.xy);

                //Dissolve
                half dissolve = i.uv1.r;
                half dissolveSharpness = saturate(i.uv1.g);
                half temp = lerp(0, 0.5, dissolveSharpness);
                half temp2 = temp * 0.5;
                half smoothstepRatio = (1-controlMap.g) + lerp(temp2 - 1, 1 - temp2, dissolve);
                half alpha = controlMap.a - smoothstep(temp, 1-temp, smoothstepRatio);
                alpha = saturate(alpha);
                alpha *= i.color.a;

#ifdef _ALPHA_CUTOFF
                //Alpha Cutoff
                clip(alpha - _CutoffCoef);
#endif

#ifdef _SOFT_PARTICLES
                 half4 screenSpaceUV = i.positionCS / _ScreenParams;
                float sceneZ = LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(i.projection.xy / i.projection.w)).r, _ZBufferParams);
                float thisZ = i.projection.w;
                //half thisZ = LinearEyeDepth(i.projection.z / i.projection.w, _ZBufferParams);
                half softFactor = (sceneZ - thisZ);
                //half fade = saturate(far * ((sceneZ - near) - thisZ));
                //return half4(softFactor, 0, 0, 1);
                softFactor = saturate(softFactor);

                // half softParticleFactor = i.uv1.a;
                // half sceneRawDepth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV.xy).r;
                // half depth = LinearEyeDepth(sceneRawDepth, _ZBufferParams);
                // half softFactor = (depth - screenSpaceUV.w);
                // softFactor = saturate(softFactor);

    #ifdef _SURFACETYPE_OPAUQE
                float alphaClip;
                float ditherSize = 1;
                Unity_Dither_positionCS(softFactor, i.positionCS.xy / ditherSize, alphaClip);
                clip(alphaClip - 0.05);
    #elif _SURFACETYPE_TRANSPARENT
                alpha *= softFactor;
    #endif
#endif

                //Color
                half3 mainColor = i.color.rgb * controlMap.r;
                half3 subColor = i.uv2.rgb;
                half3 colorLerpRatio = i.uv2.a * controlMap.b;
                half emissivePower = i.uv1.b;
                half3 color = lerp(mainColor, subColor, colorLerpRatio);
                color *= emissivePower;

                //Fog
                color.rgb = MixFog(color.rgb, i.fogFactor);
                return half4(color, alpha);
            }
            ENDHLSL
        }
    }
}



 //Soft Particles
                // half softParticleFactor = i.uv1.a;
                // half4 screenSpaceUV = i.positionCS / _ScreenParams;
                // half sceneRawDepth = SAMPLE_TEXTURE2D(_CameraDepthTexture, sampler_CameraDepthTexture, screenSpaceUV.xy).r;
                // //half depth = LinearEyeDepth(sceneRawDepth, _ZBufferParams);
                // half depth = sceneRawDepth;
                // half softFactor = (depth - screenSpaceUV.w) / softParticleFactor;
                // //return half4(softFactor, softFactor, softFactor, 1);
                // softFactor = saturate(softFactor);
                // alpha *= softFactor;


                // //half fLinearSceneZ = LinearEyeDepth (_CameraDepthTexture.Sample(sampler_CameraDepthTexture, screenSpaceUV.xy / screenSpaceUV.w).r);                
                // //float fLinearSceneZ = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(screenSpaceUV)));
                // half fLinearSceneZ = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(screenSpaceUV));
                // //float fLinearSceneZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, sampler_CameraDepthTexture, i.projection.xy / i.projection.w), _ZBufferParams);
                // float fSoftParticleFadeValue = saturate(0.5 * (fLinearSceneZ - screenSpaceUV.z));
                // return half4(fSoftParticleFadeValue, fSoftParticleFadeValue, fSoftParticleFadeValue, 1);
                // alpha *= fSoftParticleFadeValue;

                // // float near = _SoftParticleFadeParams.x;
                // // float far = _SoftParticleFadeParams.y;
                // float near = 0.01;
                // float far = 2;

                // float fade = 1;
                // float sceneZ = LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(i.projection.xy / i.projection.w)).r, _ZBufferParams);
                // //float thisZ = LinearEyeDepth(i.projection.z / i.projection.w, _ZBufferParams);
                // float thisZ = screenSpaceUV.w;
                // fade = saturate(far * ((sceneZ - near) - thisZ));
                // return half4(fade, 0, 0, 1);