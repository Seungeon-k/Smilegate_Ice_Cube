using System;

using TMPro;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace PixelCanvas
{
    public enum EToolType
    {
        Brush,
        PaintCan,
        Spoid,
        Eraser,
        Marquee,
    }

    public enum EBrushPass
    {
        Indicator_Brush,
        Indicator_Brush_Continuous,
        Indicator_Eraser,
        Indicator_Eraser_Continuous,
        Brush,
        Brush_Continuous,
        Eraser,
        Eraser_Continuous,
    }

    public class ToolGroup : MonoBehaviour
    {
        [SerializeField] private Button _selectColorButton;
        [SerializeField] private Button _undoButton;
        [SerializeField] private Button _redoButton;

        [SerializeField] private TMP_Text _nCoordText;

        public static bool BrushXMirrortoggle => _brushXMirrorActivated;
        private static bool _brushXMirrorActivated;
        [SerializeField] private Toggle _brushXMirrortoggle;

        [SerializeField] private Selectable[] _interactableGroup;
        [SerializeField] private EventTrigger[] _tirggerEventGroup;

        [Header("Range Indicator")]
        [SerializeField] private Material _brushRangeBakerMaterial;
        [SerializeField] private RenderTexture _brushIndicatorTexture;

        public EToolType ToolType => _toolSettings.ToolType;

        public static MainTools ToolSettings => _staticToolSettings;
        private static MainTools _staticToolSettings;
        [SerializeField] private MainTools _toolSettings;

        private bool _undoActive;
        private bool _redoActive;

        private void Awake()
        {
            _staticToolSettings = _toolSettings;
            _brushXMirrorActivated = false;

            _selectColorButton.onClick.AddListener(() =>
            {
                EventManager.Notify(EPixelArtEventID.ToggleColorPickerWindow);
            });

            _undoButton.onClick.AddListener(() =>
            {
                EventManager.Notify(EPixelArtEventID.UndoRedo, ERedoUndo.Undo);
            });

            _redoButton.onClick.AddListener(() =>
            {
                EventManager.Notify(EPixelArtEventID.UndoRedo, ERedoUndo.Redo);
            });

            _brushXMirrortoggle.onValueChanged.AddListener((value) =>
            {
                _brushXMirrorActivated = value;
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });
        }

        private void OnEnable()
        {
            EventManager.Register(EPixelArtEventID.OnTaskCommandModified, NotifyEvent);
            EventManager.Register(EPixelArtEventID.TriggerMainTool, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ToggleInteraction, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangeTool, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnColorChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnPaintBoardTypeChanged, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnMarqueeCopy, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangeSelectedUV, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnChangeBrushSetting, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnPainboardTouch, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.OnTaskCommandModified, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.TriggerMainTool, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ToggleInteraction, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangeTool, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnColorChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnPaintBoardTypeChanged, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnMarqueeCopy, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangeSelectedUV, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnChangeBrushSetting, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnPainboardTouch, NotifyEvent);
        }

        internal void Update()
        {
            if (Input.GetKeyDown(KeyCode.X) == true)
                _brushXMirrortoggle.isOn = !_brushXMirrortoggle.isOn;

            _toolSettings.Update();
        }

        internal void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnTaskCommandModified:
                    {
                        var commandCount = (int)datas[0];
                        var redoCommandCount = (int)datas[1];

                        _undoActive = 0 < commandCount;
                        _redoActive = 0 < redoCommandCount;
                        _undoButton.interactable = _undoActive;
                        _redoButton.interactable = _redoActive;
                    }
                    break;
                case EPixelArtEventID.ToggleInteraction:
                    {
                        var toggle = (bool)datas[0];
                        toggle = !toggle;

                        var activatedSelectable = datas[1] as Selectable;
                        if (activatedSelectable == null)
                            return;

                        foreach (var element in _interactableGroup)
                        {
                            if (element == null)
                                continue;

                            // Special Conditions
                            if (element.gameObject == activatedSelectable.gameObject)
                                continue;
                            else if (element == _undoButton)
                            {
                                element.interactable = _undoActive && toggle;
                            }
                            else if (element == _redoButton)
                            {
                                element.interactable = _redoActive && toggle;
                            }
                            else
                                element.interactable = toggle;
                        }

                        foreach (var trigger in _tirggerEventGroup)
                        {
                            if (trigger == null)
                                continue;
                            if (activatedSelectable.gameObject == trigger.gameObject)
                                continue;

                            trigger.enabled = toggle;
                        }
                    }
                    break;
                case EPixelArtEventID.OnTriggerMainTool:
                    {
                        var toggle = (bool)datas[0];

                        toggle = !toggle;

                        foreach (var element in _interactableGroup)
                        {
                            if (element == null)
                                continue;
                            element.interactable = toggle;
                        }
                    }
                    break;
                case EPixelArtEventID.ChangeSelectedUV:
                    {
                        var nUV = (int2)datas[0];
                        _nCoordText.text = $"({nUV.x}, {nUV.y})";
                    }
                    break;
                case EPixelArtEventID.OnColorChanged:
                    {
                        //var color = (Color)datas[0];
                        var pass = 0;
                        switch (_toolSettings.ToolType)
                        {
                            case EToolType.Brush:
                                pass = 0;
                                Graphics.Blit(null, _brushIndicatorTexture, _brushRangeBakerMaterial, pass);
                                break;
                            case EToolType.Eraser:
                                pass = 1;
                                Graphics.Blit(null, _brushIndicatorTexture, _brushRangeBakerMaterial, pass);
                                break;
                        }
                    }
                    break;
                case EPixelArtEventID.OnChangeBrushSetting:
                    {
                        var strokeThickness = (float)datas[0];
                        var strokeSoftness = (float)datas[1];
                        var strokeFlow = (float)datas[2];

                        var pass = 0;
                        switch (_toolSettings.ToolType)
                        {
                            case EToolType.Brush:
                                pass = 0;

                                Shader.SetGlobalVector(GlobalValue._BrushStyle, new float4(strokeThickness, strokeSoftness, strokeFlow, 1));
                                Graphics.Blit(null, _brushIndicatorTexture, _brushRangeBakerMaterial, pass);
                                break;
                            case EToolType.Eraser:
                                pass = 1;

                                Shader.SetGlobalVector(GlobalValue._BrushStyle, new float4(strokeThickness, strokeSoftness, strokeFlow, 1));
                                Graphics.Blit(null, _brushIndicatorTexture, _brushRangeBakerMaterial, pass);
                                break;
                        }
                    }
                    break;
            }

            _toolSettings.NotifyEvent(id, datas);
        }
    }

    [Serializable]
    public class IconButton
    {
        public Button Button => _button;
        [SerializeField] private Button _button;

        public Image Icon => _icon;
        [SerializeField] private Image _icon;

        public GameObject Select => _select;
        [SerializeField] private GameObject _select;

        public GameObject Settings => _settings;
        [SerializeField] private GameObject _settings;
    }

    [Serializable]
    public class MainTools
    {
        public IconButton MainTool => _mainTools[(int)_toolType];
        [SerializeField] private IconButton[] _mainTools;
        [SerializeField] private EToolType[] _2DModeMainActionTools;
        [SerializeField] private EToolType[] _3DModeMainActionTools;

        [Header("Brush")]
        [SerializeField] private Slider _brushThicknessSlider;
        public float BrushThicknessSlider => _brushThicknessSlider.value;
        public float BrushSoftnessSlider => _brushSoftnessSlider.value;
        [SerializeField] private Slider _brushSoftnessSlider;
        public float BrushFlowSlider => _brushFlowSlider.value;
        [SerializeField] private Slider _brushFlowSlider;

        [Header("Paint")]
        [SerializeField] private Slider _paintColorThreasholdSlider;
        public float PaintColorThreasholdSlider => _paintColorThreasholdSlider.value;

        [Header("Eraser")]
        [SerializeField] private Slider _eraserThicknessSlider;
        public float EraserThicknessSlider => _eraserThicknessSlider.value;
        public float EraserSoftnessSlider => _eraserSoftnessSlider.value;
        [SerializeField] private Slider _eraserSoftnessSlider;
        public float EraserFlowSlider => _eraserFlowSlider.value;
        [SerializeField] private Slider _eraserFlowSlider;
        [SerializeField] private Button _initializeButton;

        [Header("Marquee")]
        [SerializeField] private Button _marqueePasteButton;

        [SerializeField] private MaskableGraphic[] _rangeIndicator;

        public EToolType ToolType => _toolType;
        private EToolType _toolType;

        private EPaintBoardType _paintBoardType;

        public void Initialize()
        {
            for (var i = 0; i < _mainTools.Length; ++i)
            {
                var idx = i;    //Lambda Capture Issue
                _mainTools[i].Button.onClick.AddListener(() =>
                {
                    EventManager.Notify(EPixelArtEventID.ChangeTool, (EToolType)idx);
                });
            }

            var brushThicknessText = _brushThicknessSlider.GetComponentInChildren<TMP_Text>();
            _brushThicknessSlider.onValueChanged.AddListener((value) =>
            {
                //value = ((int)(value * 10) / 10f);
                brushThicknessText.text = $"{value:0.0}";
                EventManager.Notify(EPixelArtEventID.OnChangeBrushSetting, value, _brushSoftnessSlider.value, _brushFlowSlider.value);
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });
            _brushThicknessSlider.value = 1;

            _brushThicknessSlider.minValue = ResourceManager.Instance._brushMinMaxSize.x;
            _brushThicknessSlider.maxValue = ResourceManager.Instance._brushMinMaxSize.y;

            var brushSolidityText = _brushSoftnessSlider.GetComponentInChildren<TMP_Text>();
            _brushSoftnessSlider.onValueChanged.AddListener((value) =>
            {
                //value = ((int)(value * 10) / 10f);
                brushSolidityText.text = $"{value:0.0}";
                EventManager.Notify(EPixelArtEventID.OnChangeBrushSetting, _brushThicknessSlider.value, value, _brushFlowSlider.value);
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });
            _brushSoftnessSlider.value = 0;
            _brushSoftnessSlider.minValue = ResourceManager.Instance._brushSoftnessMinMax.x;
            _brushSoftnessSlider.maxValue = ResourceManager.Instance._brushSoftnessMinMax.y;

            var brushFlowText = _brushFlowSlider.GetComponentInChildren<TMP_Text>();
            _brushFlowSlider.onValueChanged.AddListener((value) =>
            {
                brushFlowText.text = $"{value:0.0}";
                EventManager.Notify(EPixelArtEventID.OnChangeBrushSetting, _brushThicknessSlider.value, BrushSoftnessSlider, value);
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });
            _brushFlowSlider.value = 1;
            _brushFlowSlider.minValue = ResourceManager.Instance._brushMinMaxFlow.x;
            _brushFlowSlider.maxValue = ResourceManager.Instance._brushMinMaxFlow.y;

            var paintColorThreasholdText = _paintColorThreasholdSlider.GetComponentInChildren<TMP_Text>();
            _paintColorThreasholdSlider.onValueChanged.AddListener((value) => { paintColorThreasholdText.text = $"{value:0.00}"; });
            _paintColorThreasholdSlider.value = 0;
            _paintColorThreasholdSlider.minValue = ResourceManager.Instance._paintMinMaxThreshold.x;
            _paintColorThreasholdSlider.maxValue = ResourceManager.Instance._paintMinMaxThreshold.y;

            var eraserThicknessText = _eraserThicknessSlider.GetComponentInChildren<TMP_Text>();
            _eraserThicknessSlider.onValueChanged.AddListener((value) =>
            {
                eraserThicknessText.text = $"{value:0.0}";
                EventManager.Notify(EPixelArtEventID.OnChangeBrushSetting, value, EraserSoftnessSlider, _eraserFlowSlider.value);
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });
            _eraserThicknessSlider.value = 1;
            _eraserThicknessSlider.minValue = ResourceManager.Instance._brushMinMaxSize.x;
            _eraserThicknessSlider.maxValue = ResourceManager.Instance._brushMinMaxSize.y;

            _initializeButton.onClick.AddListener(() =>
            {
                EventManager.Notify(EPixelArtEventID.RevertSeedData);
            });

            var eraserSoftnessText = _eraserSoftnessSlider.GetComponentInChildren<TMP_Text>();
            _eraserSoftnessSlider.onValueChanged.AddListener((value) =>
            {
                eraserSoftnessText.text = $"{value:0.0}";
                EventManager.Notify(EPixelArtEventID.OnChangeBrushSetting, _eraserThicknessSlider.value, value, _eraserFlowSlider.value);
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });
            _eraserSoftnessSlider.value = 0;
            _eraserSoftnessSlider.minValue = ResourceManager.Instance._brushSoftnessMinMax.x;
            _eraserSoftnessSlider.maxValue = ResourceManager.Instance._brushSoftnessMinMax.y;

            var eraserFlowText = _eraserFlowSlider.GetComponentInChildren<TMP_Text>();
            _eraserFlowSlider.onValueChanged.AddListener((value) =>
            {
                eraserFlowText.text = $"{value:0.0}";
                EventManager.Notify(EPixelArtEventID.OnChangeBrushSetting, _eraserThicknessSlider.value, _eraserSoftnessSlider.value, value);
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });
            _eraserFlowSlider.value = 1;
            _eraserFlowSlider.minValue = ResourceManager.Instance._brushMinMaxFlow.x;
            _eraserFlowSlider.maxValue = ResourceManager.Instance._brushMinMaxFlow.y;

            _marqueePasteButton.interactable = false;
            _marqueePasteButton.onClick.AddListener(() =>
            {
                EventManager.Notify(EPixelArtEventID.MarqueePaste);
            });
        }

        public void OnPressed()
        {
            if (GlobalValue.ExecuteAction == true)
                return;
            GlobalValue.ExecuteAction = true;

            EventManager.Notify(EPixelArtEventID.ToggleInteraction, true, MainTool.Button);
            EventManager.Notify(EPixelArtEventID.ExecutePaintAction, EBitPaintActionTrigger.Press);
        }

        public void OnDragged(BaseEventData baseEvent)
        {
            if (GlobalValue.ExecuteAction == false)
                return;

            var ped = baseEvent as PointerEventData;
            EventManager.Notify(EPixelArtEventID.OnActionButtonDragged, ped.delta);
        }

        public void OnReleased()
        {
            if (GlobalValue.ExecuteAction == false)
                return;
            GlobalValue.ExecuteAction = false;

            EventManager.Notify(EPixelArtEventID.ToggleInteraction, false, MainTool.Button);
            EventManager.Notify(EPixelArtEventID.ExecutePaintAction, EBitPaintActionTrigger.Release);
        }

        internal void Update()
        {
            //if (Input.GetKeyDown(KeyCode.Space) == true)
            //{
            //    EventManager.Notify(EPixelArtEventID.ResetAimPosition); //PaintBoard3D Event
            //    OnPressed();
            //}
            //if (Input.GetKeyUp(KeyCode.Space) == true)
            //    OnReleased();

            if (GlobalValue.ExecuteAction == false)
            {
                if (Input.GetKey(KeyCode.LeftControl) == true)
                {
                    if (Input.GetKeyDown(KeyCode.Z) == true)
                    {
                        if (Input.GetKey(KeyCode.LeftShift) == false)
                            EventManager.Notify(EPixelArtEventID.UndoRedo, ERedoUndo.Undo);
                        else
                            EventManager.Notify(EPixelArtEventID.UndoRedo, ERedoUndo.Redo);
                    }
                }

                //if (Input.GetKeyDown(KeyCode.Alpha1) == true)
                //    EventManager.Notify(EPixelArtEventID.ChangeTool, EToolType.Brush);
                //if (Input.GetKeyDown(KeyCode.Alpha2) == true)
                //    EventManager.Notify(EPixelArtEventID.ChangeTool, EToolType.PaintCan);
                //if (Input.GetKeyDown(KeyCode.Alpha3) == true)
                //    EventManager.Notify(EPixelArtEventID.ChangeTool, EToolType.Spoid);
                //if (Input.GetKeyDown(KeyCode.Alpha4) == true)
                //    EventManager.Notify(EPixelArtEventID.ChangeTool, EToolType.Eraser);
                //if (Input.GetKeyDown(KeyCode.Alpha5) == true)
                //    EventManager.Notify(EPixelArtEventID.ChangeTool, EToolType.Marquee);
            }

            if (Input.GetKeyDown(KeyCode.LeftBracket) == true)
            {
                switch (_toolType)
                {
                    case EToolType.Brush:
                        _brushThicknessSlider.value -= 1;
                        break;
                    case EToolType.Eraser:
                        _eraserThicknessSlider.value -= 1;
                        break;
                }
            }
            if (Input.GetKeyDown(KeyCode.RightBracket) == true)
            {
                switch (_toolType)
                {
                    case EToolType.Brush:
                        _brushThicknessSlider.value += 1;
                        break;
                    case EToolType.Eraser:
                        _eraserThicknessSlider.value += 1;
                        break;
                }
            }
        }

        internal void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.TriggerMainTool:
                    {
                        var trigger = (bool)datas[0];
                        if (trigger == true)
                            OnPressed();
                        else
                            OnReleased();

                        EventManager.Notify(EPixelArtEventID.OnTriggerMainTool, datas);
                    }
                    break;
                case EPixelArtEventID.ChangeTool:
                    {
                        var toolType = (EToolType)datas[0];

                        var mainActionTools = default(EToolType[]);
                        switch (_paintBoardType)
                        {
                            case EPaintBoardType.PaintBoard2D:
                                mainActionTools = _2DModeMainActionTools;
                                break;
                            case EPaintBoardType.PaintBoard3D:
                                mainActionTools = _3DModeMainActionTools;
                                break;
                        }

                        foreach (var toolSettings in _mainTools)
                        {
                            if (toolSettings.Select != null)
                                toolSettings.Select.SetActive(false);
                            if (toolSettings.Settings != null)
                                toolSettings.Settings.SetActive(false);
                        }
                        if (_mainTools[(int)toolType].Select != null)
                            _mainTools[(int)toolType].Select.SetActive(true);
                        if (_mainTools[(int)toolType].Settings != null)
                            _mainTools[(int)toolType].Settings.SetActive(true);

                        switch (_toolType)
                        {
                            case EToolType.Brush:
                                break;
                            case EToolType.PaintCan:
                                break;
                            case EToolType.Eraser:
                                break;
                            case EToolType.Marquee:
                                EventManager.Notify(EPixelArtEventID.LockPartition, false, true);
                                break;
                        }

                        switch (toolType)
                        {
                            case EToolType.Brush:
                                EventManager.Notify(EPixelArtEventID.OnChangeBrushSetting, _brushThicknessSlider.value, _brushSoftnessSlider.value, _brushFlowSlider.value);
                                break;
                            case EToolType.PaintCan:
                                EventManager.Notify(EPixelArtEventID.OnChangeBrushSetting, 1f, 1f, 1f);
                                break;
                            case EToolType.Eraser:
                                EventManager.Notify(EPixelArtEventID.OnChangeBrushSetting, _eraserThicknessSlider.value, _eraserSoftnessSlider.value, _eraserFlowSlider.value);
                                break;
                            case EToolType.Marquee:
                                EventManager.Notify(EPixelArtEventID.ChangePartitionByIndex, 0);
                                EventManager.Notify(EPixelArtEventID.LockPartition, true, true);
                                break;
                        }
                        _toolType = toolType;

                        EventManager.Notify(EPixelArtEventID.OnToolChanged, toolType);
                        EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
                    }

                    break;
                case EPixelArtEventID.OnColorChanged:
                    {
                        var color = (Color)datas[0];

                        foreach (var toolSettings in _mainTools)
                        {
                            if (toolSettings.Icon != null)
                                toolSettings.Icon.color = color;
                        }
                    }
                    break;
                case EPixelArtEventID.OnPaintBoardTypeChanged:
                    {
                        var patinBoardType = (EPaintBoardType)datas[0];
                        _paintBoardType = patinBoardType;

                        switch (patinBoardType)
                        {
                            case EPaintBoardType.PaintBoard2D:
                                {
                                    _mainTools[(int)EToolType.Marquee].Button.interactable = true;
                                    var seletables = _mainTools[(int)EToolType.Marquee].Settings.GetComponentsInChildren<Selectable>();
                                    foreach (var selectable in seletables)
                                        selectable.interactable = true;
                                }
                                break;
                            case EPaintBoardType.PaintBoard3D:
                                {
                                    _mainTools[(int)EToolType.Marquee].Button.interactable = false;
                                    var seletables = _mainTools[(int)EToolType.Marquee].Settings.GetComponentsInChildren<Selectable>();
                                    foreach (var selectable in seletables)
                                        selectable.interactable = false;

                                    if (_toolType == EToolType.Marquee)
                                    {
                                        EventManager.Notify(EPixelArtEventID.ChangeTool, EToolType.Brush);
                                    }
                                }
                                break;
                        }
                    }
                    break;
                case EPixelArtEventID.OnMarqueeCopy:
                    {
                        var copiedTexture = datas[0] as Texture2D;

                        _marqueePasteButton.interactable = (copiedTexture != null) ? true : false;
                    }
                    break;
                case EPixelArtEventID.OnPainboardTouch:
                    {
                        foreach (var toolSettings in _mainTools)
                        {
                            if (toolSettings.Settings != null)
                                toolSettings.Settings.SetActive(false);
                        }
                    }
                    break;
            }
        }
    }
}