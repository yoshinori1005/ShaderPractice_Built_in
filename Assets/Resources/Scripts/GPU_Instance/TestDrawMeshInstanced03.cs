using System.Collections.Generic;
using UnityEngine;

public class TestDrawMeshInstanced03 : MonoBehaviour
{
    [SerializeField] private Mesh mesh;
    [SerializeField] private Material material;

    private int meshCount = 1023 * 4;
    private List<Matrix4x4[]> batches;

    void Start()
    {
        batches = new List<Matrix4x4[]>();
        var matrices = new Matrix4x4[1023];

        for (int i = 0; i < meshCount; i++)
        {
            if (i % 1023 == 0)
            {
                matrices = new Matrix4x4[1023];
                batches.Add(matrices);
            }

            var pos = new Vector3(
                UnityEngine.Random.Range(-10f, 10f),
                UnityEngine.Random.Range(-10f, 10f),
                UnityEngine.Random.Range(-10f, 10f)
            );

            matrices[i % 1023] = Matrix4x4.TRS(pos, Quaternion.identity, Vector3.one);
        }
    }

    void Update()
    {
        foreach (var batch in batches)
        {
            Graphics.DrawMeshInstanced(mesh, 0, material, batch, 1023);
        }
    }
}
