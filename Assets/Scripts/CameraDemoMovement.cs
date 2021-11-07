using UnityEngine;

public class CameraDemoMovement : MonoBehaviour
{
    [SerializeField] private float amplitude;
    [SerializeField] private float frequency;

    private Vector3 _initialPosition;

    private void Awake()
    {
        _initialPosition = transform.localPosition;
    }

    private void Update()
    {
        var additionXVector = new Vector3(+Mathf.Sin(Time.time * frequency) * amplitude, 0, 0);
        transform.localPosition = _initialPosition + additionXVector;
    }
}
