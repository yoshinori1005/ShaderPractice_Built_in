Shader "Unlit/WireframeWithoutDiagonal"
{
    Properties
    {
        [PowerSlider(3.0)]
        _WireframeWidth("Wireframe Width", Range(0, 0.5)) = 0.05
        _FrontColor("Front Color", Color) = (1, 1, 1, 1)
        _BackColor("Back Color", Color) = (0, 0, 0, 1)
        [Toggle] _RemoveDiag("Remove Diagonals", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        LOD 100

        // 裏面のPass
        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
            // C#スクリプトからこのキーワードを設定したい場合は、
            // "shader_feature "を "pragma_compile "に変更
            #pragma shader_feature __ _REMOVEDIAG_ON

            #include "UnityCG.cginc"

            float _WireframeWidth;
            fixed4 _BackColor;

            struct v2g
            {
                float4 worldPos : SV_POSITION;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float3 bary : TEXCOORD0;
            };

            v2g vert (appdata_base v)
            {
                v2g o;
                // ローカル座標をワールド座標に変換
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> stream)
            {
                float3 param = float3(0, 0, 0);

                // 3辺の長さを計算し、最も長い辺を調べ除外する
                #if _REMOVEDIAG_ON
                float edgeA = length(IN[0].worldPos - IN[1].worldPos);
                float edgeB = length(IN[1].worldPos - IN[2].worldPos);
                float edgeC = length(IN[2].worldPos - IN[0].worldPos);

                if(edgeA > edgeB && edgeA > edgeC)
                param.y = 1;
                else if(edgeB > edgeC && edgeB > edgeA)
                param.x = 1;
                else
                param.z = 1;
                #endif

                g2f o;
                o.pos = mul(UNITY_MATRIX_VP, IN[0].worldPos);
                o.bary = float3(1, 0, 0) + param;
                stream.Append(o);

                o.pos = mul(UNITY_MATRIX_VP, IN[1].worldPos);
                o.bary = float3(0, 0, 1) + param;
                stream.Append(o);

                o.pos = mul(UNITY_MATRIX_VP, IN[2].worldPos);
                o.bary = float3(0, 1, 0) + param;
                stream.Append(o);
            }

            fixed4 frag (g2f i) : SV_Target
            {
                // 各ピクセルがどの辺に近いかを調べて、線に近くなければ表示しない
                if(! any(bool3(i.bary.x < _WireframeWidth, i.bary.y < _WireframeWidth, i.bary.z < _WireframeWidth)))
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
            // C#スクリプトからこのキーワードを設定したい場合は、
            // "shader_feature "を "pragma_compile "に変更
            #pragma shader_feature __ _REMOVEDIAG_ON

            #include "UnityCG.cginc"

            float _WireframeWidth;
            fixed4 _FrontColor;

            struct v2g
            {
                float4 worldPos : SV_POSITION;
            };

            struct g2f
            {
                float4 pos : SV_POSITION;
                float3 bary : TEXCOORD0;
            };

            v2g vert(appdata_base v)
            {
                v2g o;
                // ローカル座標をワールド座標に変換
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            [maxvertexcount(3)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> stream)
            {
                float3 param = float3(0, 0, 0);

                // 3辺の長さを計算し、最も長い辺を調べ除外する
                #if _REMOVEDIAG_ON
                float edgeA = length(IN[0].worldPos - IN[1].worldPos);
                float edgeB = length(IN[1].worldPos - IN[2].worldPos);
                float edgeC = length(IN[2].worldPos - IN[0].worldPos);

                if(edgeA > edgeB && edgeA > edgeC)
                param.y = 1;
                else if(edgeB > edgeC && edgeB > edgeA)
                param.x = 1;
                else
                param.z = 1;
                #endif

                g2f o;
                o.pos = mul(UNITY_MATRIX_VP, IN[0].worldPos);
                o.bary = float3(1, 0, 0) + param;
                stream.Append(o);

                o.pos = mul(UNITY_MATRIX_VP, IN[1].worldPos);
                o.bary = float3(0, 0, 1) + param;
                stream.Append(o);

                o.pos = mul(UNITY_MATRIX_VP, IN[2].worldPos);
                o.bary = float3(0, 1, 0) + param;
                stream.Append(o);
            }

            fixed4 frag(g2f i) : SV_Target
            {
                // 各ピクセルがどの辺に近いかを調べて、線に近くなければ表示しない
                if(! any(bool3(i.bary.x <= _WireframeWidth, i.bary.y <= _WireframeWidth, i.bary.z <= _WireframeWidth)))
                discard;

                return _FrontColor;
            }
            ENDCG
        }
    }
}
