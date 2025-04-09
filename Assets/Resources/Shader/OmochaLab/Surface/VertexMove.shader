Shader "Custom/VertexMove"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MoveSpeed("Move Speed", Float) = 100
        _MoveFactor("Move Factor", Float) = 100
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;
        float _MoveSpeed;
        float _MoveFactor;

        struct Input
        {
            float2 uv_MainTex;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);
            // 時間と速度に波の周期性(値が高いと密度が低くなり、値が低くなると密度が高く成る)
            float amp = 0.5 * sin(_Time * _MoveSpeed + v.vertex.x * _MoveFactor);
            v.vertex.xyz = float3(v.vertex.x, v.vertex.y + amp, v.vertex.z);
            // v.normal = normalize(float3(v.normal.x + offset_, v.normal.y, v.normal.z));
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
