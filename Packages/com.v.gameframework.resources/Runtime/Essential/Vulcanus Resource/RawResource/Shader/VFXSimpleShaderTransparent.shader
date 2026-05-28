Shader "ZAMMYSMITH/VFX/SimpleShaderTransparent"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR]_Color("Color", Color) = (1,1,1,1)
         
        //Clipping
        [Space(20)]
        [Header(Cut Off)]
        _Cutoff("        -Cutoff", Range(0, 1)) = 0
        _CutoffSoftness("        -Cutoff softness", Range(0, 1)) = 0

        //[HDR]_BurnCol("Burn color", Color) = (1,1,1,1)
        //_BurnSize("Burn size", Range(0, 1)) = 0

        //Banding
        [Space(20)]
        [Toggle(BANDING)] BANDING("BANDING (default = off)", Float) = 0
        _Bands("        -Number of bands", float) = 3

        [Space(20)]
        [Header(UV Settings)]
        [Toggle(POLAR)] POLAR("POLAR (default = off)", Float) = 0
        _PanningSpeed("        -Panning speed (XY main texture - ZW displacement texture)", Vector) = (0,0,0,0)
        //Polar coordinates
 
        //Displacement
        [Space(20)]
        _DisplacementAmount("Displacement", float) = 0
        _DisplacementGuide("        -DisplacementGuide", 2D) = "white" {}
 
        //Circle mask
        [Space(20)]
        [Toggle(CIRCLE_MASK)] CIRCLE_MASK("CIRCLE_MASK (default = off)", Float) = 0
        _OuterRadius("        -Outer radius", Range(0,1)) = 0.5
        _InnerRadius("        -Inner radius", Range(-1,1)) = 0
        _Smoothness("        -Smoothness", Range(0,1)) = 0.2
 
        //Rect mask
        [Space(20)]
        [Toggle(RECT_MASK)] RECT_MASK("RECT_MASK (default = off)", Float) = 0
        _RectWidth("        -Rectangle width", float) = 0
        _RectHeight("        -Rectangle height", float) = 0
        _RectMaskCutoff("        -Rectangle mask cutoff", Range(0,1)) = 0
        _RectSmoothness("        -Rectangle mask smoothness", Range(0,1)) = 0        

        //Softness
        [Space(20)]
        [Toggle(SOFT_BLEND)] SOFT_BLEND("SOFT_BLEND (default = off)", Float) = 0
        _IntersectionThresholdMax("        -Intersection Threshold Max", float) = 1

        [Header(Fog)]
        [Toggle(_FOG)] _FOG("    Fog (default = on)", Float) = 1

        //Render State
        [Space(20)]
        [Enum(UnityEngine.Rendering.CullMode)] _Culling("Cull Mode", Int) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Offset -1, -1
        Cull [_Culling]
        LOD 100
 
        Pass
        {
            HLSLPROGRAM

            #pragma shader_feature SOFT_BLEND
            #pragma shader_feature BANDING
            #pragma shader_feature POLAR
            #pragma shader_feature CIRCLE_MASK
            #pragma shader_feature RECT_MASK
            #pragma shader_feature _FOG

            #pragma multi_compile_fog
 
            //Vertex, Fragment Shader
            #pragma vertex      vert
            #pragma fragment    frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
 
            sampler2D _MainTex;
            sampler2D _DisplacementGuide;

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                half4 _Color;
 
                float _Cutoff;
                float _CutoffSoftness;
                //half4 _BurnCol;
                //float _BurnSize;

                float _Bands;
                float4 _PanningSpeed;
 
                float4 _DisplacementGuide_ST;
                float _DisplacementAmount;
 
                float _Smoothness;
                float _OuterRadius;
                float _InnerRadius;
 
                float _RectSmoothness;
                float _RectHeight;
                float _RectWidth;
                float _RectMaskCutoff;

                float _IntersectionThresholdMax;
            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                half4 color : COLOR;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 displUV : TEXCOORD2;
                float4 screenPos : TEXCOORD4;
                float4 vertex : SV_POSITION;
                half4 color : COLOR;
                float fogCoord : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
 
                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.displUV = TRANSFORM_TEX(v.uv, _DisplacementGuide);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.color = v.color;

#ifdef _FOG
                o.fogCoord = ComputeFogFactor(o.vertex.z);
#else
                o.fogCoord = 0;
#endif
                return o;
            }
 
            half4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 uv = i.uv;
                float2 displUV = i.displUV;
 
#ifdef POLAR
                float2 mappedUV = (i.uv * 2) - 1;
                uv = float2(atan2(mappedUV.y, mappedUV.x) / PI / 2.0 + 0.5, length(mappedUV));
                mappedUV = (i.displUV * 2) - 1;
                displUV = float2(atan2(mappedUV.y, mappedUV.x) / PI / 2.0 + 0.5, length(mappedUV));
#endif
 
                //UV Panning
                uv += _Time.y * _PanningSpeed.xy;
                displUV += _Time.y * _PanningSpeed.zw;
 
                //Displacement
                float2 displ = tex2D(_DisplacementGuide, displUV).xy;
                displ = ((displ * 2) - 1) * _DisplacementAmount;
 
                half4 col = tex2D(_MainTex, uv + displ) * _Color * i.color;
             //   clip(col.a - _Cutoff);

#ifdef CIRCLE_MASK
                float circle = distance(i.uv, float2(0.5, 0.5));
                col.a *= 1 - smoothstep(_OuterRadius, _OuterRadius + _Smoothness, circle);
                col.a *= smoothstep(_InnerRadius, _InnerRadius + _Smoothness, circle);
#endif
 
#ifdef RECT_MASK
                float2 uvMapped = (i.uv * 2) - 1;
                float rect = max(abs(uvMapped.x / _RectWidth), abs(uvMapped.y / _RectHeight));
                col.a *= 1 - smoothstep(_RectMaskCutoff, _RectMaskCutoff + _RectSmoothness, rect);
#endif
             
 
                half4 orCol = col;
 
#ifdef BANDING
                col.rgb = round(col.rgb * _Bands) / _Bands;
#endif
 
                //Transparency
                float cutoff = saturate(_Cutoff + (1 - i.color.a));
                float alpha = smoothstep(cutoff, cutoff + _CutoffSoftness, orCol.a);
                col *= alpha;
 
                ////Coloring
                //half4 rampCol = col + _BurnCol * smoothstep(orCol - cutoff, orCol - cutoff + _CutoffSoftness, _BurnSize) * smoothstep(0.001, 0.5, cutoff);
                //half4 finalCol = half4(rampCol.rgb * _Color.rgb * rampCol.a, 1);

#ifdef SOFT_BLEND

                float rawDepth = _CameraDepthTexture.Sample(sampler_CameraDepthTexture, i.screenPos.xy / i.screenPos.w).r;
                half linearDepth = LinearEyeDepth(rawDepth, _ZBufferParams);
                half diff = saturate(_IntersectionThresholdMax * (linearDepth - i.screenPos.w));
                col.a *= diff;
#endif

#ifdef _FOG
                col.rgb = MixFog(col.rgb, i.fogCoord);
#endif

                return col;
            }
            ENDHLSL
        }
    }
}