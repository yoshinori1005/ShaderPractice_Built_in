Shader "Unlit/SliceScroll"
{
    Properties
    {
        // 色
        _Color("Main Color", Color) = (1, 1, 1, 1)
        // スライスされる間隔
        _SliceSpace("Slice Space", Range(0, 30)) = 15
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

            fixed4 _Color;
            float _SliceSpace;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv + _Time.y / 2;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 各頂点のローカル座標(Y軸)それぞれに 15 をかけて frac 関数で小数だけ取り出す
                // そこから 0.5 を引いて clip 関数で 0 を下回ったら描画しない
                clip(frac(i.uv.y * _SliceSpace) - 0.5);
                // プロパティで設定した色を返す
                return fixed4(_Color);
            }
            ENDCG
        }
    }
}
