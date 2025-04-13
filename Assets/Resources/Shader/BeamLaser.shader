Shader "Unlit/BeamLaser"
{
    Properties
    {
        _Color("Beam Color", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(0, 5)) = 1
        _BeamCount("Beam Count", Float) = 5
        _LineWidth("Line Width", Range(0.01, 0.2)) = 0.05
        _ScaleTop("Top Width Scale", Range(0.15, 5.0)) = 1.0
        _Length("Length Scale", Range(0.3, 5.0)) = 1
        _PulseSpeed("Puluse Speed", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha One
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
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 normal : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            fixed4 _Color;
            float _Intensity;
            float _BeamCount;
            float _LineWidth;
            float _ScaleTop;
            float _Length;
            float _PulseSpeed;

            v2f vert (appdata v)
            {
                v2f o;

                float3 pos = v.vertex.xyz;

                // 長さ制御
                pos.z *= _Length;

                // 底に行くほど拡がる
                float scaleFactor = lerp(1.0, _ScaleTop, pos.z);
                pos.xy *= scaleFactor;

                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, float4(pos, 1.0)).xyz;
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.pos = UnityObjectToClipPos(float4(pos, 1.0));
                return o;
            }

            // レインボーカラーをuv.x + 時間から算出
            fixed4 GetRainbowColor(float t)
            {
                float3 col = 0.5 + 0.5 * sin(float3(2.0, 2.0, 2.0) * t + float3(0.0, 2.0, 4.0));
                return fixed4(col, 1.0);
            }

            float rand(float2 co)
            {
                return frac(sin(dot(co.xy, float2(12.9898, 78.213))) * 43758.5453);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ビームラインアニメーション(U 方向スクロール)
                // float scrollU = step(0.9, sin(i.uv.x * _BeamCount + _Time.y * _PulseSpeed));
                float beam = step(1 - _LineWidth, frac(i.uv.x * _BeamCount + _Time.y * _PulseSpeed));

                // 線の中心からの距離
                // float centerDist = abs(scrollU - 0.5);

                // 線の太さ調整
                // float beam = smoothstep(_LineWidth, 0.0, centerDist);

                // ノイズの追加
                float noise = rand(i.uv.x * 10.0);
                beam *= 0.8 + 0.2 * noise;

                // レインボーカラー取得
                fixed4 rainbow = GetRainbowColor(i.uv * 4.0 + _Time.y * 2.0);

                // 点滅エフェクト
                // float pulse = sin(_Time.y * _PulseSpeed + i.uv.x * 20.0);
                // beam *= saturate(pulse);

                // フェードアウト
                float fade = 1.0 - i.uv.y;

                fixed4 col = rainbow * _Intensity;

                return col * beam * fade;
            }
            ENDCG
        }
    }
}
