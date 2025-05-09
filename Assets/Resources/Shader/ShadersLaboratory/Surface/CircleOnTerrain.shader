Shader "Custom/CircleOnTerrain"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _AreaColor ("Area Color", Color) = (1, 1, 1, 1)
        _Center("Center", Vector) = (0, 0, 0, 0)
        _Radius("Radius", Range(0, 10)) = 3
        _Border("Border", Range(0, 10)) = 0.5
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
        fixed4 _AreaColor;
        float4 _Center;
        float _Radius;
        float _Border;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            // _Centerを中心に円を描く
            float dist = distance(_Center, IN.worldPos);

            // リングになる部分に指定の色を設定し、それ以外にはテクスチャを適用する
            if(dist > _Radius && dist < (_Radius + _Border))
            o.Albedo = _AreaColor;
            else
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
