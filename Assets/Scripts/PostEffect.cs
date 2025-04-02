using UnityEngine;

public class PostEffect : MonoBehaviour
{
    public Material postEffect;

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, postEffect);
    }
}
