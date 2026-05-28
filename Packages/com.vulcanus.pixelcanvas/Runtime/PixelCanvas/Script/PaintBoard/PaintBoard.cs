
using UnityEngine.EventSystems;
using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;
using System.Threading;

namespace PixelCanvas
{
    public enum EPaintBoardType : byte
    {
        PaintBoard3D,
        PaintBoard2D,
    }

    public enum EPaintBoardUXMode
    {
        Initial = -1,
        None = 0,
        JoystickMode,
        ToolFingerMode,
        OneFingerMode,
        DoubleFingerMode,
        MouseMode,
    }

    [System.Flags]
    public enum EBitPaintActionTrigger
    {
        None = 0,
        Press   = 1 << 0,
        Release = 1 << 1,

        ALL = ~0
    }

    public abstract class PaintBoard : MonoBehaviour, IScrollHandler, IDragHandler, IPointerUpHandler, IPointerDownHandler
    {
        public RectTransform RectTransform => _rectTransform;
        [SerializeField] protected RectTransform _rectTransform;

        public RawImage MergedImage => _mergedImage;
        [SerializeField] protected RawImage _mergedImage;
        [SerializeField] protected ColorPallete _colorPallete;
        [SerializeField] protected PixelBrushAim _brushAim;
        [SerializeField] protected float _scrollMultiplier = 0.01f;

        protected Canvas _canvas;
        protected Camera _uiCamera;
        protected bool _mainToolActivation = false;

        protected SeedData _seedData;
        protected Partition _partition;
        protected EToolType _toolType;

        protected Dictionary<int, PointerEventData> _inputCollector = new Dictionary<int, PointerEventData>();

        public abstract EPaintBoardUXMode UXMode
        {
            get;
            set;
        }
        protected EPaintBoardUXMode _uxMode = EPaintBoardUXMode.Initial;

        protected virtual void Awake()
        {
            _rectTransform.anchoredPosition = Vector3.zero;
            _canvas = transform.GetComponentInParent<Canvas>();
            _uiCamera = _canvas.worldCamera;
        }

        protected virtual void OnEnable()
        {
            UXMode = EPaintBoardUXMode.None;
            _mainToolActivation = false;
        }

        protected virtual void OnDisable()
        {
            _inputCollector.Clear();
        }

        protected virtual void OnDestroy()
        {

        }

        protected virtual void Update()
        {
        }

        public abstract void OnDrag(PointerEventData eventData);

        public abstract void OnPointerDown(PointerEventData eventData);

        public abstract void OnPointerUp(PointerEventData eventData);

        public abstract void OnScroll(PointerEventData eventData);
    }
}