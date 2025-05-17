using UnityEngine;

public class ApplyPlayerPos : MonoBehaviour
{
    Material material;
    GameObject player;
    public int radius = 10;

    void Start()
    {
        // マテリアルを取得
        material = GetComponent<Renderer>().material;
        // プレイヤーのゲームオブジェクトを取得
        player = GameObject.Find("Player");
    }

    void Update()
    {
        // シェーダーにプレイヤーの位置を設定
        material.SetVector("_PlayerPos", player.transform.position);
        // 半径または距離を設定する
        material.SetFloat("_Distance", radius);
    }
}
