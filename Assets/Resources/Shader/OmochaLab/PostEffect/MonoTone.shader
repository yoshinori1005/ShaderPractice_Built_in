Shader "Unlit/MonoTone"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            fixed4 frag (v2f_img i) : COLOR
            {
                fixed4 c = tex2D(_MainTex, i.uv);
                float gray = c.r * 0.3 + c.g * 0.6 + c.b * 0.1;
                c.rgb = fixed3(gray, gray, gray);
                return c;
            }
            ENDCG
        }
    }
}
