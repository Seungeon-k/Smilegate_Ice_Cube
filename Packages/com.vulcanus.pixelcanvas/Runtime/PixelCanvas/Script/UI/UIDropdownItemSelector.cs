using Cysharp.Threading.Tasks;

using TMPro;

using UnityEngine;
using UnityEngine.EventSystems;

namespace PixelCanvas
{
    public class UIDropdownItemSelector : MonoBehaviour, IPointerClickHandler
    {
        public TMP_Dropdown dropdown;
        public TMP_InputField textOverride;

        public async void OnPointerClick(PointerEventData eventData)
        {
            await UniTask.NextFrame();
            Debug.LogError(gameObject);


            dropdown.onValueChanged.Invoke(0);
            //dropdown.options
        }

        public void OnSelect(BaseEventData eventData)
        {
         //   Debug.LogError((eventData.selectedObject as GameObject).name);

            //Debug.LogError(eventData);
            //if (dropdown.options.Count == 1 || (dropdown.options.Count > 1 && dropdown.value == 0))
            //{
            //    textOverride.text = dropdown.options[0].text;
            //    saveGame.UpdateTextOverride()  // The handler in the script the dropdown lives in.
        }
    }
}
