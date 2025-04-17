Shader "Unlit/ClickRippleTessellation"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _MainTex ("Texture", 2D) = "white" {}
        _DisTex("Displacement Texture", 2D) = "gray"{}
        _MinDist("Min Distance", Range(0.1, 50)) = 10
        _MaxDist("Max Distance", Range(0.1, 50)) = 25
        _TessFactor("Tessellation", Range(1, 50)) = 10
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
            #pragma hull hull
            #pragma domain domain

            #include "Tessellation.cginc"
            #include "UnityCG.cginc"

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

            struct HsInput
            {
                float4 position : POS;
                float3 normal : NORMAL;
                float2 texCoord : TEXCOORD0;
            };

            struct HsControlPointOutput
            {
                float3 position : POS;
                float3 normal : NORMAL;
                float2 texCoord : TEXCOORD0;
            };

            struct HsConstantOutput
            {
                float tessFactor[3] : SV_TessFactor;
                float insideTessFactor : SV_InsideTessFactor;
            };

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

            [domain("tri")]
            [partitioning("integer")]
            [outputtopology("triangle_cw")]
            [patchconstantfunc("hullConst")]
            [outputcontrolpoints(OUTPUT_PATCH_SIZE)]
            HsControlPointOutput hull(InputPatch<HsInput, INPUT_PATCH_SIZE> i, uint id : SV_OutputControlPointID)
            {
                HsControlPointOutput o = (HsControlPointOutput)0;
                o.position = i[id].position.xyz;
                o.normal = i[id].normal;
                o.texCoord = i[id].texCoord;
                return o;
            }

            HsConstantOutput hullConst(InputPatch<HsInput, INPUT_PATCH_SIZE> i)
            {
                HsConstantOutput o = (HsConstantOutput)0;
                float4 p0 = i[0].position;
                float4 p1 = i[1].position;
                float4 p2 = i[2].position;

                float4 tessFactor = UnityDistanceBasedTess(p0, p1, p2, _MinDist, _MaxDist, _TessFactor);

                o.tessFactor[0] = tessFactor.x;
                o.tessFactor[1] = tessFactor.y;
                o.tessFactor[2] = tessFactor.z;
                o.insideTessFactor = tessFactor.w;

                return o;
            }

            [domain("tri")]
            DsOutput domain(
            HsConstantOutput hsConst,
            const OutputPatch<HsControlPointOutput, INPUT_PATCH_SIZE> i,
            float3 bary : SV_DomainLocation
            )
            {
                DsOutput o = (DsOutput)0;

                float3 f3Position =
                bary.x * i[0].position +
                bary.y * i[1].position +
                bary.z * i[2].position;

                float3 f3Normal = normalize(
                bary.x * i[0].normal +
                bary.y * i[1].normal +
                bary.z * i[2].normal
                );

                o.texCoord =
                bary.x * i[0].texCoord +
                bary.y * i[1].texCoord +
                bary.z * i[2].texCoord;

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
    Fallback "Unlit/Texture"
}
