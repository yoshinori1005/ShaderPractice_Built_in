Shader "Unlit/MatrixMix"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _MoveX("Move X", Range(-0.5, 0.5)) = 0
        _MoveY("Move Y", Range(-0.5, 0.5)) = 0
        _MoveZ("Move Z", Range(-0.5, 0.5)) = 0
        [KeywordEnum(X, Y, Z)] _AXIS("Axis", Int) = 0
        _Rotation("Rotation", Range(-6.28, 6.28)) = 0
        _ScaleX("Scale X", Range(0, 2)) = 1
        _ScaleY("Scale Y", Range(0, 2)) = 1
        _ScaleZ("Scale Z", Range(0, 2)) = 1
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
            float _MoveX;
            float _MoveY;
            float _MoveZ;
            float _Rotation;
            float _ScaleX;
            float _ScaleY;
            float _ScaleZ;

            v2f vert (appdata v)
            {
                v2f o;

                // 移動のための行列を計算
                float4x4 moveMatrix = float4x4(
                1, 0, 0, _MoveX,
                0, 1, 0, _MoveY,
                0, 0, 1, _MoveZ,
                0, 0, 0, 1
                );

                // 回転行列を作る
                float c = cos(_Rotation);
                float s = sin(_Rotation);

                float4x4 rotateMatrix = float4x4(
                1, 0, 0, 0,
                0, 1, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
                );

                #ifdef _AXIS_X

                // X軸中心の回転
                rotateMatrix = float4x4(
                1, 0, 0, 0,
                0, c, - s, 0,
                0, s, c, 0,
                0, 0, 0, 1
                );

                #elif _AXIS_Y

                // Y軸中心の回転
                rotateMatrix = float4x4(
                c, 0, s, 0,
                0, 1, 0, 0,
                - s, 0, c, 0,
                0, 0, 0, 1
                );

                #elif _AXIS_Z

                // Z軸中心の回転
                rotateMatrix = float4x4(
                c, - s, 0, 0,
                s, c, 0, 0,
                0, 0, 1, 0,
                0, 0, 0, 1
                );

                #endif

                // スケールのための行列を計算
                float4x4 scaleMatrix = float4x4(
                _ScaleX, 0, 0, 0,
                0, _ScaleY, 0, 0,
                0, 0, _ScaleZ, 0,
                0, 0, 0, 1
                );

                // 平行移動、回転、拡大縮小の行列を一気に計算
                v.vertex = mul(rotateMatrix, mul(scaleMatrix, mul(moveMatrix, v.vertex)));
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
