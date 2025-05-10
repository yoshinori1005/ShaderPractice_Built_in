Shader "Unlit/DistortingGrabPass"
{
    Properties
    {
        _Intensity("Intensity", Range(0, 50)) = 0
    }
    SubShader
    {
        // その時点の画面の見た目をテクスチャとして取り込む
        GrabPass { "_GrabTexture" }

        Pass
        {
            Tags
            {
                "RenderType" = "Transparent"
                "Queue" = "Transparent"
            }
            LOD 100

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                half4 pos : SV_POSITION;
                half4 grabPos : TEXCOORD0;
            };

            sampler2D _GrabTexture;
            half _Intensity;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 背景画像の取り込み位置をgrabPosに計算
                o.grabPos = ComputeGrabScreenPos(o.pos);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                // 縦方向にスキャンラインのように歪ませる
                i.grabPos.x += sin((_Time.y + i.grabPos.y) * _Intensity) / 20;
                // tex2Dprojで歪んだ位置から元の画面画像を取得
                fixed4 color = tex2Dproj(_GrabTexture, UNITY_PROJ_COORD(i.grabPos));
                return color;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
