Shader "Vulcanus/PixelCanvas/ZoneBounds"
{
    Properties
    {
        _MainTex ("Main Tex (vertical strip)", 2D) = "white" {}
        _UVOutlineTex ("UV Outline Texture", 2D) = "white" {}

        [Header(Render State)]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10
    }

    SubShader
    {
        Tags {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }
            
            Blend [_BlendScr] [_BlendDst], One One
            ZWrite Off
            Cull Front
            //ZWrite Off

            HLSLPROGRAM

            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"
            #include "Common.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_UVOutlineTex); SAMPLER(sampler_UVOutlineTex);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
            CBUFFER_END

            struct appdata 
            {
                float4 vertex : POSITION;
                float3 normalOS : NORMAL;
                float2 uv : TEXCOORD0;
                
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS : NORMAL;
                float2 uv : TEXCOORD0;
                float2 texcoord : TEXCOORD1;
                float4 positionSS : TEXCOORD2; 
                float4 objectPositionSS : TEXCOORD3;
            
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);
                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.normalWS = TransformObjectToWorldDir(v.normalOS);

                o.uv = v.uv;
                o.texcoord = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(i);

                //half d = dot(i.normalWS, normalize(half3(1, -1, 1)));
                //return half4(i.normalWS.xyz * d, 1);

                //half2 backgroundUV = i.uv * 5;
                // backgroundUV.x -= _Time.x;
                // backgroundUV.y -= _Time.x;
                //half4 color = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, backgroundUV);

                float2 gridUV = i.texcoord;
                gridUV = frac(gridUV);
                gridUV = (gridUV - 0.5) * 2;
                gridUV *= 1.04;
                gridUV *= gridUV;
                gridUV *= gridUV;
                gridUV *= gridUV;
                gridUV = 1 - gridUV;
                half gridRatio = (1 - saturate(gridUV.x + gridUV.y));

                half2 outline = abs((i.uv - 0.5) * 2);
                half o = max(outline.x, outline.y);
                o -= 0.99;
                o = step(0, o);

                half alpha = gridRatio + o;
                alpha = saturate(alpha);
//                alpha = max(alpha, color.a * 0.3);

                return half4(1, 1, 1, alpha);
            }

            ENDHLSL
        }
    }
}