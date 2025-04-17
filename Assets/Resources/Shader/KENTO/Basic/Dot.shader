Shader "Unlit/Dot"
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
                // unity_ObjectToWorld * 頂点座標(v.vertex) = 描画しようとしているピクセルのワールド座標
                // mulは行列の掛け算をやってくれる関数
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 各ピクセルのワールド座標の位置ベクトルを正規化していないパターン
                // float interpolation = dot(i.worldPos, float2(0, 1));

                // 斜め方向のベクトルを利用
                // float interpolation = dot(i.worldPos, normalize(float2(1, 1)));

                // 単位ベクトル同士
                float interpolation = dot(normalize(i.worldPos), float2(0, 1));
                fixed4 col = lerp(_Color1, _Color2, interpolation);
                return col;
            }
            ENDCG
        }
    }
}
