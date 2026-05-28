Shader "Vulcanus/DefaultWhite"
{
    Properties
    {
		
    }
    SubShader
    {
        Tags { "Queue" = "Geometry" "RenderType" = "Opaque" }

        CGPROGRAM
        #pragma surface surf Lambert

		

        struct Input {
            float2 uv;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo.r = 1;
			o.Albedo.b = 1;
			o.Albedo.g = 0;
        }
        ENDCG
    }
}
