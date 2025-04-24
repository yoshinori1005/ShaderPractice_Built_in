Shader "Unlit/DistortionWave"
{
    Properties
    {
        [HDR] _WaterColor("Water Color", Color) = (0, 0.71, 0.74, 0.7)
        _FoamColor("Foam Color", Color) = (1, 1, 1, 1)
        _EdgeColor("Edge Color", Color) = (0.32, 0.66, 0.78, 1)
        _SquareNum("Square Num", int) = 5
        _DistortionPower("Distortion Power", Range(0, 0.1)) = 0
        _DepthFactor("Depth Factor", Range(0, 10)) = 1
        _WaveSpeed("Wave Speed", Range(0.01, 10)) = 1
        _FoamPower("Foam Power", Range(0, 1)) = 0.6
        _Frequency("Frequency", Range(0, 3)) = 1
        _Amplitude("Amplitude", Range(0, 1)) = 0.5
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

        GrabPass
        {
            "_GrabPassTextureForDistortionWave"
        }

        // パスを跨いで利用できる変数や関数
        CGINCLUDE

        float _WaveSpeed;
        float _Frequency;
        float _Amplitude;

        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"

        float vertex_wave(float2 vert, float waveSpeed, float amplitude, float frequency)
        {
            float2 factors = _Time.x * waveSpeed + vert * frequency;
            float2 offsetYFactors = sin(factors) * amplitude;
            return offsetYFactors.x + offsetYFactors.y;
        }
        ENDCG

        // 揺らぎの表現を頑張る(描画結果を利用する)
        Pass
        {
            CGPROGRAM

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 grabPos : TEXCOORD1;
                float4 srcPos : TEXCOORD2;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _GrabPassTextureForDistortionWave;
            float _DistortionPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.srcPos = ComputeScreenPos(o.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float2 distortion = sin(i.uv.y * 50 * _Time.w) * 0.1f;
                distortion *= _DistortionPower;
                float4 depthUV = i.grabPos;

                depthUV.xy = i.grabPos.xy + distortion * 1.5f;

                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(depthUV));

                float backgroundDepth = LinearEyeDepth(depthSample);

                float surfaceDepth = UNITY_Z_0_FAR_FROM_CLIPSPACE(i.srcPos.z);

                float depthDiff = saturate(backgroundDepth - surfaceDepth);

                float2 uv = (i.grabPos.xy + distortion * depthDiff) / i.grabPos.w;

                return tex2D(_GrabPassTextureForDistortionWave, uv);
            }
            ENDCG
        }

        // 泡の表現
        Pass
        {
            CGPROGRAM

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 srcPos : TEXCOORD1;
            };

            sampler2D _CameraDepthTexture;
            float4 _WaterColor;
            float4 _FoamColor;
            float4 _EdgeColor;
            int _SquareNum;
            float _DepthFactor;
            float _FoamPower;

            float2 random2(float2 st)
            {
                st = float2(
                dot(st, float2(127.1, 311.7)),
                dot(st, float2(269.5, 183.3))
                );
                return - 1.0 + 2.0 * frac(sin(st) * 43758.5453123);
            }

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.srcPos = ComputeScreenPos(o.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                float2 st = i.uv;
                // 格子状のマス目作成 UVにかけた数分だけ同じUVが繰り返し展開される
                st *= _SquareNum;

                // 各マス目の起点
                float2 ist = floor(st);
                // 各マス目の起点からの描画したい位置
                float2 fst = frac(st);

                float4 waveColor = 0;
                float m_dist = 100;

                // 自身含む周囲のマスを探索
                for(int y =- 1; y <= 1; y ++)
                {
                    for(int x =- 1; x <= 1; x ++)
                    {
                        // 周辺1×1のエリア
                        float2 neighbor = float2(x, y);

                        // 点のxy座標
                        float2 p = 0.5 + 0.5 * sin(random2(ist + neighbor) + _Time.x * _WaveSpeed);

                        // 点と処理対象のピクセルとの距離ベクトル
                        float2 diff = neighbor + p - fst;

                        m_dist = min(m_dist, length(diff));

                        waveColor = lerp(_WaterColor, _FoamColor, smoothstep(1 - _FoamPower, 1, m_dist));
                    }
                }

                // 深度テクスチャをサンプリング
                float4 depthSample = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.srcPos));
                float screenDepth = LinearEyeDepth(depthSample) - i.srcPos.w;
                float edge = 1 - saturate(_DepthFactor * screenDepth);
                float4 color = lerp(waveColor, _EdgeColor, edge);
                return color;
            }
            ENDCG
        }
    }
}
