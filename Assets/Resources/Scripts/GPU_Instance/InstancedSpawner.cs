using UnityEngine;
using System.Collections.Generic;

public class InstancedSpawner : MonoBehaviour
{
    public Mesh mesh; // たとえばCube Mesh
    public Material material;
    public int instanceCount = 100;

    Matrix4x4[] matrices;
    MaterialPropertyBlock propertyBlock;

    // void Start()
    // {
    //     matrices = new Matrix4x4[instanceCount];
    //     propertyBlock = new MaterialPropertyBlock();

    //     List<Vector4> colors = new List<Vector4>();
    //     List<float> scales = new List<float>();

    //     for (int i = 0; i < instanceCount; i++)
    //     {
    //         Vector3 position = new Vector3(
    //             Random.Range(-5f, 5f),
    //             Random.Range(0f, 0f),
    //             Random.Range(-5f, 5f)
    //         );
    //         Quaternion rotation = Quaternion.identity;
    //         float scale = Random.Range(0.5f, 1.5f);

    //         matrices[i] = Matrix4x4.TRS(position, rotation, Vector3.one * scale); // スケールはShader側でかける

    //         colors.Add(new Vector4(Random.value, Random.value, Random.value, 1f)); // ランダム色
    //         scales.Add(scale);
    //     }

    //     propertyBlock.SetVectorArray("_Color", colors);
    //     propertyBlock.SetFloatArray("_Scale", scales);
    // }

    void Start()
    {
        matrices = new Matrix4x4[instanceCount];
        propertyBlock = new MaterialPropertyBlock();

        List<Vector4> colors = new List<Vector4>();
        List<float> scales = new List<float>();

        int gridSize = Mathf.CeilToInt(Mathf.Sqrt(instanceCount)); // 正方形に近いグリッドサイズ

        for (int i = 0; i < instanceCount; i++)
        {
            int x = i % gridSize;
            int z = i / gridSize;

            Vector3 position = new Vector3(x * 2f, 0f, z * 2f); // 2m間隔で並べる
            Quaternion rotation = Quaternion.identity;
            float scale = 1f; // スケール固定1倍（拡大縮小しない）

            matrices[i] = Matrix4x4.TRS(position, rotation, Vector3.one * scale);

            colors.Add(new Vector4(Random.value, Random.value, Random.value, 1f)); // ランダム色
            scales.Add(scale);
        }

        propertyBlock.SetVectorArray("_Color", colors);
        propertyBlock.SetFloatArray("_Scale", scales);
    }

    void Update()
    {
        Graphics.DrawMeshInstanced(mesh, 0, material, matrices, instanceCount, propertyBlock);
    }
}
