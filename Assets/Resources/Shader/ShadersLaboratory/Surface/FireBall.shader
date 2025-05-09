Shader "Custom/FireBall"
{
    Properties
    {
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "grey"{}
        _RampVal("Ramp Offset", Range(-0.5, 0.5)) = 0
        _Amplitude("Amplitude Factor", Range(0, 0.03)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // ライトの影響をランバート拡散反射、頂点シェーダーの使用
        // vertex:vert はこの形でないと正常に動作しない
        #pragma surface surf Lambert vertex:vert

        sampler2D _RampTex;
        sampler2D _NoiseTex;
        fixed _RampVal;
        fixed _Amplitude;

        struct Input
        {
            float2 uv_NoiseTex;
        };

        void vert(inout appdata_full v)
        {
            // 頂点シェーダーでTextureを扱うためのTex2DLodを使用、R値を取得
            half noiseVal = tex2Dlod(_NoiseTex, float4(v.texcoord.xy, 0, 0)).r;
            // 頂点を法線方向にノイズテクスチャのR値に基づいて振幅させる
            v.vertex.xyz += v.normal * sin(_Time.y + noiseVal * 100) * _Amplitude;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Noise TextureのR値を振幅させる
            half noiseVal = tex2D(_NoiseTex, IN.uv_NoiseTex).r + (sin(_Time.y)) / 15;
            // Ramp Textureの色を(_RampVal + noiseVal)と0.5の間に収める
            half4 color = tex2D(_RampTex, float2(saturate(_RampVal + noiseVal), 0.5));
            o.Albedo = color.rgb;
            o.Emission = color.rgb;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
