using System.Collections;
using System.Collections.Generic;
using System.Linq;

using TMPro;

using UnityEngine;

namespace PixelCanvas
{
    public static class TextTable
    {
        public static bool TryGetTextDataString(string key, out string text)
        {

#if PIXELCANVAS_EDITOR
            if (GlobalValue.KeyToTableString.TryGetValue(key, out text) == false)
            {
                text = null;
                return false;
            }
#else
            if (GlobalValue.GetTextDataString == null)
            {
                text = null;
                return false;
            }

            text = GlobalValue.GetTextDataString.Invoke(key);
            if (string.IsNullOrEmpty(text) == true)
                return false;
#endif

            return true;
        }

        public static string GetTextDataString(string key)
        {
            if (TryGetTextDataString(key, out var text) == false)
                return "";
            return text;
        }
    }

    [RequireComponent(typeof(TextMeshProUGUI))]
    public partial class UITextTranslator : MonoBehaviour
    {
        [SerializeField] private string _key;
        [SerializeField] private TextMeshProUGUI _text;

        private void OnEnable()
        {
            if (TextTable.TryGetTextDataString(_key, out var text) == true)
                _text.text = text;
            else
                _text.text = _key;
        }
    }

#if UNITY_EDITOR
    public partial class UITextTranslator
    {
        private void OnValidate()
        {
            if (string.IsNullOrEmpty(_key) == false)
                _key = _key.Trim(' ');

            _text = GetComponent<TextMeshProUGUI>();
        }
    }
#endif

}
