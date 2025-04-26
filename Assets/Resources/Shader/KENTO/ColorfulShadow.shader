Shader "Unlit/ColorfulShadow"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _ShadowColor("Shadow Color", Color) = (0, 0, 0, 1)
        _ShadowTex("Shadow Texture", 2D) = "white"{}
        _ShadowIntensity("Shadow Intensity", Range(0, 1)) = 0.6
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        CGINCLUDE
        #pragma vertex vert
        #pragma fragment frag

        #include "UnityCG.cginc"
        ENDCG

        // メインカラーのパス
        Pass
        {
            CGPROGRAM

            float4 _MainColor;

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // RGBAにそれぞれのプロパティを当てはめる
                return float4(_MainColor);
            }
            ENDCG
        }

        // 影を塗りこむパス
        Pass
        {
            Tags
            {
                "Queue" = "Geometry"
                "LightMode" = "ForwardBase"
            }

            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma multi_compile_fwdbase

            #include "AutoLight.cginc"

            sampler2D _ShadowTex;
            float4 _ShadowTex_ST;
            float4 _ShadowColor;
            float _ShadowIntensity;

            // グローバル変数
            float _ShadowDistance;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 shadow_uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 worldPos : WORLD_POS;
                float2 shadow_uv : TEXCOORD0;
                SHADOW_COORDS(1)
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                TRANSFER_SHADOW(o);
                // タイリングとオフセットの処理
                o.shadow_uv = TRANSFORM_TEX(v.shadow_uv, _ShadowTex);
                // 法線方向のベクトル
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                // カメラとオブジェクトの距離(長さ)を取得
                // _WorldSpaceCameraPos：定義済の値 ワールド座標系のカメラの位置
                float cameraToObjLength = clamp(length(
                _WorldSpaceCameraPos - i.worldPos),
                0,
                _ShadowDistance
                );

                // 1つ目のライトのベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                // ワールド座標系の法線を正規化
                float3 N = normalize(i.worldNormal);

                // 内積の結果が0以上なら1 この値を使って裏側の影は描画しない
                float front = step(0, dot(N, L));

                // 影の場合0、それ以外は1
                float attenuation = SHADOW_ATTENUATION(i);

                // 影の減衰率
                float fade = 1 - pow(cameraToObjLength / _ShadowDistance, _ShadowDistance);

                // 影の色
                float3 shadowColor = tex2D(_ShadowTex, i.shadow_uv) * _ShadowColor;

                // 影の場所とそれ以外の場所を塗分け
                float4 finalColor = float4(
                shadowColor,
                (1 - attenuation) * _ShadowIntensity * front * fade
                );

                return finalColor;
            }
            ENDCG
        }

        // 影を落とす処理を行うPass
        Pass
        {
            Tags { "LightMode" = "ShadowCaster" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster

            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i);
            }
            ENDCG
        }
    }
}
