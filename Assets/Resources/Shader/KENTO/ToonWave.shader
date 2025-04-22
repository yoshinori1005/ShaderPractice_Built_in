Shader "Unlit/ToonWave"
{
    Properties
    {
        [HDR] _WaterColor("Water Color", Color) = (0.09, 0.89, 1, 1)
        _FoamColor("Foam Color", Color) = (1, 1, 1, 1)
        _EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
        _SquareNum("Square Num", int) = 5
        _WaveSpeed("Wave Speed", Range(0.01, 10)) = 1
        _FoamPower("Foam Power", Range(0, 1)) = 0.6
        _DepthFactor("Depth Factor", Float) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

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
                float4 screenPos : TEXCOORD1;
            };

            float2 random2(float2 st)
            {
                st = float2(
                dot(st, float2(127.1, 311.7)),
                dot(st, float2(269.5, 183.3))
                );
                return - 1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            uniform sampler2D _CameraDepthTexture;
            float4 _WaterColor;
            float4 _FoamColor;
            float4 _EdgeColor;
            int _SquareNum;
            float _WaveSpeed;
            float _FoamPower;
            float _DepthFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 st = i.uv;
                st *= _SquareNum;

                float2 ist = floor(st);
                float2 fst = frac(st);

                float4 waveColor = 0;
                float m_dist = 100;

                for(int y =- 1; y <= 1; y ++)
                {
                    for(int x =- 1; x <= 1; x ++)
                    {
                        float2 neighbor = float2(x, y);

                        float2 p = 0.5 + 0.5 * sin(random2(ist + neighbor) + _Time.y * _WaveSpeed);

                        float2 diff = neighbor + p - fst;

                        m_dist = min(m_dist, length(diff));

                        waveColor = lerp(_WaterColor, _FoamColor, smoothstep(1 - _FoamPower, 1, m_dist));
                    }
                }

                // 深度の計算
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos));
                float depth = LinearEyeDepth(depthSample);
                float screenDepth = depth - i.screenPos.w;
                float edgeLine = 1 - saturate(_DepthFactor * screenDepth);
                float4 finalColor = lerp(waveColor, _EdgeColor, edgeLine);

                return finalColor;
            }
            ENDCG
        }
    }
}
