Shader "Unlit/ToonLit"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _ShadowTex("Shadow Texture", 2D) = "white"{}
        _Strength("Shadow Strength", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Name "TOON"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            sampler2D _ShadowTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _Strength;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float2 uv : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 法線方向のベクトル
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 1つ目のライトのベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                // ワールド座標系の法線を正規化
                float3 N = normalize(i.worldNormal);

                // 内積でLerpの補間値を計算(0以下の場合のみ補間値を利用する)
                float interpolation = step(dot(N, L), 0);

                // 絶対値で正数にすることで影の領域を塗分ける
                float2 absD = abs(dot(N, L));

                // 影の領域のテクスチャをサンプリング
                float3 shadowColor = tex2D(_ShadowTex, absD).rgb;

                // メインのテクスチャのサンプリング
                float3 mainColor = tex2D(_MainTex, i.uv).rgb;

                // 補間値を用いて色を塗分け(影の強さ : 影テクスチャの強さを調整)
                float3 finalColor = lerp(
                mainColor,
                shadowColor * (1 - _Strength) * mainColor,
                interpolation
                );
                finalColor *= _Color.rgb;

                return float4(finalColor, 1);
            }
            ENDCG
        }
    }
}
