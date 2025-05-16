Shader "Unlit/InvertColor"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Threshold("Threshold", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Threshold;

            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = abs(_Threshold - col.rgb);
                return col;
            }
            ENDCG
        }
    }
}
