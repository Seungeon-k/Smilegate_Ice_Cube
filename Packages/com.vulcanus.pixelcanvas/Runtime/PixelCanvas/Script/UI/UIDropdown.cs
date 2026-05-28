using System;
using System.Linq;

using TMPro;

using UnityEngine;
using UnityEngine.EventSystems;

namespace PixelCanvas
{
    public class UIDropdown : TMP_Dropdown
    {
        [SerializeField] private Transform _arrow;

        public Action onClick;

        protected override void Start()
        {
            base.Start();

            _arrow = transform.Find("Btn").Find("Arrow");
            //ClearOptions();
        }

        public override void OnPointerClick(PointerEventData eventData)
        {
            base.OnPointerClick(eventData);
            var dropdownItems = transform.Find("Dropdown List").GetComponentsInChildren<DropdownItem>();
            dropdownItems.Last().transform.Find("Splitter").gameObject.SetActive(false);

            onClick.Invoke();
        }

        public override void OnSubmit(BaseEventData eventData)
        {
            base.OnSubmit(eventData);
        }

        public override void OnCancel(BaseEventData eventData)
        {
            base.OnCancel(eventData);
        }

        protected override GameObject CreateDropdownList(GameObject template)
        {
            _arrow.transform.localScale = new Vector3(1, -1, 1);
            return base.CreateDropdownList(template);
        }

        protected override void DestroyDropdownList(GameObject dropdownList)
        {
            _arrow.transform.localScale = new Vector3(1, 1, 1);
            base.DestroyDropdownList(dropdownList);
        }
    }
}
