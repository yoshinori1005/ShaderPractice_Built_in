Shader "Unlit/ParallaxMapping"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _Reflection("Reflection", Range(0, 10)) = 1
        _Specular("Specular", Range(0, 10)) = 1
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _HeightMap("Height Map", 2D) = "white"{}
        _HeightFactor("Height Factor", Range(0.0, 0.1)) = 0.02
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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _NormalMap;
            sampler2D _HeightMap;
            float4 _MainColor;
            float _Reflection;
            float _Specular;
            float _HeightFactor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                // 接空間の行列を取得
                TANGENT_SPACE_ROTATION;

                // ライトの方向ベクトルを接空間に変換
                o.lightDir = normalize(mul(rotation, ObjSpaceLightDir(v.vertex)));

                // カメラの方向ベクトルを接空間に変換
                o.viewDir = normalize(mul(rotation, ObjSpaceViewDir(v.vertex)));
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // ハイトマップをサンプリングしてUVをずらす
                float4 height = tex2D(_HeightMap, i.uv);
                i.uv += i.viewDir.xy * height * _HeightFactor;

                // ノーマルマップから法線を取得
                float3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));

                // ライトベクトルと法線ベクトルから反射ベクトルを計算
                float3 refVec = reflect(- i.lightDir, normal);

                // 視線ベクトルと反射ベクトルの内積を計算
                float RdotV = dot(refVec, i.viewDir);

                // 0以下は利用しないように内積の値を再計算
                RdotV = max(0, RdotV);
                RdotV = pow(RdotV, _Reflection);

                // スペキュラー
                float3 specular = _LightColor0.xyz * RdotV * _Specular;

                // 内積を補間値として塗分け
                float4 finalColor = _MainColor * float4(specular, 1);

                return finalColor;
            }
            ENDCG
        }
    }
}
