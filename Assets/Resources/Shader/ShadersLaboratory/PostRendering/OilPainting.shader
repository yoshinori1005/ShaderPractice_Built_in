Shader "Unlit/OilPainting"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Radius("Radius", Range(0, 10)) = 0
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
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;
            int _Radius;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                // 色の平均のための4つのグループ
                float3 mean[4] =
                {
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0}
                };

                // 色の分散のための4つのグループ
                float3 sigma[4] =
                {
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0},
                    {0, 0, 0}
                };

                float2 start[4] = {{ - _Radius, - _Radius}, { - _Radius, 0}, {0, - _Radius}, {0, 0}};

                float2 pos;
                float3 col;

                for(int k = 0; k < 4; k ++)
                {
                    for(int i = 0; i <= _Radius; i ++)
                    {
                        for(int j = 0; j <= _Radius; j ++)
                        {
                            pos = float2(i, j) + start[k];
                            col = tex2Dlod(_MainTex, float4(uv + float2(pos.x * _MainTex_TexelSize.x, pos.y * _MainTex_TexelSize.y), 0, 0)).rgb;
                            mean[k] += col;
                            sigma[k] += col * col;
                        }
                    }
                }

                float sigma2;

                float n = pow(_Radius + 1, 2);
                float4 color = tex2D(_MainTex, uv);
                float min = 1;

                // 各ブロックの色の分散を合計し、一番ばらつきの小さいブロックの平均色を使う
                for(int l = 0; l < 4; l ++)
                {
                    mean[l] /= n;
                    sigma[l] = abs(sigma[l] / n - mean[l] * mean[l]);
                    sigma2 = sigma[l].r + sigma[l].g + sigma[l].b;

                    if(sigma2 < min)
                    {
                        min = sigma2;
                        color.rgb = mean[l].rgb;
                    }
                }

                return color;
            }
            ENDCG
        }
    }
}
