Shader "Vulcanus/SpecialFX/ZoneBarrier"
{
	Properties
	{
		[MainTexture] _BaseMap("Base Texture", 2D) = "white" {}
        [MainColor][HDR] _BaseColor("Base Color", Color) = (1, 1, 1, 1)
		[MainColor][HDR] _LineColor("Line Color", Color) = (1, 1, 1, 1)
		_OutLineThickness("Outline Thickness", Range(0, 1)) = 0.01
		_Distance("Distance (default = On)", Float) = 10

		[Header(Render State)]
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("    ZTest (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("    Cull (default = Front)", Float) = 1 //1 = Front
	}

	SubShader 
	{
		Tags {"Queue" = "Transparent" "RenderType" = "Opaque" }
		Blend SrcAlpha OneMinusSrcAlpha
		ZTest[_ZTest]
		ZWrite Off
		Cull[_Cull]

		Pass 
		{
			HLSLPROGRAM

			#pragma multi_compile _ _ULTRA_LOW_SPEC

			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			 #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
			// #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

			TEXTURE2D(_BaseMap);
			SAMPLER(sampler_BaseMap);

			CBUFFER_START(UnityPerMaterial)
				half4  _BaseMap_ST;
				half4 _BaseColor;
				half4 _LineColor;
				half _OutLineThickness;
				half _Distance;
			CBUFFER_END

			struct vertexInput
			{
				float4 vertex : POSITION;
				float2 uvCoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				float4 vertex : SV_POSITION;
				float3 worldPos : POSITION1;
				float2 uv : TEXCOORD0;
				float2 uvCoord : TEXCOORD1;
				float4 screenPos : TEXCOORD2;
				half scaleXYRatio : TEXCOORD3;
			};

			float4 _TargetPosition;

			vertexOutput vert(vertexInput v) 
			{
				half worldXScale = length(half3(unity_ObjectToWorld._11, unity_ObjectToWorld._21, unity_ObjectToWorld._31));
				half worldYScale = length(half3(unity_ObjectToWorld._12, unity_ObjectToWorld._22, unity_ObjectToWorld._32));

				vertexOutput o;
				o.vertex = TransformObjectToHClip(v.vertex.xyz);
				o.worldPos = TransformObjectToWorld(v.vertex.xyz); 
				o.uv = v.uvCoord;
				o.uvCoord = float2(worldXScale * 0.5, worldYScale * 0.5) * v.uvCoord;
				o.screenPos = ComputeScreenPos(o.vertex);
				o.scaleXYRatio = worldXScale / worldYScale;
				return o;
			}

			half4 frag(vertexOutput i) : SV_Target
			{
				half distance = length(i.worldPos - _TargetPosition.xyz);
				
#if !defined(_ULTRA_LOW_SPEC)
				half ratio = distance / _Distance;
				ratio = ratio * ratio;
				ratio = ratio * ratio;
				ratio = ratio * ratio;
				ratio = (1 - ratio);
				ratio = saturate(ratio);

				half3 color = _BaseColor.rgb;
				half diffuseAlpha = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uvCoord).r;
				half alpha = diffuseAlpha * _BaseColor.a * ratio;
				color = lerp(color, _LineColor.rgb, step(0.3, diffuseAlpha) * alpha);

				//Soft 
                float sceneZ = LinearEyeDepth(SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(i.screenPos.xy / i.screenPos.w)).r, _ZBufferParams);
                float thisZ = i.screenPos.w;
                half softFactor = (sceneZ - thisZ);
                softFactor = saturate(softFactor);
				alpha *= softFactor;

				half2 outlineUV = abs(i.uv - 0.5 ) * 2;
				half outlineFactor = step(1 - _OutLineThickness, outlineUV.x);
				outlineFactor = outlineFactor + step(1 - (_OutLineThickness * i.scaleXYRatio) , outlineUV.y);
				
				color = lerp(color, _LineColor.rgb, outlineFactor);
				alpha = lerp(alpha, 1, outlineFactor);
#else
				half ratio = distance / _Distance;
				ratio = (1 - ratio);
				ratio = saturate(ratio);

				half3 color = _LineColor.rgb;
				half alpha = _LineColor.a * ratio;
				half2 uvCoord = i.uvCoord;
				uvCoord = frac(uvCoord);
				uvCoord -= 0.5;
				uvCoord *= 2;
				uvCoord = 1 - abs(uvCoord);
				alpha *= step(0.95, uvCoord.x) + step(0.95, uvCoord.y);
				alpha = saturate(alpha);

				half2 outlineUV = abs(i.uv - 0.5 ) * 2;
				half outlineFactor = step(1 - _OutLineThickness, outlineUV.x);
				outlineFactor = outlineFactor + step(1 - (_OutLineThickness * i.scaleXYRatio) , outlineUV.y);
				alpha = lerp(alpha, 1, outlineFactor);
#endif

				return half4(color, alpha);
			}
			ENDHLSL
		}
	}
}