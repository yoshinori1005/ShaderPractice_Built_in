Shader "Unlit/LoopAnimatedDistortion"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
        _DistTex("Distortion Texture", 2D) = "white"{}
        _Intensity("Intensity", Float) = 1
        _Ramp("Ramp", Float) = 1
        _GlowColor("Glow Color", Color) = (1, 1, 1, 1)
        _GlowThickness("Glow Thickness", Range(0.05, 0.5)) = 0.1
        _GlowIntensity("Glow Intensity", Float) = 1
        _DistThickness("Distortion Thickness", Range(0.1, 1)) = 0.5
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex, _DistTex;
            float4 _MainTex_ST, _Color, _GlowColor;
            float _Intensity, _Ramp, _DistThickness, _GlowThickness, _GlowIntensity;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 mainTex = tex2D(_MainTex, i.uv);
                float luminance = Luminance(mainTex);
                float3 mainColor = luminance * _Color;
                mainColor = pow(mainColor, _Ramp) * _Intensity;

                float3 distTex = tex2D(_DistTex, i.uv);
                float distMask = abs(sin(distTex.r * 10 + _Time.y));
                float distStep = step(distMask, _DistThickness);

                float glow = 1 - smoothstep(
                distMask - _GlowThickness,
                distMask + _GlowThickness,
                _DistThickness
                );
                glow *= _GlowIntensity;

                return fixed4(mainColor + glow * _GlowColor, distStep);
            }
            ENDCG
        }
    }
}
