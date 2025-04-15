Shader "Unlit/SkyboxTest"
{
    Properties
    {
        // スクロールさせるテクスチャ
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            // 最背面に描画するので Background
            "RenderType" = "Background"
            "Queue" = "Background"
            // 設定すればマテリアルのプレビューがスカイボックスになる
            "PreviewType" = "SkyBox"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;

            // GPU から頂点シェーダーに渡す構造体
            struct appdata
            {
                float4 vertex : POSITION;
            };

            // 頂点シェーダーからフラグメントシェーダーに渡す構造体
            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            v2f vert (appdata v)
            {
                v2f o;
                // mul は行列の掛け算をする関数
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 描画したいピクセルのワールド座標を正規化
                float3 dir = normalize(i.worldPos);
                // ラジアンを算出する
                // atan2(x, y) : 直行座標の角度をラジアンで返す
                // atan(x) と異なり、1 周分の角度をラジアンで返せる(今回はスカイボックスの円周上のラジアンが返される)
                // asin(x) : - π / 2~π / 2 の間で逆正弦を返す(x の範囲は - 1～1)
                float rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                float2 uv = rad / float2(2.0 * UNITY_PI, UNITY_PI / 2);
                // テクスチャと UV 座標から色の計算を行う
                float4 col = tex2D(_MainTex, uv);
                return float4(col);
            }
            ENDCG
        }
    }
}
