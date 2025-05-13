Shader "Unlit/AlphaDependingDistance"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Radius("Radius", Range(0.001, 500)) = 10
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha

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
                float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Radius;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                // オブジェクトのワールド座標とカメラの位置を比較し、
                // 距離に応じてアルファ値を変更する
                float dis = distance(i.worldPos, _WorldSpaceCameraPos);
                col.a = saturate(dis / _Radius);
                return col;
            }
            ENDCG
        }
    }
}
