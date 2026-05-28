Shader "Custom/BlurWithAlpha"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Alpha ("Alpha", Range(0, 1)) = 1
        _BlendStrength ("Blend Strength", Range(0, 30)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _BlurTex;
            float4 _MainTex_ST;
            float _BlurRadius;
            float _Alpha;
            float _BlendStrength;
            int _BlurIterations;

            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };
            v2f vert(appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }
            
            float4 frag(v2f i) : SV_Target
            {
                float2 texel = float2(1.0 / _ScreenParams.x, 1.0 / _ScreenParams.y);
                float4 col = float4(0, 0, 0, 0);
                float2 uv = i.uv;
                int count = 0;
                _BlurIterations = 5;
                for (int x = -_BlurIterations; x <= _BlurIterations; x++)
                {
                    for (int y = -_BlurIterations; y <= _BlurIterations; y++)
                    {
                        float2 offset = texel*((float2(x, y) * _BlendStrength * 0.1));
                        col += tex2D(_MainTex, uv + offset);
                        count++;
                    }
                }
                col /= count;
                col.a *= _Alpha;
                return col;
            }
            ENDCG
        }
    }
}
