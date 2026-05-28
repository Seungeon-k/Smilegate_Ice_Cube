using UnityEngine;

namespace PixelCanvas
{
    [RequireComponent(typeof(RectTransform))]
    public class UISafeArea : MonoBehaviour
    {
        private RectTransform _rectTransform;
        private Vector2 _initialAnchorMin;
        private Vector2 _initialAnchorMax;


        private ScreenOrientation _lastOrientation;
        private Vector2Int _lastResolution;
        private Rect _lastSafeArea;



        void Awake()
        {
            if (_rectTransform == null)
                _rectTransform = GetComponent<RectTransform>();

            _initialAnchorMin = _rectTransform.anchorMin;
            _initialAnchorMax = _rectTransform.anchorMax;
            //            _initialPosition = _rectTransform.anchoredPosition;
            ApplySafeArea();
        }

        void Update()
        {
            if (_lastOrientation != Screen.orientation ||
                _lastSafeArea != Screen.safeArea ||
                _lastResolution.x != Screen.width || _lastResolution.y != Screen.height)
            {
                _lastOrientation = Screen.orientation;
                _lastSafeArea = Screen.safeArea;
                _lastResolution = new Vector2Int(Screen.width, Screen.height);

                ApplySafeArea();
            }
        }

        private void ApplySafeArea()
        {
            var safeArea = Screen.safeArea;
            var min = safeArea.min / new Vector2(Screen.width, Screen.height);
            var max = safeArea.max / new Vector2(Screen.width, Screen.height);
            _rectTransform.anchorMin = _initialAnchorMin;
            _rectTransform.anchorMax = _initialAnchorMax;
            _rectTransform.anchorMin = new Vector2(Mathf.Clamp(_rectTransform.anchorMin.x, min.x, max.x), Mathf.Clamp(_rectTransform.anchorMin.y, min.y, max.y));
            _rectTransform.anchorMax = new Vector2(Mathf.Clamp(_rectTransform.anchorMax.x, min.x, max.x), Mathf.Clamp(_rectTransform.anchorMax.y, min.y, max.y));
        }
    }
}