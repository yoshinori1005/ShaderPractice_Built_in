Shader "Unlit/PictureInPicture"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SecondaryTex("Secondary Texture", 2D) = "white"{}
        _RedThreshold("Red Threshold", Range(0, 1)) = 0
        _GreenThreshold("Green Threshold", Range(0, 1)) = 0
        _BlueThreshold("Blue Threshold", Range(0, 1)) = 0
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
                float2 uv1 : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;
            float _RedThreshold;
            float _GreenThreshold;
            float _BlueThreshold;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv1 = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv2 = TRANSFORM_TEX(v.texcoord, _SecondaryTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 各テクスチャの色情報を取得
                fixed4 col1 = tex2D(_MainTex, i.uv1);
                fixed4 col2 = tex2D(_SecondaryTex, i.uv2);

                // RとBはしきい値以下、Gはしきい値以上で条件を満たした時は1、そうでなければ0
                fixed val = floor(1 - saturate(col1.r - _RedThreshold))
                * floor(1 - saturate(col1.b - _BlueThreshold))
                * saturate(col1.g + _GreenThreshold);

                // しきい値での計算結果を元に各テクスチャの色を割当てる
                return lerp(col1, col2, val);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
