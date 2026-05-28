
using System.Collections.Generic;

using Unity.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace PixelCanvas
{
    public partial class PaletteSlot : MonoBehaviour
    {
        [SerializeField] private Graphic _background;
		[SerializeField] private Graphic _color;
        [SerializeField] private Graphic _selected;
        [SerializeField] private Button _button;
        [SerializeField] private EventTrigger _buttonEvent;

        private Animator _animator;

        public Color Color
        {
            set => _color.color = value;
            get => _color.color;
        }

        private GraphColorPicker _colorPicker;
        private int _index;

        private void Awake()
        {
            _selected.gameObject.SetActive(false);
            _animator = GetComponent<Animator>();
            _animator.Play("Color_Unselected", 0, 1);

            _buttonEvent.triggers = new List<EventTrigger.Entry> {
                EventTriggerUtility.Create(
                    EventTriggerType.PointerDown,
                    (baseEvent) =>
                    {
                        EventManager.Notify(EPixelArtEventID.SelectColorPreset, this);
                        EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
                        _colorPicker.color = _color.color;
                    }
                )
            };
        }

        public void Initialize(GraphColorPicker colorPicker, int index)
        {
            _colorPicker = colorPicker;
            _index = index;
        }

        public void Select()
        {
            _animator.Play("Color_Selected", 0, 0);

            _colorPicker.RegisterEvent(OnColorChanged);
            _colorPicker.color = _color.color;
            _selected.gameObject.SetActive(true);
            //transform.localScale = new Vector3(1.1f, 1.1f, 1.1f);
        }

        public void Unselect()
        {
            _animator.Play("Color_Unselected");

            _colorPicker.UnregisterEvent(OnColorChanged);
            _selected.gameObject.SetActive(false);
            //transform.localScale = Vector3.one;
        }

        public void OnColorChanged(Color color)
        {
			_color.color = color;
            EventManager.Notify(EPixelArtEventID.OnColorChanged, color);
            EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
        }

        internal void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnColorChanged:
                    {
                        var color = (Color)datas[0];
						_color.color = color;
                    }
                    break;
            }
        }
    }

#if UNITY_EDITOR
    public partial class PaletteSlot
    {

    }
#endif
}