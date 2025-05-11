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

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // TV noise
        material.SetFloat("_OffsetNoiseX", Random.Range(0f, 0.6f));
        float offsetNoise = material.GetFloat("_OffsetNoiseY");
        material.SetFloat("_OffsetNoiseY", offsetNoise + Random.Range(-0.03f, 0.03f));

        // Vertical shift
        float offsetPosY = material.GetFloat("_OffsetPosY");

        if (offsetPosY > 0.0f)
        {
            material.SetFloat("_OffsetPosY", offsetPosY - Random.Range(0f, offsetPosY));
        }
        else if (offsetPosY < 0.0f)
        {
            material.SetFloat("_OffsetPosY", offsetPosY + Random.Range(0f, -offsetPosY));
        }
        else if (Random.Range(0, 150) == 1)
        {
            material.SetFloat("_OffsetPosY", Random.Range(-0.5f, 0.5f));
        }

        // Channel color shift
        float offsetColor = material.GetFloat("_OffsetColor");

        if (offsetColor > 0.003f)
        {
            material.SetFloat("_OffsetColor", offsetColor - 0.001f);
        }
        else if (Random.Range(0, 400) == 1)
        {
            material.SetFloat("_OffsetColor", Random.Range(0.003f, 0.1f));
        }

        // Distortion
        if (Random.Range(0, 15) == 1)
        {
            material.SetFloat("_OffsetDistortion", Random.Range(1f, 480f));
        }
        else
        {
            material.SetFloat("_OffsetDistortion", 480f);
        }

        Graphics.Blit(source, destination, material);
    }
}
