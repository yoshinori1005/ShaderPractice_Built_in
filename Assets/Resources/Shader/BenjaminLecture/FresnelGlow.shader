Shader "Unlit/FresnelGlow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Distortion)]
        _DistTex("Distortion Texture", 2D) = "white"{}
        _DistIntensity("Distortion Intensity", Range(0, 10)) = 0

        [Header(Fresnel)]
        _FresnelColor("Fresnel Color", Color) = (1, 1, 1, 1)
        _FresnelIntensity("Fresnel Intensity", Range(0, 10)) = 0
        _FresnelRamp("Fresnel Ramp", Range(0, 10)) = 0

        [Header(Inverse Fresnel)]
        _InvFresnelColor("Inverse Fresnel Color", Color) = (1, 1, 1, 1)
        _InvFresnelIntensity("Inverse Fresnel Intensity", Range(0, 10)) = 0
        _InvFresnelRamp("Inverse Fresnel Ramp", Range(0, 10)) = 0

        [Header(Normal)]
        [Toggle] NORMAL_MAP("Normal Mapping", Float) = 0
        _NormalMap("Normal Map", 2D) = "white"{}
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile__NORMAL_MAP_ON
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                float3 tangent : TEXCOORD3;
                float3 bitangent : TEXCOORD4;

            };

            sampler2D _MainTex, _NormalMap, _DistTex;
            float4 _MainTex_ST, _FresnelColor, _InvFresnelColor;

            float _FresnelIntensity, _FresnelRamp, _DistIntensity, _InvFresnelIntensity, _InvFresnelRamp;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);

                #if NORMAL_MAP_ON
                o.tangent = UnityObjectToWorldDir(v.tangent);
                o.bitangent = cross(o.tangent, o.normal);
                #endif

                o.viewDir = normalize(WorldSpaceViewDir(v.vertex));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float distortion = tex2D(_DistTex, i.uv + _Time.y).r;

                float3 finalNormal = i.normal;
                #if NORMAL_MAP_ON
                float3 normalMap = UnpackNormal(tex2D(_NormalMap, i.uv));
                finalNormal = normalMap.r * i.tangent + normalMap.g * i.bitangent + normalMap.b * i.normal;
                #endif

                // 常に正の値にした法線と視線方向の内積
                float NdotV = 1 - max(0, dot(finalNormal, i.viewDir));
                NdotV *= distortion * _DistIntensity;
                NdotV = pow(NdotV, _FresnelRamp) * _FresnelIntensity;
                float3 fresnelColor = NdotV * _FresnelColor;

                float inverseNdotV = max(0, dot(finalNormal, i.viewDir));
                inverseNdotV *= distortion * _DistIntensity;
                inverseNdotV = pow(inverseNdotV, _InvFresnelRamp) * _InvFresnelIntensity;
                float3 invFresnelColor = inverseNdotV * _InvFresnelColor;
                float3 finalColor = fresnelColor + invFresnelColor;
                float fresnelAlpha = saturate(NdotV + inverseNdotV);

                return fixed4(finalColor, fresnelAlpha);
            }
            ENDCG
        }
    }
}
