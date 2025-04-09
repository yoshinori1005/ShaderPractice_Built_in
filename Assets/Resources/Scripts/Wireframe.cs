using UnityEngine;

public class Wireframe : MonoBehaviour
{
    void Start()
    {
        MeshFilter meshFilter = GetComponent<MeshFilter>();
        meshFilter.mesh.SetIndices(
            meshFilter.mesh.GetIndices(0),
            MeshTopology.Lines,
            0
            );
    }
}
