using System.Linq;
using System.Threading;

using Cysharp.Threading.Tasks;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace PixelCanvas
{
    public class PaintBoard2D : PaintBoard
    {
        [Header("PaintBoard 2D")]
        [SerializeField] private RectTransform _transformPivot;
        [SerializeField] UIMarquee _marquee;

        //Move Property
        [SerializeField] private float _moveMorphTime = 0.1f;
        private Vector2 _targetBoardPos;
        private Vector2 _prvBoardPos;
        private int2 _prvSpoidNUV;
        private Color _prvSpoidColor = Color.clear;
        private float _boardMoveTime;

        private float2 _prvBrushUV;
        private bool _brushStrokeValid;
        private bool _reserveCanvasUpdate;
        private bool _colorSpoidTriggered;

        public override EPaintBoardUXMode UXMode
        {
            get => _uxMode;
            set
            {
                if (_uxMode == value)
                    return;
                _uxMode = value;
            }
        }

        public float CurrScale
        {
            set
            {
                var scale = Mathf.Clamp(value, ResourceManager.Instance._zoomMinMax.x, ResourceManager.Instance._zoomMinMax.y);
                _transformPivot.localScale = new Vector3(scale, scale, scale);
                Shader.SetGlobalFloat(GlobalValue._ZoomRatio, Mathf.InverseLerp(ResourceManager.Instance._zoomMinMax.x, ResourceManager.Instance._zoomMinMax.y, value));

                //var sliderValue = math.unlerp(ResourceManager.Instance._zoomMInMax.x, ResourceManager.Instance._zoomMInMax.y, scale);
                //_scaleSlider.onValueChanged.SetPersistentListenerState(0, UnityEngine.Events.UnityEventCallState.Off);
                //_scaleSlider.value = sliderValue * sliderValue;
                //_scaleSlider.onValueChanged.SetPersistentListenerState(0, UnityEngine.Events.UnityEventCallState.RuntimeOnly);

                //Set Grid Alpha
                var gridAlpha = math.unlerp(0.25f, 5, scale);
                gridAlpha = math.saturate(gridAlpha);
                ResourceManager.Instance.MergedImageUIMaterial.SetFloat(GlobalValue._Alpha, gridAlpha);

                _marquee.UpdateScale(scale);
            }
            get => _transformPivot.localScale.x;
        }

        protected override void Awake()
        {
            base.Awake();

            EventManager.Register(EPixelArtEventID.OnTextureGenerated, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnSeedDataChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnPartitionChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnPaintBoardTypeChanged, NotifyEvent);
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();

            EventManager.Unregister(EPixelArtEventID.OnTextureGenerated, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnSeedDataChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnPartitionChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnPaintBoardTypeChanged, NotifyEvent);
        }

        private void Start()
        {
            _prvBoardPos = _transformPivot.anchoredPosition;
            _targetBoardPos = _transformPivot.anchoredPosition;
            _boardMoveTime = 0;

            CurrScale = 1;
        }

        protected override void OnEnable()
        {
            base.OnEnable();
            _marquee.Initialize(_canvas, _transformPivot);
            _mainToolActivation = false;

            EventManager.Register(EPixelArtEventID.OnOpenCanvas, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnToolChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ReserveCanvasUpdate, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ForceExecuteCanvasUpdate, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnLockPartition, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ExecutePaintAction, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnColorSpoidTriggered, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnColorChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnActionButtonDragged, NotifyEvent);
        }

        protected override void OnDisable()
        {
            base.OnDisable();

            EventManager.Unregister(EPixelArtEventID.OnOpenCanvas, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnToolChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ReserveCanvasUpdate, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ForceExecuteCanvasUpdate, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnLockPartition, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ExecutePaintAction, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnColorSpoidTriggered, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnColorChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnActionButtonDragged, NotifyEvent);
        }

        protected override void Update()
        {
            base.Update();
            //Board
            {
                _boardMoveTime = Mathf.Clamp(_boardMoveTime + Time.unscaledDeltaTime, 0, _moveMorphTime);
                var ratio = Mathf.InverseLerp(0, _moveMorphTime, _boardMoveTime);
                ratio = 1 - Mathf.Pow(2, ratio * -10);
                _transformPivot.anchoredPosition = Vector2.Lerp(_prvBoardPos, _targetBoardPos, ratio);
            }

            ////Brush Board Mover
            //if (_mainToolActivation == true)
            //{
            //    var halfSize = _rectTransform.rect.size * 0.5f;
            //    var clampedPos = math.clamp(_brushAim.RectTransform.anchoredPosition, -halfSize, halfSize);

            //    //var clampedPos = math.clamp(_brushAim.RectTransform.anchoredPosition, new float2((int)_rectTransform.rect.x, 0), new float2(0, (int)_rectTransform.rect.height));
            //    //var clampedPos = math.clamp(_brushAim.RectTransform.anchoredPosition, new float2(0, 0), new float2((int)_rectTransform.rect.width, (int)_rectTransform.rect.height));
            //    var delta = new Vector2(clampedPos.x, clampedPos.y) - _brushAim.AnchoredPosition;

            //    Debug.LogError(_brushAim.AnchoredPosition);
            //    if (delta != Vector2.zero)
            //    {
            //        _targetBoardPos += delta * ResourceManager.BrushBoardMoverMultiplier * Time.deltaTime;
            //    }
            //}

            if (_brushAim.UpdateAimPosition() == true)
                _reserveCanvasUpdate = true;
        }

        private void LateUpdate()
        {
            ExecuteColorSpoid();
            ExecutePaintingSequence();
        }

        private void ExecuteColorSpoid()
        {
            if (_colorSpoidTriggered == false)
                return;

            var curBrushUV = (float2)_brushAim.AimPosition;
            var uv = curBrushUV;
            if (uv.x < 0 || 1 < uv.x)
                return;
            if (uv.y < 0 || 1 < uv.y)
                return;

            var textureSize = new float2(_seedData._textureWidth, _seedData._textureHeight);
            var nUV = (int2)(curBrushUV * textureSize);
            if (_prvSpoidNUV.Equals(nUV) == true)
                return;
            _prvSpoidNUV = nUV;

            var color = ResourceManager.Instance.SeedTexture.GetPixel(nUV.x, nUV.y);
            if (color != _prvSpoidColor)
            {
                //Debug.LogError($"Spoid : {color}");
                _prvSpoidColor = color;
                EventManager.Notify(EPixelArtEventID.ChangeColor, color);
            }

            EventManager.Notify(EPixelArtEventID.ChangePartitionByUV, _brushAim.AimPosition);
        }

        private void ExecutePaintingSequence()
        {
            if (_reserveCanvasUpdate == false)
                return;

            var pass = default(EBrushPass);
            var strokeThickness = 0.0f;
            var strokeSolidity = 0.0f;
            var strokeFlow = 0.0f;
            var textureSize = new float2(_seedData._textureWidth, _seedData._textureHeight);

            switch (ToolGroup.ToolSettings.ToolType)
            {
                case EToolType.Brush:
                    strokeThickness = ToolGroup.ToolSettings.BrushThicknessSlider;
                    strokeSolidity = ToolGroup.ToolSettings.BrushSoftnessSlider;
                    strokeFlow = ToolGroup.ToolSettings.BrushFlowSlider;

                    if (ToolGroup.ToolSettings.BrushFlowSlider == 1)
                        pass = EBrushPass.Brush;
                    else
                        pass = EBrushPass.Brush_Continuous;
                    break;
                case EToolType.Eraser:
                    strokeThickness = ToolGroup.ToolSettings.EraserThicknessSlider;
                    strokeSolidity = ToolGroup.ToolSettings.EraserSoftnessSlider;
                    strokeFlow = ToolGroup.ToolSettings.EraserFlowSlider;

                    if (ToolGroup.ToolSettings.EraserFlowSlider == 1)
                        pass = EBrushPass.Eraser;
                    else
                        pass = EBrushPass.Eraser_Continuous;
                    break;
                default:
                    break;
            }
            if (_colorSpoidTriggered == true)
                strokeThickness = 1;

            var curBrushUV = _brushAim.AimPosition;
            var prvBrushUV = (Vector2)_prvBrushUV;
            _prvBrushUV = curBrushUV;

            if (_mainToolActivation == false)
            {
                Shader.SetGlobalVector(GlobalValue._BrushColor, _colorPallete.Color.linear);
                Graphics.Blit(Texture2D.blackTexture, ResourceManager.Instance.DrawingLayerTarget);
                EventManager.Notify(EPixelArtEventID.ChangePartitionByUV, curBrushUV);
                prvBrushUV = curBrushUV;
            }
            EventManager.Notify(EPixelArtEventID.ChangeSelectedUV, new int2((int)(_seedData._textureWidth * curBrushUV.x), (int)(_seedData._textureHeight * curBrushUV.y)));

            var normPartition = _partition._normPartition;
            var normPartitionBegPos = normPartition.min;
            var normPartitionEndPos = normPartition.max;
            var normPartitionSize = normPartitionEndPos - normPartitionBegPos;

            var brushIndicatorVisibility = _brushAim.ContainsAnyVisibleState(EAimVisibleState.BrushIndicator);
            Shader.SetGlobalVector(GlobalValue._BrushStyle, new float4(strokeThickness, strokeSolidity, strokeFlow, (brushIndicatorVisibility == true) ? 1 : 0));
            Shader.SetGlobalVector(GlobalValue._Parameters1, new float4(textureSize.x, textureSize.y, textureSize.x * _seedData._scale, textureSize.y * _seedData._scale));

            switch (_toolType)
            {
                case EToolType.Brush:
                case EToolType.Eraser:
                case EToolType.Spoid:
                case EToolType.PaintCan:
                    {
                        if (_mainToolActivation == false && brushIndicatorVisibility == false)
                            break;

                        Shader.SetGlobalTexture(GlobalValue._SeedTex, ResourceManager.Instance.CanvasTarget);

                        // Checking whether Brush Stroke is Valid in Canvas or not.
                        var stroke = new Vector2(strokeThickness, strokeThickness) * 0.5f;
                        stroke /= ((Vector2)textureSize * normPartitionSize);
                        var rect = new Rect(0, 0, 1, 1);
                        rect.min -= stroke;
                        rect.max += stroke;
                        if (LineIntersectsRect(prvBrushUV, curBrushUV, rect) == true)
                        {
                            //X Mirror Brushing
                            if (ToolGroup.BrushXMirrortoggle == true)
                            {
                                var flippedPrvBrushUV = prvBrushUV;
                                var flippedCurBrushUV = prvBrushUV;
                                flippedPrvBrushUV.x = normPartitionEndPos.x - flippedPrvBrushUV.x + normPartitionBegPos.x;
                                flippedCurBrushUV.x = normPartitionEndPos.x - flippedCurBrushUV.x + normPartitionBegPos.x;
                                Shader.SetGlobalVector(GlobalValue._Parameters0, new float4(flippedPrvBrushUV.x, flippedPrvBrushUV.y, flippedCurBrushUV.x, flippedCurBrushUV.y));
                                Graphics.Blit(_seedData._originSeedTarget, ResourceManager.Instance.DrawingLayerTarget, ResourceManager.Instance.BrushMaterial, (int)pass);
                            }

                            Shader.SetGlobalVector(GlobalValue._Parameters0, new float4(prvBrushUV.x, prvBrushUV.y, curBrushUV.x, curBrushUV.y));
                            Graphics.Blit(_seedData._originSeedTarget, ResourceManager.Instance.DrawingLayerTarget, ResourceManager.Instance.BrushMaterial, (int)pass);

                            if (_mainToolActivation == true)
                                _brushStrokeValid = true;
                        }
                    }
                    break;
                case EToolType.Marquee:
                    {
                        if (_mainToolActivation == false)
                            break;

                        _marquee.UpdateRegion(_brushAim.AimPosition);
                    }
                    break;
            }

            _marquee.Draw();

            //Copy Seed Texture
            Graphics.Blit(ResourceManager.Instance.SeedTarget, ResourceManager.Instance.MergedTarget);

            //Merge Drawing Layer
            Graphics.Blit(ResourceManager.Instance.DrawingLayerTarget, ResourceManager.Instance.MergedTarget, ResourceManager.Instance.DrawingLayerMergerMaterial);

            //Copy Merged Texture
            Graphics.Blit(ResourceManager.Instance.MergedTarget, ResourceManager.Instance.CanvasTarget);

            switch (_seedData._upscaleType)
            {
                case EUpscaleType.Xbrz:
                    //Upscale Texture
                    Graphics.Blit(ResourceManager.Instance.CanvasTarget, ResourceManager.Instance.ScaledTarget, ResourceManager.Instance.UpscaleMaterial, 0, 0);
                    break;
                default:
                    //Non Upscale Texture
                    Graphics.Blit(ResourceManager.Instance.CanvasTarget, ResourceManager.Instance.ScaledTarget);
                    break;
            }

            _reserveCanvasUpdate = false;

            static bool LineIntersectsRect(float2 p1, float2 p2, Rect r)
            {
                return r.Contains(p1) ||
                       r.Contains(p2) ||
                       LineIntersectsLine(p1, p2, new float2(r.x, r.y), new float2(r.x + r.width, r.y)) ||
                       LineIntersectsLine(p1, p2, new float2(r.x + r.width, r.y), new float2(r.x + r.width, r.y + r.height)) ||
                       LineIntersectsLine(p1, p2, new float2(r.x + r.width, r.y + r.height), new float2(r.x, r.y + r.height)) ||
                       LineIntersectsLine(p1, p2, new float2(r.x, r.y + r.height), new float2(r.x, r.y));

                static bool LineIntersectsLine(float2 l1p1, float2 l1p2, float2 l2p1, float2 l2p2)
                {
                    float q = (l1p1.y - l2p1.y) * (l2p2.x - l2p1.x) - (l1p1.x - l2p1.x) * (l2p2.y - l2p1.y);
                    float d = (l1p2.x - l1p1.x) * (l2p2.y - l2p1.y) - (l1p2.y - l1p1.y) * (l2p2.x - l2p1.x);

                    if (d == 0)
                    {
                        return false;
                    }

                    float r = q / d;


                    q = (l1p1.y - l2p1.y) * (l1p2.x - l1p1.x) - (l1p1.x - l2p1.x) * (l1p2.y - l1p1.y);
                    float s = q / d;

                    if (r < 0 || 1 < r || s < 0 || 1 < s)
                    {
                        return false;
                    }

                    return true;
                }
            }
        }

        private void ValidateMoveTarget()
        {
            var paintBoardSize = _transformPivot.sizeDelta * CurrScale;
            var paintBoardHalfSize = paintBoardSize * 0.5f;

            //_transformPivot.pivot may change during Zoom Operations(Not fixed on (0.5, 0.5))
            var pivotOffset = new Vector2(0.5f, 0.5f) - new Vector2(_transformPivot.pivot.x, _transformPivot.pivot.y);
            pivotOffset *= paintBoardSize;
            var anchoredCenterPos = _targetBoardPos + pivotOffset;

            var minMargin = 300;
            var boardHalfSizeX = _rectTransform.rect.width * 0.5f + (paintBoardHalfSize.x - minMargin);
            var boardHalfSizeY = _rectTransform.rect.height * 0.5f + (paintBoardHalfSize.y - minMargin);
            anchoredCenterPos.x = Mathf.Clamp(anchoredCenterPos.x, -boardHalfSizeX, boardHalfSizeX);
            anchoredCenterPos.y = Mathf.Clamp(anchoredCenterPos.y, -boardHalfSizeY, boardHalfSizeY);

            _targetBoardPos = anchoredCenterPos - pivotOffset;
        }


        public override void OnPointerDown(PointerEventData eventData)
        {
            EventManager.Notify(EPixelArtEventID.OnPainboardTouch);

            switch (eventData.button)
            {
                case PointerEventData.InputButton.Right:
                    {
                        UXMode = EPaintBoardUXMode.OneFingerMode;
                        _inputCollector.Add(eventData.pointerId, eventData);
                    }
                    return;
                    //case PointerEventData.InputButton.Middle:
                    //	{
                    //		UXMode = EPaintBoard3DUXMode.;
                    //		_inputCollector.Add(eventData.pointerId, eventData);
                    //	}
                    //	return;
            }

            switch (UXMode)
            {
                case EPaintBoardUXMode.None:
                    UXMode = EPaintBoardUXMode.OneFingerMode;
                    if (_mainToolActivation == false && _colorSpoidTriggered == false)
                        _brushAim.ActivatePressedTimeGuage(Time.unscaledTime, eventData.position);
                    _inputCollector.Add(eventData.pointerId, eventData);
                    break;
                case EPaintBoardUXMode.JoystickMode:
                    break;
                case EPaintBoardUXMode.ToolFingerMode:
                    break;
                case EPaintBoardUXMode.OneFingerMode:
                    UXMode = EPaintBoardUXMode.DoubleFingerMode;
                    _brushAim.InactivatePressedTimeGuage();
                    _inputCollector.Add(eventData.pointerId, eventData);

                    var touch0 = _inputCollector.First().Value;
                    var touch1 = _inputCollector.Last().Value;
                    var curCenterPos = (touch0.position + touch1.position) * 0.5f;
                    RectTransformUtility.ScreenPointToLocalPointInRectangle(_transformPivot, curCenterPos, _canvas.worldCamera, out var localPoint);
                    var newPivot = localPoint / _mergedImage.rectTransform.sizeDelta + _transformPivot.pivot;
                    var oldPivot = _transformPivot.pivot;
                    var pivotDelta = newPivot - oldPivot;
                    var size = _transformPivot.sizeDelta;
                    var positionOffset = pivotDelta * size * CurrScale;
                    _transformPivot.pivot = newPivot;
                    _transformPivot.anchoredPosition += positionOffset;

                    _prvBoardPos = _transformPivot.anchoredPosition;
                    _targetBoardPos = _transformPivot.anchoredPosition;

                    break;
                case EPaintBoardUXMode.DoubleFingerMode:
                    break;
                case EPaintBoardUXMode.MouseMode:
                    break;
            }
        }

        public override void OnDrag(PointerEventData eventData)
        {
            //_doubleTabTimer = 0;

            //Standalone_Platform
            //switch (eventData.button)
            //{
            //    //case PointerEventData.InputButton.Middle:
            //    //    {
            //    //        _boardMoveTime = 0;
            //    //        _prvBoardPos = _transformPivot.anchoredPosition;
            //    //        _targetBoardPos += (eventData.delta / _canvas.scaleFactor);
            //    //        _reserveCanvasUpdate = true;
            //    //        return;
            //    //    }
            //}

            if (_inputCollector.ContainsKey(eventData.pointerId) == false)
                return;

            switch (UXMode)
            {
                case EPaintBoardUXMode.None:
                    break;
                case EPaintBoardUXMode.JoystickMode:
                    break;
                case EPaintBoardUXMode.ToolFingerMode:
                    {
                        _brushAim.InactivatePressedTimeGuage();
                        _brushAim.AnchoredPosition += (eventData.delta / _canvas.scaleFactor);
                    }
                    break;
                case EPaintBoardUXMode.OneFingerMode:
                    {
                        _brushAim.SetVisibleState(EAimVisibleState.ALL);
                        _brushAim.ResetPosition();
                        if (_brushAim.IsTabPaintingValid() == true)
                        {
                            if (ResourceManager.Instance._fingerToolDragThreashold < eventData.delta.magnitude)
                            {
                                _brushAim.InactivatePressedTimeGuage();
                                break;
                            }
                        }

                        _boardMoveTime = 0;
                        _prvBoardPos = _transformPivot.anchoredPosition;
                        _targetBoardPos += (eventData.delta / _canvas.scaleFactor);
                    }
                    break;
                case EPaintBoardUXMode.DoubleFingerMode:
                    {
                        _brushAim.SetVisibleState(EAimVisibleState.ALL);
                        _brushAim.ResetPosition();

                        var touch0 = _inputCollector.First().Value;
                        var touch1 = _inputCollector.Last().Value;
                        touch0.delta *= 0.5f;
                        touch1.delta *= 0.5f;

                        var prvTouchZeroPos = touch0.position - (touch0.delta / _canvas.scaleFactor);
                        var prvTouchOnePos = touch1.position - (touch1.delta / _canvas.scaleFactor);

                        var prvCenterPos = (prvTouchZeroPos + prvTouchOnePos) * 0.5f;
                        var curCenterPos = (touch0.position + touch1.position) * 0.5f;

                        var centerPosDelta = curCenterPos - prvCenterPos;

                        var prevTouchDeltaMag = Vector2.Distance(prvTouchZeroPos, prvTouchOnePos);
                        var currTouchDeltaMag = Vector2.Distance(touch0.position, touch1.position);

                        var prvMultiTouchCenterPos = (prvTouchZeroPos + prvTouchOnePos) * 0.5f;
                        var currMultiTouchCenterPos = (touch0.position + touch1.position) * 0.5f;

                        //Move
                        _boardMoveTime = 0;
                        _prvBoardPos = _transformPivot.anchoredPosition;
                        _targetBoardPos += (centerPosDelta / _canvas.scaleFactor);

                        ////Rotate
                        //var prvVector = prvTouchZeroPos - prvTouchOnePos;
                        //var currVector = touch1.position - touch2.position;
                        //_pivotRectTransform.RotateAround(_uiCamera.ScreenToWorldPoint(currMultiTouchCenterPos.ToVector3()), Vector3.forward, Vector2.SignedAngle(prvVector, currVector));

                        //Scale
                        var scale = (currTouchDeltaMag / prevTouchDeltaMag);
                        var newScaleValue = CurrScale * scale;
                        newScaleValue = Mathf.Clamp(newScaleValue, ResourceManager.Instance._zoomMinMax.x, ResourceManager.Instance._zoomMinMax.y);
                        if (CurrScale != newScaleValue)
                        {
                            var dot = Vector2.Dot(touch0.delta.normalized, touch1.delta.normalized);
                            var angle = math.degrees(math.acos(dot));
                            if (angle == math.NAN)
                                angle = 0;

                            if (ResourceManager.Instance._zoomAngleThreashold < angle)
                                CurrScale = newScaleValue;
                        }
                    }
                    break;
                case EPaintBoardUXMode.MouseMode:
                    break;
            }
            _reserveCanvasUpdate = true;
        }

        public override void OnPointerUp(PointerEventData eventData)
        {
            //switch (eventData.button)
            //{
            //    case PointerEventData.InputButton.Middle:
            //        _boardMoveTime = 0;
            //        _prvBoardPos = _transformPivot.anchoredPosition;
            //        break;
            //}

            if (_inputCollector.ContainsKey(eventData.pointerId) == false)
                return;

            switch (UXMode)
            {
                case EPaintBoardUXMode.None:
                    break;
                case EPaintBoardUXMode.JoystickMode:
                    break;
                case EPaintBoardUXMode.ToolFingerMode:
                    {
                        UXMode = EPaintBoardUXMode.None;
                        _brushAim.InactivatePressedTimeGuage();
                        _brushAim.SetVisibleState(EAimVisibleState.None);
                        EventManager.Notify(EPixelArtEventID.TriggerMainTool, false);
                    }
                    break;
                case EPaintBoardUXMode.OneFingerMode:
                    {
                        UXMode = EPaintBoardUXMode.None;

                        _boardMoveTime = 0;
                        _prvBoardPos = _transformPivot.anchoredPosition;

                        if (_brushAim.IsTabPaintingValid() == true)
                        {
                            RectTransformUtility.ScreenPointToLocalPointInRectangle(_rectTransform, eventData.position, _uiCamera, out var position);
                            _brushAim.AnchoredPosition = position;

                            EventManager.Notify(EPixelArtEventID.ChangePartitionByUV, _brushAim.AimPosition);
                            EventManager.Notify(EPixelArtEventID.ExecutePaintAction, EBitPaintActionTrigger.ALL);

                            _brushAim.InactivatePressedTimeGuage();
                            _brushAim.SetVisibleState(EAimVisibleState.None);
                        }
                        ValidateMoveTarget();
                    }
                    break;
                case EPaintBoardUXMode.DoubleFingerMode:
                    {
                        UXMode = EPaintBoardUXMode.OneFingerMode;
                        _boardMoveTime = 0;
                        _prvBoardPos = _transformPivot.anchoredPosition;
                    }
                    break;
                case EPaintBoardUXMode.MouseMode:
                    break;
            }
            _inputCollector.Remove(eventData.pointerId);
        }

        public override void OnScroll(PointerEventData eventData)
        {
            // Set the new scale
            eventData.scrollDelta = eventData.scrollDelta.normalized;
            var additionalScale = eventData.scrollDelta.y * _scrollMultiplier;
            var newScale = CurrScale + additionalScale;
            newScale = Mathf.Clamp(newScale, ResourceManager.Instance._zoomMinMax.x, ResourceManager.Instance._zoomMinMax.y);
            if (newScale == CurrScale)
                return;

            var scale = newScale / CurrScale;
            CurrScale = newScale;

            RectTransformUtility.ScreenPointToLocalPointInRectangle(_transformPivot, eventData.position, _canvas.worldCamera, out var localPoint);
            var newPivot = localPoint / _mergedImage.rectTransform.sizeDelta + _transformPivot.pivot;
            var oldPivot = _transformPivot.pivot;
            var pivotDelta = newPivot - oldPivot;
            var size = _transformPivot.sizeDelta;
            var positionOffset = pivotDelta * size * CurrScale;
            _transformPivot.pivot = newPivot;
            _transformPivot.anchoredPosition += positionOffset;
            _prvBoardPos = _transformPivot.anchoredPosition;
            _targetBoardPos = _transformPivot.anchoredPosition;
            ValidateMoveTarget();

            _brushAim.ResetPosition();
            _brushAim.SetVisibleState(EAimVisibleState.ALL);
            _reserveCanvasUpdate = true;
        }

        private void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnOpenCanvas:
                    {
                    }
                    break;
                case EPixelArtEventID.OnPaintBoardTypeChanged:
                    {
                        var paintBoardType = (EPaintBoardType)datas[0];

                        switch (paintBoardType)
                        {
                            case EPaintBoardType.PaintBoard2D:
                                Graphics.Blit(Texture2D.blackTexture, ResourceManager.Instance.DrawingLayerTarget);

                                gameObject.SetActive(true);
                                _brushAim.Initialize(this);
                                _reserveCanvasUpdate = true;
                                break;
                            case EPaintBoardType.PaintBoard3D:
                                gameObject.SetActive(false);
                                break;
                        }

                        _brushAim.SetVisibleState(EAimVisibleState.None);
                        _brushAim.ResetPosition();
                    }
                    break;
                case EPixelArtEventID.OnTextureGenerated:
                    _mergedImage.texture = ResourceManager.Instance.CanvasTarget;
                    break;
                case EPixelArtEventID.OnSeedDataChanged:
                    {
                        var seedData = datas[0] as SeedData;
                        _seedData = seedData;
                    }
                    break;
                case EPixelArtEventID.OnToolChanged:
                    {
                        var toolType = (EToolType)datas[0];
                        _toolType = toolType;

                        switch (_toolType)
                        {
                            case EToolType.Brush:
                            case EToolType.Eraser:
                                _brushAim.SetVisibleState(EAimVisibleState.ALL);
                                break;
                            case EToolType.PaintCan:
                                _brushAim.SetVisibleState(EAimVisibleState.CrossHair);
                                break;
                            case EToolType.Marquee:
                                _brushAim.SetVisibleState(EAimVisibleState.CrossHair);
                                break;
                        }
                    }
                    break;
                case EPixelArtEventID.ReserveCanvasUpdate:
                    {
                        _reserveCanvasUpdate = true;
                    }
                    break;
                case EPixelArtEventID.ForceExecuteCanvasUpdate:
                    {
                        _reserveCanvasUpdate = true;
                        ExecutePaintingSequence();
                    }
                    break;
                case EPixelArtEventID.OnPartitionChanged:
                    {
                        var partition = datas[0] as Partition;

                        _partition = partition;
                        var seedTextureSize = new Vector2(_seedData._textureWidth, _seedData._textureHeight);
                        _mergedImage.material.SetVector(GlobalValue._Parameters1, new Vector4(seedTextureSize.x, seedTextureSize.y, 0, 0));
                    }
                    break;
                case EPixelArtEventID.OnLockPartition:
                    {
                        _reserveCanvasUpdate = true;
                    }
                    break;
                case EPixelArtEventID.ExecutePaintAction:
                    {
                        var bitTrigger = (EBitPaintActionTrigger)datas[0];

                        switch (_toolType)
                        {
                            case EToolType.Brush:
                            case EToolType.Eraser:
                                if (bitTrigger.Contains(EBitPaintActionTrigger.Press) == true)
                                {
                                    _mainToolActivation = true;
                                    EventManager.Notify(EPixelArtEventID.ChangePartitionByUV, _brushAim.AimPosition);
                                    _brushAim.SetVisibleState(EAimVisibleState.BrushIndicator);
                                    _prvBrushUV = _brushAim.AimPosition;
                                    Graphics.Blit(Texture2D.blackTexture, ResourceManager.Instance.DrawingLayerTarget);
                                    _reserveCanvasUpdate = true;
                                    _brushStrokeValid = false;
                                }

                                if (bitTrigger == EBitPaintActionTrigger.ALL)
                                {
                                    ExecutePaintingSequence();
                                }

                                if (bitTrigger.Contains(EBitPaintActionTrigger.Release) == true)
                                {
                                    _mainToolActivation = false;
                                    if (_brushStrokeValid == false)
                                        break;
                                    _brushStrokeValid = false;
                                    EventManager.Notify(EPixelArtEventID.AddTaskCommand, new BrushCommand(ECanvasType.Albedo));
                                }
                                break;
                            case EToolType.PaintCan:
                                if (bitTrigger.Contains(EBitPaintActionTrigger.Press) == true)
                                {
                                    _mainToolActivation = true;
                                }

                                if (bitTrigger.Contains(EBitPaintActionTrigger.Release) == true)
                                {
                                    _mainToolActivation = false;

                                    var textureSize = new Vector2(_seedData._textureWidth, _seedData._textureHeight);
                                    var uv = _brushAim.AimPosition / _mergedImage.rectTransform.sizeDelta;
                                    var nUV = _brushAim.AimPosition * textureSize;

                                    var partitionBeg = _partition._normPartition.min * textureSize;
                                    var partitionSize = _partition._normPartition.size * textureSize;
                                    var partition = new RectInt((int)partitionBeg.x, (int)partitionBeg.y, (int)partitionSize.x, (int)partitionSize.y);

                                    _reserveCanvasUpdate = true;

                                    var taskCommand = new PaintCommand(ECanvasType.Albedo, new int2((int)nUV.x, (int)nUV.y), partition, _colorPallete.Color, ToolGroup.ToolSettings.PaintColorThreasholdSlider, ToolGroup.BrushXMirrortoggle);
                                    EventManager.Notify(EPixelArtEventID.AddTaskCommand, taskCommand);
                                }
                                break;
                            case EToolType.Spoid:
                                {
                                    if (bitTrigger.Contains(EBitPaintActionTrigger.Press) == true)
                                    {
                                        _mainToolActivation = true;
                                        EventManager.Notify(EPixelArtEventID.ChangePartitionByUV, _brushAim.AimPosition);
                                        _brushAim.SetVisibleState(EAimVisibleState.BrushIndicator);
                                        _prvBrushUV = _brushAim.AimPosition;
                                        _reserveCanvasUpdate = true;
                                        EventManager.Notify(EPixelArtEventID.OnColorSpoidTriggered, true);
                                    }

                                    if (bitTrigger == EBitPaintActionTrigger.ALL)
                                    {
                                        ExecuteColorSpoid();
                                    }

                                    if (bitTrigger.Contains(EBitPaintActionTrigger.Release) == true)
                                    {
                                        _mainToolActivation = false;
                                        _brushStrokeValid = false;
                                        EventManager.Notify(EPixelArtEventID.OnColorSpoidTriggered, false);
                                    }
                                }
                                break;
                            case EToolType.Marquee:
                                if (bitTrigger == EBitPaintActionTrigger.ALL)
                                {
                                    _mainToolActivation = true;
                                    EventManager.Notify(EPixelArtEventID.ChangePartitionByUV, _brushAim.AimPosition);
                                    _brushAim.SetVisibleState(EAimVisibleState.None);

                                    if (_marquee.gameObject.activeSelf == true)
                                    {
                                        _mainToolActivation = false;
                                        _marquee.Apply();
                                        _marquee.Inactivate();
                                        break;
                                    }
                                    else
                                    {
                                        _marquee.BeginRegion(_brushAim.AimPosition);
                                    }

                                    _reserveCanvasUpdate = true;
                                    ExecutePaintingSequence();

                                    _mainToolActivation = false;
                                    _marquee.EndRegion();
                                }
                                else
                                {
                                    if (bitTrigger.Contains(EBitPaintActionTrigger.Press) == true)
                                    {
                                        _mainToolActivation = true;
                                        EventManager.Notify(EPixelArtEventID.ChangePartitionByUV, _brushAim.AimPosition);
                                        _brushAim.SetVisibleState(EAimVisibleState.None);

                                        _marquee.BeginRegion(_brushAim.AimPosition);

                                        _reserveCanvasUpdate = true;
                                    }

                                    if (bitTrigger.Contains(EBitPaintActionTrigger.Release) == true)
                                    {
                                        _mainToolActivation = false;
                                        _marquee.EndRegion();
                                    }
                                }
                                break;
                        }
                    }
                    break;
                case EPixelArtEventID.OnColorSpoidTriggered:
                    {
                        var trigger = (bool)datas[0];
                        _colorSpoidTriggered = trigger;
                        if (trigger == true)
                            _brushAim.SetVisibleState(EAimVisibleState.ALL);
                        else
                            _brushAim.SetVisibleState(EAimVisibleState.None);
                        //_brushAim.ResetPosition();
                        _reserveCanvasUpdate = true;
                    }
                    break;
                case EPixelArtEventID.OnColorChanged:
                    {
                        _brushAim.SetVisibleState(EAimVisibleState.ALL);
                    }
                    break;
                case EPixelArtEventID.OnActionButtonDragged:
                    {
                        var draggedDelta = (Vector2)datas[0];
                        _prvBoardPos = _transformPivot.anchoredPosition;
                        _targetBoardPos -= (draggedDelta / _canvas.scaleFactor);
                    }
                    break;
            }
        }
    }
}