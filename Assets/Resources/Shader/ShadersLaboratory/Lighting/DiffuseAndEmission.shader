Shader "Unlit/DiffuseAndEmission"
{
    Properties
    {
        [Header(Diffuse)]
        _Color("Color", Color) = (1, 1, 1, 1)
        _Diffuse("Diffuse Value", Range(0, 1)) = 1
        [Header(Emission)]
        _EmissionTex ("Emission Texture", 2D) = "white" {}
        [HDR] _EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
        _Threshold("Threshold", Range(0, 1)) = 1
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

            sampler2D _EmissionTex;
            float4 _EmissionTex_ST;
            fixed4 _Color;
            fixed4 _LightColor0;
            float4 _EmissionColor;
            float _Diffuse;
            float _Threshold;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 col : COLOR0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = max(0.0, dot(worldNormal, lightDir));
                fixed4 diff = _Color * NdotL * _LightColor0 * _Diffuse;
                o.col = diff;
                o.uv = TRANSFORM_TEX(v.texcoord, _EmissionTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 emission = tex2D(_EmissionTex, i.uv).r * _EmissionColor.rgb * _Threshold;
                i.col.rgb += emission;
                return i.col;
            }
            ENDCG
        }
    }
}
