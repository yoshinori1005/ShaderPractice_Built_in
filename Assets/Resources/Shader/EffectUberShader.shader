Shader "Unlit/EffectUberShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // ブレンドモード用の列挙体
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendSrc("Blend Src", Float) = 5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _BlendDst("Blend Dst", Float) = 10
        // Zテスト用の列挙体
        [Enum(UnityEngine.Rendering.CompareFunction)]
        _ZTestMode("ZTest Mode", Float) = 0
        [Toggle]
        _ZWriteParam("ZWrite", Float) = 0
        [Enum(UnityEngine.Rendering.CullMode)]
        _CullMode("Cull Mode", Float) = 0

        [Toggle(_USE_LERP_COLOR)]
        _UseLerpColor("Use Lerp Color", Float) = 0
        _LerpColorWhite("Color White", Color) = (1, 1, 1, 1)
        _LerpColorBlack("Color Black", Color) = (0, 0, 0, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend [_BlendSrc] [_BlendDst]
        ZTest [_ZTestMode]
        ZWrite [_ZWriteParam]
        Cull [_CullMode]

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ _USE_LERP_COLOR

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
            fixed4 _LerpColorWhite;
            fixed4 _LerpColorBlack;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャの色を取得
                fixed4 col = tex2D(_MainTex, i.uv);
                #if _USE_LERP_COLOR
                // テクスチャの色から輝度を計算
                fixed lum = Luminance(col.rgb);
                // 黒に入れる色、白に入れる色を輝度で補間する
                col = lerp(_LerpColorBlack, _LerpColorWhite, lum);
                #endif
                return col;
            }
            ENDCG
        }
    }
}
