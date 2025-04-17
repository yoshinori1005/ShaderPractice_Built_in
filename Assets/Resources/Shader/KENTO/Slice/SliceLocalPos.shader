Shader "Unlit/SliceLocalPos"
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

            fixed4 _Color;
            float _SliceSpace;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 localPos : TEXCOORD0;
            };

            // appdata_base は UnityCG.cginc で定義されている構造体
            v2f vert (appdata_base v)
            {
                v2f o;
                // 描画しようとしている頂点(ローカル座標)
                o.localPos = v.vertex.xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 各頂点のローカル座標(Y軸)それぞれに 15 をかけて frac 関数で小数だけ取り出す
                // そこから 0.5 を引いて clip 関数で 0 を下回ったら描画しない
                clip(frac(i.localPos.y * _SliceSpace) - 0.5);
                // RGBA にそれぞれのプロパティを当てはめてみる
                return fixed4(_Color);
            }
            ENDCG
        }
    }
}
