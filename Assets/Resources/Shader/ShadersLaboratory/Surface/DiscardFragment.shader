Shader "Custom/DiscardFragment"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _InsideColor ("Inside Color", Color) = (1, 0, 0, 1)
        _OutsideColor("Outside Color", Color) = (1, 1, 1, 1)
        _Value("Value", Range(0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        // 表面に関してのプログラム
        CGPROGRAM
        #pragma surface surf Lambert

        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _InsideColor;
        fixed4 _OutsideColor;
        float _Value;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);

            // Valueの値より大きいテクスチャのR値の箇所を描画しない
            if(c.r > _Value)
            {
                discard;
            }

            // 表面の描画する部分にOutsideColorを割当てる
            o.Albedo = _OutsideColor;
            o.Alpha = 1;
        }
        ENDCG

        // 裏面についてのプログラム
        Cull Front

        CGPROGRAM
        #pragma surface surf Lambert

        struct Input
        {
            float2 uv_MainTex;
        };

        sampler2D _MainTex;
        fixed4 _InsideColor;
        float _Value;

        void surf(Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);

            // Valueの値より大きいテクスチャのR値の箇所を描画しない
            if(c.r > _Value)
            {
                discard;
            }

            // 裏面の描画する部分にInsideColorを割当てる
            o.Albedo = _InsideColor;
            o.Alpha = 1;
        }
        ENDCG
    }
}
