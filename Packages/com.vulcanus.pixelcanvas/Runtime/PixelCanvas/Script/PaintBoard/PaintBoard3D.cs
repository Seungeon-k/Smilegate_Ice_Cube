using System.Linq;

using Cysharp.Threading.Tasks;

using TMPro;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using UnityEngine.UI;

#if UNITY_EDITOR
#endif

namespace PixelCanvas
{
    public class PaintBoard3D : PaintBoard
    {
        [Header("PaintBoard 3D")]
        [SerializeField] private Environment3D_PaintBoard3D _environment3D;
        [SerializeField] private RectTransform _backgroundRectTransform;
        [SerializeField] private EventTrigger _rotaterEventTrigger;
        [SerializeField] private TMP_Text _uxModeText;

        [Header("Gesture UI")]
        [SerializeField] private Image _gesturePivot;
        private Vector3 _pressedPivot;

        private bool _colorSpoidTriggered;
        private bool _reserveCanvasUpdate;
        private float2 _modelRotationDelta;
        private bool _drawBrushOnCenter;
        private bool _joystickPressed;
        private Color _prvSpoidColor = Color.clear;
        private RaycastHit _prvRayCastHit;
        private RenderTexture _backBuffer;

        public override EPaintBoardUXMode UXMode
        {
            get => _uxMode;
            set
            {
                if (value == _uxMode)
                    return;

                switch (value)
                {
                    case EPaintBoardUXMode.None:
                        break;
                    case EPaintBoardUXMode.JoystickMode:
                        _drawBrushOnCenter = true;
                        break;
                    case EPaintBoardUXMode.ToolFingerMode:
                        _drawBrushOnCenter = false;
                        break;
                    case EPaintBoardUXMode.OneFingerMode:
                        break;
                    case EPaintBoardUXMode.DoubleFingerMode:
                        _drawBrushOnCenter = true;
                        break;
                }
                _uxMode = value;
                _uxModeText.text = _uxMode.ToString();

                EventManager.Notify(EPixelArtEventID.OnUXModeChanged, value);
            }
        }

        protected override void Awake()
        {
            base.Awake();

            _mergedImage.color = Color.white;

            _backBuffer = _environment3D.VirtualCamera.ColorBuffer;
            _gesturePivot.CrossFadeAlpha(0, 0, true);
            ////Model Rotater Button Event
            //_rotaterEventTrigger.triggers = new List<EventTrigger.Entry>
            //{
            //    EventTriggerUtility.Create(EventTriggerType.PointerDown, OnRotaterDown),
            //    EventTriggerUtility.Create(EventTriggerType.Drag,        OnRotaterDrag),
            //    EventTriggerUtility.Create(EventTriggerType.PointerUp,   OnRotaterUp),
            //};

            EventManager.Register(EPixelArtEventID.OnOpenCanvas, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnSeedDataChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnPartitionChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnPaintBoardTypeChanged, NotifyEvent);

#if !PIXELCANVAS_EDITOR
            _uxModeText.gameObject.SetActive(false);
#endif
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();

            EventManager.Unregister(EPixelArtEventID.OnOpenCanvas, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnSeedDataChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnPartitionChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnPaintBoardTypeChanged, NotifyEvent);
        }

        protected override void OnEnable()
        {
            base.OnEnable();

            EventManager.Register(EPixelArtEventID.OnScreenSizeChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnToolChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ReserveCanvasUpdate, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ResetAimPosition, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnLockPartition, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnUndoRedo, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ExecutePaintAction, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnActionButtonDragged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.SwapMovingMode, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnColorSpoidTriggered, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnColorChanged, NotifyEvent);

            RenderPipelineManager.beginFrameRendering += BeginFrameRendering;
        }

        protected override void OnDisable()
        {
            base.OnDisable();

            EventManager.Unregister(EPixelArtEventID.OnScreenSizeChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnToolChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ReserveCanvasUpdate, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ResetAimPosition, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnLockPartition, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnUndoRedo, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ExecutePaintAction, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnActionButtonDragged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.SwapMovingMode, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnColorSpoidTriggered, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnColorChanged, NotifyEvent);

            RenderPipelineManager.beginFrameRendering -= BeginFrameRendering;
        }

        protected override void Update()
        {
            base.Update();
            UpdateDoubleFingerDragGesture();
        }

        private void BeginFrameRendering(ScriptableRenderContext context, Camera[] cameras)
        {
            if (cameras.Length == 0)
                return;
            if (cameras[0].cameraType != CameraType.Game)
                return;

            ExecuteColorSpoid();
            ExecutePaintingSequence();
        }

