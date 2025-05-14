Shader "Custom/WorldSpaceTexture"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard

        #pragma target 3.0

        sampler2D _MainTex;

        struct Input
        {
            float3 worldPos;
            float3 worldNormal;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // 法線のワールド空間(Y軸)が0.5より大きい場合
            if(abs(IN.worldNormal.y) > 0.5)
            {
                // ワールド座標のX, Z軸にテクスチャを割当てる
                o.Albedo = tex2D (_MainTex, IN.worldPos.xz);
            }
            // 法線のワールド空間(X軸)が0.5より大きい場合
            else if(abs(IN.worldNormal.x) > 0.5)
            {
                // ワールド座標のY, Z軸にテクスチャを割当てる
                o.Albedo = tex2D (_MainTex, IN.worldPos.yz);
            }
            else
            {
                // ワールド座標のX, Y軸にテクスチャを割当てる
                o.Albedo = tex2D (_MainTex, IN.worldPos.xy);
            }

            o.Emission = o.Albedo;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
