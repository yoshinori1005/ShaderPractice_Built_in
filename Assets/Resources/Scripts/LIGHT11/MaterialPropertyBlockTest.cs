using UnityEngine;

public class MaterialPropertyBlockTest : MonoBehaviour
{
    [SerializeField] private Color color;

    private MeshRenderer meshRenderer;
    private MaterialPropertyBlock matBlock;

    void Start()
    {
        meshRenderer = GetComponent<MeshRenderer>();
        matBlock = new MaterialPropertyBlock();
    }

    void Update()
    {
        // この時点ですでにほかのスクリプトなどからMaterialPropertyBlockが
        // セットされているかもしれないので、まずは取得する
        meshRenderer.GetPropertyBlock(matBlock);

        // MaterialPropertyBlockに対して色をセットする
        matBlock.SetColor("_Color", color);

        // MaterialPropertyBlockをセットする
        meshRenderer.SetPropertyBlock(matBlock);
    }
}
