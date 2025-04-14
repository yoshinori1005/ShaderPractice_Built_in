Shader "Unlit/MouseClickReceive"
{
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
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
            };

            // C# 側で操作する変数
            float4 _MousePosition;

            v2f vert (appdata_base v)
            {
                v2f o;
                // 3D 空間座標 → スクリーン座標変換
                o.vertex = UnityObjectToClipPos(v.vertex);
                // 描画したいピクセルのワールド座標を計算
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ベースカラー
                float4 baseColor = (1, 1, 1, 1);

                /*マウスから出た Ray とオブジェクトの衝突箇所(ワールド座標)と
                描画しようとしているピクセルのワールド座標の距離を求める*/
                float dist = distance(_MousePosition, i.worldPos);

                // 求めた距離が任意の距離以下なら描画しようとしているピクセルの色を変える
                // 三項演算子での記述
                baseColor *= (dist < 0.1) ? float4(1, 0, 0, 1) : float4(1, 1, 1, 1);

                // if(dist < 0.1)
                // {
                //     baseColor *= float4(1, 0, 0, 1)
                // }

                return baseColor;
            }
            ENDCG
        }
    }
}
