Shader "Unlit/Tessellation"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _DisTex("Displacement Texture", 2D) = "gray"{}
        _MinDist("Min Distance", Range(0.1, 50)) = 10
        _MaxDist("Max Distance", Range(0.1, 50)) = 25
        // 分割レベル
        _TessFactor("Tessellation", Range(1, 50)) = 10
        // 変位
        _Displacement("Displacement", Range(0, 1)) = 0.3
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
            // hullがハルシェーダーであることをGPUに伝える
            #pragma hull hull
            // domainがドメインシェーダーであることをGPUに伝える
            #pragma domain domain

            #include "Tessellation.cginc"
            #include "UnityCG.cginc"

            // 定数を定義
            #define INPUT_PATCH_SIZE 3
            #define OUTPUT_PATCH_SIZE 3

            float _TessFactor;
            float _Displacement;
            float _MinDist;
            float _MaxDist;
            sampler2D _DisTex;
            sampler2D _MainTex;
            fixed4 _Color;

            struct appdata
            {
                float3 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            // 頂点シェーダーからハルシェーダーに渡す構造体
            struct HsInput
            {
                float4 position : POS;
                float3 normal : NORMAL;
                float2 texCoord : TEXCOORD0;
            };

            // ハルシェーダーからテッセレーター経由でドメインシェーダーに渡す構造体
            struct HsControlPointOutput
            {
                float3 position : POS;
                float3 normal : NORMAL;
                float2 texCoord : TEXCOORD0;
            };

            // Patch - Constant - Functionからテッセレーター経由でドメインシェーダーに渡す構造体
            struct HsConstantOutput
            {
                float tessFactor[3] : SV_TessFactor;
                float insideTessFactor : SV_InsideTessFactor;
            };

            // ドメインシェーダーからフラグメントシェーダーに渡す構造体
            struct DsOutput
            {
                float4 position : SV_Position;
                float2 texCoord : TEXCOORD0;
            };

            HsInput vert (appdata i)
            {
                HsInput o;
                o.position = float4(i.vertex, 1.0);
                o.normal = i.normal;
                o.texCoord = i.texcoord;
                return o;
            }

            // コントロールポイント : 頂点分割で使う制御点
            // パッチ : ポリゴン分割処理を行なう際に使用するコントロールポイントの集合

            // ハルシェーダー
            // パッチに対してコントロールポイントを割当てて出力する
            // コントロールポイントごとに1回実行
            // 分割に利用する形状を指定("tri", "quad", "isoline"から選択)
            [domain("tri")]
            // 分割方法("integer", "fractional_eve", "fractional_odd", "pow2"から選択)
            [partitioning("integer")]
            // 出力された頂点が形成するトポロジー(形状)("point", "line", "triangle_cw", "triangle_ccw"から選択)
            [outputtopology("triangle_cw")]
            // Patch - Constant - Functionの指定
            [patchconstantfunc("hullConst")]
            // 出力されるコントロールポイントの集合の数
            [outputcontrolpoints(OUTPUT_PATCH_SIZE)]

            HsControlPointOutput hull(InputPatch<HsInput, INPUT_PATCH_SIZE> i, uint id : SV_OutputControlPointID)
            {
                HsControlPointOutput o = (HsControlPointOutput)0;
                // 頂点シェーダーに対してコントロールポイントを割当て
                o.position = i[id].position.xyz;
                o.normal = i[id].normal;
                o.texCoord = i[id].texCoord;
                return o;
            }

            // Patch - Constant - Function
            // どの程度頂点を分割するかを決める係数を詰め込んでテッセレーターに渡す
            // パッチごとに1回実行される
            HsConstantOutput hullConst(InputPatch<HsInput, INPUT_PATCH_SIZE> i)
            {
                HsConstantOutput o = (HsConstantOutput)0;

                float4 p0 = i[0].position;
                float4 p1 = i[1].position;
                float4 p2 = i[2].position;
                /*頂点からカメラまでの距離を計算し、
                テッセレーション係数を距離に応じて計算しなおす(LOD)*/
                float4 tessFactor = UnityDistanceBasedTess(p0, p1, p2, _MinDist, _MaxDist, _TessFactor);

                o.tessFactor[0] = tessFactor.x;
                o.tessFactor[1] = tessFactor.y;
                o.tessFactor[2] = tessFactor.z;
                o.insideTessFactor = tessFactor.w;

                return o;
            }

            // ドメインシェーダー
            // テッセレーターから出てきた分割位置で頂点を計算し出力する
            // 分割に利用する形状を指定("tri", "quad", "isoline"から選択)
            [domain("tri")]
            DsOutput domain(
            HsConstantOutput hsConst,
            const OutputPatch<HsControlPointOutput, INPUT_PATCH_SIZE> i,
            float3 bary : SV_DomainLocation
            )
            {
                DsOutput o = (DsOutput)0;

                // 新しく出力する各頂点の座標を計算
                float3 f3Position =
                bary.x * i[0].position +
                bary.y * i[1].position +
                bary.z * i[2].position;

                // 新しく出力する各頂点の法線を計算
                float3 f3Normal = normalize(
                bary.x * i[0].normal +
                bary.y * i[1].normal +
                bary.z * i[2].normal
                );

                // 新しく出力する各頂点のUV座標を計算
                o.texCoord =
                bary.x * i[0].texCoord +
                bary.y * i[1].texCoord +
                bary.z * i[2].texCoord;

                //tex2Dlodはフラグメントシェーダー以外の箇所でもテクスチャをサンプリングできる関数
                //ここでrだけ利用することで波紋の高さに応じて頂点の変位を操作できる
                float dis = tex2Dlod(_DisTex, float4(o.texCoord, 0, 0)).r * _Displacement;
                f3Position.xyz += f3Normal * dis;

                o.position = UnityObjectToClipPos(float4(f3Position.xyz, 1.0));

                return o;
            }

            fixed4 frag (DsOutput i) : SV_Target
            {
                return tex2D(_MainTex, i.texCoord) * _Color;
            }
            ENDCG
        }
    }
}
