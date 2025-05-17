Shader "Unlit/GreenToTransparent"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Threshold("Threshold", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Threshold;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv1 : TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv1 = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv1);
                fixed4 val = ceil(saturate(col.g - col.r - _Threshold) * ceil(saturate(col.g - col.b - _Threshold)));
                return lerp(col, fixed4(0, 0, 0, 0), val);
            }
            ENDCG
        }
    }
}
