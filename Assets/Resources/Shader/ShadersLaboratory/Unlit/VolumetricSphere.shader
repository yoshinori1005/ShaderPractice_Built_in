Shader "Unlit/VolumetricSphere"
{
    Properties
    {
        _Center("Center", Vector) = (0, 0, 0, 0)
        _CubeColor("Cube Color", Color) = (1, 1, 1, 1)
        _SphereColor("Sphere Color", Color) = (1, 1, 1, 1)
        _Radius("Radius", Float) = 2
        _StepNumber("Step Number", Float) = 10
        _StepVal("Step Value", Float) = 0.1
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
                float3 worldPos : TEXCOORD1;
            };

            fixed4 _CubeColor;
            fixed4 _SphereColor;
            float3 _Center;
            float _Radius;
            float _StepNumber;
            float _StepVal;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                // 各ピクセルがワールド空間のどこにあるかを記録
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 raymarch(float3 worldPos, float3 viewDirection)
            {
                // カメラから光線をピクセルごとに飛ばし、球の中心範囲内なら_SphereColorに
                // 球の中心から範囲外の場合は_CubeColorを返す
                for(int i = 0; i < _StepNumber; i ++)
                {
                    if(distance(worldPos, _Center) < _Radius)
                    return _SphereColor;
                    worldPos += viewDirection * _StepVal;
                }

                return _CubeColor;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // ピクセルからカメラへ向かう視線ベクトルを計算
                float3 viewDirection = normalize(i.worldPos - _WorldSpaceCameraPos);
                return raymarch(i.worldPos, viewDirection);
            }
            ENDCG
        }
    }
}
