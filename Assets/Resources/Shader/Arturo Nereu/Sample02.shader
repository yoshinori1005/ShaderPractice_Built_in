Shader "Unlit/Sample02"
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
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                // メッシュの頂点座標を0.75倍(縮小)する
                // float4 vert = v.vertex * 0.75;
                // メッシュの頂点座標を時間経過に応じてsin関数で変化
                float4 vert = float4(v.vertex.xyz * sin(_Time.y), v.vertex.w);
                o.pos = UnityObjectToClipPos(vert);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return half4(1, 1, 1, 1);
            }
            ENDCG
        }
    }
}
