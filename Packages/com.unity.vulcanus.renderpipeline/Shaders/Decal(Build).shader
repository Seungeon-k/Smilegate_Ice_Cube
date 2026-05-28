// see README here: 
// github.com/ColinLeung-NiloCat/UnityURPUnlitScreenSpaceDecalShader
// https://docs.unity3d.com/ScriptReference/Rendering.BlendMode.html
// https://docs.unity3d.com/ScriptReference/Rendering.CompareFunction.html
// https://docs.unity3d.com/ScriptReference/Rendering.CompareFunction.html
// https://docs.unity3d.com/ScriptReference/Rendering.CullMode.html

Shader "Vulcanus/BuildDecal"
{
    Properties
    {
        [Header(Basic)]
        _MainTex("Texture", 2D) = "white" {}
        [HDR]_Color("_Color (default = 1,1,1,1)", color) = (1,1,1,1)

        [Header(Blending)]
        
        [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("_BlendOp (default = SrcAlpha)", Float) = 0 // 0 = Add
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend (default = SrcAlpha)", Float) = 5 // 5 = SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend (default = OneMinusSrcAlpha)", Float) = 10 // 10 = OneMinusSrcAlpha

        //alpha will first mul x, then add y    (zw unused)
        [Header(Alpha remap(extra alpha control))]
        _AlphaRemap("_AlphaRemap (default = 1,0,0,0)", vector) = (1,0,0,0)

        [Header(Prevent Side Stretching(Compare projection direction with scene normal and Discard if needed))]
        [Toggle(_ProjectionAngleDiscardEnable)] _ProjectionAngleDiscardEnable("_ProjectionAngleDiscardEnable (default = off)", float) = 0
        _ProjectionAngleDiscardThreshold("_ProjectionAngleDiscardThreshold (default = 0)", range(-1,1)) = 0

        //====================================== below = usually can ignore in normal use case =====================================================================
        //Set to NotEqual if you want to mask by specific _StencilRef value, else set to Disable
        [Header(Stencil Masking)]
        _StencilRef("_StencilRef", Float) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("_StencilComp (default = Disable)", Float) = 0 //0 = disable

        //to improve GPU performance, Set to LessEqual if camera never goes into cube volume, else set to Disable
        [Header(ZTest)]
        // default need to be Disable, because we need to make sure decal render correctly even if camera goes into decal cube volume, although disable ZTest by default will prevent EarlyZ (bad for GPU performance)
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("_ZTest (default = Disable)", Float) = 0 //0 = disable

        //to improve GPU performance, Set to Back if camera never goes into cube volume, else set to Front
        [Header(Cull)]
        // default need to be Front, because we need to make sure decal render correctly even if camera goes into decal cube
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("_Cull (default = Front)", Float) = 1 //1 = Front

        [Header(Unity Fog)]
        [Toggle(_UnityFogEnable)] _UnityFogEnable("_UnityFogEnable (default = on)", Float) = 1
    }

    SubShader
    {
        Tags { "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }

        Pass
        {
            Stencil
            {
                Ref[_StencilRef]
                Comp[_StencilComp]
            }

            Cull[_Cull]
            ZTest[_ZTest]

            ZWrite off
            BlendOp[_BlendOp]
            Blend[_SrcBlend][_DstBlend]

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            //#pragma target 3.0

            #pragma shader_feature_local_fragment _ProjectionAngleDiscardEnable
            #pragma shader_feature_local _UnityFogEnable
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.vulcanus.render-pipelines.vulcanus/Shaders/HLSL_functions.hlsl" 

            struct appdata
            {
                float3 positionOS : POSITION;
            };

            struct v2f
            {
                float4 positionCS : SV_POSITION;
                float4 screenPos : TEXCOORD0;
                float4 viewRayOS : TEXCOORD1; // xyz: viewRayOS, w: extra copy of positionVS.z 
                float4 cameraPosOSAndFogFactor : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;

            CBUFFER_START(UnityPerMaterial)               
                float4 _MainTex_ST;
                float _ProjectionAngleDiscardThreshold;
                half4 _Color;
                half2 _AlphaRemap;
            CBUFFER_END

            v2f vert(appdata input)
            {
                v2f o;
                VertexPositionInputs vertexPositionInput = GetVertexPositionInputs(input.positionOS);
                o.positionCS = vertexPositionInput.positionCS;

#if _UnityFogEnable
                o.cameraPosOSAndFogFactor.a = ComputeFogFactor(o.positionCS.z);
#else
                o.cameraPosOSAndFogFactor.a = 0;
#endif

                o.screenPos = ComputeScreenPos(o.positionCS);

                float3 viewRay = vertexPositionInput.positionVS;
                o.viewRayOS.w = viewRay.z;//store the division value to varying o.viewRayOS.w
                viewRay *= -1;

                float4x4 ViewToObjectMatrix = mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V);

                o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
                o.cameraPosOSAndFogFactor.xyz = mul(ViewToObjectMatrix, float4(0,0,0,1)).xyz; // hard code 0 or 1 can enable many compiler optimization
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                i.viewRayOS.xyz /= i.viewRayOS.w;

                float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
                float sceneRawDepth = tex2D(_CameraDepthTexture, screenSpaceUV).r;

                float sceneDepthVS = LinearEyeDepth(sceneRawDepth, _ZBufferParams);
                float3 decalSpaceScenePos = i.cameraPosOSAndFogFactor.xyz + i.viewRayOS.xyz * sceneDepthVS;
                float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;

                float shouldClip = 0;
#if _ProjectionAngleDiscardEnable
                float3 decalSpaceHardNormal = normalize(cross(ddx(decalSpaceScenePos), ddy(decalSpaceScenePos)));//reconstruct scene hard normal using scene pos ddx&ddy
                shouldClip = decalSpaceHardNormal.z > _ProjectionAngleDiscardThreshold ? 0 : 1;
#endif
                clip(0.5 - abs(decalSpaceScenePos) - shouldClip);

                half decalScaleXY = length(float3(unity_ObjectToWorld._11, unity_ObjectToWorld._21, unity_ObjectToWorld._31));
                half decalScaleZ = length(float3(unity_ObjectToWorld._13, unity_ObjectToWorld._23, unity_ObjectToWorld._33));
                float3 decalForward = normalize(float3(unity_ObjectToWorld._13, unity_ObjectToWorld._23, unity_ObjectToWorld._33));
				float3 decalPosition = float3(unity_ObjectToWorld._14, unity_ObjectToWorld._24, unity_ObjectToWorld._34);
                float4 clipSpacePosition = 0;

#if defined(UNITY_REVERSED_Z)
                float depth = sceneRawDepth;
                clipSpacePosition = float4(screenSpaceUV * 2 - 1, depth, 1);
                clipSpacePosition.y = -clipSpacePosition.y;
#else
                float depth = sceneRawDepth * 2 - 1;
                clipSpacePosition = float4(screenSpaceUV * 2 - 1, depth, 1);
#endif
                
				float4 worldSpacePosition = mul(UNITY_MATRIX_I_VP, clipSpacePosition);
				worldSpacePosition /= max(worldSpacePosition.w, 0.000001);

                float depthFactor = abs(dot(decalForward, (worldSpacePosition.xyz - decalPosition.xyz)));
                depthFactor /= (decalScaleZ * 0.5);
                depthFactor = 1 - depthFactor;

                float distFactor = distance(decalPosition, worldSpacePosition.xyz) / (decalScaleXY * 0.5);
                distFactor = saturate(distFactor);
                distFactor *= distFactor;
                distFactor *= distFactor;
                distFactor *= distFactor;
                distFactor = 1 - distFactor;
                distFactor *= depthFactor;

                float2 uv = decalSpaceUV.xy * _MainTex_ST.xy + _MainTex_ST.zw;//Texture tiling & offset
                float noise;
                Unity_GradientNoise_float(uv + (_Time.y * 0.1), 100, noise);
                distFactor *= saturate(noise + 0.5);

                half4 col = tex2D(_MainTex, uv);
                col *= _Color;
                col.a *= distFactor;

#if _UnityFogEnable
                col.rgb = MixFog(col.rgb, i.cameraPosOSAndFogFactor.a);
#endif
                return col;
            }
            ENDHLSL
        }
    }
}
