using UnityEngine;

public class PostRenderer : MonoBehaviour
{
    public Material material;

    void Awake()
    {
        material = new Material(Shader.Find("Unlit/PostRenderNoise"));
        material.SetTexture("_SecondaryTex", Resources.Load("Textures/Noise") as Texture);
    }

    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetFloat("_OffsetX", Random.Range(0f, 1.1f));
        material.SetFloat("_OffsetY", Random.Range(0f, 1.1f));
        Graphics.Blit(source, destination, material);
    }
}
