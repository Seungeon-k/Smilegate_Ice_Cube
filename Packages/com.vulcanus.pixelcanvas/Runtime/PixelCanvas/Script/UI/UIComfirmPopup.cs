using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.UI;

namespace PixelCanvas 
{
    public enum EComfirmPopupType
    {
        YesNoCancel,
        //Yes,
        //No,
    }

    public class UIComfirmPopup : MonoBehaviour
    {
        [SerializeField] TMPro.TMP_Text _text;
        [SerializeField] Button _yesButton;
        [SerializeField] Button _noButton;
        [SerializeField] Button _cancelButton;

        private RectTransform _rectTransform;
        private Action _yesCallback;
        private Action _noCallback;

        private void Awake()
        {
            _rectTransform = GetComponent<RectTransform>();
            _rectTransform.anchoredPosition = Vector2.zero;
            gameObject.SetActive(false);

            EventManager.Register(EPixelArtEventID.OpenComfirmPopup, NotifyEvent);
        }

        private void OnDestroy()
        {
            EventManager.Unregister(EPixelArtEventID.OpenComfirmPopup, NotifyEvent);
        }

        internal void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OpenComfirmPopup:
                    {
                        var type = (EComfirmPopupType)datas[0];
                        var text = datas[1] as string;
                        var action0 = datas[2] as Action;
                        var action1 = datas[3] as Action;
                        var action2 = datas[4] as Action;

                        switch (type)
                        {
                            case EComfirmPopupType.YesNoCancel:
                                gameObject.SetActive(true);
                                _text.text = text;
                                _yesButton.gameObject.SetActive(true);
                                _noButton.gameObject.SetActive(true);
                                _cancelButton.gameObject.SetActive(true);

                                _yesButton.onClick.RemoveAllListeners();
                                _noButton.onClick.RemoveAllListeners();
                                _cancelButton.onClick.RemoveAllListeners();

                                _yesButton.onClick.AddListener(() => 
                                { 
                                    action0?.Invoke();
                                    gameObject.SetActive(false);
                                });

                                _noButton.onClick.AddListener(() =>
                                { 
                                    action1?.Invoke();
                                    gameObject.SetActive(false);
                                });

                                _cancelButton.onClick.AddListener(() => 
                                {
                                    action2?.Invoke();
                                    gameObject.SetActive(false);
                                });

                                break;
                        }
                    }
                    break;
            }
        }
    }
}