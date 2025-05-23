Shader "Unlit/GeometryTest"
{
    Properties
    {
        _PositionFactor("Position Factor", Range(0.0, 1.0)) = 0.5
        _RotationFactor("Rotation Factor", Range(0.0, 1.0)) = 0.5
        _ScaleFactor("Scale Factor", Range(0.0, 1.0)) = 0.5
    }
    SubShader
    {
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

            float _PositionFactor;
            float _RotationFactor;
            float _ScaleFactor;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 localPos : TEXCOORD0;
            };

            appdata vert (appdata v)
            {
                appdata o;
                // ジオメトリシェーダーで頂点を動かす前に
                // 描画しようとしているピクセルのローカル座標を保存
                o.localPos = v.vertex.xyz;
                return v;
            }

            struct g2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
            };

            // 回転させる
            // p は回転させたい座標、angle は回転させる角度、 axis はどの軸を元に回転させるか
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

            // ジオメトリシェーダー
            [maxvertexcount(3)]
            void geom(triangle appdata input[3], uint pid : SV_PrimitiveID, inout TriangleStream<g2f> stream)
            {
                // 法線を計算
                float3 vec1 = input[1].vertex - input[0].vertex;
                float3 vec2 = input[2].vertex - input[0].vertex;
                float3 normal = normalize(cross(vec1, vec2));

                // 1 枚のポリゴンの中心
                float3 center = (input[0].vertex + input[1].vertex + input[2].vertex) / 3;
                float random = 2.0 * rand(center.xy) - 0.5;
                float r3 = random.xxx;

                [unroll]
                for (int i = 0; i < 3; i ++)
                {
                    appdata v = input[i];
                    g2f o;
                    // 移動に利用する位置ベクトルを保持
                    // 負の値は法線と逆方向に移動してしまうので絶対値利用
                    // float3 currentPos = normal * _PositionFactor * abs(r3);
                    // 法線ベクトルに沿って頂点を移動
                    // v.vertex.xyz += currentPos;
                    // 回転させる
                    // v.vertex.xyz = currentPos + center + rotate(
                    // v.vertex.xyz - center - currentPos,
                    // (pid + _Time.y) * _RotationFactor,
                    // r3
                    //);
                    // 中心を起点にスケールを変える
                    // v.vertex.xyz = currentPos + center + (v.vertex.xyz - center - currentPos) * (1.0 - _ScaleFactor);

                    v.vertex.xyz = center + rotate(
                    v.vertex.xyz - center,
                    (pid + _Time.y) * _RotationFactor,
                    r3
                    );
                    v.vertex.xyz = center + (v.vertex.xyz - center) * (1.0 - _ScaleFactor);
                    v.vertex.xyz += normal * _PositionFactor * abs(r3);

                    // NGパターン
                    // v.vertex.xyz += normal * _PositionFactor * abs(r3);
                    // v.vertex.xyz = center + rotate(
                    // v.vertex.xyz - center,
                    // (pid + _Time.y) * _RotationFactor,
                    // r3
                    //);
                    // v.vertex.xyz = center + (v.vertex.xyz - center) * (1.0 - _ScaleFactor);

                    o.vertex = UnityObjectToClipPos(v.vertex);

                    // ランダムな値
                    // シード値にワールド座標を利用すると移動するたびに色が変わるのでローカル座標を利用
                    float r = rand(v.localPos.xy);
                    float g = rand(v.localPos.xz);
                    float b = rand(v.localPos.yz);

                    // NGパターン
                    // float r = rand(v.vertex.xy);
                    // float g = rand(v.vertex.xz);
                    // float b = rand(v.vertex.yz);

                    o.color = fixed4(r, g, b, 1);
                    stream.Append(o);
                }
            }

            // フラグメントシェーダー
            fixed4 frag (g2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
