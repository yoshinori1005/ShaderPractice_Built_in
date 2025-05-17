Shader "Unlit/DepthDissolve"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}

        [Header(Dissolve)]
        _DissolveBegin("Begin(The lower,the closer of the camera)", Range(0, 1)) = 0
        _DissolveEnd("End(Should be lower than Begin value)", Range(0, 1)) = 0

        [Header(Ambient)]
        _Ambient("Ambient", Range(0, 1)) = 0.1
        _AmbientColor("Ambient Color", Color) = (1, 1, 1, 1)

        [Header(Diffuse)]
        _Diffuse("Diffuse Value", Range(0, 1)) = 1
        _DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)

        [Header(Specular)]
        [Toggle] _Spec("Enabled", Float) = 0
        _Shininess("Shininess", Range(0.1, 10)) = 1
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1)

        [Header(Emission)]
        _EmissionTex("Emission Texture", 2D) = "gray"{}
        _Intensity("Intensity", Float) = 0
        [HDR] _EmissionColor("Emission Color", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
            "LightMode" = "ForwardBase"
        }

        // Blend SrcAlpha OneMinusSrcAlpha
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
            // ClassicNoise3D.cgincの保存場所パス
            #include "Assets/Resources/ClassicNoise3D.cginc"

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

            // ディゾルブ
            fixed _DissolveBegin;
            float _DissolveEnd;

            // 深度テクスチャ
            sampler2D _CameraDepthTexture;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 projPos : TEXCOORD3;
            };

            v2f vert (appdata_full v)
            {
                v2f o;

                // 頂点をワールド空間に変換
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                // ワールド空間をクリップ空間に変換
                o.pos = mul(UNITY_MATRIX_VP, float4(o.worldPos, 1.0));

                // クリップ空間をスクリーン空間に変換
                o.projPos = ComputeScreenPos(o.pos);

                // 法線ベクトルをワールド空間に変換
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_WorldToObject));

                o.uv = v.texcoord;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // ライト方向
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

                // カメラ方向
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                float3 worldNormal = normalize(i.worldNormal);

                // 環境光を計算
                fixed4 ambient = _Ambient * _AmbientColor;

                // 拡散光を計算
                fixed4 NdotL = max(0.0, dot(worldNormal, lightDir) * _LightColor0);
                fixed4 diff = NdotL * _Diffuse * _LightColor0 * _DiffuseColor;

                fixed4 light = diff + ambient;

                // 鏡面反射光を計算
                #if _SPEC_ON
                float3 ref = normalize(reflect(- lightDir, worldNormal));
                float RdotV = max(0.0, dot(ref, viewDir));
                fixed4 spec = pow(RdotV, _Shininess) * _LightColor0 * ceil(NdotL) * _SpecColor;

                light += spec;
                #endif

                col.rgb *= light.rgb;

                // 自発光を計算
                fixed4 emission = tex2D(_EmissionTex, i.uv).r * _EmissionColor * _Intensity;
                col.rgb += emission.rgb;

                // 深度の値を取得する
                float depth = Linear01Depth(tex2Dproj(_CameraDepthTexture, UNITY_PROJ_COORD(i.projPos)).r);

                // アーティファクト予防のため
                if(depth == 1.0)
                discard;

                // 距離に応じてディゾルブ量を計算
                float ind = step(depth, _DissolveBegin) * (1 - (depth - _DissolveEnd) / (_DissolveBegin - _DissolveEnd));

                // ノイズによるディゾルブ表現
                if((cnoise(i.worldPos) + 1.0) / 2.0 <= ind)
                discard;

                return col;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
