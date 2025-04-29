using UnityEngine;

public class TestDrawMeshInstanced01 : MonoBehaviour
{
    [SerializeField] private Mesh mesh;
    [SerializeField] private Material material;

    [SerializeField] private int meshCount = 1023;
    private Matrix4x4[] matrices;

    void Start()
    {
        matrices = new Matrix4x4[meshCount];

        for (int i = 0; i < meshCount; i++)
        {
            var pos = new Vector3(
                UnityEngine.Random.Range(-10f, 10f),
                UnityEngine.Random.Range(-10f, 10f),
                UnityEngine.Random.Range(-10f, 10f)
            );

            matrices[i] = Matrix4x4.TRS(pos, Quaternion.identity, Vector3.one);
        }
    }

    void Update()
    {
        Graphics.DrawMeshInstanced(mesh, 0, material, matrices);
    }
}
