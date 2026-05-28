using Unity.Mathematics;

using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Experimental.Rendering;
using UnityEngine.UI;

namespace PixelCanvas
{
    public class UIMarquee : MonoBehaviour, IDragHandler, IPointerUpHandler, IPointerDownHandler
    {
        public RectTransform RectTransform => _rectTransform;
        [SerializeField] private RectTransform _rectTransform;

        [SerializeField] private RectTransform _buttons;
        [SerializeField] private Button _copyButton;
        [SerializeField] private Button _cutButton;
        [SerializeField] private Button _patsteButton;
        [SerializeField] private Button _cancelButton;

        public RawImage Image => _image;
        [SerializeField] private RawImage _image;

        private RectTransform _rootRectTransform;
        private Canvas _canvas;
        private Vector2 _pos1;
        private Vector2 _anchoredPosition;
        private Vector2 _pressedAnchoredPosition;
        private RectInt _originRegion;
        private Partition _partition;

        private static readonly RectInt defaultRectInt = new RectInt(new Vector2Int(-999_999, -999_999), Vector2Int.zero);

        public static Texture2D CopiedTexture => _copiedTexture;
        private static Texture2D _copiedTexture;

        private void Awake()
        {
            _image.material = GameObject.Instantiate(_image.material);

            _copyButton.onClick.AddListener(Copy);
            _cutButton.onClick.AddListener(Cut);
            _patsteButton.onClick.AddListener(Paste);
            _cancelButton.onClick.AddListener(Cancel);

            EventManager.Register(EPixelArtEventID.MarqueePaste, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnRedoUndoMarqueeActivationCommand, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnRedoUndoMarqueeInactivationCommand, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnUndoRedoMarqueeReallocateCommand, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnUndoRedoMarqueeTranslateCommand, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnPartitionChanged, NotifyEvent);

            gameObject.SetActive(false);
        }

        private void OnEnable()
        {
            _patsteButton.interactable = (_copiedTexture != null) ? true : false;

            EventManager.Register(EPixelArtEventID.OnToolChanged, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.OnToolChanged, NotifyEvent);
        }

        private void OnDestroy()
        {
            if (_copiedTexture != null)
                GameObject.DestroyImmediate(_copiedTexture);

            EventManager.Unregister(EPixelArtEventID.MarqueePaste, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnRedoUndoMarqueeActivationCommand, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnRedoUndoMarqueeInactivationCommand, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnUndoRedoMarqueeReallocateCommand, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnUndoRedoMarqueeTranslateCommand, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnPartitionChanged, NotifyEvent);
        }

        private void ReleaseImageTexture()
        {
            if (_image.texture == null)
                return;

            if (_image.texture == _copiedTexture)
            {
                _image.texture = null;
                return;
            }

            GameObject.DestroyImmediate(_image.texture);
        }

        public void Initialize(Canvas canvas, RectTransform rootRectTransform)
        {
            _canvas = canvas;
            _rootRectTransform = rootRectTransform;
        }

        public void UpdateScale(float boardScale)
        {
            boardScale = math.clamp(boardScale, 1, int.MaxValue);
            boardScale = 1 / boardScale;
            _buttons.transform.localScale = new Vector3(boardScale, boardScale, boardScale);
        }

        public void Activate()
        {
            gameObject.SetActive(true);
        }

        public void Inactivate()
        {
            if (gameObject.activeSelf == false)
                return;

            gameObject.SetActive(false);
            ReleaseImageTexture();
            _originRegion = defaultRectInt;
            EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
        }

        public void Apply()
        {
            if (gameObject.activeSelf == false)
                return;

            if (_image.texture == null)
                return;

            EventManager.Notify(EPixelArtEventID.AddTaskCommand, new MarqueeInactivationCommand(ECanvasType.Albedo, _originRegion, GetRegion()));
        }

