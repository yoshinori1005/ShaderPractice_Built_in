Shader "Unlit/Instancing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        CGINCLUDE
        #include "UnityCG.cginc"

        struct appdata
        {
            float4 vertex : POSITION;
            float2 uv : TEXCOORD0;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct v2f
        {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD0;
            float4 worldPos : TEXCOORD2;
            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        sampler2D _MainTex;
        float4 _MainTex_ST;

        v2f vert (appdata v)
        {
            v2f o;
            UNITY_SETUP_INSTANCE_ID(v);
            UNITY_TRANSFER_INSTANCE_ID(v, o);
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = TRANSFORM_TEX(v.uv, _MainTex);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex);
            return o;
        }

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
        UNITY_INSTANCING_BUFFER_END(Props)

        fixed4 frag (v2f i) : SV_Target
        {
            UNITY_SETUP_INSTANCE_ID(i);
            fixed4 col = tex2D(_MainTex, i.uv);
            col * UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
            return col;
        }
        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            ENDCG
        }
    }
}
