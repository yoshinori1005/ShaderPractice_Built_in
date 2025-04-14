Shader "Unlit/TextureMask"
{
    Properties
    {
        // テクスチャ(オフセット、タイリングなし)
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        // Mask 用テクスチャ(オフセット、タイリングなし)
        [NoScaleOffset] _MaskTex("Mask Texture", 2D) = "white"{}
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // マスク用画像のピクセルの色を計算
                fixed4 mask = tex2D(_MaskTex, i.uv);
                // 引数の値が 0 以下なら描画しない(Alphaが 0.5 以下なら描画しない)
                clip(mask.a - 0.5);
                // メイン画像のピクセルの色の計算
                fixed4 col = tex2D(_MainTex, i.uv);
                // メイン画像とマスク画像のピクセルの計算結果を掛け合わせる
                return col * mask;
            }
            ENDCG
        }
    }
}
