Shader "Custom/RimEffect"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _RimValue("Rim Value", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Geometry"
        }
        LOD 200

        Blend SrcAlpha OneMinusSrcAlpha

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert alpha

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        fixed _RimValue;

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
            float3 worldNormal;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            // ピクセルの向き(法線)を取得
            float3 normal = normalize(IN.worldNormal);
            // カメラからの方向ベクトル
            float3 dir = normalize(IN.viewDir);
            // カメラと法線が直行するほどvalが大きくなる
            float val = 1 - (abs(dot(dir, normal)));
            // リム値から設定したしきい値を引く(2乗することで滑らかなリムに)
            float rim = val * val - _RimValue;
            o.Alpha = c.a * rim;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
