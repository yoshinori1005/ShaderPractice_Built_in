Shader "Unlit/GradationSky"
{
    Properties
    {
        // グラデーションカラー
        _TopColor("Top Color", Color) = (1, 1, 1, 1)
        _UnderColor("Under Color", Color) = (1, 1, 1, 1)
        // 色の境界の位置
        _ColorBorder("Color Border", Range(0, 3)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Background"
            "Queue" = "Background"
            "PreviewType" = "SkyBox"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _TopColor;
            fixed4 _UnderColor;
            float _ColorBorder;

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = v.vertex.xyz;
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

                // 整えたい UV の Y軸方向の座標を利用して色をグラデーションさせる
                return lerp(_UnderColor, _TopColor, uv.y + _ColorBorder);
            }
            ENDCG
        }
    }
}
