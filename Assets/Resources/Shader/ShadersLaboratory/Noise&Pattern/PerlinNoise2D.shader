Shader "Unlit/PerlinNoise2D"
{
    Properties
    {
        _GridSize("Grid Size", Float) = 1
        _SeedX("Seed X", Float) = 1
        _SeedY("Seed Y", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _GridSize;
            float _SeedX;
            float _SeedY;

            // 疑似的にランダムな数値を生成する関数
            float4 permute(float4 x)
            {
                return fmod(34 * pow(x, 2) + x, 289);
            }

            // ノイズの補間をなめらかにする関数
            float2 fade(float2 t)
            {
                return 6 * pow(t, 5) - 15 * pow(t, 4) + 10 * pow(t, 3);
            }

            // ベクトルの長さのが逆数を高速で近似計算する関数
            float4 taylorInSqrt(float4 r)
            {
                return 1.79284291400159 - 0.85373472095314 * r;
            }

            #define DIV_289 0.00346020761245674740484429065744f

            float mod289(float x)
            {
                return x - floor(x * DIV_289) * 289;
            }

            float PerlinNoise2D(float2 P)
            {
                // 周囲のグリッドセルを取得
                // 現在の座標が属する正方形の4つの角のインデックス
                float4 Pi = floor(P.xyxy) + float4(0, 0, 1, 1);
                // 各角からの相対位置(0～1)
                float4 Pf = frac(P.xyxy) - float4(0, 0, 1, 1);

                float4 ix = Pi.xzxz;
                float4 iy = Pi.yyww;
                float4 fx = Pf.xzxz;
                float4 fy = Pf.yyww;

                // 各点からランダムな向きのベクトルを割当てる
                float4 i = permute(permute(ix) + iy);

                // 割当てたベクトル(グラディエント)の正規化
                float4 gx = frac(i / 41) * 2 - 1;
                float4 gy = abs(gx) - 0.5;
                float4 tx = floor(gx + 0.5);
                gx = gx - tx;

                float2 g00 = float2(gx.x, gy.x);
                float2 g10 = float2(gx.y, gy.y);
                float2 g01 = float2(gx.z, gy.z);
                float2 g11 = float2(gx.w, gy.w);

                float4 norm = taylorInSqrt(float4(
                dot(g00, g00), dot(g01, g01), dot(g10, g10), dot(g11, g11)));

                g00 *= norm.x;
                g01 *= norm.y;
                g10 *= norm.z;
                g11 *= norm.w;

                // 各隅のグラディエントベクトルとピクセルの相対位置ベクトルとの内積
                // グラディエント方向がどれだけ寄っているかを数値化し、この結果をノイズの高さにする
                float n00 = dot(g00, float2(fx.x, fy.x));
                float n10 = dot(g10, float2(fx.y, fy.y));
                float n01 = dot(g01, float2(fx.z, fy.z));
                float n11 = dot(g11, float2(fx.w, fy.w));

                // 隣り合う点との間をスムーズに補間
                float2 fade_xy = fade(Pf.xy);
                float2 n_x = lerp(float2(n00, n01), float2(n10, n11), fade_xy.x);
                float n_xy = lerp(n_x.x, n_x.y, fade_xy.y);
                return 2.3 * n_xy;
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv *= _GridSize;
                i.uv += float2(_SeedX, _SeedY);
                float ns = PerlinNoise2D(i.uv) / 2 + 0.5f;
                return float4(ns, ns, ns, 1);
            }
            ENDCG
        }
    }
}
