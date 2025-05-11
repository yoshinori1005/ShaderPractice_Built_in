Shader "Custom/BasicGlass"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _EmissionColor ("Emission Color", Color) = (1, 1, 1, 1)
        _Transparency("Transparency", Range(0, 1)) = 1
        _CubeMap("Cube Map", Cube) = "white"{}
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
        #pragma surface surf BlinnPhong alpha

        #pragma target 3.0

        sampler2D _MainTex;
        samplerCUBE _CubeMap;
        fixed4 _EmissionColor;
        fixed _Transparency;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldRef1;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed4 w = texCUBE(_CubeMap, IN.worldRef1);
            o.Emission = _EmissionColor.rgb * w.rgb;

            o.Specular = 0;
            o.Gloss = 1;
            o.Albedo = 0;
            o.Alpha = c.a * _EmissionColor.a * _Transparency;
        }
        ENDCG
    }
    FallBack "Transparent/VertexLit"
}