        public void Cancel()
        {
            var curRegion = GetRegion();
            SetRegion(_originRegion, false);
            EventManager.Notify(EPixelArtEventID.ForceExecuteCanvasUpdate);
            _originRegion = curRegion;

            EventManager.Notify(EPixelArtEventID.AddTaskCommand, new MarqueeInactivationCommand(ECanvasType.Albedo, GetRegion(), _originRegion));
            EventManager.Notify(EPixelArtEventID.ShowToastMessage, "ID_Text_4091"); // Cancled
            Inactivate();
        }

        public void BeginRegion(Vector2 pos1)
        {
            //Reallocation Case
            Apply();
            ReleaseImageTexture();
            _originRegion = defaultRectInt;

            Activate();
            _pos1 = pos1;
        }

        public void UpdateRegion(Vector2 pos2)
        {
            var textureSize = new float2(ResourceManager.Instance.SeedTarget.width, ResourceManager.Instance.SeedTarget.height);

            var minRegionUV = math.min((float2)_pos1, pos2);
            minRegionUV = math.floor(minRegionUV * textureSize);
            minRegionUV /= textureSize;

            var maxRegionUV = math.max((float2)_pos1, pos2);
            maxRegionUV = math.ceil(maxRegionUV * textureSize);
            maxRegionUV /= textureSize;

            var dragDelta = (maxRegionUV - minRegionUV);
            var centerPos = (maxRegionUV + minRegionUV) * 0.5f;
            var regionSize = math.abs(dragDelta);

            _rectTransform.anchoredPosition = _anchoredPosition = (Vector2)centerPos * _rootRectTransform.sizeDelta;
            _rectTransform.sizeDelta = (Vector2)regionSize * _rootRectTransform.sizeDelta;
            _image.material.SetVector(GlobalValue._RectSize, new Vector4(_rectTransform.sizeDelta.x, _rectTransform.sizeDelta.y, 0, 0));
        }

        public void EndRegion()
        {
            var textureSize = new float2(ResourceManager.Instance.SeedTarget.width, ResourceManager.Instance.SeedTarget.height);
            var selectedRegion = GetRegion();
            var regionSize = selectedRegion.max - selectedRegion.min;

            //Invalid Region
            if (selectedRegion.width == 0 || selectedRegion.height == 0)
            {
                Inactivate();
                return;
            }

            //RectTransform Coord
            _rectTransform.anchoredPosition = _anchoredPosition = (((selectedRegion.max.ToVector2() + selectedRegion.min.ToVector2()) * 0.5f) / (Vector2)textureSize) * _rootRectTransform.sizeDelta;
            _rectTransform.sizeDelta = (regionSize / (Vector2)textureSize) * _rootRectTransform.sizeDelta;

            if (_originRegion.size == Vector2.zero)
            {
                EventManager.Notify(EPixelArtEventID.AddTaskCommand, new MarqueeActivationCommand(selectedRegion));
            }
            else
            {
                var modifiedMin = selectedRegion.min - _originRegion.min;
                var modifiedMax = selectedRegion.max - _originRegion.max;
                EventManager.Notify(EPixelArtEventID.AddTaskCommand, new MarqueeReallocateCommand(modifiedMin.ToInt2(), modifiedMax.ToInt2()));
            }

            CropSelectedRegion(selectedRegion);
            _originRegion = selectedRegion;
            _image.material.SetFloat(GlobalValue._EventTime, Time.time);
        }

