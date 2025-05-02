using UnityEngine;

[ExecuteInEditMode]
public class InstanceColorSetter : MonoBehaviour
{
    [SerializeField] Color color;

    Renderer objRender;
    MaterialPropertyBlock props;

    static readonly int id = Shader.PropertyToID("_Color");

    void Start()
    {
        color = Random.ColorHSV();
        objRender = GetComponent<Renderer>();
        props = new MaterialPropertyBlock();
    }

    void Update()
    {
        props.SetColor(id, color);
        objRender.SetPropertyBlock(props);
    }
}
