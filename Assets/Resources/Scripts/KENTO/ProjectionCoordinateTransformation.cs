using System.Collections;
using System.Collections.Generic;
using UnityEngine;

/// <summary>
/// プロジェクション座標変換の過程を可視化する
/// </summary>
public class ProjectionCoordinateTransformation : MonoBehaviour
{
    /// <summary>
    /// カメラは原点に固定する想定でメッシュを作る
    /// </summary>
    [SerializeField] private Camera fixedOriginCamera;
    [SerializeField, Range(0, 100)] private float animationSeconds = 5f;

    void Start()
    {
        var mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;

        var vertices = CreateVertexPositionList();
        CreateMesh(mesh, vertices);

        // 頂点を変化させる
        StartCoroutine(UpdateVertices(vertices, mesh));
    }

    /// <summary>
    /// メッシュの作成
    /// </summary>
    /// <param name="mesh">MeshFilterに適用する予定のメッシュ</param>
    /// <param name="vertices">頂点の座標リスト</param>
    private void CreateMesh(Mesh mesh, List<Vector3> vertices)
    {
        // 頂点のインデックスを整える
        // この順番を参照して面ができあがる
        var triangles = new[]
        {
            // 視錘台
            0, 2, 1,
            1, 2, 3,
            1, 3, 5,
            7, 5, 3,
            3, 2, 7,
            6, 7, 2,
            2, 0, 6,
            4, 6, 0,
            0, 1, 4,
            5, 4, 1,
            4, 7, 6,
            5, 7, 4,
            // 四角錘の底面
            11, 8, 9, 11, 9, 10,
            // 四角錘の側面
            12, 13, 14,
            15, 16, 17,
            18, 19, 21,
            21, 22, 23,
            // 四角錘の底面
            27, 24, 25, 27, 25, 26,
            // 四角錘の側面
            28, 29, 30,
            31, 32, 33,
            34, 35, 37,
            37, 38, 39,
        };

        mesh.Clear();
        mesh.SetVertices(vertices);
        mesh.SetTriangles(triangles, 0);
        mesh.RecalculateBounds();
    }