        private RectInt GetRegion()
        {
            var textureSize = new float2(ResourceManager.Instance.SeedTarget.width, ResourceManager.Instance.SeedTarget.height);
            var seedDataCoordMin = _rectTransform.anchoredPosition - (_rectTransform.sizeDelta * 0.5f);
            seedDataCoordMin /= _rootRectTransform.sizeDelta;
            seedDataCoordMin *= (Vector2)textureSize;

            var seedDataCoordSize = _rectTransform.sizeDelta;
            seedDataCoordSize /= _rootRectTransform.sizeDelta;
            seedDataCoordSize *= (Vector2)textureSize;

            var seedDataCoordMax = seedDataCoordMin + seedDataCoordSize;
            //seedDataCoordMin = math.clamp(seedDataCoordMin, new float2(0, 0), textureSize);
            //seedDataCoordMax = math.clamp(seedDataCoordMax, new float2(0, 0), textureSize);
            seedDataCoordMin = math.clamp(seedDataCoordMin, _partition._normPartition.min * (Vector2)textureSize, _partition._normPartition.max * (Vector2)textureSize);
            seedDataCoordMax = math.clamp(seedDataCoordMax, _partition._normPartition.min * (Vector2)textureSize, _partition._normPartition.max * (Vector2)textureSize);
            seedDataCoordSize = (seedDataCoordMax - seedDataCoordMin);

            var selectedRegion = new RectInt((int)seedDataCoordMin.x, (int)seedDataCoordMin.y, (int)seedDataCoordSize.x, (int)seedDataCoordSize.y);
            return selectedRegion;
        }

        private void SetRegion(RectInt region, bool cropRegion = true)
        {
            var textureSize = new float2(ResourceManager.Instance.SeedTarget.width, ResourceManager.Instance.SeedTarget.height);
            var seedDataCoordMin = region.min.ToVector2();
            var seedDataCoordMax = region.max.ToVector2();

            if (region.width != 0 && region.height != 0)
            {
                //seedDataCoordMin = math.clamp(seedDataCoordMin, new float2(0, 0), textureSize);
                //seedDataCoordMax = math.clamp(seedDataCoordMax, new float2(0, 0), textureSize);

                //Partition Clamp
                seedDataCoordMin = math.clamp(seedDataCoordMin, _partition._normPartition.min * (Vector2)textureSize, _partition._normPartition.max * (Vector2)textureSize);
                seedDataCoordMax = math.clamp(seedDataCoordMax, _partition._normPartition.min * (Vector2)textureSize, _partition._normPartition.max * (Vector2)textureSize);
            }


            var seedDataCoordSize = seedDataCoordMax - seedDataCoordMin;

            //RectTransform Coord
            _rectTransform.anchoredPosition = (((seedDataCoordMax + seedDataCoordMin) * 0.5f) / (Vector2)textureSize) * _rootRectTransform.sizeDelta;
            _rectTransform.sizeDelta = (seedDataCoordSize / (Vector2)textureSize) * _rootRectTransform.sizeDelta;
            _anchoredPosition = _rectTransform.anchoredPosition;
            _image.material.SetVector(GlobalValue._RectSize, new Vector4(_rectTransform.sizeDelta.x, _rectTransform.sizeDelta.y, 0, 0));

            var selectedRegion = new RectInt((int)seedDataCoordMin.x, (int)seedDataCoordMin.y, (int)seedDataCoordSize.x, (int)seedDataCoordSize.y);
            _originRegion = selectedRegion;

            if (cropRegion == true)
                CropSelectedRegion(selectedRegion);
            _image.material.SetFloat(GlobalValue._EventTime, Time.time);
        }

        private void SetRegion(Texture2D sourceTexture, Vector2 position)
        {
            var textureSize = new float2(ResourceManager.Instance.SeedTarget.width, ResourceManager.Instance.SeedTarget.height);
            var sourceTextureSize = new float2(sourceTexture.width, sourceTexture.height);

            _rectTransform.anchoredPosition = position * _rootRectTransform.sizeDelta;
            _rectTransform.sizeDelta = ((Vector2)sourceTextureSize / (Vector2)textureSize) * _rootRectTransform.sizeDelta;
            _anchoredPosition = _rectTransform.anchoredPosition;
            _image.material.SetVector(GlobalValue._RectSize, new Vector4(_rectTransform.sizeDelta.x, _rectTransform.sizeDelta.y, 0, 0));
            _image.texture = sourceTexture;

            _originRegion = defaultRectInt;
            _image.material.SetFloat(GlobalValue._EventTime, Time.time);
        }