        private void ExecuteColorSpoid()
        {
            if (_colorSpoidTriggered == false)
                return;

            if (RaycastPixel(_brushAim.AimPosition, ref _prvRayCastHit) == false)
                return;

            var textureSize = new Vector2(_seedData._textureWidth, _seedData._textureHeight);
            var nUV = (int2)((float2)_prvRayCastHit.textureCoord * (float2)textureSize);

            var color = ResourceManager.Instance.SeedTexture.GetPixel(nUV.x, nUV.y);
            if (color != _prvSpoidColor)
            {
                _prvSpoidColor = color;
                EventManager.Notify(EPixelArtEventID.ChangeColor, color);
            }
        }

        private void ExecutePaintingSequence()
        {
            //if (_mainToolActivation == false && _reserveCanvasUpdate == false)
            if (_reserveCanvasUpdate == false)
                return;

            var pass = default(EBrushPass);
            var strokeThickness = 0.0f;
            var strokeSolidity = 0.0f;
            var strokeFlow = 0.0f;
            var textureSize = new Vector2(_seedData._textureWidth, _seedData._textureHeight);

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

            var brushStyle = Shader.GetGlobalVector(GlobalValue._BrushStyle);
            brushStyle.x = (_colorSpoidTriggered == true) ? 1 : strokeThickness;
            brushStyle.y = strokeSolidity;
            brushStyle.z = strokeFlow;
            Shader.SetGlobalVector(GlobalValue._BrushStyle, brushStyle);
            Shader.SetGlobalVector(GlobalValue._Parameters1, new float4(textureSize.x, textureSize.y, textureSize.x * _seedData._scale, textureSize.y * _seedData._scale));
            Shader.SetGlobalTexture(GlobalValue._SeedTex, ResourceManager.Instance.CanvasTarget);

            if (_mainToolActivation == false)
            {
                Shader.SetGlobalVector(GlobalValue._BrushColor, _colorPallete.Color.linear);
                Graphics.Blit(Texture2D.blackTexture, ResourceManager.Instance.DrawingLayerTarget);
            }

            if (RaycastPixel(_brushAim.AimPosition, ref _prvRayCastHit) == true)
            {
                //Check SubMesh Index
                var validSubMesh = true;
                var meshCollider = _prvRayCastHit.collider as MeshCollider;
                if (1 < meshCollider.sharedMesh.subMeshCount)
                {
                    var desc = meshCollider.sharedMesh.GetSubMesh(0);
                    if (_prvRayCastHit.triangleIndex < desc.indexCount / 3)
                        validSubMesh = false;
                }

                if (validSubMesh == true && (_mainToolActivation == true || _brushAim.ContainsAnyVisibleState(EAimVisibleState.BrushIndicator) == true))
                {
                    if (ToolGroup.BrushXMirrortoggle == true)
                    {
                        var normPartition = _partition._normPartition;
                        var normPartitionBegPos = normPartition.min;
                        var normPartitionEndPos = normPartition.max;
                        var brushUV = _prvRayCastHit.textureCoord;

                        brushUV.x = normPartitionEndPos.x - brushUV.x + normPartitionBegPos.x;
                        Shader.SetGlobalVector(GlobalValue._Parameters0, new float4(brushUV.x, brushUV.y, brushUV.x, brushUV.y));
                        Graphics.Blit(_seedData._originSeedTarget, ResourceManager.Instance.DrawingLayerTarget, ResourceManager.Instance.BrushMaterial, (int)pass);
                    }
                    Shader.SetGlobalVector(GlobalValue._Parameters0, new float4(_prvRayCastHit.textureCoord.x, _prvRayCastHit.textureCoord.y, _prvRayCastHit.textureCoord.x, _prvRayCastHit.textureCoord.y));
                    Graphics.Blit(_seedData._originSeedTarget, ResourceManager.Instance.DrawingLayerTarget, ResourceManager.Instance.BrushMaterial, (int)pass);
                }
                else
                {
                    Shader.SetGlobalVector(GlobalValue._Parameters0, new float4(-1000, -1000, -1000, -1000));
                    //Graphics.Blit(Texture2D.blackTexture, ResourceManager.Instance.BrushProjectorLayerTarget);
                }
            }
            else
            {
                Shader.SetGlobalVector(GlobalValue._Parameters0, new float4(-1000, -1000, -1000, -1000));
            }

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
        }

