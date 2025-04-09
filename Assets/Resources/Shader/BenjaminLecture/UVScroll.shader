Shader "Unlit/UVScroll"
{
    Properties
    {
        // インスペクターで使う記述
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Source Factor", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Destination Factor", Float) = 10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation", Float) = 0

        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex("Main Texture", 2D) = "white"{}
        _MaskTex("Mask Texture", 2D) = "white"{}
        _Reveal("Reveal", Float) = 0
        _Feather("Feather", Float) = 0
        _EdgeColor("Edge Color", Color) = (1, 1, 1, 1)
        _Intensity("Intensity", Range(0, 10)) = 3
        _DissolveSpeed("Dissolve Speed", Float) = 1
        _AnimateXY("Animate XY", Vector) = (0, 0, 0, 0)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Transparent"
        }
        LOD 100

        // 実行処理
        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

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
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;

            fixed4 _Color;
            float _Reveal;
            float _Feather;
            fixed4 _EdgeColor;
            float _Intensity;
            float _DissolveSpeed;
            float4 _AnimateXY;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex);
                // _MainTex_ST をかけることでタイリングをしても速度が変わらない
                o.uv += frac(_AnimateXY * _MainTex_ST * _Time.y);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 tex = tex2D(_MainTex, i.uv.xy) * _Color;
                fixed4 mask = tex2D(_MaskTex, i.uv.zw);
                float revealAnim = sin(_Time.y * _DissolveSpeed) * 0.5 + 0.5;
                float amountTop = step(mask.r, revealAnim + _Feather);
                float amountBottom = step(mask.r, revealAnim - _Feather);
                float difference = amountTop - amountBottom;
                fixed4 edge = _EdgeColor * _Intensity;
                float3 col = lerp(tex.rgb, edge, difference);

                return fixed4(col, tex.a * amountTop);
            }
            ENDCG
        }
    }
}
