Shader "Unlit/Rim"
{
    Properties
    {
        _TintColor("Tint Color", Color) = (0, 0.5, 1, 1)
        _RimColor("Rim Color", Color) = (0, 1, 1, 1)
        _RimPower("Rim Power", Range(0, 2)) = 0.4
    }
    Category
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        SubShader
        {
            Pass
            {
                ZWrite On
                ColorMask 0
            }

            Name "RIM"

            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag

                #include "UnityCG.cginc"

                float4 _TintColor;
                float4 _RimColor;
                float _RimPower;

                struct appdata
                {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float4 vertex : SV_POSITION;
                    float2 uv : TEXCOORD0;
                    float3 worldPos : TEXCOORD1;
                    float3 normalDir : TEXCOORD2;
                };

                v2f vert (appdata v)
                {
                    v2f o;
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = v.uv;
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                    // 法線を取得
                    o.normalDir = UnityObjectToWorldNormal(v.normal);
                    return o;
                }

                float4 frag (v2f i) : SV_Target
                {
                    // カメラのベクトルを計算
                    float3 viewDirection = normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

                    // 法線とカメラのベクトルの内積を計算し、補間値を算出
                    float rim = 1.0 - saturate(dot(viewDirection, i.normalDir));

                    // 補間値で塗分け
                    float4 col = lerp(_TintColor, _RimColor, rim * _RimPower);

                    return col;
                }
                ENDCG
            }
        }
    }
}
