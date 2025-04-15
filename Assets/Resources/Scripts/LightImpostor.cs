using UnityEngine;

public class LightImpostor : MonoBehaviour
{
    // 更新時にこのグローバルベクターを更新し、すべてのシェーダはこの値を取得
    void Update()
    {
        Shader.SetGlobalVector("_lightDir", transform.forward);
    }
}
