Shader "Custom/CustomizableBump"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BumpMap("Bump Texture", 2D) = "bump"{}
        _Intensity("Intensity", Range(-5, 5)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        float _Intensity;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Bump;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            fixed3 normal = UnpackNormal(tex2D(_BumpMap, IN.uv_Bump));
            normal.x *= _Intensity;
            normal.y *= _Intensity;
            o.Normal = normalize(normal);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