        public bool RaycastPixel(Vector2 aimPosition, ref RaycastHit raycastHit)
        {
            var viewportClick = aimPosition;
            var ray = _environment3D.VirtualCamera.ViewportPointToRay(new Vector3(viewportClick.x, viewportClick.y, 0));

            if (Physics.Raycast(ray, out RaycastHit hit, Mathf.Infinity, GlobalValue._DefaultLayer) == false)
            {
                //Notify Once
                if (raycastHit.collider != hit.collider)
                    EventManager.Notify(EPixelArtEventID.ChangePartitionByUV, new Vector2(-1, -1));
                raycastHit = hit;
                return false;
            }
            else
            {
                //Raycast targeted Renderer
                if (hit.collider.CompareTag("Player") == false)
                    return false;

                if (0 < Vector3.Dot(hit.normal, ray.direction))
                    return false;
            }

            EventManager.Notify(EPixelArtEventID.ChangeSelectedUV, new int2((int)(_seedData._textureWidth * hit.textureCoord.x), (int)(_seedData._textureHeight * hit.textureCoord.y)));
            EventManager.Notify(EPixelArtEventID.ChangePartitionByUV, hit.textureCoord);
            raycastHit = hit;
            return true;
        }

        private Vector2 _cameraRevolutionEuler = new Vector2(180, 0);
        private Vector3 _cameraRevolutionOffset;

        public void OnPointerMove(PointerEventData eventData)
        {

        }

        public override void OnPointerDown(PointerEventData eventData)
        {
            EventManager.Notify(EPixelArtEventID.OnPainboardTouch);

            switch (eventData.button)
            {
                case PointerEventData.InputButton.Right:
                    {
                        var screenSize = new Vector2(Screen.width, Screen.height);
                        var viewPortPosition = ((eventData.position / screenSize) + (eventData.position / screenSize)) * 0.5f;
                        var ray = _environment3D.VirtualCamera.ViewportPointToRay(viewPortPosition);
                        _environment3D.TouchPivot.position = _environment3D.ModelHandle.position;
                        if (Physics.Raycast(ray, out RaycastHit hit, Mathf.Infinity, GlobalValue._DefaultLayer) == true)
                        {
                            _environment3D.TouchPivot.position = hit.point;
                            _pressedPivot = hit.point;
                            _pressedPivot.z = _environment3D.ModelHandle.position.z;
                        }
                        else
                        {
                            var distanceToTarget = Vector3.Distance(_environment3D.ModelHandle.position, _environment3D.VirtualCamera.transform.position);
                            var length = distanceToTarget / Vector3.Dot(_environment3D.VirtualCamera.transform.forward, ray.direction);
                            var pos = ray.origin + ray.direction * length;
                            _pressedPivot = pos;
                        }

                        //RectTransformUtility.ScreenPointToLocalPointInRectangle(_rectTransform, _environment3D.VirtualCamera.WorldToScreenSpace(_pressedPivot), _uiCamera, out var anchoredPosition);
                        RectTransformUtility.ScreenPointToLocalPointInRectangle(_rectTransform, eventData.position, _canvas.worldCamera, out var anchoredPosition);
                        _gesturePivot.rectTransform.anchoredPosition = anchoredPosition;
                        _gesturePivot.transform.rotation = Quaternion.identity;
                        _gesturePivot.CrossFadeAlpha(1, 0.1f, true);

                        _inputCollector.Add(eventData.pointerId, eventData);
                    }
                    return;
                case PointerEventData.InputButton.Middle:
                    {
                        UXMode = EPaintBoardUXMode.OneFingerMode; // To DoubleFingerMode
                    }
                    break;
            }

            switch (UXMode)
            {
                case EPaintBoardUXMode.None:
                    {
                        UXMode = EPaintBoardUXMode.OneFingerMode;

                        var screenSize = new Vector2(Screen.width, Screen.height);
                        var viewPortPosition = ((eventData.position / screenSize) + (eventData.position / screenSize)) * 0.5f;
                        var ray = _environment3D.VirtualCamera.ViewportPointToRay(viewPortPosition);
                        _environment3D.TouchPivot.position = _environment3D.ModelHandle.position;
                        if (Physics.Raycast(ray, out RaycastHit hit, Mathf.Infinity, GlobalValue._DefaultLayer) == true)
                            _environment3D.TouchPivot.position = hit.point;

                        if (_mainToolActivation == false && _colorSpoidTriggered == false)
                        {
                            _brushAim.ActivatePressedTimeGuage(Time.unscaledTime, eventData.position);
                        }
                        _inputCollector.Add(eventData.pointerId, eventData);
                    }
                    break;
                case EPaintBoardUXMode.JoystickMode:
                    if (1 <= _inputCollector.Count)
                        return;
                    UXMode = EPaintBoardUXMode.OneFingerMode;

                    _inputCollector.Add(eventData.pointerId, eventData);
                    break;
                case EPaintBoardUXMode.ToolFingerMode:
                    break;
                case EPaintBoardUXMode.OneFingerMode:
                    {
                        UXMode = EPaintBoardUXMode.DoubleFingerMode;
                        _inputCollector.TryAdd(eventData.pointerId, eventData);

                        var touch1 = _inputCollector.First().Value;
                        var touch2 = _inputCollector.Last().Value;

                        var screenSize = new Vector2(Screen.width, Screen.height);
                        var viewPortPosition = ((touch1.position / screenSize) + (touch2.position / screenSize)) * 0.5f;
                        var ray = _environment3D.VirtualCamera.ViewportPointToRay(viewPortPosition);
                        _environment3D.TouchPivot.position = _environment3D.ModelHandle.position;
                        if (Physics.Raycast(ray, out RaycastHit hit, Mathf.Infinity, GlobalValue._DefaultLayer) == true)
                            _environment3D.TouchPivot.position = hit.point;

                        _brushAim.InactivatePressedTimeGuage();
                        EventManager.Notify(EPixelArtEventID.ToggleJoystick, false);

                        var rotation = Quaternion.LookRotation(-_environment3D.VirtualCamera.transform.localPosition.normalized, Vector3.up);
                        _cameraRevolutionEuler = rotation.eulerAngles;
                        if (180 < _cameraRevolutionEuler.x)
                            _cameraRevolutionEuler.x -= 360;
                        _cameraRevolutionOffset = new Vector3(0, 0, -_environment3D.VirtualCamera.transform.localPosition.magnitude);
                        //RotateCameralToRevolutionMode(0.2f);
                    }
                    break;
                case EPaintBoardUXMode.DoubleFingerMode:
                    break;
            }
        }

