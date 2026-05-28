Shader "ZAMMYSMITH/SpecialFX/SkillIndicator_01_GF"
{
    Properties
    {
        [Header(add script. ScreenSpaceDecal)]        
        [Space(10)]
        [HDR] _BaseColor ("BaseColor", Color) = (1, 1, 1, 1)
        [HDR] _MaskColor("MaskColor" , Color) = (1, 1, 1, 1)

        //[NoScaleOffset] 
        _MainTex ("Main Tex (vertical strip)", 2D) = "white" {}
        [Space(10)]
        //[NoScaleOffset] 
        _FlowTex ("Flow Tex (vertical strip)", 2D) = "black" {}
        _FlowSpeed ("Flow Speed", Float) = 0.5

        [Header(Render State)]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10

        [Space(10)]
        _MorphRatio ("Appear Ratio", Range(-1, 1)) = 0.0
        _MorphWidth ("Morph Width", Range(0, 1)) = 0.1
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
            
            Blend [_BlendScr] [_BlendDst]
            ZWrite Off

            HLSLPROGRAM

            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Common.hlsl"

            TEXTURE2D(_MainTex); SAMPLER(sampler_MainTex);
            TEXTURE2D(_FlowTex); SAMPLER(sampler_FlowTex);
            // intended to use SAMPLER(linear_clamp_sampler_FlowTex); but freeing settings just in case

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            half4 _FlowTex_ST;
            half4 _BaseColor;
            half4 _MaskColor;
            half _FlowSpeed;
            half _MorphRatio;
            half _MorphWidth;
            CBUFFER_END

            struct appdata 
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f 
            {
                float4 clipPos : SV_POSITION;
                float2 uv : TEXCOORD0;
            
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                UNITY_SETUP_INSTANCE_ID(v);

                
                half3 forward = UNITY_MATRIX_M._31_32_33;

                //v.vertex.z *= _DisappearRatio;
                //v.vertex.xyz += forward * (1 - _DisappearRatio);

                half3 wPos = TransformObjectToWorld(v.vertex.xyz);
                half4 clipPos = TransformWorldToHClip(wPos.xyz);
                half4 screenPos = ComputeScreenPos(clipPos);

                o.clipPos = clipPos;
                o.uv = v.uv;
                return o;
            }

            half4 frag (v2f i) : SV_TARGET
            {
                UNITY_SETUP_INSTANCE_ID(i);

                half4 mainTex = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, i.uv);

                half2 flowUV = i.uv + _FlowTex_ST.zw;
                flowUV = flowUV * _FlowTex_ST.xy;
                flowUV.x -= _Time.y * _FlowSpeed;
                half4 flowTex = SAMPLE_TEXTURE2D(_FlowTex, sampler_FlowTex, flowUV);

                half ratio = _MorphRatio * (1 + _MorphWidth);
                half alpha = (ratio < 0) ?  ((1 - i.uv.x) + ratio) / _MorphWidth : 1 - (ratio - i.uv.x) / _MorphWidth;
                alpha = saturate(alpha);
                
                half4 col;
                col.rgb = lerp(_BaseColor.rgb, _MaskColor.rgb, flowTex.r);
                col.a = max(mainTex.r, flowTex.r) * alpha;
                return col;
            }

            ENDHLSL
        }
    }
}