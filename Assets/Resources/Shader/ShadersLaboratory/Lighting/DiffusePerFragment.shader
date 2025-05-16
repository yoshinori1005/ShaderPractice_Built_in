Shader "Unlit/DiffusePerFragment"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
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

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _LightColor0;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float dif = max(0.0, dot(i.normal, normalize(_WorldSpaceLightPos0.xyz)));
                fixed4 col = tex2D(_MainTex, i.uv);
                return fixed4(col.rgb * dif * _LightColor0.rgb, 1);
            }
            ENDCG
        }
    }
}