        private PointerEventData _currEventData = null;

        public void OnPointerDown(PointerEventData eventData)
        {
            if (_currEventData != null)
                return;
            _currEventData = eventData;

            _pressedAnchoredPosition = _rectTransform.anchoredPosition;
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (_currEventData != eventData)
                return;

            _anchoredPosition += (eventData.delta / _rootRectTransform.localScale / _canvas.scaleFactor);
            _rectTransform.anchoredPosition = _anchoredPosition;

            var textureSize = new float2(ResourceManager.Instance.SeedTarget.width, ResourceManager.Instance.SeedTarget.height);
            var regionSize = (float2)_rectTransform.sizeDelta / (float2)_rootRectTransform.sizeDelta * textureSize;
            var pixelSize = (float2)_rootRectTransform.sizeDelta / textureSize;
            var halfPixelSize = pixelSize * 0.5f;
            var pixelIndex = (float2)(int2)((float2)_anchoredPosition / (float2)_rootRectTransform.sizeDelta * textureSize);
            pixelIndex.x += (regionSize.x % 2 == 0) ? 0f : 0.5f;
            pixelIndex.y += (regionSize.y % 2 == 0) ? 0f : 0.5f;
            var newNormalizedPosition = (Vector2)((pixelIndex) / textureSize);
            newNormalizedPosition *= _rootRectTransform.sizeDelta;

            _rectTransform.anchoredPosition = newNormalizedPosition;
            EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            if (_currEventData != eventData)
                return;
            _currEventData = null;

            _image.material.SetFloat(GlobalValue._EventTime, Time.time);
            var dragDelta = _rectTransform.anchoredPosition - _pressedAnchoredPosition;
            if (dragDelta == Vector2.zero)
                return;

            EventManager.Notify(EPixelArtEventID.AddTaskCommand, new MarqueeTranslateCommand(dragDelta));
        }

        private void CropSelectedRegion(RectInt selectedRegion)
        {
            var minRegion = selectedRegion.min;
            var maxRegion = selectedRegion.max;

            var width = (int)(maxRegion.x - minRegion.x);
            var height = (int)(maxRegion.y - minRegion.y);

            if (0 < width && 0 < height)
            {
                var regionTexture = new Texture2D(width, height, GraphicsFormat.R8G8B8A8_SRGB, TextureCreationFlags.None);
                regionTexture.filterMode = FilterMode.Point;
                RenderTexture.active = ResourceManager.Instance.SeedTarget;
                regionTexture.ReadPixels(new Rect(minRegion.x, minRegion.y, width, height), 0, 0, false);
                RenderTexture.active = null;
                regionTexture.Apply();
                ReleaseImageTexture();
                _image.texture = regionTexture;
            }
        }

        private void Copy()
        {
            if (_copiedTexture != _image.texture)
            {
                GameObject.DestroyImmediate(_copiedTexture);

                var marqueeTexture = _image.texture as Texture2D;
                _copiedTexture = marqueeTexture.Clone();
            }

            _image.material.SetFloat(GlobalValue._EventTime, Time.time);
            _patsteButton.interactable = (_copiedTexture != null) ? true : false;
            EventManager.Notify(EPixelArtEventID.OnMarqueeCopy, _copiedTexture);
            EventManager.Notify(EPixelArtEventID.ShowToastMessage, "ID_Text_4092"); //Copy
        }

