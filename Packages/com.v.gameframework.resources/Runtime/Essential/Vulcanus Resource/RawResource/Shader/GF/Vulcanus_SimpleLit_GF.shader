// Shader targeted for low end devices. Single Pass Forward Rendering.
Shader "ZAMMYSMITH/ZAMMYSMITH_SimpleLit_GF"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Map (RGB) Smoothness / Alpha (A)", 2D) = "white" {}
        [MainColor]   _BaseColor("Base Color", Color) = (1, 1, 1, 1)

        _Tiling ("Tiling", Vector) = (1,1,0,0)
        _Offset ("Offset", Vector) = (0,0,0,0)
        
        _Cutoff("Alpha Clipping", Range(0.0, 1.0)) = 0.5

        [KeywordEnum(Transparency, MaskColor)] _AbedoChannelMode("Albedo Channel Type", Float) = 0.0
        _MaskColor("Mask Color", Color) = (1,1,1)

        _UberMap("Uber", 2D) = "white" {}
        _SpecColor("Specular Color", Color) = (0.5, 0.5, 0.5, 0.5)
        [Enum(Specular Alpha,0,Albedo Alpha,1)] _SmoothnessSource("Smoothness Source", Float) = 0.0
        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [HideInInspector] _BumpScale("Scale", Float) = 1.0
        [NoScaleOffset] _BumpMap("Normal Map", 2D) = "bump" {}
        [HideInInspector] _EmissionPower("Emission Power", Range(0.0, 50.0)) = 0

        //Vulcanus Properties
        _ReceiveSilhouette("Receive Silhouette", Float) = 1.0
        _ReceiveDecal("Receive Decal", Float) = 1.0
        _BdrfFersnelRatio("BDRF Fersnel Ratio", Range(0, 1)) = 1
        [HDR] _RimColor("Rim Color", Color) = (1, 1, 1, 0)
        _RimPower("Rim Power", Range(0.5, 10.0)) = 3.5
        [HDR] _SubRimColor("Sub Rim Color", Color) = (1, 1, 1, 0)
        _SubRimPower("Sub Rim Power", Range(0.5, 10.0)) = 3.5
        [Toggle] _DyeingMaskToggle("Enable DyeingMask ", Float) = 0.0
        [NoScaleOffset] _DyeingMaskMap("Dyeing Mask Map", 2D) = "black" {}
        [HDR] _Dyeing_Color_R("Dyeing Channel R", Color) = (1,1,1,1)
        [HDR] _Dyeing_Color_G("Dyeing Channel G", Color) = (1,1,1,1)
        [HDR] _Dyeing_Color_B("Dyeing Channel B", Color) = (1,1,1,1)
        [HDR] _Dyeing_Color_A("Dyeing Channel A", Color) = (1,1,1,1)
        [NoScaleOffset] _UtilityMap("Utility Map", 2D) = "white" {}
        _SSClipVariables("SSClip Variables", Vector) = (0, 0, 0, 0) //(screenUV.x, screenUV.y, size, activeFlag)
        _SwapObjectRatio("Object Swap Ratio", Range(0, 1)) = 0
        [IntRange] _SwapObjectSign("Object Swap Sign", Range(-1, 1)) = 0
        _MeshXBounds("Mesh X Bounds", Float) = 0
        [HDR] _DissolveColorThickness("Dissolve Color Thickness", Color) = (0, 5, 5, 0.2)
        _Dissolve("Dissolve", Range(0.0, 1.0)) = 0
        _DitherAlpha("Dither Alpha", Range(0, 1)) = 1

        //[ToggleOff] _Fog("Fog (default = on)", Float) = 0

        // Blending state
        [HideInInspector] _Surface("__surface", Float) = 0.0
        [HideInInspector] _Blend("__blend", Float) = 0.0
        [HideInInspector] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _Cull("__cull", Float) = 2.0

        [ToggleOff] _ReceiveShadows("Receive Shadows", Float) = 1.0

        // Editmode props
        [HideInInspector] _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _Shininess("Smoothness", Float) = 0.0
        [HideInInspector] _GlossinessSource("GlossinessSource", Float) = 0.0
        [HideInInspector] _SpecSource("SpecularHighlights", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}

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
            "UniversalMaterialType" = "SimpleLit"
            "IgnoreProjector" = "True"
            "ShaderModel"="2.0"
        }
        LOD 300

        Pass
        {
            Name "ForwardLit"
            Tags { "LightMode" = "UniversalForward" }

            // Use same blending / depth states as Standard shader
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
            //#pragma exclude_renderers gles gles3 glcore
            #pragma target 2.0

            // -------------------------------------
            // Material Keywords
            //#pragma shader_feature_local _FOG_OFF
            //#pragma shader_feature_local _NORMALMAP
            //#pragma shader_feature_local _RECEIVE_SHADOWS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_COLOR
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
            //#pragma multi_compile_fragment _ _SHADOWS_SOFT
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            //#pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            //#pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            // #pragma multi_compile_fragment _ _LIGHT_LAYERS
            // #pragma multi_compile_fragment _ _LIGHT_COOKIES
            // #pragma multi_compile _ _CLUSTERED_RENDERING
            
            //#pragma multi_compile_vertex _ LOD_FADE_CROSSFADE 
            #pragma multi_compile _ _ULTRA_LOW_SPEC                         //(VULCANUS_CUSTOM)
            #pragma multi_compile _ _VERTEX_LIGHTING                        //(VULCANUS_CUSTOM)
            //#pragma multi_compile_fragment _ _ADDITIONAL_LIGHTS_SPECULAR    //(VULCANUS_CUSTOM)
            
            // -------------------------------------
            #pragma multi_compile_fog
            #pragma skip_variants FOG_EXP FOG_EXP2
            //#pragma multi_compile_instancing

            #pragma vertex LitPassVertexSimple
            #pragma fragment LitPassFragmentSimple
            #define BUMP_SCALE_NOT_SUPPORTED 1

            #include "Vulcanus_SimpleLitInput.hlsl"
            #include "Vulcanus_SimpleLitForwardPass.hlsl"
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

            #include "Vulcanus_SimpleLitInput.hlsl"
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

            #include "Vulcanus_SimpleLitInput.hlsl"
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

            #include "Vulcanus_SimpleLitInput.hlsl"
            #include "DepthNormalsPass.hlsl"

            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags{ "LightMode" = "Meta" }

            Cull Off

            HLSLPROGRAM
            //#pragma exclude_renderers gles gles3 glcore
            #pragma target 2.0

            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaSimple

            #include "Vulcanus_SimpleLitInput.hlsl"
            #include "Vulcanus_SimpleLitMetaPass.hlsl"

            ENDHLSL
        }
    }

    Fallback "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.Vulcanus_SimpleLitShader_GF"
}
