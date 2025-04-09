Shader "Unlit/DrawSquare"
{
    Properties
    {
        _LightColor("Light Color", Color) = (1, 1, 1, 1)
        _DarkColor("Dark Color", Color) = (0, 0, 0, 1)
        _Horizontal("Horizontal", Range(0, 1)) = 0.3
        _Vertical("Vertical", Range(0, 1)) = 0.1
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            fixed4 _LightColor;
            fixed4 _DarkColor;
            float _Horizontal;
            float _Vertical;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 lc = _LightColor;
                fixed4 dc = _DarkColor;
                fixed2 size = fixed2(_Horizontal, _Vertical);
                // 左下の座標を計算する
                fixed2 leftBottom = fixed2(0.5, 0.5) - size * 0.5;
                // 四角形の左下部分を塗りつぶし、上下左右反転させ、右上部分を塗りつぶす
                fixed2 uv = step(leftBottom, i.uv);
                uv *= step(leftBottom, 1 - i.uv);
                return lerp(dc, lc, uv.x * uv.y);
            }
            ENDCG
        }
    }
}