        public override void OnDrag(PointerEventData eventData)
        {
            if (_inputCollector.ContainsKey(eventData.pointerId) == false)
                return;

            switch (eventData.button)
            {
                case PointerEventData.InputButton.Right:
                    {
                        //UXMode = EPaintBoardUXMode.OneFingerMode;
                        //_inputCollector.Add(eventData.pointerId, eventData);

                        //var screenPosition = RectTransformUtility.WorldToScreenPoint(_canvas.worldCamera, _rectTransform.position);

                        var toTarget = (_environment3D.TouchPivot.position - _environment3D.VirtualCamera.transform.position).normalized;

                        var pivotSS = RectTransformUtility.WorldToScreenPoint(_canvas.worldCamera, _gesturePivot.rectTransform.position);
                        //var pivotSS = _environment3D.VirtualCamera.WorldToScreenSpace(_pressedPivot);
                        var prvTouchPositionSS = eventData.position - eventData.delta;
                        var degree = Vector2.SignedAngle(prvTouchPositionSS - pivotSS, eventData.position - pivotSS);
                        var rotation = Quaternion.AngleAxis(degree, _environment3D.VirtualCamera.transform.forward);

                        var pivot = _environment3D.ModelHandle.position;
                        var vector2 = pivot - _pressedPivot;
                        vector2 = rotation * vector2;
                        pivot = _pressedPivot + vector2;

                        _environment3D.ModelHandle.position = pivot;
                        _environment3D.ModelHandle.rotation = rotation * _environment3D.ModelHandle.rotation;

                        _gesturePivot.transform.rotation = rotation * _gesturePivot.transform.rotation;
                        _reserveCanvasUpdate = true;
                    }
                    return;
            }

            switch (UXMode)
            {
                case EPaintBoardUXMode.None:
                    break;
                case EPaintBoardUXMode.JoystickMode:
                    {
                        _modelRotationDelta += (float2)eventData.delta * ResourceManager.Instance._cameraRotationSensitivity;
                        _brushAim.SetVisibleState(EAimVisibleState.ALL);
                        _brushAim.ResetPosition();
                    }
                    break;
                case EPaintBoardUXMode.ToolFingerMode:
                    {
                        _brushAim.InactivatePressedTimeGuage();
                        _brushAim.AnchoredPosition += (eventData.delta / _canvas.scaleFactor);
                        _reserveCanvasUpdate = true;
                    }
                    break;
                case EPaintBoardUXMode.OneFingerMode:
                    {
                        if (_brushAim.IsTabPaintingValid() == true)
                        {
                            if (ResourceManager.Instance._fingerToolDragThreashold < eventData.delta.magnitude)
                            {
                                _brushAim.InactivatePressedTimeGuage();
                                break;
                            }
                        }

                        _brushAim.SetVisibleState(EAimVisibleState.ALL);
                        _brushAim.ResetPosition();
                        _drawBrushOnCenter = true;
                        _reserveCanvasUpdate = true;

                        var distanceToTarget = Vector3.Distance(_environment3D.VirtualCamera.transform.position, _environment3D.TouchPivot.position);
                        var worldUnit = (distanceToTarget * 2 * Mathf.Tan(_environment3D.VirtualCamera.fieldOfView / 2 * Mathf.Deg2Rad)) / Screen.height;

                        var scale = _environment3D.ModelHandle.localScale.x;

                        var delta = (eventData.delta / _canvas.scaleFactor) * worldUnit * 200;
                        var right = _environment3D.VirtualCamera.transform.right;
                        var forward = _environment3D.VirtualCamera.transform.forward;
                        var up = Vector3.Cross(forward, right);

                        _environment3D.ModelHandle.rotation = Quaternion.AngleAxis(-delta.x, up) * _environment3D.ModelHandle.rotation;
                        _environment3D.ModelHandle.rotation = Quaternion.AngleAxis(delta.y, right) * _environment3D.ModelHandle.rotation;
                    }
                    break;
                case EPaintBoardUXMode.DoubleFingerMode:
                    {
                        _doubleFingerDragGestureFlag = true;
                    }
                    break;
            }
        }