    /// <summary>
    /// 頂点の座標リストを作成する
    /// </summary>
    /// <returns>頂点の座標のリスト</returns>
    private List<Vector3> CreateVertexPositionList()
    {
        var near = fixedOriginCamera.nearClipPlane;
        var far = fixedOriginCamera.farClipPlane;

        // カメラのパラメーターから視錘台を計算
        var nearFrustumHeight = 2 * near * Mathf.Tan(fixedOriginCamera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        var nearFrustumWidth = nearFrustumHeight * fixedOriginCamera.aspect;
        var farFrustumHeight = 2 * far * Mathf.Tan(fixedOriginCamera.fieldOfView * 0.5f * Mathf.Deg2Rad);
        var farFrustumWidth = farFrustumHeight * fixedOriginCamera.aspect;

        var farHalf = far / 2;
        var farQuarter = far / 4;

        // 視錐台を可視化するための頂点
        // 四角錐の頂点を作成する
        var vertices = new List<Vector3>
        {
            // 0,1,2,3,4,5,6,7
            new Vector3(nearFrustumWidth * -0.5f, nearFrustumHeight * -0.5f, near),
            new Vector3(nearFrustumWidth * 0.5f, nearFrustumHeight * -0.5f, near),
            new Vector3(nearFrustumWidth * -0.5f, nearFrustumHeight * 0.5f, near),
            new Vector3(nearFrustumWidth * 0.5f, nearFrustumHeight * 0.5f, near),
            new Vector3(farFrustumWidth * -0.5f, farFrustumHeight * -0.5f, far),
            new Vector3(farFrustumWidth * 0.5f, farFrustumHeight * -0.5f, far),
            new Vector3(farFrustumWidth * -0.5f, farFrustumHeight * 0.5f, far),
            new Vector3(farFrustumWidth * 0.5f, farFrustumHeight * 0.5f, far),

            // 8,9,10,11
            new Vector3(0, 0, farHalf),
            new Vector3(1, 0, farHalf),
            new Vector3(1, 0, farHalf + 5),
            new Vector3(0, 0, farHalf + 5),

            // 12,13,14
            new Vector3(0, 0, farHalf),
            new Vector3(0.5f, 1, farHalf + 2.5f),
            new Vector3(1, 0, farHalf),

            // 15,16,17
            new Vector3(1, 0, farHalf),
            new Vector3(0.5f, 1, farHalf + 2.5f),
            new Vector3(0, 0, farHalf + 5),

            // 18,19,20
            new Vector3(1, 0, farHalf + 5),
            new Vector3(0.5f, 1, farHalf + 2.5f),
            new Vector3(0, 0, farHalf + 5),

            // 21,22,23
            new Vector3(0, 0, farHalf + 5),
            new Vector3(0.5f, 1, farHalf + 2.5f),
            new Vector3(0, 0, farHalf),

            // 24,25,26,27
            new Vector3(0, 0, farQuarter),
            new Vector3(-1, 0, farQuarter),
            new Vector3(-1, 0, farQuarter + 5),
            new Vector3(0, 0, farQuarter + 5),

            // 28,29,30
            new Vector3(0, 0, farQuarter),
            new Vector3(-0.5f, 1, farQuarter + 2.5f),
            new Vector3(-1, 0, farQuarter),

            // 31,32,33
            new Vector3(-1, 0, farQuarter),
            new Vector3(-0.5f, 1, farQuarter + 2.5f),
            new Vector3(-1, 0, farQuarter +5),

            // 34,35,36
            new Vector3(-1, 0, farQuarter + 5),
            new Vector3(-0.5f, 1, farQuarter + 2.5f),
            new Vector3(0, 0, farQuarter + 5),

            // 37,38,39
            new Vector3(0, 0, farQuarter + 5),
            new Vector3(-0.5f, 1, farQuarter + 2.5f),
            new Vector3(0, 0, farQuarter),
        };

        return vertices;
    }

    /// <summary>
    /// 頂点をカメラの視錘台に合わせた状態に更新する
    /// </summary>
    /// <param name="vertices">頂点リスト</param>
    /// <param name="mesh">変更を適用したいメッシュ</param>
    private IEnumerator UpdateVertices(List<Vector3> vertices, Mesh mesh)
    {
        var vartexList = new List<Vector4>();

        // VP行列を適用する
        for (int i = 0; i < vertices.Count; i++)
        {
            // 頂点情報を4次元に
            var vertex = new Vector4(vertices[i].x, vertices[i].y, vertices[i].z, 1);

            // VP行列を作成
            var mat = fixedOriginCamera.projectionMatrix * fixedOriginCamera.worldToCameraMatrix;

            // VP行列を適用
            vertex = mat * vertex;

            // メッシュに対して頂点を適用
            vertices[i] = vertex;
            mesh.vertices = vertices.ToArray();
            mesh.RecalculateBounds();

            // アニメーションように頂点リストに追加
            vartexList.Add(vertex);
        }

        // 理解用にディレイ
        yield return new WaitForSeconds(3.0f);

        // プロジェクション座標変換の最後の工程である除算を行なう
        for (var i = 0; i < vertices.Count; i++)
        {
            var vertex = vartexList[i];
            StartCoroutine(VertexAnimationCoroutine(vertices, vertex, i, mesh));
        }
    }

    private IEnumerator VertexAnimationCoroutine(List<Vector3> vertices, Vector4 vertex, int index, Mesh mesh)
    {
        var startTime = Time.time;
        var spendSeconds = 0f;
        while (spendSeconds < animationSeconds)
        {
            spendSeconds = Time.time - startTime;
            yield return null;

            // w除算
            vertex /= Mathf.Lerp(1, vertex.w, spendSeconds / animationSeconds);

            // メッシュに対して頂点を適用
            vertices[index] = vertex;
            mesh.vertices = vertices.ToArray();
            mesh.RecalculateBounds();
        }
    }
}
