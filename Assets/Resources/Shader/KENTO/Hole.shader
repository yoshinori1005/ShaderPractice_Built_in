Shader "Unlit/Hole"
{
    Properties
    {
        _ClipSize("Clip Size", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry-1"
        }
        LOD 100

        Blend Zero SrcAlpha

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

            float _ClipSize;

            float circle(float2 p, float radius)
            {
                return length(p) - radius;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 f_st = frac(i.uv) * 2 - 1;
                float ci = circle(f_st, 0);
                float4 col = step(_ClipSize, ci);

                // 引数の値が0以下なら"描画しない(すなわちAlphaが0.5以下なら"描画しない)
                clip(col.a - 0.5);

                return col;
            }
            ENDCG
        }
    }
}
