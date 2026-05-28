Shader "Vulcanus/SpecialFX/SkillIndicator_00"
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_MaskTex("Mask (RGB)", 2D) = "white" {}
		[HDR] _Color("Color", Color) = (1,1,1,1)
		_FinalAlpha("FinalAlpha", Range(0.0, 1.0)) = 0.05

		[Header(Out Line)]
		[HDR] _OutLineColor("      OutLineColor", Color) = (1,1,1,1)
		_OutLineThickness("      OutLineThickness", Range(0.0, 1.0)) = 1.0

		[Header(Mask)]
		[HDR] _MaskColor("      MaskColor" , Color) = (1, 1, 1, 1)
		_XScrollSpeed("      X Scroll Speed", Float) = 0
		_YScrollSpeed("      Y Scroll Speed", Float) = 0

		[Header(ZTest)]
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("ZTest (default = Disable)", Float) = 0 //0 = disable

		[Header(ZWrite)]
		[Enum(Off, 0, On, 1)]_ZWrite("ZWrite (default = Disable)", Float) = 0 //0 = disable

		[Header(Cull)]
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("Cull (default = Front)", Float) = 1 //1 = Front
	}
	SubShader
	{
		Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
		Blend SrcAlpha OneMinusSrcAlpha
		Lighting Off
		Cull[_Cull]
		ZWrite[ZWrite]
		ZTest[_ZTest]

		Pass
		{
			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
		//	#pragma multi_compile_instancing
			#pragma target 3.0
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

			CBUFFER_START(UnityPerMaterial)
				sampler2D _MainTex;
				sampler2D _MaskTex;
				half4 _Color;
				half4 _MaskColor;
				half4 _OutLineColor;
				half _OutLineThickness;
				half _FinalAlpha;
				half _XScrollSpeed;
				half _YScrollSpeed;
				float4 _MainTex_ST;
			CBUFFER_END

			struct appdata_t {
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			//	float2 texcoord2 : TEXCOORD1;
			};

			struct v2f {
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			//	float2 texcoord2 : TEXCOORD1;
			};

			v2f vert(appdata_t v)
			{
				v2f o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.texcoord = TRANSFORM_TEX(v.texcoord, _MainTex);
			//	o.texcoord2 = TRANSFORM_TEX(v.texcoord2, _MainTex);
				return o;
			}

			half4 frag(v2f i) : SV_Target
			{
				half4 tempColor = tex2D(_MainTex, i.texcoord).a * _Color;
				half3 color = tempColor.rgb;
				half alpha = tempColor.a;
				
				//UV Alpha
				half2 uvAlphaUV = abs((i.texcoord - 0.5) * 2);
				half uvAlpha = max(uvAlphaUV.x, uvAlphaUV.y);
				uvAlpha = pow(uvAlpha, 1.1);
				alpha *= uvAlpha;

				half outlineXFactor = saturate(abs((i.texcoord.x - 0.5) * (2 + _OutLineThickness)));
				outlineXFactor *= outlineXFactor * outlineXFactor * outlineXFactor;
				outlineXFactor *= outlineXFactor * outlineXFactor * outlineXFactor;
				outlineXFactor *= outlineXFactor * outlineXFactor * outlineXFactor;
				color = ((color * (1-outlineXFactor)) + (_OutLineColor * outlineXFactor).rgb) * alpha;


				half outlineYFactor = saturate(abs((i.texcoord.y - 0.5) * (2 + _OutLineThickness)));
				outlineYFactor *= outlineYFactor * outlineYFactor * outlineYFactor;
				outlineYFactor *= outlineYFactor * outlineYFactor * outlineYFactor;
				outlineYFactor *= outlineYFactor * outlineYFactor * outlineYFactor;
				color = ((color * (1-outlineYFactor)) + (_OutLineColor * outlineYFactor).rgb) * alpha;

				
				float3 worldScale = float3(length(float3(unity_ObjectToWorld._m00, unity_ObjectToWorld._m10, unity_ObjectToWorld._m20)),
									  length(float3(unity_ObjectToWorld._m01, unity_ObjectToWorld._m11, unity_ObjectToWorld._m21)),
									  length(float3(unity_ObjectToWorld._m02, unity_ObjectToWorld._m12, unity_ObjectToWorld._m22)));

				half scaleRatio = worldScale.z / worldScale.x;
				half2 scrollUV = i.texcoord + half2(_XScrollSpeed * _Time.y, _YScrollSpeed * _Time.y) / scaleRatio;
				scrollUV.y *= scaleRatio;
				half4 mask = tex2D(_MaskTex, scrollUV).a * _MaskColor;
				color += mask.rgb * mask.a;
				alpha = max(mask.a, alpha);

				alpha *= _FinalAlpha;
				return half4(color, alpha);
			}
			ENDHLSL
		}
	}
}
