Shader "Unlit/SwitchTexture"
{
    Properties
    {
        _FrontTex("Front Face Texture", 2D) = "white"{}
        _BackTex ("Back Face Texture", 2D) = "white" {}
        [Toggle] _RenderSwitch("Render Switch", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _FrontTex;
            sampler2D _BackTex;
            float _RenderSwitch;

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
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 frontCol = tex2D(_FrontTex, i.uv);
                float4 backCol = tex2D(_BackTex, i.uv);
                float4 finalCol = lerp(backCol, frontCol, _RenderSwitch);
                return finalCol;
            }
            ENDCG
        }
    }
}
