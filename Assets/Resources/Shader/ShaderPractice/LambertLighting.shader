Shader "Unlit/LambertLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Base Color", Color) = (1, 1, 1, 1)
        _SpecColor("Specular Color", Color) = (1, 1, 1, 1)
        // 反射の鋭さ(数字が大きいほど鋭くなる)
        _Shininess("Shininess", Range(1, 128)) = 32
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

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float4 _SpecColor;
            float _Shininess;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                // 法線をワールド空間に変換
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 法線の方向を取得
                float3 N = normalize(i.worldNormal);
                // ライトの方向を取得
                float3 L = normalize(_WorldSpaceLightPos0.xyz);
                // 視線(カメラ)の方向を取得(カメラ→表面)
                float3 V = normalize(_WorldSpaceCameraPos - i.worldPos);
                // ハーフベクトル(ライトと視線の中間)
                float3 H = normalize(L + V);

                // 拡散反射、明るさを制御
                float NdotL = max(0, dot(N, L));
                float NdotH = max(0, dot(N, H));
                float spec = pow(NdotH, _Shininess);

                fixed4 texCol = tex2D(_MainTex, i.uv);
                fixed4 finalColor = texCol * _Color * NdotL + _SpecColor * spec;
                return finalColor;
            }
            ENDCG
        }
    }
}
