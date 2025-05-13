Shader "Unlit/PostRenderNoise"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SecondaryTex("Secondary Texture", 2D) = "white"{}
        _OffsetX("Offset X", Float) = 0
        _OffsetY("Offset Y", Float) = 0
        _Intensity("Mask Intensity", Range(0, 1)) = 1
        _Color("Color", Color) = (1, 1, 1, 1)

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
                float2 uv2 : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SecondaryTex;
            half _OffsetX;
            half _OffsetY;
            fixed4 _Color;
            fixed _Intensity;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv2 = v.texcoord + float2(_OffsetX, _OffsetY);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 col2 = tex2D(_SecondaryTex, i.uv2);
                return lerp(col, _Color, ceil(saturate(1 - col2.r - _Intensity)));
            }
            ENDCG
        }
    }
}
