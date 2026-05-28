Shader "Vulcanus/PixelCanvas/ResultViewer"
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
        _ColorMask ("Color Mask", Float) = 15

        _Thickness ("Thickness", Range(0.0, 1.0)) = 0
        _Softness ("Softness", Range(0.0, 1.0)) = 0.5

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
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
                half4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            half4 _Color;
            half4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;

            float _Toggle;
            float _ToggleTime;
            float _Thickness;
            float _Softness;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                
                OUT.worldPosition = v.vertex;
                OUT.vertex = TransformObjectToHClip(OUT.worldPosition);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                OUT.color = v.color * _Color;
                return OUT;
            }

            float SDFRoundedBox( in float2 p, in float2 b, in float4 r )
            {
                r.xy = (p.x > 0.0) ? r.xy : r.zw;
                r.x  = (p.y > 0.0) ? r.x  : r.y;
                float2 q = abs(p)-b + r.x;
                return min(max(q.x,q.y),0.0) + length(max(q,0.0)) - r.x;
            }

            half4 frag(v2f IN) : SV_Target
            {
                half4 color = tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd;

                float elapsedTime = _Time.y - _ToggleTime;

                float ratio = saturate(elapsedTime / 0.2);
                ratio = lerp(1 - ratio, ratio, _Toggle);
                
                //float pulseRatio = (1 + pow(frac(elapsedTime * 0.8) - 1, 3)) * 1.2;
                //return half4(pulseRatio, 0, 0, 1);

                color.rgb = lerp(IN.color.rgb, color.rgb, color.a);
                
                float2 texcoord = IN.texcoord.xy;
                texcoord -= 0.5;
                texcoord *= 2;
                float sdf = SDFRoundedBox(texcoord, float2(_Thickness, _Thickness), lerp(float4(0.2, 0.2, 0.2, 1), float4(0.1, 0.1, 0.1, 0.2), ratio));
                float alpha = smoothstep(-_Softness, _Softness, sdf);
                alpha = 1 - alpha;

                half modelAlpha = saturate(alpha * 5);
                color.a = max(IN.color.a * alpha, color.a) * modelAlpha;
                return color;
            }
            ENDHLSL
        }
    }
}