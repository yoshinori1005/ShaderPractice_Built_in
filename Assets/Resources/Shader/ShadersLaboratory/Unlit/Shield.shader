Shader "Unlit/Shield"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _RimEffect("Rim Effect", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend One One
        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _RimEffect;

            v2f vert (appdata_full v)
            {
                v2f o;

                // 頂点をクリップ空間に変換(MVP行列)
                o.pos = UnityObjectToClipPos(v.vertex);

                // 法線をワールド空間に変換(マクロ)
                o.normal = UnityObjectToWorldNormal(v.normal);

                // 頂点をワールド空間に変換
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                // カメラからの方向ベクトル
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);

                // UV座標の変換
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float t = tex2D(_MainTex, i.uv);
                float val = 1 - abs(dot(i.viewDir, i.normal)) * _RimEffect;
                return _Color * _Color.a * val * val * t;
            }
            ENDCG
        }
    }
}
