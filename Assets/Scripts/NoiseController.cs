using System.Collections;
using UnityEngine;

public class NoiseController : MonoBehaviour
{
    void Update()
    {
        if (Input.GetMouseButtonDown(0))
        {
            StartCoroutine(GeneratePulseNoise());
        }
    }

    IEnumerator GeneratePulseNoise()
    {
        for (int i = 0; i <= 180; i += 30)
        {
            GetComponent<MeshRenderer>().material.SetFloat(
                "_Amount",
                0.2f * Mathf.Sin(i * Mathf.Deg2Rad)
                );
            yield return null;
        }
    }
}