        private bool _doubleFingerDragGestureFlag = false;
        private void UpdateDoubleFingerDragGesture()
        {
            if (_doubleFingerDragGestureFlag == false)
                return;
            _doubleFingerDragGestureFlag = false;

            var touch1 = _inputCollector.First().Value;
            var touch2 = _inputCollector.Last().Value;

            _brushAim.SetVisibleState(EAimVisibleState.ALL);
            _brushAim.ResetPosition();
            _reserveCanvasUpdate = true;

            var prvPed1Pos = touch1.position - (touch1.delta);
            var prvPed2Pos = touch2.position - (touch2.delta);
            var prvVector = prvPed1Pos - prvPed2Pos;
            var curVector = touch1.position - touch2.position;

            var screenSize = new Vector2(Screen.width, Screen.height);
            var viewPortPosition = ((touch1.position / screenSize) + (touch2.position / screenSize)) * 0.5f;
            var ray = _environment3D.VirtualCamera.ViewportPointToRay(viewPortPosition);

            var toTarget = (_environment3D.TouchPivot.position - ray.origin);
            var dotDIstance = Vector3.Dot(ray.direction.normalized, toTarget);
            var point = ray.origin + (ray.direction.normalized * dotDIstance);

            var distanceToTarget = Vector3.Distance(_environment3D.VirtualCamera.transform.position, _environment3D.TouchPivot.position);
            var worldUnit = (distanceToTarget * 2 * Mathf.Tan(_environment3D.VirtualCamera.fieldOfView / 2 * Mathf.Deg2Rad)) / Screen.height;

            var lengthBetweenPositions = (touch1.position - touch2.position).magnitude;
            var prvLengthBetweenPositions = (prvPed1Pos - prvPed2Pos).magnitude;
            var prvMultiTouchCenterPos = (prvPed1Pos + prvPed2Pos) * 0.5f;
            var currMultiTouchCenterPos = (touch1.position + touch2.position) * 0.5f;
            var multiTouchCenterPosDelata = currMultiTouchCenterPos - prvMultiTouchCenterPos;

            //Move
            {
                multiTouchCenterPosDelata *= worldUnit;
                _environment3D.ModelHandle.position += new Vector3(multiTouchCenterPosDelata.x, multiTouchCenterPosDelata.y, 0);
            }

            //Scale
            {
                var originFOV = _environment3D.VirtualCamera.fieldOfView;

                var scale = prvLengthBetweenPositions / lengthBetweenPositions;
                if (prvLengthBetweenPositions * lengthBetweenPositions == 0)
                    scale = 1;

                    _environment3D.VirtualCamera.fieldOfView = math.clamp(_environment3D.VirtualCamera.fieldOfView * scale, 5, 120);
                //_environment3D.VirtualCamera.fieldOfView = math.clamp(_environment3D.VirtualCamera.fieldOfView + (prvLengthBetweenPositions - lengthBetweenPositions) * 0.075f, 5, 120);
                var scaleRatio = _environment3D.VirtualCamera.fieldOfView / originFOV;
            }

            //Rotate
            if (70 < curVector.magnitude)  //Ignore Touches that is too narrow
            {
                var vector = _environment3D.ModelHandle.position;

                var quaternion = Quaternion.AngleAxis(Vector2.SignedAngle(prvVector, curVector), _environment3D.VirtualCamera.transform.forward);
                var vector2 = vector - point;
                vector2 = quaternion * vector2;
                vector = point + vector2;

                _environment3D.ModelHandle.position = vector;
                _environment3D.ModelHandle.rotation = Quaternion.AngleAxis(Vector2.SignedAngle(prvVector, curVector), _environment3D.VirtualCamera.transform.forward) * _environment3D.ModelHandle.rotation;
            }
        }

