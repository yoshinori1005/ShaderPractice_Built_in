Shader "Custom/ExampleSurfaceShader"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white"{}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }

        CGPROGRAM
        // surfaceディレクティブで使用する関数やライティングの方法を定義する
        // ランバート(非PBR)ライティング
        // #pragma surface surf Lambert
        // スタンダードシェーダー
        // #pragma surface surf Standard
        // vertexオプションを追加する
        // #pragma surface surf Standard vertex : vert
        // finalcolorオプションを追加(ライティング計算後に色調整できる)
        // #pragma surface surf Standard vertex : vert finalcolor : final
        // 自作したライティング関数からLightingのPrefixを削除したもの
        #pragma surface surf HalfLambert vertex:vert finalcolor:final

        // surf関数の入力に使う構造体
        struct Input
        {
            float2 uv_MainTex;
            // ビュー方向
            float3 viewDir;
            // 独自の変数を頂点シェーダーからsurfに値を渡すことも出来る
            // 頂点シェーダーから受け渡す変数を定義する
            float3 rimColor;
        };

        sampler2D _MainTex;

        // 頂点シェーダーはappdata_full構造体を引数に取る
        // 第二引数にInputを指定する
        void vert(inout appdata_full v, out Input o)
        {
            // Input構造体は初期化が必要
            // UNITY_INITIALIZE_OUTPUTでInputを初期化
            UNITY_INITIALIZE_OUTPUT(Input, o);
            // Input構造体を通してsurf関数に値を受け渡す
            // Inputの変数に値を代入
            o.rimColor = float3(1, 0, 0);
        }

        // アウトプット用構造体もSurfaceOutputからSurfaceOutputStandardに変更
        void surf (Input IN, inout SurfaceOutput o)
        {
            o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
            // 金属かどうか
            // o.Metallic = 1;
            // // 表面のなめらかさ
            // o.Smoothness = 0.5;
            // // IN.viewDirでビュー咆哮が取得できる
            // o.Emission = (1 - dot(IN.viewDir, o.Normal)) * IN.rimColor;
        }

        // カスタムライティング関数
        // Lightingから始まる名前を付ける必要がある
        half4 LightingHalfLambert(SurfaceOutput s, half3 lightDir, half atten)
        {
            half NdotL = dot(s.Normal, lightDir);
            half4 c;
            c.rgb = s.Albedo * _LightColor0.rgb * atten * (NdotL * 0.5 + 0.5);
            c.a = s.Alpha;
            return c;
        }

        // finalcolor関数
        void final(Input IN, SurfaceOutput o, inout fixed4 color)
        {
            color = pow(color, 3);
        }
        ENDCG
    }
}
