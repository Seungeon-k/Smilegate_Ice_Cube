// 이 셰이더는 Hidden/ 경로를 사용하여 재질 생성 메뉴에 나타나지 않도록 합니다.
Shader "VirtualCamera/UberPost"
{
    // 사용자가 Unity 인스펙터에서 제어할 수 있는 프로퍼티 목록
    Properties
    {
        _MainTex ("Source Texture", 2D) = "white" {}
        _LensDirt_Texture ("Lens Dirt Texture", 2D) = "black" {}
        
        _BloomIntensity ("Bloom Intensity", Float) = 1.0
        _BloomTint ("Bloom Tint", Color) = (1, 1, 1, 1)
        
        _LensDirtIntensity ("Lens Dirt Intensity", Float) = 1.0
        _LensDirtScale ("Lens Dirt Scale", Float) = 1.0
        _LensDirtOffset ("Lens Dirt Offset", Vector) = (0, 0, 0, 0)

        // RGBM 디코딩을 사용할지 여부 (0 또는 1)
        _BloomRGBM ("Bloom uses RGBM", Float) = 0.0
    }

    SubShader
    {
        // 렌더링 순서와 상태 설정
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }
        // LOD 100
        // ZWrite Off 
        // Cull Off 
        // ZTest Always

        Pass
        {
            Name "VirtualCamera-Postprocess"
            
            HLSLPROGRAM
             
            //#pragma multi_compile_local_fragment _ _HDR_GRADING _TONEMAP_ACES _TONEMAP_NEUTRAL
            #pragma multi_compile_local_fragment _TONEMAP_ACES
            #pragma multi_compile_local _ BLOOM
            // #pragma multi_compile_local _ _BLOOM_HQ
            // #pragma multi_compile_local _ BLOOM_DIRT
            
            #pragma vertex vert
            #pragma fragment Frag
            // #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
            // #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            // #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"

            //#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            //#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Filtering.hlsl"
            //#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/ScreenCoordOverride.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/DebuggingFullscreen.hlsl"
            //#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/FoveatedRendering.hlsl"

            TEXTURE2D(_MainTex);
            TEXTURE2D(_Bloom_Texture);
            TEXTURE2D(_LensDirt_Texture);

            TEXTURE2D(_InternalLut);
            TEXTURE2D(_UserLut);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST; 
                float4 _Lut_Params;
                float4 _UserLut_Params;
                float4 _Bloom_Params;
                half4 _Bloom_Texture_TexelSize;
                half4 _MainTex_TexelSize;
                half _BloomIntensity;
                half4 _BloomTint;
                half _LensDirtIntensity;
                half _LensDirtScale;
                half2 _LensDirtOffset;
                half _BloomRGBM;
            CBUFFER_END

            #define BloomIntensity          _Bloom_Params.x
            #define BloomTint               _Bloom_Params.yzw

            #define LutParams               _Lut_Params.xyz
            #define PostExposure            _Lut_Params.w
            #define UserLutParams           _UserLut_Params.xyz
            #define UserLutContribution     _UserLut_Params.w

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.texcoord = v.texcoord;
                return o;
            }

            half4 Frag(v2f input) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_LinearClamp, input.texcoord);

                //Bloom
                half4 bloom = SAMPLE_TEXTURE2D(_Bloom_Texture, sampler_LinearClamp, input.texcoord);

                #if UNITY_COLORSPACE_GAMMA
                bloom.xyz *= bloom.xyz; // γ to linear
                #endif

                bloom.xyz *= BloomIntensity;
                color.xyz += bloom.xyz * BloomTint.xyz;
                color.a = saturate(color.a + bloom.a * 2.5);

                //ACES Tonemapping
                float3 aces = unity_to_ACES(color.rgb);
                color.rgb = AcesTonemap(aces);

                return color;
            }
            ENDHLSL
        }
    }
}