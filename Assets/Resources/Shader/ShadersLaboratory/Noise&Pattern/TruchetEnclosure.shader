Shader "Unlit/TruchetEnclosure"
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

            float2 truchetPattern(float2 uv, float index)
            {
                index = frac((index - 0.5) * 2);

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

            float noise(half2 uv)
            {
                return frac(sin(dot(uv, float2(_Factor1, _Factor2))) * _Factor3);
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                i.uv *= _GridSize;
                float2 intVal = floor(i.uv);
                float2 fracVal = frac(i.uv);

                float2 tile = truchetPattern(fracVal, noise(intVal));

                fixed val = step(length(tile), 0.4) - step(length(tile), 0.3)
                + step(length(tile), 0.7) - step(length(tile), 0.6)
                + step(tile.x - 1 + tile.y, 0.7) - step(tile.x - 1 + tile.y, 0.6)
                + step(tile.x - 1 + tile.y, 0.4) - step(tile.x - 1 + tile.y, 0.3);

                return fixed4(val, val, val, 1);
            }
            ENDCG
        }
    }
}
