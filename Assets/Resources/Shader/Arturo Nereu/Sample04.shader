Shader "Unlit/Sample04"
{
    Properties
    {
        // ここに書いたものがInspectorに表示される
        _RedValue("Red Value", Float) = 0.5
        _GreenValue("Green Value", Float) = 0.5
        _BlueValue("Blue Value", Float) = 0.5
        _AlphaValue("Alpha Value", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            // Render Queueの記述もしないとGame View での表示がおかしくなる
            "Queue" = "Transparent"
        }
        LOD 100

        // 不透明度を扱う場合は記述必須
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _RedValue;
            float _GreenValue;
            float _BlueValue;
            float _AlphaValue;

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
                // RGBにそれぞれのプロパティを当てはめる
                return half4(_RedValue, _GreenValue, _BlueValue, _AlphaValue);
            }
            ENDCG
        }
    }
}
