Shader "Unlit/SimpleNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseScale("Noise Scale", Range(0, 50)) = 10
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

            float unity_noise_randomValue(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float unity_noise_interpolate(float a, float b, float t)
            {
                return (1.0 - t) * a + (t * b);
            }

            float unity_valueNoise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);

                float2 c00 = i + float2(0.0, 0.0);
                float2 c10 = i + float2(1.0, 0.0);
                float2 c01 = i + float2(0.0, 1.0);
                float2 c11 = i + float2(1.0, 1.0);

                float r0 = unity_noise_randomValue(c00);
                float r1 = unity_noise_randomValue(c10);
                float r2 = unity_noise_randomValue(c01);
                float r3 = unity_noise_randomValue(c11);

                float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
                float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
                float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);

                return t;
            }

            float Unity_SimpleNoise_float(float2 UV, float Scale)
            {
                float t = 0.0;

                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3 - 0));
                t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3 - 1));
                t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3 - 2));
                t += unity_valueNoise(float2(UV.x * Scale / freq, UV.y * Scale / freq)) * amp;

                return t;
            }

            sampler2D _MainTex;
            float _NoiseScale;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャのサンプリング
                float4 texColor = tex2D(_MainTex, Unity_SimpleNoise_float(i.uv, _NoiseScale));
                return texColor;
            }
            ENDCG
        }
    }
}
