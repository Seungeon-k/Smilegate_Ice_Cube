using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using TMPro;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;
using Color = UnityEngine.Color;

namespace PixelCanvas
{
    public enum EElementType
    {
        R,
        G,
        B,
        A,
        Opaque,
        Transparent
    }

    [Serializable] public struct Picker
    {
        public EElementType _elementType;
        public Image image;
        public RectTransform _handle;
        public bool _applyAlpha;
        public TMP_InputField _inputField;
    }

    [Serializable] public struct PresetColor
    {
        public Color[] _colors;
    }

    public class ColorPallete : MonoBehaviour
    {
        [SerializeField] private Picker[] pickers;

        [SerializeField] private TMP_InputField _hexInput;
        [SerializeField] private GraphColorPicker _colorPicker;
        [SerializeField] private PaletteSlot[] _colorPresets;

        [SerializeField] private PresetColor[] _presetColors;

        private Canvas _canvas;
        private PaletteSlot _selectedColorPreView;
        private Picker _focusedPicker;

        public Color Color => _selectedColorPreView.Color;

        private void Awake()
        {
            _canvas = GetComponentInParent<Canvas>();

            for (var i = 0; i < _colorPresets.Length; ++i)
                _colorPresets[i].Initialize(_colorPicker, i);

            foreach (var picker in pickers)
            {
                picker.image.material = GameObject.Instantiate(picker.image.material);
            }
        }

        private void OnEnable()
        {
            _colorPicker.RegisterEvent(UpdateMarkers);
            _colorPicker.RegisterEvent(UpdateTextures);
            _colorPicker.RegisterEvent(UpdateHex);
            EventManager.Register(EPixelArtEventID.ChangeColor, NotifyEvent);
            EventManager.Register(EPixelArtEventID.SelectColorPreset, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.ChangeColor, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.SelectColorPreset, NotifyEvent);
            _colorPicker.UnregisterEvent(UpdateMarkers);
            _colorPicker.UnregisterEvent(UpdateTextures);
            _colorPicker.UnregisterEvent(UpdateHex);
        }

        private void Start()
        {
            ChangeColorPresets(0);
            EventManager.Notify(EPixelArtEventID.SelectColorPreset, _colorPresets[0]);
        }

        //private void Update()
        //{
        //    if (Input.GetKeyDown(KeyCode.Alpha4) == true)
        //        EventManager.Notify(EPixelArtEventID.SelectColorPreset, _colorPresets[0]);
        //    else if (Input.GetKeyDown(KeyCode.Alpha5) == true)
        //        EventManager.Notify(EPixelArtEventID.SelectColorPreset, _colorPresets[1]);
        //    else if (Input.GetKeyDown(KeyCode.Alpha6) == true)
        //        EventManager.Notify(EPixelArtEventID.SelectColorPreset, _colorPresets[2]);
        //    else if (Input.GetKeyDown(KeyCode.Alpha7) == true)
        //        EventManager.Notify(EPixelArtEventID.SelectColorPreset, _colorPresets[3]);
        //    else if (Input.GetKeyDown(KeyCode.Alpha8) == true)
        //        EventManager.Notify(EPixelArtEventID.SelectColorPreset, _colorPresets[4]);
        //    else if (Input.GetKeyDown(KeyCode.Alpha9) == true)
        //        EventManager.Notify(EPixelArtEventID.SelectColorPreset, _colorPresets[5]);
        //}

        public void SetPointerFocus(int i)
        {
            _focusedPicker = pickers[i];
        }

        public void PointerUpdate(BaseEventData e)
        {
            var v = GetNormalizedPointerPosition(_canvas, _focusedPicker.image.rectTransform, e);

            var curColor = _colorPicker.color;
            switch (_focusedPicker._elementType)
            {
                case EElementType.R:
                    curColor.r = v.x;
                    break;
                case EElementType.G:
                    curColor.g = v.x;
                    break;
                case EElementType.B:
                    curColor.b = v.x;
                    break;
                case EElementType.A:
                    curColor.a = v.x;
                    break;
            }

            _colorPicker.color = curColor;
            UpdateMarkers(curColor);
            UpdateTextures(curColor);
            UpdateHex(curColor);

            //onColorChange.Invoke(_bufferedColor.color);
        }

