
Shader "Vulcanus/PixelCanvas/BrushIndicator"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        _BrushColor ("Tint", Color) = (1,1,1,1)
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
        Pass //Dot Brush
        { 
            Cull Back
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            TEXTURE2D_X(_MainTex);
            SAMPLER(sampler_MainTex); 
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST; 
                float4 _BrushColor;
            CBUFFER_END

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.color = v.color * _BrushColor; 
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f input) : SV_Target
            {
                half4 col = SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, input.uv) * input.color;

                half4 inverted = 1 - col;
                col.rgb = lerp(inverted, col, col.a);
                col.a = 1;
                return col;
            } 
            ENDHLSL
        }
        
    }
}
