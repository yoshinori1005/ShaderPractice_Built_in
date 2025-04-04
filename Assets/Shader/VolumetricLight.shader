Shader "Unlit/VolumetricLight"
{
    Properties
    {
        _Color("Light Color", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(0, 10)) = 3
        _FadeDistance("Fade Distance", Range(0, 5)) = 3
        _EdgeFade("Edge Fade", Range(0, 5)) = 2.5
        [Space] _NoiseScale("Noise Scale", Range(0.1, 10)) = 7
        _Contrast("Noise Contrast", Range(0, 1)) = 0.5
        _NoiseOctaves("Noise Octaves", Range(1, 4)) = 3
        _NoisePersistence("Noise Persistence", Range(0, 1)) = 0.5
        [Toggle] _ReverseNoiseToggle("Reverse Noise", Float) = 0
        _NoiseSpeed("Noise Speed", Range(0, 5)) = 0.5
        _NoiseFactor("Noise Factor", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
            };

            // ノイズパラメーター
            float _NoiseScale;
            float _Contrast;
            int _NoiseOctaves;
            float _NoisePersistence;
            float _ReverseNoiseToggle;
            float _NoiseSpeed;
            float _NoiseFactor;

            // 基本パラメーター
            float4 _Color;
            float _Intensity;
            float _FadeDistance;
            float _EdgeFade;

            // Perlin - like hash function
            float hash(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
            }

            // Gradient noise function
            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash(i);
                float b = hash(i + float2(1.0, 0.0));
                float c = hash(i + float2(0.0, 1.0));
                float d = hash(i + float2(1.0, 1.0));

                float2 u = f * f * (3.0 - 2.0 * f);
                return lerp(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
            }

            // fBm noise (Fractional Brownian Motion)
            float fbm(float2 p)
            {
                float value = 0.0;
                float amplitude = 1.0;
                float frequency = 1.0;

                for(int i = 0; i < _NoiseOctaves; i ++)
                {
                    value += noise(p * frequency) * amplitude;
                    frequency *= 2.0;
                    amplitude *= _NoisePersistence;

                }
                return value;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float sign = (_ReverseNoiseToggle > 0.5) ? - 1.0 : 1.0;
                float2 noiseUV = i.uv * _NoiseScale + _Time.y * _NoiseSpeed * sign;
                float noiseValue = fbm(noiseUV);

                noiseValue = saturate(noiseValue - 0.5) * _Contrast;

                float distanceFactor = 1.0 - saturate(1.0 - i.uv.y / _FadeDistance);
                float edgeFade = smoothstep(1.0, 1.0 - _EdgeFade, abs(i.uv.x * 2.0 - 1.0));
                float noiseEffect = lerp(1.0, noiseValue, _NoiseFactor);
                float alpha = distanceFactor * edgeFade * noiseEffect * _Intensity;

                return fixed4(_Color.rgb, alpha);
            }
            ENDCG
        }
    }
}
