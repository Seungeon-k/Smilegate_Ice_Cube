using TMPro;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class UISlider : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler
{
    [SerializeField] private Slider _slider;
    [SerializeField] private RectTransform _sliderRectTransform;
    [SerializeField] private TMP_Text _text;
    [SerializeField] private Image _image;

    private MaskableGraphic[] _maskableGraphics;

    public float MinValue
    {
        set => _slider.minValue = value;
    }

    public float MaxValue
    {
        set => _slider.maxValue = value;
    }

    public float Value 
    {
        set => _slider.value = value;
        get => _slider.value;
    }

    public void AddOnValudChangedEvent(UnityAction<float> action)
    {
        _slider.onValueChanged.AddListener(action);
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        //_rectTransform.CrossFadeAlpha(0, 0.1f, true);
        //foreach (var maskableGraphic in _maskableGraphics)
        //    maskableGraphic.CrossFadeAlpha(1, 0.1f, true);
    }

    public void OnDrag(PointerEventData eventData)
    {
        var ratioDelta = eventData.delta.y / _sliderRectTransform.sizeDelta.y;
        //_slider.value += (_slider.maxValue - _slider.minValue) * ratioDelta * 2f;
        //_slider.normalizedValue;
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        //_rectTransform.CrossFadeAlpha(1, 0.1f, true);
        //foreach (var maskableGraphic in _maskableGraphics)
        //    maskableGraphic.CrossFadeAlpha(0, 0.5f, true);
    }

}
