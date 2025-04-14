Shader "Unlit/UVRotation"
{
    Properties
    {
        // テクスチャー(オフセット、タイリングの設定なし)
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
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

            // 頂点シェーダーに渡る頂点データ
            struct appdata
            {
                float4 vertex : POSITION;
                // 1 番目のUV座標
                float2 uv : TEXCOORD0;
            };

            // フラグメントシェーダーへ渡すデータ
            struct v2f
            {
                // 座標変換された後の頂点座標
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _RotateSpeed;

            // 頂点シェーダー
            v2f vert (appdata v)
            {
                v2f o;
                // 3D 空間座標 → スクリーン座標変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 受け取った UV 座標をフラグメントシェーダーで使用
                o.uv = v.uv;
                return o;
            }

            // フラグメントシェーダー
            fixed4 frag (v2f i) : SV_Target
            {
                // Time を入力として現在の回転速度を作る
                half timer = _Time.y;
                // 回転行列を作る
                half angleCos = cos(timer * _RotateSpeed);
                half angleSin = sin(timer * _RotateSpeed);

                /* | cosΘ - sinΘ |
                R(Θ) = | sinΘ cosΘ | 2次元回転行列の公式*/
                half2x2 rotateMatrix = half2x2(angleCos, - angleSin, angleSin, angleCos);

                // 中心
                half2 uv = i.uv - 0.5;

                // 中心を起点に UV を回転させる
                i.uv = mul(uv, rotateMatrix) + 0.5;

                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
