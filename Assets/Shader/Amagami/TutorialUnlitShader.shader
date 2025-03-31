Shader "Unlit/TutorialUnlitShader"
{
    Properties
    {
        // 2D = Texture2Dの略
        // つまり通常のテクスチャ

        _MainTex ("Texture", 2D) = "black" {}

        // float
        // 小数点の値を自由に設定できる

        [Space] _FloatValue("Float", float) = 0.1

        // int
        // 整数の値を自由に設定できる

        [Space] _IntValue("Int", int) = 5

        // Range
        // 指定範囲内の値をスライダーで設定できる

        [Space] _Range("Range", Range(0.5, 1.0)) = 0.75

        // Color
        // 色をカラーピッカーで設定できる

        [Space] _Color("Color", Color) = (1, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM // ここから Cg 言語のプログラムを書くという意味
            // プリプロセッサ
            #pragma vertex vert // 頂点シェーダー関数名
            #pragma fragment frag // フラグメントシェーダー関数名
            // make fog work
            #pragma multi_compile_fog // シェーダーバリアントという機能を使うための命令

            #include "UnityCG.cginc"

            // 頂点シェーダーへの入力定義(構造体structで定義、構造体：複数の値を格納できる型)
            struct appdata
            {
                // データ型とセマンティクス(POSITIONやTEXCOORD0)は決められたものを使う必要がある
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            // 頂点シェーダーからフラグメントシェーダーへ渡す情報(構造体structで定義)
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            // uniform変数(uniformは省略されている、他の言語のグローバル変数のようなもの)
            // sampler2D = Properties ブロックの Texture2D と同じ

            sampler2D _MainTex;
            float4 _MainTex_ST;

            // 頂点シェーダーの処理(変数o = out)
            v2f vert (appdata v)
            {
                v2f o;
                // モデル×ビュー×プロジェクションの変換を行なってくれる関数
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 中心を右上に設定する
                // o.vertex.x += 1;
                // o.vertex.y += 1 * _ProjectionParams.x;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            // フラグメントシェーダーの処理(変数i = in)
            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // 色を反転させる
                // fixed4 col = 1 - tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG // プログラム終了
        }
    }
}
