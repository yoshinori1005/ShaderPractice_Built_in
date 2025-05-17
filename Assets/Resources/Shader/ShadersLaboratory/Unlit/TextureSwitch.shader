Shader "Unlit/TextureSwitch"
{
    Properties
    {
        _PlayerPos("Player Position", Vector) = (0, 0, 0, 0)
        _Distance("Distance", Float) = 5
        _MainTex ("Main Texture", 2D) = "white" {}
        _SecondaryTex("Secondary Texture", 2D) = "whiter"{}
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
                float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _SecondaryTex;
            float4 _PlayerPos;
            float _Distance;

            v2f vert (appdata_base v)
            {
                v2f o;
                // ワールド座標を計算し、フラグメント関数で使用
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // プレイヤーとの距離に応じて、異なるテクスチャを使用
                if(distance(_PlayerPos.xyz, i.worldPos.xyz) > _Distance)
                return tex2D(_MainTex, i.uv);
                else
                return tex2D(_SecondaryTex, i.uv);
            }
            ENDCG
        }
    }
}
