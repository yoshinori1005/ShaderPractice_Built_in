Shader "Unlit/ChromaticAberration"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        [Header(Red)]
        _RedX("Offset Red X", Range(-0.5, 0.5)) = 0.0
        _RedY("Offset Red Y", Range(-0.5, 0.5)) = 0.0
        [Header(Green)]
        _GreenX("Offset Green X", Range(-0.5, 0.5)) = 0.0
        _GreenY("Offset Green Y", Range(-0.5, 0.5)) = 0.0
        [Header(Blue)]
        _BlueX("Offset Blue X", Range(-0.5, 0.5)) = 0.0
        _BlueY("Offset Blue Y", Range(-0.5, 0.5)) = 0.0
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
            float _RedX;
            float _RedY;
            float _GreenX;
            float _GreenY;
            float _BlueX;
            float _BlueY;


            fixed4 frag (v2f_img i) : SV_Target
            {
                fixed4 col = fixed4(1, 1, 1, 1);

                // R,G,BそれぞれのチャンネルをUVをオフセットすることでズラす
                float2 red_uv = i.uv + float2(_RedX, _RedY);
                float2 green_uv = i.uv + float2(_GreenX, _GreenY);
                float2 blue_uv = i.uv + float2(_BlueX, _BlueY);

                col.r = tex2D(_MainTex, red_uv).r;
                col.g = tex2D(_MainTex, green_uv).g;
                col.b = tex2D(_MainTex, blue_uv).b;

                return col;
            }
            ENDCG
        }
    }
}
