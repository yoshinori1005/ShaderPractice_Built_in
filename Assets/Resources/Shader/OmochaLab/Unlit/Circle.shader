Shader "Unlit/Circle"
{
    Properties
    {
        _LightColor("Light Color", Color) = (1, 1, 1, 1)
        _DarkColor("Dark Color", Color) = (0, 0, 0, 1)
        _Radius("Radius", Range(0, 1)) = 0.4
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
            float _Radius;

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
                fixed radius = _Radius;
                // UVの中心をとる
                fixed r = distance(i.uv, fixed2(0.5, 0.5));
                // return lerp(dc, lc, step(radius, r));
                // エッジ周辺をぼかすアンチエイリアス
                return lerp(dc, lc, smoothstep(radius, radius + 0.02, r));
            }
            ENDCG
        }
    }
}
