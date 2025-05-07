Shader "Custom/SnowEffect"
{
    Properties
    {
        _SnowColor ("Snow Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _BumpMap("Bump Texture", 2D) = "bump"{}
        _SnowDirection("Snow Direction", Vector) = (0, 1, 0)
        _SnowLevel("Amount of Snow", Range(-1, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Lambert

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        half4 _SnowColor;
        half3 _SnowDirection;
        fixed _SnowLevel;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Bump;
            float3 worldNormal;
            INTERNAL_DATA
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 tex = tex2D(_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_Bump));

            // 面の向きと雪の降る方向の内積で角度を計算し、ピクセルがSnowLevel以上の角度の場合
            if(dot(WorldNormalVector(IN, o.Normal), _SnowDirection) >= _SnowLevel)
            {
                // 雪のカラーに設定
                o.Albedo = _SnowColor.rgb;
            }
            else
            {
                // MainTextureに設定
                o.Albedo = tex.rgb;
            }
        }
        ENDCG
    }
    FallBack "Diffuse"
}
