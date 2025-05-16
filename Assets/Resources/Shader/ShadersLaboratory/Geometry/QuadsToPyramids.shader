Shader "Unlit/QuadsToPyramids"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Factor("Factor", Range(0, 2)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2g
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 col : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Factor;

            v2g vert (appdata_base v)
            {
                v2g o;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.normal = v.normal;
                return o;
            }

            [maxvertexcount(12)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> stream)
            {
                g2f o;

                // 三角形の法線を計算
                float3 normalFace = normalize(cross(
                IN[1].vertex - IN[0].vertex,
                IN[2].vertex - IN[0].vertex
                ));

                float edge1 = distance(IN[1].vertex, IN[0].vertex);
                float edge2 = distance(IN[2].vertex, IN[0].vertex);
                float edge3 = distance(IN[2].vertex, IN[1].vertex);

                float3 centerPos = (IN[0].vertex + IN[1].vertex) / 2;
                float2 centerTex = (IN[0].uv + IN[1].uv) / 2;

                // 三角形の一番長い辺を探し、その中点を頂点とする
                if((step(edge1, edge2) * step(edge3, edge2)) == 1.0)
                {
                    centerPos = (IN[2].vertex + IN[0].vertex) / 2;
                    centerTex = (IN[2].uv + IN[0].uv) / 2;
                }
                else if((step(edge2, edge3) * step(edge1, edge3)) == 1.0)
                {
                    centerPos = (IN[1].vertex + IN[2].vertex) / 2;
                    centerTex = (IN[1].uv + IN[2].uv) / 2;
                }

                centerPos += float4(normalFace, 0) * _Factor;

                // 中点の頂点と各辺で側面の三角形を作る
                for(int i = 0; i < 3; i ++)
                {
                    o.pos = UnityObjectToClipPos(IN[i].vertex);
                    o.uv = IN[i].uv;
                    o.col = fixed4(0.0, 0.0, 0.0, 1.0);
                    stream.Append(o);

                    int inext = (i + 1) % 3;
                    o.pos = UnityObjectToClipPos(IN[inext].vertex);
                    o.uv = IN[inext].uv;
                    o.col = fixed4(0.0, 0.0, 0.0, 1.0);
                    stream.Append(o);

                    o.pos = UnityObjectToClipPos(float4(centerPos, 1));
                    o.uv = centerTex;
                    o.col = fixed4(1.0, 1.0, 1.0, 1.0);
                    stream.Append(o);

                    stream.RestartStrip();
                }

                o.pos = UnityObjectToClipPos(IN[0].vertex);
                o.uv = IN[1].uv;
                o.col = fixed4(0.0, 0.0, 0.0, 1.0);
                stream.Append(o);

                o.pos = UnityObjectToClipPos(IN[1].vertex);
                o.uv = IN[1].uv;
                o.col = fixed4(0.0, 0.0, 0.0, 1.0);
                stream.Append(o);

                o.pos = UnityObjectToClipPos(IN[2].vertex);
                o.uv = IN[2].uv;
                o.col = fixed4(0.0, 0.0, 0.0, 1.0);
                stream.Append(o);

                stream.RestartStrip();
            }

            fixed4 frag (g2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * i.col;
                return col;
            }
            ENDCG
        }
    }
}
