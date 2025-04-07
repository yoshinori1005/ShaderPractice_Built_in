Shader "Custom/PosterizeLighting"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Steps ("Banded Steps", Range(1, 100)) = 20
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Banded
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;
        float _Steps;

        half4 LightingBanded(SurfaceOutput s, half3 lightDir, half atten)
        {
            half NdotL = dot(s.Normal, lightDir);
            half lightBandMultiplier = _Steps / 256;
            half lightBandAdditive = _Steps / 2;
            fixed bandedLightModel = (floor((NdotL * 256 + lightBandAdditive) / _Steps)) * lightBandMultiplier;
            half4 c;
            c.rgb = s.Albedo * atten * _LightColor0.rgb * bandedLightModel;
            c.a = s.Alpha;
            return c;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = _Color.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
