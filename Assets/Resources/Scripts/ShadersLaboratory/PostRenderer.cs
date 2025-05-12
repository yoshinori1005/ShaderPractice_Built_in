using UnityEngine;

public class PostRenderer : MonoBehaviour
{
    public Material material;

    void Awake()
    {
        // Unlit/PostRenderNoiseという名前のシェーダーを探しマテリアルを作成
        material = new Material(Shader.Find("Unlit/PostRenderNoise"));
        // ResourcesからTexturesのNoiseという名前の画像を探す
        material.SetTexture("_SecondaryTex", Resources.Load("Textures/RandomNoiseAdditive") as Texture);
    }

    /// <summary>
    /// ノイズ画像の表示位置をランダムに動かす
    /// </summary>
    /// <param name="source">加工前のゲーム画面</param>
    /// <param name="destination">加工後に表示される画面</param>
    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        material.SetFloat("_OffsetX", Random.Range(0f, 1.1f));
        material.SetFloat("_OffsetY", Random.Range(0f, 1.1f));
        Graphics.Blit(source, destination, material);
    }
}
