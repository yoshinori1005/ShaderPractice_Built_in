Shader "Unlit/Outline"
{
    Properties
    {
        _MainColor("Main Color", Color) = (1, 1, 1, 1)
        _FirstShadow("First Shadow", Range(0, 1)) = 0.3
        _SecondShadow("Second Shadow", Range(0, 1)) = 0.1
        _Thickness("Thickness", Float) = 0.04
        _OutlineColor("Outline Color", Color) = (0.1, 0.1, 0.1, 1)
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        // アウトラインのシェーダー
        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float _Thickness;
            fixed4 _OutlineColor;

            v2f vert (appdata v)
            {
                v2f o;
                // モデルを頂点方向に少し膨らませる(ローカル座標)
                v.vertex += float4(v.normal * _Thickness, 0);
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = _OutlineColor;
                return col;
            }
            ENDCG
        }

        // モデルを描画するトゥーンシェーダー
        Pass
        {
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
            };

            fixed4 _MainColor;
            float _SecondShadow;
            float _FirstShadow;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // ランバート計算を行ない、3段階に階調化
                half n1 = max(0, dot(i.normal, _WorldSpaceLightPos0.xyz));
                if(n1 <= 0.01f)n1 = _SecondShadow;
                else if(n1 <= 0.3f)n1 = _FirstShadow;
                else n1 = 1.0f;
                fixed4 col = fixed4(n1, n1, n1, 1) * _MainColor;
                return col;
            }
            ENDCG
        }
    }
}
