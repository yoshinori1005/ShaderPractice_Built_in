Shader "Unlit/FlowMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FlowTex("Flow Texture", 2D) = "white"{}
        _UVTex("UV Texture", 2D) = "white"{}
        _FlowSpeedTile("Flow Speed/Tile", Vector) = (0, 0, 0, 0)
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
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _FlowTex;
            sampler2D _UVTex;
            float4 _FlowSpeedTile;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 uv = tex2D(_UVTex, i.uv.xy);
                uv.rg *= _FlowSpeedTile.zw;
                uv.rg += frac(_Time.y * _FlowSpeedTile.xy);
                fixed4 flow = tex2D(_FlowTex, uv.rg) * uv.a;
                fixed4 col = tex2D(_MainTex, i.uv.xy) * (1 - uv.a * flow.a);

                return flow + col;
            }
            ENDCG
        }
    }
}
