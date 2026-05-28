using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


namespace PixelCanvas
{
    public class UISoundnteractor : MonoBehaviour
    {
        [SerializeField] private string _audioClipName;

        private void Awake()
        {
            if (TryGetComponent<Button>(out var button) == true)
            {
                button.onClick.AddListener(() =>
                {
                    SoundManager.Instance.PlaySound(_audioClipName);
                });
            }
            else if (TryGetComponent<Toggle>(out var toggle) == true)
            {
                toggle.onValueChanged.AddListener((flag) =>
                {
                    SoundManager.Instance.PlaySound(_audioClipName);
                });
            }
            else if (TryGetComponent<UIDropdown>(out var dropDown) == true)
            {
                dropDown.onClick += () => 
                {
                    SoundManager.Instance.PlaySound(_audioClipName);
                };
            }
        }
    }
}