        private void Cut()
        {
            //Ignore "(Copy or Cut) -> Paste -> Cut" Case
            if (_image.texture == _copiedTexture)
            {
                Inactivate();
                return;
            }

            GameObject.DestroyImmediate(_copiedTexture);

            var marqueeTexture = _image.texture as Texture2D;
            _copiedTexture = marqueeTexture.Clone();
            _image.texture = null;
            _patsteButton.interactable = (_copiedTexture != null) ? true : false;

            EventManager.Notify(EPixelArtEventID.OnMarqueeCopy, _copiedTexture);
            EventManager.Notify(EPixelArtEventID.ForceExecuteCanvasUpdate);
            EventManager.Notify(EPixelArtEventID.AddTaskCommand, new MarqueeCutCommand(ECanvasType.Albedo, _originRegion, GetRegion()));
            EventManager.Notify(EPixelArtEventID.ShowToastMessage, "ID_Text_4093"); //Cut
            Inactivate();
        }

        private void Paste()
        {
            if (_copiedTexture == null)
                return;

            if (gameObject.activeSelf == true)
                EventManager.Notify(EPixelArtEventID.AddTaskCommand, new MarqueeInactivationCommand(ECanvasType.Albedo, _originRegion, GetRegion()));

            if (EventManager.QueryValue<Vector2>(EQueryEventID.AimPosition, out var anchoredAimPosition) == false)
                return;

            Activate();

            SetRegion(_copiedTexture, anchoredAimPosition);
            _image.material.SetFloat(GlobalValue._EventTime, Time.time);

            EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            EventManager.Notify(EPixelArtEventID.ShowToastMessage, "ID_Text_4094"); // Paste
        }

        public void Draw()
        {
            if (gameObject.activeSelf == false)
                return;
            //if (_rectTransform.texture == null)
            //    return;

            var croppedTexture = _image.texture;
            var targetTexture = ResourceManager.Instance.DrawingLayerTarget;
            var targetTextureSize = new Vector2(targetTexture.width, targetTexture.height);

            Graphics.SetRenderTarget(targetTexture);
            GL.PushMatrix();
            GL.LoadPixelMatrix(0, targetTextureSize.x, targetTextureSize.y, 0);

            //GL.LoadOrtho();
            ////GL.LoadIdentity();
            //var matrix = Matrix4x4.Ortho(0, targetTextureSize.x, targetTextureSize.y, 0, -1, 1);
            //GL.MultMatrix(matrix);
            //////var r = Quaternion.Euler(0, 0, Time.time * 100);
            //////Matrix4x4.TRS(Vector3.zero, r, Vector3.one);

            if (0 < _originRegion.width && 0 < _originRegion.height)
            {
                //Draw Blank Region
                var rect = new Rect();
                rect.size = new Vector2(_originRegion.width, _originRegion.height);
                var center = _originRegion.center;
                center.y = ResourceManager.Instance.SeedTarget.height - center.y - 0.5f;
                rect.center = center;
                Graphics.DrawTexture(rect, Texture2D.whiteTexture, new Rect(0, 0, 1, 1), 0, 0, 0, 0, new Color(1, 1, 1, 1), ResourceManager.Instance.RegionDrawerMaterial, 0);
            }

            if (_image.texture != null)
            {
                //Draw Cropped Region
                var rect = new Rect();
                rect.size = new Vector2(croppedTexture.width, croppedTexture.height);
                rect.center = _rectTransform.anchoredPosition / _rootRectTransform.sizeDelta * targetTextureSize;
                ResourceManager.Instance.RegionDrawerMaterial.SetVector("_MarqueeMinMax", new Vector4(rect.min.x, rect.min.y, rect.max.x, rect.max.y));

                var center = _rectTransform.anchoredPosition / _rootRectTransform.sizeDelta;
                center.y = 1 - center.y;
                center *= targetTextureSize;
                rect.center = center;
                Graphics.DrawTexture(rect, croppedTexture, new Rect(0, 0, 1, 1), 0, 0, 0, 0, new Color(1, 1, 1, 1), ResourceManager.Instance.RegionDrawerMaterial, 1);
            }
            GL.PopMatrix();
            Graphics.SetRenderTarget(null);
        }

