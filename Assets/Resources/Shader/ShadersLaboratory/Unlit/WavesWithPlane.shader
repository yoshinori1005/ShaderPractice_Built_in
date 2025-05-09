Shader "Unlit/WavesWithPlane"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Amplitude("Amplitude", Range(0, 4)) = 1
        _Movement("Movement", Range(-100, 100)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Cull Off

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

            float4 _Color;
            float _Amplitude;
            float _Movement;

            v2f vert (appdata v)
            {
                v2f o;

                // 現在のモデル行列(unity_ObjectToWorld) * 頂点座標(v.vertex)で頂点のワールド座標を求める
                float4 posWorld = mul(unity_ObjectToWorld, v.vertex);

                // X方向にもY方向にも波をつくる
                float displacement = (cos(posWorld.y) + cos(posWorld.x + _Movement * _Time.x));
                // 波の強さの調整
                posWorld.y = posWorld.y + _Amplitude * displacement;

                o.vertex = UnityObjectToClipPos(posWorld);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
