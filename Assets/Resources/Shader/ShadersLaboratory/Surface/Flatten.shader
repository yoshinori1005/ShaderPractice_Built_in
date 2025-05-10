Shader "Custom/Flatten"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Elevation("Elevation", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert

        #pragma target 3.0

        sampler2D _MainTex;
        fixed _Elevation;

        struct Input
        {
            float2 uv_MainTex;
        };

        void vert(inout appdata_full v)
        {
            // _Elevationが0の時はそのまま、1の時は全ての頂点が - 1になり平面化される
            v.vertex.y = v.vertex.y - (1 + v.vertex.y) * _Elevation;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
