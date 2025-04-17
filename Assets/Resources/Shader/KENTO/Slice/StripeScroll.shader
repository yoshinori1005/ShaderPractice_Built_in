Shader "Unlit/StripeScroll"
{
    Properties
    {
        // 色
        _StripeColor1("Stripe Color1", Color) = (1, 1, 1, 1)
        _StripeColor2("Stripe Color2", Color) = (1, 1, 1, 1)
        // スライスされる間隔
        _SliceSpace("Slice Space", Range(0, 1)) = 0.5
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

            fixed4 _StripeColor1;
            fixed4 _StripeColor2;
            float _SliceSpace;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv + _Time.x * 2;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 補間値の計算
                // step関数 : step(t, x)
                // x の値が t よりも小さい場合には 0、大きい場合には 1 を返す
                float interpolation = step(frac(i.uv.y * 15), _SliceSpace);

                // Color1 か Color2 のどちらかを返す
                fixed4 col = lerp(_StripeColor1, _StripeColor2, interpolation);

                // 計算し終わったピクセルの色を返す
                return col;
            }
            ENDCG
        }
    }
}
