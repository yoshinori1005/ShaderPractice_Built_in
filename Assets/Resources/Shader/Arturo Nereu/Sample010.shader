Shader "Custom/Sample010"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _EmissionTex("Emission Texture", 2D) = "white"{}
        _EmissionMultiplier("Emission Multiplier", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard

        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _EmissionTex;
        float _EmissionMultiplier;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_EmissionTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
            o.Emission = tex2D(_EmissionTex, IN.uv_EmissionTex) * _EmissionMultiplier;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
