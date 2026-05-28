
using System;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

using static UnityEngine.Mathf;

namespace PixelCanvas
{
    [ExecuteAlways, RequireComponent(typeof(Image))]
    public class GraphColorPicker : MonoBehaviour, IPointerDownHandler, IDragHandler, IPointerUpHandler
    {
        private const float recip2Pi = 0.159154943f;
        private const string colorPickerShaderName = "UI/GraphColorPicker";

        private static readonly int _HSV = Shader.PropertyToID(nameof(_HSV));
        private static readonly int _AspectRatio = Shader.PropertyToID(nameof(_AspectRatio));
        private static readonly int _HueCircleInner = Shader.PropertyToID(nameof(_HueCircleInner));
        private static readonly int _SVSquareSize = Shader.PropertyToID(nameof(_SVSquareSize));

        [SerializeField, HideInInspector] private Shader graphColorPickerShader;
        private Material generatedMaterial;

        private enum PointerDownLocation { HueCircle, SVSquare, Outside }
        private PointerDownLocation pointerDownLocation = PointerDownLocation.Outside;

        private RectTransform rectTransform;
        private Image image;

        float h, s, v, a;

        public Color color
        {
            get 
            { 
                var color = Color.HSVToRGB(h, s, v);
                color.a = a;
                return color;
            }
            set
            {
                Color.RGBToHSV(value, out h, out s, out v);
                a = value.a;
                ApplyColor();
            }
        }

        private event Action<Color> onColorChanged;
        public void RegisterEvent(Action<Color> actionEvent) => onColorChanged += actionEvent;
        public void UnregisterEvent(Action<Color> actionEvent) => onColorChanged -= actionEvent;

        private void Awake()
        {
            rectTransform = transform as RectTransform;
            image = GetComponent<Image>();

            h = s = v = 0;

            if (WrongShader())
            {
                Debug.LogWarning($"Color picker requires image material with {colorPickerShaderName} shader.");

                if (Application.isPlaying && graphColorPickerShader != null)
                {
                    generatedMaterial = new Material(graphColorPickerShader);
                    generatedMaterial.hideFlags = HideFlags.HideAndDontSave;
                }

                image.material = generatedMaterial;
                return;
            }
            ApplyColor();
        }

        private void Reset()
        {
            graphColorPickerShader = Shader.Find(colorPickerShaderName);
        }

        private void OnEnable()
        {
            EventManager.Register(EPixelArtEventID.CloseColorPickerWindow, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.CloseColorPickerWindow, NotifyEvent);
        }

        private bool WrongShader()
        {
            return image?.material?.shader?.name != colorPickerShaderName;
        }

        private void Update()
        {
            if (WrongShader()) return;

            var rect = rectTransform.rect;

            image.material.SetFloat(_AspectRatio, rect.width / rect.height);
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (WrongShader()) return;

            var pos = GetRelativePosition(eventData);

            switch (pointerDownLocation)
            {
                case PointerDownLocation.HueCircle:
                    {
                        h = (Atan2(pos.y, pos.x) * recip2Pi + 1) % 1;
                        ApplyColor();
                    }
                    break;
                case PointerDownLocation.SVSquare:
                    {
                        var size = image.material.GetFloat(_SVSquareSize);

                        s = InverseLerp(-size, size, pos.x);
                        v = InverseLerp(-size, size, pos.y);
                        ApplyColor();
                    }
                    break;
                default:
                    transform.parent.SendMessageUpwards("OnDrag", eventData);
                    break;
            }
        }

        public void OnPointerDown(PointerEventData eventData)
        {
            if (WrongShader()) return;

            var pos = GetRelativePosition(eventData);

            float r = pos.magnitude;

            if (r < .5f && r > image.material.GetFloat(_HueCircleInner))
            {
                pointerDownLocation = PointerDownLocation.HueCircle;
                h = (Atan2(pos.y, pos.x) * recip2Pi + 1) % 1;
                ApplyColor();
            }
            else
            {
                var size = image.material.GetFloat(_SVSquareSize);

                // s -> x, v -> y
                if (pos.x >= -size && pos.x <= size && pos.y >= -size && pos.y <= size)
                {
                    pointerDownLocation = PointerDownLocation.SVSquare;
                    s = InverseLerp(-size, size, pos.x);
                    v = InverseLerp(-size, size, pos.y);
                    ApplyColor();
                }
                else
                {
                    transform.parent.SendMessageUpwards("OnPointerDown", eventData);
                }
            }
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            if (pointerDownLocation == PointerDownLocation.Outside)
                transform.parent.SendMessageUpwards("OnPointerUp", eventData);
            pointerDownLocation = PointerDownLocation.Outside;
        }

        private void ApplyColor()
        {
            image.material.SetVector(_HSV, new Vector3(h, s, v));
            onColorChanged?.Invoke(color);

            Shader.SetGlobalVector(GlobalValue._BrushColor, color.linear);
        }

        private void OnDestroy()
        {
            if (generatedMaterial != null)
                DestroyImmediate(generatedMaterial);
        }

        /// <summary>
        /// Returns position in range -0.5..
        /// P0.5 when it's inside color picker square area
        /// </summary>
        public Vector2 GetRelativePosition(PointerEventData eventData)
        {
            var rect = GetSquaredRect();

            Vector2 rtPos;

            RectTransformUtility.ScreenPointToLocalPointInRectangle(rectTransform, eventData.position, eventData.pressEventCamera, out rtPos);

            return new Vector2(InverseLerpUnclamped(rect.xMin, rect.xMax, rtPos.x), InverseLerpUnclamped(rect.yMin, rect.yMax, rtPos.y)) - Vector2.one * 0.5f;
        }

        public Rect GetSquaredRect()
        {
            var rect = rectTransform.rect;
            var smallestDimension = Min(rect.width, rect.height);
            return new Rect(rect.center - Vector2.one * smallestDimension * 0.5f, Vector2.one * smallestDimension);
        }

        public float InverseLerpUnclamped(float min, float max, float value)
        {
            return (value - min) / (max - min);
        }

        internal void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.CloseColorPickerWindow:
                    {
                        transform.parent.gameObject.SetActive(false);
                    }
                    break;
            }
        }

        //#if UNITY_EDITOR

        //    [UnityEditor.MenuItem("GameObject/UI/Color Picker", false, 10)]
        //    private static void CreateColorPicker(UnityEditor.MenuCommand menuCommand)
        //    {
        //        GameObject go = new GameObject("Color Picker");

        //        go.AddComponent<ColorPicker>();

        //        UnityEditor.GameObjectUtility.SetParentAndAlign(go, menuCommand.context as GameObject);

        //        UnityEditor.Undo.RegisterCreatedObjectUndo(go, "Create " + go.name);
        //        UnityEditor.Selection.activeObject = go;
        //    }
        //#endif
    }
}