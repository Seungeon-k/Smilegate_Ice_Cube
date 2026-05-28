
Shader "Vulcanus/PixelCanvas/BrushRangeBaker"
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
        Pass //0 Brush
        { 
            Cull Back
            ZWrite Off
            Blend One Zero
            //Blend One One, SrcAlpha One
            //Blend One OneMinusSrcColor
            
            HLSLPROGRAM
            //#pragma shader_feature_local_fragment LINE
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
            #include "Global.hlsl"
            #include "Common.hlsl"

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                return o; 
            }

            half4 frag (v2f input) : SV_Target
            {
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 textureSize = 21;//_Parameters0.zw;
                
                float2 nUV = (int2)(input.uv * textureSize) + 0.5;
                float dist = length(nUV - (float2(0.5, 0.5) * textureSize));

                //float dist = Line(preBrushUV, curBrushUV, uv);
                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp));
                return half4(_BrushColor.rgb, _BrushColor.a * alpha);
            } 
            ENDHLSL
        }

        Pass //1 Eraser
        { 
            Cull Back
            ZWrite Off
            Blend One Zero
            //Blend One One, SrcAlpha One
            //Blend One OneMinusSrcColor
            
            HLSLPROGRAM
            //#pragma shader_feature_local_fragment LINE
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"
            #include "Global.hlsl"
            #include "Common.hlsl"

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = v.uv;
                return o; 
            }

            half4 frag (v2f input) : SV_Target
            {
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 textureSize = 21;//_Parameters0.zw;
                
                float2 nUV = (int2)(input.uv * textureSize) + 0.5;
                float dist = length(nUV - (float2(0.5, 0.5) * textureSize));

                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp));
                return half4(1, 1, 1, alpha);
            } 
            ENDHLSL
        }
    }
}
