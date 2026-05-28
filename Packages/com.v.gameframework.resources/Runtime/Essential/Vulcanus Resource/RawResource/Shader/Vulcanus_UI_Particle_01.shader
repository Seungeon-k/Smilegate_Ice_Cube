// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Unlit/Shader_UI_Disslove_Color_Plus_2"
{
	Properties
	{
		[PerRendererData] _MainTex("Sprite Texture", 2D) = "white" {}
		_Color("Tint", Color) = (1,1,1,1)

		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][Enum(OFF,0,ON,1)]_Zwrite("Zwrite", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_Ztest("Ztest", Float) = 4
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		_Main_Tex("Main_Tex", 2D) = "white" {}
		[Enum(RGB,0,R,1)]_RGBorA("RGB or A", Float) = 0
		[HDR]_Main_Color("Main_Color", Color) = (1,1,1,1)
		_MainTilingOffset("MainTilingOffset", Vector) = (1,1,0,0)
		_Main_curv("Main_curv", Float) = 1
		_Dissolve_Tex("Dissolve_Tex", 2D) = "white" {}
		_DissTilingOffset("DissTilingOffset", Vector) = (1,1,0,0)
		_Diss_Uspeed("Diss_Uspeed", Float) = 0
		_Diss_Vspeed("Diss_Vspeed", Float) = 0
		[Toggle]_Dissolve_Gra_On("Dissolve_Gra_On", Float) = 0
		_Dissolve_Gra("Dissolve_Gra", 2D) = "white" {}
		_Dissolve_Gra_Curv("Dissolve_Gra_Curv", Float) = 1
		[HDR]_Edge_Color("Edge_Color", Color) = (1,1,1,1)
		_Edge("Edge", Float) = 0
		_Mask_Clip_Value("Mask_Clip_Value", Float) = 0
		_soft("soft", Range(0.5 , 1)) = 1
		[Toggle(_EDGE_ON_ON)] _Edge_on("Edge_on", Float) = 0
		_Noise_Tex("Noise_Tex", 2D) = "white" {}
		_MaskTex("MaskTex", 2D) = "white" {}
		_NoiseTilingOffset("NoiseTilingOffset", Vector) = (1,1,0,0)
		_mask_curv("mask_curv", Float) = 1
		_Noise_Uspeed("Noise_Uspeed", Float) = 0
		_Nosie_Vspeed("Nosie_Vspeed", Float) = 0
		_Noise_Power("Noise_Power", Float) = 0
		[Enum(Polar,0,Normal,1)]_NormalorPolar("Normal or Polar", Float) = 1
		_Depth("Depth", Float) = 0
		[Enum(OFF,0,ON,1)]_Float1("Depth_Alpha", Float) = 0
		_Color_Tex("Color_Tex", 2D) = "white" {}
		_ColorUspeed("ColorUspeed", Float) = 0
		_ColorVspeed("ColorVspeed", Float) = 0
		_Color_curv("Color_curv", Float) = 1
		[Toggle(_LINEARBURN_USE_ON)] _LinearBurn_use("LinearBurn_use", Float) = 0
		_Linearburn_Tex("Linearburn_Tex", 2D) = "white" {}
		_LinearTilling("LinearTilling", Vector) = (1,1,0,0)
		_LinearPanner("LinearPanner", Vector) = (0,0,0,0)
		_Linearburn_Mask("Linearburn_Mask", 2D) = "white" {}
		_LinearBurn_Mask_Str("LinearBurn_Mask_Str", Float) = 1
		[ASEEnd]_LinearBurn_Gra_Curv("LinearBurn_Gra_Curv", Float) = 1
		[HideInInspector] _texcoord("", 2D) = "white" {}

		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
		[HideInInspector]_QueueControl("_QueueControl", Float) = -1
		[HideInInspector]_LocalDimmedWeight("_LocalDimmedWeight", Float) = 0

		_StencilComp("Stencil Comparison", Float) = 8
		_Stencil("Stencil ID", Float) = 0
		_StencilOp("Stencil Operation", Float) = 0
		_StencilWriteMask("Stencil Write Mask", Float) = 255
		_StencilReadMask("Stencil Read Mask", Float) = 255

		_ColorMask("Color Mask", Float) = 15

		[Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip("Use Alpha Clip", Float) = 0
	}

		SubShader
		{
			Tags
			{
				"Queue" = "Transparent"
				"IgnoreProjector" = "True"
				"RenderType" = "Transparent"
				"PreviewType" = "Plane"
			}

			Stencil
			{
				Ref 0
				Comp Always // 8
				Pass Keep // 0
				ReadMask 255
				WriteMask 255
			}
			 
			Cull Off
			Lighting Off
			Blend [_BlendScr][_BlendDst]
			ZWrite Off
			ZTest[unity_GUIZTestMode]
			Offset 0 , 0
			ColorMask RGBA

			Pass
			{
				Name "Default"
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0

				#include "UnityCG.cginc"
				#include "UnityUI.cginc"
				#include "ORShaderVariablesFunctions.hlsl"

				#pragma multi_compile_local _ UNITY_UI_CLIP_RECT
				#pragma multi_compile_local _ UNITY_UI_ALPHACLIP


				#define ASE_NEEDS_FRAG_COLOR
				#pragma shader_feature_local _EDGE_ON_ON
				#pragma shader_feature_local _LINEARBURN_USE_ON

				struct appdata_t
				{
					float4 vertex : POSITION;
					float3 ase_normal : NORMAL;
					float4 texcoord : TEXCOORD0;
					float4 texcoord1 : TEXCOORD1;
					float4 texcoord2 : TEXCOORD2;
					float4 color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 vertex : SV_POSITION;
					float4 uvPack0 : TEXCOORD3;
					float4 uvPack1 : TEXCOORD4;
					float4 uvPack2 : TEXCOORD5;
					float4 color : COLOR;
					float4  mask : TEXCOORD1;

					float4 uvResult0 : TEXCOORD7;
					float4 uvResult1 : TEXCOORD8;
					float4 uvResult2 : TEXCOORD9;
					float4 screenPos : TEXCOORD10;
					UNITY_VERTEX_OUTPUT_STEREO
				};




				UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);


				sampler2D _MainTex;

				float4 _NoiseTilingOffset;
				float4 _MaskTex_ST;
				float4 _Main_Color;
				float4 _DissTilingOffset;
				float4 _Edge_Color;
				float4 _Main_Tex_ST;
				float4 _MainTilingOffset;
				float4 _Color_Tex_ST;
				float4 _Dissolve_Gra_ST;
				float4 _Linearburn_Mask_ST;
				float2 _LinearPanner;
				float2 _LinearTilling;
				float _Dissolve_Gra_Curv;
				float _Ztest;
				float _ColorUspeed;
				float _Diss_Vspeed;
				float _ColorVspeed;
				float _Color_curv;
				float _Depth;
				float _Float1;
				float _Edge;
				float _Diss_Uspeed;
				float _LinearBurn_Mask_Str;
				float _soft;
				float _mask_curv;
				float _LinearBurn_Gra_Curv;
				float _RGBorA;
				float _Main_curv;
				float _Noise_Power;
				float _Nosie_Vspeed;
				float _Noise_Uspeed;
				float _NormalorPolar;
				float _BlendDst;
				float _Zwrite;
				float _CullMode;
				float _BlendScr;
				float _Dissolve_Gra_On;
				float _Mask_Clip_Value;

				float _LocalDimmedWeight;
				float _GlobalDimmedWeight;


				fixed4 _TextureSampleAdd;
				float4 _ClipRect;
				float4 _MainTex_ST;
				float _UIMaskSoftnessX;
				float _UIMaskSoftnessY;

				sampler2D _Main_Tex;
				sampler2D _Noise_Tex;
				sampler2D _Linearburn_Mask;
				sampler2D _Linearburn_Tex;
				sampler2D _Dissolve_Tex;
				sampler2D _Dissolve_Gra;
				sampler2D _Color_Tex;
				uniform float4 _CameraDepthTexture_TexelSize;
				sampler2D _MaskTex;

				v2f vert(appdata_t v)
				{
					v2f o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


					float4 ase_clipPos = UnityObjectToClipPos(v.vertex);

					o.vertex = ase_clipPos;

					float4 screenPos = ComputeScreenPos(ase_clipPos);
					 
					 

					float4 screenPosNorm = screenPos / screenPos.w;
					screenPosNorm.z = (UNITY_NEAR_CLIP_VALUE >= 0) ? screenPosNorm.z : screenPosNorm.z * 0.5 + 0.5;

					 

					o.screenPos = screenPosNorm;


					o.uvPack0 = v.texcoord;
					o.uvPack1 = v.texcoord1;
					o.uvPack2 = v.texcoord2;
					o.color = v.color;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						float3 defaultVertexValue = v.vertex.xyz;
					#else
						float3 defaultVertexValue = float3(0, 0, 0);
					#endif
					float3 vertexValue = defaultVertexValue;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif
					v.ase_normal = v.ase_normal;

					float3 positionWS = mul(unity_ObjectToWorld, v.vertex.xyz);


					// -- FS to VS ------------------------------------------------------------.



					float2 calcUVMidPos = v.texcoord.xy * 2.0 + -1.0;
					o.uvResult0.xy = float2(length(calcUVMidPos.xy) , (0.0 + (atan2(calcUVMidPos.y , calcUVMidPos.x) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0)));



					float2 uvMain = v.texcoord.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
					float2 lerpResult108 = lerp(o.uvResult0.xy , uvMain , _NormalorPolar);
					o.uvResult0.zw = (lerpResult108 * _MainTilingOffset.xy + v.texcoord1.xy);

					float2 uvLerpB = lerp(o.uvResult0.xy , v.texcoord.xy , _NormalorPolar);
					o.uvResult1.xy = (_Time.y * float2(_Noise_Uspeed , _Nosie_Vspeed) + (uvLerpB * _NoiseTilingOffset.xy + _NoiseTilingOffset.zw));



					float2 uvLerpC = lerp(o.uvResult0.xy , v.texcoord.xy , _NormalorPolar);
					o.uvResult1.zw = (_Time.y * float2(_Diss_Uspeed , _Diss_Vspeed) + (uvLerpC * _DissTilingOffset.xy + _DissTilingOffset.zw));



					o.uvResult2.xy = (_Time.y * float2(_ColorUspeed , _ColorVspeed) + v.texcoord.xy * _Color_Tex_ST.xy + _Color_Tex_ST.zw);
					o.uvResult2.zw = float2(0,0);



					float2 pixelSize = o.vertex.w;
					pixelSize /= float2(1, 1) * abs(mul((float2x2)UNITY_MATRIX_P, _ScreenParams.xy));

					float4 clampedRect = clamp(_ClipRect, -2e10, 2e10);
					float2 maskUV = (v.vertex.xy - clampedRect.xy) / (clampedRect.zw - clampedRect.xy);
					o.mask = float4(v.vertex.xy * 2 - clampedRect.xy - clampedRect.zw, 0.25 / (0.25 * half2(_UIMaskSoftnessX, _UIMaskSoftnessY) + abs(pixelSize.xy)));



					return o;


				}

				fixed4 frag(v2f IN) : SV_Target
				{
					float4 noiseColor = tex2D(_Noise_Tex, IN.uvResult1.xy) * IN.uvPack1.z * _Noise_Power;
					float4 mainTcolor = tex2D(_Main_Tex, (float4(IN.uvResult0.zw, 0.0 , 0.0) + noiseColor).rg);
					float4 LerpColor = lerp(pow(mainTcolor , _Main_curv.xxxx) , pow(mainTcolor.a , _Main_curv).xxxx , _RGBorA);


					#ifdef _LINEARBURN_USE_ON
					float2 LBurnUV = IN.uvPack0.xy * _LinearTilling + (_Time.y * _LinearPanner);
					half4 LBurnMaskColor = tex2D(_Linearburn_Mask, IN.uvPack0.xy * _Linearburn_Mask_ST.xy + _Linearburn_Mask_ST.zw);
					half4 LBurnTexColor = tex2D(_Linearburn_Tex, LBurnUV);
					float4 MaskSwitch = (LerpColor + saturate(((LBurnMaskColor * pow(_LinearBurn_Gra_Curv , 1.0)) + LBurnTexColor) * _LinearBurn_Mask_Str)) + -1.0;
					#else
					float4 MaskSwitch = LerpColor;
					#endif


					float4 DisolveColor = tex2D(_Dissolve_Tex,   IN.uvResult1.zw + noiseColor.xy);
					half4 DissolveGraColor = tex2D(_Dissolve_Gra, IN.uvPack0.xy * _Dissolve_Gra_ST.xy + _Dissolve_Gra_ST.zw);

					float SStep = smoothstep((1.0 - _soft) , _soft , saturate(((((_Dissolve_Gra_On) ? ((DisolveColor.r + (DissolveGraColor.r * pow(_Dissolve_Gra_Curv , 1.0)))) : (DisolveColor.r)) + 1.0) - (IN.uvPack1.w * 2.0))));
					float CalcStepA = step(IN.uvPack1.w , ((_Dissolve_Gra_On) ? ((DisolveColor.r + (DissolveGraColor.r * pow(_Dissolve_Gra_Curv , 1.0)))) : (DisolveColor.r)));
					float CalcStepB = (CalcStepA - step((IN.uvPack1.w + _Edge) , ((_Dissolve_Gra_On) ? ((DisolveColor.r + (DissolveGraColor.r * pow(_Dissolve_Gra_Curv , 1.0)))) : (DisolveColor.r))));



					#ifdef _EDGE_ON_ON
					float staticSwitch34 = (CalcStepA + CalcStepB);
					#else
					float staticSwitch34 = SStep;
					#endif



					half4 colorTexColor = tex2D(_Color_Tex, IN.uvResult2.xy);

					float4 colorResult = (MaskSwitch * _Main_Color * (IN.uvPack2 * IN.color) * staticSwitch34 * pow(colorTexColor, _Color_curv.xxxx));






					#ifdef _EDGE_ON_ON
					float4 edgeSwitchA = lerp(colorResult , _Edge_Color , CalcStepB);;
					#else
					float4 edgeSwitchA = colorResult;
					#endif



					float screenDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, IN.screenPos.xy));
					float distanceDepth = abs((screenDepth - LinearEyeDepth(IN.screenPos.z)) / (_Depth));
					distanceDepth = saturate(distanceDepth);
					float4 finalColorResult = lerp(edgeSwitchA , (distanceDepth * edgeSwitchA) , _Float1);



					#ifdef _EDGE_ON_ON
					float edgeSwitchB = CalcStepA;
					#else
					float edgeSwitchB = SStep;
					#endif


					half4 MskColor = tex2D(_MaskTex, IN.uvPack0.xy * _MaskTex_ST.xy + _MaskTex_ST.zw);
					float4 CalcMask = (edgeSwitchB * MaskSwitch * IN.color.a * pow(MskColor , _mask_curv));



					float4 AlphaResult = lerp(CalcMask , (distanceDepth * CalcMask) , _Float1);


					float3 Color = finalColorResult.rgb;
					float Alpha = AlphaResult.r;
					float AlphaClipThreshold = _Mask_Clip_Value;
					float AlphaClipThresholdShadow = 0.5;
					 
					  
					#ifdef UNITY_UI_CLIP_RECT
					half2 m = saturate((_ClipRect.zw - _ClipRect.xy - abs(IN.mask.xy)) * IN.mask.zw);
					Alpha *= m.x * m.y;
					#endif

					clip(Alpha - AlphaClipThreshold);

					#if defined(_ALPHAPREMULTIPLY_ON)
					Color *= Alpha;
					#endif
					ORDimmedColor(Color.rgb, _GlobalDimmedWeight, _LocalDimmedWeight);
					return half4(Color, Alpha);
				}
			ENDCG
			}
		}
}
