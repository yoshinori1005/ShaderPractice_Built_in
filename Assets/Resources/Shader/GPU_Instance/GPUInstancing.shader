Shader "Unlit/GPUInstancing"
{
    Properties
    {
        // 色、陰影
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _AmbientLight("Ambient Light", Color) = (0.5, 0.5, 0.5, 1)
        _AmbientPower("Ambient Power", Range(0, 3)) = 1

        // 出現する表現で利用
        _Alpha("Alpha", Float) = 1
        _Size("Size", Float) = 1

        // 揺れ表現で利用
        _Frequency("Frequency", Range(0, 3)) = 1
        _Amplitude("Amplitude", Range(0, 1)) = 0.5
        _WaveSpeed("Wave Speed", Range(0, 20)) = 10
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            // ランダムな値を返す
            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            // パーリンノイズ
            float perlinNoise(float2 st)
            {
                float2 p = floor(st);
                float2 f = frac(st);
                float2 u = f * f * (3.0 - 2.0 * f);

                float v00 = rand(p + float2(0, 0));
                float v10 = rand(p + float2(1, 0));
                float v01 = rand(p + float2(0, 1));
                float v11 = rand(p + float2(1, 1));

                return lerp(
                lerp(dot(v00, f - float2(0, 0)), dot(v10, f - float2(1, 0)), u.x),
                lerp(dot(v01, f - float2(0, 1)), dot(v11, f - float2(1, 1)), u.x),
                u.y) + 0.5f;
            }

            struct appdata
            {
                float4 position : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            float4 _MainColor;
            float4 _AmbientLight;
            float _AmbientPower;
            float _Alpha;
            float _Size;
            float _Frequency;
            float _Amplitude;
            float _WaveSpeed;

            v2f vert (appdata v, uint instanceID : SV_InstanceID)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);

                float4x4 scaleMatrix = float4x4(
                _Size * clamp(rand(instanceID), 0.7, 1.0) * 1.2, 0, 0, 0,
                0, _Size * clamp(rand(instanceID), 0.7, 1.0) * 1.2, 0, 0,
                0, 0, _Size * clamp(rand(instanceID), 0.7, 1.0) * 1.2, 0,
                0, 0, 0, 1
                );
                v.position = mul(scaleMatrix, v.position);

                // 揺らめく表現
                // float2 factors = _Time.w * _WaveSpeed + v.position.xy * _Frequency;
                // float2 offsetFactor = sin(factors) * _Amplitude * (v.position.y) * perlinNoise(_Time * rand(instanceID));
                // v.position.xz += offsetFactor.x + offsetFactor.y;

                o.vertex = UnityObjectToClipPos(v.position);
                o.normal = v.normal;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = _MainColor;
                float t = dot(i.normal, _WorldSpaceLightPos0);
                t = max(0, t);
                float3 diffuseLight = _LightColor0 * t;
                col.rgb *= diffuseLight + _AmbientLight * _AmbientPower;
                col.a = _Alpha;
                return col;
            }
            ENDCG
        }
    }
}
