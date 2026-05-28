
Shader "Vulcanus/PixelCanvas/ColorDiff"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        [PerRendererData]_SourceTex ("Texture", 2D) = "white" {}
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
            ZWrite Off
            // BlendOp RevSub
            // Blend SrcAlpha One
            //ColorMask 0
            //BlendOp Add
            //Blend OneMinusDstColor Zero, Zero One
            //Blend OneMinusDstColor Zero
            //Blend SrcAlpha OneMinusSrcAlpha
            Blend One Zero
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D_X(_MainTex);
            SAMPLER(sampler_MainTex); 
            
            TEXTURE2D_X(_SourceTex);
            SAMPLER(sampler_SourceTex); 

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST; 
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f input) : SV_Target
            {
                float3 seedColor = LOAD_TEXTURE2D_X(_MainTex, input.vertex.xy).rgb;
                float3 mergedColor = LOAD_TEXTURE2D_X(_SourceTex, input.vertex.xy).rgb;
                return float4(mergedColor - seedColor, 1);
            } 
            ENDHLSL
        }
    }
}
