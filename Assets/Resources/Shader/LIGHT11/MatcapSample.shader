Shader "Unlit/MatcapSample"
{
    Properties
    {
        _Matcap ("Matcap Tex", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
            };

            sampler2D _Matcap;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // カメラ座標系の法線を取得
                float3 normal = UnityObjectToWorldNormal(v.normal);
                normal = mul((float3x3)UNITY_MATRIX_V, normal);

                // 法線のxyを0～1に変換する
                o.uv = normal.xy * 0.5 + 0.5;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // カメラから見た法線のxyをそのままuvとして使う
                return tex2D(_Matcap, i.uv);
            }
            ENDCG
        }
    }
}
