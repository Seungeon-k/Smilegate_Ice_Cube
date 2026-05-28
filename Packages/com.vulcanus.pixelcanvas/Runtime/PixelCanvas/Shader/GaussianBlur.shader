

Shader "Vulcanus/PixelCanvas/GaussianBlur"
{
    Properties
    {
        [PerRendererData] _MainTex ("Texture", 2D) = "white" {} // Blit에서 source로 전달된 텍스처
        _TextureWidth ("Texture Width", Float) = 0
        _TextureHeight ("Texture Height", Float) = 0

        _BlurRadius ("Blur Radius", Range(0.1, 20)) = 1

        _Threshold ("Threshold", Range(0, 1)) = 0.5
        _MaxDistance ("MaxDistance", Float) = 0.5

        [Header(Render State)]
		[Enum(UnityEngine.Rendering.BlendMode)]_BlendScr("BlendScr", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]_BlendDst("BlendDst", Float) = 10
    }

    SubShader
    {
        Tags {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Pass
        {
            // BlendOp Add
            // Blend SrcAlpha OneMinusSrcAlpha

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#pragma fragment JumpFrag
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/PostProcessing/Common.hlsl"  
            #include "GaussianBlur.hlsl"
            
            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f 
            {
                float4 positionCS : SV_POSITION;
                float2 texcoord : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                half3 positionWS = TransformObjectToWorld(v.vertex.xyz).xyz;
                o.positionCS = TransformWorldToHClip(positionWS);
                o.texcoord = v.texcoord;
                return o;
            }

            // Horizontal blur fragment shader
            half4 frag(v2f input) : SV_Target
            {
                float2 texelSize = float2(1.0 / _TextureWidth, 1.0 / _TextureHeight);
                float4 result = 0;
                float sigma = _BlurRadius * 0.5; // Convert radius to sigma (approximation)
            
                half4 color = GaussianBlurSingle(TEXTURE2D_ARGS(_MainTex, sampler_MainTex), texelSize, input.texcoord, sigma, _BlurRadius);
                return color;
            }
            ENDHLSL
        }
    }
}