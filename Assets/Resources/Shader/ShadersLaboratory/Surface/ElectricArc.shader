Shader "Custom/ElectricArc"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "grey"{}
        _Speed("Speed", Range(0, 50)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert alpha

        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _NoiseTex;
        float _Speed;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_NoiseTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // 時間ベースのノイズ位置を計算ceilでカクカクした動きを作り
            // fracでゆっくり動く座標を作成
            float time1 = frac(ceil(_Time.y * _Speed) * 0.01);
            float time2 = frac(ceil(_Time.x * _Speed) * 0.01);
            float noise = tex2D(_NoiseTex, float2(time1, time2)).r;
            float2 uv = IN.uv_MainTex;
            // メインテクスチャのUVをノイズで揺らす
            uv.y = frac(uv.y + noise);
            half4 c = tex2D (_MainTex, uv);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
