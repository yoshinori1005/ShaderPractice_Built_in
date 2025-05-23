Shader "Unlit/GlitchJaggy"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _FrameRate("FrameRate", Range(0.1, 30)) = 15
        _Frequency("Frequency", Range(0, 1)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" }
        LOD 100

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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _FrameRate;
            float _Frequency;

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.233))) * 43758.5453);
            }

            float perlinNoise(fixed2 st)
            {
                fixed2 p = floor(st);
                fixed2 f = frac(st);
                fixed2 u = f * f * (3.0 - 2.0 * f);

                float v00 = rand(p + fixed2(0, 0));
                float v10 = rand(p + fixed2(1, 0));
                float v01 = rand(p + fixed2(0, 1));
                float v11 = rand(p + fixed2(1, 1));

                return lerp(lerp(dot(v00, f - fixed2(0, 0)), dot(v10, f - fixed2(1, 0)), u.x),
                lerp(dot(v01, f - fixed2(0, 1)), dot(v11, f - fixed2(1, 1)), u.x),
                u.y) + 0.5f;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                float posterize1 = floor(frac(perlinNoise(_SinTime) * 10) / (1 / _FrameRate)) * (1 / _FrameRate);
                float posterize2 = floor(frac(perlinNoise(_SinTime) * 5) / (1 / _FrameRate)) * (1 / _FrameRate);

                float noiseX = (2.0 * rand(posterize1) - 0.5) * 0.1;

                float frequency = step(rand(posterize2), _Frequency);
                noiseX *= frequency;

                float noiseY = 2.0 * rand(posterize1) - 0.5;

                float glitchLine1 = step(uv.y - noiseY, rand(uv));
                float glitchLine2 = step(uv.y + noiseY, noiseY);
                float glitch = saturate(glitchLine1 - glitchLine2);

                uv.x = lerp(uv.x, uv.x + noiseX, glitch);

                float4 glitchColor = tex2D(_MainTex, uv);

                return glitchColor;
            }
            ENDCG
        }
    }
}
