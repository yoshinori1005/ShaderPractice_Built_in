Shader "Unlit/Echolocation"
{
    Properties
    {
        [HDR] _Color("Color", Color) = (1, 1, 1, 1)
        _Center("Center", Vector) = (0, 0, 0, 0)
        _Radius("Radius", Float) = 1
        _Width("Width", Float) = 0.4
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

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldPos : TEXCOORD1;
            };

            float4 _Color;
            float4 _Center;
            float _Radius;
            float _Width;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 頂点をワールド座標に変換して保存
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 中心点とピクセルの位置の距離を求める
                float dist = distance(_Center, i.worldPos);

                // 半径より少し内側を暗くする
                float val = 1 - step(dist, _Radius - 0.1) * 0.5;
                // 距離が_Width以上、_Radius以下の部分だけ描画される
                val = step(_Radius - _Width, dist) * step(dist, _Radius) * val;

                // valの値に応じて、それぞれのRGBを設定する
                // 中心に近いか遠いかで色の強さが変わる
                return fixed4(val * _Color.r, val * _Color.g, val * _Color.b, 1.0);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
