// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "DSFX/Vulcanus_Step_Distort_Transparent_Master"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin][HDR]_Color("Color", Color) = (1,1,1,1)
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 0
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 0
		[Enum(UnityEngine.Rendering.CullMode)]_Cull_Mode("Cull_Mode", Float) = 2
		_Multiply("Multiply", Float) = 1
		_Tex_Main("Tex_Main", 2D) = "white" {}
		[Toggle]_RGBRGBA("RGB>RGBA", Float) = 0
		_Main_Speed_X("Main_Speed_X", Float) = 0
		_Main_Speed_Y("Main_Speed_Y", Float) = 0
		_Mask_Speed_X("Mask_Speed_X", Float) = 0
		_Mask_Speed_Y("Mask_Speed_Y", Float) = 0
		[Header(____________)][Header(Step)]_Step_Power("Step_Power", Range( 0 , 1)) = 1
		[Toggle]_Custom_Step_Use("Custom_Step_Use", Float) = 1
		[Header(__________)][Header(Distortion)]Distortion_Speed_X("Distortion_Speed_X", Float) = 0
		Distortion_Speed_Y("Distortion_Speed_Y", Float) = 0
		_Distortion_Power_X("Distortion_Power_X", Float) = 0
		_Distortion_Power_Y("Distortion_Power_Y", Float) = 0
		[Toggle]Custom_Distortion_Panner("Custom_Distortion_Panner", Float) = 1
		[Toggle]Custom_Distortion_Power("Custom_Distortion_Power", Float) = 1
		[Toggle]Custom_Disslove_Speed("Custom_Disslove_Speed", Float) = 1
		[HDR][Header(___________)][Header(Edge)]_Edge_Color("Edge_Color", Color) = (1,1,1,1)
		[Toggle(_EDGE_ON_ON)] _Edge_on("Edge_on", Float) = 0
		_Edge_Size("Edge_Size", Float) = 0.15
		_Soft("Soft", Range( 0.5 , 1)) = 1
		[Header(_____________)][Header(UV_Add)]_UV_Add_TilingOffset("UV_Add_Tiling/Offset", Vector) = (0,0,0,0)
		[Toggle]_UV_Add_Use("UV_Add_Use", Float) = 0
		[Toggle]_ZWrite_Mode("ZWrite_Mode", Float) = 0
		[Enum()]_ZOffsetFactor("ZOffsetFactor", Float) = 0
		[Enum()]_ZOffsetUnits("ZOffsetUnits", Float) = 0
		_AlphaClip("AlphaClip", Float) = 0.3
		_Edge_con("Edge_con", Range( -1 , 1)) = 0
		_Depth1("Depth", Float) = 0
		[ASEEnd][Enum(OFF,0,ON,1)]DepthAlpha("DepthAlpha", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

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
		
		Cull [_Cull_Mode]
		AlphaToMask Off
		HLSLINCLUDE
		#pragma target 3.0

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
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend [_BlendScr] [_BlendDst], One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset [_ZOffsetFactor] , [_ZOffsetUnits]
			ColorMask RGBA
			

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_FRAG_COLOR
			#pragma shader_feature_local _EDGE_ON_ON


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;
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
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Edge_Color;
			float4 _Tex_Main_ST;
			float4 _Color;
			float4 _UV_Add_TilingOffset;
			float _BlendDst;
			float DepthAlpha;
			float _Depth1;
			float _Edge_con;
			float _Edge_Size;
			float _Soft;
			float _RGBRGBA;
			float _Mask_Speed_Y;
			float _Mask_Speed_X;
			float Custom_Distortion_Panner;
			float _Step_Power;
			float _Custom_Step_Use;
			float _UV_Add_Use;
			float Distortion_Speed_Y;
			float Distortion_Speed_X;
			float Custom_Disslove_Speed;
			float Custom_Distortion_Power;
			float _Distortion_Power_Y;
			float _Distortion_Power_X;
			float _Main_Speed_Y;
			float _Main_Speed_X;
			float _BlendScr;
			float _ZWrite_Mode;
			float _Cull_Mode;
			float _ZOffsetFactor;
			float _ZOffsetUnits;
			float _Multiply;
			float _AlphaClip;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Tex_Main;
			uniform float4 _CameraDepthTexture_TexelSize;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord6 = screenPos;
				
				o.ase_texcoord3.xy = v.ase_texcoord.xy;
				o.ase_texcoord4 = v.ase_texcoord2;
				o.ase_color = v.ase_color;
				o.ase_texcoord5 = v.ase_texcoord1;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.zw = 0;
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
				float4 ase_color : COLOR;
				float4 ase_texcoord1 : TEXCOORD1;

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
				o.ase_color = v.ase_color;
				o.ase_texcoord1 = v.ase_texcoord1;
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
				o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
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
				float2 uv_Tex_Main = IN.ase_texcoord3.xy * _Tex_Main_ST.xy + _Tex_Main_ST.zw;
				float2 appendResult257 = (float2(_Main_Speed_X , _Main_Speed_Y));
				float2 panner258 = ( 1.0 * _Time.y * appendResult257 + float2( 0,0 ));
				float2 appendResult282 = (float2(_Distortion_Power_X , _Distortion_Power_Y));
				float2 temp_cast_0 = (0.0).xx;
				float4 texCoord347 = IN.ase_texcoord4;
				texCoord347.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult311 = (float2(texCoord347.x , texCoord347.y));
				float2 temp_cast_1 = (0.0).xx;
				float4 texCoord435 = IN.ase_texcoord4;
				texCoord435.xy = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult438 = (float2(texCoord435.z , texCoord435.w));
				float2 appendResult229 = (float2(Distortion_Speed_X , Distortion_Speed_Y));
				float2 panner222 = ( 1.0 * _Time.y * appendResult229 + float2( 0,1 ));
				float2 Disslove447 = ( uv_Tex_Main + ( (( Custom_Disslove_Speed )?( appendResult438 ):( temp_cast_1 )) + panner222 ) );
				float2 appendResult293 = (float2(_UV_Add_TilingOffset.x , _UV_Add_TilingOffset.y));
				float2 appendResult308 = (float2(_UV_Add_TilingOffset.z , _UV_Add_TilingOffset.w));
				float2 texCoord288 = IN.ase_texcoord3.xy * appendResult293 + appendResult308;
				float UV_Add_Use442 = (( _UV_Add_Use )?( ( texCoord288.x + texCoord288.y ) ):( 1.0 ));
				float2 temp_output_281_0 = ( ( appendResult282 + (( Custom_Distortion_Power )?( appendResult311 ):( temp_cast_0 )) ) * tex2D( _Tex_Main, Disslove447 ).b * UV_Add_Use442 );
				float2 Distortion423 = ( ( uv_Tex_Main + panner258 ) + temp_output_281_0 );
				float4 tex2DNode199 = tex2D( _Tex_Main, Distortion423 );
				float4 texCoord348 = IN.ase_texcoord5;
				texCoord348.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float2 temp_cast_3 = (0.0).xx;
				float2 texCoord249 = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float4 texCoord488 = IN.ase_texcoord5;
				texCoord488.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult489 = (float2(texCoord488.z , texCoord488.w));
				float2 appendResult262 = (float2(_Mask_Speed_X , _Mask_Speed_Y));
				float2 panner263 = ( 1.0 * _Time.y * appendResult262 + float2( 0,0 ));
				float Step469 = step( (( _Custom_Step_Use )?( texCoord348.x ):( _Step_Power )) , tex2D( _Tex_Main, ( temp_output_281_0 + ( texCoord249 + ( (( Custom_Distortion_Panner )?( appendResult489 ):( float2( 0,0 ) )) + panner263 ) ) ) ).g );
				float RGB454 = (( _RGBRGBA )?( tex2DNode199.a ):( tex2DNode199.r ));
				float Disslove_Tex441 = tex2D( _Tex_Main, uv_Tex_Main ).g;
				float4 texCoord354 = IN.ase_texcoord5;
				texCoord354.xy = IN.ase_texcoord5.xy * float2( 1,1 ) + float2( 0,0 );
				float smoothstepResult363 = smoothstep( ( 1.0 - _Soft ) , _Soft , saturate( ( ( Disslove_Tex441 + 1.0 ) - ( texCoord354.x * 2.0 ) ) ));
				float temp_output_369_0 = step( texCoord354.x , Disslove_Tex441 );
				float temp_output_367_0 = ( temp_output_369_0 + ( temp_output_369_0 - step( ( texCoord354.x + _Edge_Size ) , Disslove_Tex441 ) ) );
				#ifdef _EDGE_ON_ON
				float staticSwitch361 = temp_output_367_0;
				#else
				float staticSwitch361 = smoothstepResult363;
				#endif
				float EdgeOn356 = staticSwitch361;
				float4 MainTex425 = ( float4( ( tex2DNode199.r * (IN.ase_color).rgb ) , 0.0 ) * Step469 * _Color * RGB454 * EdgeOn356 );
				float4 lerpResult426 = lerp( MainTex425 , _Edge_Color , _Edge_con);
				#ifdef _EDGE_ON_ON
				float4 staticSwitch430 = lerpResult426;
				#else
				float4 staticSwitch430 = MainTex425;
				#endif
				float4 screenPos = IN.ase_texcoord6;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth494 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth494 = abs( ( screenDepth494 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth1 ) );
				float DepthFade496 = saturate( distanceDepth494 );
				float4 lerpResult499 = lerp( staticSwitch430 , ( DepthFade496 * staticSwitch430 ) , DepthAlpha);
				
				float Multifly460 = _Multiply;
				float temp_output_306_0 = saturate( ( _Color.a * Step469 * RGB454 * IN.ase_color.a * Multifly460 ) );
				float lerpResult501 = lerp( temp_output_306_0 , ( DepthFade496 * temp_output_306_0 ) , DepthAlpha);
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = lerpResult499.rgb;
				float Alpha = lerpResult501;
				float AlphaClipThreshold = _AlphaClip;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
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
			
			Name "ShadowCaster"
			Tags { "LightMode"="ShadowCaster" }

			ZWrite On
			ZTest LEqual
			AlphaToMask Off

			HLSLPROGRAM
			#pragma multi_compile_instancing
			#define _ALPHATEST_ON 1
			#define ASE_SRP_VERSION 999999
			#define REQUIRE_DEPTH_TEXTURE 1

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
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
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_color : COLOR;
				float4 ase_texcoord5 : TEXCOORD5;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _Edge_Color;
			float4 _Tex_Main_ST;
			float4 _Color;
			float4 _UV_Add_TilingOffset;
			float _BlendDst;
			float DepthAlpha;
			float _Depth1;
			float _Edge_con;
			float _Edge_Size;
			float _Soft;
			float _RGBRGBA;
			float _Mask_Speed_Y;
			float _Mask_Speed_X;
			float Custom_Distortion_Panner;
			float _Step_Power;
			float _Custom_Step_Use;
			float _UV_Add_Use;
			float Distortion_Speed_Y;
			float Distortion_Speed_X;
			float Custom_Disslove_Speed;
			float Custom_Distortion_Power;
			float _Distortion_Power_Y;
			float _Distortion_Power_X;
			float _Main_Speed_Y;
			float _Main_Speed_X;
			float _BlendScr;
			float _ZWrite_Mode;
			float _Cull_Mode;
			float _ZOffsetFactor;
			float _ZOffsetUnits;
			float _Multiply;
			float _AlphaClip;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _Tex_Main;
			uniform float4 _CameraDepthTexture_TexelSize;


			
			float3 _LightDirection;

			VertexOutput VertexFunction( VertexInput v )
			{
				VertexOutput o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );

				float4 ase_clipPos = TransformObjectToHClip((v.vertex).xyz);
				float4 screenPos = ComputeScreenPos(ase_clipPos);
				o.ase_texcoord5 = screenPos;
				
				o.ase_texcoord2 = v.ase_texcoord1;
				o.ase_texcoord3 = v.ase_texcoord2;
				o.ase_texcoord4.xy = v.ase_texcoord.xy;
				o.ase_color = v.ase_color;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord4.zw = 0;
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

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				float3 normalWS = TransformObjectToWorldDir( v.ase_normal );

				float4 clipPos = TransformWorldToHClip( ApplyShadowBias( positionWS, normalWS, _LightDirection ) );

				#if UNITY_REVERSED_Z
					clipPos.z = min(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#else
					clipPos.z = max(clipPos.z, clipPos.w * UNITY_NEAR_CLIP_VALUE);
				#endif

				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				o.clipPos = clipPos;

				return o;
			}
			
			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord : TEXCOORD0;
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
				o.ase_texcoord1 = v.ase_texcoord1;
				o.ase_texcoord2 = v.ase_texcoord2;
				o.ase_texcoord = v.ase_texcoord;
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
				o.ase_texcoord1 = patch[0].ase_texcoord1 * bary.x + patch[1].ase_texcoord1 * bary.y + patch[2].ase_texcoord1 * bary.z;
				o.ase_texcoord2 = patch[0].ase_texcoord2 * bary.x + patch[1].ase_texcoord2 * bary.y + patch[2].ase_texcoord2 * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
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

				float4 texCoord348 = IN.ase_texcoord2;
				texCoord348.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult282 = (float2(_Distortion_Power_X , _Distortion_Power_Y));
				float2 temp_cast_0 = (0.0).xx;
				float4 texCoord347 = IN.ase_texcoord3;
				texCoord347.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult311 = (float2(texCoord347.x , texCoord347.y));
				float2 uv_Tex_Main = IN.ase_texcoord4.xy * _Tex_Main_ST.xy + _Tex_Main_ST.zw;
				float2 temp_cast_1 = (0.0).xx;
				float4 texCoord435 = IN.ase_texcoord3;
				texCoord435.xy = IN.ase_texcoord3.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult438 = (float2(texCoord435.z , texCoord435.w));
				float2 appendResult229 = (float2(Distortion_Speed_X , Distortion_Speed_Y));
				float2 panner222 = ( 1.0 * _Time.y * appendResult229 + float2( 0,1 ));
				float2 Disslove447 = ( uv_Tex_Main + ( (( Custom_Disslove_Speed )?( appendResult438 ):( temp_cast_1 )) + panner222 ) );
				float2 appendResult293 = (float2(_UV_Add_TilingOffset.x , _UV_Add_TilingOffset.y));
				float2 appendResult308 = (float2(_UV_Add_TilingOffset.z , _UV_Add_TilingOffset.w));
				float2 texCoord288 = IN.ase_texcoord4.xy * appendResult293 + appendResult308;
				float UV_Add_Use442 = (( _UV_Add_Use )?( ( texCoord288.x + texCoord288.y ) ):( 1.0 ));
				float2 temp_output_281_0 = ( ( appendResult282 + (( Custom_Distortion_Power )?( appendResult311 ):( temp_cast_0 )) ) * tex2D( _Tex_Main, Disslove447 ).b * UV_Add_Use442 );
				float2 texCoord249 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
				float4 texCoord488 = IN.ase_texcoord2;
				texCoord488.xy = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
				float2 appendResult489 = (float2(texCoord488.z , texCoord488.w));
				float2 appendResult262 = (float2(_Mask_Speed_X , _Mask_Speed_Y));
				float2 panner263 = ( 1.0 * _Time.y * appendResult262 + float2( 0,0 ));
				float Step469 = step( (( _Custom_Step_Use )?( texCoord348.x ):( _Step_Power )) , tex2D( _Tex_Main, ( temp_output_281_0 + ( texCoord249 + ( (( Custom_Distortion_Panner )?( appendResult489 ):( float2( 0,0 ) )) + panner263 ) ) ) ).g );
				float2 appendResult257 = (float2(_Main_Speed_X , _Main_Speed_Y));
				float2 panner258 = ( 1.0 * _Time.y * appendResult257 + float2( 0,0 ));
				float2 temp_cast_2 = (0.0).xx;
				float2 Distortion423 = ( ( uv_Tex_Main + panner258 ) + temp_output_281_0 );
				float4 tex2DNode199 = tex2D( _Tex_Main, Distortion423 );
				float RGB454 = (( _RGBRGBA )?( tex2DNode199.a ):( tex2DNode199.r ));
				float Multifly460 = _Multiply;
				float temp_output_306_0 = saturate( ( _Color.a * Step469 * RGB454 * IN.ase_color.a * Multifly460 ) );
				float4 screenPos = IN.ase_texcoord5;
				float4 ase_screenPosNorm = screenPos / screenPos.w;
				ase_screenPosNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_screenPosNorm.z : ase_screenPosNorm.z * 0.5 + 0.5;
				float screenDepth494 = LinearEyeDepth(SHADERGRAPH_SAMPLE_SCENE_DEPTH( ase_screenPosNorm.xy ),_ZBufferParams);
				float distanceDepth494 = abs( ( screenDepth494 - LinearEyeDepth( ase_screenPosNorm.z,_ZBufferParams ) ) / ( _Depth1 ) );
				float DepthFade496 = saturate( distanceDepth494 );
				float lerpResult501 = lerp( temp_output_306_0 , ( DepthFade496 * temp_output_306_0 ) , DepthAlpha);
				
				float Alpha = lerpResult501;
				float AlphaClipThreshold = _AlphaClip;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					#ifdef _ALPHATEST_SHADOW_ON
						clip(Alpha - AlphaClipThresholdShadow);
					#else
						clip(Alpha - AlphaClipThreshold);
					#endif
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}

			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18800
