//
// Noise Shader Library for Unity - https : //github.com / keijiro / NoiseShader
//
// Original work (webgl - noise) Copyright (C) 2011 Stefan Gustavson
// Translation and modification was made by Keijiro Takahashi.
//
// このシェーダは webgl - noise GLSL シェーダに基づいています
// オリジナルシェーダーの詳細については、
// オリジナルソースコードの以下の説明を参照してください
//

//
// GLSL テクスチャのない古典的な 3D ノイズ "cnoise",
// RSL スタイルの周期的な変形 "pnoise" を持つ
// 作者 Stefan Gustavson (stefan.gustavson@liu.se)
// Version : 2011 - 10 - 11
//
// パーミュテーションとグラデーションの選択に関する
// アイデアを提供してくれたAshima ArtsのIan McEwanに感謝します
//
// Copyright (c) 2011 Stefan Gustavson. 無断複写・転載を禁じます
// MITライセンスの下で配布されています
// LICENSEファイルを参照
// https : //github.com / ashima / webgl - noise
//

float3 mod(float3 x, float3 y)
{
    return x - y * floor(x / y);
}

// 289で割った余りの値を一定範囲に保つ(float3)
float3 mod289(float3 x)
{
    return x - floor(x / 289.0) * 289.0;
}

// 289で割った余りの値を一定範囲に保つ(float4)
float4 mod289(float4 x)
{
    return x - floor(x / 289.0) * 289.0;
}

// 疑似的乱数を生成する
float4 permute(float4 x)
{
    return mod289(((x * 34.0) + 1.0) * x);
}

// ベクトルの長さを正規化する高速近似
float4 taylorInvSqrt(float4 r)
{
    return (float4)1.79284291400159 - r * 0.85373472095314;
}

// なめらかに補完する
float3 fade(float3 t)
{
    return t * t * t * (t * (t * 6.0 - 15.0) + 10.0);
}

// 古典的な3Dパーリンノイズ(Pは3D座標)
// Pの整数部分と小数部分を使いノイズ値を計算
// 近くの8つのノイズ格子点との影響を合成して1つの滑らかな値を返す
float cnoise(float3 P)
{
    // インデックス用整数部分
    float3 Pi0 = floor(P);
    // 整数部分 + 1
    float3 Pi1 = Pi0 + (float3)1.0;
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    // 補間のための小数部分
    float3 Pf0 = frac(P);
    // 小数部分 + 1
    float3 Pf1 = Pf0 - (float3)1.0;
    float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    float4 iy = float4(Pi0.y, Pi0.y, Pi1.y, Pi1.y);
    float4 iz0 = (float4)Pi0.z;
    float4 iz1 = (float4)Pi1.z;

    float4 ixy = permute(permute(ix) + iy);
    float4 ixy0 = permute(ixy + iz0);
    float4 ixy1 = permute(ixy + iz1);

    float4 gx0 = ixy0 / 7.0;
    float4 gy0 = frac(floor(gx0) / 7.0) - 0.5;
    gx0 = frac(gx0);
    float4 gz0 = (float4)0.5 - abs(gx0) - abs(gy0);
    float4 sz0 = step(gz0, (float4)0.0);
    gx0 -= sz0 * (step((float4)0.0, gx0) - 0.5);
    gy0 -= sz0 * (step((float4)0.0, gy0) - 0.5);

    float4 gx1 = ixy1 / 7.0;
    float4 gy1 = frac(floor(gx1) / 7.0) - 0.5;
    gx1 = frac(gx1);
    float4 gz1 = (float4)0.5 - abs(gx1) - abs(gy1);
    float4 sz1 = step(gz1, (float4)0.0);
    gx1 -= sz1 * (step((float4)0.0, gx1) - 0.5);
    gy1 -= sz1 * (step((float4)0.0, gy1) - 0.5);

    float3 g000 = float3(gx0.x, gy0.x, gz0.x);
    float3 g100 = float3(gx0.y, gy0.y, gz0.y);
    float3 g010 = float3(gx0.z, gy0.z, gz0.z);
    float3 g110 = float3(gx0.w, gy0.w, gz0.w);
    float3 g001 = float3(gx1.x, gy1.x, gz1.x);
    float3 g101 = float3(gx1.y, gy1.y, gz1.y);
    float3 g011 = float3(gx1.z, gy1.z, gz1.z);
    float3 g111 = float3(gx1.w, gy1.w, gz1.w);

    float4 norm0 = taylorInvSqrt(float4(
    dot(g000, g000),
    dot(g010, g010),
    dot(g100, g100),
    dot(g110, g110)
    ));

    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;

    float4 norm1 = taylorInvSqrt(float4(
    dot(g001, g001),
    dot(g011, g011),
    dot(g101, g101),
    dot(g111, g111)
    ));

    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, float3(Pf1.x, Pf0.y, Pf0.z));
    float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, float3(Pf1.x, Pf1.y, Pf0.z));
    float n001 = dot(g001, float3(Pf0.x, Pf0.y, Pf1.z));
    float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, float3(Pf0.x, Pf1.y, Pf1.z));
    float n111 = dot(g111, Pf1);

    float3 fade_xyz = fade(Pf0);
    float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
    float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}

