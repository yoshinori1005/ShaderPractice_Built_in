Shader "Unlit/SimpleGeometryStencil"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Ref("Ref", Int) = 1
        _PositionFactor("Position Factor", Range(0, 1)) = 0.5
        _RotationFactor("Rotation Factor", Range(0, 1)) = 0.5
        _ScaleFactor("Scale Factor", Range(0, 1)) = 0.5
    }
    SubShader
    {
        // ステンシルバッファに関して
        Stencil
        {
            // ステンシルの値
            Ref [_Ref]

            // ステンシルバッファの値の判定方法
            // Equalなので描画しようとしているピクセルのステンシルバッファが
            // Refと同じ場合、そのピクセルを描画の処理対象とする
            Comp Equal
        }

        Tags { "RenderType" = "Opaque" }
        LOD 100

        // 両面描画
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _PositionFactor;
            float _RotationFactor;
            float _ScaleFactor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 localPos : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            struct g2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD1;
            };

            // 回転させる
            // pは回転させたい座標、angleは回転させる角度、axisはどの軸を元に回転させるか
            float3 rotate(float3 p, float angle, float3 axis)
            {
                float3 a = normalize(axis);
                float s = sin(angle);
                float c = cos(angle);
                float r = 1.0 - c;
                float3x3 m = float3x3(
                a.x * a.x * r + c, a.y * a.x * r + a.z * s, a.z * a.x * r - a.y * s,
                a.x * a.y * r - a.z * s, a.y * a.y * r + c, a.z * a.y * r + a.x * s,
                a.x * a.z * r + a.y * s, a.y * a.z * r - a.x * s, a.z * a.z * r + c
                );

                return mul(m, p);
            }

            // ランダムな値を返す
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            appdata vert (appdata v)
            {
                appdata o;
                // ジオメトリーシェーダーで頂点を動かす前に
                // 描画しようとしているピクセルのローカル座標を保持しておく
                o.localPos = v.vertex.xyz;
                o.uv = v.uv;
                return v;
            }

            // ジオメトリシェーダー
            [maxvertexcount(3)]
            void geom(triangle appdata input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> stream)
            {
                // 法線を計算
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                // 1枚のポリゴンの中心
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                float random = 2.0 * rand(center.xy) - 0.5;
                float3 r3 = random.xxx;

                [unroll]
                for(int i = 0; i < 3; i ++)
                {
                    appdata v = input[i];
                    g2f o;

                    // ジオメトリーの移動・回転・拡大縮小処理
                    v.vertex.xyz = center + rotate(
                    v.vertex.xyz - center,
                    (pid * _Time.y) * _RotationFactor,
                    r3
                    );
                    v.vertex.xyz = center + (v.vertex.xyz - center) * (1.0 - _ScaleFactor);
                    v.vertex.xyz += normal * _PositionFactor * abs(r3);

                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;

                    stream.Append(o);
                }
            }

            float4 frag (g2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