        private void UpdateMarkers(Color color)
        {
            for (int i = 0; i < pickers.Length; i++)
            {
                var picker = pickers[i];
                var colorElement = default(float);
                switch (picker._elementType)
                {
                    case EElementType.R:
                        colorElement = color.r;
                        break;
                    case EElementType.G:
                        colorElement = color.g;
                        break;
                    case EElementType.B:
                        colorElement = color.b;
                        break;
                    case EElementType.A:
                        colorElement = color.a;
                        break;
                    default:
                        return;
                }

                var parent = picker.image.rectTransform;
                var parentSize = parent.rect.size;
                var localPos = picker._handle.localPosition;
                localPos.x = (colorElement - parent.pivot.x) * parentSize.x;
                picker._handle.localPosition = localPos;
                picker._inputField.SetTextWithoutNotify($"{(int)(colorElement * 255)}");
            }
        }

        private void UpdateTextures(Color color)
        {
            for (var i = 0; i < pickers.Length; i++)
            {
                var picker = pickers[i];
                var c1 = color;
                var c2 = color;
                switch (picker._elementType)
                {
                    case EElementType.R:
                        c1.r = 0;
                        c2.r = 1;
                        break;
                    case EElementType.G:
                        c1.g = 0;
                        c2.g = 1;
                        break;
                    case EElementType.B:
                        c1.b = 0;
                        c2.b = 1;
                        break;
                    case EElementType.A:
                        c1.a = 0;
                        c2.a = 1;
                        break;
                }
                if (picker._applyAlpha == false)
                {
                    c1.a = 1;
                    c2.a = 1;
                }

                var m = picker.image.material;
                m.SetColor(GlobalValue._Color1, c1);
                m.SetColor(GlobalValue._Color2, c2);
            }
        }

        private void UpdateHex(Color color)
        {
            if (_hexInput == null || _hexInput.gameObject.activeInHierarchy == false)
                return;
            _hexInput.SetTextWithoutNotify("#" + ColorUtility.ToHtmlStringRGB(color));
        }

        public void TypeHex(string input)
        {
            TypeHex(input, false);

            var color = _colorPicker.color;
            UpdateTextures(color);
            UpdateMarkers(color);
        }

        private void TypeHex(string input, bool finish)
        {
            var newText = GetSanitizedHex(input, finish);
            var parseText = GetSanitizedHex(input, true);

            int cp = _hexInput.caretPosition;
            _hexInput.SetTextWithoutNotify(newText);
            if (_hexInput.caretPosition == 0)
                _hexInput.caretPosition = 1;
            else if (newText.Length == 2)
                _hexInput.caretPosition = 2;
            else if (input.Length > newText.Length && cp < input.Length)
                _hexInput.caretPosition = cp - input.Length + newText.Length;

            if (ColorUtility.TryParseHtmlString(parseText, out var newColor))
            {
                _colorPicker.color = newColor;
            }

            static string GetSanitizedHex(string input, bool full)
            {
                if (string.IsNullOrEmpty(input))
                    return "#";

                List<char> toReturn = new List<char>();
                toReturn.Add('#');
                int i = 0;
                char[] chars = input.ToCharArray();
                while (toReturn.Count < 7 && i < input.Length)
                {
                    char nextChar = char.ToUpper(chars[i++]);
                    if (IsValidHexChar(nextChar))
                        toReturn.Add(nextChar);
                }

                while (full && toReturn.Count < 7)
                    toReturn.Insert(1, '0');

                return new string(toReturn.ToArray());
            }

            static bool IsValidHexChar(char c)
            {
                bool valid = char.IsNumber(c);
                valid |= c >= 'A' & c <= 'F';
                return valid;
            }
        }

        public void TypeElement(string input)
        {
            TypeElementEnd(input);
        }

