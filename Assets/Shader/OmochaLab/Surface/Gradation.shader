Shader "Unlit/Gradation"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Displacement("Displacement", Float) = 0.0
    }
    SubShader
    {
        Tags { "RenderType" = "Transparent" }
        Cull Off ZWrite On Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD0;
            };

            fixed4 _Color;
            float _Displacement;

            v2f vert (appdata_base v)
            {
                v2f o;
                float3 n = UnityObjectToWorldNormal(v.normal);
                // o.pos = UnityObjectToClipPos(v.vertex);
                // 頂点を動かして飛び散るエフェクト
                o.pos = UnityObjectToClipPos(v.vertex) + float4(n * _Displacement, 0);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                return o;
            }

            half4 frag (v2f i) : COLOR
            {
                float4 red = float4(255.0 / 255, 70.0 / 255, 150.0 / 255, 1);
                float4 blue = float4(90.0 / 255, 90.0 / 255, 250.0 / 255, 1);

                return lerp(red, blue, i.worldPos.y * 0.2);
            }
            ENDCG
        }
    }
    Fallback Off
}
