Shader "Unlit/UVRotationWithMatrix"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Angle("Angle", Range(-6.3, 6.3)) = 0
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
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Angle;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // UVを回転させる場合スケーリングをしないとテクスチャがはみ出る
                // 回転をUVの中心に設定
                float2 pivot = float2(0.5, 0.5);

                // 回転行列による回転処理
                float cosAngle = cos(_Angle);
                float sinAngle = sin(_Angle);
                float2x2 rot = float2x2(cosAngle, - sinAngle, sinAngle, cosAngle);

                // 回転に応じたUVスケーリング
                float scale = abs(cos(_Angle)) + abs(sin(_Angle));
                float2 uv = (v.texcoord.xy - pivot) / scale;

                // ピボットを考慮した回転
                o.uv = mul(rot, uv);
                o.uv += pivot;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
