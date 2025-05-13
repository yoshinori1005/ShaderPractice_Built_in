Shader "Custom/TessellationDistanceCamera"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Tess("Tessellation Value", Range(0, 20)) = 1
        _DistanceMin("Distance Min", Float) = 0
        _DistanceMax("Distance Max", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard vertex:vert tessellate:tess
        #pragma target 4.6

        #include "UnityCG.cginc"
        #include "Tessellation.cginc"

        fixed4 _Color;
        float _Tess;
        float _DistanceMin;
        float _DistanceMax;

        // テッセレーション関数
        float4 tess(appdata_base v0, appdata_base v1, appdata_base v2)
        {
            return UnityDistanceBasedTess(
            v0.vertex,
            v1.vertex,
            v2.vertex,
            _DistanceMin,
            _DistanceMax,
            _Tess
            );
        }

        void vert(inout appdata_base v){}

        struct Input
        {
            float3 worldPos;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            o.Albedo = _Color;
        }
        ENDCG
    }
}
