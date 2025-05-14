Shader "Unlit/PseudoRandom"
{
    Properties
    {
        _Factor1("Factor1", Float) = 1
        _Factor2("Factor2", Float) = 1
        _Factor3("Factor3", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Factor1;
            float _Factor2;
            float _Factor3;

            float noise(half2 uv)
            {
                return frac(sin(dot(uv, float2(_Factor1, _Factor2))) * _Factor3);
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 col = noise(i.uv);
                return col;
            }
            ENDCG
        }
    }
}
