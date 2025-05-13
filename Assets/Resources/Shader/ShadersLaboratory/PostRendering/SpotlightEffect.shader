Shader "Unlit/SpotlightEffect"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Main Texture", 2D) = "white" {}
        _CenterX("Center X", Range(0.0, 0.5)) = 0.25
        _CenterY("Center Y", Range(0.0, 0.5)) = 0.25
        _Radius("Radius", Range(0.01, 0.5)) = 0.1
        _Sharpness("Sharpness", Range(1, 20)) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _CenterX;
            float _CenterY;
            float _Radius;
            float _Sharpness;

            fixed4 frag (v2f_img i) : SV_Target
            {
                // 指定した中心座標とワールド座標のスクリーン上の位置を計算
                float dis = distance(
                float2(_CenterX, _CenterY),
                ComputeScreenPos(i.pos).xy / _ScreenParams.x
                );
                fixed4 col = tex2D(_MainTex, i.uv);

                // 計算した位置に半径Radiusの円を描画
                return col * (1 - pow(dis / _Radius, _Sharpness));
            }
            ENDCG
        }
    }
}
