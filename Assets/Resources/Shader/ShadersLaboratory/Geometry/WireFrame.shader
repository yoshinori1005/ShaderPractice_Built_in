Shader "Unlit/WireFrame"
{
    Properties
    {
        [PowerSlider(3.0)]
        _WireframeVal("Wireframe Value", Range(0, 0.34)) = 0.05
        _FrontColor("Front Color", Color) = (1, 1, 1, 1)
        _BackColor("Back Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        // 裏面のPass
        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _WireframeVal;
            fixed4 _BackColor;

            struct v2g
            {
                float4 pos : SV_POSITION;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float3 bary : TEXCOORD0;
            };

            v2g vert (appdata_base v)
            {
                v2g o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // 三角形1枚に対して、頂点3つの位置と値を設定
            [maxvertexcount(3)]
            void geom(triangle v2g IN[3],inout TriangleStream<g2f> stream)
            {
                g2f o;
                o.pos = IN[0].pos;
                o.bary = float3(1, 0, 0);
                stream.Append(o);

                o.pos = IN[1].pos;
                o.bary = float3(0, 0, 1);
                stream.Append(o);

                o.pos = IN[2].pos;
                o.bary = float3(0, 1, 0);
                stream.Append(o);
            }

            fixed4 frag (g2f i) : SV_Target
            {
                // 各ピクセルがどの辺に近いかを調べて、線に近くなければ表示しない
                if(! any(bool3(i.bary.x < _WireframeVal, i.bary.y < _WireframeVal, i.bary.z < _WireframeVal)))
                discard;

                return _BackColor;
            }
            ENDCG
        }

        // 表面のPass
        Pass
        {
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _WireframeVal;
            fixed4 _FrontColor;

            struct v2g
            {
                float4 pos : SV_POSITION;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float3 bary : TEXCOORD0;
            };

            v2g vert(appdata_base v)
            {
                v2g o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            // 三角形1枚に対して、頂点3つの位置と値を設定
            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> stream)
            {
                g2f o;
                o.pos = IN[0].pos;
                o.bary = float3(1, 0, 0);
                stream.Append(o);

                o.pos = IN[1].pos;
                o.bary = float3(0, 0, 1);
                stream.Append(o);

                o.pos = IN[2].pos;
                o.bary = float3(0, 1, 0);
                stream.Append(o);
            }

            fixed4 frag(g2f i) : SV_Target
            {
                // 各ピクセルがどの辺に近いかを調べて、線に近くなければ表示しない
                if(! any(bool3(i.bary.x < _WireframeVal, i.bary.y < _WireframeVal, i.bary.z < _WireframeVal)))
                discard;

                return _FrontColor;
            }
            ENDCG
        }
    }
}
