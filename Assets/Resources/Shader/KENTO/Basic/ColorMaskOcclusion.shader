Shader "Unlit/ColorMaskOcclusion"
{
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry-1"
        }
        LOD 100
        ColorMask 0

        Pass
        {
        }
    }
}
