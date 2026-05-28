// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "ZAMMYSMITH/UI/ScreenTransition(0)_GF"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        //_NoiseTex ("Noise Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        [Header(Screen Transition)]
        [IntRange]_PartitionXCount ("Partition X Count", Range(3, 30)) = 10
        _ProgressRatio ("Progress Ratio", Range(0, 1)) = 0

        [Header(Render State)]
        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15


        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP
            #pragma shader_feature_local _ _RANDOM_COLOR

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };
            
            struct v2f
            {
                float4 vertex   : SV_POSITION;
                half4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float2 texcoord2 : TEXCOORD1;
                float4 worldPosition : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            half4 _Color;
            half4 _TextureSampleAdd;
            float4 _ClipRect;
            half _PartitionXCount;
            half _ProgressRatio;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.texcoord2 = TRANSFORM_TEX(v.texcoord, _NoiseTex);
                OUT.color = v.color * _Color;
                return OUT;
            }

            half3 palette(in half3 a, in half3 b, in half3 c, in half3 d )
            {
                return a + b*cos( 6.283185*(_Time.x * c + d) );
            }


            float InverseLerp(float a, float b, float x)
            {
                return (x - a)/(b - a);
            }

            half4 frag(v2f IN) : SV_Target
            {                
                half partitionXCount = _PartitionXCount;
                half partitionSize = _ScreenParams.x / partitionXCount;
                half partitionYCount = _ScreenParams.y / partitionSize;

                half time = 5;
                //_ProgressRatio = (_Time.z % time) / (time - 1);
                //_ProgressRatio = saturate(_ProgressRatio);

                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                
#ifdef UNITY_UI_CLIP_RECT
                color.a *= UnityGet2DClipping(IN.worldPosition.xy, _ClipRect);
#endif
                
#ifdef UNITY_UI_ALPHACLIP
                clip (color.a - 0.001);
#endif
                
                float2 vertex = IN.vertex.xy;
                vertex.y -= _ScreenParams.y * 0.5;
                float2 partitionUV = (int2)(vertex / partitionSize) / float2(partitionXCount, partitionYCount);
                partitionUV = abs(partitionUV);
                half2 fraction = frac(vertex / partitionSize);
                half2 distance = abs(fraction - 0.5);
                //half noise = tex2D(_NoiseTex, partitionUV).r;
                //half uvFade = saturate(partitionUV.x + lerp(-1 - noise, 0.5 + noise, _ProgressRatio));
                half uvFade = saturate(partitionUV.x + lerp(-1, 1, _ProgressRatio)) * lerp(1, 0, partitionUV.y);
                half alphaA = 0.501 - (distance.x + distance.y);
                alphaA = step(uvFade, alphaA);

                vertex = IN.vertex.xy;
                vertex.x += partitionSize * 0.5;
                vertex.y -= _ScreenParams.y * 0.5;
                vertex.y = abs(vertex.y) + (partitionSize * 0.5);
                partitionUV = (vertex / partitionSize);
                partitionUV = abs(partitionUV);
                partitionUV = (int2)partitionUV;
                partitionUV /= float2(partitionXCount, partitionYCount);
                fraction = frac(vertex / partitionSize);
                distance = abs(fraction - 0.5);
                //noise = tex2D(_NoiseTex, partitionUV).r;
                //uvFade = saturate(partitionUV.x + lerp(-1 - noise, 0.5 + noise, _ProgressRatio)) * lerp(1, 0, partitionUV.y);
                uvFade = saturate(partitionUV.x + lerp(-1, 1, _ProgressRatio)) * lerp(1, 0, partitionUV.y);
                half alphaB = 0.501 - (distance.x + distance.y);
                alphaB = step(uvFade, alphaB);

                half alpha = alphaA + alphaB;
                clip(alpha - 0.001);
                //color.a = alpha;

                return color;
            }

        ENDCG
        }
    }
}