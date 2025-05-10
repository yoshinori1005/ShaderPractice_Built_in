Shader "Custom/FakeWireframe"
{
    Properties
    {
        _MainColor("Main Color", Color) = (0, 0, 0, 1)
        _LineColor ("Line Color", Color) = (1, 1, 1, 1)
        _LineWidth("Line Width", Range(0, 1)) = 0.1
        _ParcelSize("Parcel Size", Range(0, 100)) = 1
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
        float4 _MainColor;
        float4 _LineColor;
        float _LineWidth;
        float _ParcelSize;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // frac関数で小数部分だけ取り出し、グリッドの相対位置を決める
            // step関数で線の範囲内なら0、範囲外なら1にし、線の太さを制御する
            half val1 = step(_LineWidth * 2, frac(IN.worldPos.x / _ParcelSize) + _LineWidth);
            half val2 = step(_LineWidth * 2, frac(IN.worldPos.z / _ParcelSize) + _LineWidth);
            float val = 1 - (val1 * val2);
            // MainColorとLineColorをvalに基づいて色を設定
            o.Albedo = lerp(_MainColor, _LineColor, val);
            o.Alpha = 1;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
