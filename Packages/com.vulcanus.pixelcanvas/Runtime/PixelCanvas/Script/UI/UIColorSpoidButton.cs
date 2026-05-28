using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace PixelCanvas
{
    public class UIColorSpoidButton : MonoBehaviour
    {
        [SerializeField] private GameObject _pressedMode;
        [SerializeField] private Button _button;
        [SerializeField] private EventTrigger _eventTrigger;
        private bool _pressed;

        private void Awake()
        {
            _eventTrigger.triggers = new List<EventTrigger.Entry>
            {
                EventTriggerUtility.Create(EventTriggerType.PointerDown, 
                    (baseEvent) =>
                    {
                        _pressed = true;
                        _pressedMode.SetActive(true);
                        EventManager.Notify(EPixelArtEventID.ToggleInteraction, true, _button);
                        EventManager.Notify(EPixelArtEventID.OnColorSpoidTriggered, true);
                    }),

                EventTriggerUtility.Create(EventTriggerType.Drag,        
                    (baseEvent) =>
                    {
                        if (_pressed == false)
                            return;

                        var ped = baseEvent as PointerEventData;
                        EventManager.Notify(EPixelArtEventID.OnActionButtonDragged, ped.delta);
                    }),

                EventTriggerUtility.Create(EventTriggerType.PointerUp,
                    (baseEvent) =>
                    {
                        _pressed = false;
                        _pressedMode.SetActive(false);
                        EventManager.Notify(EPixelArtEventID.ToggleInteraction, false, _button);
                        EventManager.Notify(EPixelArtEventID.OnColorSpoidTriggered, false);
                    }),
            };
        }
    }
}