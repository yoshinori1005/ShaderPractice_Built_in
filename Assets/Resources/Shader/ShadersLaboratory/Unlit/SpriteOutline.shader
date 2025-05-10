Shader "Unlit/SpriteOutline"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Cull Off
        Blend One OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_TexelSize;
            fixed4 _Color;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャから色情報を取得し、アルファに応じて色の明るさを調整
                half4 c = tex2D(_MainTex, i.uv);
                c.rgb *= c.a;

                // アウトラインを_Colorに基づいて、ceilで切り上げや切り捨てを
                // 行なうことで0か1にし、アルファに応じて色の明るさを調整
                half4 outlineC = _Color;
                outlineC.a *= ceil(c.a);
                outlineC.rgb *= outlineC.a;

                // 上下左右のピクセルの透明度を確認
                // _MainTex_TexelSizeはピクセル単位のサイズで、1ピクセル分ずらし隣を確認
                fixed alpha_up = tex2D(_MainTex, i.uv + fixed2(0, _MainTex_TexelSize.y)).a;
                fixed alpha_down = tex2D(_MainTex, i.uv - fixed2(0, _MainTex_TexelSize.y)).a;
                fixed alpha_right = tex2D(_MainTex, i.uv + fixed2(_MainTex_TexelSize.x, 0)).a;
                fixed alpha_left = tex2D(_MainTex, i.uv - fixed2(_MainTex_TexelSize.x, 0)).a;

                // alphaの積が0(どれかが透明→縁取り)、積が1(元画像)
                // 中心ピクセルの周囲に透明部分があるならアウトラインをを描画
                return lerp(outlineC, c, ceil(alpha_up * alpha_down * alpha_right * alpha_left));
            }
            ENDCG
        }
    }
}
