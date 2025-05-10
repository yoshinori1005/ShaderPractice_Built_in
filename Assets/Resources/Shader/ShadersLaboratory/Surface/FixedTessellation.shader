Shader "Custom/FixedTessellation"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BumpMap("Bump Map", 2D) = "bump"{}
        _DisplaceMap("Displacement Map", 2D) = "grey"{}
        _TexVal("Tessellation Value", Range(1, 40)) = 1
        _DisplaceVal("Displacement Value", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf BlinnPhong vertex:vert tessellate:tess

        #pragma target 4.6

        sampler2D _MainTex;
        sampler2D _BumpMap;
        sampler2D _DisplaceMap;
        float _TexVal;
        float _DisplaceVal;

        struct appdata
        {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 tangent : TANGENT;
            float2 texcoord : TEXCOORD0;
        };

        // テッセレーション関数
        float4 tess()
        {
            return _TexVal;
        }

        void vert(inout appdata v)
        {
            // Displacement Mapの値を読み取り、モデルの法線方向に頂点を動かす
            float val = tex2Dlod(_DisplaceMap, float4(v.texcoord.xy, 0, 0)).r * _DisplaceVal;
            v.vertex.xyz += v.normal * val;
        }

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            // Main Textureから色情報を取得し、Normal Mapから凹凸情報を読み込む
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_MainTex));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
