Shader "Unlit/UV_Scroll"
{
    Properties
    {
        // スクロールさせるテクスチャ
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
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

            // 変数の宣言 Properties で定義した名前と一致させる
            sampler2D _MainTex;

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
                o.uv.y = v.uv.y + _Time.y;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // テクスチャと UV 座標から色の計算を行う
                // 頂点シェーダーから渡ってきた UV 情報が時間で変化する
                fixed4 col = tex2D(_MainTex, i.uv);
                return half4(col);
            }
            ENDCG
        }
    }
}
