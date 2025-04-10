Shader "Unlit/ParticleErode"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ErodeTex("Erode Texture", 2D) = "white"{}
        _Feather("Feather", Range(0.0, 0.1)) = 0.1
        _EmberColor("Ember Color", Color) = (1, 1, 1, 1)
        _EmberBoost("Ember Boost", Float) = 1
        _CharColor("Char Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
                float4 custom : TEXCOORD1;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 custom : TEXCOORD1;
            };

            sampler2D _MainTex, _ErodeTex;
            float4 _MainTex_ST, _EmberColor, _CharColor;
            float _Feather, _EmberBoost;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv.xy, _MainTex);
                o.uv.zw = v.uv.zw;
                o.custom.xyz = v.custom.xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                float cutoff = i.uv.z;

                float3 erode = tex2D(_ErodeTex, i.uv.xy).rgb;
                float erodeVariation = abs(lerp(erode.r, i.uv.x - erode.g, i.uv.w)) * 1.5;
                erodeVariation *= (1 - i.uv.y);

                float emberArea = smoothstep(erodeVariation - _Feather, erodeVariation + _Feather, cutoff);
                // fixed3 emberArea = step(erodeVariation - _Feather, cutoff);
                // emberArea = saturate(emberArea / fwidth(emberArea));
                // fixed3 burnArea = smoothstep(erodeVariation - _Feather, erodeVariation + _Feather, cutoff);
                float burnArea = smoothstep(erodeVariation, erodeVariation + _Feather, cutoff);
                fixed3 emberColor = lerp(col, _EmberColor * _EmberBoost, emberArea);
                fixed3 color = lerp(emberColor, _CharColor, burnArea);
                fixed alpha = saturate(col.a - step(erodeVariation + _Feather, cutoff));

                return fixed4(color, alpha);
            }
            ENDCG
        }
    }
}