        public void TypeElementEnd(string input)
        {
            if (float.TryParse(input, NumberStyles.Float, CultureInfo.InvariantCulture, out var result) == false)
            {
                switch (_focusedPicker._elementType)
                {
                    case EElementType.R:
                        _focusedPicker._inputField.SetTextWithoutNotify($"{(int)(_colorPicker.color.r * 255)}");
                        break;
                    case EElementType.G:
                        _focusedPicker._inputField.SetTextWithoutNotify($"{(int)(_colorPicker.color.g * 255)}");
                        break;
                    case EElementType.B:
                        _focusedPicker._inputField.SetTextWithoutNotify($"{(int)(_colorPicker.color.b * 255)}");
                        break;
                    case EElementType.A:
                        _focusedPicker._inputField.SetTextWithoutNotify($"{(int)(_colorPicker.color.a * 255)}");
                        break;
                    default:
                        return;
                }
                return;
            }

            result = Math.Clamp(result, 0, 255);
            var color = _colorPicker.color;
            switch (_focusedPicker._elementType)
            {
                case EElementType.R:
                    color.r = result / 255.0f;
                    break;
                case EElementType.G:
                    color.g = result / 255.0f;
                    break;
                case EElementType.B:
                    color.b = result / 255.0f;
                    break;
                case EElementType.A:
                    color.a = result / 255.0f;
                    break;
                default:
                    return;
            }
            _colorPicker.color = color;
            if (_focusedPicker._inputField != null)
                _focusedPicker._inputField.SetTextWithoutNotify($"{(int)result}");

            UpdateTextures(color);
            UpdateMarkers(color);
        }



        private static Vector2 GetNormalizedPointerPosition(Canvas canvas, RectTransform rect, BaseEventData e)
        {
            switch (canvas.renderMode)
            {
                case RenderMode.ScreenSpaceCamera:
                    if (canvas.worldCamera == null)
                        return GetNormScreenSpace(rect, e);
                    else
                        return GetNormWorldSpace(canvas, rect, e);

                case RenderMode.ScreenSpaceOverlay:
                    return GetNormScreenSpace(rect, e);

                case RenderMode.WorldSpace:
                    if (canvas.worldCamera == null)
                    {
                        Debug.LogError("FCP in world space render mode requires an event camera to be set up on the parent canvas!");
                        return Vector2.zero;
                    }
                    return GetNormWorldSpace(canvas, rect, e);

                default: return Vector2.zero;
            }

            static Vector2 GetNormScreenSpace(RectTransform rect, BaseEventData e)
            {
                Vector2 screenPoint = ((PointerEventData)e).position;
                Vector2 localPos = rect.worldToLocalMatrix.MultiplyPoint(screenPoint);
                float x = Mathf.Clamp01((localPos.x / rect.rect.size.x) + rect.pivot.x);
                float y = Mathf.Clamp01((localPos.y / rect.rect.size.y) + rect.pivot.y);
                return new Vector2(x, y);
            }

            static Vector2 GetNormWorldSpace(Canvas canvas, RectTransform rect, BaseEventData e)
            {
                Vector2 screenPoint = ((PointerEventData)e).position;
                Ray pointerRay = canvas.worldCamera.ScreenPointToRay(screenPoint);
                Plane canvasPlane = new Plane(canvas.transform.forward, canvas.transform.position);
                float enter;
                canvasPlane.Raycast(pointerRay, out enter);
                Vector3 worldPoint = pointerRay.origin + enter * pointerRay.direction;
                Vector2 localPoint = rect.worldToLocalMatrix.MultiplyPoint(worldPoint);

                float x = Mathf.Clamp01((localPoint.x / rect.rect.size.x) + rect.pivot.x);
                float y = Mathf.Clamp01((localPoint.y / rect.rect.size.y) + rect.pivot.y);
                return new Vector2(x, y);
            }
        }

        public void ChangeColorPresets(int idx)
        {
            var preset = _presetColors[idx];

            for (var i = 0; i < preset._colors.Length; ++i) 
            {
                _colorPresets[i].Color = preset._colors[i];
            }
        }

        internal void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.ChangeColor:
                    {
                        var color = (Color)datas[0];
                        _selectedColorPreView.Color = color;
						EventManager.Notify(EPixelArtEventID.OnColorChanged, color);
                        EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
                    }
                    break;
                case EPixelArtEventID.SelectColorPreset:
                    {
                        var colorPreview = (PaletteSlot)datas[0];

                        if (_selectedColorPreView == colorPreview)
                        {
                            EventManager.Notify(EPixelArtEventID.ToggleColorPickerWindow);
                            return;
                        }

                        if (_selectedColorPreView != null)
                            _selectedColorPreView.Unselect();

                        colorPreview.Select();
                        _selectedColorPreView = colorPreview;
						EventManager.Notify(EPixelArtEventID.OnColorChanged, _selectedColorPreView.Color);
                    }
                    break;
            }
        }
    }
}