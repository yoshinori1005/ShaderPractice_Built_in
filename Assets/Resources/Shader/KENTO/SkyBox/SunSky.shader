Shader "Unlit/Sun"
{
    Properties
    {
        _BGColor("Background Color", Color) = (0.05, 0.9, 1, 1)
        _SunColor("Sun Color", Color) = (1, 0.8, 0.5, 1)
        _SunDir("Sun Direction", Vector) = (0, 0.5, 1, 0)
        _SunStrength("Sun Strength", Range(0, 200)) = 30
    }
    SubShader
    {
        Tags
        {
            // 最背面に描画するのでBackground
            "RenderType" = "Background"
            "Queue" = "Background"
            // 設定するとマテリアルのプレビューがスカイボックスになる
            "PreviewType" = "SkyBox"
        }
        LOD 100

        Pass
        {
            // 常に最背面に描画するので深度情報の書き込み不要
            ZWrite Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _BGColor;
            fixed4 _SunColor;
            float3 _SunDir;
            float _SunStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 太陽の位置ベクトル正規化
                float3 dir = normalize(_SunDir);
                // 太陽の位置ベクトルと描画されるピクセルの位置ベクトルの内積
                float angle = dot(dir, i.uv);
                // pow(x, y)は x を y 乗する
                // 0 < max(0, angle) < 1 なので _SunStrength を大きくするほど計算結果は 0 に近づく
                fixed4 c = _BGColor + _SunColor * pow(max(0, angle), _SunStrength);
                return c;
            }
            ENDCG
        }
    }
}
