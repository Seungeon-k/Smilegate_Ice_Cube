using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using Cysharp.Threading.Tasks;
using UnityEngine.EventSystems;
using System.Threading;
using System.IO;

namespace PixelCanvas
{
    public class SeedDataViewerItem : MonoBehaviour//, IPointerDownHandler, IBeginDragHandler, IDragHandler, IEndDragHandler, IPointerUpHandler
    {
        [SerializeField] private Image _background;
        [SerializeField] private RawImage _seedImage;
        [SerializeField] private TMP_Text _name;
        [SerializeField] private TMP_Text _author;
        [SerializeField] private TMP_Text _date;
        [SerializeField] private TMP_Text _guid;
        [SerializeField] private TMP_Text _format;
        [SerializeField] private Image _officialTag;

        private ScrollRect _scrollRect;
        private SeedData _seedData;
        private bool _dragged;
        private CancellationTokenSource _cancellationToken = new CancellationTokenSource();

        public void Initialize(ScrollRect scrollRect, SeedData seedData)
        {
            gameObject.SetActive(true);
            _scrollRect = scrollRect;

            if (seedData == null)
            {
                OnError();
                return;
            }
            _seedImage.texture = seedData.GetThumbnail(EBitFlagGenerateThumbnail.None);

            _seedImage.material = null;
            _seedData = seedData;
            _name.text = seedData._name;
            _author.text = seedData._author;
            _date.text = seedData._lastModifiedDate;
            _guid.text = seedData._guid;

            var format = Path.GetExtension(seedData._storagePath);
            _format.text = format;
            switch (format)
            {
                case GlobalValue._jsonExtension:
                    _format.color = Color.green;
                    if (seedData._isOfficial == true)
                        _background.color = new Color(0.1084906f, 0.6f, 1, 1);
                    break;
                case GlobalValue._bytesExtension:
                    _format.color = Color.red;
                    if (seedData._isOfficial == true)
                        _background.color = new Color(1f, 0.6f, 1, 1);
                    break;
            }
        }

        private void OnDisable()
        {
            _cancellationToken.Cancel();
        }

        private void OnDestroy()
        {
            _cancellationToken.Cancel();
            _seedImage = null;
        }

        public void Release()
        {
        }

        public bool CompareData(string keyword)
        {
            var filter0 = -1 < _name.text.IndexOf(keyword, System.StringComparison.OrdinalIgnoreCase);
            if (filter0 == true)
                return true;

            var filter1 = -1 < _author.text.IndexOf(keyword, System.StringComparison.OrdinalIgnoreCase);
            if (filter1 == true)
                return true;

            var filter2 = -1 < _guid.text.IndexOf(keyword, System.StringComparison.OrdinalIgnoreCase);
            if (filter2 == true)
                return true;

            return false;
        }

        private void OnError()
        {
            var fileName = Path.GetFileNameWithoutExtension(_seedData._storagePath);
            _background.color = new Color(1, 0.45f, 0.45f, 1);
            _seedImage.texture = ResourceManager.Instance.ErrorImage;

            _name.text = fileName;
            _author.text = "Error";

            //switch (result)
            //{
            //    //case EPixelCanvas_Result.Error_FileNotFound:
            //    //    break;
            //    case EPixelCanvas_Result.Error_StringToJObject:
            //        _date.text = "Parse Json Failed";
            //        break;
            //    case EPixelCanvas_Result.Error_VersionMigration:
            //        _date.text = "Migration Failed";
            //        break;
            //    case EPixelCanvas_Result.Error_TextureByte:
            //        _date.text = "Texture Byte Corrupted";
            //        break;
            //}
        }

        public void OnPointerDown(BaseEventData eventData)
        {
            _dragged = false;
        }

        public void OnBeginDrag(BaseEventData eventData)
        {
            _dragged = true;
            _scrollRect.OnBeginDrag(eventData as PointerEventData);
        }

        public void OnDrag(BaseEventData eventData)
        {
            _scrollRect.OnDrag(eventData as PointerEventData);
        }

        public void OnEndDrag(BaseEventData eventData)
        {
            _scrollRect.OnEndDrag(eventData as PointerEventData);
        }

        public void OnPointerUp(BaseEventData eventData)
        {
            if (_dragged == true)
                return;
            EventManager.Notify(EPixelArtEventID.OpenSeedDataPopup, _seedData);
            
        }
    }
}