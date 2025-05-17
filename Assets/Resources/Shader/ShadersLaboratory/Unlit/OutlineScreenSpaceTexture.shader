// Upgrade NOTE : replaced 'mul(UNITY_MATRIX_MVP, *)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/OutlineScreenSpaceTexture"
{
    Properties
    {
        [Header(Outline)]
        _OutlineVal("Outline Value", Range(0, 2)) = 0.01
        _OutlineCol("Outline Color", Color) = (0, 0, 0, 1)

        [Header(Texture)]
        _MainTex ("Main Texture", 2D) = "white" {}
        _Zoom("Zoom", Range(0.5, 20)) = 1
        _SpeedX("Speed Along X", Range(-1, 1)) = 0
        _SpeedY("Speed Along Y", Range(-1, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        LOD 100

        // アウトラインのPass
        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _OutlineVal;
            fixed4 _OutlineCol;

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata_base v)
            {
                v2f o;

                // 頂点をクリップ空間に変換
                o.pos = UnityObjectToClipPos(v.vertex);

                // 法線ベクトルをビュー空間に変換(カメラ空間)
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);

                // クリップ空間の法線ベクトルを計算
                normal.x *= UNITY_MATRIX_P[0][0];
                normal.y *= UNITY_MATRIX_P[1][1];

                // 計算した法線とアウトラインの値に応じてモデルを拡大縮小する
                o.pos.xy += _OutlineVal * normal.xy;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _OutlineCol;
            }
            ENDCG
        }

        // テクスチャのPass
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Zoom;
            float _SpeedX;
            float _SpeedY;

            float4 vert(appdata_base v) : SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }

            fixed4 frag(float4 i : VPOS) : SV_Target
            {
                // スクリーン空間テクスチャ
                return tex2D(_MainTex, ((i.xy / _ScreenParams.xy) + float2(_Time.y * _SpeedX, _Time.y * _SpeedY)) / _Zoom);
            }
            ENDCG
        }
    }
}
