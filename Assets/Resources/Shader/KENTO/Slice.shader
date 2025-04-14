Shader "Unlit/Slice"
{
    Properties
    {
        // ここに書いたものが Inspector に表示される
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

            // 変数の宣言、Properties で定義した名前と一致させる
            fixed4 _Color;
            float _SliceSpace;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                // mul は行列の掛け算をやってくれる関数
                // unity_ObjectToWorld * 頂点座標(v.vertex) = 頂点のワールド座標
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 書く頂点のワールド座標(Y軸)それぞれに 15 をかけて frac 関数で小数だけ取り出す
                // そこから 0.5 を引いて clip 関数に渡す 0 を下回ったら描画しない
                clip(frac(i.worldPos.y * _SliceSpace) - 0.5);
                // RGBA にそれぞれのプロパティを当てはめてみる
                return fixed4(_Color);
            }
            ENDCG
        }
    }
}
