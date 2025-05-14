Shader "Custom/TextureDependingNormal"
{
    Properties
    {
        _FloorTex ("Floor Texture", 2D) = "white" {}
        _WallTex("Wall Texture", 2D) = "white"{}
        _CeilTex("Ceil Texture", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard

        #pragma target 3.0

        sampler2D _FloorTex;
        sampler2D _WallTex;
        sampler2D _CeilTex;

        struct Input
        {
            float3 worldNormal;
            float2 uv_FloorTex;
            float2 uv_WallTex;
            float2 uv_CeilTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // 法線のワールド空間(Y軸)が0.9より大きければ床テクスチャを割当てる
            if(IN.worldNormal.y > 0.9)
            {
                o.Albedo = tex2D (_FloorTex, IN.uv_FloorTex).rgb;
            }
            // // 法線のワールド空間(Y軸)が - 0.9より小さければ天井テクスチャを割当てる
            else if(IN.worldNormal.y <- 0.9)
            {
                o.Albedo = tex2D(_CeilTex, IN.uv_CeilTex).rgb;
            }
            // 法線のワールド空間がそれ以外のものには壁テクスチャを割当てる
            else
            {
                o.Albedo = tex2D(_WallTex, IN.uv_WallTex).rgb;
            }

            o.Emission = half3(1, 1, 1) * o.Albedo;
            o.Metallic = 0.0;
            o.Smoothness = 0.5;
        }
        ENDCG
    }
}
