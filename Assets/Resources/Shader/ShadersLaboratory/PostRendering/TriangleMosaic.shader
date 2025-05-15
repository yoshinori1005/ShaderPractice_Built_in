Shader "Unlit/TriangleMosaic"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _TileNumX("Tile Number Along X", Float) = 0
        _TileNumY("Tile Number Along Y", Float) = 0
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
                float4 screenUV : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _TileNumX;
            float _TileNumY;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 各ピクセルの画面上での位置を取得
                o.screenUV = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // 画面上のUV座標を取得
                float2 uv = i.screenUV.xy / i.screenUV.w;
                // どのタイル(三角形)に属しているか判定
                float2 tileNum = float2(_TileNumX, _TileNumY);
                // UV2はピクセルが属するタイルの左下のUV
                float2 uv2 = floor(uv * tileNum) / tileNum;
                // タイルの中のローカル位置を計算
                uv -= uv2;
                uv *= tileNum;

                // 2つのstep関数で三角形の上側か下側かを判定し、
                // 中心を少しずらしてサンプル位置を決定
                fixed4 col = tex2D(_MainTex, uv2 + float2(step(1 - uv.y, uv.x) / (2 * _TileNumX),
                step(uv.x, uv.y) / (2 * _TileNumY)));

                return col;
            }
            ENDCG
        }
    }
}
