Shader "Unlit/PostRenderingCheckerboard"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        [PowerSlider(2.0)]
        _Val("Size", Range(0, 1)) = 0
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;
            float _Val;

            fixed4 frag (v2f_img i) : SV_Target
            {
                float2 val = floor(i.pos.xy * _Val) * 0.5;

                if(frac(val.x + val.y) > 0)
                return _Color;

                return tex2D(_MainTex, i.uv); ;
            }
            ENDCG
        }
    }
}
