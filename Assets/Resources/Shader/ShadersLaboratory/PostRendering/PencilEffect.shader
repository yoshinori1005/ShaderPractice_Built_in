Shader "Unlit/PencilEffect"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _GradThreshold("Gradient Threshold", Range(0.00001, 0.01)) = 0.01
        _ColorThreshold("Color Threshold", Range(0, 1)) = 0.5
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
            #pragma target 4.0

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _GradThreshold;
            float _ColorThreshold;
            float _Intensity;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 screenUV : TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // フラグメントシェーダーでスクリーン上の位置がわかるようにする
                o.screenUV = ComputeScreenPos(o.pos);
                return o;
            }

            #define PI2 6.28318530717959
            #define STEP 2.0
            #define RANGE 16.0
            #define ANGLENUM 4.0
            #define GRADTHRESH 0.01
            #define SENSITIVITY 10.0

            float4 getCol(float2 pos)
            {
                return tex2D(_MainTex, pos / _ScreenParams.xy);
            }

            // 輝度(グレースケール)の計算関数
            // 色を明るさ(白黒)に変換、人の目に近い見え方でRGBの重みづけ
            float getVal(float2 pos)
            {
                float4 c = getCol(pos);
                return dot(c.xyz, float3(0.2126, 0.7152, 0.0722));
            }

            // グラデーション(エッジ)の検出を行う関数
            // 画面上の隣り合うピクセルとの差から、変化の方向、強さ(輪郭)を計算
            float2 getGrad(float2 pos, float delta)
            {
                float2 d = float2(delta, 0.0);
                return float2(getVal(pos + d.xy) - getVal(pos - d.xy),
                getVal(pos + d.yx) - getVal(pos - d.yx)) / delta / 2.0;
            }

            void pR(inout float2 p, float a)
            {
                p = cos(a) * p + sin(a) * float2(p.y, - p.x);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenUV = i.screenUV.xy / i.screenUV.w;
                float2 screenPos = float2(
                i.screenUV.x * _ScreenParams.x,
                i.screenUV.y * _ScreenParams.y
                );
                float weight = 1.0;

                // 角度を変えてエッジをチェック(線の向きを表現)
                // 複数方向に線を走らせて、どの向きに輪郭があるかを調べる
                // 実際に線を引く代わりに、そこに線があるべきかどうかの重みづけをする
                for(int j = 0; j < ANGLENUM; j ++)
                {
                    float2 dir = float2(1.0, 0.0);
                    pR(dir, j * PI2 / (2.0 * ANGLENUM));

                    float2 grad = float2(- dir.y, dir.x);

                    for(int i =- RANGE; i <= RANGE; i += STEP)
                    {
                        float2 b = normalize(dir);
                        float2 pos2 = screenPos + float2(b.x, b.y) * i;

                        if(pos2.y<0.0||pos2.x<0.0||pos2.x>_ScreenParams.x||pos2.y>_ScreenParams.y)
                        continue;

                        float2 g = getGrad(pos2, 1.0);

                        if(sqrt(dot(g, g)) < _GradThreshold)
                        continue;

                        // 黒い線を重ねる処理
                        // 輪郭があるほどweightを小さくする(黒くなる)
                        // 輪郭がない場所は白くなる(weightが1.0のまま)
                        weight -= pow(abs(dot(normalize(grad), normalize(g))), SENSITIVITY) / floor((2.0 * RANGE + 1.0) / STEP) / ANGLENUM;
                    }
                }

                float4 col = getCol(screenPos);
                // 色の補正と最終合成
                // 背景色(元の画像)に白を混ぜて明るく調整
                // weightによって黒と背景色の割合を決める(鉛筆で描いたような線の濃さ)
                float4 background = lerp(col, float4(1.0, 1.0, 1.0, 1.0), _ColorThreshold);

                return lerp(float4(0.0, 0.0, 0.0, 0.0), background, weight);
            }
            ENDCG
        }
    }
}
