//
Shader "Vulcanus/Terrain(Test)"
{
    Properties
    {
        _SplatMap("Splat Texture", 2D) = "white" {}

        [MainColor]     _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        [MainTexture]   _RBaseMap("Base Texture", 2D) = "white" {}
        [NoScaleOffset] _RSpecGlossMap("    Specular Map", 2D) = "white" {}
        [NoScaleOffset] _RBumpMap("    Normal Map", 2D) = "bump" {}

        [NoScaleOffset] _GBaseMap("Base Texture", 2D) = "white" {}
        [NoScaleOffset] _GSpecGlossMap("    Specular Map", 2D) = "white" {}
        [NoScaleOffset] _GBumpMap("    Normal Map", 2D) = "bump" {}

        [NoScaleOffset] _BBaseMap("Base Texture", 2D) = "white" {}
        [NoScaleOffset] _BSpecGlossMap("    Specular Map", 2D) = "white" {}
        [NoScaleOffset] _BBumpMap("    Normal Map", 2D) = "bump" {}

        [NoScaleOffset] _EBaseMap("Base Texture", 2D) = "white" {}
        [NoScaleOffset] _ESpecGlossMap("    Specular Map", 2D) = "white" {}
        [NoScaleOffset] _EBumpMap("    Normal Map", 2D) = "bump" {}

        [Header(Specular)]
        [HDR] _SpecColor("    Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)

        [Header(Normal)]
        _BumpScale("    Bump Scale", Range(1.0, 10.0)) = 1

        [Header(Rim Light)]
        _RimColor("    Rim Color", Color) = (1, 1, 1, 1)
        _RimColorPower("    Rim Color Power", Range(0.0, 5.0)) = 1.0
        _RimPower("    Rim Power", Range(0.5, 10.0)) = 3.5    

        [Header(Render State)]
        [HideInInspector][Enum(UnityEngine.Rendering.CullMode)]_Cull("        Cull (default = Back)", Float) = 2 //2 = Back
        [HideInInspector][Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("        ZTest (default = LessEqual)", Float) = 4 //4 = LessEqual
        [HideInInspector][Enum(Off, 0, On, 1)]_ZWrite("        ZWrite (default = On)", Float) = 1 //0 = On
    }

        SubShader
        {
            Tags { "Queue" = "Geometry-10" "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" "UniversalMaterialType" = "SimpleLit" "IgnoreProjector" = "True" "ShaderModel" = "2.0"}
            LOD 300

            Pass
            {
                Name "Terrain"
                Tags { "LightMode" = "UniversalForward" }

                ZTest[_ZTest]
                ZWrite[_ZWrite]
                Cull[_Cull]

                HLSLPROGRAM
                //#pragma only_renderers gles gles3 glcore d3d11
                //#pragma target 2.0

            // -------------------------------------
            // Material Keywords
            //#pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _NORMALMAP
            #pragma multi_compile _ _SPECULARMAP
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile _ _ADDITIONAL_LIGHTS

            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile_fog

            #pragma vertex vert
            #pragma fragment frag

            //Origin Source
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitInput.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/SimpleLitForwardPass.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.vulcanus.render-pipelines.vulcanus/Shaders/HLSL_functions.hlsl"
                     
            TEXTURE2D(_RBaseMap);
            SAMPLER(sampler_RBaseMap);
            TEXTURE2D(_RSpecGlossMap);
            SAMPLER(sampler_RSpecGlossMap);
            TEXTURE2D(_RBumpMap);
            SAMPLER(sampler_RBumpMap);

            TEXTURE2D(_GBaseMap);
            SAMPLER(sampler_GBaseMap);
            TEXTURE2D(_GSpecGlossMap);
            SAMPLER(sampler_GSpecGlossMap);
            TEXTURE2D(_GBumpMap);
            SAMPLER(sampler_GBumpMap);

            TEXTURE2D(_BBaseMap);
            SAMPLER(sampler_BBaseMap);
            TEXTURE2D(_BSpecGlossMap);
            SAMPLER(sampler_BSpecGlossMap);
            TEXTURE2D(_BBumpMap);
            SAMPLER(sampler_BBumpMap);

            TEXTURE2D(_EBaseMap);
            SAMPLER(sampler_EBaseMap);
            TEXTURE2D(_ESpecGlossMap);
            SAMPLER(sampler_ESpecGlossMap);
            TEXTURE2D(_EBumpMap);
            SAMPLER(sampler_EBumpMap);

            TEXTURE2D(_SplatMap);
            SAMPLER(sampler_SplatMap);

            CBUFFER_START(UnityPerMaterial)
                float4  _RBaseMap_ST;
                float4  _SplatMap_ST;
                half4   _BaseColor;
                half4   _SpecColor;
                half    _BumpScale;
                half4	_RimColor;
                half	_RimColorPower;
                half	_RimPower;
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
                float4 positionCS               : SV_POSITION;

                float2 uv                       : TEXCOORD0;
                float2 baseUV                   : TEXCOORD1;
                DECLARE_LIGHTMAP_OR_SH(lightmapUV, vertexSH, 2);

                float3 positionWS               : TEXCOORD3;    // xyz: positionWS

            #ifdef _NORMALMAP
                float4 normalWS                 : TEXCOORD4;    // xyz: normalWS, w: viewDirWS.x
                float4 tangentWS                : TEXCOORD5;    // xyz: tangentWS, w: viewDirWS.y
                float4 binormalWS               : TEXCOORD6;    // xyz: binormalWS, w: viewDirWS.z
            #else
                float3 normalWS                 : TEXCOORD4;
                float3 viewDirWS                : TEXCOORD5;
            #endif

                half4 fogFactorAndVertexLight   : TEXCOORD7;    // x: fogFactor, yzw: vertex light

            #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                float4 shadowCoord              : TEXCOORD8;
            #endif

                float dissolve                  : TEXCOORD9;
            };

            //Custom Function Headeder
            void InitializeInputData(v2f i, out InputData inputData);
            half3 CustomPixelBlinnPhong(InputData inputData, half3 albedo, half4 specularGloss, half smoothness);
            half3 CustomSampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap));

            ///////////////////////////////////////////////////////////////////////////////
            //                           Vertex functions                                //
            ///////////////////////////////////////////////////////////////////////////////
            v2f vert(appdata i)
            {
                v2f o = (v2f)0;

                o.positionWS = TransformObjectToWorld(i.positionOS.xyz);
                o.positionCS = TransformWorldToHClip(o.positionWS);
                o.uv = i.uv;
                o.baseUV = TRANSFORM_TEX(i.uv, _RBaseMap);

                half3 viewDirWS = GetWorldSpaceViewDir(o.positionWS);
#ifdef _NORMALMAP
                real sign = i.tangentOS.w * GetOddNegativeScale();
                o.normalWS = half4(TransformObjectToWorldNormal(i.normalOS), viewDirWS.x);
                o.tangentWS = half4(TransformObjectToWorldDir(i.tangentOS.xyz), viewDirWS.y);
                o.binormalWS = half4(cross(o.normalWS.xyz, o.tangentWS.xyz) * sign, viewDirWS.z); 
#else
                o.normalWS = NormalizeNormalPerVertex(TransformObjectToWorldNormal(i.normalOS));
                o.viewDirWS = viewDirWS;
#endif

                OUTPUT_LIGHTMAP_UV(i.lightmapUV, unity_LightmapST, o.lightmapUV);
                OUTPUT_SH(o.normalWS.xyz, o.vertexSH);

                half fogFactor = ComputeFogFactor(o.positionCS.z);
                half3 vertexLight = VertexLighting(o.positionWS, o.normalWS.xyz);
                o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                o.shadowCoord = TransformWorldToShadowCoord(o.positionWS);
#endif

                return o;
            }

            ///////////////////////////////////////////////////////////////////////////////
            //                            Pixel functions                                //
            ///////////////////////////////////////////////////////////////////////////////
            half4 frag(v2f i) : SV_Target
            {
                half3 emission = 0;

                half4 splat = SAMPLE_TEXTURE2D(_SplatMap, sampler_SplatMap, i.uv);
                half sum = splat.r + splat.g + splat.b;
                half empty = clamp(1 - sum, 0, 1);
                splat.a = empty; 
                sum += empty;

                //float2 uv = clamp(fmod(i.baseUV % 1.0f, 0.5f), 0, 0.5f);
                //float2 uv = (i.baseUV % 1.0f * 0.5);
                //uv.x = clamp(uv.x + 0.5, 0.5, 1.0);
                //uv.y = clamp(uv.y + 0.5, 0.5, 1.0);

                float2 uv = i.baseUV;
                float2 rUV = uv + float2(0, 0.5);
                float2 gUV = uv + 0.5;
                float2 bUV = uv;
                float2 aUV = uv + float2(0.5, 0);

                //Albedo
                float4 splatRatio = saturate(splat / sum);
                half3 rBase = splatRatio.r * SAMPLE_TEXTURE2D(_RBaseMap, sampler_RBaseMap, rUV);
                half3 gBase = splatRatio.g * SAMPLE_TEXTURE2D(_GBaseMap, sampler_RBaseMap, gUV);
                half3 bBase = splatRatio.b * SAMPLE_TEXTURE2D(_BBaseMap, sampler_GBaseMap, bUV);
                half3 eBase = splatRatio.a * SAMPLE_TEXTURE2D(_EBaseMap, sampler_EBaseMap, aUV);
                half3 albedo = (rBase + gBase + bBase + eBase) * _BaseColor;

                //Input Data
                InputData inputData;
                inputData.positionWS = i.positionWS;
#ifdef _NORMALMAP
                half3 viewDirWS = half3(i.normalWS.w, i.tangentWS.w, i.binormalWS.w);
                half3 rNormalTS = splatRatio.r * CustomSampleNormal(rUV, TEXTURE2D_ARGS(_RBumpMap, sampler_RBumpMap));
                half3 gNormalTS = splatRatio.g * CustomSampleNormal(gUV, TEXTURE2D_ARGS(_GBumpMap, sampler_GBumpMap));
                half3 bNormalTS = splatRatio.b * CustomSampleNormal(bUV, TEXTURE2D_ARGS(_BBumpMap, sampler_BBumpMap));
                half3 aNormalTS = splatRatio.a * CustomSampleNormal(aUV, TEXTURE2D_ARGS(_EBumpMap, sampler_EBumpMap));
                half3 normalTS = normalize(rNormalTS + gNormalTS + bNormalTS + aNormalTS);
                normalTS.xy *= _BumpScale;

                //return half4(normalTS, 1);
                inputData.normalWS = TransformTangentToWorld(normalTS, half3x3(i.tangentWS.xyz, i.binormalWS.xyz, i.normalWS.xyz));
#else
                half3 viewDirWS = i.viewDirWS;
                inputData.normalWS = i.normalWS;
#endif

                inputData.viewDirectionWS = SafeNormalize(viewDirWS);
                inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);

#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                inputData.shadowCoord = i.shadowCoord;
#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
#else
                inputData.shadowCoord = float4(0, 0, 0, 0);
#endif

                inputData.fogCoord = i.fogFactorAndVertexLight.x;
                inputData.vertexLighting = i.fogFactorAndVertexLight.yzw;
                inputData.bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, inputData.normalWS);
                inputData.normalizedScreenSpaceUV = GetNormalizedScreenSpaceUV(i.positionCS);
                inputData.shadowMask = SAMPLE_SHADOWMASK(i.lightmapUV);

                //Specular
                half4 specularSmoothness = 0;
#ifdef _SPECULARMAP
                half4 rSpecularSmoothness = splatRatio.r * SAMPLE_TEXTURE2D(_RSpecGlossMap, sampler_RSpecGlossMap, rUV) * _SpecColor;
                half4 gSpecularSmoothness = splatRatio.g * SAMPLE_TEXTURE2D(_GSpecGlossMap, sampler_GSpecGlossMap, gUV) * _SpecColor;
                half4 bSpecularSmoothness = splatRatio.b * SAMPLE_TEXTURE2D(_BSpecGlossMap, sampler_BSpecGlossMap, bUV) * _SpecColor;
                half4 aSpecularSmoothness = splatRatio.a * SAMPLE_TEXTURE2D(_ESpecGlossMap, sampler_ESpecGlossMap, aUV) * _SpecColor;
                specularSmoothness = rSpecularSmoothness + gSpecularSmoothness + bSpecularSmoothness + aSpecularSmoothness;
#else
                specularSmoothness = _SpecColor;
#endif
                specularSmoothness.a = exp2(10 * specularSmoothness.a + 1);

                //Rim Light
                float rim = 1.0 - saturate(dot(inputData.viewDirectionWS, i.normalWS.xyz));
                half3 rimResult = (_RimColor.rgb * _RimColor.a) * _RimColorPower * pow(rim, _RimPower);
                emission += rimResult;

                half4 color;
                color.rgb = CustomPixelBlinnPhong(inputData, albedo, specularSmoothness, specularSmoothness.a);
                color.rgb += emission;
                color.rgb = MixFog(color.rgb, inputData.fogCoord);
                color.a = 1;
                return color;
            }

            half3 CustomSampleNormal(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap))
            {
#ifdef _NORMALMAP
                half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);
                return UnpackNormalScale(n, 1);
