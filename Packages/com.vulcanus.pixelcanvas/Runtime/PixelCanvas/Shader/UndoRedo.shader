
Shader "Vulcanus/PixelCanvas/UndoRedo"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
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
        Pass // Pass 0
        { 
            Cull Back
            ZWrite Off
            BlendOp RevSub
            Blend One One
            // BlendOp Add
            // Blend One Zero
            
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
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST; 
                uint4 _Params; //x : nUVOffset.x, y : nUVOffset.y, z : width, w : height
                int _Sign;
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
                clip(input.vertex.xy - _Params.xy);
                clip((_Params.xy + (_Params.zw)) - input.vertex.xy);
                
                float3 diffColor = LOAD_TEXTURE2D_X(_MainTex, input.vertex.xy - _Params.xy).rgb;
                return float4(diffColor * _Sign, 0);
            } 
            ENDHLSL
        }

        Pass // Pass 1
        { 
            Cull Back
            ZWrite Off
            BlendOp Add
            Blend One One
            
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
            
            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST; 
                uint4 _Params; //x : nUVOffset.x, y : nUVOffset.y, z : width, w : height
                int _Sign;
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
                clip(input.vertex.xy - _Params.xy);
                clip((_Params.xy + (_Params.zw)) - input.vertex.xy);
                
                float3 diffColor = LOAD_TEXTURE2D_X(_MainTex, input.vertex.xy - _Params.xy).rgb;
                return float4(-diffColor * _Sign, 0);
            } 
            ENDHLSL
        }
    }
}
