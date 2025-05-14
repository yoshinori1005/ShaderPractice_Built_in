Shader "Unlit/FadingWhenTooEdge"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Threshold("Threshold", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 val : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Threshold;

            v2f vert (appdata_base v)
            {
                v2f o;
                // 頂点のワールド空間での法線とカメラへの方向ベクトルを使って、
                // どれだけカメラに正対しているか(dot値)を計算する
                // 値が小さいと斜めに向いている(透明にする)
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = mul(UNITY_MATRIX_VP, worldPos); ;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);
                // 1に近いと正面向き(不透明)
                o.val = abs(dot(worldNormal, viewDir));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // step関数でカメラにある程度正対していない面のアルファを0にして透明にする
                col.a *= step(_Threshold + 0.01, i.val);
                return col;
            }
            ENDCG
        }
    }
}
