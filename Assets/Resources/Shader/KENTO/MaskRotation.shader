Shader "Unlit/MaskRotation"
{
    Properties
    {
        // テクスチャ(オフセット、タイリングなし)
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        // マスク用テクスチャ(オフセット、タイリングなし)
        [NoScaleOffset] _MaskTex("Mask Texture", 2D) = "white"{}
        // 回転の速度
        _RotateSpeed("Rotate Speed", Float) = 1.0
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
                // UV2 になるものを用意しないとうまくいかない
                float2 uv1 : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
            };

            sampler2D _MainTex;
            sampler2D _MaskTex;
            float _RotateSpeed;

            v2f vert (appdata v)
            {
                v2f o;
                // 3D空間座標 → スクリーン座標変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.uv1 = v.uv1;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Time を入力として全外の回転速度を作る
                half timer = _Time.y;
                // 回転行列を作る
                half angleCos = cos(timer * _RotateSpeed);
                half angleSin = sin(timer * _RotateSpeed);

                half2x2 rotateMatrix = half2x2(angleCos, - angleSin, angleSin, angleCos);

                // 中心合わせ
                half2 uv = i.uv - 0.5;
                // 中心を起点にメインテクスチャの UV を回転させる
                i.uv = mul(uv, rotateMatrix) + 0.5;

                // マスク用画像のピクセルの色を計算
                fixed4 mask = tex2D(_MaskTex, i.uv1);

                // 引数の値が 0 以下なら描画しない(Alpha が 0.5 以下なら描画しない)
                clip(mask.a - 0.5);

                // メインテクスチャの色を取得
                fixed4 col = tex2D(_MainTex, i.uv);

                // メイン画像とマスク画像のピクセルの計算を掛け合わせる
                return col * mask;
            }
            ENDCG
        }
    }
}
