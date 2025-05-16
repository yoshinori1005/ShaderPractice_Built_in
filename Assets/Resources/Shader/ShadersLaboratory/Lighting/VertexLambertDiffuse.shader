Shader "Unlit/VertexLambertDiffuse"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Diffuse("Diffuse Value", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "LightMode" = "ForwardBase"
        }
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 col : COLOR0;
            };

            fixed4 _Color;
            fixed4 _LightColor0;
            float _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;

                // モデルの頂点位置を画面に表示できるように変換
                o.pos = UnityObjectToClipPos(v.vertex);

                // 法線をワールド空間に変換
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);

                // 面の向きと光の向きの角度に応じて明るさが変わる(Lambert拡散反射)
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = max(0, dot(worldNormal, lightDir)); // max()明るさが0にならないように

                // マテリアルの色、ライトの色、法線と光の角度に応じた明るさ、
                // 拡散の強さを計算し最終的な色を決定し、頂点の色として格納
                fixed4 diff = _Color * NdotL * _LightColor0 * _Diffuse;
                o.col = diff;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return i.col;
            }
            ENDCG
        }
    }
}
