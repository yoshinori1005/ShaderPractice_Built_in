Shader "Unlit/SliceTextureScroll"
{
    Properties
    {
        // スクロールさせるテクスチャ
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
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

            sampler2D _MainTex;
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
                float2 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                // 描画しようとしている頂点(ローカル座標)
                o.localPos = v.vertex.xyz;
                o.uv = v.uv + _Time;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 頂点の色を計算
                fixed4 col = tex2D(_MainTex, i.uv);
                // 各頂点のローカル座標(Y軸)それぞれに 15 をかけて frac 関数で小数だけ取り出す
                // そこから 0.5 を引いて clip 関数で 0 を下回ったら描画しない
                clip(frac(i.localPos.y * _SliceSpace) - 0.5);
                // 計算した色とプロパティで設定した色を乗算する
                return col * _Color;
            }
            ENDCG
        }
    }
}
