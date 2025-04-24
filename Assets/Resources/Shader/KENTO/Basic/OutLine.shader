Shader "Unlit/OutLine"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
        _ShadowTex("Shadow Texture", 2D) = "white"{}
        _Strength("Strength", Range(0, 1)) = 0.5
        [HDR] _OutlineColor("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineWidth("Outline Width", Range(0.005, 0.1)) = 0.01
        [Toggle(USE_VERTEX_EXPANSION)]
        _UseVertexExpansion("Use Vertex for Outline", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        // 他のShaderのパスを利用
        UsePass "Unlit/ToonLit/TOON"

        // アウトラインを描画
        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shade_feature USE_VERTEX_EXPANSION

            #include "UnityCG.cginc"

            float4 _OutlineColor;
            float _OutlineWidth;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 n = 0;

                // モデルの頂点方向に拡大するパターン
                #ifdef USE_VERTEX_EXPANSION

                // モデルの原点からみた各頂点の位置ベクトルを計算
                float3 dir = normalize(v.vertex.xyz);

                // UNITY_MATRIX_IT_MVはモデルビュー行列の逆行列の転置行列
                // 各頂点の位置ベクトルをモデル座標系からビュー座標系に変換し正規化
                n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, dir));

                // モデルの法線方向に拡大するパターン
                #else

                // 法線をモデル座標系からビュー座標系に変換し正規化
                n = normalize(mul((float3x3)UNITY_MATRIX_IT_MV, v.normal));

                #endif

                // ビュー座標系に変換した法線を投影座標系に変換
                // アウトラインとして描画予定であるピクセルのXY方向のオフセット
                float2 offset = TransformViewToProjection(n.xy);
                o.pos.xy += offset * _OutlineWidth;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }
    }
}
