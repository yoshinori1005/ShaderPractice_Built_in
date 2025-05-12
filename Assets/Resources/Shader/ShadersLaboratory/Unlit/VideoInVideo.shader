Shader "Unlit/VideoInVideo"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SecondaryTex("Secondary Texture", 2D) = "white"{}
        _Threshold("Threshold", Range(0, 1)) = 0
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
                float2 uv2 : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SecondaryTex;
            float4 _SecondaryTex_ST;
            float _Threshold;

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
                fixed4 col1 = tex2D(_MainTex, i.uv1);
                fixed4 col2 = tex2D(_SecondaryTex, i.uv2);

                // col1.g - col.r - _Thresholdが0より大きい→緑が赤より明らかに強い
                // col1.g - col1.b - _Thresholdが0より大きい→緑が青より明らかに強い
                // 両方の条件を満たしたらvalが1、それ以外は0
                fixed4 val = ceil(saturate(col1.g - col1.r - _Threshold))
                * ceil(saturate(col1.g - col1.b - _Threshold));
                return lerp(col1, col2, val);
            }
            ENDCG
        }
    }
}
