Shader "Unlit/MatrixRotation"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        // キーワードのEnumを定義できる
        [KeywordEnum(X, Y, Z)] _Axis("Axis", Int) = 0
        _Rotation("Rotation", Range(-6.28, 6.28)) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // ここでシェーダーキーワードを定義する
            #pragma multi_compile _AXIS_X _AXIS_Y _AXIS_Z

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float _Rotation;

            v2f vert (appdata v)
            {
                v2f o;
                // 回転行列を作る
                float c = cos(_Rotation);
                float s = sin(_Rotation);

                #ifdef _AXIS_X

                // X軸中心の回転(定義したキーワードで判定)
                float4x4 rotationMatrixX = float4x4(
                1, 0, 0, 0,
                0, c, - s, 0,
                0, s, c, 0,
                0, 0, 0, 1
                );
                v.vertex = mul(rotationMatrixX, v.vertex);

                #elif _AXIS_Y

                // Y軸中心の回転(定義したキーワードで判定)
                float4x4 rotationMatrixY = float4x4(
                c, 0, s, 0,
                0, 1, 0, 0,
                - s, 0, c, 0,
                0, 0, 0, 1
                );
                v.vertex = mul(rotationMatrixY, v.vertex);

                #elif _AXIS_Z

                // Z軸中心の回転(定義したキーワードで判定)
                float4x4 rotationMatrixZ = float4x4(
                c, - s, 0, 0,
                s, c, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
                );
                v.vertex = mul(rotationMatrixZ, v.vertex);

                #endif

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
