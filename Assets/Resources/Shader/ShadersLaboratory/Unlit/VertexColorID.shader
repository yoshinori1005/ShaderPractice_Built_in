Shader "Unlit/VertexColorID"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _Value1("Value1", Range(1, 50)) = 2
        _Value2("Value2", Range(1, 50)) = 7
        _Value3("Value3", Range(1, 50)) = 5
        _Color1("Color1", Color) = (1, 1, 1, 1)
        _Color2("Color2", Color) = (1, 1, 1, 1)
        _Color3("Color3", Color) = (1, 1, 1, 1)
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
                fixed4 col : COLOR0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Value1;
            float _Value2;
            float _Value3;
            fixed4 _Color1;
            fixed4 _Color2;
            fixed4 _Color3;

            // SV_VERTEXID : 現在の頂点番号(ID)を取得するセマンティクス
            v2f vert (appdata_base v, uint id : SV_VERTEXID)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.col = fixed4(1, 1, 1, 1);

                // 条件を複数満たした場合は色を混ぜる
                // idをValue1で割った余りが0なら、Color1を割当てる(Value1の倍数の頂点だけ色を変える)
                if(fmod(id, floor(_Value1)) == 0)
                o.col *= _Color1;

                // idをValue2で割った余りが0なら、Color2を割当てる(Value2の倍数の頂点だけ色を変える)
                if(fmod(id, floor(_Value2)) == 0)
                o.col *= _Color2;

                // idをValue3で割った余りが0なら、Color3を割当てる(Value3の倍数の頂点だけ色を変える)
                if(fmod(id, floor(_Value3)) == 0)
                o.col *= _Color3;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // テクスチャをベースに頂点の色を割当てる
                fixed4 col = tex2D(_MainTex, i.uv);
                return i.col * col;
            }
            ENDCG
        }
    }
}