// 周期的に繰り返す古典的なパーリンノイズ(repで繰り返し範囲を指定)
// cnoiseと性質は似ているが、repでノイズの繰り返し範囲を指定する
// タイル状に模様をつなげたい時に使う
float pnoise(float3 P, float3 rep)
{
    // 余りの整数部分
    float3 Pi0 = mod(floor(P), rep);
    // 余りの整数部分 + 1
    float3 Pi1 = mod(Pi0 + (float3)1.0, rep);
    Pi0 = mod289(Pi0);
    Pi1 = mod289(Pi1);
    // 補間のための小数部分
    float3 Pf0 = frac(P);
    // 補間のための小数部分 - 1
    float3 Pf1 = Pf0 - (float3)1.0;
    float4 ix = float4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
    float4 iy = float4(Pi0.y, Pi0.y, Pi1.y, Pi1.y);
    float4 iz0 = (float4)Pi0.z;
    float4 iz1 = (float4)Pi1.z;

    float4 ixy = permute(permute(ix) + iy);
    float4 ixy0 = permute(ixy + iz0);
    float4 ixy1 = permute(ixy + iz1);

    float4 gx0 = ixy0 / 7.0;
    float4 gy0 = frac(floor(gx0) / 7.0) - 0.5;
    gx0 = frac(gx0);
    float4 gz0 = (float4)0.5 - abs(gz0) - abs(gy0);
    float4 sz0 = step(gz0, (float4)0.0);
    gx0 -= sz0 * (step((float4)0.0, gx0) - 0.5);
    gy0 -= sz0 * (step((float4)0.0, gy0) - 0.5);

    float4 gx1 = ixy1 / 7.0;
    float4 gy1 = frac(floor(gx1) / 7.0) - 0.5;
    gx1 = frac(gx1);
    float4 gz1 = (float4)0.5 - abs(gx1) - abs(gy1);
    float4 sz1 = step(gz1, (float4)0.0);
    gx1 -= sz1 * (step((float4)0.0, gx1) - 0.5);
    gy1 -= sz1 * (step((float4)0.0, gy1) - 0.5);

    float3 g000 = float3(gx0.x, gy0.x, gz0.x);
    float3 g100 = float3(gx0.y, gy0.y, gz0.y);
    float3 g010 = float3(gx0.z, gy0.z, gz0.z);
    float3 g110 = float3(gx0.w, gy0.w, gz0.w);
    float3 g001 = float3(gx1.x, gy1.x, gz1.x);
    float3 g101 = float3(gx1.y, gy1.y, gz1.y);
    float3 g011 = float3(gx1.z, gy1.z, gz1.z);
    float3 g111 = float3(gx1.w, gy1.w, gz1.w);

    float4 norm0 = taylorInvSqrt(float4(
    dot(g000, g000),
    dot(g010, g010),
    dot(g100, g100),
    dot(g110, g110)
    ));

    g000 *= norm0.x;
    g010 *= norm0.y;
    g100 *= norm0.z;
    g110 *= norm0.w;

    float4 norm1 = taylorInvSqrt(float4(
    dot(g001, g001),
    dot(g011, g011),
    dot(g101, g101),
    dot(g111, g111)
    ));

    g001 *= norm1.x;
    g011 *= norm1.y;
    g101 *= norm1.z;
    g111 *= norm1.w;

    float n000 = dot(g000, Pf0);
    float n100 = dot(g100, float3(Pf1.x, Pf0.y, Pf0.z));
    float n010 = dot(g010, float3(Pf0.x, Pf1.y, Pf0.z));
    float n110 = dot(g110, float3(Pf1.x, Pf1.y, Pf0.z));
    float n001 = dot(g001, float3(Pf0.x, Pf0.y, Pf1.z));
    float n101 = dot(g101, float3(Pf1.x, Pf0.y, Pf1.z));
    float n011 = dot(g011, float3(Pf0.x, Pf1.y, Pf1.z));
    float n111 = dot(g111, Pf1);

    float3 fade_xyz = fade(Pf0);
    float4 n_z = lerp(float4(n000, n100, n010, n110), float4(n001, n101, n011, n111), fade_xyz.z);
    float2 n_yz = lerp(n_z.xy, n_z.zw, fade_xyz.y);
    float n_xyz = lerp(n_yz.x, n_yz.y, fade_xyz.x);
    return 2.2 * n_xyz;
}

