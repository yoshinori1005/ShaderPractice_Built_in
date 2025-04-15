Shader "Custom/Sample011"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert alpha:fade

        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            clip(frac((IN.worldPos.y + IN.worldPos.z * 0.1 * _Time.y * 0.5) * 5) - 0.5);
            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb * float3(0, 0.5, 0.75);
            o.Alpha = 0.5;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
