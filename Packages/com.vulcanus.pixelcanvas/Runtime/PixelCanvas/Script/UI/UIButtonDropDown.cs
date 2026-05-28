using TMPro;

using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace PixelCanvas
{
    public partial class UIButtonDropDown : MonoBehaviour
    {
        public RectTransform RectTransform => _rectTransform;
        [SerializeField] private RectTransform _rectTransform;
        [SerializeField] private RectTransform _viewRectTransform;

        [SerializeField] private Button _button;
        [SerializeField] private Button _elementPrefab;

        private void Awake()
        {
            _button.onClick.AddListener(() => 
            {
                _viewRectTransform.gameObject.SetActive(!_viewRectTransform.gameObject.activeSelf);
            });

            _viewRectTransform.gameObject.SetActive(false);
            _elementPrefab.gameObject.SetActive(false);
        }

        public void AddElement(string buttonName, UnityAction action)
        {
            var button = GameObject.Instantiate(_elementPrefab, _viewRectTransform);
            button.gameObject.SetActive(true);

            button.GetComponentInChildren<TMP_Text>().text = buttonName;
            button.onClick.AddListener(() => 
            {
                action?.Invoke();
                _viewRectTransform.gameObject.SetActive(false); 
            });
        }
    }

#if UNITY_EDITOR
    public partial class UIButtonDropDown
    {
        private void OnValidate()
        {
            _rectTransform = GetComponent<RectTransform>();
            _button = GetComponent<Button>();
        }
    }
#endif
}
