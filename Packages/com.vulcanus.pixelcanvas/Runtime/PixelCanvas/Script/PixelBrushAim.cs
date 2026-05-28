using Unity.Mathematics;

using UnityEngine;
using UnityEngine.UI;

namespace PixelCanvas
{
    public enum EAimVisibleState
    {
        None = 0,
        CrossHair = 1 << 0,
        BrushIndicator = 1 << 1,

        ALL = ~0
    }

    public partial class PixelBrushAim : MonoBehaviour/*, IDragHandler, IPointerUpHandler, IPointerDownHandler*/
    {
        public RectTransform RectTransform => _rectTransform;
        [SerializeField] private RectTransform _rectTransform;

        [SerializeField] private Image _crosshair;
        [SerializeField] private Image _colorSpoidGuide;
        [SerializeField] private Image _pressedTimeGuageImage;
        [SerializeField] private float _doubleTabTimeThreshold = 0.2f;
        private PaintBoard _paintBoard;

        private Canvas _canvas;
        private EToolType _currToolType;
        private Color _color;
        private Vector3 _pressedPosition;
        private float _pressedTime;

        public void SetVisibleState(EAimVisibleState state)
        {
            _crosshair.enabled = (state & EAimVisibleState.CrossHair) != 0;

            //Set BrushIndicator
            var brushStyle = Shader.GetGlobalVector(GlobalValue._BrushStyle);
            brushStyle.w = ((state & EAimVisibleState.BrushIndicator) != 0) ? 1 : 0;
            Shader.SetGlobalVector(GlobalValue._BrushStyle, brushStyle);

            _visibleState = state;
        }
        //public void ActiveVisibleState(EAimVisibleState state) => _visibleState |= state;
        //public void InactiveVisibleState(EAimVisibleState state) => _visibleState &= ~state;
        public bool ContainsAnyVisibleState(EAimVisibleState state) => (_visibleState & state) != 0;
        private EAimVisibleState _visibleState;

        public Vector2 AnchoredPosition
        {
            set
            {
                if (_rectTransform.anchoredPosition == value)
                    return;

                _rectTransform.anchoredPosition = value;
                var screenPosition = RectTransformUtility.WorldToScreenPoint(_canvas.worldCamera, _rectTransform.position);
                RectTransformUtility.ScreenPointToLocalPointInRectangle(_paintBoard.MergedImage.rectTransform, screenPosition, _canvas.worldCamera, out var position);

                var newPosition = position / _paintBoard.MergedImage.rectTransform.rect.size;
                _aimPosition = newPosition;
            }
            get
            {
                return _rectTransform.anchoredPosition;
            }
        }

        public Vector2 AimPosition => _aimPosition;
        private Vector2 _aimPosition;

        private void Awake()
        {
            var brushMaxSize = (int)ResourceManager.Instance._brushMinMaxSize.y;
            brushMaxSize += 1;

            _colorSpoidGuide.CrossFadeAlpha(0, 0, true);
            //_colorSpoidGuide.gameObject.SetActive(false);

            _canvas = GetComponentInParent<Canvas>();
            _rectTransform = GetComponent<RectTransform>();
        }

        public void Initialize(PaintBoard paintBoard)
        {
            _paintBoard = paintBoard;
            SetVisibleState(EAimVisibleState.None);
        }

        private void OnEnable()
        {
            _pressedTimeGuageImage.gameObject.SetActive(false);

            EventManager.Register(EPixelArtEventID.OnToolChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnColorChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnChangeBrushSetting, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnColorSpoidTriggered, NotifyEvent);

            EventManager.Register(EQueryEventID.AimPosition, (id) => { return AimPosition; } );
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.OnToolChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnColorChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnChangeBrushSetting, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnColorSpoidTriggered, NotifyEvent);

            EventManager.Unregister(EQueryEventID.AimPosition);
        }

