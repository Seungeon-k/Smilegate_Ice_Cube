
Shader "Vulcanus/PixelCanvas/Test"
{
    Properties
    {
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
            "RenderType" = "Transparent"
            "PreviewType" = "Plane"
            "ShaderUsage" = "Creator"
        }
        Pass
        { 
            Cull Back
            ZWrite On
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #pragma multi_compile _ _ULTRA_LOW_SPEC
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_SPECULAR
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile _ _TEST
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            CBUFFER_START(UnityPerMaterial)
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                return o;
            }

            float4 frag (v2f input) : SV_Target
            {
                #if defined(_MAIN_LIGHT_SHADOWS_CASCADE)
                    return half4(1, 0, 0, 1);
                    // #if defined(FOG_LINEAR)
                    // #else
                    //     return half4(0, 1, 0, 1);
                    // #endif
                #else

                    #if defined(FOG_LINEAR)
                        return half4(1, 1, 0, 1);
                    #else
                        return half4(0, 0, 0, 1);
                    #endif
                #endif
                
                #if defined(_TEST)
                    return half4(1, 0, 0, 1);
                #else
                    return half4(0, 0, 0, 1);
                #endif

                return half4(1, 0, 0, 1);
            } 
            ENDHLSL
        }
    }
}
