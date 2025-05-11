Shader "Custom/FinalColorSepia"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SepiaIntensity("Sepia Intensity", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        LOD 200

        CGPROGRAM
        // 最終的な色をセピアに変換する処理を追加
        #pragma surface surf Lambert finalcolor:SepiaColor

        #pragma target 3.0

        sampler2D _MainTex;
        fixed _SepiaIntensity;

        struct Input
        {
            float2 uv_MainTex;
        };

        // セピア調の色合いに変換する関数
        void SepiaColor(Input In, SurfaceOutput s, inout fixed4 col)
        {
            fixed3 c = col;
            c.r = dot(col.rgb, half3(0.393, 0.769, 0.189));
            c.g = dot(col.rgb, half3(0.349, 0.686, 0.168));
            c.b = dot(col.rgb, half3(0.272, 0.534, 0.131));
            col.rgb = lerp(col, c, _SepiaIntensity);
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
            o.Alpha = 1.0;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
