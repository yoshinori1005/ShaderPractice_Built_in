using UnityEngine;

public class PostRendererVHS : MonoBehaviour
{
    public Material material;

    void Awake()
    {
        material = new Material(Shader.Find("Unlit/VHSEffect"));
        material.SetTexture("_SecondaryTex", Resources.Load("Textures/TVNoise") as Texture);
        material.SetFloat("_OffsetPosY", 0f);
        material.SetFloat("_OffsetColor", 0.01f);
        material.SetFloat("_OffsetDistortion", 480f);
        material.SetFloat("_Intensity", 0.64f);
    }

    /// <summary>
    /// VHSビデオのようにTVノイズや色収差、歪みを行う
    /// </summary>
    /// <param name="source">加工前のゲーム画面</param>
    /// <param name="destination">加工後に表示される画面</param>
    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // TV noise
        // 水平方向にTVノイズをランダムに動かす
        material.SetFloat("_OffsetNoiseX", Random.Range(0f, 0.6f));
        // 垂直方向のノイズもゆらゆら揺れるように調整
        float offsetNoise = material.GetFloat("_OffsetNoiseY");
        material.SetFloat("_OffsetNoiseY", offsetNoise + Random.Range(-0.03f, 0.03f));

        // Vertical shift
        float offsetPosY = material.GetFloat("_OffsetPosY");

        // 上から戻る
        if (offsetPosY > 0.0f)
        {
            material.SetFloat("_OffsetPosY", offsetPosY - Random.Range(0f, offsetPosY));
        }
        // 下から戻る
        else if (offsetPosY < 0.0f)
        {
            material.SetFloat("_OffsetPosY", offsetPosY + Random.Range(0f, -offsetPosY));
        }
        // たまにガクッとずれる
        else if (Random.Range(0, 150) == 1)
        {
            material.SetFloat("_OffsetPosY", Random.Range(-0.5f, 0.5f));
        }

        // Channel color shift
        float offsetColor = material.GetFloat("_OffsetColor");

        // 徐々に収まる
        if (offsetColor > 0.003f)
        {
            material.SetFloat("_OffsetColor", offsetColor - 0.001f);
        }
        // たまにズレる
        else if (Random.Range(0, 400) == 1)
        {
            material.SetFloat("_OffsetColor", Random.Range(0.003f, 0.1f));
        }

        // Distortion
        // たまに強く歪む
        if (Random.Range(0, 15) == 1)
        {
            material.SetFloat("_OffsetDistortion", Random.Range(1f, 480f));
        }
        // 通常は安定
        else
        {
            material.SetFloat("_OffsetDistortion", 480f);
        }

        Graphics.Blit(source, destination, material);
    }
}
