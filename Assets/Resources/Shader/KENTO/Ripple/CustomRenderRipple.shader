Shader "Unlit/CustomRenderRipple"
{
    Properties
    {
        // _S2は係数 : 位相の変化する速度
        _S2("Phase Velocity^2", Range(0.0, 0.5)) = 0.2
        // 減衰係数
        _Attenuation("Attenuation", Range(0, 1)) = 0.999
        _DeltaUV("Delta UV", Float) = 0.1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            // 専用の定義済みvertexシェーダ関数
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag

            // 専用のcgincファイル
            #include "UnityCustomRenderTexture.cginc"

            half _S2;
            half _Attenuation;
            float _DeltaUV;
            sampler2D _MainTex;

            float4 frag (v2f_customrendertexture i) : SV_Target
            {
                float2 uv = i.globalTexcoord;

                // 1pxあたりの単位を計算する
                float du = 1.0 / _CustomRenderTextureWidth;
                float dv = 1.0 / _CustomRenderTextureHeight;
                float2 duv = float2(du, dv) * _DeltaUV;

                // 現在の位置のテクセルをフェッチ
                float2 c = tex2D(_SelfTexture2D, uv);

                //波動方程式
                //h(t + 1) = 2h + c(h(x + 1) + h(x - 1) + h(y + 1) + h(y - 1) - 4h) - h(t - 1)
                //今回、h(t + 1)は次のフレームでの波の高さを表す
                //R, Gをそれぞれ高さとして使用
                // 2h - h(t - 1) を先に計算
                float k = (2.0 * c.r) - c.g;
                float p = (k + _S2 * (
                tex2D(_SelfTexture2D, uv + duv.x).r
                + tex2D(_SelfTexture2D, uv - duv.x).r
                + tex2D(_SelfTexture2D, uv + duv.y).r
                + tex2D(_SelfTexture2D, uv - duv.y).r
                - 4.0 * c.r)
                ) * _Attenuation;

                // 現在の状態をテクスチャのR成分に、ひとつ前の（過去の）状態をG成分に書き込む
                return float4(p, c.r, 0, 0);
            }
            ENDCG
        }
    }
}
