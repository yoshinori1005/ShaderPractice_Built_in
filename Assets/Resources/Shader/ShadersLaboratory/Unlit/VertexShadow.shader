Shader "Unlit/VertexShadow"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                LIGHTING_COORDS(0, 1)
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                // 3D空間の頂点を画面に表示できるように変換
                o.pos = UnityObjectToClipPos(v.vertex);
                // 影の計算に必要なライトの情報を次の処理に渡すマクロ
                TRANSFER_VERTEX_TO_FRAGMENT(o);
                return o;
            }

            float4 _Color;
            fixed4 _LightColor0;

            fixed4 frag (v2f i) : SV_Target
            {
                // LIGHT_ATTENUATIONはそのピクセルがどれだけ光を受けているか計算する
                // 1.0に近ければ明るい(光が強い)、0.0に近ければ位(影の中)
                float attenuation = LIGHT_ATTENUATION(i);
                // _LightColor0はシーン内のメインライトの色(Directional Lightなど)
                return _Color * attenuation * _LightColor0;
            }
            ENDCG
        }
    }
}
