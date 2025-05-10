Shader "Unlit/UnlitOutline"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _Outline("Outline", Range(0, 0.1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            float4 _MainTex_ST;
            float4 _OutlineColor;
            float _Outline;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 normal = UnityObjectToWorldNormal(v.normal);
                // 頂点の法線方向に沿って外側に拡大
                normal.x *= UNITY_MATRIX_P[0][0];
                normal.y *= UNITY_MATRIX_P[1][1];
                // カメラに向かって輪郭を広げる
                o.pos.xy += normal.xy * _Outline;
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        CGPROGRAM
        #pragma surface surf Lambert

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf(Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex);
        }
        ENDCG
    }
    Fallback "Diffuse"
}
