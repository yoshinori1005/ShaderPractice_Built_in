using UnityEngine;
using Unity.Collections;
using Unity.Jobs;

sealed class StickShow : MonoBehaviour
{
    [SerializeField] Mesh _mesh = null;
    [SerializeField] Material _material = null;
    [SerializeField] Audience _audience = Audience.Default();

    NativeArray<Matrix4x4> _matrices;
    NativeArray<Color> _colors;
    MaterialPropertyBlock _matProps;

    const int InstanceLimit = 1023; // DrawMeshInstanced制限

    void Start()
    {
        _matrices = new NativeArray<Matrix4x4>(
            _audience.TotalSeatCount, Allocator.Persistent, NativeArrayOptions.UninitializedMemory);

        _colors = new NativeArray<Color>(
            _audience.TotalSeatCount, Allocator.Persistent, NativeArrayOptions.UninitializedMemory);

        _matProps = new MaterialPropertyBlock();
    }

    void OnDestroy()
    {
        _matrices.Dispose();
        _colors.Dispose();
    }

    void Update()
    {
        var job = new AudienceAnimationJob()
        {
            config = _audience,
            xform = transform.localToWorldMatrix,
            time = Time.time,
            matrices = _matrices,
            colors = _colors
        };
        job.Schedule(_audience.TotalSeatCount, 64).Complete();

        int total = _audience.TotalSeatCount;
        int batchCount = Mathf.CeilToInt((float)total / InstanceLimit);

        for (int batch = 0; batch < batchCount; batch++)
        {
            int start = batch * InstanceLimit;
            int count = Mathf.Min(InstanceLimit, total - start);

            // インスタンスごとの色をセット
            Vector4[] colorArray = new Vector4[count];
            for (int i = 0; i < count; i++)
                colorArray[i] = _colors[start + i];

            _matProps.Clear();
            _matProps.SetVectorArray("_Color", colorArray); // _Color で渡す

            Graphics.DrawMeshInstanced(
                _mesh, 0, _material,
                new System.ArraySegment<Matrix4x4>(_matrices.ToArray(), start, count).ToArray(),
                count, _matProps);
        }
    }
}
