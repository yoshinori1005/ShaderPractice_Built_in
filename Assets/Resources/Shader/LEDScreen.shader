Shader "Unlit/LEDScreen"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _PixShape("Pixel Shape Tex", 2D) = "white"{}
        _UV_X("Pixel num X", Range(10, 1600)) = 960
        _UV_Y("Pixel num Y", Range(10, 1600)) = 360
        _Intensity("Intensity", float) = 1
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

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _PixShape;
            float4 _PixShape_ST;
            float _UV_X;
            float _UV_Y;
            float _Intensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 縦横にいくつ並べるか
                float2 uv_res = float2(_UV_X, _UV_Y);
                fixed4 col = tex2D(_MainTex, (floor(i.uv * uv_res) / uv_res + (1 / (uv_res * 2))));

                // 画素
                float2 uv = i.uv * uv_res;
                float4 pix = tex2D(_PixShape, uv);

                return col * pix * _Intensity;
            }
            ENDCG
        }
    }
}
