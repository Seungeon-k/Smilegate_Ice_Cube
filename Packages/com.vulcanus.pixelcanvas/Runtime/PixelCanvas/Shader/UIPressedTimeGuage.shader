// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Vulcanus/PixelCanvas/PressedTimeGuage"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _OuterBounds ("Outer Bounds", Range(1, 0)) = 1
        _OuterSoftness ("Outer Softness", Range(0, 1)) = 1

        _InnerBounds ("Inner Bounds", Range(1, 0)) = 0.5
        _InnerSoftness ("Inner Softness", Range(0, 1)) = 1

        //_Ratio ("Ratio", Range(0, 1)) = 1
        _CancelDirection ("Cancel Direction", Vector) = (0, 0, 0, 0)

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
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            half4 _CancelDirection;
            half _OuterBounds;
            half _OuterSoftness;
            half _InnerBounds;
            half _InnerSoftness;
            half _PressTimeGuageRatio;
            
            //Global Value
            half _TimeGuagePressedTime;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.texcoord -= 0.5;
                OUT.texcoord *= 2;
                OUT.color = v.color * _Color;
                return OUT;
            }

            half4 frag(v2f IN) : SV_Target
            {
                //half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd) * IN.color;
                half4 color = IN.color;

                float range = abs(length(IN.texcoord));
                float elapsedTime = _Time.y - _TimeGuagePressedTime;
                float pulseRatio = (1 + pow(frac(elapsedTime * 0.8) - 1, 3)) * 1.2;
                pulseRatio = 1 - saturate(abs(range - pulseRatio) / 0.2);
                
                // half dirLength = length(_CancelDirection.xy);
                // half2 direction = _CancelDirection.xy / dirLength;
                // dirLength = clamp(0, 0.6, dirLength);
                // half2 test = IN.texcoord.xy - (direction * dirLength);
                // half len = length(test);
                // len = 1 - len;
                // half knobAlpha = smoothstep(0.7 - _OuterSoftness, 0.7 + _OuterSoftness, len);
                
                half ratio = 1 - _PressTimeGuageRatio;
                range = 1 - range;
                half outerAlpha = smoothstep(ratio + _OuterBounds - _OuterSoftness, ratio + _OuterBounds + _OuterSoftness, range);
                half innerAlpha = smoothstep(_InnerBounds - _InnerSoftness, _InnerBounds + _InnerSoftness, range);

                color.rgb = lerp(half3(1, 0, 0), color.rgb, step(ratio, 0.0001));
                color.rgb = lerp(half3(1, 1, 1), color.rgb, outerAlpha);
                color.rgb = lerp(color.rgb, half3(1, 1, 1), pulseRatio);

                color.a *= saturate(outerAlpha - innerAlpha - pulseRatio);
                return color;
            }
        ENDCG
        }
    }
}
