using UnityEngine;

public class GPUInstancingAnimation : MonoBehaviour
{
    [Header("Mesh & Material")]
    [SerializeField] private Mesh mesh;
    [SerializeField] private Material material;

    [Header("Block Settings")]
    [SerializeField] private int blockRows = 10;
    [SerializeField] private int blockColumns = 10;

    [Header("Grid Settings(Per Block)")]
    [SerializeField] private int rowCount = 3;
    [SerializeField] private int columnCount = 3;
    [SerializeField] private float spacing = 1.5f;
    [SerializeField] private float blockSpacing = 5f;

    [Header("Color Settings")]
    [SerializeField] private bool useRandomColor = true;
    // [ColorUsage(true, true)]
    [SerializeField] private Color color = Color.white;
    [Range(0, 5)] public float intensity = 1;

    [Header("Animation Settings")]
    [SerializeField] private float swingSpeed = 4f;
    [SerializeField] private float swingAngle = 30f;
    [SerializeField] private float swingOffset = 1.0f;
    // [SerializeField] private int instanceCount = 100;

    private int instanceCount;
    private MaterialPropertyBlock materialPropertyBlock;
    private Matrix4x4[] matrices;
    private Vector4[] colors;
    private float[] animationOffset;
    private float[] swingSpeedOffset;
    private Vector3[] basePositions;

    void Start()
    {
        int instancePerBlock = rowCount * columnCount;
        int blockCount = blockRows * blockColumns;
        instanceCount = instancePerBlock * blockCount;

        matrices = new Matrix4x4[instanceCount];
        colors = new Vector4[instanceCount];
        animationOffset = new float[instanceCount];
        swingSpeedOffset = new float[instanceCount];
        basePositions = new Vector3[instanceCount];
        materialPropertyBlock = new MaterialPropertyBlock();

        int index = 0;

        for (int br = 0; br < blockRows; br++)
        {
            for (int bc = 0; bc < blockColumns; bc++)
            {
                Vector3 sceneOrigin = transform.position;

                Vector3 blockOrigin = sceneOrigin + new Vector3(
                    (bc - blockColumns / 2f) * (rowCount * spacing + blockSpacing),
                    0,
                    (br - blockRows / 2f) * (columnCount * spacing + blockSpacing)
                );


                for (int x = 0; x < rowCount; x++)
                {
                    for (int z = 0; z < columnCount; z++)
                    {
                        // 位置を設定
                        Vector3 localPosition = new Vector3(
                            x * spacing,
                            0f,
                            z * spacing
                        );

                        Vector3 worldPosition = blockOrigin + localPosition;

                        basePositions[index] = worldPosition;

                        // ランダム or 固定色
                        Color finalColor = useRandomColor
                            ? new Color(Random.value, Random.value, Random.value)
                            : color;

                        finalColor *= intensity;
                        finalColor.a = 1f;

                        colors[index] = finalColor;

                        // ノイズまたはランダムによるスピードの個体差
                        swingSpeedOffset[index] = Random.Range(0.5f, 1.0f);

                        // アニメーションの開始時間をずらすためのオフセット
                        animationOffset[index] = Random.Range(0f, Mathf.PI * 2);

                        matrices[index] = Matrix4x4.TRS(worldPosition, Quaternion.identity, Vector3.one);

                        index++;
                    }
                }
            }

        }

        materialPropertyBlock.SetVectorArray("_Color", colors);
    }

    void Update()
    {
        float time = Time.time;

        for (int i = 0; i < instanceCount; i++)
        {
            float t = time * swingSpeed * swingSpeedOffset[i] + animationOffset[i];
            // サイリウムを振るアニメーション
            float swing = Mathf.Sin(t) * swingAngle;

            // 回転軸の揺らぎ (X軸に少し傾ける)
            float axisX = Mathf.PerlinNoise(i * 0.1f, time * 0.5f) * 0.3f;
            Vector3 rotationAxis = new Vector3(axisX, 0f, 1f).normalized;

            Quaternion rotation = Quaternion.AngleAxis(swing, rotationAxis);

            // サイリウムの原点をpivotOffsetY分下げて回転 → 実際の位置に戻す
            Vector3 pivotOffset = new Vector3(0f, swingOffset, 0f);
            Vector3 position = basePositions[i];
            Matrix4x4 pivot = Matrix4x4.TRS(position + pivotOffset, rotation, Vector3.one);
            // 回転後に戻す
            matrices[i] = pivot * Matrix4x4.Translate(pivotOffset);
        }

        // 1回で1023個までしか描画できないので分割
        int batchSize = 1023;

        for (int i = 0; i < instanceCount; i += batchSize)
        {
            int count = Mathf.Min(batchSize, instanceCount - i);

            if (!useRandomColor)
            {
                for (int j = 0; j < instanceCount; j++)
                {
                    Color finalColor = color * intensity;
                    finalColor.a = 1f;
                    colors[i] = finalColor;
                }
            }

            materialPropertyBlock.SetVectorArray("_Color", colors);

            Graphics.DrawMeshInstanced(
                mesh,
                0,
                material,
                new System.ArraySegment<Matrix4x4>(matrices, i, count).ToArray(),
                count,
                materialPropertyBlock
            );
        }
    }
}
