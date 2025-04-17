Shader "Unlit/Diffuse"
{
    Properties
    {
        _MainColor("Main Color", Color) = (0.8, 0.8, 0.8, 1)
        _DiffuseShade("Diffuse Shade", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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
                float3 worldNormal : TEXCOORD0;
                // 環境光
                float3 ambient : COLOR0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.ambient = ShadeSH9(half4(o.worldNormal, 1));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 1つ目のライトのベクトルを正規化
                float3 L = normalize(_WorldSpaceLightPos0.xyz);

                // ワールド座標系の法線を正規化
                float3 N = normalize(i.worldNormal);

                // ライトベクトルと法線の内積からピクセルの明るさを計算(ランバートの調整も行う)
                fixed4 diffuseColor = max(0, dot(N, L) * _DiffuseShade + (1 - _DiffuseShade));

                // 色を計算
                fixed4 finalColor = _MainColor * diffuseColor * _LightColor0 * float4(i.ambient, 1);

                return finalColor;
            }
            ENDCG
        }
    }
}
