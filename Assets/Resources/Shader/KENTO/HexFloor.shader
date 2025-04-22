Shader "Unlit/HexFloor"
{
    Properties
    {
        [HDR] _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _RepeatFactor("Repeat Factor", Range(0, 100)) = 15
        _DistanceInterpolation("Distance Interpolation", Range(0, 1)) = 0.05
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

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
                float3 worldPos : WORLD_POS;
            };

            float4 _MainColor;
            float _RepeatFactor;
            float _DistanceInterpolation;

            // UVから六角形のタイルを出力
            float hex(float2 uv, float scale = 1)
            {
                float2 p = uv * scale;

                // x座標を2 / √3倍 (六角形の横方向の大きさが√3 / 2倍になる)
                p.x *= 1.15470053838;

                // 偶数列目なら1.0
                float isTwo = frac(floor(p.x) / 2.0) * 2.0;

                // 偶数列目を0.5ずらす
                p.y += isTwo * 0.5;
                p = frac(p) - 0.5;

                // 上下左右対称にする
                p = abs(p);

                // 六角形タイルとして出力
                return abs(max(p.x * 1.5 + p.y, p.y * 2.0) - 1.0);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // ローカル座標系をワールド座標系に変換
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // カメラとオブジェクトの距離(長さ)を取得
                // _WorldSpaceCameraPos：定義済の値 ワールド座標系のカメラの位置
                float cameraToObjectLength = length(_WorldSpaceCameraPos - i.worldPos);

                // 六角形描画のUVを利用して補間値を計算
                float interpolation = hex(i.uv, _RepeatFactor);
                float3 finalColor = lerp(_MainColor, 0, interpolation);

                // 六角形描画のUVを利用してアルファを塗分け
                float alpha = lerp(1, 0, interpolation);

                // 1m以下かつ、_DistanceInterpolationが0のときアルファが
                // 完全に0にならないのでmax関数で1以上をキープする
                alpha *= lerp(1, 0, max(cameraToObjectLength, 1) * _DistanceInterpolation);
                clip(alpha);

                return float4(finalColor, alpha);
            }
            ENDCG
        }
    }
}
