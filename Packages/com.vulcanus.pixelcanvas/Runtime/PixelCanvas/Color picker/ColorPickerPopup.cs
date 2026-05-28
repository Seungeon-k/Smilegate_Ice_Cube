using System.Collections;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace PixelCanvas
{
    public class ColorPickerPopup : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler
    {
        [SerializeField] private Button _closeButton;
        [SerializeField] private Button _narrowModeButton;
        [SerializeField] private Button _wideModeButton;
        [SerializeField] private GraphColorPicker _graphColorPicker;
        [SerializeField] private GameObject _colorPickerGroup;
        [SerializeField] private GameObject _sliderPickerGroup;
        [SerializeField] private Graphic _dragHandle;

        private bool _active;
        private Canvas _canvas;
        private RectTransform _rectTransform;

        private void Awake()
        {
            _closeButton.onClick.AddListener(() =>
            {
                var animator = gameObject.GetComponentInChildren<Animator>();
                animator.Play("Popup_Close");
                _dragHandle.raycastTarget = false;
                _active = false;
            });

            //_wideModeButton.onClick.AddListener(() =>
            //{
            //    _colorPickerGroup.SetActive(true);
            //    _wideModeButton.gameObject.SetActive(false);
            //});
            _wideModeButton.gameObject.SetActive(false);

            _narrowModeButton.onClick.AddListener(() =>
            {
                if (_colorPickerGroup.activeSelf == true && _sliderPickerGroup.activeSelf == true)
                {
                    _sliderPickerGroup.SetActive(false);
                }
                else if (_colorPickerGroup.activeSelf == true)
                {
                    _colorPickerGroup.SetActive(false);
                    _sliderPickerGroup.SetActive(true);
                }
                else
                {
                    _colorPickerGroup.SetActive(true);
                    _sliderPickerGroup.SetActive(true);
                }
            });

            _rectTransform = GetComponent<RectTransform>();
            _canvas = transform.GetComponentInParent<Canvas>();
            _rectTransform.anchoredPosition = new Vector2(0, 0);

            EventManager.Register(EPixelArtEventID.ToggleColorPickerWindow, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangeColor, NotifyEvent);
        }

        private void Start()
        {
            _active = false;
            transform.gameObject.SetActive(false);
        }

        private void OnEnable()
        {
            _dragHandle.raycastTarget = true;
        }

        private void OnDisable()
        {
        }

        private void OnDestroy()
        {
            EventManager.Unregister(EPixelArtEventID.ToggleColorPickerWindow, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangeColor, NotifyEvent);
        }

        public void OnPointerDown(PointerEventData eventData)
        {
        }

        public void OnDrag(PointerEventData eventData)
        {
            _rectTransform.anchoredPosition += (eventData.delta / _canvas.scaleFactor);

            var rect = _rectTransform.GetWorldRect(_canvas.worldCamera);
            var adjustment = Vector2.zero;
            var threashold = rect.size - new Vector2(100, 100);

            adjustment.x -= Mathf.Min(0, rect.min.x + threashold.x);
            adjustment.y -= Mathf.Min(0, rect.min.y + threashold.y);
            adjustment.x -= Mathf.Max(0, rect.max.x - Screen.width - threashold.x);
            adjustment.y -= Mathf.Max(0, rect.max.y - Screen.height - threashold.y);

            _rectTransform.anchoredPosition += adjustment;
        }

        public void OnPointerUp(PointerEventData eventData)
        {
        }

        internal void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.ToggleColorPickerWindow:
                    {
                        var animator = gameObject.GetComponentInChildren<Animator>();

                        if (_active == true)
                        {
                            animator.Play("Popup_Close");
                            _dragHandle.raycastTarget = false;
                            _active = false;
                        }
                        else
                        {
                            gameObject.SetActive(true);
                            animator.Play("Popup_Open");
                            _dragHandle.raycastTarget = true;
                            _active = true;
                        }
                    }
                    break;
                case EPixelArtEventID.ChangeColor:
                    {
                        var color = (Color)datas[0];
                        _graphColorPicker.color = color;
                    }
                    break;
            }
        }
    }
}