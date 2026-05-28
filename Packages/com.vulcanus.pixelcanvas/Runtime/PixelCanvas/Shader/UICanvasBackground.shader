// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Vulcanus/PixelCanvas/CanvasBackground"
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

        _SDFOutlineThickness ("SDF Outline Thickness", Range(0, 1)) = 0.5
        _SDFOutlineSoftness ("SDF Outline Softness", Range(0, 1)) = 0.1

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
        //Blend One Zero
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
            half _SDFOutlineThickness;
            half _SDFOutlineSoftness;
            half _ZoomRatio;

            half2 RotateUV(float2 uv, half uvRatio, half rotation)
            {
                half2 mid = half2(uvRatio * 0.5, 0.5);
                uv -= mid;
                uv = float2(
                    cos(rotation) * (uv.x) + sin(rotation) * (uv.y),
                    cos(rotation) * (uv.y) - sin(rotation) * (uv.x)
                );
                uv += mid;
                return uv;
            }

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                half zoomScale  = lerp(1, 0.3, _ZoomRatio);

                half uvRatio = _ScreenParams.x / _ScreenParams.y;
                float radian = radians(_Time.x);
                OUT.texcoord = v.texcoord;

                OUT.texcoord -= 0.5;
                OUT.texcoord *= 2;
                OUT.texcoord *= zoomScale;
                OUT.texcoord *= 0.5;
                OUT.texcoord += 0.5;

                OUT.texcoord.x *= uvRatio;
                OUT.texcoord = RotateUV(OUT.texcoord, uvRatio, radian);
                OUT.texcoord = TRANSFORM_TEX(OUT.texcoord, _MainTex);
                OUT.texcoord.x -= _Time.x;

                OUT.color = v.color * _Color;
                return OUT;
            }

            float invLerp(float from, float to, float value)
            {
                return (value - from) / (to - from);
            }

            fixed4 frag(v2f IN) : SV_Target
            {
                float2 uv = frac(IN.texcoord);
                half4 mainTexture = tex2D(_MainTex, uv);

                float sdf = mainTexture.r;
                half sdfSoftness = lerp(0.1, 1, _ZoomRatio);

                sdf *= 10;
                float thicknessRange = 1 - smoothstep(_SDFOutlineThickness - sdfSoftness, _SDFOutlineThickness + sdfSoftness, sdf);
                sdf = thicknessRange;

                // float h = _Time.x - 1 - outlineMask;
                // float3 rgb = clamp(abs(fmod(h * 6.0 + float3(0.0,4.0,2.0), 6.0) -3.0) - 1.0, 0.0, 1.0);
                // rgb = lerp(rgb, float3(1, 1, 1), 1.0 - smoothstep(0.0, 0.02, abs(outlineMask)));
                // return half4(rgb, 1);

                half4 color = IN.color;
                color.a *= sdf;
                return color;
            }
        ENDCG
        }
    }
}
