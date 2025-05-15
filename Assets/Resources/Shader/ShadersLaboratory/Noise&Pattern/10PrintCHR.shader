Shader "Unlit/10PrintCHR"
{
    Properties
    {
        _Factor1("Factor1", Float) = 1
        _Factor2("Factor2", Float) = 1
        _Factor3("Factor3", Float) = 1
        _GridSize("Grid Size", Float) = 1
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

            float _Factor1;
            float _Factor2;
            float _Factor3;
            float _GridSize;

            // トルシェ・パターン関数(タイル内のラインパターンを決める)
            float2 truchetPattern(float2 uv, float index)
            {
                index = frac((index - 0.5) * 2.0);

                if(index > 0.75)
                {
                    return float2(1, 1) - uv;
                }

                if(index > 0.5)
                {
                    return float2(1 - uv.x, uv.y);
                }

                if(index > 0.25)
                {
                    return 1 - float2(1 - uv.x, uv.y);
                }

                return uv;
            }

            // ノイズ関数によるランダム生成
            float noise(half2 uv)
            {
                return frac(sin(dot(uv, float2(_Factor1, _Factor2))) * _Factor3);
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv *= _GridSize;
                // タイルの正数座標
                float2 intVal = floor(i.uv);
                // タイルの中での位置
                float2 fracVal = frac(i.uv);

                float2 tile = truchetPattern(fracVal, noise(intVal));

                fixed col = smoothstep(tile.x - 0.3, tile.x, tile.y) - smoothstep(tile.x, tile.x + 0.3, tile.y);

                return fixed4(col, col, col, 1);
            }
            ENDCG
        }
    }
}