        public override void OnPointerUp(PointerEventData eventData)
        {
            if (_inputCollector.ContainsKey(eventData.pointerId) == false)
                return;            

            switch (eventData.button)
            {
                case PointerEventData.InputButton.Right:
                    _gesturePivot.CrossFadeAlpha(0, 0.3f, true);
                    break;
                case PointerEventData.InputButton.Middle:
                    {
                        if (UXMode == EPaintBoardUXMode.DoubleFingerMode)
                        {
                            UXMode = EPaintBoardUXMode.OneFingerMode; // To DoubleFingerMode
                            EventManager.Notify(EPixelArtEventID.ToggleJoystick, true);
                        }
                    }
                    break;
            }

            _inputCollector.Remove(eventData.pointerId);
            switch (UXMode)
            {
                case EPaintBoardUXMode.None:
                    break;
                case EPaintBoardUXMode.JoystickMode:
                    break;
                case EPaintBoardUXMode.ToolFingerMode:
                    UXMode = EPaintBoardUXMode.None;
                    _brushAim.InactivatePressedTimeGuage();
                    _brushAim.SetVisibleState(EAimVisibleState.None);
                    _drawBrushOnCenter = false;
                    EventManager.Notify(EPixelArtEventID.ExecutePaintAction, EBitPaintActionTrigger.Press);
                    EventManager.Notify(EPixelArtEventID.ToggleJoystick, true);
                    EventManager.Notify(EPixelArtEventID.TriggerMainTool, false);
                    break;
                case EPaintBoardUXMode.OneFingerMode:
                    {
                        if (_joystickPressed == true)
                            UXMode = EPaintBoardUXMode.JoystickMode;
                        else
                            UXMode = EPaintBoardUXMode.None;

                        if (_brushAim.IsTabPaintingValid() == true)
                        {
                            RectTransformUtility.ScreenPointToLocalPointInRectangle(_rectTransform, eventData.position, _uiCamera, out var position);
                            _brushAim.AnchoredPosition = position;

                            _reserveCanvasUpdate = true;
                            EventManager.Notify(EPixelArtEventID.ExecutePaintAction, EBitPaintActionTrigger.ALL);

                            _brushAim.InactivatePressedTimeGuage();
                            _brushAim.SetVisibleState(EAimVisibleState.None);
                            _reserveCanvasUpdate = true;
                        }
                    }
                    break;
                case EPaintBoardUXMode.DoubleFingerMode:
                    UXMode = EPaintBoardUXMode.OneFingerMode;

                    if (100 < _environment3D.VirtualCamera.fieldOfView)
                        _environment3D.RotateModelToIdle(0.2f, EIdleTransformType.PintchDefault);

                    EventManager.Notify(EPixelArtEventID.ToggleJoystick, true);
                    break;
            }
        }

        public override void OnScroll(PointerEventData eventData)
        {
            eventData.scrollDelta = eventData.scrollDelta.normalized;
            _environment3D.VirtualCamera.fieldOfView = math.clamp(_environment3D.VirtualCamera.fieldOfView - eventData.scrollDelta.y * _scrollMultiplier, 5, 120);

            if (100 < _environment3D.VirtualCamera.fieldOfView)
                _environment3D.RotateModelToIdle(0.2f, EIdleTransformType.PintchDefault);

            //var screenSize = new Vector2(Screen.width, Screen.height);
            //var viewPortPosition = ((eventData.position / screenSize) + (eventData.position / screenSize)) * 0.5f;
            //var ray = _environment3D.VirtualCamera.ViewportPointToRay(viewPortPosition);
            //_environment3D.TouchPivot.position = _environment3D.ModelHandle.position;
            //if (Physics.Raycast(ray, out RaycastHit hit, Mathf.Infinity, GlobalValue._DefaultLayer) == true)
            //    _environment3D.TouchPivot.position = hit.point;

            //var prvPosition = _environment3D.TouchPivot.transform.position;
            //var originScale = _environment3D.ModelHandle.localScale;
            //_environment3D.ModelHandle.localScale += Vector3.one * eventData.scrollDelta.y * _scrollMultiplier;
            //var delta = _environment3D.TouchPivot.position - prvPosition;
            //_environment3D.ModelHandle.position -= delta;
        }

