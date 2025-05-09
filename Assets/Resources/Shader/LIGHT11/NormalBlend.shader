Shader "Custom/NormalBlend"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap1("Normal Map1", 2D) = "bump"{}
        _NormalMap2("Normal Map2", 2D) = "bump"{}
        _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        _Metallic ("Metallic", Range(0, 1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        #pragma target 3.0

        // BlendNormals関数を使用する場合
        #include "UnityStandardUtils.cginc"

        sampler2D _MainTex;
        sampler2D _NormalMap1;
        sampler2D _NormalMap2;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NormalMap1;
            float2 uv_NormalMap2;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;

            half3 normal1 = UnpackNormal(tex2D(_NormalMap1, IN.uv_NormalMap1));
            half3 normal2 = UnpackNormal(tex2D(_NormalMap2, IN.uv_NormalMap2));

            // "UnityStandardUtils.cginc"の関数を使用したノーマルマップブレンド
            half3 normal = BlendNormals(normal1, normal2);

            // 関数を使用しない場合のノーマルマップブレンド
            // half3 normal = normalize(half3(normal1.xy + normal2.xy, normal1.z * normal2.z));

            o.Normal = normal;

            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
