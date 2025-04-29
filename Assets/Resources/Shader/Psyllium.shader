Shader "Unlit/Psyllium"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _EmissionStrength("Emission Strength", Float) = 1
        [Toggle] _UseRandomColor("Use Random Color", Float) = 0
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
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            UNITY_INSTANCING_BUFFER_START(Props)
            UNITY_DEFINE_INSTANCED_PROP(float4, _InstanceColor)
            UNITY_INSTANCING_BUFFER_END(Props)

            float4 _Color;
            float _EmissionStrength;
            float _UseRandomColor;

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                o.pos = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                float4 baseColor = _Color;

                if(_UseRandomColor > 0.5)
                {
                    baseColor = UNITY_ACCESS_INSTANCED_PROP(Props, _InstanceColor);
                }

                return baseColor * _EmissionStrength;
            }
            ENDCG
        }
    }
}
