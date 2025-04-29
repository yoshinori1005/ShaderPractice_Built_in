using UnityEngine;

public class TestDrawMeshInstanced02 : MonoBehaviour
{
    [SerializeField] private Mesh mesh;
    [SerializeField] private Material material;
    [SerializeField] private int meshCount = 1023;

    private Matrix4x4[] matrices;
    // MaterialPropertyBlockを使用してインスタンス毎にプロパティを設定
    private MaterialPropertyBlock propertyBlock;

    void Start()
    {
        matrices = new Matrix4x4[meshCount];
        propertyBlock = new MaterialPropertyBlock();

        var colors = new Vector4[meshCount];

        for (int i = 0; i < meshCount; i++)
        {
            var pos = new Vector3(
                UnityEngine.Random.Range(-10f, 10f),
                UnityEngine.Random.Range(-10f, 10f),
                UnityEngine.Random.Range(-10f, 10f)
            );

            matrices[i] = Matrix4x4.TRS(pos, Quaternion.identity, Vector3.one);
            var r = i / (float)meshCount;
            var g = 1f - i / (float)meshCount;
            colors[i] = new Vector4(r, g, 0f, 1f);
        }

        propertyBlock.SetVectorArray("_Color", colors);
    }

    void Update()
    {
        Graphics.DrawMeshInstanced(
            mesh,
            0,
            material,
            matrices,
            meshCount,
            propertyBlock
            );
    }
}
