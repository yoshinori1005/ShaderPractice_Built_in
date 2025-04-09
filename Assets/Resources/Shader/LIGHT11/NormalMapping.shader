Shader "Unlit/NormalMapping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Normal]_NormalMap("Normal Map", 2D) = "bump"{}
        _Shininess("Shininess", Range(0.0, 1.0)) = 0.078125
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Tags{"LightMode" = "ForwardBase"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                half3 lightDir : TEXCOORD1;
                half3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            float4 _LightColor0;
            half _Shininess;

            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;

                // UnityCG.cginc に定義されているマクロ
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                i.lightDir = normalize(i.lightDir);
                i.viewDir = normalize(i.viewDir);
                half3 halfDir = normalize(i.lightDir + i.viewDir);

                fixed4 tex = tex2D(_MainTex, i.uv);
                // ノーマルマップから法線を取得
                half3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                // ノーマルマップの法線が確実に正規化されているならなくてもいい
                normal = normalize(normal);

                half3 diffuse = max(0, dot(normal, i.lightDir)) * _LightColor0.rgb;
                half3 specular = pow(max(0, dot(normal, halfDir)), _Shininess * 128.0) * _LightColor0.rgb;

                fixed4 color;
                color.rgb = tex.rgb + diffuse + specular;
                return color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
