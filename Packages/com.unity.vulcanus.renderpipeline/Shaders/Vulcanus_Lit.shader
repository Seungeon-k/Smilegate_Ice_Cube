Shader "Vulcanus/Vulcanus_Lit"
{
    Properties
    {
        // Specular vs Metallic workflow
        [HideInInspector] _WorkflowMode("WorkflowMode", Float) = 1.0

        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)

        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        [KeywordEnum(Transparency, MaskColor)] _AbedoChannelMode("Albedo Channel Type", Float) = 0.0
        _MaskColor("Mask Color", Color) = (1,1,1)

        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _UberMap("Uber", 2D) = "white" {}
        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
        _EmissionPower("Emission Power", Range(0.0, 50.0)) = 0
        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0
        //[ToggleOff] _Fog("Fog (default = on)", Float) = 0

        //Vulcanus Properties
        _ReceiveSilhouette("Receive Silhouette", Float) = 1.0
        _ReceiveDecal("Receive Decal", Float) = 1.0
        _BdrfFersnelRatio("BDRF Fersnel Ratio", Range(0, 1)) = 1
        [HDR] _RimColor("Rim Color", Color) = (1, 1, 1, 0)
        _RimPower("Rim Power", Range(0.5, 10.0)) = 3.5
        [HDR] _SubRimColor("Sub Rim Color", Color) = (1, 1, 1, 0)
        _SubRimPower("Sub Rim Power", Range(0.5, 10.0)) = 3.5
        [NoScaleOffset] _DyeingMaskMap("Dyeing Mask Map", 2D) = "black" {}
        [HDR] _Dyeing_Color_R("Dyeing Channel R", Color) = (1,1,1,1)
        [HDR] _Dyeing_Color_G("Dyeing Channel G", Color) = (1,1,1,1)
        [HDR] _Dyeing_Color_B("Dyeing Channel B", Color) = (1,1,1,1)
        [HDR] _Dyeing_Color_A("Dyeing Channel A", Color) = (1,1,1,1)
        [NoScaleOffset] _UtilityMap("Utility Map", 2D) = "white" {}
        _SSClipVariables("SSClip Variables", Vector) = (0, 0, 0, 0) //(screenUV.x, screenUV.y, size, activeFlag)
        _SwapObjectRatio("Object Swap Ratio", Range(0, 1)) = 0
        _ClippingArea("Clipping Area", Vector) = (-9999999, 9999999, -9999999, 9999999)
        [IntRange] _SwapObjectSign("Object Swap Sign", Range(-1, 1)) = 0
        _MeshXBounds("Mesh X Bounds", Float) = 0
        [HDR] _DissolveColorThickness("Dissolve Color Thickness", Color) = (0, 5, 5, 0.2)
        _Dissolve("Dissolve", Range(0.0, 1.0)) = 0
        _DitherAlpha("Dither Alpha", Range(0, 1)) = 1

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0

        _ReceiveShadows("Receive Shadows", Float) = 1.0
        // Editmode props
        [HideInInspector] _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

        // Stencil Properties
        _StencilReadMask("_StencilReadMask", Float) = 255
		_StencilRef("└─StencilRef", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("└─StencilComp (default = Disable)", Float) = 0 //0 = disable
		[Enum(UnityEngine.Rendering.StencilOp)]_PassOperation("└─PassOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_FailOperation("└─FailOperation (default = Keep)", Float) = 0	//0 = keep
		[Enum(UnityEngine.Rendering.StencilOp)]_ZFailOperation("└─ZFailOperation (default = Keep)", Float) = 0 //0 = keep
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
            "ShaderModel"="2.0"
            //"ShaderModel"="4.5"
        }
        LOD 300

        // ------------------------------------------------------------------
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            Blend[_SrcBlend][_DstBlend]
            ZWrite[_ZWrite]
            Cull[_Cull]
            //ZTest Always
            Stencil
            {
                ReadMask[_StencilReadMask]
                Ref[_StencilRef]
                Comp[_StencilComp]
                Pass [_PassOperation]
                Fail [_FailOperation]
                ZFail [_ZFailOperation]
            }
            HLSLPROGRAM
            ////#pragma exclude_renderers gles gles3 glcore
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            //#pragma shader_feature_local _FOG_OFF
            //#pragma shader_feature_local _NORMALMAP
            //#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _ALBEDO_ALPHA_MASKCOLOR   //(VULCANUS_CUSTOM)
            //#pragma shader_feature_local_fragment _DYEINGMASK               //(VULCANUS_CUSTOM)
            //#pragma shader_feature_local_fragment _UBERMAP                  //(VULCANUS_CUSTOM)
            
            // -------------------------------------
            // Universal Pipeline keywords
            //#pragma multi_compile _ DIRLIGHTMAP_COMBINED
            //#pragma multi_compile LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ SHADOWS_SHADOWMASK
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS _ADDITIONAL_LIGHTS_VERTEX
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            //#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            //#pragma multi_compile_fragment _ _LIGHT_LAYERS
            //#pragma multi_compile_fragment _ _LIGHT_COOKIES
            //#pragma multi_compile _ _CLUSTERED_RENDERING
            // #pragma multi_compile_fragment _ _REFLECTION_PROBE_BLENDING
            // #pragma multi_compile_fragment _ _REFLECTION_PROBE_BOX_PROJECTION
            
            #pragma multi_compile_vertex _ LOD_FADE_CROSSFADE 
            #pragma multi_compile _ _ULTRA_LOW_SPEC                         //(VULCANUS_CUSTOM)
            #pragma multi_compile _ _VERTEX_LIGHTING                        //(VULCANUS_CUSTOM)
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS_SPECULAR    //(VULCANUS_CUSTOM)

            // -------------------------------------
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            //#pragma multi_compile_instancing

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "Vulcanus_LitInput.hlsl"
            #include "Vulcanus_LitForwardPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            //#pragma multi_compile_instancing

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Vulcanus_LitInput.hlsl"
            #include "Vulcanus_ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags{"LightMode" = "DepthOnly"}

            ZWrite On
            ColorMask 0
            Cull[_Cull]

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            #pragma target 2.0

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            //#pragma multi_compile_instancing

            #include "Vulcanus_LitInput.hlsl"
            #include "DepthOnlyPass.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags{"LightMode" = "DepthNormals"}

            ZWrite On
            Cull[_Cull]

            HLSLPROGRAM
            //#pragma only_renderers gles gles3 glcore d3d11
            #pragma target 2.0

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON

            // #include "Vulcanus_LitInput.hlsl"
            // #include "DepthNormalsPass.hlsl"

            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"

            // -------------------------------------
            // Unity defined keywords
            //#pragma multi_compile_fragment _ LOD_FADE_CROSSFADE

            // Universal Pipeline keywords
            //#include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/RenderingLayers.hlsl"

            // //--------------------------------------
            // // GPU Instancing
            // #pragma multi_compile_instancing
            // #include_with_pragmas "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DOTS.hlsl"

            // -------------------------------------
            // Includes
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags{"LightMode" = "Meta"}

            Cull Off

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            #pragma target 2.0

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            //#pragma shader_feature_local_fragment _UBERMAP
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SPECGLOSSMAP

            #include "Vulcanus_LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

            ENDHLSL
        }
        
        // Pass
        // {
        //     Name "Universal2D"
        //     Tags{ "LightMode" = "Universal2D" }

        //     Blend[_SrcBlend][_DstBlend]
        //     ZWrite[_ZWrite]
        //     Cull[_Cull]

        //     HLSLPROGRAM
        //     //#pragma exclude_renderers gles gles3 glcore
        //     #pragma target 2.0

        //     #pragma vertex vert
        //     #pragma fragment frag
        //     #pragma shader_feature_local_fragment _ALPHATEST_ON
        //     //#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

        //     #include "Vulcanus_LitInput.hlsl"
        //     #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
        //     ENDHLSL
        // }
    }

    // SubShader
    // {
    //     Tags
    //     {
    //         "RenderType" = "Opaque"
    //         "RenderPipeline" = "UniversalPipeline"
    //         "UniversalMaterialType" = "Lit"
    //         "IgnoreProjector" = "True"
    //         "ShaderModel"="2.0"
    //     }
    //     LOD 300

    //     // ------------------------------------------------------------------
    //     Pass
    //     {
    //         Name "ForwardLit"
    //         Tags{"LightMode" = "UniversalForward"}

    //         Blend[_SrcBlend][_DstBlend]
    //         ZWrite[_ZWrite]
    //         Cull[_Cull]
    //         //ZTest Always
    //         Stencil
    //         {
    //             ReadMask[_StencilReadMask]
    //             Ref[_StencilRef]
    //             Comp[_StencilComp]
    //             Pass [_PassOperation]
    //             Fail [_FailOperation]
    //             ZFail [_ZFailOperation]
    //         }
    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         // -------------------------------------
    //         // Material Keywords
    //         #pragma shader_feature_local _FOG_OFF
    //         #pragma shader_feature_local _NORMALMAP
    //         #pragma shader_feature_local _RECEIVE_SHADOWS_OFF
    //         #pragma shader_feature_local_fragment _ALBEDO_ALPHA_MASKCOLOR 
    //         #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
    //         #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
    //         #pragma shader_feature_local_fragment _SPECULAR_SETUP
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _UBERMAP                  //(VULCANUS_CUSTOM)
    //         #pragma shader_feature_local_fragment _DYEINGMASK               //(VULCANUS_CUSTOM)

    //         // -------------------------------------
    //         // Universal Pipeline keywords
    //         #pragma multi_compile _ _MAIN_LIGHT_SHADOWS //_MAIN_LIGHT_SHADOWS_CASCADE //_MAIN_LIGHT_SHADOWS_SCREEN
    //         #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
    //         #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
    //         #pragma multi_compile_fragment _SHADOWS_SOFT //#pragma multi_compile_fragment _ _SHADOWS_SOFT

    //         #pragma multi_compile _ LIGHTMAP_ON
    //         #pragma multi_compile _ SHADOWS_SHADOWMASK
    //         #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
    //         #pragma multi_compile_vertex _ LOD_FADE_CROSSFADE 
    //         #pragma multi_compile _ _ULTRA_LOW_SPEC                         //(VULCANUS_CUSTOM)
    //         #pragma multi_compile _ _VERTEX_LIGHTING                        //(VULCANUS_CUSTOM)
    //         #pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS_SPECULAR    //(VULCANUS_CUSTOM)

    //         // -------------------------------------
    //         // Unity defined keywords
    //         #pragma multi_compile_fog
    //         #pragma skip_variants FOG_EXP FOG_EXP2


    //         // -------------------------------------
    //         // Unity defined keywords
    //         #pragma multi_compile_fog
    //         #pragma skip_variants FOG_EXP FOG_EXP2

    //         #pragma vertex LitPassVertex
    //         #pragma fragment LitPassFragment

    //         #include "Vulcanus_LitInput.hlsl"
    //         #include "Vulcanus_LitForwardPass.hlsl"
    //         ENDHLSL
    //     }

    //     Pass
    //     {
    //         Name "ShadowCaster"
    //         Tags{"LightMode" = "ShadowCaster"}

    //         ZWrite On
    //         ZTest LEqual
    //         ColorMask 0
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         // -------------------------------------
    //         // Material Keywords
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON

    //         #pragma vertex ShadowPassVertex
    //         #pragma fragment ShadowPassFragment

    //         #include "Vulcanus_LitInput.hlsl"
    //         #include "Vulcanus_ShadowCasterPass.hlsl"
    //         ENDHLSL
    //     }

    //     Pass
    //     {
    //         Name "DepthOnly"
    //         Tags{"LightMode" = "DepthOnly"}

    //         ZWrite On
    //         ColorMask 0
    //         Cull[_Cull]

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex DepthOnlyVertex
    //         #pragma fragment DepthOnlyFragment

    //         // -------------------------------------
    //         // Material Keywords
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON

    //         #include "Vulcanus_LitInput.hlsl"
    //         #include "DepthOnlyPass.hlsl"
    //         ENDHLSL
    //     }

    //     // This pass it not used during regular rendering, only for lightmap baking.
    //     Pass
    //     {
    //         Name "Meta"
    //         Tags{"LightMode" = "Meta"}

    //         Cull Off

    //         HLSLPROGRAM
    //         #pragma only_renderers gles gles3 glcore d3d11
    //         #pragma target 2.0

    //         #pragma vertex UniversalVertexMeta
    //         #pragma fragment UniversalFragmentMetaLit

    //         #pragma shader_feature_local_fragment _UBERMAP
    //         #pragma shader_feature_local_fragment _SPECULAR_SETUP
    //         #pragma shader_feature_local_fragment _ALPHATEST_ON
    //         #pragma shader_feature_local_fragment _SPECGLOSSMAP

    //         #include "Vulcanus_LitInput.hlsl"
    //         #include "Packages/com.unity.render-pipelines.universal/Shaders/LitMetaPass.hlsl"

    //         ENDHLSL
    //     }

    //     // Pass
    //     // {
    //     //     Name "Universal2D"
    //     //     Tags{ "LightMode" = "Universal2D" }

    //     //     Blend[_SrcBlend][_DstBlend]
    //     //     ZWrite[_ZWrite]
    //     //     Cull[_Cull]

    //     //     HLSLPROGRAM
    //     //     #pragma only_renderers gles gles3 glcore d3d11
    //     //     #pragma target 2.0

    //     //     #pragma vertex vert
    //     //     #pragma fragment frag
    //     //     #pragma shader_feature_local_fragment _ALPHATEST_ON

    //     //     #include "Vulcanus_LitInput.hlsl"
    //     //     #include "Packages/com.unity.render-pipelines.universal/Shaders/Utils/Universal2D.hlsl"
    //     //     ENDHLSL
    //     // }
    // }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.Vulcanus_LitShader"
}
