Shader "Custom/Triplanar"
{
    Properties
    {
        _TextureX ("Texture X Axis", 2D) = "white" {}
        _TextureY ("Texture Y Axis", 2D) = "white" {}
        _TextureZ ("Texture Z Axis", 2D) = "white" {}
        _Scale("Scale", Range(0.001, 0.2)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard

        #pragma target 3.0

        sampler2D _TextureX;
        sampler2D _TextureY;
        sampler2D _TextureZ;
        float _Scale;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
            float3 worldNormal;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // X, Y, Z各軸にモデルのワールド空間の位置をもとにテクスチャを割当てる
            fixed4 colX = tex2D (_TextureX, IN.worldPos.xz * _Scale);
            fixed4 colY = tex2D (_TextureY, IN.worldPos.yz * _Scale);
            fixed4 colZ = tex2D (_TextureZ, IN.worldPos.xy * _Scale);

            // X, Y, Z各軸への向きの強さを取得し、正規化
            float3 vec = abs(IN.worldNormal);
            vec /= vec.x + vec.y + vec.z + 0.001f;

            // X, Y, Z各方向からのテクスチャに重みをかけて滑らかな合成
            fixed4 col = vec.x * colX + vec.y * colY + vec.z * colZ;

            o.Albedo = col;
            o.Emission = col;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
