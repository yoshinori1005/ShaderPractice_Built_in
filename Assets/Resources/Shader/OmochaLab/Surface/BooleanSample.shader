Shader "Unlit/BooleanSample"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "Queue" = "Geometry-1" }
        LOD 100

        Pass
        {
            ZWrite On
            ColorMask 0
        }
    }
}
