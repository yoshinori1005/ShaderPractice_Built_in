Shader "Unlit/SpriteDissolve"
{
    Properties
    {
        [PerRenderDatta]
        _MainTex ("Main Texture", 2D) = "white" {}
        _DissolveTex("Dissolve Texture", 2D) = "gray"{}
        _Threshold("Threshold", Range(0, 1.01)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _DissolveTex;
            float _Threshold;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float val = tex2D(_DissolveTex, i.uv).r;

                col.a *= step(_Threshold, val);

                return col;
            }
            ENDCG
        }
    }
}
