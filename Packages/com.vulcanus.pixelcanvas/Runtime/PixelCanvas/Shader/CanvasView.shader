// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Vulcanus/PixelCanvas/CanavsView"
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

        _StripeThickness ("Stripe Thickness", Range(0.01, 0.5)) = 0.5
        _StripeColor ("Stripe Color", Color) = (1, 1, 0, 1)
        _Alpha ("Alpha", Float) = 0

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
            #include "Global.hlsl"
            #include "Common.hlsl"

            #pragma multi_compile_local _ UNITY_UI_CLIP_RECT
            #pragma multi_compile_local _ UNITY_UI_ALPHACLIP

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float2 texcoord  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            half4 _StripeColor;
            half _StripeThickness;
            half _Alpha;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = UnityObjectToClipPos(OUT.worldPosition);

                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                // //OUT.texcoord.x /= 2;

                // OUT.texcoord.xy = lerp(_Partition.xy, _Partition.zw, OUT.texcoord.xy);
                // // OUT.texcoord.xy += _Partition.xy;
                // // OUT.texcoord.xy /= _Partition.zw;
                return OUT;
            }

            half4 frag(v2f IN) : SV_Target
            {
                half4 color = (tex2D(_MainTex, IN.texcoord) + _TextureSampleAdd);
                half luminance = 0.299f * color.r + 0.587f * color.g + 0.114f * color.b;
                half4 contrastColor = float4(step(luminance, 0.5f).rrr, 1);

                float stripeMask = IN.texcoord.x - (IN.texcoord.y - _Time.x * 0.3);
                stripeMask /= _StripeThickness;
                stripeMask = frac(stripeMask);
                stripeMask = step(0.5, stripeMask);

                //Partition Masking
                half2 beg = _PartitionMin;
                half2 end = _PartitionMax;
                half2 partitionSize = end - beg;
                half2 partitionHalfSize = partitionSize * 0.5f;
                half distance = SDFBox(IN.texcoord - beg - partitionHalfSize, partitionHalfSize);
                half region = step(distance, 0);
                color.rgb = lerp(_StripeColor.rgb * stripeMask, color.rgb, region);
                //color.rgb *= clamp(region, 0.1, 1);

                //Grid
                float2 gridUV = IN.texcoord * _SeedTextureSize;
                gridUV = frac(gridUV);
                gridUV = (gridUV - 0.5) * 2;
                gridUV *= gridUV;
                gridUV *= gridUV;
                gridUV *= 0.85;
                gridUV = 1 - gridUV;
                half gridRatio = (1 - saturate(gridUV.x + gridUV.y)) * _Alpha * region;
                color = lerp(color, contrastColor, gridRatio * region);

                //Brush Grid
                float brushRadius = _BrushThickness * 0.5f;
                float2 preBrushUV = (int2)(_CurPosition * _SeedTextureSize) + (sign(_CurPosition) * 0.5);
                float2 curBrushUV = (int2)(_CurPosition * _SeedTextureSize) + (sign(_CurPosition) * 0.5);
                float2 uv = (int2)(IN.texcoord * _SeedTextureSize) + 0.5;
                half2 brushGridUV = frac(IN.texcoord * _SeedTextureSize);
                brushGridUV = frac(brushGridUV);
                brushGridUV = (brushGridUV - 0.5) * 2;
                brushGridUV *= 1.1;
                brushGridUV *= brushGridUV;
                brushGridUV *= brushGridUV;
                brushGridUV *= brushGridUV;
                brushGridUV = 1 - brushGridUV;
                half brushGridRatio = (1 - saturate(brushGridUV.x + brushGridUV.y));
                float dist = SDFLine(preBrushUV, curBrushUV, uv);
                dist = 1 - ((dist - brushRadius) / 0);
                brushGridRatio = saturate(dist * brushGridRatio);
                color = lerp(color, contrastColor, brushGridRatio);

                return lerp(color, contrastColor, gridRatio);
            }
        ENDCG
        }
    }
}