#else
                return half3(0.0h, 0.0h, 1.0h);
#endif
            }

            half3 CustomPixelBlinnPhong(InputData inputData, half3 albedo, half4 specularGloss, half smoothness)
            {
            // To ensure backward compatibility we have to avoid using shadowMask i, as it is not present in older shaders
//#if defined(SHADOWS_SHADOWMASK) && defined(LIGHTMAP_ON)
//                half4 shadowMask = inputData.shadowMask;
//#elif !defined (LIGHTMAP_ON)
//                half4 shadowMask = unity_ProbesOcclusion;
//#else
                half4 shadowMask = half4(1, 1, 1, 1);
//#endif

                Light mainLight = GetMainLight(inputData.shadowCoord, inputData.positionWS, shadowMask);

#if defined(_SCREEN_SPACE_OCCLUSION)
                AmbientOcclusionFactor aoFactor = GetScreenSpaceAmbientOcclusion(inputData.normalizedScreenSpaceUV);
                mainLight.color *= aoFactor.directAmbientOcclusion;
                inputData.bakedGI *= aoFactor.indirectAmbientOcclusion;
#endif
                //MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);

                //half3 ambientColor = SampleSH(inputData.normalWS) * mainLight.color;
                half3 ambientColor = inputData.bakedGI * mainLight.color;
                half3 attenuatedLightColor = inputData.bakedGI * mainLight.color * (mainLight.distanceAttenuation * mainLight.shadowAttenuation);
                half3 diffuse = LightingLambert(attenuatedLightColor, mainLight.direction, inputData.normalWS);
                half3 specularColor = LightingSpecular(attenuatedLightColor, mainLight.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);

#ifdef _ADDITIONAL_LIGHTS
                uint pixelLightCount = GetAdditionalLightsCount();
                for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
                {
                    Light light = GetAdditionalLight(lightIndex, inputData.positionWS, shadowMask);
#if defined(_SCREEN_SPACE_OCCLUSION)
                    light.color *= aoFactor.directAmbientOcclusion;
#endif
                    half3 attenuatedLightColor = light.color * (light.distanceAttenuation * light.shadowAttenuation);
                    diffuse += LightingLambert(attenuatedLightColor, light.direction, inputData.normalWS);
                    specularColor += LightingSpecular(attenuatedLightColor, light.direction, inputData.normalWS, inputData.viewDirectionWS, specularGloss, smoothness);
                }
#endif

#ifdef _ADDITIONAL_LIGHTS_VERTEX
                diffuse += inputData.vertexLighting;
#endif

                return (albedo * (ambientColor + diffuse)) + specularColor;
            }

            ENDHLSL
        }

        //Pass
        //{
        //    Name "Terrain_ShadowCaster"
        //    Tags{"LightMode" = "ShadowCaster"}

        //    ZWrite On
        //    ZTest LEqual
        //    ColorMask 0
        //    Cull[_Cull]

        //    HLSLPROGRAM
        //    #pragma only_renderers gles gles3 glcore d3d11
        //    #pragma target 2.0

        //    // -------------------------------------
        //    // Material Keywords
        //    #pragma shader_feature_local_fragment _ALPHATEST_ON
        //    #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

        //    #pragma vertex ShadowPassVertex
        //    #pragma fragment ShadowPassFragment

        //    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        //    CBUFFER_START(UnityPerMaterial)
        //        float4  _BaseMap_ST;
        //        float4  _SplatMap_ST;
        //        half4   _RChannelColor;
        //        half4   _GChannelColor;
        //        half4   _BChannelColor;
        //        half4   _EChannelColor;
        //        half4	_RimColor;
        //        half	_RimColorPower;
        //        half	_RimPower;
        //        half4   _SpecColor;
        //        half    _BumpScale;
        //    CBUFFER_END

        //    struct VertexInput
        //    {
        //        float4 vertex   : POSITION;
        //        float4 normalWS   : NORMAL;
        //        float2 uv       : TEXCOORD0;
        //    };

        //    struct VertexOutput
        //    {
        //        float4 vertex   : SV_POSITION;
        //        float2 baseUV   : TEXCOORD0;
        //    };

        //    VertexOutput ShadowPassVertex(VertexInput v)
        //    {
        //        VertexOutput o;
        //        float3 positionWS = TransformObjectToWorld(v.vertex.xyz);
        //        float3 normalWS = TransformObjectToWorldNormal(v.normalWS.xyz);
        //        o.vertex = TransformWorldToHClip(ApplyShadowBias(positionWS, normalWS, _MainLightPosition.xyz));
        //        o.baseUV = v.uv;
        //        return o;
        //    }

        //    half4 ShadowPassFragment(VertexOutput i) : SV_TARGET
        //    {
        //        return 0;
        //    }
        //    ENDHLSL
        //}
    
        Pass
        {
            Name "Terrain_DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            //#pragma only_renderers gles gles3 glcore d3d11
            //#pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            #include "Packages/com.unity.render-pipelines.universal/Shaders/UnlitInput.hlsl"

            struct VertexInput
            {
                float4 vertex : POSITION;
            };

            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
            };

            VertexOutput DepthOnlyVertex(VertexInput v)
            {
                VertexOutput o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }

            half4 DepthOnlyFragment(VertexOutput i) : SV_TARGET
            {
                return 0;
            }
            ENDHLSL
        }

        Pass
        {
            Name "Terrain_DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            ZTest LEqual
            Cull[_Cull]

            HLSLPROGRAM
            #pragma vertex DepthNormalVertex
            #pragma fragment DepthNormalFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //Origin DepthNormal Pass
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/DepthNormalsPass.hlsl"

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"

            CBUFFER_START(UnityPerMaterial)
                float4  _BaseMap_ST;
                float4  _SplatMap_ST;
                half4   _BaseColor;
                half4   _SpecColor;
                half    _BumpScale;
                half4	_RimColor;
                half	_RimColorPower;
                half	_RimPower;
            CBUFFER_END

            struct VertexInput
            {
                float4 vertex		: POSITION;
                float4 tangentOS    : TANGENT;
                float2 uv           : TEXCOORD0;
                float3 normalWS     : NORMAL;
            };

            struct VertexOutput
            {
                float4 vertex	    : SV_POSITION;
                float2 baseUV       : TEXCOORD0;
                float2 dissolveUV   : TEXCOORD1;
                float3 normalWS     : TEXCOORD2;
            };

            VertexOutput DepthNormalVertex(VertexInput i)
            {
                VertexOutput o = (VertexOutput)0;

                o.vertex = TransformObjectToHClip(i.vertex.xyz);
                o.baseUV = TRANSFORM_TEX(i.uv, _BaseMap);

                VertexNormalInputs normalInput = GetVertexNormalInputs(i.normalWS, i.tangentOS);
                o.normalWS = NormalizeNormalPerVertex(normalInput.normalWS);
                return o;
            }

            half4 DepthNormalFragment(VertexOutput i) : SV_TARGET
            {
                return float4(PackNormalOctRectEncode(TransformWorldToViewDir(i.normalWS, true)), 0.0, 0.0);
            }

            ENDHLSL
        }
    }
}