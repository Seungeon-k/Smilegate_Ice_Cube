Shader "Gizmo/LitColored"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _CullMode("Cull Mode", Int) = 2
    }

    SubShader
    {
        Tags {"Queue" = "Transparent+1000" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite OFF
        Cull Off

        Pass
        {
            ZTest ON

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc" // for _LightColor0

            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 normal : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 diff   : COLOR;
            };

            float4 _Color;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                // dot product between normal and light direction for
                // standard diffuse (Lambert) lighting
                half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                // factor in the light color
                o.diff = nl;// * _LightColor0;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                _Color.rgb = _Color.rgb * 0.3 + _Color.rgb * i.diff * 0.7;
                return _Color;
            }
            ENDCG
        }

        
    }
}
