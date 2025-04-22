Shader "Unlit/CellularNoise"
{
    Properties
    {
        [HDR] _WaterColor("Water Color", Color) = (0.09, 0.89, 1, 1)
        _FoamColor("Foam Color", Color) = (1, 1, 1, 1)
        _SquareNum("Square Num", int) = 5
        _WaveSpeed("Wave Speed", Range(0.01, 10)) = 1
        _FoamPower("Foam Power", Range(0, 1)) = 0.6
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
            };

            float2 random2(float2 st)
            {
                st = float2(
                dot(st, float2(127.1, 311.7)),
                dot(st, float2(269.5, 183.3))
                );
                return - 1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            float4 _WaterColor;
            float4 _FoamColor;
            int _SquareNum;
            float _WaveSpeed;
            float _FoamPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 st = i.uv;
                // 格子状の升目作成(UVにかけた数分だけ同じUVが繰り返し展開される)
                st *= _SquareNum;

                // 各マス目の起点
                float2 ist = floor(st);
                // 各マス目の起点からの描画したい位置
                float2 fst = frac(st);

                float4 waveColor = 0;
                float m_dist = 100;

                // 自身を含む周囲のマスをチェック
                for(int y =- 1; y <= 1; y ++)
                {
                    for(int x =- 1; x <= 1; x ++)
                    {
                        // 周辺1x1のエリア
                        float2 neighbor = float2(x, y);

                        // 点のxy座標
                        float2 p = 0.5 + 0.5 * sin(random2(ist + neighbor) + _Time.y * _WaveSpeed);

                        // 点と処理対象のピクセルとの距離ベクトル
                        float2 diff = neighbor + p - fst;

                        m_dist = min(m_dist, length(diff));

                        waveColor = lerp(_WaterColor, _FoamColor, smoothstep(1 - _FoamPower, 1, m_dist));
                    }
                }

                return waveColor;
            }
            ENDCG
        }
    }
}
