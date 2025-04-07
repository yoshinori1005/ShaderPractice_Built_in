Shader "Custom/DiffuseColor"
{
    Properties
    {
        _Albedo ("Albedo Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white"{}
        _RampTex("Ramp Texture", 2D) = "white"{}
        _NormalMap("Normal Map", 2D) = "bump"{}
        _NormalStrength("Normal Strength", Range(0.0, 5.0)) = 1.0
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecPower("Specular Power", Range(0, 10)) = 5
        _SpecGloss("Specular Gloss", Range(0.01, 5)) = 3
        _GlossStep("Gloss Step", Range(1, 8)) = 2
        _RimColor("Rim Color", Color) = (1, 0, 0, 1)
        _RimPower("Rim Power", Range(0.0, 8.0)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf CustomLambert
        #pragma target 3.0

        struct Input
        {
            // プロパティと同じ名前
            float2 uv_MainTex;
            float2 uv_NormalMap;
            float3 viewDir;
        };

        fixed4 _Albedo;
        sampler2D _MainTex;
        sampler2D _RampTex;
        sampler2D _NormalMap;
        float _NormalStrength;
        fixed4 _SpecularColor;
        float _SpecPower;
        float _SpecGloss;
        float _GlossStep;
        fixed4 _RimColor;
        float _RimPower;

        half4 LightingCustomLambert(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten)
        {
            half NdotL = max(0, dot(s.Normal, lightDir));
            half diff = NdotL * 0.5 + 0.5;

            float2 uv_RampTex = float2(diff, 0);
            fixed3 rampColor = tex2D(_RampTex, uv_RampTex).rgb;

            half3 reflectedLight = reflect(- lightDir, s.Normal);
            half RdotV = max(0, dot(reflectedLight, viewDir));
            fixed3 spec = pow(RdotV, _SpecGloss / _GlossStep) * _SpecPower * _SpecularColor.rgb;

            half4 c;
            c.rgb = (NdotL * s.Albedo * rampColor + spec) * _LightColor0.rgb * atten;
            c.a = s.Alpha;

            return c;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 texColor = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = texColor.rgb * _Albedo.rgb;

            // 法線マップの適用
            fixed4 normalMap = tex2D(_NormalMap, IN.uv_NormalMap);
            float3 normal = UnpackNormal(normalMap);
            normal.z/=_NormalStrength;
            o.Normal = normalize(normal);

            // リムライトの適用
            float3 V = normalize(IN.viewDir);
            float3 NdotV = dot(V, o.Normal);
            float rim = saturate(NdotV);
            o.Emission = _RimColor.rgb * (1 - pow(rim, _RimPower));

        }
        ENDCG
    }
    FallBack "Diffuse"
}
