using System.Collections;
using System.Collections.Generic;
using System.Drawing;

using UnityEngine;
using UnityEngine.EventSystems;

namespace PixelCanvas
{
    public class UIRedoUndoGestureZone : MonoBehaviour, IPointerDownHandler
    {
        [SerializeField] private ERedoUndo _commandType;
        private float _doubleTabTimer = 0;

        public void OnPointerDown(PointerEventData eventData)
        {
            EventManager.Notify(EPixelArtEventID.OnPainboardTouch);

            //Check Double Tab
            if (Time.unscaledTime - _doubleTabTimer < ResourceManager.Instance._doubleTabTimeThreshold)
            {
                EventManager.Notify(EPixelArtEventID.UndoRedo, _commandType);
            }
            _doubleTabTimer = Time.unscaledTime;

        }
    }
}
