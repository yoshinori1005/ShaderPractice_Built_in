Shader "Unlit/UseCameraDistance"
{
    Properties
    {
        [NoScaleOffset] _NearTex ("Near Texture", 2D) = "white" {}
        [NoScaleOffset] _FarTex ("Far Texture", 2D) = "white" {}
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

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _NearTex;
            sampler2D _FarTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : WORLD_POS;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // ローカル座標系をワールド座標系に変換
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 nearCol = tex2D(_NearTex, i.uv);
                fixed4 farCol = tex2D(_FarTex, i.uv);

                // カメラとオブジェクトの距離(長さ)を取得
                // _WorldSpaceCameraPos : 定義済みの値、ワールド座標系のカメラの位置
                float cameraToObjLength = length(_WorldSpaceCameraPos - i.worldPos);

                // Lerp を使って色を変化、補間値にカメラとオブジェクトの距離を使用
                fixed4 col = fixed4(lerp(nearCol, farCol, cameraToObjLength * 0.05));

                // Alpha が 0 以下なら描画しない
                clip(col);

                // 最終的なピクセルの色を返す
                return col;
            }
            ENDCG
        }
    }
}
