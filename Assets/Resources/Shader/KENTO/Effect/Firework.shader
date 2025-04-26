Shader "Unlit/Firework"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        // 不当明度を利用するときに必要 文字通り、
        // 1 - フラグメントシェーダーのAlpha値という意味
        Blend SrcAlpha OneMinusSrcAlpha

        // 両面描画
        Cull Off

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
                // COLORを受け取る変数
                float4 color : COLOR;
                // TEXCOORD1を受け取る変数
                float alpha : TEXCOORD1;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                o.color = v.color;
                o.color.a = v.alpha;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャのサンプリング
                fixed4 col = tex2D(_MainTex, i.uv);
                // 引数の値が0以下なら描画しない すなわちAlphaが0.5以下なら描画しない
                clip(col.a - 0.5);
                float4 color = float4(col * i.color.xyz, i.color.w);
                return color * _Color;
            }
            ENDCG
        }
    }
}
