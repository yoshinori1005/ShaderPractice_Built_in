Shader "Custom/SoccerLawnField"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _BumpMap("Bump Map", 2D) = "bump"{}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)
        _SubColor("Sub Color", Color) = (1, 1, 1, 1)
        _Width("Width", Float) = 10
        _Offset("Offset", Float) = 0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Lambert vertex:vert

        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _BumpMap;
        fixed4 _MainColor;
        fixed4 _SubColor;
        fixed _Width;
        fixed _Offset;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_BumpMap;
            float3 modelPos;
        };

        void vert(inout appdata_full v, out Input o)
        {
            // 指定された変数の型を0に初期化するマクロ
            UNITY_INITIALIZE_OUTPUT(Input, o);
            // オブジェクトのローカル座標を保存
            o.modelPos = v.vertex;
        }

        void surf (Input IN, inout SurfaceOutput o)
        {
            // オブジェクトをX方向に_Widthで区切り、0(暗い色)と1(明るい色)を繰り返すようにしている
            fixed val = ceil(frac(floor((IN.modelPos.x - _Offset) / _Width) / 2));
            fixed3 col1 = tex2D(_MainTex, IN.uv_MainTex).rgb;
            o.Albedo = lerp(col1 * _MainColor, col1 * _SubColor, val);
            o.Alpha = 1;
            o.Normal = UnpackNormal(tex2D(_BumpMap, IN.uv_BumpMap));
        }
        ENDCG
    }
    FallBack "Diffuse"
}
