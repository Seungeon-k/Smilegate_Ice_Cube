Shader "ParticleShaderAnimationAdd"
{
	Properties
	{
		_Color("Color", Color) = (0.5,0.5,0.5,0.5)
		_MainTex("Particle Texture", 2D) = "white" {}
		_XScrollSpeed("X Scroll Speed", Float) = 0
		_YScrollSpeed("Y Scroll Speed", Float) = 0
	}

	SubShader
	{
		Tags { "Queue" = "Transparent+2" "IgnoreProjector" = "True" "RenderType" = "Transparent" "ShaderUsage" = "Creator" }
		Blend SrcAlpha One
		Cull Off Lighting Off ZWrite Off Fog{ Color(0,0,0,0) }
		BindChannels
		{
			Bind "Color", color
			Bind "Vertex", vertex
			Bind "TexCoord", texcoord
		}

		Pass
		{
			HLSLPROGRAM
			#pragma exclude_renderers gles gles3 glcore

			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma multi_compile_particles
			#pragma multi_compile_local __ VULCANUS_COLORSPACE_GAMMA _SHADER_USAGE_CREATOR


			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "../Supported/HLSL/GammaToLinear.hlsl"

			CBUFFER_START(UnityPerMaterial)

			sampler2D _MainTex;
			half4 _Color;
			float _XScrollSpeed;
			float _YScrollSpeed;
			float4 _MainTex_ST;

			CBUFFER_END

			struct appdata_t
			{
				float4 vertex : POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				half4 color : COLOR;
				float2 texcoord : TEXCOORD0;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.color = v.color;
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				float2 scrollUV = i.texcoord;
				float xScrollValue = _XScrollSpeed * _Time.x;
				float yScrollValue = _YScrollSpeed * _Time.x;
				scrollUV += float2(xScrollValue, yScrollValue);

				half4 c = tex2D(_MainTex, scrollUV);

#if VULCANUS_COLORSPACE_GAMMA
				c = GammaToLinearBeginHLSL(c);
				
#endif

				c.rgba = c.rgba * _Color.rgba;

#if VULCANUS_COLORSPACE_GAMMA
				c = GammaToLinearEndHLSL(c);
				
#endif

				return c;
			}

			ENDHLSL
		}
	}
	//FallBack "Diffuse"
}

