Shader "Unlit/MatrixEffect"
{
    Properties
    {
        _Grid("Grid", Range(1.0, 50.0)) = 30.0
        _SpeedMin("Speed Min", Range(0.0, 10.0)) = 2.0
        _SpeedMax("Speed Max", Range(0.0, 30.0)) = 20.0
        _Density("Density", Range(0.0, 30.0)) = 5.0
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Grid;
            float _SpeedMin;
            float _SpeedMax;
            float _Density;

            // 浮動小数点を使った疑似的乱数
            float noise(float x)
            {
                return frac(sin(x) * 43758.5453);
            }

            // ベクトルを酸かった疑似的乱数
            float noise(float2 vect)
            {
                return frac(sin(dot(vect, float2(5372.156, 8452.751))) * 1643.268);
            }

            // ビット情報からピクセルがオンかオフかを取得する
            float texelValue(float2 ipos, float n)
            {
                // 5行3列のグリッドを作成し、ビット文字を表示(n = 21158)
                for(float i = 0.0; i < 5.0; i ++)
                {
                    for(float j = 0.0; j < 3.0; j ++)
                    {
                        if(i == ipos.y && j == ipos.x)
                        {
                            return step(1, fmod(n, 2.0));
                        }

                        n = ceil(n / 2.0);
                    }
                }

                return 0.0;
            }

            // グリッド内の1文字の描画処理
            float char(float2 st, float n)
            {
                // 文字内の領域(5行3列)のどこかを取得する
                st.x = st.x * 2.0 - 0.5;
                st.y = st.y * 1.2 - 0.1;

                float2 ipos = floor(st * float2(3.0, 5.0));

                n = floor(fmod(n, 20.0 + _Density));

                float digit = 0;

                // 表示すべきピクセルかどうかを判断し、範囲外であれば非表示
                if(n < 1) {digit = 9712; }
                else if(n < 2){digit = 21158.0; }
                else if(n < 3){digit = 25231.0; }
                else if(n < 4){digit = 23187.0; }
                else if(n < 5){digit = 23498.0; }
                else if(n < 6){digit = 31702.0; }
                else if(n < 7){digit = 25202.0; }
                else if(n < 8){digit = 30163.0; }
                else if(n < 9){digit = 18928.0; }
                else if(n < 10){digit = 23531.0; }
                else if(n < 11){digit = 29128.0; }
                else if(n < 12){digit = 17493.0; }
                else if(n < 13){digit = 7774.0; }
                else if(n < 14){digit = 311411.0; }
                else if(n < 15){digit = 29264.0; }
                else if(n < 16){digit = 3641.0; }
                else if(n < 17){digit = 31315.0; }
                else if(n < 18){digit = 31406.0; }
                else if(n < 19){digit = 30864.0; }
                else if(n < 20){digit = 31208.0; }
                else{digit = 1.0; }

                float tex = texelValue(ipos, digit);

                float2 borders = float2(1.0, 1.0);
                borders *= step(0.0, st) * step(0.0, 1.0 - st);

                return step(0.1, 1.0 - tex) * borders.x * borders.y;
            }

            fixed4 frag (v2f_img i) : SV_Target
            {
                // 画面をGrid分割したマス目を取得
                float2 ipos = floor(i.uv * _Grid);
                float2 fpos = frac(i.uv * _Grid);

                // 時間によって縦に流れるように見せる処理
                ipos.y += floor(_Time.y * max(_SpeedMin, _SpeedMax * noise(ipos.x)));
                // 文字データ0～20 + Densityからマスにどの文字を表示するかを決める
                float charNum = noise(ipos);
                float val = char(fpos, (20.0 + _Density) * charNum);
                return fixed4(0.0, val, 0.0, 1.0);
            }
            ENDCG
        }
    }
}
