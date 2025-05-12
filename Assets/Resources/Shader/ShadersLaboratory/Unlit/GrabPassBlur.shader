Shader "Unlit/GrabPassBlur"
{
    Properties
    {
        _Factor("Factor", Range(0, 5)) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
        }
        LOD 100

        GrabPass {}

        // 横方向のブラー
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            float _Factor;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeGrabScreenPos(o.pos);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 pixelCol = half4(0, 0, 0, 0);

                // 画面の左右方向に9点をサンプリングし、それぞれに重みを付けてぼかす
                #define ADDPIXEL(weight,kernelX) tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(float4(i.uv.x + _GrabTexture_TexelSize.x * kernelX * _Factor, i.uv.y, i.uv.z, i.uv.w))) * weight

                pixelCol += ADDPIXEL(0.05, 4.0);
                pixelCol += ADDPIXEL(0.09, 3.0);
                pixelCol += ADDPIXEL(0.12, 2.0);
                pixelCol += ADDPIXEL(0.15, 1.0);
                pixelCol += ADDPIXEL(0.18, 0.0);
                pixelCol += ADDPIXEL(0.15, - 1.0);
                pixelCol += ADDPIXEL(0.12, - 2.0);
                pixelCol += ADDPIXEL(0.09, - 3.0);
                pixelCol += ADDPIXEL(0.05, - 4.0);
                return pixelCol;
            }
            ENDCG
        }

        GrabPass {}

        // 縦方向のブラー
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
            };

            sampler2D _GrabTexture;
            float4 _GrabTexture_TexelSize;
            float _Factor;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = ComputeGrabScreenPos(o.pos);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 pixelCol = fixed4(0, 0, 0, 0);

                // 画面の上下方向に9点をサンプリングし、それぞれに重みを付けてぼかす
                #define ADDPIXEL(weight,kernelY) tex2Dproj(_GrabTexture,UNITY_PROJ_COORD(float4(i.uv.x, i.uv.y + _GrabTexture_TexelSize.y * kernelY * _Factor, i.uv.z, i.uv.w))) * weight

                pixelCol += ADDPIXEL(0.05, 4.0);
                pixelCol += ADDPIXEL(0.09, 3.0);
                pixelCol += ADDPIXEL(0.12, 2.0);
                pixelCol += ADDPIXEL(0.15, 1.0);
                pixelCol += ADDPIXEL(0.18, 0.0);
                pixelCol += ADDPIXEL(0.15, - 1.0);
                pixelCol += ADDPIXEL(0.12, - 2.0);
                pixelCol += ADDPIXEL(0.09, - 3.0);
                pixelCol += ADDPIXEL(0.05, - 4.0);
                return pixelCol;
            }
            ENDCG
        }
    }
}
