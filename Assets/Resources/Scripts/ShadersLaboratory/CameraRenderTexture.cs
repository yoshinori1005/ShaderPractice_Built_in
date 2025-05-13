using UnityEngine;

public class CameraRenderTexture : MonoBehaviour
{
    public Material material;

    /// <summary>
    /// カメラのレンダリングを設定したマテリアルの状態にする
    /// </summary>
    /// <param name="source">加工前のゲーム画面</param>
    /// <param name="destination">加工後に表示される画面</param>
    public void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        Graphics.Blit(source, destination, material);
    }
}
