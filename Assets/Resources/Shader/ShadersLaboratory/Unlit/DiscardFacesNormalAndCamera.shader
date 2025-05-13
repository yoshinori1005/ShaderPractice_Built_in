Shader "Unlit/DiscardFacesNormalAndCamera"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _ScalarVal("Value", Range(0, 1)) = 0
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
                fixed val : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ScalarVal;

            v2f vert (appdata_base v)
            {
                v2f o;
                // モデルの頂点位置をワールド空間に変換
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(worldPos);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                // 頂点の法線をワールド空間に変換
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);

                // カメラと法線のなす角度の内積
                // 値が1に近い : カメラに向いている
                // 値が0に近い : カメラと垂直
                // 負の値 : カメラと逆を向いている
                if(dot(worldNormal, normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz)) > _ScalarVal)
                o.val = 1;
                else
                o.val = 0;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // カメラに向いてない部分を描画しない
                if(i.val < 0.99) discard;
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
