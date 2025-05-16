Shader "Unlit/CelShaderFormula"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Threshold("Cel Threshold", Range(1.0, 20.0)) = 5.0
        _Ambient("Ambient Intensity", Range(0.0, 0.5)) = 0.1
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

            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed4 _LightColor0;
            float _Threshold;
            half _Ambient;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : NORMAL;
            };

            // 光の当たり方を階調表現する関数
            float LightToonShading(float3 normal, float3 lightDir)
            {
                float NdotL = max(0.0, dot(normalize(normal), normalize(lightDir)));
                return floor(NdotL * _Threshold) / (_Threshold - 0.5);
            }

            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // 光の強さを段階的にし、環境光Ambientを足す
                col.rgb *= saturate(LightToonShading(i.worldNormal, _WorldSpaceLightPos0.xyz) + _Ambient) * _LightColor0.rgb;
                return col;
            }
            ENDCG
        }
    }
}
