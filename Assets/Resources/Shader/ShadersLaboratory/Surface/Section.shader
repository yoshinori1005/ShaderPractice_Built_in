Shader "Custom/Section"
{
    Properties
    {
        _OutsideColor ("Outside Color", Color) = (1, 1, 1, 1)
        _SectionColor("Section Color", Color) = (0, 0, 0, 1)
        _EdgeWidth("Edge Width", Range(0.1, 0.9)) = 0.9
        _HeightVal("Height Value", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }
        LOD 200

        // Pass 1 : 通常部分の表示(上をカット)
        CGPROGRAM
        #pragma surface surf Standard

        #pragma target 3.0

        fixed4 _OutsideColor;
        float _HeightVal;

        struct Input
        {
            float3 worldPos;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // ワールド座標(Y軸)がHeightVal以上はカットし、残りの部分にOutsideColorを割当て
            if(IN.worldPos.y > _HeightVal)
            discard;
            o.Albedo = _OutsideColor;
        }
        ENDCG

        // Pass 2 : 断面を描画(表面)
        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
            };

            fixed4 _SectionColor;
            float _HeightVal;

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // ワールド座標(Y軸)がHeightVal以上はカットし、残りの部分にSectionColorを割当て
                if(i.worldPos.y > _HeightVal)
                discard;

                return _SectionColor;
            }
            ENDCG
        }

        // Pass 3 : エッジ(断面の厚み)を描画
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 worldPos : TEXCOORD0;
            };

            fixed4 _SectionColor;
            float _EdgeWidth;
            float _HeightVal;

            v2f vert(appdata_base v)
            {
                v2f o;
                // EdgeWidth分内側へ縮む
                v.vertex.xyz *= _EdgeWidth;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // ワールド座標(Y軸)がHeightVal以上はカットし、残りの部分にSectionColorを割当て
                if(i.worldPos.y > _HeightVal)
                discard;

                return _SectionColor;
            }
            ENDCG
        }

        // Pass 4 : エッジの外側も描画(裏側)
        Cull Front

        CGPROGRAM
        #pragma surface surf Standard vertex:vert

        struct Input
        {
            float3 worldPos;
        };

        fixed4 _OutsideColor;
        float _EdgeWidth;
        float _HeightVal;

        void vert(inout appdata_base v)
        {
            v.vertex.xyz *= _EdgeWidth;
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // ワールド座標(Y軸)がHeightVal以上はカットし、残りの部分にOutsideColorを割当て
            if(IN.worldPos.y > _HeightVal)
            discard;

            o.Albedo = _OutsideColor;
        }
        ENDCG
    }
}