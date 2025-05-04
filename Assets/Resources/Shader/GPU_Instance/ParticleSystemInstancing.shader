Shader "Unlit/ParticleSystemInstancing"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle]
        _UseInstancingCustomVertexStreams("Use Instancing And Custom Vertex Streams", Float) = 0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask RGB
        Cull Off
        Lighting Off
        ZWrite Off

        Pass
        {
            CGPROGRAM

            // OpenGL ES 2.0を対象外にする
            // MyParticleInstanceData内にfloat3x4型を使うことにより自動的に追加されるコード
            #pragma exclude_renderers gles
            #pragma vertex vert
            #pragma fragment frag
            // インスタンシング用バリアントを作る
            #pragma multi_compile_instancing
            // プロシージャルインスタンシングを有効化
            #pragma instancing_options procedural:vertInstancingSetup
            #pragma multi_compile _ _USEINSTANCINGCUSTOMVERTEXSTREAMS_ON

            // インスタンシングかつCustom Vertex Streams使用フラグが立っているときのみ独自の構造体を定義
            #ifdef _USEINSTANCINGCUSTOMVERTEXSTREAMS_ON
            // 独自のインスタンシング用のデータ構造を定義する
            #define UNITY_PARTICLE_INSTANCE_DATA MyParticleInstanceData
            #define UNITY_PARTICLE_INSTANCE_DATA_NO_ANIM_FRAME

            struct MyParticleInstanceData
            {
                float3x4 transform;
                uint color;
                // ここまではDefaultParticleInstanceDataに定義されているもの

                // ここから独自のデータを定義
                float3 noise;
            };
            #endif

            #include "UnityCG.cginc"
            // 上記のvertInstancingSetupが定義されているcgincをインクルード
            #include "UnityStandardParticleInstancing.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
                // Custom Vertex Streams使用フラグが立っていないときのみ独自のデータ（ノイズ）を定義する
                #if !(defined(_USEINSTANCINGCUSTOMVERTEXSTREAMS_ON)&&defined(UNITY_PARTICLE_INSTANCING_ENABLED))
                float3 noise : TEXCOORD1;
                #endif
                // 頂点情報にインスタンスIDを追加
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                // インスタンスIDを初期化
                UNITY_SETUP_INSTANCE_ID(v);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.uv = v.uv;

                #ifdef UNITY_PARTICLE_INSTANCING_ENABLED
                // インスタンシング対象の値を取得
                vertInstancingColor(o.color);
                // これを書かないとこのあとo.colorを加工する際に一部端末でおかしくなる可能性がある
                o.color.rgb = min(1, o.color.rgb);
                vertInstancingUVs(v.uv, o.uv);
                #endif

                // Custom Vertex Streams使用フラグが立っているときのみ独自のデータ（ノイズ）を適用する
                #if defined(_USEINSTANCINGCUSTOMVERTEXSTREAMS_ON)&&defined(UNITY_PARTICLE_INSTANCING_ENABLED)
                // 独自に定義したデータから取得する
                UNITY_PARTICLE_INSTANCE_DATA data = unity_ParticleInstanceData[unity_InstanceID];
                o.color.rgb *= data.noise;
                #else
                // インスタンシングが無効な時の処理
                o.color.rgb *= v.noise;
                #endif

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv) * i.color;
                return col;
            }
            ENDCG
        }
    }
}
