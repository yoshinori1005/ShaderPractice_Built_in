Shader "Unlit/FakeFog"
{
    Properties
    {
        [Header(Textures And Color)]
        [Space]
        _FogTex ("Fog Texture", 2D) = "white" {}
        [NoScaleOffset]
        _MaskTex("Mask Texture", 2D) = "white"{}
        _Color("Color", Color) = (1, 1, 1, 1)
        [Space(10)]
        [Header(Behaviour)]
        [Space]
        _ScrollDirX("Scroll Along X", Range(-1.0, 1.0)) = 1.0
        _ScrollDirY("Scroll Along Y", Range(-1.0, 1.0)) = 1.0
        _Speed("Speed", Float) = 1.0
        _Distance("Fading Distance", Range(1.0, 10.0)) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _FogTex;
            float4 _FogTex_ST;
            sampler2D _MaskTex;
            fixed4 _Color;
            fixed _ScrollDirX;
            fixed _ScrollDirY;
            float _Speed;
            float _Distance;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uv2 : TEXCOORD1;
                fixed4 vertCol : COLOR0;
            };



            v2f vert (appdata_full v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _FogTex);
                o.uv2 = v.texcoord;
                o.vertCol = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 切りテクスチャをスクロールさせる
                float2 uv = i.uv + fixed2(_ScrollDirX, _ScrollDirY) * _Speed * _Time.x;
                fixed4 col = tex2D(_FogTex, uv) * _Color * i.vertCol;
                // マスクテクスチャで表示範囲を制限
                col.a *= tex2D(_MaskTex, i.uv2).r;
                // カメラとの距離に応じて透明度を調整(距離が離れるほど透明)
                col.a *= 1 - ((i.pos.z / i.pos.w) * _Distance);
                return col;
            }
            ENDCG
        }
    }
}
