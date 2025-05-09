Shader "Unlit/WaterDistortion"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "grey"{}

        _Mitigation("Distortion Mitigation", Range(1, 30)) = 1
        _SpeedX("Speed Along X", Range(0, 5)) = 1
        _SpeedY("Speed Along Y", Range(0, 5)) = 1
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
            sampler2D _NoiseTex;
            float4 _MainTex_ST;
            float _Mitigation;
            float _SpeedX;
            float _SpeedY;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // Main TextureのTillingとOffsetを可能に
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half2 uv = i.uv;
                // Noise TextureのR値を取得
                half noiseVal = tex2D(_NoiseTex, uv).r;
                // UVのX, Yのそれぞれに時間とスピードを掛け、係数で除算し調整
                uv.x = uv.x + noiseVal * sin(_Time.y * _SpeedX) / _Mitigation;
                uv.y = uv.y + noiseVal * sin(_Time.y * _SpeedY) / _Mitigation;
                return tex2D(_MainTex, uv);
            }
            ENDCG
        }
    }
}
