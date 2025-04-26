Shader "Unlit/RenderingStudy"
{
    Properties
    {
        _Color("Main Color", Color) = (0, 0, 0, 1)
        [KeywordEnum(OFF, ON)]
        _ZWrite("ZWrite", Int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]
        _ZTest("ZTest", Float) = 4
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry-1"
        }
        LOD 100

        Pass
        {
            ZWrite [_ZWrite]
            ZTest [_ZTest]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            half4 _Color;

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                return half4(_Color);
            }
            ENDCG
        }
    }
}
