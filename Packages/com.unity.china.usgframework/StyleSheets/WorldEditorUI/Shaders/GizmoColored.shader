Shader "Gizmo/Colored"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1, 1)
    }

    SubShader
    {
        Tags {"Queue" = "Transparent+1000" "IgnoreProjector" = "True" "RenderType" = "Transparent"}

        Blend SrcAlpha OneMinusSrcAlpha

        ZWrite Off
        
        Pass
        {
            ZTest LEqual
            Color[_Color]
        }

        Pass
        {
            ZTest Greater
            Color[_Color]
        }
    }
}
