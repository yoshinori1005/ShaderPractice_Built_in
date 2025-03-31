Shader "Custom/UVScrollSample"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SpeedX("SpeedX", Float) = 0.1
        _SpeedY("SpeedY", Float) = 0.2
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        float _SpeedX;
        float _SpeedY;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed2 uv = IN.uv_MainTex;
            uv.x += _SpeedX * _Time;
            uv.y += _SpeedY * _Time;
            o.Albedo = tex2D(_MainTex, uv);
        }
        ENDCG
    }
    FallBack "Diffuse"
}
