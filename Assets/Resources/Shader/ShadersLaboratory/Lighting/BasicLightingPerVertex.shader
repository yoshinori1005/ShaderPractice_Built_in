Shader "Unlit/BasicLightingPerVertex"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}

        [Header(Ambient)]
        _Ambient("Ambient", Range(0, 1)) = 0.1
        _AmbientColor("Ambient Color", Color) = (1, 1, 1, 1)

        [Header(Diffuse)]
        _Diffuse("Diffuse Val", Range(0, 1)) = 1
        _DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)

        [Header(Specular)]
        [Toggle] _Spec("Enabled", Float) = 0
        _Shininess("Shininess", Range(0.1, 10)) = 1
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1)

        [Header(Emission)]
        _EmissionTex("Emission Texture", 2D) = "gray"{}
        _Intensity("Intensity", Float) = 0
        [HDR] _EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "LightMode" = "ForwardBase"
        }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // C#スクリプトからこのキーワードを設定したい場合は、
            // "shader_feature "を "pragma_compile "に変更
            #pragma shader_feature __ _SPEC_ON

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _LightColor0;

            // 拡散光
            fixed _Diffuse;
            fixed4 _DiffuseColor;

            // 鏡面反射光
            fixed _Shininess;
            fixed4 _SpecColor;

            // 環境光
            fixed _Ambient;
            fixed4 _AmbientColor;

            // 自発光
            sampler2D _EmissionTex;
            fixed4 _EmissionColor;
            fixed _Intensity;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 light : COLOR0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                
                // 頂点をワールド空間に変換
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

                // クリップ空間
                o.pos = mul(UNITY_MATRIX_VP, worldPos);

                // ライト方向
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // 法線ベクトルをワールド空間に変換
                float3 worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                // カメラ方向
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - worldPos.xyz);

                // 環境光の計算
                fixed4 ambient = _Ambient * _AmbientColor;

                // 拡散反射光の計算
                fixed4 NdotL = max(0.0, dot(worldNormal, lightDir) * _LightColor0);
                fixed4 diff = NdotL * _Diffuse * _LightColor0 * _DiffuseColor;

                o.light = diff + ambient;

                // 鏡面反射光の計算
                #if _SPEC_ON
                float3 ref = reflect(- lightDir, worldNormal);
                float RdotV = max(0.0, dot(ref, viewDir));
                fixed4 spec = pow(RdotV, _Shininess) * _LightColor0 * ceil(NdotL) * _SpecColor;

                o.light += spec;
                #endif

                o.uv = v.texcoord;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャの色とライティングを掛け合わせる
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= i.light;

                // 自発光を計算して追加
                fixed4 emission = tex2D(_EmissionTex, i.uv).r * _EmissionColor * _Intensity;
                col.rgb += emission.rgb;

                return col;
            }
            ENDCG
        }
    }
}