        public async void RotateCameralToRevolutionMode(float maxTime)
        {
            var begTime = Time.time;

            while (true)
            {
                var currRotation = _environment3D.VirtualCamera.transform.rotation;
                var currPosition = _environment3D.VirtualCamera.transform.localPosition;

                var rotation = Quaternion.Euler(_cameraRevolutionEuler);
                var elapsedTime = Time.time - begTime;
                var ratio = Mathf.InverseLerp(0, maxTime, elapsedTime);
                ratio = Mathf.Clamp01(ratio);
                _environment3D.VirtualCamera.transform.rotation = Quaternion.Lerp(currRotation, rotation, ratio);
                _environment3D.VirtualCamera.transform.localPosition = Vector3.Lerp(currPosition, rotation * _cameraRevolutionOffset, ratio);
                _reserveCanvasUpdate = true;
                if (ratio == 1)
                    return;

                await UniTask.Yield();
            }
        }

        internal void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnOpenCanvas:
                    {
                    }
                    break;
                case EPixelArtEventID.OnScreenSizeChanged:
                    {
                        var screenSize = (Vector2Int)datas[0];

                        if (_backBuffer != _environment3D.VirtualCamera.ColorBuffer && _environment3D.VirtualCamera.ColorBuffer != null)
                            GameObject.Destroy(_environment3D.VirtualCamera.ColorBuffer);

                        var renderTexture = new RenderTexture(screenSize.x, screenSize.y, GraphicsFormat.R8G8B8A8_SRGB, GraphicsFormat.D24_UNorm_S8_UInt);
                        renderTexture.name = "PaintBoard3D";
                        _environment3D.VirtualCamera.ColorBuffer = renderTexture;
                        _mergedImage.texture = renderTexture;
                    }
                    break;
                case EPixelArtEventID.OnPaintBoardTypeChanged:
                    {
                        var paintBoardType = (EPaintBoardType)datas[0];

                        switch (paintBoardType)
                        {
                            case EPaintBoardType.PaintBoard2D:
                                gameObject.SetActive(false);
                                _environment3D.VirtualCamera.enabled = false;
                                break;
                            case EPaintBoardType.PaintBoard3D:
                                Graphics.Blit(Texture2D.blackTexture, ResourceManager.Instance.DrawingLayerTarget);

                                gameObject.SetActive(true);
                                _brushAim.Initialize(this);
                                _environment3D.VirtualCamera.enabled = true;
                                _reserveCanvasUpdate = true;
                                break;
                        }

                        _brushAim.SetVisibleState(EAimVisibleState.None);
                        _brushAim.ResetPosition();
                    }
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
                    }
                    break;
                case EPixelArtEventID.ReserveCanvasUpdate:
                    {
                        _reserveCanvasUpdate = true;
                    }
                    break;
                case EPixelArtEventID.ResetAimPosition:
                    {
                        _brushAim.ResetPosition();
                        _drawBrushOnCenter = true;
                        _reserveCanvasUpdate = true;
                    }
                    break;
                case EPixelArtEventID.OnPartitionChanged:
                    {
                        var partition = datas[0] as Partition;
                        _partition = partition;
                    }
                    break;
                case EPixelArtEventID.OnLockPartition:
                    {
                        _reserveCanvasUpdate = true;
                    }
                    break;
                case EPixelArtEventID.OnUndoRedo:
                    {
                        _brushAim.SetVisibleState(EAimVisibleState.None);
                        _drawBrushOnCenter = false;
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
                                    _brushAim.SetVisibleState(EAimVisibleState.ALL);
                                    Graphics.Blit(Texture2D.blackTexture, ResourceManager.Instance.DrawingLayerTarget);
                                    RaycastPixel(_brushAim.AimPosition, ref _prvRayCastHit);
                                    _reserveCanvasUpdate = true;
                                }

                                if (bitTrigger == EBitPaintActionTrigger.ALL)
                                {
                                    ExecutePaintingSequence();
                                }

                                if (bitTrigger.Contains(EBitPaintActionTrigger.Release) == true)
                                {
                                    _mainToolActivation = false;
                                    _brushAim.SetVisibleState(EAimVisibleState.None);
                                    EventManager.Notify(EPixelArtEventID.ToggleJoystick, true);
                                    EventManager.Notify(EPixelArtEventID.AddTaskCommand, new BrushCommand(ECanvasType.Albedo));
                                }
                                break;
                            case EToolType.Spoid:
                                if (bitTrigger.Contains(EBitPaintActionTrigger.Press) == true)
                                    EventManager.Notify(EPixelArtEventID.OnColorSpoidTriggered, true);

                                if (bitTrigger == EBitPaintActionTrigger.ALL)
                                {
                                    ExecuteColorSpoid();
                                }

