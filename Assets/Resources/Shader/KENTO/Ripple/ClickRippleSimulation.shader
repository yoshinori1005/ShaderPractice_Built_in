Shader "Unlit/ClickRippleSimulation"
{
    Properties
    {
        _S2("Phase Velocity^2", Range(0.0, 0.5)) = 0.2
        _Attenuation("Attenuation", Range(0, 1)) = 0.999
        _DeltaUV("Delta UV", Range(0.0, 0.5)) = 0.1
        _Displacement("Displacement", Range(1, 5)) = 3
    }

    CGINCLUDE
    #include "UnityCustomRenderTexture.cginc"

    half _S2;
    half _Attenuation;
    float _DeltaUV;
    float _Displacement;
    float _height;
    sampler2D _MainTex;

    // 波動方程式を計算するフラグメントシェーダー
    float4 frag(v2f_customrendertexture i) : SV_Target
    {
        float2 uv = i.globalTexcoord;

        float du = 1.0 / _CustomRenderTextureWidth;
        float dv = 1.0 / _CustomRenderTextureHeight;
        float2 duv = float2(du, dv) * _DeltaUV;

        float2 c = tex2D(_SelfTexture2D, uv);

        float k = (2.0 * c.r) - c.g;
        float p = (k + _S2 * (
        tex2D(_SelfTexture2D, uv + duv.x).r +
        tex2D(_SelfTexture2D, uv - duv.x).r +
        tex2D(_SelfTexture2D, uv + duv.y).r +
        tex2D(_SelfTexture2D, uv - duv.y).r - 4.0 * c.r
        )) * _Attenuation;

        return float4(p, c.r, 0, 0);
    }

    // クリックした時に利用されるフラグメントシェーダー
    float4 frag_left_click(v2f_customrendertexture i) : SV_Target
    {
        return float4(_Displacement, 0, 0, 0);
    }

    ENDCG

    SubShader
    {
        Cull Off
        ZWrite Off
        ZTest Always

        // デフォルトで利用されるPass
        Pass
        {
            Name "Update"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            ENDCG
        }

        // クリックした時に利用されるPass
        Pass
        {
            Name "LeftClick"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag_left_click
            ENDCG
        }
    }
}
