Shader "Unlit/Jelly"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
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
            float4 _MainTex_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                // 頂点のX, Yの位置を時間に応じて動かす
                // sign()は値が正なら1、負なら - 1を返す
                v.vertex.x += sign(v.vertex.x) * sin(_Time.w) / 50;
                v.vertex.y += sign(v.vertex.y) * cos(_Time.w) / 50;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 c = tex2D(_MainTex, i.uv);
                return c;
            }
            ENDCG
        }
    }
}
