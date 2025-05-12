Shader "Unlit/VHSEffect"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _SecondaryTex("Secondary Texture", 2D) = "white"{}
        _OffsetNoiseX("Offset Noise X", Float) = 0
        _OffsetNoiseY("Offset Noise Y", Float) = 0
        _OffsetPosY("Offset Position Y", Float) = 0
        _OffsetColor("Offset Color", Range(0.005, 0.1)) = 0
        _OffsetDistortion("Offset Distortion", Float) = 500
        _Intensity("Mask Intensity", Range(0, 1)) = 1
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
            half _OffsetNoiseX;
            half _OffsetNoiseY;
            half _OffsetPosY;
            float _OffsetColor;
            half _OffsetDistortion;
            fixed _Intensity;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                // ノイズ用映像にズレを加えたUV(位置ずれした映像)
                o.uv2 = v.texcoord + float2(_OffsetNoiseX - 0.2f, _OffsetNoiseY);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 横方向(uv.x)にコサイン波による歪み→映像がビリビリ震える
                // 縦方向(uv.y)に_OffsetPosYを加えて映像が縦スクロール
                i.uv = float2(
                frac(i.uv.x + cos((i.uv.y + _CosTime.y) * 100) / _OffsetDistortion),
                frac(i.uv.y + _OffsetPosY)
                );

                // 色のにじみ(RGBずらし)
                // 赤はそのまま、緑は右下方向にズラしてサンプリング、青は左上方向にズラしてサンプリング
                fixed4 col = tex2D(_MainTex, i.uv);
                col.g = tex2D(_MainTex, i.uv + float2(_OffsetColor, _OffsetColor)).g;
                col.b = tex2D(_MainTex, i.uv + float2(- _OffsetColor, - _OffsetColor)).b;

                // _SecondaryTexの赤チャンネルが_Intensityより大きければ、その部分にノイズを表示
                // 中央付近の一部だけ(uv.y ≒ 0.5)に限定して表示→VHSにある「上下に走る線ノイズ」
                fixed4 col2 = tex2D(_SecondaryTex, i.uv2);

                return lerp(
                col,
                col2,
                ceil(col2.r - _Intensity) * (1 - ceil(saturate(abs(i.uv.y - 0.5) - 0.49)))
                );
            }
            ENDCG
        }
    }
}