                                if (bitTrigger.Contains(EBitPaintActionTrigger.Release) == true)
                                    EventManager.Notify(EPixelArtEventID.OnColorSpoidTriggered, false);
                                break;
                            case EToolType.PaintCan:
                                if (bitTrigger.Contains(EBitPaintActionTrigger.Press) == true)
                                {
                                    _mainToolActivation = true;
                                }

                                if (bitTrigger.Contains(EBitPaintActionTrigger.Release) == true)
                                {
                                    _mainToolActivation = false;
                                    RaycastPixel(_brushAim.AimPosition, ref _prvRayCastHit);

                                    var textureSize = new Vector2(_seedData._textureWidth, _seedData._textureHeight);
                                    var nUV = _prvRayCastHit.textureCoord * textureSize;

                                    var partitionBeg = _partition._normPartition.min * textureSize;
                                    var partitionSize = _partition._normPartition.size * textureSize;
                                    var partition = new RectInt((int)partitionBeg.x, (int)partitionBeg.y, (int)partitionSize.x, (int)partitionSize.y);

                                    _reserveCanvasUpdate = true;

                                    var taskCommand = new PaintCommand(ECanvasType.Albedo, new int2((int)nUV.x, (int)nUV.y), partition, _colorPallete.Color, ToolGroup.ToolSettings.PaintColorThreasholdSlider, ToolGroup.BrushXMirrortoggle);
                                    EventManager.Notify(EPixelArtEventID.AddTaskCommand, taskCommand);
                                }
                                break;
                        }
                    }
                    break;
                case EPixelArtEventID.OnActionButtonDragged:
                    {
                        var draggedDelta = (Vector2)datas[0];

                        var fovRatio = Mathf.InverseLerp(3, 60, _environment3D.VirtualCamera.fieldOfView);
                        var sensitivity = Mathf.Lerp(0.1f, 1, fovRatio);
                        _modelRotationDelta += (float2)draggedDelta * sensitivity;
                    }
                    break;
                case EPixelArtEventID.SwapMovingMode:
                    {
                        var joystickPressed = (bool)datas[0];

                        _joystickPressed = joystickPressed;
                        switch (UXMode)
                        {
                            case EPaintBoardUXMode.None:
                                if (joystickPressed == true)
                                {
                                    UXMode = EPaintBoardUXMode.JoystickMode;
                                }
                                else
                                {

                                }
                                break;
                            case EPaintBoardUXMode.OneFingerMode:
                                if (joystickPressed == true)
                                {

                                }
                                else
                                {

                                }
                                break;
                            case EPaintBoardUXMode.JoystickMode:
                                if (joystickPressed == true)
                                {

                                }
                                else
                                {
                                    UXMode = EPaintBoardUXMode.None;
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
                        {
                            //_drawBrushOnCenter = true;
                            _brushAim.SetVisibleState(EAimVisibleState.ALL);
                            _reserveCanvasUpdate = true;
                        }
                        else
                        {
                            _brushAim.SetVisibleState(EAimVisibleState.ALL);
                            //_drawBrushOnCenter = false;
                            _reserveCanvasUpdate = true;
                        }
                    }
                    break;
                case EPixelArtEventID.OnColorChanged:
                    {
                        _brushAim.SetVisibleState(EAimVisibleState.ALL);
                    }
                    break;
            }
        }
    }
}



//public void OnRotaterDown(BaseEventData eventData)
//{
//    _rotaterDragged = false;
//    _rotaterImage.CrossFadeAlpha(1, 0.2f, true);
//}

//public void OnRotaterDrag(BaseEventData eventData)
//{
//    var ped = eventData as PointerEventData;
//    _rotaterDragged = true;
//    _reserveCanvasUpdate = true;

//    var tempDelta = ped.delta.normalized;
//    var angle = Vector2.SignedAngle(Vector2.up, tempDelta);
//    //var angleSign = Mathf.Sign(angle);
//    //angle = Mathf.Abs(angle);
//    //angle += 45;
//    //angle = (int)(angle / 90) * 90;
//    //angle *= angleSign;
//    var rotaterDirection = Quaternion.Euler(0, 0, angle) * Vector2.up;

//    var delta = (ped.delta / 2 / _canvas.scaleFactor);
//    var dot = Vector2.Dot(rotaterDirection, delta);
//    delta = rotaterDirection * dot;
//    EventManager.Notify(EPixelArtEventID.OnOneFingerDragged, delta);
//}

//public void OnRotaterUp(BaseEventData eventData)
//{
//    if (_rotaterDragged == false)
//        EventManager.Notify(EPixelArtEventID.RotateToIdle_Paintboard3D);

//    _rotaterDragged = false;
//    _rotaterImage.CrossFadeAlpha(0.3f, 0.5f, true);
//}
