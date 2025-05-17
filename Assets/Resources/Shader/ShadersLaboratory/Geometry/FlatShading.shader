Shader "Unlit/FlatShading"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            struct v2g
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 vertex : TEXCOORD1;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float light : TEXCOORD1;
            };

            v2g vert (appdata_full v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3],inout TriangleStream<g2f> stream)
            {
                g2f o;

                // 法線ベクトルの計算
                float3 vecA = IN[1].vertex - IN[0].vertex;
                float3 vecB = IN[2].vertex - IN[0].vertex;
                float3 normal = cross(vecA, vecB);
                normal = normalize(mul(normal, (float3x3)unity_WorldToObject));

                // 拡散光を計算
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                o.light = max(0.0, dot(normal, lightDir));

                // UVの重心を計算
                o.uv = (IN[0].uv + IN[1].uv + IN[2].uv) / 3;

                for(int i = 0; i < 3; i ++)
                {
                    o.pos = IN[i].pos;
                    stream.Append(o);
                }
            }

            half4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= i.light * _Color;
                return col;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
