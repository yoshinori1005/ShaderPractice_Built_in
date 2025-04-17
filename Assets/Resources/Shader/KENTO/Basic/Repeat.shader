Shader "Unlit/Repeat"
{
    Properties
    {
        _Color1("Color 1", Color) = (0, 0, 0, 1)
        _Color2("Color 2", Color) = (1, 1, 1, 1)
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            fixed4 _Color1;
            fixed4 _Color2;

            v2f vert (appdata v)
            {
                v2f o;
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                // 3D空間座標→スクリーン座標変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dotResult = dot(i.worldPos, normalize(float2(1, 1)));
                float repeat = abs(dotResult - _Time.w);
                // fmod(a, b)はaをbで除算した正の剰余
                float interpolation = step(fmod(repeat, 1), 0.1);
                fixed4 col = lerp(_Color1, _Color2, interpolation);
                return col;
            }
            ENDCG
        }
    }
}
