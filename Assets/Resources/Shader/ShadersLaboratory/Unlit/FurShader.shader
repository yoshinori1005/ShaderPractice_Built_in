Shader "Unlit/FurShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FurTex("Fur Texture", 2D) = "white"{}
        _Diffuse("Diffuse Value", Range(0, 1)) = 1
        _FurLength("Fur Length", Range(0, 1)) = 0.5
        _CutOff("Alpha Cut Off", Range(0, 1)) = 0.5
        _Blur("Blur", Range(0, 1)) = 0.5
        _Thickness("Thickness", Range(0, 0.5)) = 0
    }

    CGINCLUDE

    fixed _Diffuse;

    inline fixed4 LambertDiffuse(float3 worldNormal)
    {
        float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
        float NdotL = max(0, dot(worldNormal, lightDir));
        return NdotL * _Diffuse;
    }
    ENDCG

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 dif : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.dif = LambertDiffuse(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb *= i.dif;
                return col;
            }
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.05

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.10

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.15

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.20

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.25

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.30

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.35

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.40

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.45

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.50

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.55

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.60

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.65

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.70

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.75

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.80

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.85

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.90

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define FURSTEP 0.95

            #include "Assets/Resources/FurHelper.cginc"
            ENDCG
        }
    }
}
