Shader "ZAMMYSMITH/ShadowDecal(Shadow)_GF"
{
    Properties
    {
        [Header(Basic)]
        _Alpha("Alpha", Range(0, 1)) = 0.5
        _Softness("Softness", Range(0, 1)) = 0.5

        [Header(Blending)]
        [Enum(UnityEngine.Rendering.BlendOp)]_BlendOp("_BlendOp (default = SrcAlpha)", Float) = 0 // 0 = Add
        [Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend (default = SrcAlpha)", Float) = 5 // 5 = SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend (default = OneMinusSrcAlpha)", Float) = 10 // 10 = OneMinusSrcAlpha

        //to improve GPU performance, Set to LessEqual if camera never goes into cube volume, else set to Disable
        [Header(ZTest)]
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("_ZTest (default = Disable)", Float) = 0 //0 = disable
        [Header(Cull)]
        [Enum(UnityEngine.Rendering.CullMode)]_Cull("_Cull (default = Front)", Float) = 1 //1 = Front

        [Header(Stencil State)]
        _StencilRef("└─StencilRef", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("└─StencilComp (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.StencilOp)]_PassOperation("└─PassOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_FailOperation("└─FailOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_ZFailOperation("└─ZFailOperation (default = Keep)", Float) = 0 //0 = keep
    }

    SubShader
    {
        Tags { "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }

        Pass
        {
            Cull[_Cull]
            ZTest[_ZTest]

            ZWrite off
            BlendOp[_BlendOp]
            Blend[_SrcBlend][_DstBlend], Zero One

            Stencil
            {
                ReadMask 2
                //WriteMask 255
                Ref[_StencilRef]
                Comp[_StencilComp]
                Pass [_PassOperation]
                Fail [_FailOperation]
                ZFail [_ZFailOperation]
            }

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            //#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #pragma target 3.0

            struct appdata
            {
                float3 positionOS : POSITION;
            };

            struct v2f
            {
                float4 positionCS                : SV_POSITION;
                float4 screenPos                 : TEXCOORD0;
                float4 viewRayOS                 : TEXCOORD1; // xyz: viewRayOS, w: extra copy of positionVS.z 
                float4 cameraPosOSAndFogFactor   : TEXCOORD2;
                float3 objectWorldPosition       : POSITION1;
            };

            sampler2D _CameraDepthTexture;

            CBUFFER_START(UnityPerMaterial)               
                half _Alpha;
                half _Softness;
            CBUFFER_END

            v2f vert(appdata input)
            {
                v2f o;

                float4x4 worldMatrix = unity_ObjectToWorld;

                //Remove Rotation From WorldMatrix
                worldMatrix = float4x4(
                    length(worldMatrix._11_21_31), 0, 0, worldMatrix._14,
                    0, length(worldMatrix._12_22_32), 0, worldMatrix._24,
                    0, 0, length(worldMatrix._13_23_33), worldMatrix._34,
                    0, 0, 0, 1
                );
                float4x4 invertedWorldMatrix = Inverse(worldMatrix);

                o.objectWorldPosition = worldMatrix._14_24_34;

                //Scale of X, Z Must be set Same on GameObject.Transform Inspector.
                float worldXZScale = length(float3(unity_ObjectToWorld._11, unity_ObjectToWorld._21, unity_ObjectToWorld._31));
                float worldYScale = length(float3(unity_ObjectToWorld._12, unity_ObjectToWorld._22, unity_ObjectToWorld._32));

                float3 positionWS = mul(worldMatrix, float4(input.positionOS.xyz, 1)).xyz;
                float3 positionVS = TransformWorldToView(positionWS);
                o.positionCS = TransformWorldToHClip(positionWS);

                float3 viewRay = positionVS;
                o.viewRayOS.w = viewRay.z;//store the division value to varying o.viewRayOS.w
                viewRay *= -1;
                
                float4x4 ViewToObjectMatrix = mul(invertedWorldMatrix, UNITY_MATRIX_I_V);
                o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
                
                o.cameraPosOSAndFogFactor.xyz = mul(ViewToObjectMatrix, float4(0,0,0,1)).xyz; // hard code 0 or 1 can enable many compiler optimization
                o.cameraPosOSAndFogFactor.a = ComputeFogFactor(o.positionCS.z);
                
                o.screenPos = ComputeScreenPos(o.positionCS);
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                i.viewRayOS.xyz /= i.viewRayOS.w;
                float2 screenSpaceUV = i.screenPos.xy / i.screenPos.w;
                float sceneRawDepth = tex2D(_CameraDepthTexture, screenSpaceUV).r;
                float sceneDepthVS = LinearEyeDepth(sceneRawDepth, _ZBufferParams);

                float3 decalSpaceScenePos = i.cameraPosOSAndFogFactor.xyz + i.viewRayOS.xyz * sceneDepthVS;
                half shadow = length(decalSpaceScenePos) * 2;
                shadow = 1 - shadow;
                shadow /= _Softness;
                shadow = saturate(shadow);
                
                // float3 normal = normalize(decalSpaceScenePos);
                // float3 decalSpaceHardNormal = normalize(cross(ddx(decalSpaceScenePos), ddy(decalSpaceScenePos)));
                //float faceOcclusion = 1 - step(dot(decalSpaceHardNormal, normal), 0);
                //float faceOcclusion = step(0.000001, dot(decalSpaceHardNormal, normal) + 0.8);
                //shadow *= faceOcclusion;

                // return half4(decalSpaceHardNormal, 1);
                // float _ProjectionAngleDiscardThreshold = 0;
                // float shouldClip = decalSpaceHardNormal.z > _ProjectionAngleDiscardThreshold ? 0 : 1;
                // clip(0.5 - abs(decalSpaceScenePos) - shouldClip);

                half4 col = half4(0, 0, 0, shadow * _Alpha);
                col.rgb = MixFog(col.rgb, i.cameraPosOSAndFogFactor.a);
#ifdef LOD_FADE_CROSSFADE
                col.a *= saturate(unity_LODFade.r * 6);
#endif
                return col;
             }
            ENDHLSL
        }
    }
}
