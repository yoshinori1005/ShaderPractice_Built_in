Shader "Unlit/MatrixMove"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _MoveX("Move X", Range(-0.5, 0.5)) = 0
        _MoveY("Move Y", Range(-0.5, 0.5)) = 0
        _MoveZ("Move Z", Range(-0.5, 0.5)) = 0
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
                v.vertex = mul(moveMatrix, v.vertex);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャのサンプリング
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}
