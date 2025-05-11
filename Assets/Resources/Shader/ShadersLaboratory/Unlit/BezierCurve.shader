Shader "Unlit/BezierCurve"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _ControlPoint("Control Point", Vector) = (1, 1, 1, 1)
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
            float4 _MainTex_ST;
            float4 _ControlPoint;

            v2f vert (appdata_base v)
            {
                v2f o;

                // 元のメッシュの頂点の位置を中心を0とみなし正規化
                float3 begin = float3(- 0.5, v.vertex.y, v.vertex.z);
                float3 end = float3(0.5, v.vertex.y, v.vertex.z);

                float vertX = v.vertex.x + 0.5;

                // ベジェ曲線(2次)の式に基づく計算
                // B(t) = (1 - t) ^ 2 * P0 + 2 * (1 - t) * t * P1 + t ^ 2 * P2
                // P0 : 始点、P1 : 制御点(曲がる位置)、P2 : 終点、t : 0～1の間の数(割合)
                v.vertex.xyz = (1 - vertX) * (1 - vertX) * begin.xyz
                + 2.0 * (1 - vertX) * vertX * _ControlPoint.xyz
                + vertX * vertX * end.xyz;

                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
