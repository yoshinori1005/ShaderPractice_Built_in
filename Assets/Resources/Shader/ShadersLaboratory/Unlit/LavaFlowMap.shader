Shader "Unlit/LavaFlowMap"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        // 流れの方向をベクトルとしてエンコードした画像
        _FlowMap("Flow Map", 2D) = "grey"{}
        _Speed("Speed", Range(-1, 1)) = 0.2
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

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            sampler2D _FlowMap;
            float4 _MainTex_ST;
            float _Speed;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c;
                // UVでフローマップの色情報を取得(0～1)、 * 2 - 1で値の範囲を - 1～1にリマップ
                half3 flowVal = (tex2D(_FlowMap, i.uv) * 2 - 1) * _Speed;

                // 時間に応じてずれる2つのUVを作成
                float dif1 = frac(_Time.y * 0.25 + 0.5);
                float dif2 = frac(_Time.y * 0.25);

                half lerpVal = abs((0.5 - dif1) / 0.5);

                // テクスチャを2回サンプリングして補間
                half4 col1 = tex2D(_MainTex, i.uv - flowVal.xy * dif1);
                half4 col2 = tex2D(_MainTex, i.uv - flowVal.xy * dif2);

                c = lerp(col1, col2, lerpVal);

                return c;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
