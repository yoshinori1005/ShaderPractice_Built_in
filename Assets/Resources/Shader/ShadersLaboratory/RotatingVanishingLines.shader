Shader "Unlit/RotatingVanishingLines"
{
    Properties
    {
        _OriginX("PosX Origin", Range(0, 1)) = 0.5
        _OriginY("PosY Origin", Range(0, 1)) = 0.5
        _Speed("Speed", Range(-100, 100)) = 60
        _CircleNbr("Circle Quantity", Range(10, 1000)) = 60
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
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            float _OriginX;
            float _OriginY;
            float _Speed;
            float _CircleNbr;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 color;
                float distanceToCenter;
                float time = _Time.x * _Speed;

                // UVは0～1の範囲なので0を引いた時0.5、1を引いた時 - 0.5となる
                // モデル側から見て左側が正の値、右側が負の値
                float xDist = _OriginX - i.uv.x;
                float yDist = _OriginY - i.uv.y;

                // ユークリッド距離(空間内の2点間の直線距離を算出する方法)を利用
                distanceToCenter = (xDist * xDist + yDist * yDist) * _CircleNbr;

                // atan2 : 引数を2つ使うarctangent
                // 0.5 + 0.5 * sin()にすることで - 1～1をカラー用の0～1にclamp
                color = 0.5 + 0.5 * sin(atan2(xDist, yDist) * _CircleNbr + time);

                return color;
            }
            ENDCG
        }
    }
}
