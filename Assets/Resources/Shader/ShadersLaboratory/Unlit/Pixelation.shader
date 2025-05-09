Shader "Unlit/Pixelation"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _PixelNumberX("Pixel Number Along X", float) = 500
        _PixelNumberY("Pixel Number Along Y", float) = 500
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _PixelNumberX;
            float _PixelNumberY;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // appdata_baseを使用する場合v.uvは使えず、v.texcoordになる
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // UVを指定数で分割する
                half ratioX = 1 / _PixelNumberX;
                half ratioY = 1 / _PixelNumberY;
                half2 uv = half2((int)(i.uv.x / ratioX) * ratioX, (int)(i.uv.y / ratioY) * ratioY);
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
