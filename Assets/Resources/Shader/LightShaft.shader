Shader "Unlit/LightShaft"
{
    Properties
    {
        [Header(Main Category)]
        _Color("Light Color", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(0, 5)) = 1
        [Header(Shape Category)]
        _Length("Length Scale", Range(0.3, 5.0)) = 1.0
        _Width("Width Scale", Range(0.15, 5.0)) = 1.0
        [Header(Fade)]
        _TipFade("Tip Fade Strength", Range(0.0, 1.0)) = 0
        [Header(Pulse)]
        _PulseSpeed("Pulse Speed", Float) = 0
        [Header(Noise Category)]
        _NoiseScale("Noise Scale", Float) = 5.0
        _NoiseSpeed("Noise Scroll Speed", Vector) = (0.1, 0.1, 0, 0)
        _NoiseIntensity("Noise Intensity", Range(0, 1)) = 0
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
        Cull Front

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
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _Color;
            float _Intensity;
            float _Length;
            float _Width;
            float _TipFade;
            float _EdgeFade;
            float _PulseSpeed;

            float _NoiseScale;
            float4 _NoiseSpeed;
            float _NoiseIntensity;

            // パーリンノイズベースのfbm
            float hash(float2 p)
            {
                return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
            }

            float noise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);
                float a = hash(i);
                float b = hash(i + float2(1.0, 0.0));
                float c = hash(i + float2(0.0, 1.0));
                float d = hash(i + float2(1.0, 1.0));
                float2 u = f * f * (3.0 - 2.0 * f);

                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            float fbm(float2 p)
            {
                float v = 0.0;
                float a = 0.5;
                for(int i = 0; i < 5; i ++)
                {
                    v += a * noise(p);
                    p *= 2.0;
                    a *= 0.5;
                }

                return v;
            }

            v2f vert (appdata v)
            {
                v2f o;
                float3 pos = v.vertex.xyz;

                // ライトシャフトの長さをZ方向にスケーリング
                pos.z *= _Length;

                // 底面に近いほどスケーリングが大きくなる(円錐拡縮)
                float scaleFactor = lerp(1.0, _Width, pos.z);
                pos.xy *= scaleFactor;
                // pos.y *= scaleFactor;

                o.uv = v.uv;
                o.worldPos = mul(unity_ObjectToWorld, float4(pos, 1.0).xyz);
                o.pos = UnityObjectToClipPos(float4(pos, 1.0));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // グラデーション(V方向で色変化)
                float t = i.uv.y;

                // 先端フェード(透明度をV方向で減衰)
                float fade = saturate((1.0 - t) - _TipFade);

                // 脈動(点滅表現)
                float pulse = 0.5 + 0.5 * sin(_Time.y * _PulseSpeed);

                // fbm ノイズ(UV スクロールを含む)
                float2 noiseUV = i.uv * _NoiseScale + _Time.y * _NoiseSpeed.xy;
                float noiseVal = fbm(noiseUV);

                // フレネル(視野角でエッジぼかし)
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 normal = float3(0, 0, 1);
                float fresnel = pow(1.0 - saturate(dot(normalize(normal), normalize(viewDir))), 3.0);

                fixed4 col = _Color * _Intensity;
                // 塵ノイズの明滅効果
                col.rgb *= (1.0 + noiseVal * _NoiseIntensity);
                // フレネルで側面ぼかし
                col.a *= fade * pulse * (0.5 + 0.5 * fresnel);

                return col;
            }
            ENDCG
        }
    }
}
