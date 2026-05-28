Shader "Vulcanus/ScreenTransition"
{
    Properties
    {
        [MainTexture][NoScaleOffset] _BaseMap1("Main Texture 1", 2D) = "white" {}
        [MainTexture][NoScaleOffset] _BaseMap2("Main Texture 2", 2D) = "white" {}

        _XTileCount("X Tile Count", Int) = 30
        _YTileCount("Y Tile Count", Int) = 20
        _Scroll("Scroll", Float) = 2.5
        _Speed("Transition Speed", Range(0, 10)) = 3

        [Header(Render State)]
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest (default = LessEqual)", Float) = 4 //4 = LessEqual
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlend("src", Float) = 1.0
        [Enum(UnityEngine.Rendering.BlendMode)] _DstBlend("dst", Float) = 0.0
    }
    SubShader 
	{
		Tags {"Queue" = "Geometry" "RenderType" = "Opaque" }
		Blend[_SrcBlend][_DstBlend]
		ZTest[_ZTest]
		ZWrite On
		Cull Back

		Pass {
			HLSLPROGRAM

            #pragma multi_compile _ LOD_FADE_CROSSFADE
            #pragma multi_compile _ _ULTRA_LOW_SPEC
            #pragma multi_compile_fog

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.vulcanus.render-pipelines.vulcanus/Shaders/Vulcanus_Common.hlsl"  
            

            TEXTURE2D(_BaseMap1);   SAMPLER(sampler_BaseMap1);
            TEXTURE2D(_BaseMap2);   SAMPLER(sampler_BaseMap2);

			CBUFFER_START(UnityPerMaterial)
                half _XTileCount;
                half _YTileCount;
                half _Scroll;
                half _Speed;
			CBUFFER_END

			struct vertexInput
			{
				float4 positionOS   : POSITION;
				float2 uv           : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 positionCS   : SV_POSITION;
                float2 uv           : TEXCOORD0;
                VULCANUS_FOG_COORDS(1)
                half time           : TEXCOORD2;
			};

            float Unity_Posterize_float(float In, float Steps);
            float Unity_Rectangle_float(float2 UV, float Width, float Height);

			vertexOutput vert(vertexInput v) 
			{
				vertexOutput o;
                float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
                o.positionCS = TransformWorldToHClip(positionWS);
                o.uv = v.uv;
                o.time = clamp((_SinTime.z * _Speed) + (0.5 * _Speed ), 0, 1);
                o.vulcanusFogCoord = VSFogDither(positionWS);
				return o;
			}

			half4 frag(vertexOutput i) : SV_Target
			{
                PSFogDither(i.positionCS, i.vulcanusFogCoord.x);

#if !defined(_ULTRA_LOW_SPEC)
                half posterize = Unity_Posterize_float(i.uv.r, _XTileCount);
                half poserizepOneMinus = (1 - posterize);
                poserizepOneMinus *= 0.5;

                half gradationCoef = posterize + poserizepOneMinus;
                gradationCoef *= _Scroll * i.time;
                gradationCoef -= 0.2;

                half2 tilePattern = i.uv * half2(_XTileCount, _YTileCount);
                tilePattern = frac(tilePattern);
                half transitionPattern = Unity_Rectangle_float(tilePattern, gradationCoef, gradationCoef);
#else
                half transitionPattern = i.time;
#endif

                half4 texture_0 = SAMPLE_TEXTURE2D(_BaseMap1, sampler_BaseMap1, i.uv);
                half4 texture_1 = SAMPLE_TEXTURE2D(_BaseMap2, sampler_BaseMap2, i.uv);
                half4 color = lerp(texture_0, texture_1, transitionPattern);

                color.rgb = PSFogColor(color.rgb, i.vulcanusFogCoord.y);
				return color;
			}

            //Functions
            float Unity_Posterize_float(float In, float Steps)
            {
                return floor(In * Steps) * (1 / Steps);
            }

            float Unity_Rectangle_float(float2 UV, float Width, float Height)
            {
                float2 d = abs(UV * 2 - 1) - float2(Width, Height);
                d = 1 - d / fwidth(d);
                return saturate(min(d.x, d.y));
            }

			ENDHLSL
		}
	}
}