Shader "Unlit/CausticsRGB"
{
    Properties
    {
        _CubeMap("Environment CubeMap", Cube) = ""{}
        _NormalMap("Normal Map", 2D) = "bump"{}
        _RefractiveIndex("Refractive Index", Range(1, 2)) = 1.02
        _Spectroscopy("Spectroscopy Offset", Range(0, 1)) = 0.02
        _CausticPower("Caustics Power", Range(1, 10)) = 5
        _Intensity("Intensity", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend One One
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            samplerCUBE _CubeMap;
            sampler2D _NormalMap;

            float _RefractiveIndex;
            float _Spectroscopy;
            float _CausticPower;
            float _Intensity;

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
                float3 normal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            // スネルの法則に基づいた屈折方向ベクトルの計算
            float3 refractDir(float3 incident, float3 normal, float eta)
            {
                // 入射角の余弦 : 入射ベクトル(カメラ→表面)と表面法線の内積
                float cosI = dot(- incident, normal);
                // 透過側の余弦(eta : 屈折率の比 入射側 / 透過側)、負の場合全反射
                float sinT2 = eta * eta * (1.0 - cosI * cosI);
                if(sinT2 > 1.0)
                return reflect(incident, normal); // 全内部反射フォールバック
                float cosT = sqrt(1.0 - sinT2);

                // 全反射ならベクトルが0になる
                return eta * incident + (eta * cosI - cosT) * normal;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv + _Time.w * 0.01));
                // ノーマル補正
                float3 normal = normalize(i.normal + normalMap * 0.5);

                float3 viewDir = normalize(i.worldPos - _WorldSpaceCameraPos);

                // RGBの屈折方向をそれぞれ別計算
                float3 refractR = refractDir(viewDir, normal, _RefractiveIndex - _Spectroscopy);
                float3 refractG = refractDir(viewDir, normal, _RefractiveIndex);
                float3 refractB = refractDir(viewDir, normal, _RefractiveIndex + _Spectroscopy);

                // 各屈折方向の環境色取得
                float3 colR = texCUBE(_CubeMap, refractR).rgb * float3(1, 0, 0);
                float3 colG = texCUBE(_CubeMap, refractG).rgb * float3(0, 1, 0);
                float3 colB = texCUBE(_CubeMap, refractB).rgb * float3(0, 0, 1);

                // 結果を合成
                float3 caustic = saturate(colR + colG + colB) * _CausticPower;

                return float4(caustic * _Intensity, _Intensity);
            }
            ENDCG
        }
    }
}
