Shader "MeshShaderAnimatedNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "black" {}
        _NoiseTex ("NoiseTex", 2D) = "white" {}
        [HDR]_OutlineColor("_OutlineColor",Color) = (1,1,1,1)
        [HDR]_BackgroundColor("_BackgroundColor",Color) = (1,1,1,1)
        _ColorRate("ColorRate" , Range(0,1)) = 1
        _Min("Min" , Range(-20,0)) = -10
        _Max("Max" , Range(0,20)) = 10
        _Speed("Speed",Vector) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "ShaderUsage"="Creator" }
        Blend SrcAlpha OneMinusSrcAlpha
        cull off
        zwrite off

        Pass
        {
            Name "Universal Forward"
            Tags {"LightMode" = "UniversalForward"}

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_instancing
            #pragma multi_compile_fog

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile __ _SHADOWS_SOFT

            #pragma multi_compile_local __ VULCANUS_COLORSPACE_GAMMA _SHADER_USAGE_CREATOR

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "../Supported/HLSL/GammaToLinear.hlsl"

            CBUFFER_START(UnityPerMaterial)

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float4 _NoiseTex_ST;
            half4 _OutlineColor;
            half4 _BackgroundColor;
            half _ColorRate;
            half _Min;
            half _Max;
            half4 _Speed;

            CBUFFER_END

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0; 
                float4 vertex : SV_POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            v2f vert(appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                o.vertex = TransformObjectToHClip(v.vertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }
            
            half4 frag(v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                half4 color = tex2D(_NoiseTex, float2(i.uv.x + _Time.x * _Speed.x , i.uv.y + _Time.x * _Speed.y));

                color += tex2D(_NoiseTex, float2(i.uv.x - _Time.x * _Speed.z , i.uv.y - _Time.x * _Speed.w));



                half gap = _Max - _Min;
                color = color * gap + _Min;
                color = 1-clamp(color, 0, 1);

                half4 mainColor = tex2D(_MainTex, color.rg);
#if VULCANUS_COLORSPACE_GAMMA
                mainColor = GammaToLinearBeginHLSL(mainColor);
#endif
                mainColor.a = mainColor.r;

#if VULCANUS_COLORSPACE_GAMMA           
                mainColor = GammaToLinearEndHLSL(mainColor);
#endif	
                float4 result = mainColor * _OutlineColor + _BackgroundColor;
                result = result * _ColorRate;

                return result;
            }
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
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            //#pragma multi_compile _ DOTS_INSTANCING_ON

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/ShadowCasterPass.hlsl"
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
            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            //#pragma multi_compile _ DOTS_INSTANCING_ON

            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }
    }

    Fallback "Diffuse"
}