        private void Update()
        {
            if (_paintBoard.UXMode == EPaintBoardUXMode.OneFingerMode)
            {
                if (0 < _pressedTime)
                {
                    _pressedTimeGuageImage.fillAmount = (Time.unscaledTime - _pressedTime) / ResourceManager.Instance._fingerToolTimeThreashold;
                    Shader.SetGlobalFloat(GlobalValue._PressTimeGuageRatio, _pressedTimeGuageImage.fillAmount);

                    if (_pressedTimeGuageImage.fillAmount == 1)
                    {
                        _paintBoard.UXMode = EPaintBoardUXMode.ToolFingerMode;

                        var screenPosition = RectTransformUtility.WorldToScreenPoint(_canvas.worldCamera, _pressedPosition);
                        RectTransformUtility.ScreenPointToLocalPointInRectangle(_paintBoard.RectTransform, screenPosition, _canvas.worldCamera, out var position);
                        AnchoredPosition = position;
                        EventManager.Notify(EPixelArtEventID.TriggerMainTool, true);
                    }
                }
            }
            _pressedTimeGuageImage.transform.position = _pressedPosition;
        }

        public void ResetPosition()
        {
            AnchoredPosition = Vector2.zero;

            if (_paintBoard is PaintBoard3D == true)
                _aimPosition = new Vector2(0.5f, 0.5f);
        }

        public bool UpdateAimPosition()
        {
            var screenPosition = RectTransformUtility.WorldToScreenPoint(_canvas.worldCamera, _rectTransform.position);
            RectTransformUtility.ScreenPointToLocalPointInRectangle(_paintBoard.MergedImage.rectTransform, screenPosition, _canvas.worldCamera, out var position);

            var textureSize = new float2(ResourceManager.Instance.SeedTarget.width, ResourceManager.Instance.SeedTarget.height);
            var index = new int2((float2)position / (float2)_paintBoard.MergedImage.rectTransform.sizeDelta * textureSize);
            var newPosition = (Vector2)(((float2)index + 0.5f) / textureSize);

            if (_aimPosition == newPosition)
                return false;
            _aimPosition = newPosition;

            return true;
        }

        public bool IsTabPaintingValid()
        {
            if (_pressedTime < 0)
                return false;

            if (ResourceManager.Instance._fingerToolTimeThreashold < Time.unscaledTime - _pressedTime)
                return false;

            return true;
        }

        public void ActivatePressedTimeGuage(float time, Vector2 screenPosition)
        {
            _pressedTime = time;
            _pressedTimeGuageImage.fillAmount = 0;
            _pressedTimeGuageImage.CrossFadeAlpha(1, 0, true);
            _pressedTimeGuageImage.gameObject.SetActive(true);
            _pressedTimeGuageImage.material.SetFloat("_Ratio", _pressedTimeGuageImage.fillAmount);
            Shader.SetGlobalFloat(GlobalValue._TimeGuagePressedTime, time);

            RectTransformUtility.ScreenPointToWorldPointInRectangle(_paintBoard.RectTransform, screenPosition, _canvas.worldCamera, out var position);
            _pressedPosition = position;
        }

        public void InactivatePressedTimeGuage()
        {
            _pressedTime = -1;
            _pressedTimeGuageImage.CrossFadeAlpha(0, 0.15f, true);
        }

        internal void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnToolChanged:
                    {
                        var toolType = (EToolType)datas[0];
                        _currToolType = toolType;
                    }
                    break;
                case EPixelArtEventID.OnColorChanged:
                    {
                        var color = (Color)datas[0];
                        _color = color;
                        _crosshair.color = GetContrastColor(_color);
                        _colorSpoidGuide.color = color;

                        Color GetContrastColor(Color color)
                        {
                            var luminance = 0.299f * color.r + 0.587f * color.g + 0.114f * color.b;
                            var contrastColor = (luminance > 0.5f) ? new Color(0, 0, 0, 1) : new Color(1, 1, 1, 1);
                            return contrastColor;
                        }
                    }
                    break;
                case EPixelArtEventID.OnChangeBrushSetting:
                    {
                        //var strokeThickness = (float)datas[0];
                        //var strokeSoftness = (float)datas[1];
                        //var strokeFlow = (float)datas[2];

                        if (GlobalValue.ExecuteAction == false)
                            ResetPosition();

                        SetVisibleState(EAimVisibleState.ALL);
                    }
                    break;
                case EPixelArtEventID.OnColorSpoidTriggered:
                    {
                        var toggle = (bool)datas[0];
                        if (toggle == true)
                            _colorSpoidGuide.CrossFadeAlpha(1, 0, true);
                        else
                            _colorSpoidGuide.CrossFadeAlpha(0, 0.3f, true);
                    }
                    break;
            }
        }
    }
}