Shader "Unlit/Displacement"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Strength("Strength", Range(0.01, 5)) = 0.5
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Strength;

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                float xMod = tex2Dlod(_MainTex, float4(o.uv.xy, 0, 1));
                xMod = xMod * 2 - 1;

                o.uv.x = frac(sin(xMod * 10 - _Time.y));
                float3 vert = v.vertex;
                vert.y = o.uv.x * _Strength;
                o.uv.x = o.uv.x * 0.5 + 0.5;
                o.vertex = UnityObjectToClipPos(vert);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.uv.x, 0.2, 0.2, 1);
            }
            ENDCG
        }
    }
}
