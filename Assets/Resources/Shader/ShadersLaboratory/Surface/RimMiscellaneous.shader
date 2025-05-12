Shader "Custom/RimMiscellaneous"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _RimValue("Rim Value", Range(0, 3)) = 0.5
        _Speed("Speed", Float) = 0.1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert alpha

        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color;
        fixed _RimValue;
        float _Speed;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float3 worldNormal;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex + _Time.y * _Speed);
            o.Albedo = c.rgb * _Color;

            float3 normal = normalize(IN.worldNormal);
            float3 dir = normalize(IN.viewDir);
            float val = 1 - (abs(dot(dir, normal)));
            float rim = val * val * _RimValue;
            o.Alpha = c.a * rim;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
