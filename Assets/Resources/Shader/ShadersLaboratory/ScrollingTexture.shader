Shader "Custom/ScrollingTexture"
{
    Properties
    {
        _TextureColor ("Texture Color", Color) = (1, 1, 1, 1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _ScrollXSpeed("X Scroll Speed", Range(-5, 5)) = 0
        _ScrollYSpeed("Y Scroll Speed", Range(-5, 5)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert alpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _TextureColor;
        fixed _ScrollXSpeed;
        fixed _ScrollYSpeed;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // X軸方向、Y軸方向にそれぞれ時間と速度をテクスチャに追加してスクロールさせる
            fixed varX = _ScrollXSpeed * _Time.x;
            fixed varY = _ScrollYSpeed * _Time.x;

            fixed2 uv_Tex = IN.uv_MainTex + fixed2(varX, varY);

            fixed4 c = tex2D (_MainTex, uv_Tex) * _TextureColor;

            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
