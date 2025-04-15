Shader "Unlit/RandomVertexMove"
{
    Properties
    {
        // 頂点の動きの幅
        _VertexMoveRange("Vertex Move Range", Range(0, 5)) = 0.025
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

            // ランダムな値を返す
            float rand(float2 co)
            {
                // 引数はシードルと呼ばれる、同じ値を渡せば同じものを返す
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float _VertexMoveRange;

            v2f vert (appdata v)
            {
                v2f o;
                // ランダムな値生成
                float random = rand(v.vertex.xy);
                // ランダムな値を sin 関数の引数に渡して
                // 経過時間を掛け合わせることで各頂点にランダムな変化を与える
                float4 vert = float4(v.vertex.xyz + v.vertex.xyz * sin(1 + _Time.w * random) * _VertexMoveRange, v.vertex.w);
                o.vertex = UnityObjectToClipPos(vert);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // シード値に同じ値を渡すと全部同じ値になるので
                // 引数のシード値に別の値を渡す
                float r = rand(i.vertex.xy + 0.1);
                float g = rand(i.vertex.xy + 0.2);
                float b = rand(i.vertex.xy + 0.3);

                return float4(r, g, b, 1);
            }
            ENDCG
        }
    }
}
