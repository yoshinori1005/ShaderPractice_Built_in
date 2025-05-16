Shader "Unlit/VertexSpecular"
{
    Properties
    {
        [Header(Diffuse)]
        _Color("Color", Color) = (1, 1, 1, 1)
        _Diffuse("Diffuse Value", Range(0, 1)) = 1
        [Header(Specular)]
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1)
        _Shininess("Shininess", Range(0.1, 10)) = 1
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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed4 col : COLOR0;
            };

            fixed4 _LightColor0;
            fixed4 _Color;
            fixed4 _SpecColor;

            float _Diffuse;
            float _Shininess;

            v2f vert (appdata v)
            {
                v2f o;
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);

                float3 worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos).xyz);
                float3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos).xyz);
                float3 ref1 = reflect(- lightDir, worldNormal);

                float NdotL = max(0, dot(worldNormal, lightDir));
                float RdotV = max(0, dot(ref1, viewDir));

                fixed4 diff = _Color * NdotL * _LightColor0 * _Diffuse;
                fixed4 spec = ceil(NdotL) * _LightColor0 * _SpecColor * pow(RdotV, _Shininess);

                o.col = diff + spec;

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                return i.col;
            }
            ENDCG
        }
    }
}
