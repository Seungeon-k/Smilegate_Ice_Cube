using TMPro;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.UI;


namespace PixelCanvas
{
    public class SeedDataPopup : MonoBehaviour
    {
        [SerializeField] private RawImage _seedTexture;
        [SerializeField] private TMP_InputField _nameField;
        [SerializeField] private TMP_Text _upscaleTypeText;
        [SerializeField] private TMP_Text _filterTypeText;
        [SerializeField] private TMP_Text _scaleText;

        [SerializeField] private Button _openButton;
        [SerializeField] private Button _copyButton;
        [SerializeField] private Button _deleteButton;
        [SerializeField] private Button _closeButton;

        private RectTransform _rectTransform;
        private SeedData _seedData;

        private const int _nameMaxLength = 50;

        public void Awake()
        {
            _nameField.onValueChanged.AddListener((value) =>
            {
                value = value.Substring(0, math.min(value.Length, _nameMaxLength));
                _nameField.SetTextWithoutNotify(value);
            });

            _nameField.onEndEdit.AddListener((value) =>
            {
                if (value.Length == 0)
                {
                    _nameField.SetTextWithoutNotify(_seedData._name);
                    return;
                }

                value = value.Substring(0, math.min(value.Length, _nameMaxLength));
                if (_seedData._name == value)
                    return;
                _seedData._name = value;
                _seedData.Save();

                EventManager.Notify(EPixelArtEventID.UpdateSeedDataListViewer);
            });

            _openButton.onClick.AddListener(() =>
            {
                EventManager.Notify(EPixelArtEventID.OpenCanvas, _seedData);
                EventManager.Notify(EPixelArtEventID.CloseSeedDataListViewer);
                EventManager.Notify(EPixelArtEventID.CloseSeedDataPopup);
            });

            _copyButton.onClick.AddListener(() =>
            {
                var seedData = PixelCanvasStorageManager.Instance.CopySeedData(_seedData);
                seedData.Save(EBitFlagSave.ForceGenerateThumbnail);
                EventManager.Notify(EPixelArtEventID.AddItemToSeedDataListViewer, seedData);
            });

            _deleteButton.onClick.AddListener(() =>
            {
                PixelCanvasStorageManager.Instance.Delete(_seedData);
                EventManager.Notify(EPixelArtEventID.UpdateSeedDataListViewer);
                EventManager.Notify(EPixelArtEventID.CloseSeedDataPopup);
            });

            _closeButton.onClick.AddListener(() =>
            {
                gameObject.SetActive(false);
            });

            _rectTransform = GetComponent<RectTransform>();
            _rectTransform.anchoredPosition = Vector2.zero;
            gameObject.SetActive(false);

            EventManager.Register(EPixelArtEventID.OpenSeedDataPopup, NotifyEvent);
        }

        private void OnDestroy()
        {
            EventManager.Unregister(EPixelArtEventID.OpenSeedDataPopup, NotifyEvent);
        }

        private void OnEnable()
        {
            EventManager.Register(EPixelArtEventID.CloseSeedDataPopup, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.CloseSeedDataPopup, NotifyEvent);
        }

        private void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OpenSeedDataPopup:
                    {
                        var seedData = datas[0] as SeedData;
                        _seedData = seedData;

                        _seedTexture.texture = seedData.Thumbnail;
                        _nameField.text = seedData._name;
                        _upscaleTypeText.text = $"{seedData._upscaleType}";
                        _filterTypeText.text = $"{seedData._filterMode}";
                        _scaleText.text = $"X{seedData._scale}";

                        //if (PixelCanvasManager.IsDevMode == false)
                        //{
                        var isOfficial = _seedData._isOfficial == true;
                        //_nameField.interactable = !isOfficial;
                        _deleteButton.interactable = !isOfficial;
                        //}

                        gameObject.SetActive(true);
                    }
                    break;
                case EPixelArtEventID.CloseSeedDataPopup:
                    {
                        gameObject.SetActive(false);
                    }
                    break;
            }
        }
    }
}