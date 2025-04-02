Shader "Unlit/RadialFIll"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Threshold("Threshold", Range(0, 1)) = 0
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
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Threshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                // 平面上の角度を求める
                fixed2 uv = 0.5 - i.uv;
                // 0度(右 : atan2(uv.y, uv.x))、90度(上 : atan2(- uv.x, uv.y))、
                // 180度(左 : atan2(- uv.y, - uv.x))、270度(下 : atan2(uv.x, - uv.y))
                // 時計回りの場合はatan2の第一引数を正負逆にする
                float rad = atan2(uv.y, uv.x);

                // - π～πを0～1の値に変換する
                float value = (rad + 3.14) / (2 * 3.14);

                // しきい値以下なら表示しない
                if(value < _Threshold) discard;

                col.a *= value;

                return col;
            }
            ENDCG
        }
    }
}
