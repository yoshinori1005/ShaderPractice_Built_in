using System;
using UnityEngine;
using UnityEngine.UI;

public class ScanButtonEvent : MonoBehaviour
{
    [SerializeField] private Button button;
    [SerializeField] private Animator animator;

    void Start()
    {
        button.onClick.AddListener(ScanEvent);
    }

    void OnDestroy()
    {
        button.onClick.RemoveListener(ScanEvent);
    }

    /// <summary>
    /// スキャン時のイベント
    /// アニメーターのTriggerを切り替える
    /// </summary>
    private void ScanEvent()
    {
        animator.SetTrigger("Scan");
    }
}
