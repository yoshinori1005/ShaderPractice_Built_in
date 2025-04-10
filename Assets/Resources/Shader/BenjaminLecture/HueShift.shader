Shader "Unlit/HueShift"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HueShiftTex("Hue Shift Texture", 2D) = "white"{}
        _HueShift("Hue Shift", Range(0, 10)) = 0
        _Saturation("Saturation", Range(0, 5)) = 0
        _Brightness("Brightness", Range(-1, 1)) = 0
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

            sampler2D _HueShiftTex;
            float _HueShift;
            float _Saturation;
            float _Brightness;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            float3 HueShift(float3 color, float hueShift)
            {
                // YIQ = テレビのカラー方式
                float3x3 RGB2YIQ = float3x3 (
                0.299, 0.587, 0.114,
                0.5959, - 0.275, - 0.3213,
                0.2115, - 0.5227, 0.3112
                );

                float3x3 YIQ2RGB = float3x3(
                1, 0.956, 0.619,
                1, - 0.272, - 0.647,
                1, - 1.106, 1.782
                );

                float3 YIQ = mul(RGB2YIQ, color);

                float hue = atan2(YIQ.z, YIQ.y) + hueShift;
                float chroma = length(float2(YIQ.y, YIQ.z)) * _Saturation;

                float Y = YIQ.x + _Brightness;
                float I = chroma * cos(hue);
                float Q = chroma * sin(hue);

                float3 shiftYIQ = float3(Y, I, Q);
                float3 newRGB = mul(YIQ2RGB, shiftYIQ);

                return newRGB;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 hue = tex2D(_HueShiftTex, i.uv).r;
                col.rgb = HueShift(col.rgb, _HueShift + hue);
                return col;
            }
            ENDCG
        }
    }
}
