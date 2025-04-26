Shader "Unlit/SeaPostEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // カラー
        _EffectColor("Effect Color", Color) = (0.7, 0.85, 1, 1)
        // 歪みの値
        _DistortionPower("Distortion Power", Range(0, 0.1)) = 0
        _DistortionScale("Distortion Scale", Range(0, 100)) = 50
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
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _EffectColor;
            float _DistortionPower;
            float _DistortionScale;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // サンプリングするUVをずらす(sin波でゆらゆら)
                float2 distortion = sin(i.uv.y * _DistortionScale + _Time.w) * 0.1f;
                distortion *= _DistortionPower;

                // 描画結果をサンプリング
                float4 renderingColor = tex2D(_MainTex, i.uv + distortion);

                return renderingColor * _EffectColor;
            }
            ENDCG
        }
    }
}
