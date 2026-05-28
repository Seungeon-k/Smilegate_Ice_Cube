using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mover : MonoBehaviour
{
    private RectTransform _rectTransform;

    private void Awake()
    {
        _rectTransform = GetComponent<RectTransform>();
    }

    void Update()
    {
        var position = _rectTransform.anchoredPosition;
        position.x = Mathf.Sin(Time.time * 10) * 200;
        _rectTransform.anchoredPosition = position;
    }
}
