Shader "Unlit/UnlitToonLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _RampTex("Ramp Texture", 2D) = "white"{}
        [Space] _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularStrength("Specular Strength", Range(0, 1)) = 0.5
        [Space] _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth("Outline Width", Range(0.0, 0.1)) = 0.02
        [Space] _RimColor("Rim Light Color", Color) = (1, 1, 1, 1)
        _RimPower("Rim Light Power", Range(0, 10)) = 3
        [Space] _EmissionColor("Emission Color", Color) = (0, 0, 0, 1)
        _EmissionStrength("Emission Strength", Range(0, 10)) = 1
        [Space] _MatCap("MatCap Texture", 2D) = "gray"{}
        _MatCapStrength("MatCap Strength", Range(0, 1)) = 0.3

        // 反射キューブマップやToon階調の係数
        // _Cube("Reflection Cubemap", Cube) = ""{}
        // _ReflectPower("Reflection Strenght", Range(0, 1)) = 0.2
        // _ShadeThreshold1("Shadow Threshold", Range(0, 1)) = 0.5
        // _ShadeThreshold2("Midlight Threshold", Range(0, 1)) = 0.75
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 300

        // アウトライン描画用パス
        Pass
        {
            Tags{"LightMode" = "Always"}
            ZWrite On
            ZTest LEqual
            Cull Front // 表面が後ろ側に描画されるように

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            float4 _OutlineColor;
            float _OutlineWidth;

            v2f vert(appdata v)
            {
                v2f o;
                // 法線方向に押し出しを加えて外形を大きくする
                float3 norm = normalize(v.normal);
                v.vertex.xyz += norm * _OutlineWidth;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _OutlineColor; // アウトラインの色の設定
            }
            ENDCG
        }

        // メインシェーダー
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 viewDir : TEXCOORD3;
            };

            // メインパラメーター
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _Color;

            // ランプテクスチャ
            sampler2D _RampTex;

            // スペキュラーパラメーター
            float4 _SpecularColor;
            float _SpecularStrength;

            // リムライトパラメーター
            float4 _RimColor;
            float _RimPower;

            // 発光パラメーター
            float4 _EmissionColor;
            float _EmissionStrength;

            // マットキャップパラメーター
            sampler2D _MatCap;
            float _MatCapStrength;

            // 反射キューブマップとライト係数
            // samplerCUBE _Cube;
            // float _ReflectPower;
            // float _ShadeThreshold1;
            // float _ShadeThreshold2;

            v2f vert (appdata v)
            {
                v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                float3 worldNormal = UnityObjectToWorldNormal(v.normal);

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.worldNormal = worldNormal;
                o.worldPos = worldPos;
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ライティング情報
                float3 N = normalize(i.worldNormal);
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                // ライト方向と法線方向の内積で明るさを決める
                // float NdotL = dot(N, L);

                // Lambert によるライティング値
                float NdotL = saturate(dot(N, L));

                // Toon シェーディングのランプ
                float3 ramp = tex2D(_RampTex, float2(NdotL, 0)).rgb;

                // // 段階的 Toon ライト処理(3段階)
                // fixed lightLevel;
                // if(NdotL < _ShadeThreshold1)
                // lightLevel = 0.2; // shadow
                // else if(NdotL < _ShadeThreshold2)
                // lightLevel = 0.5; // mid
                // else
                // lightLevel = 1.0; // highLight

                // テクスチャと色
                fixed4 tex = tex2D(_MainTex, i.uv);
                // fixed3 baseCol = tex.rgb * _Color.rgb * lightLevel;
                fixed3 baseCol = tex.rgb * _Color.rgb * ramp;

                // // Cubemap 反射の取得
                // fixed3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                // fixed3 refl = reflect(- V, N);
                // fixed3 cubeCol = texCUBE(_Cube, refl).rgb;

                // MatCap
                float3 r = reflect(- i.viewDir, N);
                float2 matcapUV = r.xy * 0.5 + 0.5;
                matcapUV.y = 1.0 - matcapUV.y; // Y反転(Unity仕様)
                float3 matcap = tex2D(_MatCap, matcapUV).rgb;

                // ベースと反射のブレンド
                // fixed3 finalCol = lerp(baseCol, cubeCol, _ReflectPower);

                // 最終的な色の計算
                float3 finalCol = lerp(baseCol, matcap, _MatCapStrength);

                // エミッション(発光)の追加
                fixed4 emissionColor = _EmissionColor * _EmissionStrength;
                finalCol += emissionColor.rgb;

                // スペキュラーハイライト
                float3 H = normalize(i.viewDir + L); // 視線方向とライト方向の半ベクトル
                float spec = pow(saturate(dot(N, H)), 16); // スペキュラーハイライトの計算
                finalCol += _SpecularStrength * spec * _SpecularColor.rgb; // スペキュラーハイライトの追加

                // リムライティング(縁光)
                float rim = saturate(dot(N, i.viewDir));
                finalCol += _RimColor.rgb * (1.0 - pow(rim, _RimPower)); // リムライティングの強さ

                return fixed4(finalCol, 1.0);
            }
            ENDCG
        }
    }
}
