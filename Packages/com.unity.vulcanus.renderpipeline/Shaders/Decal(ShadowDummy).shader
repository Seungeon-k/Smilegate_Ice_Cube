Shader "Vulcanus/ShadowDecal(Dummy)"
{
    Properties
    {
    }

    SubShader
    {
        //Tags { "LightMode" = "Test" "RenderType" = "Overlay" "Queue" = "Transparent-499" "DisableBatching" = "True" }
        Tags { "LightMode" = "ShadowDecal(Dummy)" "RenderType" = "Overlay" "Queue" = "Transparent-499" }

        Pass
        {
            Cull[_Cull]
            ZTest[_ZTest]

            ZWrite off
            ColorMask 0

            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            
            #pragma target 3.0

            struct appdata
            {
                float3 positionOS : POSITION;
            };

            struct v2f
            {
            };

            v2f vert(appdata input)
            {
                v2f o;
                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                return half4(1, 0, 0, 1);
            }
            ENDHLSL
        }
    }
}
