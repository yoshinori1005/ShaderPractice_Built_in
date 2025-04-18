Shader "Unlit/Shade"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _DiffuseShade("Diffuse Shade", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            fixed4 _MainColor;
            float _DiffuseShade;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                half3 worldNormal : TEXCOORD0;
                SHADOW_COORDS(1)
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                TRANSFER_SHADOW(o);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 最終的に出力するピクセルの色
                fixed4 finalColor = fixed4(1, 0, 0, 1);

                // 1つ目のライトのベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                // ワールド座標系の法線を正規化
                float3 N = normalize(i.worldNormal);

                // ライトベクトルと法線の内積からピクセルの明るさを計算(ランバートの調整も行う)
                fixed4 diffuseColor = max(0, dot(N, L) * _DiffuseShade + (1 - _DiffuseShade));

                // ライトの色を乗算
                finalColor = _MainColor * diffuseColor * _LightColor0;

                // 影を計算
                finalColor *= SHADOW_ATTENUATION(i);

                return finalColor;
            }
            ENDCG
        }

        // 影を落とす処理を行なうPass
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
