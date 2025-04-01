Shader "Custom/CircleDraw"
{
    Properties
    {
        _Speed("Speed", Float) = 100
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard
        #pragma target 3.0

        struct Input
        {
            float3 worldPos;
        };

        float _Speed;

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float dist = distance(fixed3(0, 0, 0), IN.worldPos);

            // 円の描き方
            // float radius = 2;
            // if(radius < dist)
            // {
                // o.Albedo = fixed4(110 / 255.0, 87 / 255.0, 139 / 255.0, 1);
            // }
            // else
            // {
                // o.Albedo = fixed4(1, 1, 1, 1);
            // }

            // リングの描き方
            // float radius = 2;
            // if(radius < dist && dist < radius + 0.2)
            // {
                // o.Albedo = fixed4(1, 1, 1, 1);
            // }
            // else
            // {
                // o.Albedo = fixed4(110 / 255.0, 87 / 255.0, 139 / 255.0, 1);
            // }

            // リングをたくさん描く方法
            // float val = abs(sin(dist * 3.0));
            // if(val > 0.98)
            // {
                // o.Albedo = fixed4(1, 1, 1, 1);
            // }
            // else
            // {
                // o.Albedo = fixed4(110 / 255.0, 87 / 255.0, 139 / 255.0, 1);
            // }

            // リングを動かす
            float val = abs(sin(dist * 3.0 - _Time * _Speed));
            if(val > 0.98)
            {
                o.Albedo = fixed4(1, 1, 1, 1);
            }
            else
            {
                o.Albedo = fixed4(110 / 255.0, 87 / 255.0, 139 / 255.0, 1);
            }
        }
        ENDCG
    }
    FallBack "Diffuse"
}