2553.333;-0.6666667;2560;1373;-145.496;1287.165;1.586157;True;False
Node;AmplifyShaderEditor.CommentaryNode;450;-3788.41,-403.214;Inherit;False;1575.25;788.7753;Disslove;14;440;438;439;437;228;230;229;222;223;254;447;446;441;485;Disslove;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;485;-3787.244,-292.1582;Inherit;False;295.3333;252;3CH;1;435;3CH;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;230;-3642.126,171.9842;Float;False;Property;Distortion_Speed_Y;Distortion_Speed_Y;14;0;Create;False;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;435;-3758.244,-247.1582;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;228;-3651.041,55.00982;Float;False;Property;Distortion_Speed_X;Distortion_Speed_X;13;1;[Header];Create;False;2;__________;Distortion;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;444;-3750.265,650.1791;Inherit;False;1686;413;Comment;8;309;293;308;288;294;302;297;442;Uv_Add_Use;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;439;-3424.494,-121.8086;Inherit;False;Constant;_Float6;Float 6;31;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;229;-3418.22,74.90868;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;309;-3700.265,780.1792;Float;False;Property;_UV_Add_TilingOffset;UV_Add_Tiling/Offset;24;1;[Header];Create;True;2;_____________;UV_Add;0;0;False;0;False;0,0,0,0;0.24,0.27,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;438;-3419.494,-291.8087;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;222;-3215.446,102.7374;Inherit;False;3;0;FLOAT2;0,1;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;437;-3244.747,-227.1562;Float;False;Property;Custom_Disslove_Speed;Custom_Disslove_Speed;19;0;Create;False;0;0;0;False;0;False;1;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;293;-3364.265,764.1792;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;308;-3364.265,876.1791;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;223;-2876.552,-189.2562;Inherit;False;0;199;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;288;-3172.265,764.1792;Inherit;True;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;453;-2024.396,-400.6176;Inherit;False;1009.571;445.9591;Mask_Speed;8;262;263;264;249;491;490;489;488;Mask_Speed;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;440;-2879.749,-15.86077;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;483;-2338.073,-1651.562;Inherit;False;295.3333;252;Comment;1;347;3ch;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;260;-2072.267,98.62179;Float;False;Property;_Mask_Speed_Y;Mask_Speed_Y;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;294;-2788.264,700.1792;Float;False;Constant;_Float2;Float 2;18;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;488;-1945.582,-356.4402;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;347;-2288.073,-1601.562;Inherit;False;2;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;302;-2772.264,812.1791;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;254;-2630.261,-62.95845;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;261;-2072.825,-14.1459;Float;False;Property;_Mask_Speed_X;Mask_Speed_X;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-1427.648,-1665.416;Float;False;Property;_Main_Speed_Y;Main_Speed_Y;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;489;-1711.435,-305.8391;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;276;-1941.461,-1183.87;Float;False;Property;_Distortion_Power_Y;Distortion_Power_Y;16;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;312;-1965.45,-1437.068;Float;False;Constant;_Float0;Float 0;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;262;-1776.562,22.23432;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;239;-1947.306,-1288.007;Float;False;Property;_Distortion_Power_X;Distortion_Power_X;15;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;311;-1977.987,-1577.49;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;297;-2516.264,716.1792;Float;False;Property;_UV_Add_Use;UV_Add_Use;25;0;Create;True;0;0;0;False;0;False;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;256;-1430.313,-1756.966;Float;False;Property;_Main_Speed_X;Main_Speed_X;7;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;447;-2465.161,-54.92867;Inherit;False;Disslove;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;257;-1221.044,-1696.002;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;442;-2292.265,716.1792;Inherit;False;UV_Add_Use;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;313;-1721.986,-1465.634;Float;False;Property;Custom_Distortion_Power;Custom_Distortion_Power;18;0;Create;False;0;0;0;False;0;False;1;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;449;-1876.844,-876.4622;Inherit;False;447;Disslove;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;282;-1641.856,-1217.64;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;490;-1532.614,-296.8804;Float;False;Property;Custom_Distortion_Panner;Custom_Distortion_Panner;17;0;Create;False;0;0;0;False;0;False;1;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;263;-1548.724,8.69728;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;445;-1651.973,-893.0455;Inherit;True;Property;_TextureSample2;Texture Sample 2;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;199;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;491;-1214.404,-131.4898;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PannerNode;258;-1042.673,-1694.786;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;249;-1223.947,-309.3724;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;314;-1455.409,-1206.812;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;443;-1451.473,-669.7908;Inherit;False;442;UV_Add_Use;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;165;-1056.112,-1543.72;Inherit;False;0;199;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;264;-1026.592,-252.3435;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;259;-706.9789,-1594.648;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;281;-1202.603,-849.5767;Inherit;True;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;251;-789.5109,-341.4395;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;250;-459.9773,-1475.23;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WireNode;463;-609.5548,168.5592;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;486;-130.9653,-155.4811;Inherit;False;295.3333;252;2CH;1;348;2CH;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;423;-270.589,-1593.533;Inherit;False;Distortion;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;348;-80.96533,-105.4811;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;283;-119.8072,-361.1081;Float;False;Property;_Step_Power;Step_Power;11;1;[Header];Create;True;2;____________;Step;0;0;False;0;False;1;0.105;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;452;-131.7127,-1002.546;Inherit;False;423;Distortion;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;344;-113.356,196.8669;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;199;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;199;114.9425,-1024.817;Inherit;True;Property;_Tex_Main;Tex_Main;5;0;Create;True;0;0;0;False;0;False;-1;None;363c564eda84764418d7c86a8a3922d6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;317;264.9338,-145.5831;Float;False;Property;_Custom_Step_Use;Custom_Step_Use;12;0;Create;True;0;0;0;False;0;False;1;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;464;492.8962,195.9377;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;493;1645.723,523.8065;Inherit;False;Property;_Depth1;Depth;31;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;117;545.9963,-226.8186;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;307;444.8212,-874.0533;Float;False;Property;_RGBRGBA;RGB>RGBA;6;0;Create;True;0;0;0;False;0;False;0;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;305;1387.951,-1306.172;Float;False;Property;_Multiply;Multiply;4;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;454;651.746,-872.1612;Inherit;False;RGB;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;469;768.2974,-228.3764;Inherit;False;Step;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;460;1550.133,-1296.434;Inherit;False;Multifly;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade;494;1831.928,516.2057;Inherit;False;True;False;True;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;458;953.0306,175.6508;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;495;2122.765,525.4818;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;471;951.2646,-26.52523;Inherit;False;469;Step;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;462;954.1917,380.8907;Inherit;False;460;Multifly;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;129;900.9794,-526.9261;Float;False;Property;_Color;Color;0;1;[HDR];Create;True;0;0;0;False;0;False;1,1,1,1;11.18176,2.634446,2.634446,1;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;456;946.1758,68.85678;Inherit;False;454;RGB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;270;1228.525,-52.44106;Inherit;True;5;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;496;2310.146,522.8441;Inherit;False;DepthFade;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;505;2523.675,-7.473824;Inherit;False;496;DepthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;306;1671.728,-63.46221;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;349;-3793.807,1455.745;Inherit;False;2143.323;1147.119;Edge;22;360;362;358;367;356;375;365;366;352;363;371;370;369;373;368;364;374;372;357;361;359;487;Edge;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;376;2845.654,950.8264;Inherit;False;595.5128;310.733;Custom;6;342;341;327;328;338;339;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;487;-3771.079,1857.301;Inherit;False;295.3333;252;2CH;1;354;2CH;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;506;2930.77,-342.8705;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;500;2790.456,-718.6031;Inherit;False;Property;DepthAlpha;DepthAlpha;32;1;[Enum];Create;False;0;2;OFF;0;ON;1;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;427;2048.262,-1114.952;Inherit;False;Property;_Edge_Color;Edge_Color;20;2;[HDR];[Header];Create;True;2;___________;Edge;0;0;False;0;False;1,1,1,1;1.377235,0.1613298,0,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;365;-3261.305,1675.094;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;359;-3355.786,1992.179;Inherit;True;441;Disslove_Tex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;363;-2534.572,1683.859;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.WireNode;467;1086.475,-612.0666;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;358;-3729.492,1569.677;Inherit;True;441;Disslove_Tex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;370;-3019.903,1792.442;Inherit;False;Property;_Soft;Soft;23;0;Create;True;0;0;0;False;0;False;1;0.5;0.5;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;371;-3307.616,2222.052;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;360;-3648.48,2146.359;Inherit;False;Constant;_Float4;Float 4;1;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;374;-2731.586,1726.821;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;426;2406.587,-1129.578;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;341;3071.511,1000.826;Inherit;False;Property;_BlendDst;BlendDst;2;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;356;-1931.859,1678.252;Inherit;True;EdgeOn;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;428;2045.795,-897.7545;Inherit;True;352;EdgeAlpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;497;2810.27,-1443.724;Inherit;False;496;DepthFade;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;339;2902.654,1099.175;Inherit;False;Property;_ZOffsetUnits;ZOffsetUnits;28;1;[Enum];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;338;2895.654,1006.175;Inherit;False;Property;_ZOffsetFactor;ZOffsetFactor;27;1;[Enum];Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;328;3056.393,1124.763;Inherit;False;Property;_Cull_Mode;Cull_Mode;3;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.CullMode;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;498;3086.27,-1398.724;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StaticSwitch;430;2737.233,-1135.678;Inherit;True;Property;_Keyword0;Keyword 0;21;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Reference;361;True;True;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;499;3335.27,-1115.092;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;502;1479.807,-1973.548;Inherit;True;Property;_TextureSample4;Texture Sample 4;33;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;199;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;503;1833.123,-1862.759;Inherit;False;Main_Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;504;2541.568,-544.0065;Inherit;False;503;Main_Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;446;-2910.136,154.5613;Inherit;True;Property;_TextureSample3;Texture Sample 3;5;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;199;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;431;2452.233,-1261.678;Inherit;False;425;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;372;-3357.724,2358.165;Inherit;True;441;Disslove_Tex;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;362;-3697.127,1770.884;Inherit;False;Constant;_Float5;Float 5;1;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;375;-3035.624,2167.437;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;367;-2501.212,1905.651;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;434;2788.744,206.868;Inherit;False;Property;_AlphaClip;AlphaClip;29;0;Create;True;0;0;0;False;0;False;0.3;0.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;448;-2593.005,-866.7507;Inherit;False;447;Disslove;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;455;1266.484,-774.6017;Inherit;False;454;RGB;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;368;-2749.059,2113.077;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;357;-3547.338,2280.135;Inherit;False;Property;_Edge_Size;Edge_Size;22;0;Create;True;0;0;0;False;0;False;0.15;0.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;470;1266.825,-917.8213;Inherit;False;469;Step;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;343;-2358.637,-893.8076;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Instance;199;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;425;1768.821,-996.0276;Inherit;False;MainTex;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;465;942.9277,-664.5533;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;373;-3480.453,1572.094;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;361;-2194.274,1678.115;Inherit;True;Property;_Edge_on;Edge_on;21;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;441;-2586.967,200.3969;Inherit;False;Disslove_Tex;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;235;1524.548,-989.1722;Inherit;True;5;5;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;352;-2226.292,2106.456;Inherit;True;EdgeAlpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;424;1267.842,-603.3121;Inherit;False;356;EdgeOn;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;501;3265.45,-526.2899;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;342;3263.912,1003.426;Inherit;False;Property;_BlendScr;BlendScr;1;1;[Enum];Create;True;0;0;1;UnityEngine.Rendering.BlendMode;True;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;369;-3045.17,1904.385;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ComponentMaskNode;268;399.8039,-641.395;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;354;-3749.079,1900.301;Inherit;False;1;-1;4;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;13;1022.432,-1004.605;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode;8;130.3275,-641.983;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;364;-3417.541,1798.977;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;468;-1476.486,-2780.343;Inherit;False;-1;;1;0;OBJECT;;False;1;OBJECT;0
Node;AmplifyShaderEditor.RangedFloatNode;492;1998.364,-646.4825;Inherit;False;Property;_Edge_con;Edge_con;30;0;Create;True;0;0;0;False;0;False;0;0.13;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;366;-2959.641,1668.703;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;429;2040.648,-1367.675;Inherit;True;425;MainTex;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;466;1126.058,-786.775;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.WireNode;472;1408.849,-837.7618;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;327;3243.833,1146.559;Inherit;False;Property;_ZWrite_Mode;ZWrite_Mode;26;1;[Toggle];Create;True;0;0;1;;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;324;1842.651,-383.3046;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;340;1842.651,-383.3046;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;1;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;325;1842.651,-383.3046;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;323;3756.556,-409.7329;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;DSFX/Vulcanus_Step_Distort_Transparent_Master;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;True;328;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;2;0;True;2;5;True;342;10;True;341;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;327;True;3;False;-1;True;True;0;True;338;0;True;339;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;1;Cast Shadows;1;  Use Shadow Threshold;0;Receive Shadows;1;GPU Instancing;1;LOD CrossFade;0;Built-in Fog;0;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;True;False;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;326;1842.651,-383.3046;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;5;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;2;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;229;0;228;0
WireConnection;229;1;230;0
WireConnection;438;0;435;3
WireConnection;438;1;435;4
WireConnection;222;2;229;0
WireConnection;437;0;439;0
WireConnection;437;1;438;0
WireConnection;293;0;309;1
WireConnection;293;1;309;2
WireConnection;308;0;309;3
WireConnection;308;1;309;4
WireConnection;288;0;293;0
WireConnection;288;1;308;0
WireConnection;440;0;437;0
WireConnection;440;1;222;0
WireConnection;302;0;288;1
WireConnection;302;1;288;2
WireConnection;254;0;223;0
WireConnection;254;1;440;0
WireConnection;489;0;488;3
WireConnection;489;1;488;4
WireConnection;262;0;261;0
WireConnection;262;1;260;0
WireConnection;311;0;347;1
WireConnection;311;1;347;2
WireConnection;297;0;294;0
WireConnection;297;1;302;0
WireConnection;447;0;254;0
WireConnection;257;0;256;0
WireConnection;257;1;255;0
WireConnection;442;0;297;0
WireConnection;313;0;312;0
WireConnection;313;1;311;0
WireConnection;282;0;239;0
WireConnection;282;1;276;0
WireConnection;490;1;489;0
WireConnection;263;2;262;0
WireConnection;445;1;449;0
WireConnection;491;0;490;0
WireConnection;491;1;263;0
WireConnection;258;2;257;0
WireConnection;314;0;282;0
WireConnection;314;1;313;0
WireConnection;264;0;249;0
WireConnection;264;1;491;0
WireConnection;259;0;165;0
WireConnection;259;1;258;0
WireConnection;281;0;314;0
WireConnection;281;1;445;3
WireConnection;281;2;443;0
WireConnection;251;0;281;0
WireConnection;251;1;264;0
WireConnection;250;0;259;0
WireConnection;250;1;281;0
WireConnection;463;0;251;0
WireConnection;423;0;250;0
WireConnection;344;1;463;0
WireConnection;199;1;452;0
WireConnection;317;0;283;0
WireConnection;317;1;348;1
WireConnection;464;0;344;2
WireConnection;117;0;317;0
WireConnection;117;1;464;0
WireConnection;307;0;199;1
WireConnection;307;1;199;4
WireConnection;454;0;307;0
WireConnection;469;0;117;0
WireConnection;460;0;305;0
WireConnection;494;0;493;0
WireConnection;495;0;494;0
WireConnection;270;0;129;4
WireConnection;270;1;471;0
WireConnection;270;2;456;0
WireConnection;270;3;458;4
WireConnection;270;4;462;0
WireConnection;496;0;495;0
WireConnection;306;0;270;0
WireConnection;506;0;505;0
WireConnection;506;1;306;0
WireConnection;365;0;373;0
WireConnection;365;1;364;0
WireConnection;363;0;366;0
WireConnection;363;1;374;0
WireConnection;363;2;370;0
WireConnection;467;0;129;0
WireConnection;371;0;354;1
WireConnection;371;1;357;0
WireConnection;374;0;370;0
WireConnection;426;0;429;0
WireConnection;426;1;427;0
WireConnection;426;2;492;0
WireConnection;356;0;361;0
WireConnection;498;0;497;0
WireConnection;498;1;430;0
WireConnection;430;1;431;0
WireConnection;430;0;426;0
WireConnection;499;0;430;0
WireConnection;499;1;498;0
WireConnection;499;2;500;0
WireConnection;503;0;502;4
WireConnection;375;0;371;0
WireConnection;375;1;372;0
WireConnection;367;0;369;0
WireConnection;367;1;368;0
WireConnection;368;0;369;0
WireConnection;368;1;375;0
WireConnection;343;1;448;0
WireConnection;425;0;235;0
WireConnection;465;0;268;0
WireConnection;373;0;358;0
WireConnection;373;1;362;0
WireConnection;361;1;363;0
WireConnection;361;0;367;0
WireConnection;441;0;446;2
WireConnection;235;0;13;0
WireConnection;235;1;470;0
WireConnection;235;2;472;0
WireConnection;235;3;455;0
WireConnection;235;4;424;0
WireConnection;352;0;367;0
WireConnection;501;0;306;0
WireConnection;501;1;506;0
WireConnection;501;2;500;0
WireConnection;369;0;354;1
WireConnection;369;1;359;0
WireConnection;268;0;8;0
WireConnection;13;0;199;1
WireConnection;13;1;465;0
WireConnection;364;0;354;1
WireConnection;364;1;360;0
WireConnection;366;0;365;0
WireConnection;466;0;467;0
WireConnection;472;0;466;0
WireConnection;323;2;499;0
WireConnection;323;3;501;0
WireConnection;323;4;434;0
ASEEND*/
//CHKSM=FA68F6BFC153E71216BEF5B79A5893B55839D83E