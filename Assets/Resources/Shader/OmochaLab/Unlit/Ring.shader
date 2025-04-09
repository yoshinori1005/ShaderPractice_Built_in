Shader "Unlit/Ring"
{
    Properties
    {
        _LightColor("Light Color", Color) = (1, 1, 1, 1)
        _DarkColor("Dark Color", Color) = (0, 0, 0, 1)
        _RadiusFactor("Radius Factor", Float) = 4
        _Thickness("Thickness", Range(0, 1)) = 0.998
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
            float _RadiusFactor;
            float _Thickness;

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
                fixed len = distance(i.uv, fixed2(0.5, 0.5));
                return lerp(dc, lc, step(_Thickness, sin(len * _RadiusFactor)));
            }
            ENDCG
        }
    }
}
