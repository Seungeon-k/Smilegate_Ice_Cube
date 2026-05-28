Shader "Vulcanus/PixelCanvas/ModelBrushIndicator"
{
    Properties
    {
        _MainTex ("Main Tex (vertical strip)", 2D) = "white" {}

        _Parameters0 ("Parameters 0", Vector) = (0, 0, 0, 0)

        [Header(Render State)]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10
    }

    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend [_BlendScr] [_BlendDst], One One
            //ZWrite Off
            Cull Off

            HLSLPROGRAM

            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Common.hlsl"
            #include "Global.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
            CBUFFER_END

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float2 texcoord : TEXCOORD0;
                float3 viewDirectionWS : TEXCOORD1;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                //v.vertex.z *= _DisappearRatio;
                //v.vertex.xyz += forward * (1 - _DisappearRatio);

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.normalWS = TransformObjectToWorldDir(v.normal);
                o.texcoord = v.texcoord;
                o.viewDirectionWS = normalize(GetWorldSpaceViewDir(positionWS));
                return o;
            }

            float Line(float2 beg, float2 end, float2 coord)
            {
                float2 toLine = end - beg;
                float2 toPos = coord - beg;
                float h = saturate(dot(toPos, toLine) / dot(toLine, toLine));
                float dist = length(toPos - (toLine * h));
                return dist;
            }

            half4 frag (v2f i, float cullFace : VFACE) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(i);

                half4 color = _BrushColor; //SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.texcoord);
                half luminance = 0.299f * color.r + 0.587f * color.g + 0.114f * color.b;
                half4 contrastColor = float4(step(luminance, 0.5f).rrr, 1);

                float2 textureSize = _SeedTextureSize;
                float brushRadius = _BrushThickness * 0.5f;

                float2 preBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * textureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(i.texcoord * textureSize) + 0.5;
                
                half2 gridUV = frac(i.texcoord * textureSize);
                gridUV = frac(gridUV);
                gridUV = (gridUV - 0.5) * 2;
                gridUV *= 1.02;
                gridUV *= gridUV;
                gridUV *= gridUV;
                gridUV *= gridUV;
                gridUV = 1 - gridUV;
                half gridRatio = (1 - saturate(gridUV.x + gridUV.y));

                float dist = Line(preBrushUV, curBrushUV, uv);
                dist = 1 - ((dist - brushRadius) / 0);

                float alpha = saturate(dist * gridRatio);

                return half4(contrastColor.rgb, alpha);

                // float x = abs(ddx(alpha));
                // float y = abs(ddy(alpha));
                // alpha = step(0.0000001, x + y);
                // return half4(contrastColor.rgb, alpha);
            }

            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
