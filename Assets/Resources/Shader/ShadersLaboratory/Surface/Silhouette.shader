Shader "Custom/Silhouette"
{
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Geometry"
        }
        LOD 200

        Stencil
        {
            Ref 1
            Comp Always
            Pass Replace
        }

        CGPROGRAM
        #pragma surface surf Lambert alpha

        #pragma target 3.0

        struct Input
        {
            float3 Albedo;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = fixed3(1, 1, 1);
            o.Alpha = 0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
