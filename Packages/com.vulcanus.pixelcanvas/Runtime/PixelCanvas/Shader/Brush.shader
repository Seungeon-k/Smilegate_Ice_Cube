
Shader "Vulcanus/PixelCanvas/Brush"
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
        Pass //0 Brush(Indicator)
        { 
            Cull Back
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha, One One

            HLSLPROGRAM
            #pragma shader_feature_local_fragment LINE
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Brush.hlsl"

            half4 frag (v2f input) : SV_Target
            {
                ClipPartition(input.uv);
                
                float2 textureSize = _SeedTextureSize;
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 preBrushUV = (int2)(_PrvPosition * textureSize) + (sign(_PrvPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(input.uv * textureSize) + 0.5;
                
                float dist = Line(preBrushUV, curBrushUV, uv);
                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp));
                float4 color = half4(input.color.rgb, input.color.a * alpha);

                int4 intColor = color * 255;
                return intColor / 255.0f;
            } 
            ENDHLSL
        }

        Pass //1 Brush(Continuous Indicator)
        { 
            Cull Back
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha, One One

            HLSLPROGRAM
            #pragma shader_feature_local_fragment LINE
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Brush.hlsl"

            half4 frag (v2f input) : SV_Target
            {
                ClipPartition(input.uv);
                
                float2 textureSize = _SeedTextureSize;
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 preBrushUV = (int2)(_PrvPosition * textureSize) + (sign(_PrvPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(input.uv * textureSize) + 0.5;
                
                float dist = Line(preBrushUV, curBrushUV, uv);
                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp));
                
                half brushFlow = lerp(0.1, 1, _BrushFlow);
                float4 color = half4(input.color.rgb, input.color.a * alpha);
                color.a = alpha * brushFlow;
                
                int4 intColor = color * 255;
                return intColor / 255.0f;
            } 
            ENDHLSL
        }

        Pass //2 Eraser(Indicator)
        { 
            Cull Back
            ZWrite Off
            BlendOp Add
            Blend SrcAlpha OneMinusSrcAlpha, Zero One
            
            HLSLPROGRAM
            #pragma shader_feature_local_fragment LINE
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Brush.hlsl"

            half4 frag (v2f input) : SV_Target
            {
                ClipPartition(input.uv);

                float2 textureSize = _SeedTextureSize;
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 preBrushUV = (int2)(_PrvPosition * textureSize) + (sign(_PrvPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(input.uv * textureSize) + 0.5;
                
                float dist = Line(preBrushUV, curBrushUV, uv);
                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp));

                float4 color = SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, input.uv);
                color.a = alpha;

                // float outlineFactor = dist - brushRadius;
                // outlineFactor = 1 - saturate(abs(outlineFactor));
                // outlineFactor = step(0.3, outlineFactor);
                // half4 outlineColor = half4(1, 1, 1, outlineFactor);
                // color = lerp(color, outlineColor, outlineFactor);

                int4 intColor = color * 255;
                return intColor / 255.0f;
            } 
            ENDHLSL
        }

        Pass //3 Eraser(Continuous Indicator)
        { 
            Cull Back
            ZWrite Off
            BlendOp Add
            Blend SrcAlpha OneMinusSrcAlpha, Zero One
            
            HLSLPROGRAM
            #pragma shader_feature_local_fragment LINE
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Brush.hlsl"

            half4 frag (v2f input) : SV_Target
            {
                ClipPartition(input.uv);

                float2 textureSize = _SeedTextureSize;
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 preBrushUV = (int2)(_PrvPosition * textureSize) + (sign(_PrvPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(input.uv * textureSize) + 0.5;
                
                float dist = Line(preBrushUV, curBrushUV, uv);
                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp));

                half brushFlow = lerp(0.1, 1, _BrushFlow);
                float4 color = SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, input.uv);
                color.a = alpha * brushFlow;

                // float outlineFactor = dist - brushRadius;
                // outlineFactor = 1 - saturate(abs(outlineFactor));
                // outlineFactor = step(0.3, outlineFactor);
                // half4 outlineColor = half4(1, 1, 1, outlineFactor);
                // color = lerp(color, outlineColor, outlineFactor);

                int4 intColor = color * 255;
                return intColor / 255.0f;
            } 
            ENDHLSL
        }

        Pass //4 Brush
        { 
            Cull Back
            ZWrite Off
            // BlendOp Add, Max
            // Blend SrcAlpha OneMinusSrcAlpha, One One
            
            BlendOp Max
            Blend One Zero, One One

            HLSLPROGRAM
            #pragma shader_feature_local_fragment LINE
            
            #pragma vertex vert
            #pragma fragment frag

            #include "Brush.hlsl"

            float4 frag (v2f input) : SV_Target
            {
                ClipPartition(input.uv);

                float2 textureSize = _SeedTextureSize;
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 preBrushUV = (int2)(_PrvPosition * textureSize) + (sign(_PrvPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(input.uv * textureSize) + 0.5;
                
                float dist = Line(preBrushUV, curBrushUV, uv);
                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp)) * input.color.a;

                //float4 color = half4(input.color.rgb * (1 - step(alpha, 0)), input.color.a * alpha);
                float4 color = half4(input.color.rgb, input.color.a * alpha);
                return color;
            } 
            ENDHLSL
        }

        Pass //5 Brush(Continuous)
        { 
            Cull Back
            ZWrite Off
            BlendOp Max, Add
            Blend One Zero, One One
            //Blend One One, SrcAlpha One
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Brush.hlsl"

            half4 frag (v2f input) : SV_Target
            {
                ClipPartition(input.uv);

                float2 textureSize = _SeedTextureSize;
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 preBrushUV = (int2)(_PrvPosition * textureSize) + (sign(_PrvPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(input.uv * textureSize) + 0.5;
                
                float dist = Line(preBrushUV, curBrushUV, uv);
                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp));

                half brushFlow = lerp(1, 5, _BrushFlow);
                float4 color = input.color * (1 - step(alpha, 0));
                color.a *= alpha * unity_DeltaTime.x * brushFlow;

                int4 intColor = color * 255;
                return intColor / 255.0f;
            } 
            ENDHLSL
        }

        Pass //6 Eraser
        { 
            Cull Back
            ZWrite Off
            BlendOp Max
            Blend One Zero, One One
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Brush.hlsl"

            half4 frag (v2f input) : SV_Target
            {
                ClipPartition(input.uv);

                float2 textureSize = _SeedTextureSize;
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 preBrushUV = (int2)(_PrvPosition * textureSize) + (sign(_PrvPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(input.uv * textureSize) + 0.5;
                
                float dist = Line(preBrushUV, curBrushUV, uv);
                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp));

                float4 color = SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, input.uv);
                color.a = alpha;

                int4 intColor = color * 255;
                return intColor / 255.0f;
            } 
            ENDHLSL
        }

        Pass //7 Eraser(Continuous)
        { 
            Cull Back
            ZWrite Off
            BlendOp Add
            Blend One Zero, One One
            
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            #include "Brush.hlsl"

            half4 frag (v2f input) : SV_Target
            {
                clip(input.uv.x - _PartitionMin.x);
                clip(input.uv.y - _PartitionMin.y);
                clip(_PartitionMax.x - input.uv.x);
                clip(_PartitionMax.y - input.uv.y);

                float2 textureSize = _SeedTextureSize;
                float brushRadius = _BrushThickness * 0.5f;
                float brushSolidity = (1 - _BrushSoftness);
                float2 preBrushUV = (int2)(_PrvPosition * textureSize) + (sign(_PrvPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(input.uv * textureSize) + 0.5;
                
                float dist = Line(preBrushUV, curBrushUV, uv);
                float temp = (brushRadius * brushSolidity);
                float alpha = saturate(1 - (dist - temp) / (brushRadius - temp));

                half brushFlow = lerp(1, 5, _BrushFlow);
                float4 color = SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, input.uv);
                color.a = alpha * unity_DeltaTime.x * brushFlow;
                
                int4 intColor = color * 255;
                return intColor / 255.0f;
            } 
            ENDHLSL
        }
    }
}
