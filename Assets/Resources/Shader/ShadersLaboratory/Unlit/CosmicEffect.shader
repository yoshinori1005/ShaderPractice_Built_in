Shader "Unlit/CosmicEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Zoom("Zoom", Range(0.5, 20)) = 1
        _Speed("Speed", Range(0.01, 10)) = 1
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

            sampler2D _MainTex;
            half _Zoom;
            half _Speed;

            float4 vert (appdata_base v) : SV_POSITION
            {
                return UnityObjectToClipPos(v.vertex);
            }

            fixed4 frag (float4 i : VPOS) : SV_Target
            {
                // i.xyは現在描画しているピクセルの画面上の位置
                // i.xy / _ScreenParams.xyは画面サイズで割ることでUV座標に変換
                // 時間のコサイン値と時間のサイン値でぐるぐる回るようにする
                return tex2D(
                _MainTex,
                float2((i.xy / _ScreenParams.xy)
                * float2(_CosTime.x * _Speed, _SinTime.x * _Speed) / _Zoom)
                );
            }
            ENDCG
        }
    }
}
