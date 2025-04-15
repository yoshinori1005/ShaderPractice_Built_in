Shader "Unlit/GradationNightSkyWithMoon"
{
    Properties
    {
        _SquareNum("Square Num", int) = 10
        _MoonColor("Moon Color", Color) = (1, 1, 0, 1)

        // グラデーションカラー
        _TopColor("Top Color", Color) = (0.26, 0.33, 0.51, 1)
        _UnderColor("Under Color", Color) = (0.18, 0.37, 0.6, 1)

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

            int _SquareNum;
            float4 _MoonColor;
            float4 _TopColor;
            float4 _UnderColor;
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
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            float2 random2(float2 st)
            {
                st = float2(dot(st, float2(127.1, 311.7)), dot(st, float2(269.5, 183.3)));
                return - 1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            float4 frag (v2f i) : SV_Target
            {
                // 描画したいピクセルのワールド座標を正規化
                float3 dir = normalize(i.worldPos);
                // ラジアンを算出する
                // atan2(x, y) : 直行座標の角度をラジアンで返す
                // atan(x) と異なり、1 周分の角度をラジアンで返せる(今回はスカイボックスの円周上のラジアンが返される)
                // asin(x) : - π / 2~π / 2 の間で逆正弦を返す(x の範囲は - 1～1)
                float2 rad = float2(atan2(dir.x, dir.z), asin(dir.y));
                float2 uv = rad / float2(UNITY_PI / 2, UNITY_PI / 2);

                uv *= _SquareNum;

                float2 ist = floor(uv);
                float2 fst = frac(uv);

                float4 color = 0;

                // 自身を含む周囲のマスを探索
                for(int y =- 1; y <= 1; y ++)
                {
                    for(int x =- 1; x <= 1; x ++)
                    {
                        // 周辺 1x1 のエリア
                        float2 neighbor = float2(x, y);

                        // 点の xy 座標
                        float2 p = random2(ist);

                        // 点と処理対象のピクセルと距離ベクトル
                        float2 diff = neighbor + p - fst;

                        // 色を星ごとにランダムに当てはめる(星の座標を利用)
                        float r = rand(p + 1);
                        float g = rand(p + 2);
                        float b = rand(p + 3);
                        float4 randColor = float4(r, g, b, 1);

                        // 補間値を計算
                        // step(t, x) は x が t より大きい場合 1 を返す
                        float interpolation = 1 - step(0.01, length(diff));

                        // 補間値を利用して夜空と星を振り分ける
                        color = lerp(color, randColor, interpolation);

                        // グリッドの描画
                        // color.r += step(0.98, fst.x) + step(0.98, fst.y);

                    }
                }

                // 整えた UV のY軸方向の座標を利用して色をグラデーションさせる
                color += lerp(_UnderColor, _TopColor, uv.y + _ColorBorder);
                // 月
                color = lerp(_MoonColor, color, step(uv.y, _SquareNum * 0.75));

                return color;
            }
            ENDCG
        }
    }
}
