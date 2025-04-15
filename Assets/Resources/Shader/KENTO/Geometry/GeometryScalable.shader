Shader "Unlit/GeometryScalable"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _ScaleFactor("Scale Factor", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _Color;
            float _ScaleFactor;

            // 頂点シェーダーに渡ってくる頂点データ
            struct appdata
            {
                float4 vertex : POSITION;
            };

            // ジオメトリシェーダーからフラグメントシェーダーに渡すデータ
            struct g2f
            {
                float4 vertex : SV_POSITION;
            };

            // 頂点シェーダー
            appdata vert(appdata v)
            {
                return v;
            }

            // ジオメトリシェーダー
            // 引数の input は文字通り頂点シェーダーからの入力
            // stream は参照を渡して次の処理に値を受け渡す(TriangleStream<>で三角面を出力する)
            // 出力する頂点の最大数
            [maxvertexcount(3)]
            void geom (triangle appdata input[3], inout TriangleStream<g2f> stream)
            {
                // 1 枚のポリゴンの中心
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;

                // 繰り返す処理を畳み込んで最適化
                [unroll]
                for(int i = 0; i < 3; i ++)
                {
                    appdata v = input[i];
                    g2f o;
                    // 中心を起点にスケールを変える
                    v.vertex.xyz = (v.vertex - center) * (1.0 - _ScaleFactor) + center;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    stream.Append(o);
                }
            }

            // フラグメントシェーダー
            fixed4 frag (g2f i) : SV_Target
            {
                return _Color;
            }
            ENDCG
        }
    }
}
