// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Vulcanus/PixelCanvas/PaintBoard2DView"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255
        _ColorMask ("Color Mask", Float) = 15

        _StripeThickness ("Stripe Thickness", Range(0.01, 0.5)) = 0.5
        _StripeColor ("Stripe Color", Color) = (1, 1, 0, 1)
        _Alpha ("Alpha", Float) = 0

        [Header(Partition)]
        _PartitionTransitionSpeed ("Partition Transition Speed", Range(1, 10)) = 1

        [Header(UV Outline)]
        _OutlineStripeScale ("Outline Stripe Scale", Float) = 100
        _SDFOutlineThickness ("SDF Outline Thickness", Range(0.000001, 1)) = 0.5
        _SDFOutlineSoftness ("SDF Outline Softness", Range(0, 1)) = 0.1

        _IndicatorThickness ("Indicator Thickness", Range(1, 10)) = 0.5

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

            TEXTURE2D_X(_MainTex); SAMPLER(sampler_MainTex);
            half4 _Color;
            float4 _ClipRect;
            float4 _MainTex_ST;
            half4 _StripeColor;
            half _StripeThickness;
            half _Alpha;

            half _PartitionTransitionSpeed;

            half _OutlineStripeScale;             
            half _SDFOutlineThickness;
            half _SDFOutlineSoftness;

            half _IndicatorThickness;

            v2f vert(appdata_t v)
            {
                v2f OUT;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(OUT);
                OUT.worldPosition = v.vertex;
                OUT.vertex = TransformObjectToHClip(OUT.worldPosition);
                OUT.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
                return OUT;
            }

            float invLerp(float from, float to, float value)
            {
                return (value - from) / (to - from);
            }

            half4 frag(v2f IN) : SV_Target
            {
                half4 color = SAMPLE_TEXTURE2D_X(_MainTex, sampler_MainTex, IN.texcoord);
                half luminance = 0.299f * color.r + 0.587f * color.g + 0.114f * color.b;
                half4 contrastColor = float4(step(luminance, 0.5f).rrr, 1);

                //Partition Masking
                {
                    float timerRatio = saturate((_Time.y - _PartitionChangedTime) * _PartitionTransitionSpeed);
                    half2 partitionSize = _PartitionMax - _PartitionMin;
                    half2 partitionHalfSize = partitionSize * 0.5f;
                    half distance = SDFBox(IN.texcoord - _PartitionMin - partitionHalfSize, partitionHalfSize);
                    half newPartitionMask = (step(distance, 0));
                    partitionSize = _PrvPartitionMax - _PrvPartitionMin;
                    partitionHalfSize = partitionSize * 0.5f;
                    distance = SDFBox(IN.texcoord - _PrvPartitionMin - partitionHalfSize, partitionHalfSize);
                    half prvPartitionMask = (step(distance, 0));
                    half partitionMask = lerp(prvPartitionMask, newPartitionMask, timerRatio);

                    float stripeMask = (IN.texcoord.x - IN.texcoord.y) + _Time.x * 0.3;
                    stripeMask /= _StripeThickness;
                    stripeMask = frac(stripeMask);
                    stripeMask = step(0.5, stripeMask);
                    color.rgb = (_PartitionLock == true) ? 
                        lerp(_StripeColor.rgb * stripeMask, color.rgb, partitionMask) : 
                        lerp(luminance, color.rgb, partitionMask);
                    color.a = (_PartitionLock == true) ? 1 : lerp(0.5, 1, partitionMask);
                }
                // SDF Outline
                {
                    //Parts Outline
                    float2 outlineMask = SAMPLE_TEXTURE2D_X(_UVOutlineTex, sampler_UVOutlineTex, IN.texcoord).rg;

                    float uvOutlineMask = outlineMask.r;
                    float thicknessRange = 1 - smoothstep(-_SDFOutlineThickness, _SDFOutlineThickness, uvOutlineMask);
                    float softnessRatio = saturate(invLerp(0, _SDFOutlineSoftness, thicknessRange));
                    uvOutlineMask = lerp(0, 1, softnessRatio);
                    float stripe = (IN.texcoord.x - IN.texcoord.y) + _Time.x * 0.3;
                    stripe *= _OutlineStripeScale;
                    stripe = frac(stripe);
                    stripe = step(0.5h, abs(stripe));
    
                    //Partition Outline
                    float lerpFactor = 1 - smoothstep(-_SDFOutlineThickness, _SDFOutlineThickness, outlineMask.g);
                    softnessRatio = saturate(invLerp(0, _SDFOutlineSoftness, lerpFactor));
                    uvOutlineMask += lerp(0, 1, softnessRatio);

                    color.rgb = lerp(color.rgb, contrastColor, stripe * uvOutlineMask);
                }

                //Grid
                float2 gridUV = IN.texcoord * _SeedTextureSize;
                gridUV = frac(gridUV);
                gridUV = (gridUV - 0.5) * 2;
                gridUV *= gridUV;
                gridUV *= gridUV;
                gridUV *= 0.85;
                gridUV = 1 - gridUV;
                half gridRatio = (1 - saturate(gridUV.x + gridUV.y)) * _Alpha;
                color = lerp(color, contrastColor, gridRatio);

                // //Brush Indicator
                half indicatorThickness = ((1.0 / 6400) * _IndicatorThickness);
                half brushRadius = _BrushThickness * 0.5f;
                half2 preBrushUV = (int2)(_CurPosition * _SeedTextureSize) + (sign(_CurPosition) * 0.5);
                half2 curBrushUV = (int2)(_CurPosition * _SeedTextureSize) + (sign(_CurPosition) * 0.5);

                half count = 0;
                for (int idx=0 ; idx<5 ; ++idx)
                {
                    half2 offset = BRUSH_INDICATOR_OFFSET[idx] * indicatorThickness;
                    half2 uv = IN.texcoord + offset;
                    half2 nUV = (int2)(uv * _SeedTextureSize) + 0.5;
                    
                    half dist = SDFLine(preBrushUV, curBrushUV, nUV) + 1;
                    dist = saturate(1 - (dist - brushRadius));
                    count += step(0.000001, dist);
                    //count += step(0.000001, 1 - (dist / brushRadius));
                }

                half brushIndicatorMask = count / 5.0;
                brushIndicatorMask = (1 - step(brushIndicatorMask, 0)) * (1 - step(1, brushIndicatorMask));
                half brushLuminance = 0.299f * _BrushColor.r + 0.587f * _BrushColor.g + 0.114f * _BrushColor.b;
                half brushContrast = step(brushLuminance, 0.5f);
                color.rgb = lerp(color.rgb, brushContrast, brushIndicatorMask * _BrushIndicatorVisible);

                return color;
            }
            ENDHLSL
        }
    }
}


