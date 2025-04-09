Shader "Unlit/ToonUnlit"
{
    // Surface Shader を Unlit Shader に置き換える(元 : ToonSurface.shader)
    Properties
    {
        // マテリアルで設定可能な色とテクスチャのプロパティ
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            // 使用するシェーダーモデルと関数指定
            #pragma vertex vert
            #pragma fragment frag

            // Unity の関数や定義を使うためのインクルード
            #include "UnityCG.cginc"

            // 頂点シェーダーの入力構造体 : モデルからのデータ
            struct appdata
            {
                float4 vertex : POSITION; // 頂点の位置
                float2 uv : TEXCOORD0; // UV座標
                float3 normal : NORMAL; // 法線ベクトル
            };

            // 頂点シェーダーの出力 + フラグメントシェーダーの入力構造体
            struct v2f
            {
                float4 pos : SV_POSITION; // テクスチャ座標
                float2 uv : TEXCOORD0; // 画面上の座標
                float3 worldNormal : TEXCOORD1; // ワールド空間の法線
                float3 worldPos : TEXCOORD2; // ワールド空間の位置
            };

            // 参照用プロパティ
            sampler2D _MainTex;
            float4 _Color;

            float4 _LightColor0;

            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;
                // モデル空間の頂点を画面空間に変換
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // 法線をワールド空間へ変換(照明計算に必要)
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 頂点のワールド座標
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            // フラグメントシェーダー
            fixed4 frag (v2f i) : SV_Target
            {
                // 法線の方向の正規化
                float3 N = normalize(i.worldNormal);
                // ライトの方向を正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                // 法線の方向とライトの方向の内積をとり、0.0以下は暗くする
                float lambert = max(dot(N, L), 0.0);

                float4 tex = tex2D(_MainTex, i.uv);
                float3 col = tex.rgb * lambert * _LightColor0.rgb;

                return float4(col, 1.0);
            }
            ENDCG
        }
    }
}
