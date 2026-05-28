// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DSFX/FX_SHADER_Disslove_Color_Plus"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][Enum(OFF,0,ON,1)]_Zwrite("Zwrite", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_Ztest("Ztest", Float) = 4
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10
		[Enum(UnityEngine.Rendering.CullMode)]_CullMode("CullMode", Float) = 0
		_Main_Tex("Main_Tex", 2D) = "white" {}
		[Toggle]_Main_Alpha("Main_Alpha", Float) = 0
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
		_Edge("Edge", Float) = 0.15
		_Mask_Clip_Value("Mask_Clip_Value", Float) = 0.5
		_soft("soft", Range( 0.5 , 1)) = 1
		[Toggle(_EDGE_ON_ON)] _Edge_on("Edge_on", Float) = 0
		_MaskTex("MaskTex", 2D) = "white" {}
		_mask_curv("mask_curv", Float) = 1
		_Noise_Tex("Noise_Tex", 2D) = "white" {}
		_WP_texture("WP_texture", 2D) = "white" {}
		_WP_tiling("WP_tiling", Vector) = (1,1,0,0)
		_WP_panner("WP_panner", Vector) = (0.5,0,0,0)
		_WP_strong("WP_strong", Float) = 0
		_NoiseTilingOffset("NoiseTilingOffset", Vector) = (1,1,0,0)
		_Noise_Uspeed("Noise_Uspeed", Float) = 0
		_Nosie_Vspeed("Nosie_Vspeed", Float) = 0
		_Noise_Power("Noise_Power", Float) = 0
		[Enum(RGB,0,R,1)]_RGBorR("RGB or R", Float) = 0
		[Enum(Polar,0,Normal,1)]_NormalorPolar("Normal or Polar", Float) = 1
		_Depth("Depth", Float) = 0
		[Enum(OFF,0,ON,1)]_Float1("Depth_Alpha", Float) = 0
		_Color_Tex("Color_Tex", 2D) = "white" {}
		_ColorUspeed("ColorUspeed", Float) = 0
		_ColorVspeed("ColorVspeed", Float) = 0
		[ASEEnd]_Color_curv("Color_curv", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		[HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
        [HideInInspector]_QueueControl("_QueueControl", Float) = -1
        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull [_CullMode]
		AlphaToMask Off
		
		HLSLINCLUDE
		#pragma target 3.0

		#pragma prefer_hlslcc gles
		#pragma exclude_renderers d3d11_9x 

		#ifndef ASE_TESS_FUNCS
		#define ASE_TESS_FUNCS
		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		#endif //ASE_TESS_FUNCS

		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend [_BlendScr] [_BlendDst]
			ZWrite [_Zwrite]
			ZTest [_Ztest]
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma multi_compile _ LIGHTMAP_ON
			//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			//#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			//#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _EDGE_ON_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Main_Color;
			float4 _DissTilingOffset;
			float4 _Dissolve_Gra_ST;
			float4 _NoiseTilingOffset;
			float4 _MainTilingOffset;
			float4 _Main_Tex_ST;
			float4 _Color_Tex_ST;
			float4 _Edge_Color;
			float4 _MaskTex_ST;
			float2 _WP_tiling;
			float2 _WP_panner;
			float _Color_curv;
			float _Diss_Vspeed;
			float _ColorVspeed;
			float _ColorUspeed;
			float _Depth;
			float _Edge;
			float _Dissolve_Gra_Curv;
			float _Float1;
			float _Diss_Uspeed;
			float _BlendDst;
			float _soft;
			float _mask_curv;
			float _RGBorR;
			float _Main_Alpha;
			float _Main_curv;
			float _Noise_Power;
			float _Nosie_Vspeed;
			float _Noise_Uspeed;
			float _NormalorPolar;
			float _WP_strong;
			float _Ztest;
			float _CullMode;
			float _Zwrite;
			float _BlendScr;
			float _Dissolve_Gra_On;
			float _Mask_Clip_Value;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _WP_texture;
			sampler2D _Main_Tex;
			sampler2D _Noise_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Dissolve_Gra;
			sampler2D _Color_Tex;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _MaskTex;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 panner216 = ( 1.0 * _Time.y * ( _WP_panner + float2( 0,0 ) ) + float2( 0,0 ));
				float4 texCoord145 = v.ase_texcoord2;
				texCoord145.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult233 = (float2(texCoord145.x , texCoord145.y));
				float2 texCoord217 = v.ase_texcoord * _WP_tiling + ( panner216 + appendResult233 );
				float4 tex2DNode219 = tex2Dlod( _WP_texture, float4( texCoord217, 0, 0.0) );
				float4 temp_output_235_0 = ( ( ( 0.1 * ( tex2DNode219 * texCoord145.z ) ) * float4( v.ase_normal , 0.0 ) ) * _WP_strong );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord3 = v.ase_texcoord;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_235_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = temp_output_235_0.rgb;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float4 texCoord78 = IN.ase_texcoord3;
				texCoord78.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult79 = (float2(texCoord78.x , texCoord78.y));
				float2 temp_output_80_0 = (appendResult79*2.0 + -1.0);
				float2 break84 = temp_output_80_0;
				float2 appendResult88 = (float2(length( temp_output_80_0 ) , (0.0 + (atan2( break84.y , break84.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 Polar135 = appendResult88;
				float2 uv_Main_Tex = IN.ase_texcoord3.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 lerpResult108 = lerp( Polar135 , uv_Main_Tex , _NormalorPolar);
				float2 appendResult111 = (float2(_MainTilingOffset.x , _MainTilingOffset.y));
				float4 texCoord116 = IN.ase_texcoord4;
				texCoord116.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult110 = (float2(texCoord116.x , texCoord116.y));
				float2 temp_output_112_0 = (lerpResult108*appendResult111 + appendResult110);
				float2 appendResult53 = (float2(_Noise_Uspeed , _Nosie_Vspeed));
				float2 texCoord50 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult102 = lerp( Polar135 , texCoord50 , _NormalorPolar);
				float2 appendResult98 = (float2(_NoiseTilingOffset.x , _NoiseTilingOffset.y));
				float2 appendResult99 = (float2(_NoiseTilingOffset.z , _NoiseTilingOffset.w));
				float2 panner49 = ( 1.0 * _Time.y * appendResult53 + (lerpResult102*appendResult98 + appendResult99));
				float4 temp_output_54_0 = ( tex2D( _Noise_Tex, panner49 ) * texCoord116.z * _Noise_Power );
				float4 Noise132 = temp_output_54_0;
				float4 tex2DNode35 = tex2D( _Main_Tex, ( float4( temp_output_112_0, 0.0 , 0.0 ) + Noise132 ).rg );
				float4 temp_cast_2 = (_Main_curv).xxxx;
				float4 temp_cast_3 = ((( _Main_Alpha )?( pow( tex2DNode35.a , _Main_curv ) ):( pow( tex2DNode35.r , _Main_curv ) ))).xxxx;
				float4 lerpResult69 = lerp( pow( tex2DNode35 , temp_cast_2 ) , temp_cast_3 , _RGBorR);
				float2 appendResult59 = (float2(_Diss_Uspeed , _Diss_Vspeed));
				float2 texCoord93 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult94 = lerp( Polar135 , texCoord93 , _NormalorPolar);
				float2 appendResult91 = (float2(_DissTilingOffset.x , _DissTilingOffset.y));
				float2 appendResult92 = (float2(_DissTilingOffset.z , _DissTilingOffset.w));
				float2 panner60 = ( 1.0 * _Time.y * appendResult59 + (lerpResult94*appendResult91 + appendResult92));
				float4 tex2DNode5 = tex2D( _Dissolve_Tex, ( float4( panner60, 0.0 , 0.0 ) + temp_output_54_0 ).rg );
				float2 uv_Dissolve_Gra = IN.ase_texcoord3.xy * _Dissolve_Gra_ST.xy + _Dissolve_Gra_ST.zw;
				float smoothstepResult13 = smoothstep( ( 1.0 - _soft ) , _soft , saturate( ( ( (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) + 1.0 ) - ( texCoord116.w * 2.0 ) ) ));
				float temp_output_27_0 = step( texCoord116.w , (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) );
				float temp_output_30_0 = ( temp_output_27_0 - step( ( texCoord116.w + _Edge ) , (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) ) );
				#ifdef _EDGE_ON_ON
				float staticSwitch34 = ( temp_output_27_0 + temp_output_30_0 );
				#else
				float staticSwitch34 = smoothstepResult13;
				#endif
				float2 appendResult179 = (float2(_ColorUspeed , _ColorVspeed));
				float2 uv_Color_Tex = IN.ase_texcoord3.xy * _Color_Tex_ST.xy + _Color_Tex_ST.zw;
				float2 panner170 = ( 1.0 * _Time.y * appendResult179 + uv_Color_Tex);
				float4 temp_cast_6 = (_Color_curv).xxxx;
				float4 temp_output_38_0 = ( lerpResult69 * _Main_Color * IN.ase_color * staticSwitch34 * pow( tex2D( _Color_Tex, panner170 ) , temp_cast_6 ) );
				float4 lerpResult72 = lerp( temp_output_38_0 , _Edge_Color , temp_output_30_0);
				#ifdef _EDGE_ON_ON
				float4 staticSwitch76 = lerpResult72;
				#else
				float4 staticSwitch76 = temp_output_38_0;
				#endif
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth149 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth149 = abs( ( screenDepth149 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_152_0 = saturate( distanceDepth149 );
				float4 lerpResult153 = lerp( staticSwitch76 , ( temp_output_152_0 * staticSwitch76 ) , _Float1);
				
				#ifdef _EDGE_ON_ON
				float staticSwitch66 = temp_output_27_0;
				#else
				float staticSwitch66 = smoothstepResult13;
				#endif
				float2 uv_MaskTex = IN.ase_texcoord3.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_107_0 = ( staticSwitch66 * (( _Main_Alpha )?( pow( tex2DNode35.a , _Main_curv ) ):( pow( tex2DNode35.r , _Main_curv ) )) * pow( tex2D( _MaskTex, uv_MaskTex ).r , _mask_curv ) * IN.ase_color.a );
				float lerpResult155 = lerp( temp_output_107_0 , ( temp_output_152_0 * temp_output_107_0 ) , _Float1);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult153.rgb;
				float Alpha = lerpResult155;
				float AlphaClipThreshold = _Mask_Clip_Value;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _EDGE_ON_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_color : COLOR;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Main_Color;
			float4 _DissTilingOffset;
			float4 _Dissolve_Gra_ST;
			float4 _NoiseTilingOffset;
			float4 _MainTilingOffset;
			float4 _Main_Tex_ST;
			float4 _Color_Tex_ST;
			float4 _Edge_Color;
			float4 _MaskTex_ST;
			float2 _WP_tiling;
			float2 _WP_panner;
			float _Color_curv;
			float _Diss_Vspeed;
			float _ColorVspeed;
			float _ColorUspeed;
			float _Depth;
			float _Edge;
			float _Dissolve_Gra_Curv;
			float _Float1;
			float _Diss_Uspeed;
			float _BlendDst;
			float _soft;
			float _mask_curv;
			float _RGBorR;
			float _Main_Alpha;
			float _Main_curv;
			float _Noise_Power;
			float _Nosie_Vspeed;
			float _Noise_Uspeed;
			float _NormalorPolar;
			float _WP_strong;
			float _Ztest;
			float _CullMode;
			float _Zwrite;
			float _BlendScr;
			float _Dissolve_Gra_On;
			float _Mask_Clip_Value;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _WP_texture;
			sampler2D _Dissolve_Tex;
			sampler2D _Noise_Tex;
			sampler2D _Dissolve_Gra;
			sampler2D _Main_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 panner216 = ( 1.0 * _Time.y * ( _WP_panner + float2( 0,0 ) ) + float2( 0,0 ));
				float4 texCoord145 = v.ase_texcoord2;
				texCoord145.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult233 = (float2(texCoord145.x , texCoord145.y));
				float2 texCoord217 = v.ase_texcoord * _WP_tiling + ( panner216 + appendResult233 );
				float4 tex2DNode219 = tex2Dlod( _WP_texture, float4( texCoord217, 0, 0.0) );
				float4 temp_output_235_0 = ( ( ( 0.1 * ( tex2DNode219 * texCoord145.z ) ) * float4( v.ase_normal , 0.0 ) ) * _WP_strong );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord4 = screenPos;
				
				o.ase_texcoord2 = v.ase_texcoord;
				o.ase_texcoord3 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_235_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = temp_output_235_0.rgb;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = o.clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 appendResult59 = (float2(_Diss_Uspeed , _Diss_Vspeed));
				float4 texCoord78 = IN.ase_texcoord2;
				texCoord78.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult79 = (float2(texCoord78.x , texCoord78.y));
				float2 temp_output_80_0 = (appendResult79*2.0 + -1.0);
				float2 break84 = temp_output_80_0;
				float2 appendResult88 = (float2(length( temp_output_80_0 ) , (0.0 + (atan2( break84.y , break84.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 Polar135 = appendResult88;
				float2 texCoord93 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult94 = lerp( Polar135 , texCoord93 , _NormalorPolar);
				float2 appendResult91 = (float2(_DissTilingOffset.x , _DissTilingOffset.y));
				float2 appendResult92 = (float2(_DissTilingOffset.z , _DissTilingOffset.w));
				float2 panner60 = ( 1.0 * _Time.y * appendResult59 + (lerpResult94*appendResult91 + appendResult92));
				float2 appendResult53 = (float2(_Noise_Uspeed , _Nosie_Vspeed));
				float2 texCoord50 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult102 = lerp( Polar135 , texCoord50 , _NormalorPolar);
				float2 appendResult98 = (float2(_NoiseTilingOffset.x , _NoiseTilingOffset.y));
				float2 appendResult99 = (float2(_NoiseTilingOffset.z , _NoiseTilingOffset.w));
				float2 panner49 = ( 1.0 * _Time.y * appendResult53 + (lerpResult102*appendResult98 + appendResult99));
				float4 texCoord116 = IN.ase_texcoord3;
				texCoord116.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float4 temp_output_54_0 = ( tex2D( _Noise_Tex, panner49 ) * texCoord116.z * _Noise_Power );
				float4 tex2DNode5 = tex2D( _Dissolve_Tex, ( float4( panner60, 0.0 , 0.0 ) + temp_output_54_0 ).rg );
				float2 uv_Dissolve_Gra = IN.ase_texcoord2.xy * _Dissolve_Gra_ST.xy + _Dissolve_Gra_ST.zw;
				float smoothstepResult13 = smoothstep( ( 1.0 - _soft ) , _soft , saturate( ( ( (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) + 1.0 ) - ( texCoord116.w * 2.0 ) ) ));
				float temp_output_27_0 = step( texCoord116.w , (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) );
				#ifdef _EDGE_ON_ON
				float staticSwitch66 = temp_output_27_0;
				#else
				float staticSwitch66 = smoothstepResult13;
				#endif
				float2 uv_Main_Tex = IN.ase_texcoord2.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 lerpResult108 = lerp( Polar135 , uv_Main_Tex , _NormalorPolar);
				float2 appendResult111 = (float2(_MainTilingOffset.x , _MainTilingOffset.y));
				float2 appendResult110 = (float2(texCoord116.x , texCoord116.y));
				float2 temp_output_112_0 = (lerpResult108*appendResult111 + appendResult110);
				float4 Noise132 = temp_output_54_0;
				float4 tex2DNode35 = tex2D( _Main_Tex, ( float4( temp_output_112_0, 0.0 , 0.0 ) + Noise132 ).rg );
				float2 uv_MaskTex = IN.ase_texcoord2.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_107_0 = ( staticSwitch66 * (( _Main_Alpha )?( pow( tex2DNode35.a , _Main_curv ) ):( pow( tex2DNode35.r , _Main_curv ) )) * pow( tex2D( _MaskTex, uv_MaskTex ).r , _mask_curv ) * IN.ase_color.a );
				float4 screenPos = IN.ase_texcoord4;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth149 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth149 = abs( ( screenDepth149 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_152_0 = saturate( distanceDepth149 );
				float lerpResult155 = lerp( temp_output_107_0 , ( temp_output_152_0 * temp_output_107_0 ) , _Float1);
				
				float Alpha = lerpResult155;
				float AlphaClipThreshold = _Mask_Clip_Value;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

		
		Pass
		{
			
			Name "Universal2D"
			Tags { "LightMode"="Universal2D" }
			
			Blend [_BlendScr] [_BlendDst]
			ZWrite [_Zwrite]
			ZTest [_Ztest]
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma multi_compile _ LIGHTMAP_ON
			//#pragma multi_compile _ DIRLIGHTMAP_COMBINED
			#pragma shader_feature _ _SAMPLE_GI
			//#pragma multi_compile _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
			//#pragma multi_compile _ DEBUG_DISPLAY
			#define SHADERPASS SHADERPASS_UNLIT


			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Debug/Debugging3D.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Input.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceData.hlsl"


			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _EDGE_ON_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Main_Color;
			float4 _DissTilingOffset;
			float4 _Dissolve_Gra_ST;
			float4 _NoiseTilingOffset;
			float4 _MainTilingOffset;
			float4 _Main_Tex_ST;
			float4 _Color_Tex_ST;
			float4 _Edge_Color;
			float4 _MaskTex_ST;
			float2 _WP_tiling;
			float2 _WP_panner;
			float _Color_curv;
			float _Diss_Vspeed;
			float _ColorVspeed;
			float _ColorUspeed;
			float _Depth;
			float _Edge;
			float _Dissolve_Gra_Curv;
			float _Float1;
			float _Diss_Uspeed;
			float _BlendDst;
			float _soft;
			float _mask_curv;
			float _RGBorR;
			float _Main_Alpha;
			float _Main_curv;
			float _Noise_Power;
			float _Nosie_Vspeed;
			float _Noise_Uspeed;
			float _NormalorPolar;
			float _WP_strong;
			float _Ztest;
			float _CullMode;
			float _Zwrite;
			float _BlendScr;
			float _Dissolve_Gra_On;
			float _Mask_Clip_Value;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _WP_texture;
			sampler2D _Main_Tex;
			sampler2D _Noise_Tex;
			sampler2D _Dissolve_Tex;
			sampler2D _Dissolve_Gra;
			sampler2D _Color_Tex;
			uniform float4 _CameraDepthTexture_TexelSize;
			sampler2D _MaskTex;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 panner216 = ( 1.0 * _Time.y * ( _WP_panner + float2( 0,0 ) ) + float2( 0,0 ));
				float4 texCoord145 = v.ase_texcoord2;
				texCoord145.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult233 = (float2(texCoord145.x , texCoord145.y));
				float2 texCoord217 = v.ase_texcoord * _WP_tiling + ( panner216 + appendResult233 );
				float4 tex2DNode219 = tex2Dlod( _WP_texture, float4( texCoord217, 0, 0.0) );
				float4 temp_output_235_0 = ( ( ( 0.1 * ( tex2DNode219 * texCoord145.z ) ) * float4( v.ase_normal , 0.0 ) ) * _WP_strong );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord3 = v.ase_texcoord;
				o.ase_texcoord4 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_235_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = temp_output_235_0.rgb;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float4 texCoord78 = IN.ase_texcoord3;
				texCoord78.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult79 = (float2(texCoord78.x , texCoord78.y));
				float2 temp_output_80_0 = (appendResult79*2.0 + -1.0);
				float2 break84 = temp_output_80_0;
				float2 appendResult88 = (float2(length( temp_output_80_0 ) , (0.0 + (atan2( break84.y , break84.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 Polar135 = appendResult88;
				float2 uv_Main_Tex = IN.ase_texcoord3.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 lerpResult108 = lerp( Polar135 , uv_Main_Tex , _NormalorPolar);
				float2 appendResult111 = (float2(_MainTilingOffset.x , _MainTilingOffset.y));
				float4 texCoord116 = IN.ase_texcoord4;
				texCoord116.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult110 = (float2(texCoord116.x , texCoord116.y));
				float2 temp_output_112_0 = (lerpResult108*appendResult111 + appendResult110);
				float2 appendResult53 = (float2(_Noise_Uspeed , _Nosie_Vspeed));
				float2 texCoord50 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult102 = lerp( Polar135 , texCoord50 , _NormalorPolar);
				float2 appendResult98 = (float2(_NoiseTilingOffset.x , _NoiseTilingOffset.y));
				float2 appendResult99 = (float2(_NoiseTilingOffset.z , _NoiseTilingOffset.w));
				float2 panner49 = ( 1.0 * _Time.y * appendResult53 + (lerpResult102*appendResult98 + appendResult99));
				float4 temp_output_54_0 = ( tex2D( _Noise_Tex, panner49 ) * texCoord116.z * _Noise_Power );
				float4 Noise132 = temp_output_54_0;
				float4 tex2DNode35 = tex2D( _Main_Tex, ( float4( temp_output_112_0, 0.0 , 0.0 ) + Noise132 ).rg );
				float4 temp_cast_2 = (_Main_curv).xxxx;
				float4 temp_cast_3 = ((( _Main_Alpha )?( pow( tex2DNode35.a , _Main_curv ) ):( pow( tex2DNode35.r , _Main_curv ) ))).xxxx;
				float4 lerpResult69 = lerp( pow( tex2DNode35 , temp_cast_2 ) , temp_cast_3 , _RGBorR);
				float2 appendResult59 = (float2(_Diss_Uspeed , _Diss_Vspeed));
				float2 texCoord93 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult94 = lerp( Polar135 , texCoord93 , _NormalorPolar);
				float2 appendResult91 = (float2(_DissTilingOffset.x , _DissTilingOffset.y));
				float2 appendResult92 = (float2(_DissTilingOffset.z , _DissTilingOffset.w));
				float2 panner60 = ( 1.0 * _Time.y * appendResult59 + (lerpResult94*appendResult91 + appendResult92));
				float4 tex2DNode5 = tex2D( _Dissolve_Tex, ( float4( panner60, 0.0 , 0.0 ) + temp_output_54_0 ).rg );
				float2 uv_Dissolve_Gra = IN.ase_texcoord3.xy * _Dissolve_Gra_ST.xy + _Dissolve_Gra_ST.zw;
				float smoothstepResult13 = smoothstep( ( 1.0 - _soft ) , _soft , saturate( ( ( (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) + 1.0 ) - ( texCoord116.w * 2.0 ) ) ));
				float temp_output_27_0 = step( texCoord116.w , (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) );
				float temp_output_30_0 = ( temp_output_27_0 - step( ( texCoord116.w + _Edge ) , (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) ) );
				#ifdef _EDGE_ON_ON
				float staticSwitch34 = ( temp_output_27_0 + temp_output_30_0 );
				#else
				float staticSwitch34 = smoothstepResult13;
				#endif
				float2 appendResult179 = (float2(_ColorUspeed , _ColorVspeed));
				float2 uv_Color_Tex = IN.ase_texcoord3.xy * _Color_Tex_ST.xy + _Color_Tex_ST.zw;
				float2 panner170 = ( 1.0 * _Time.y * appendResult179 + uv_Color_Tex);
				float4 temp_cast_6 = (_Color_curv).xxxx;
				float4 temp_output_38_0 = ( lerpResult69 * _Main_Color * IN.ase_color * staticSwitch34 * pow( tex2D( _Color_Tex, panner170 ) , temp_cast_6 ) );
				float4 lerpResult72 = lerp( temp_output_38_0 , _Edge_Color , temp_output_30_0);
				#ifdef _EDGE_ON_ON
				float4 staticSwitch76 = lerpResult72;
				#else
				float4 staticSwitch76 = temp_output_38_0;
				#endif
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth149 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth149 = abs( ( screenDepth149 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_152_0 = saturate( distanceDepth149 );
				float4 lerpResult153 = lerp( staticSwitch76 , ( temp_output_152_0 * staticSwitch76 ) , _Float1);
				
				#ifdef _EDGE_ON_ON
				float staticSwitch66 = temp_output_27_0;
				#else
				float staticSwitch66 = smoothstepResult13;
				#endif
				float2 uv_MaskTex = IN.ase_texcoord3.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_107_0 = ( staticSwitch66 * (( _Main_Alpha )?( pow( tex2DNode35.a , _Main_curv ) ):( pow( tex2DNode35.r , _Main_curv ) )) * pow( tex2D( _MaskTex, uv_MaskTex ).r , _mask_curv ) * IN.ase_color.a );
				float lerpResult155 = lerp( temp_output_107_0 , ( temp_output_152_0 * temp_output_107_0 ) , _Float1);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult153.rgb;
				float Alpha = lerpResult155;
				float AlphaClipThreshold = _Mask_Clip_Value;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#if defined(_DBUFFER)
					ApplyDecalToBaseColor(IN.clipPos, Color);
				#endif

				#if defined(_ALPHAPREMULTIPLY_ON)
				Color *= Alpha;
				#endif


				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}


		
        Pass
        {
			
            Name "SceneSelectionPass"
            Tags { "LightMode"="SceneSelectionPass" }
        
			Cull Off

			HLSLPROGRAM
        
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

        
			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _EDGE_ON_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _Main_Color;
			float4 _DissTilingOffset;
			float4 _Dissolve_Gra_ST;
			float4 _NoiseTilingOffset;
			float4 _MainTilingOffset;
			float4 _Main_Tex_ST;
			float4 _Color_Tex_ST;
			float4 _Edge_Color;
			float4 _MaskTex_ST;
			float2 _WP_tiling;
			float2 _WP_panner;
			float _Color_curv;
			float _Diss_Vspeed;
			float _ColorVspeed;
			float _ColorUspeed;
			float _Depth;
			float _Edge;
			float _Dissolve_Gra_Curv;
			float _Float1;
			float _Diss_Uspeed;
			float _BlendDst;
			float _soft;
			float _mask_curv;
			float _RGBorR;
			float _Main_Alpha;
			float _Main_curv;
			float _Noise_Power;
			float _Nosie_Vspeed;
			float _Noise_Uspeed;
			float _NormalorPolar;
			float _WP_strong;
			float _Ztest;
			float _CullMode;
			float _Zwrite;
			float _BlendScr;
			float _Dissolve_Gra_On;
			float _Mask_Clip_Value;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _WP_texture;
			sampler2D _Dissolve_Tex;
			sampler2D _Noise_Tex;
			sampler2D _Dissolve_Gra;
			sampler2D _Main_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			int _ObjectId;
			int _PassValue;

			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				float2 panner216 = ( 1.0 * _Time.y * ( _WP_panner + float2( 0,0 ) ) + float2( 0,0 ));
				float4 texCoord145 = v.ase_texcoord2;
				texCoord145.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult233 = (float2(texCoord145.x , texCoord145.y));
				float2 texCoord217 = v.ase_texcoord * _WP_tiling + ( panner216 + appendResult233 );
				float4 tex2DNode219 = tex2Dlod( _WP_texture, float4( texCoord217, 0, 0.0) );
				float4 temp_output_235_0 = ( ( ( 0.1 * ( tex2DNode219 * texCoord145.z ) ) * float4( v.ase_normal , 0.0 ) ) * _WP_strong );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_235_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = temp_output_235_0.rgb;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif
			
			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 appendResult59 = (float2(_Diss_Uspeed , _Diss_Vspeed));
				float4 texCoord78 = IN.ase_texcoord;
				texCoord78.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult79 = (float2(texCoord78.x , texCoord78.y));
				float2 temp_output_80_0 = (appendResult79*2.0 + -1.0);
				float2 break84 = temp_output_80_0;
				float2 appendResult88 = (float2(length( temp_output_80_0 ) , (0.0 + (atan2( break84.y , break84.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 Polar135 = appendResult88;
				float2 texCoord93 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult94 = lerp( Polar135 , texCoord93 , _NormalorPolar);
				float2 appendResult91 = (float2(_DissTilingOffset.x , _DissTilingOffset.y));
				float2 appendResult92 = (float2(_DissTilingOffset.z , _DissTilingOffset.w));
				float2 panner60 = ( 1.0 * _Time.y * appendResult59 + (lerpResult94*appendResult91 + appendResult92));
				float2 appendResult53 = (float2(_Noise_Uspeed , _Nosie_Vspeed));
				float2 texCoord50 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult102 = lerp( Polar135 , texCoord50 , _NormalorPolar);
				float2 appendResult98 = (float2(_NoiseTilingOffset.x , _NoiseTilingOffset.y));
				float2 appendResult99 = (float2(_NoiseTilingOffset.z , _NoiseTilingOffset.w));
				float2 panner49 = ( 1.0 * _Time.y * appendResult53 + (lerpResult102*appendResult98 + appendResult99));
				float4 texCoord116 = IN.ase_texcoord1;
				texCoord116.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 temp_output_54_0 = ( tex2D( _Noise_Tex, panner49 ) * texCoord116.z * _Noise_Power );
				float4 tex2DNode5 = tex2D( _Dissolve_Tex, ( float4( panner60, 0.0 , 0.0 ) + temp_output_54_0 ).rg );
				float2 uv_Dissolve_Gra = IN.ase_texcoord.xy * _Dissolve_Gra_ST.xy + _Dissolve_Gra_ST.zw;
				float smoothstepResult13 = smoothstep( ( 1.0 - _soft ) , _soft , saturate( ( ( (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) + 1.0 ) - ( texCoord116.w * 2.0 ) ) ));
				float temp_output_27_0 = step( texCoord116.w , (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) );
				#ifdef _EDGE_ON_ON
				float staticSwitch66 = temp_output_27_0;
				#else
				float staticSwitch66 = smoothstepResult13;
				#endif
				float2 uv_Main_Tex = IN.ase_texcoord.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 lerpResult108 = lerp( Polar135 , uv_Main_Tex , _NormalorPolar);
				float2 appendResult111 = (float2(_MainTilingOffset.x , _MainTilingOffset.y));
				float2 appendResult110 = (float2(texCoord116.x , texCoord116.y));
				float2 temp_output_112_0 = (lerpResult108*appendResult111 + appendResult110);
				float4 Noise132 = temp_output_54_0;
				float4 tex2DNode35 = tex2D( _Main_Tex, ( float4( temp_output_112_0, 0.0 , 0.0 ) + Noise132 ).rg );
				float2 uv_MaskTex = IN.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_107_0 = ( staticSwitch66 * (( _Main_Alpha )?( pow( tex2DNode35.a , _Main_curv ) ):( pow( tex2DNode35.r , _Main_curv ) )) * pow( tex2D( _MaskTex, uv_MaskTex ).r , _mask_curv ) * IN.ase_color.a );
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth149 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth149 = abs( ( screenDepth149 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_152_0 = saturate( distanceDepth149 );
				float lerpResult155 = lerp( temp_output_107_0 , ( temp_output_152_0 * temp_output_107_0 ) , _Float1);
				
				surfaceDescription.Alpha = lerpResult155;
				surfaceDescription.AlphaClipThreshold = _Mask_Clip_Value;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = half4(_ObjectId, _PassValue, 1.0, 1.0);
				return outColor;
			}

			ENDHLSL
        }

		
        Pass
        {
			
            Name "ScenePickingPass"
            Tags { "LightMode"="Picking" }
        
			HLSLPROGRAM

			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1


			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define SHADERPASS SHADERPASS_DEPTHONLY
			

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _EDGE_ON_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _Main_Color;
			float4 _DissTilingOffset;
			float4 _Dissolve_Gra_ST;
			float4 _NoiseTilingOffset;
			float4 _MainTilingOffset;
			float4 _Main_Tex_ST;
			float4 _Color_Tex_ST;
			float4 _Edge_Color;
			float4 _MaskTex_ST;
			float2 _WP_tiling;
			float2 _WP_panner;
			float _Color_curv;
			float _Diss_Vspeed;
			float _ColorVspeed;
			float _ColorUspeed;
			float _Depth;
			float _Edge;
			float _Dissolve_Gra_Curv;
			float _Float1;
			float _Diss_Uspeed;
			float _BlendDst;
			float _soft;
			float _mask_curv;
			float _RGBorR;
			float _Main_Alpha;
			float _Main_curv;
			float _Noise_Power;
			float _Nosie_Vspeed;
			float _Noise_Uspeed;
			float _NormalorPolar;
			float _WP_strong;
			float _Ztest;
			float _CullMode;
			float _Zwrite;
			float _BlendScr;
			float _Dissolve_Gra_On;
			float _Mask_Clip_Value;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END

			sampler2D _WP_texture;
			sampler2D _Dissolve_Tex;
			sampler2D _Noise_Tex;
			sampler2D _Dissolve_Gra;
			sampler2D _Main_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
        
			float4 _SelectionID;

        
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);


				float2 panner216 = ( 1.0 * _Time.y * ( _WP_panner + float2( 0,0 ) ) + float2( 0,0 ));
				float4 texCoord145 = v.ase_texcoord2;
				texCoord145.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult233 = (float2(texCoord145.x , texCoord145.y));
				float2 texCoord217 = v.ase_texcoord * _WP_tiling + ( panner216 + appendResult233 );
				float4 tex2DNode219 = tex2Dlod( _WP_texture, float4( texCoord217, 0, 0.0) );
				float4 temp_output_235_0 = ( ( ( 0.1 * ( tex2DNode219 * texCoord145.z ) ) * float4( v.ase_normal , 0.0 ) ) * _WP_strong );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord2 = screenPos;
				
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_235_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = temp_output_235_0.rgb;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				o.clipPos = TransformWorldToHClip(positionWS);
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 appendResult59 = (float2(_Diss_Uspeed , _Diss_Vspeed));
				float4 texCoord78 = IN.ase_texcoord;
				texCoord78.xy = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult79 = (float2(texCoord78.x , texCoord78.y));
				float2 temp_output_80_0 = (appendResult79*2.0 + -1.0);
				float2 break84 = temp_output_80_0;
				float2 appendResult88 = (float2(length( temp_output_80_0 ) , (0.0 + (atan2( break84.y , break84.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 Polar135 = appendResult88;
				float2 texCoord93 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult94 = lerp( Polar135 , texCoord93 , _NormalorPolar);
				float2 appendResult91 = (float2(_DissTilingOffset.x , _DissTilingOffset.y));
				float2 appendResult92 = (float2(_DissTilingOffset.z , _DissTilingOffset.w));
				float2 panner60 = ( 1.0 * _Time.y * appendResult59 + (lerpResult94*appendResult91 + appendResult92));
				float2 appendResult53 = (float2(_Noise_Uspeed , _Nosie_Vspeed));
				float2 texCoord50 = IN.ase_texcoord.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult102 = lerp( Polar135 , texCoord50 , _NormalorPolar);
				float2 appendResult98 = (float2(_NoiseTilingOffset.x , _NoiseTilingOffset.y));
				float2 appendResult99 = (float2(_NoiseTilingOffset.z , _NoiseTilingOffset.w));
				float2 panner49 = ( 1.0 * _Time.y * appendResult53 + (lerpResult102*appendResult98 + appendResult99));
				float4 texCoord116 = IN.ase_texcoord1;
				texCoord116.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float4 temp_output_54_0 = ( tex2D( _Noise_Tex, panner49 ) * texCoord116.z * _Noise_Power );
				float4 tex2DNode5 = tex2D( _Dissolve_Tex, ( float4( panner60, 0.0 , 0.0 ) + temp_output_54_0 ).rg );
				float2 uv_Dissolve_Gra = IN.ase_texcoord.xy * _Dissolve_Gra_ST.xy + _Dissolve_Gra_ST.zw;
				float smoothstepResult13 = smoothstep( ( 1.0 - _soft ) , _soft , saturate( ( ( (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) + 1.0 ) - ( texCoord116.w * 2.0 ) ) ));
				float temp_output_27_0 = step( texCoord116.w , (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) );
				#ifdef _EDGE_ON_ON
				float staticSwitch66 = temp_output_27_0;
				#else
				float staticSwitch66 = smoothstepResult13;
				#endif
				float2 uv_Main_Tex = IN.ase_texcoord.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 lerpResult108 = lerp( Polar135 , uv_Main_Tex , _NormalorPolar);
				float2 appendResult111 = (float2(_MainTilingOffset.x , _MainTilingOffset.y));
				float2 appendResult110 = (float2(texCoord116.x , texCoord116.y));
				float2 temp_output_112_0 = (lerpResult108*appendResult111 + appendResult110);
				float4 Noise132 = temp_output_54_0;
				float4 tex2DNode35 = tex2D( _Main_Tex, ( float4( temp_output_112_0, 0.0 , 0.0 ) + Noise132 ).rg );
				float2 uv_MaskTex = IN.ase_texcoord.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_107_0 = ( staticSwitch66 * (( _Main_Alpha )?( pow( tex2DNode35.a , _Main_curv ) ):( pow( tex2DNode35.r , _Main_curv ) )) * pow( tex2D( _MaskTex, uv_MaskTex ).r , _mask_curv ) * IN.ase_color.a );
				float4 screenPos = IN.ase_texcoord2;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth149 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth149 = abs( ( screenDepth149 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_152_0 = saturate( distanceDepth149 );
				float lerpResult155 = lerp( temp_output_107_0 , ( temp_output_152_0 * temp_output_107_0 ) , _Float1);
				
				surfaceDescription.Alpha = lerpResult155;
				surfaceDescription.AlphaClipThreshold = _Mask_Clip_Value;


				#if _ALPHATEST_ON
					float alphaClipThreshold = 0.01f;
					#if ALPHA_CLIP_THRESHOLD
						alphaClipThreshold = surfaceDescription.AlphaClipThreshold;
					#endif
					clip(surfaceDescription.Alpha - alphaClipThreshold);
				#endif

				half4 outColor = 0;
				outColor = _SelectionID;
				
				return outColor;
			}
        
			ENDHLSL
        }
		
		
        Pass
        {
			
            Name "DepthNormals"
            Tags { "LightMode"="DepthNormalsOnly" }

			ZTest LEqual
			ZWrite On

        
			HLSLPROGRAM
			
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			
			#pragma only_renderers d3d11 glcore gles gles3 
			#pragma multi_compile_fog
			#pragma instancing_options renderinglayer
			#pragma vertex vert
			#pragma fragment frag

        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define VARYINGS_NEED_NORMAL_WS

			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY

			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _EDGE_ON_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _Main_Color;
			float4 _DissTilingOffset;
			float4 _Dissolve_Gra_ST;
			float4 _NoiseTilingOffset;
			float4 _MainTilingOffset;
			float4 _Main_Tex_ST;
			float4 _Color_Tex_ST;
			float4 _Edge_Color;
			float4 _MaskTex_ST;
			float2 _WP_tiling;
			float2 _WP_panner;
			float _Color_curv;
			float _Diss_Vspeed;
			float _ColorVspeed;
			float _ColorUspeed;
			float _Depth;
			float _Edge;
			float _Dissolve_Gra_Curv;
			float _Float1;
			float _Diss_Uspeed;
			float _BlendDst;
			float _soft;
			float _mask_curv;
			float _RGBorR;
			float _Main_Alpha;
			float _Main_curv;
			float _Noise_Power;
			float _Nosie_Vspeed;
			float _Noise_Uspeed;
			float _NormalorPolar;
			float _WP_strong;
			float _Ztest;
			float _CullMode;
			float _Zwrite;
			float _BlendScr;
			float _Dissolve_Gra_On;
			float _Mask_Clip_Value;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _WP_texture;
			sampler2D _Dissolve_Tex;
			sampler2D _Noise_Tex;
			sampler2D _Dissolve_Gra;
			sampler2D _Main_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			      
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
        
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 panner216 = ( 1.0 * _Time.y * ( _WP_panner + float2( 0,0 ) ) + float2( 0,0 ));
				float4 texCoord145 = v.ase_texcoord2;
				texCoord145.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult233 = (float2(texCoord145.x , texCoord145.y));
				float2 texCoord217 = v.ase_texcoord * _WP_tiling + ( panner216 + appendResult233 );
				float4 tex2DNode219 = tex2Dlod( _WP_texture, float4( texCoord217, 0, 0.0) );
				float4 temp_output_235_0 = ( ( ( 0.1 * ( tex2DNode219 * texCoord145.z ) ) * float4( v.ase_normal , 0.0 ) ) * _WP_strong );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_235_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = temp_output_235_0.rgb;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;

				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 appendResult59 = (float2(_Diss_Uspeed , _Diss_Vspeed));
				float4 texCoord78 = IN.ase_texcoord1;
				texCoord78.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult79 = (float2(texCoord78.x , texCoord78.y));
				float2 temp_output_80_0 = (appendResult79*2.0 + -1.0);
				float2 break84 = temp_output_80_0;
				float2 appendResult88 = (float2(length( temp_output_80_0 ) , (0.0 + (atan2( break84.y , break84.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 Polar135 = appendResult88;
				float2 texCoord93 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult94 = lerp( Polar135 , texCoord93 , _NormalorPolar);
				float2 appendResult91 = (float2(_DissTilingOffset.x , _DissTilingOffset.y));
				float2 appendResult92 = (float2(_DissTilingOffset.z , _DissTilingOffset.w));
				float2 panner60 = ( 1.0 * _Time.y * appendResult59 + (lerpResult94*appendResult91 + appendResult92));
				float2 appendResult53 = (float2(_Noise_Uspeed , _Nosie_Vspeed));
				float2 texCoord50 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult102 = lerp( Polar135 , texCoord50 , _NormalorPolar);
				float2 appendResult98 = (float2(_NoiseTilingOffset.x , _NoiseTilingOffset.y));
				float2 appendResult99 = (float2(_NoiseTilingOffset.z , _NoiseTilingOffset.w));
				float2 panner49 = ( 1.0 * _Time.y * appendResult53 + (lerpResult102*appendResult98 + appendResult99));
				float4 texCoord116 = IN.ase_texcoord2;
				texCoord116.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float4 temp_output_54_0 = ( tex2D( _Noise_Tex, panner49 ) * texCoord116.z * _Noise_Power );
				float4 tex2DNode5 = tex2D( _Dissolve_Tex, ( float4( panner60, 0.0 , 0.0 ) + temp_output_54_0 ).rg );
				float2 uv_Dissolve_Gra = IN.ase_texcoord1.xy * _Dissolve_Gra_ST.xy + _Dissolve_Gra_ST.zw;
				float smoothstepResult13 = smoothstep( ( 1.0 - _soft ) , _soft , saturate( ( ( (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) + 1.0 ) - ( texCoord116.w * 2.0 ) ) ));
				float temp_output_27_0 = step( texCoord116.w , (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) );
				#ifdef _EDGE_ON_ON
				float staticSwitch66 = temp_output_27_0;
				#else
				float staticSwitch66 = smoothstepResult13;
				#endif
				float2 uv_Main_Tex = IN.ase_texcoord1.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 lerpResult108 = lerp( Polar135 , uv_Main_Tex , _NormalorPolar);
				float2 appendResult111 = (float2(_MainTilingOffset.x , _MainTilingOffset.y));
				float2 appendResult110 = (float2(texCoord116.x , texCoord116.y));
				float2 temp_output_112_0 = (lerpResult108*appendResult111 + appendResult110);
				float4 Noise132 = temp_output_54_0;
				float4 tex2DNode35 = tex2D( _Main_Tex, ( float4( temp_output_112_0, 0.0 , 0.0 ) + Noise132 ).rg );
				float2 uv_MaskTex = IN.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_107_0 = ( staticSwitch66 * (( _Main_Alpha )?( pow( tex2DNode35.a , _Main_curv ) ):( pow( tex2DNode35.r , _Main_curv ) )) * pow( tex2D( _MaskTex, uv_MaskTex ).r , _mask_curv ) * IN.ase_color.a );
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth149 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth149 = abs( ( screenDepth149 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_152_0 = saturate( distanceDepth149 );
				float lerpResult155 = lerp( temp_output_107_0 , ( temp_output_152_0 * temp_output_107_0 ) , _Float1);
				
				surfaceDescription.Alpha = lerpResult155;
				surfaceDescription.AlphaClipThreshold = _Mask_Clip_Value;

				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}
        
			ENDHLSL
        }

		
        Pass
        {
			
            Name "DepthNormalsOnly"
            Tags { "LightMode"="DepthNormalsOnly" }
        
			ZTest LEqual
			ZWrite On
        
        
			HLSLPROGRAM
        
			#define _RECEIVE_SHADOWS_OFF 1
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

        
			#pragma exclude_renderers glcore gles gles3 
			#pragma vertex vert
			#pragma fragment frag
        
			#define ATTRIBUTES_NEED_NORMAL
			#define ATTRIBUTES_NEED_TANGENT
			#define ATTRIBUTES_NEED_TEXCOORD1
			#define VARYINGS_NEED_NORMAL_WS
			#define VARYINGS_NEED_TANGENT_WS
        
			#define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
        
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
        
			#define ASE_NEEDS_VERT_NORMAL
			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _EDGE_ON_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				float3 normalWS : TEXCOORD0;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord3 : TEXCOORD3;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
        
			CBUFFER_START(UnityPerMaterial)
			float4 _Main_Color;
			float4 _DissTilingOffset;
			float4 _Dissolve_Gra_ST;
			float4 _NoiseTilingOffset;
			float4 _MainTilingOffset;
			float4 _Main_Tex_ST;
			float4 _Color_Tex_ST;
			float4 _Edge_Color;
			float4 _MaskTex_ST;
			float2 _WP_tiling;
			float2 _WP_panner;
			float _Color_curv;
			float _Diss_Vspeed;
			float _ColorVspeed;
			float _ColorUspeed;
			float _Depth;
			float _Edge;
			float _Dissolve_Gra_Curv;
			float _Float1;
			float _Diss_Uspeed;
			float _BlendDst;
			float _soft;
			float _mask_curv;
			float _RGBorR;
			float _Main_Alpha;
			float _Main_curv;
			float _Noise_Power;
			float _Nosie_Vspeed;
			float _Noise_Uspeed;
			float _NormalorPolar;
			float _WP_strong;
			float _Ztest;
			float _CullMode;
			float _Zwrite;
			float _BlendScr;
			float _Dissolve_Gra_On;
			float _Mask_Clip_Value;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _WP_texture;
			sampler2D _Dissolve_Tex;
			sampler2D _Noise_Tex;
			sampler2D _Dissolve_Gra;
			sampler2D _Main_Tex;
			sampler2D _MaskTex;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			struct SurfaceDescription
			{
				float Alpha;
				float AlphaClipThreshold;
			};
      
			VertexOutput VertexFunction(VertexInput v  )
			{
				VertexOutput o;
				ZERO_INITIALIZE(VertexOutput, o);

				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float2 panner216 = ( 1.0 * _Time.y * ( _WP_panner + float2( 0,0 ) ) + float2( 0,0 ));
				float4 texCoord145 = v.ase_texcoord2;
				texCoord145.xy = v.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult233 = (float2(texCoord145.x , texCoord145.y));
				float2 texCoord217 = v.ase_texcoord * _WP_tiling + ( panner216 + appendResult233 );
				float4 tex2DNode219 = tex2Dlod( _WP_texture, float4( texCoord217, 0, 0.0) );
				float4 temp_output_235_0 = ( ( ( 0.1 * ( tex2DNode219 * texCoord145.z ) ) * float4( v.ase_normal , 0.0 ) ) * _WP_strong );
				
				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord3 = screenPos;
				
				o.ase_texcoord1 = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = temp_output_235_0.rgb;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = temp_output_235_0.rgb;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float3 normalWS = TransformObjectToWorldNormal(v.ase_normal);

				o.clipPos = TransformWorldToHClip(positionWS);
				o.normalWS.xyz =  normalWS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_color : COLOR;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_color = v.ase_color;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN ) : SV_TARGET
			{
				SurfaceDescription surfaceDescription = (SurfaceDescription)0;
				float2 appendResult59 = (float2(_Diss_Uspeed , _Diss_Vspeed));
				float4 texCoord78 = IN.ase_texcoord1;
				texCoord78.xy = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult79 = (float2(texCoord78.x , texCoord78.y));
				float2 temp_output_80_0 = (appendResult79*2.0 + -1.0);
				float2 break84 = temp_output_80_0;
				float2 appendResult88 = (float2(length( temp_output_80_0 ) , (0.0 + (atan2( break84.y , break84.x ) - 0.0) * (1.0 - 0.0) / (3.141593 - 0.0))));
				float2 Polar135 = appendResult88;
				float2 texCoord93 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult94 = lerp( Polar135 , texCoord93 , _NormalorPolar);
				float2 appendResult91 = (float2(_DissTilingOffset.x , _DissTilingOffset.y));
				float2 appendResult92 = (float2(_DissTilingOffset.z , _DissTilingOffset.w));
				float2 panner60 = ( 1.0 * _Time.y * appendResult59 + (lerpResult94*appendResult91 + appendResult92));
				float2 appendResult53 = (float2(_Noise_Uspeed , _Nosie_Vspeed));
				float2 texCoord50 = IN.ase_texcoord1.xy * float2( 1,1 ) + float2( 0,0 );
				float2 lerpResult102 = lerp( Polar135 , texCoord50 , _NormalorPolar);
				float2 appendResult98 = (float2(_NoiseTilingOffset.x , _NoiseTilingOffset.y));
				float2 appendResult99 = (float2(_NoiseTilingOffset.z , _NoiseTilingOffset.w));
				float2 panner49 = ( 1.0 * _Time.y * appendResult53 + (lerpResult102*appendResult98 + appendResult99));
				float4 texCoord116 = IN.ase_texcoord2;
				texCoord116.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float4 temp_output_54_0 = ( tex2D( _Noise_Tex, panner49 ) * texCoord116.z * _Noise_Power );
				float4 tex2DNode5 = tex2D( _Dissolve_Tex, ( float4( panner60, 0.0 , 0.0 ) + temp_output_54_0 ).rg );
				float2 uv_Dissolve_Gra = IN.ase_texcoord1.xy * _Dissolve_Gra_ST.xy + _Dissolve_Gra_ST.zw;
				float smoothstepResult13 = smoothstep( ( 1.0 - _soft ) , _soft , saturate( ( ( (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) + 1.0 ) - ( texCoord116.w * 2.0 ) ) ));
				float temp_output_27_0 = step( texCoord116.w , (( _Dissolve_Gra_On )?( ( tex2DNode5.r + ( tex2D( _Dissolve_Gra, uv_Dissolve_Gra ).r * pow( _Dissolve_Gra_Curv , 1.0 ) ) ) ):( tex2DNode5.r )) );
				#ifdef _EDGE_ON_ON
				float staticSwitch66 = temp_output_27_0;
				#else
				float staticSwitch66 = smoothstepResult13;
				#endif
				float2 uv_Main_Tex = IN.ase_texcoord1.xy * _Main_Tex_ST.xy + _Main_Tex_ST.zw;
				float2 lerpResult108 = lerp( Polar135 , uv_Main_Tex , _NormalorPolar);
				float2 appendResult111 = (float2(_MainTilingOffset.x , _MainTilingOffset.y));
				float2 appendResult110 = (float2(texCoord116.x , texCoord116.y));
				float2 temp_output_112_0 = (lerpResult108*appendResult111 + appendResult110);
				float4 Noise132 = temp_output_54_0;
				float4 tex2DNode35 = tex2D( _Main_Tex, ( float4( temp_output_112_0, 0.0 , 0.0 ) + Noise132 ).rg );
				float2 uv_MaskTex = IN.ase_texcoord1.xy * _MaskTex_ST.xy + _MaskTex_ST.zw;
				float temp_output_107_0 = ( staticSwitch66 * (( _Main_Alpha )?( pow( tex2DNode35.a , _Main_curv ) ):( pow( tex2DNode35.r , _Main_curv ) )) * pow( tex2D( _MaskTex, uv_MaskTex ).r , _mask_curv ) * IN.ase_color.a );
				float4 screenPos = IN.ase_texcoord3;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth149 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth149 = abs( ( screenDepth149 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth ) );
				float temp_output_152_0 = saturate( distanceDepth149 );
				float lerpResult155 = lerp( temp_output_107_0 , ( temp_output_152_0 * temp_output_107_0 ) , _Float1);
				
				surfaceDescription.Alpha = lerpResult155;
				surfaceDescription.AlphaClipThreshold = _Mask_Clip_Value;
				
				#if _ALPHATEST_ON
					clip(surfaceDescription.Alpha - surfaceDescription.AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				float3 normalWS = IN.normalWS;
				return half4(NormalizeNormalPerPixel(normalWS), 0.0);

			}

			ENDHLSL
        }
		
	}
	
	CustomEditor "UnityEditor.ShaderGraphUnlitGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18933
1530;28;1536;775;1684.449;570.3141;3.113659;True;False
Node;AmplifyShaderEditor.CommentaryNode;134;-5706.502,-1213.92;Inherit;False;1605.175;655.3245;Polar;8;78;79;80;84;85;86;81;88;;0.8537736,1,0.8583387,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;78;-5656.502,-1163.92;Inherit;False;0;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;79;-5360.114,-1139.185;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;80;-5188.429,-1124.821;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;84;-5065.344,-821.2344;Inherit;True;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.ATan2OpNode;85;-4821.349,-815.9841;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;86;-4579.779,-812.5953;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;3.141593;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LengthOpNode;81;-4650.858,-1116.447;Inherit;True;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;88;-4336.327,-993.096;Inherit;True;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;135;-4000.907,-1133.983;Inherit;False;Polar;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;139;-3649.618,-532.868;Inherit;False;135;Polar;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;50;-3781.784,-254.2665;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;97;-3634.157,118.2596;Inherit;False;Property;_NoiseTilingOffset;NoiseTilingOffset;30;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1.44,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;95;-3863.444,-409.419;Inherit;False;Property;_NormalorPolar;Normal or Polar;35;1;[Enum];Create;True;0;2;Polar;0;Normal;1;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-3149.108,298.4554;Inherit;False;Property;_Noise_Uspeed;Noise_Uspeed;31;0;Create;True;0;0;0;False;0;False;0;-0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-3172.887,384.0402;Inherit;False;Property;_Nosie_Vspeed;Nosie_Vspeed;32;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;102;-3323.49,-230.4087;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;98;-3330.763,134.1231;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;99;-3335.011,239.7108;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-2929.067,316.2605;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;138;-3613.64,-798.8012;Inherit;False;135;Polar;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;93;-3365.808,-700.9686;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ScaleAndOffsetNode;100;-3070.271,53.79584;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;2,0;False;2;FLOAT2;-1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;90;-3271.061,-497.3499;Inherit;False;Property;_DissTilingOffset;DissTilingOffset;11;0;Create;True;0;0;0;False;0;False;1,1,0,0;0.22,0.67,0.41,-1.01;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;58;-2744.961,-348.98;Inherit;False;Property;_Diss_Uspeed;Diss_Uspeed;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;92;-3010.402,-382.9924;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;94;-2978.383,-732.3922;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-2740.001,-255.9398;Inherit;False;Property;_Diss_Vspeed;Diss_Vspeed;13;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;91;-3022.402,-513.9924;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;49;-2781.434,168.2345;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;89;-2541.282,-586.2231;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;2,0;False;2;FLOAT2;-1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;59;-2501.675,-322.2005;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;116;-2237.632,-740.5469;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;55;-2562.078,335.7135;Inherit;False;Property;_Noise_Power;Noise_Power;33;0;Create;True;0;0;0;False;0;False;0;-0.43;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-2634.805,-67.80152;Inherit;True;Property;_Noise_Tex;Noise_Tex;25;0;Create;True;0;0;0;False;0;False;-1;None;0cf295bf560387640b4eeeaf1106a5e7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-2275.819,-53.5933;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;206;-1991.425,666.7638;Inherit;False;Property;_Dissolve_Gra_Curv;Dissolve_Gra_Curv;16;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;60;-2264.772,-412.8535;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;205;-1742.623,634.6616;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-2102.686,-397.9214;Inherit;True;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;202;-2175.251,366.5349;Inherit;True;Property;_Dissolve_Gra;Dissolve_Gra;15;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;5;-1931.266,-391.7455;Inherit;True;Property;_Dissolve_Tex;Dissolve_Tex;10;0;Create;True;0;0;0;False;0;False;-1;None;3584f2bf4afb5284d91edb6a29126e62;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;207;-112.9765,396.5439;Inherit;False;2325.498;1009.869;WP;21;227;226;225;224;223;222;221;220;219;218;217;216;215;214;213;212;211;210;209;208;232;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;204;-1678.626,446.1565;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;211;12.39438,1133.845;Inherit;False;Property;_WP_panner;WP_panner;28;0;Create;True;0;0;0;False;0;False;0.5,0;0.73,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;203;-1692.689,250.4292;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;109;-1879.298,-931.2769;Inherit;False;Property;_MainTilingOffset;MainTilingOffset;8;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;136;-2733.581,-1255.194;Inherit;False;135;Polar;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;62;-2756.052,-1118.915;Inherit;False;0;35;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;108;-2347.096,-1171.832;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;213;237.2277,1118.492;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;200;-1617.017,-14.20148;Float;True;Property;_Dissolve_Gra_On;Dissolve_Gra_On;14;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;111;-1627.602,-909.5579;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1452.292,-348.2419;Inherit;False;Constant;_Float0;Float 0;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;110;-1747.728,-746.3618;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1373.694,-99.23834;Inherit;False;Constant;_Float2;Float 2;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;132;-1961.489,15.97741;Inherit;False;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;145;-526.4072,930.9845;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;6;-1349.898,-499.8206;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;112;-1460.08,-922.0964;Inherit;True;3;0;FLOAT2;0,0;False;1;FLOAT2;2,0;False;2;FLOAT2;-1,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;233;235.971,1342.564;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;133;-1500.521,-1455.049;Inherit;False;132;Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;216;360.4903,1154.667;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0.5;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;-1216.622,-129.7047;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;117;-1264.915,-1114.973;Inherit;True;2;2;0;FLOAT2;0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector2Node;215;491.3735,965.348;Inherit;False;Property;_WP_tiling;WP_tiling;27;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;14;-934.6855,-376.7404;Inherit;False;Property;_soft;soft;20;0;Create;True;0;0;0;False;0;False;1;0.515;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;11;-1215.95,-466.0393;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;232;681.3972,1284.357;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;15;-646.3661,-442.3613;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;217;764.5185,1071.101;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;2,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;192;-858.6186,-954.5632;Inherit;False;Property;_Main_curv;Main_curv;9;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;35;-981.6158,-1259.791;Inherit;True;Property;_Main_Tex;Main_Tex;5;0;Create;True;0;0;0;False;0;False;-1;None;f473f14e7a9a4494fbd9253fec091f1d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;12;-874.4232,-500.4802;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;13;-449.354,-485.3231;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;196;-586.7826,-1006.335;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;115;296.9087,-309.7112;Inherit;True;Property;_MaskTex;MaskTex;23;0;Create;True;0;0;0;False;0;False;-1;None;9ce9935b1f4a9964e95e07b570247a47;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;150;826.8525,-918.2615;Inherit;False;Property;_Depth;Depth;36;0;Create;True;0;0;0;False;0;False;0;0.47;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;219;1003.82,945.5079;Inherit;True;Property;_WP_texture;WP_texture;26;0;Create;True;0;0;0;False;0;False;-1;None;60e8aec7f4e6d844b8c205ed443732fd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;195;-597.4305,-1143.551;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;27;-955.092,-257.941;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;190;580.562,-168.1978;Inherit;False;Property;_mask_curv;mask_curv;24;0;Create;True;0;0;0;False;0;False;1;2.95;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;191;779.4191,-260.1583;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;66;-127.6038,-528.3917;Inherit;False;Property;_Keyword0;Keyword 0;22;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;34;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;162;-451.2784,-1517.138;Float;True;Property;_Main_Alpha;Main_Alpha;6;0;Create;True;0;0;0;False;0;False;0;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;149;1062.843,-989.124;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;41;-413.7712,-685.2293;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;1559.66,829.6119;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;223;1601.049,717.8708;Inherit;False;Constant;_Float3;Float 3;21;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;107;924.5529,-455.2304;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;152;1341.134,-910.7682;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;225;1613.292,1093.376;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;1770.049,791.871;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;154;1239.524,-584.6078;Inherit;False;Property;_Float1;Depth_Alpha;37;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;227;1936.132,818.2144;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;221;2062.397,1026.68;Inherit;False;Property;_WP_strong;WP_strong;29;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;156;1486.615,-300.1134;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;166;-295.1976,-2128.834;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;121;-2634.696,-1650.282;Inherit;False;Property;_Zwrite;Zwrite;0;1;[Enum];Create;True;0;2;OFF;0;ON;1;0;True;0;False;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;118;-2757.031,-1518.395;Inherit;False;Property;_CullMode;CullMode;4;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.CullMode;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;212;528.8968,835.839;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;185;-120.9355,-1943.767;Inherit;False;0;165;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;165;330.6565,-2005.157;Inherit;True;Property;_Color_Tex;Color_Tex;38;0;Create;True;0;0;0;False;0;False;-1;930ecad2afa378042953edc91daf5676;0cf295bf560387640b4eeeaf1106a5e7;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;76;1449.583,-748.2269;Inherit;False;Property;_Keyword0;Keyword 0;22;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;34;True;True;All;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;28;-894.2192,-8.997456;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;168;-305.4016,-1890.375;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ComponentMaskNode;209;169.024,670.6709;Inherit;True;False;True;False;False;1;0;FLOAT2;0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;188;-77.13082,-2170.567;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;120;-2418.283,-1634.818;Inherit;False;Property;_Ztest;Ztest;1;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.CompareFunction;True;0;False;4;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;235;2349.55,913.3629;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;198;689.3621,-1704.453;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;181;-514.3403,-1700.99;Inherit;False;Property;_ColorVspeed;ColorVspeed;41;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-310.5031,-1109.178;Inherit;False;Property;_RGBorR;RGB or R;34;1;[Enum];Create;True;0;2;RGB;0;R;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;72;835.4739,-755.2833;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;179;-270.1812,-1773.41;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;-589.6464,-61.40568;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;69;-99.58734,-1188.179;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;34;-151.3146,-386.8501;Inherit;False;Property;_Edge_on;Edge_on;22;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;155;1708.615,-399.1134;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;978.2521,-1440.15;Inherit;False;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector4Node;189;-564.3613,-1977.081;Inherit;False;Property;_ColorTilingOffset;ColorTilingOffset;39;0;Create;True;0;0;0;False;0;False;1,1,0,0;1,1,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;119;-2519.243,-1446.068;Inherit;False;Property;_BlendScr;BlendScr;2;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.BlendMode;True;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;163;-1097.468,-1512.37;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT2;0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;208;-62.97647,670.6729;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;39;-119.5761,-1039.796;Inherit;False;Property;_Main_Color;Main_Color;7;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;5.992157,5.992157,5.992157,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;122;-2305.663,-1430.805;Inherit;False;Property;_BlendDst;BlendDst;3;1;[Enum];Create;True;0;1;Option1;0;1;UnityEngine.Rendering.BlendMode;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;151;1809.911,-1007.376;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;193;-611.9168,-1271.552;Inherit;False;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;1;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;29;-1222.396,52.8699;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;218;818.4922,848.637;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;199;462.452,-1640.613;Inherit;False;Property;_Color_curv;Color_curv;42;0;Create;True;0;0;0;False;0;False;1;-0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;31;-360.9924,-259.5306;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1364.12,103.9519;Inherit;False;Property;_Edge;Edge;18;0;Create;True;0;0;0;False;0;False;0.15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;164;2407.536,-461.885;Inherit;False;Property;_Mask_Clip_Value;Mask_Clip_Value;19;0;Create;True;0;0;0;False;0;False;0.5;0.4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;222;1274.869,710.6191;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;214;643.8963,834.839;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;180;-499.5672,-1788.575;Inherit;False;Property;_ColorUspeed;ColorUspeed;40;0;Create;True;0;0;0;False;0;False;0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;169;-310.7798,-1995.762;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;153;2168.757,-818.4217;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;33;146.0972,-683.2246;Inherit;False;Property;_Edge_Color;Edge_Color;17;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;3.53124,3.462972,3.411311,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;210;634.0233,606.6716;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;220;975.8427,710.1788;Inherit;False;Property;_WP_twoside_black;WP_twoside_black;21;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;170;118.1882,-1884.924;Inherit;False;3;0;FLOAT2;1,1;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;159;2119.078,-546.2148;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ScenePickingPass;0;7;ScenePickingPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Picking;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-161.2,-74.10001;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;True;False;False;False;False;0;False;-1;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;161;2119.078,-546.2148;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormalsOnly;0;9;DepthNormalsOnly;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;15;d3d9;d3d11_9x;d3d11;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;157;2119.078,-546.2148;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Universal2D;0;5;Universal2D;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;True;119;10;True;122;0;1;False;119;10;False;120;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;True;121;True;3;True;120;True;True;0;False;-1;0;False;-1;True;1;LightMode=Universal2D;False;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;2735.599,-622.1985;Float;False;True;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;DSFX/FX_SHADER_Disslove_Color_Plus;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;True;118;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;True;1;5;True;119;10;True;122;0;1;False;119;10;False;120;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;True;2;True;121;True;3;True;120;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;0;  Blend;0;0;Two Sided;1;0;Cast Shadows;0;0;  Use Shadow Threshold;0;0;Receive Shadows;0;0;GPU Instancing;0;0;LOD CrossFade;0;0;Built-in Fog;0;0;DOTS Instancing;0;0;Meta Pass;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,-1;0;  Type;0;0;  Tess;16,False,-1;0;  Min;10,False,-1;0;  Max;25,False,-1;0;  Edge Length;16,False,-1;0;  Max Displacement;25,False,-1;0;Vertex Position,InvertActionOnDeselection;1;0;0;10;False;True;False;True;False;True;True;True;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;158;2119.078,-546.2148;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=SceneSelectionPass;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;160;2119.078,-546.2148;Float;False;False;-1;2;UnityEditor.ShaderGraphUnlitGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthNormals;0;8;DepthNormals;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;0;False;-1;False;False;False;False;False;False;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;True;17;d3d9;d3d11;glcore;gles;gles3;metal;vulkan;xbox360;xboxone;xboxseries;ps4;playstation;psp2;n3ds;wiiu;switch;nomrt;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=DepthNormalsOnly;False;True;4;d3d11;glcore;gles;gles3;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;79;0;78;1
WireConnection;79;1;78;2
WireConnection;80;0;79;0
WireConnection;84;0;80;0
WireConnection;85;0;84;1
WireConnection;85;1;84;0
WireConnection;86;0;85;0
WireConnection;81;0;80;0
WireConnection;88;0;81;0
WireConnection;88;1;86;0
WireConnection;135;0;88;0
WireConnection;102;0;139;0
WireConnection;102;1;50;0
WireConnection;102;2;95;0
WireConnection;98;0;97;1
WireConnection;98;1;97;2
WireConnection;99;0;97;3
WireConnection;99;1;97;4
WireConnection;53;0;51;0
WireConnection;53;1;52;0
WireConnection;100;0;102;0
WireConnection;100;1;98;0
WireConnection;100;2;99;0
WireConnection;92;0;90;3
WireConnection;92;1;90;4
WireConnection;94;0;138;0
WireConnection;94;1;93;0
WireConnection;94;2;95;0
WireConnection;91;0;90;1
WireConnection;91;1;90;2
WireConnection;49;0;100;0
WireConnection;49;2;53;0
WireConnection;89;0;94;0
WireConnection;89;1;91;0
WireConnection;89;2;92;0
WireConnection;59;0;58;0
WireConnection;59;1;56;0
WireConnection;48;1;49;0
WireConnection;54;0;48;0
WireConnection;54;1;116;3
WireConnection;54;2;55;0
WireConnection;60;0;89;0
WireConnection;60;2;59;0
WireConnection;205;0;206;0
WireConnection;61;0;60;0
WireConnection;61;1;54;0
WireConnection;5;1;61;0
WireConnection;204;0;202;1
WireConnection;204;1;205;0
WireConnection;203;0;5;1
WireConnection;203;1;204;0
WireConnection;108;0;136;0
WireConnection;108;1;62;0
WireConnection;108;2;95;0
WireConnection;213;0;211;0
WireConnection;200;0;5;1
WireConnection;200;1;203;0
WireConnection;111;0;109;1
WireConnection;111;1;109;2
WireConnection;110;0;116;1
WireConnection;110;1;116;2
WireConnection;132;0;54;0
WireConnection;6;0;200;0
WireConnection;6;1;7;0
WireConnection;112;0;108;0
WireConnection;112;1;111;0
WireConnection;112;2;110;0
WireConnection;233;0;145;1
WireConnection;233;1;145;2
WireConnection;216;2;213;0
WireConnection;9;0;116;4
WireConnection;9;1;10;0
WireConnection;117;0;112;0
WireConnection;117;1;133;0
WireConnection;11;0;6;0
WireConnection;11;1;9;0
WireConnection;232;0;216;0
WireConnection;232;1;233;0
WireConnection;15;0;14;0
WireConnection;217;0;215;0
WireConnection;217;1;232;0
WireConnection;35;1;117;0
WireConnection;12;0;11;0
WireConnection;13;0;12;0
WireConnection;13;1;15;0
WireConnection;13;2;14;0
WireConnection;196;0;35;4
WireConnection;196;1;192;0
WireConnection;219;1;217;0
WireConnection;195;0;35;1
WireConnection;195;1;192;0
WireConnection;27;0;116;4
WireConnection;27;1;200;0
WireConnection;191;0;115;1
WireConnection;191;1;190;0
WireConnection;66;1;13;0
WireConnection;66;0;27;0
WireConnection;162;0;195;0
WireConnection;162;1;196;0
WireConnection;149;0;150;0
WireConnection;224;0;219;0
WireConnection;224;1;145;3
WireConnection;107;0;66;0
WireConnection;107;1;162;0
WireConnection;107;2;191;0
WireConnection;107;3;41;4
WireConnection;152;0;149;0
WireConnection;226;0;223;0
WireConnection;226;1;224;0
WireConnection;227;0;226;0
WireConnection;227;1;225;0
WireConnection;156;0;152;0
WireConnection;156;1;107;0
WireConnection;212;0;210;0
WireConnection;212;1;209;0
WireConnection;185;0;169;0
WireConnection;185;1;168;0
WireConnection;165;1;170;0
WireConnection;76;1;38;0
WireConnection;76;0;72;0
WireConnection;28;0;29;0
WireConnection;28;1;200;0
WireConnection;168;0;189;3
WireConnection;168;1;189;4
WireConnection;209;0;208;0
WireConnection;235;0;227;0
WireConnection;235;1;221;0
WireConnection;198;0;165;0
WireConnection;198;1;199;0
WireConnection;72;0;38;0
WireConnection;72;1;33;0
WireConnection;72;2;30;0
WireConnection;179;0;180;0
WireConnection;179;1;181;0
WireConnection;30;0;27;0
WireConnection;30;1;28;0
WireConnection;69;0;193;0
WireConnection;69;1;162;0
WireConnection;69;2;68;0
WireConnection;34;1;13;0
WireConnection;34;0;31;0
WireConnection;155;0;107;0
WireConnection;155;1;156;0
WireConnection;155;2;154;0
WireConnection;38;0;69;0
WireConnection;38;1;39;0
WireConnection;38;2;41;0
WireConnection;38;3;34;0
WireConnection;38;4;198;0
WireConnection;163;0;133;0
WireConnection;163;1;112;0
WireConnection;151;0;152;0
WireConnection;151;1;76;0
WireConnection;193;0;35;0
WireConnection;193;1;192;0
WireConnection;29;0;116;4
WireConnection;29;1;19;0
WireConnection;218;0;214;0
WireConnection;31;0;27;0
WireConnection;31;1;30;0
WireConnection;222;0;220;0
WireConnection;222;1;219;0
WireConnection;214;0;212;0
WireConnection;169;0;189;1
WireConnection;169;1;189;2
WireConnection;153;0;76;0
WireConnection;153;1;151;0
WireConnection;153;2;154;0
WireConnection;210;0;209;0
WireConnection;220;1;210;0
WireConnection;220;0;218;0
WireConnection;170;0;185;0
WireConnection;170;2;179;0
WireConnection;1;2;153;0
WireConnection;1;3;155;0
WireConnection;1;4;164;0
WireConnection;1;5;235;0
WireConnection;1;6;235;0
ASEEND*/
//CHKSM=58DDF763E84525CFA50874A7CDC432539F3B4443