        private void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnToolChanged:
                    {
                        var toolType = (EToolType)datas[0];

                        if (toolType != EToolType.Marquee)
                        {
                            Apply();
                            Inactivate();
                        }
                    }
                    break;
                case EPixelArtEventID.MarqueePaste:
                    {
                        Paste();
                    }
                    break;
                case EPixelArtEventID.OnRedoUndoMarqueeActivationCommand:
                    {
                        var undoRedoFlag = (ERedoUndo)datas[0];
                        var regionRect = (RectInt)datas[1];

                        if (undoRedoFlag == ERedoUndo.Undo)
                        {
                            Inactivate();
                        }
                        else
                        {
                            EventManager.Notify(EPixelArtEventID.ChangeTool, EToolType.Marquee);
                            Activate();
                            SetRegion(regionRect);
                        }
                    }
                    break;
                case EPixelArtEventID.OnRedoUndoMarqueeInactivationCommand:
                    {
                        var undoRedoFlag = (ERedoUndo)datas[0];
                        var prvRegionRect = (RectInt)datas[1];
                        var regionRect = (RectInt)datas[2];

                        if (undoRedoFlag == ERedoUndo.Undo)
                        {
                            EventManager.Notify(EPixelArtEventID.ChangeTool, EToolType.Marquee);
                            Activate();
                            SetRegion(regionRect);
                            _originRegion = prvRegionRect;
                        }
                        else
                        {
                            Inactivate();
                        }
                    }
                    break;
                case EPixelArtEventID.OnUndoRedoMarqueeReallocateCommand:
                    {
                        var undoRedoFlag = (ERedoUndo)datas[0];
                        var minModification = (int2)datas[1];
                        var maxModification = (int2)datas[2];

                        var textureSize = new Vector2(ResourceManager.Instance.SeedTarget.width, ResourceManager.Instance.SeedTarget.height);
                        var seedDataCoordMin = _rectTransform.anchoredPosition - (_rectTransform.sizeDelta * 0.5f);
                        seedDataCoordMin /= _rootRectTransform.sizeDelta;
                        seedDataCoordMin *= textureSize;

                        var seedDataCoordSize = _rectTransform.sizeDelta;
                        seedDataCoordSize /= _rootRectTransform.sizeDelta;
                        seedDataCoordSize *= textureSize;

                        var seedDataCoordMax = seedDataCoordMin + seedDataCoordSize;
                        if (undoRedoFlag == ERedoUndo.Undo)
                        {
                            seedDataCoordMin -= new Vector2(minModification.x, minModification.y);
                            seedDataCoordMax -= new Vector2(maxModification.x, maxModification.y);
                        }
                        else
                        {
                            seedDataCoordMin += new Vector2(minModification.x, minModification.y);
                            seedDataCoordMax += new Vector2(maxModification.x, maxModification.y);
                        }
                        seedDataCoordSize = seedDataCoordMax - seedDataCoordMin;

                        var selectedRegion = new RectInt((int)seedDataCoordMin.x, (int)seedDataCoordMin.y, (int)seedDataCoordSize.x, (int)seedDataCoordSize.y);
                        SetRegion(selectedRegion);
                    }
                    break;
                case EPixelArtEventID.OnUndoRedoMarqueeTranslateCommand:
                    {
                        var undoRedoFlag = (ERedoUndo)datas[0];
                        var draggedDelta = (float2)datas[1];

                        if (undoRedoFlag == ERedoUndo.Undo)
                            _rectTransform.anchoredPosition -= (Vector2)draggedDelta;
                        else
                            _rectTransform.anchoredPosition += (Vector2)draggedDelta;

                        _anchoredPosition = _rectTransform.anchoredPosition;
                    }
                    break;
                case EPixelArtEventID.OnPartitionChanged:
                    {
                        var partition = datas[0] as Partition;

                        _partition = partition;
                    }
                    break;
            }
        }
    }
}
