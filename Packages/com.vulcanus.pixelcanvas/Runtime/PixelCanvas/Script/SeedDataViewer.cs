using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;
using System;
using System.IO;
using Unity.Mathematics;
using Cysharp.Threading.Tasks;
using System.Linq;

namespace PixelCanvas
{
    public class SeedDataViewer : MonoBehaviour
    {
        [SerializeField] private RawImage _seedTexture;
        [SerializeField] private TMP_InputField _nameField;
        [SerializeField] private UIDropdown _upscaleTypeDropDown;
        [SerializeField] private UIDropdown _filterTypeDropDown;
        [SerializeField] private Slider _scaleSlider;

        [SerializeField] private Button _closeButton;

        private RectTransform _rectTransform;
        private SeedData _seedData;

        private Dictionary<EUpscaleType, string> _upscaleTypeToLanguageKey = new Dictionary<EUpscaleType, string>
        {
            {EUpscaleType.None, "ID_Text_4083"},
            {EUpscaleType.Xbrz, "ID_Text_4084"},
        };

        private Dictionary<EFilterMode, string> _filterTypeToLanguageKey = new Dictionary<EFilterMode, string>
        {
            {EFilterMode.Point, "ID_Text_4087"},
            {EFilterMode.Bilinear, "ID_Text_4088"},
        };

        private const int _nameMaxLength = 50;

        public void Awake()
        {
            _rectTransform = GetComponent<RectTransform>();

            _closeButton.onClick.AddListener(() => 
            {
                var animator = gameObject.GetComponentInChildren<Animator>();
                animator.Play("Popup_Close");
            });

            _nameField.onValueChanged.AddListener((value) => 
            {
                value = value.Substring(0, math.min(value.Length, _nameMaxLength));
                _nameField.SetTextWithoutNotify(value);
            });

            _nameField.onEndEdit.AddListener((value)=> 
            {
                if (value.Length == 0)
                {
                    _nameField.SetTextWithoutNotify(_seedData._name);
                    return;
                }

                value = value.Substring(0, math.min(value.Length, _nameMaxLength));
                if (_seedData._name == value)
                    return;
                _seedData._name = value;

                //var newPath = Path.Combine(GlobalValue._localSeedDataPath_Pet, $"{_seedData._name}_{_seedData._guid}{GlobalValue._jsonExtension}");
                //PixelCanvasStorageManager.Instance.MoveSeedData(_seedData._storagePath, newPath, _seedData);
                _nameField.SetTextWithoutNotify(value);
            });

            var scaleTypeTexts = _upscaleTypeToLanguageKey.Values.Select((str) => 
            {
                if (TextTable.TryGetTextDataString(str, out var text) == true)
                    return text;
                return str; 
            }).ToList();
            _upscaleTypeDropDown.ClearOptions();
            _upscaleTypeDropDown.AddOptions(scaleTypeTexts);
            _upscaleTypeDropDown.onValueChanged.AddListener((idx) =>
            {
                _seedData._upscaleType = (EUpscaleType)idx;
                EventManager.Notify(EPixelArtEventID.OnCanvasModified);
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });

            var filterTypeTexts = _filterTypeToLanguageKey.Values.Select((str) =>
            {
                if (TextTable.TryGetTextDataString(str, out var text) == true)
                    return text;
                return str;
            }).ToList();
            _filterTypeDropDown.ClearOptions();
            _filterTypeDropDown.AddOptions(filterTypeTexts);
            _filterTypeDropDown.onValueChanged.AddListener((idx) =>
            {
                _seedData._filterMode = (EFilterMode)idx;
                EventManager.Notify(EPixelArtEventID.ChangeFilterMode, _seedData);
                EventManager.Notify(EPixelArtEventID.OnCanvasModified);
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });

            _scaleSlider.onValueChanged.AddListener((value) =>
            {
                _seedData._scale = (byte)value;
                EventManager.Notify(EPixelArtEventID.ChangeUpscaleMultiplier, _seedData);
                EventManager.Notify(EPixelArtEventID.OnCanvasModified);
                EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            });

            EventManager.Register(EPixelArtEventID.OnTextureGenerated, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OpenSeedDataViewer, NotifyEvent);
            gameObject.SetActive(false);
        }

        private void OnDestroy()
        {
            EventManager.Unregister(EPixelArtEventID.OnTextureGenerated, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OpenSeedDataViewer, NotifyEvent);
        }

        private void OnEnable()
        {
            EventManager.Register(EPixelArtEventID.OnPainboardTouch, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.OnPainboardTouch, NotifyEvent);
            
        }

        private void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnTextureGenerated:
                    _seedTexture.texture = ResourceManager.Instance.ScaledTarget;
                    break;
                case EPixelArtEventID.OpenSeedDataViewer:
                    {
                        if (gameObject.activeSelf == true)
                        {
                            var animator = gameObject.GetComponentInChildren<Animator>();
                            animator.Play("Popup_Close");
                            return;
                        }

                        var seedData = datas[0] as SeedData;
                        _seedData = seedData;
                        _seedTexture.texture = ResourceManager.Instance.ScaledTarget;
                        _nameField.text = seedData._name;
                        _upscaleTypeDropDown.SetValueWithoutNotify((int)seedData._upscaleType);
                        _filterTypeDropDown.SetValueWithoutNotify((int)seedData._filterMode);
                        _scaleSlider.SetValueWithoutNotify(seedData._scale);
                        gameObject.SetActive(true);
                        _rectTransform.anchoredPosition = Vector2.zero;

#if (UNITY_EDITOR && PIXELCANVAS_EDITOR)
                        _nameField.interactable = true;
                        _upscaleTypeDropDown.interactable = true;
                        _filterTypeDropDown.interactable = true;
                        _scaleSlider.interactable = true;
#else
                        var isOfficial = _seedData._isOfficial == true;
                        _nameField.interactable = !isOfficial;
                        _upscaleTypeDropDown.interactable = !isOfficial;
                        _filterTypeDropDown.interactable = !isOfficial;
                        _scaleSlider.interactable = !isOfficial;
#endif
                    }
                    break;
                case EPixelArtEventID.OnPainboardTouch:
                    {
                        var animator = gameObject.GetComponentInChildren<Animator>();
                        animator.Play("Popup_Close");
                    }
                    break;
            }
        }
    }
}