/*
    // outlineMask = smoothstep(_SDFOutlineThickness - _SDFOutlineSoftness, _SDFOutlineThickness + _SDFOutlineSoftness, outlineMask);
    // outlineMask = 1 - outlineMask;
    // return half4(outlineMask, 0, 0, 1);

    float3 t = SAMPLE_TEXTURE2D_X(_UVOutlineTex, sampler_UVOutlineTex, IN.texcoord);
    float2 dir = float2(t.y, t.z);
    dir = (dir - 0.5) * 2;
    dir = normalize(dir);

    float2 cir = float2(0, 1);
    float2 cir = float2(sin(_Time.y), cos(_Time.y));
    float2 tex = IN.texcoord;
    tex = frac(tex * 20);
    tex = normalize((tex - 0.5) * 2);
    float t1 = dot(tex, cir);
    float angle = acos(t1) * 180 / 3.14159;
    float signValue = sign(cross(float3(tex, 0), float3(cir, 0)).z);
    if (signValue < 0)
        angle = 360 - angle;
    t1 = angle / 360;
    t1 = frac(t1 * 20);
    t1 = step(0.5h, abs(t1));
    outlineMask = smoothstep(_SDFOutlineThickness - _SDFOutlineSoftness, _SDFOutlineThickness + _SDFOutlineSoftness, outlineMask);
    outlineMask = 1 - outlineMask;
    float pattern = t1;
    pattern *= _OutlineStripeScale;
    color.rgb = lerp(color.rgb, contrastColor, pattern * outlineMask);
*/