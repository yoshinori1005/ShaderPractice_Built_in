Shader "Unlit/ParallaxMapping"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Normal]_NormalMap("Normal Map", 2D) = "bump"{}
        _HeightMap("Height Map", 2D) = "white"{}
        _Shininess("Shininess", Range(0.0, 1.0)) = 0.078125
        _HeightFactor("Height Factor", Range(0.0, 0.1)) = 0.02
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
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _HeightMap;
            float4 _LightColor0;
            half _Shininess;
            half _HeightFactor;

            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord.xy;
                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex));
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex));

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.lightDir = normalize(i.lightDir);
                i.viewDir = normalize(i.viewDir);
                half3 halfDir = normalize(i.lightDir * i.viewDir);

                // ハイトマップをサンプリングして UV をずらす
                fixed4 height = tex2D(_HeightMap, i.uv);
                i.uv += i.viewDir.xy * height.b * _HeightFactor;

                fixed4 tex = tex2D(_MainTex, i.uv);
                fixed3 normal = UnpackNormal(tex2D(_NormalMap, i.uv));
                fixed4 diffuse = saturate(dot(normal, i.lightDir)) * _LightColor0;

                half3 specular = pow(max(0, dot(normal, halfDir)), _Shininess * 128.0) * _LightColor0.rgb;

                fixed4 color;
                color.rgb = tex.rgb * diffuse * specular;
                return color;
            }
            ENDCG
        }
    }
}
