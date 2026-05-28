using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Threading;

using Cysharp.Threading.Tasks;

using TMPro;

using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.ResourceLocations;
using UnityEngine.UI;

#if EasyButton
    using EasyButtons;
#endif

namespace PixelCanvas
{
    public class SeedDataListViewer : MonoBehaviour
    {
        [SerializeField] private Canvas _canvas;
        [SerializeField] private GameObject _thumbnailPrefab;
        [SerializeField] private GridLayoutGroup _gridLayoutGropup;

        [SerializeField] private ScrollRect _scrollRect;
        [SerializeField] private Button _closeButton;
        [SerializeField] private Button _newCanvasButton;
        [SerializeField] private TMP_Dropdown _costumeTypeDropDown;
        [SerializeField] private TMP_Dropdown _modelTypeDropDown;

        [SerializeField] private TMP_InputField _searchInputField;

        private Dictionary<string, string> _seedDataModelLookupTable;

        private List<SeedDataViewerItem> DataList
        {
            get
            {
                if (0 < _searchResultThumbnails.Count)
                    return _searchResultThumbnails;
                return _allThumbnails;
            }
        }
        private List<SeedDataViewerItem> _searchResultThumbnails;
        private List<SeedDataViewerItem> _searchResultThumbnailsTemp;
        private List<SeedDataViewerItem> _allThumbnails;

        private CancellationTokenSource _cancellationToken;
        private bool _operationToolMode;

        private void Awake()
        {
            _scrollRect = GetComponentInChildren<ScrollRect>();
            _allThumbnails = new List<SeedDataViewerItem>();
            transform.localPosition = Vector3.zero;

            _thumbnailPrefab.gameObject.SetActive(false);
            _closeButton.onClick.AddListener(() => { gameObject.SetActive(false); });

            _operationToolMode = false;

            _searchResultThumbnails = new List<SeedDataViewerItem>();
            _searchResultThumbnailsTemp = new List<SeedDataViewerItem>();
            _searchInputField.onValueChanged.AddListener((value) =>
            {
                Search(value);
            });

#if SHOW_MODELDATA_LIST
            //Initialize Model Type Dropdown
            {
                var modelTypes = new List<string>();
                _modelTypeDropDown.ClearOptions();
                _seedDataModelLookupTable = new Dictionary<string, string>();
                foreach (var locator in Addressables.ResourceLocators)
                {
                    foreach (var key in locator.Keys)
                    {
                        if (key is string keyString == false)
                            continue;
                        if (keyString.Contains("/") == false)
                            continue;

                        //Collect ModelData Lookup Table
                        switch (Path.GetExtension(keyString))
                        {
                            case GlobalValue._jsonExtension:
                            case GlobalValue._bytesExtension:
                                var seedDataName = Path.GetFileNameWithoutExtension(keyString);
                                var modelDataName = Path.GetFileName(Utility.GetParentDirectory(keyString));
                                _seedDataModelLookupTable.Add(seedDataName, modelDataName);
                                continue;
                        }

                        if (locator.Locate(key, typeof(ModelData), out IList<IResourceLocation> locations) == false)
                            continue;

                        var fileName = Path.GetFileNameWithoutExtension(locations[0].ToString());
                        modelTypes.Add(fileName);
                    }
                }
                _modelTypeDropDown.AddOptions(modelTypes);
            }
#endif

            _newCanvasButton.onClick.AddListener(() =>
            {
                var seedDataName = _modelTypeDropDown.options[_modelTypeDropDown.value].text;
                if (_seedDataModelLookupTable.TryGetValue(seedDataName, out var modelDataName) == false)
                {
                    Debug.LogError($"No ModelData Found Via : {seedDataName}");
                    return;
                }

                if (PixelCanvasStorageManager.Instance.TryGetOfficialSeedData(ESeedDataType.Pet, modelDataName, seedDataName, out var officialSeedData) != EPixelCanvas_Result.Success)
                    return;

                var seedData = officialSeedData.GenerateClone();
                seedData.Save(EBitFlagSave.ForceGenerateThumbnail);

                EventManager.Notify(EPixelArtEventID.AddItemToSeedDataListViewer, seedData);
            });

            EventManager.Register(EPixelArtEventID.OpenSeedDataListViewer, NotifyEvent);
            gameObject.SetActive(false);
        }

        private void OnEnable()
        {
            EventManager.Register(EPixelArtEventID.CloseSeedDataListViewer, NotifyEvent);
            EventManager.Register(EPixelArtEventID.AddItemToSeedDataListViewer, NotifyEvent);
            EventManager.Register(EPixelArtEventID.UpdateSeedDataListViewer, NotifyEvent);
            EventManager.Register(EPixelArtEventID.FileDragDrop, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.CloseSeedDataListViewer, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.AddItemToSeedDataListViewer, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.UpdateSeedDataListViewer, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.FileDragDrop, NotifyEvent);

            _cancellationToken?.Cancel();
            //Release();
        }

        public void OnDestroy()
        {
            EventManager.Unregister(EPixelArtEventID.OpenSeedDataListViewer, NotifyEvent);
            Release();
        }

        private void Release()
        {
            _cancellationToken?.Cancel();

            foreach (var thumbnail in _allThumbnails)
            {
                thumbnail.Release();
                GameObject.Destroy(thumbnail.gameObject);
            }
            _allThumbnails.Clear();
        }

        private async void UpdateSeedDataList()
        {
            if (_operationToolMode == true)
                return;

            Release();
            //_scrollRect.OnValueChangedAsync
            _cancellationToken = new CancellationTokenSource();

            try
            {
                var seedDataPaths = default(string[]);

                //Local Storage
                seedDataPaths = Directory.GetFiles(GlobalValue._localPixelCanvasPath, GlobalValue._bytesSearchPattern, SearchOption.AllDirectories);
                foreach (var seedDataPath in seedDataPaths)
                {
                    if (SeedData.LoadFromPath(seedDataPath, out var migrationUpdated, out var seedData) != EPixelCanvas_Result.Success)
                        continue;

                    var seedDataThumbnail = GameObject.Instantiate(_thumbnailPrefab).GetComponent<SeedDataViewerItem>();
                    seedDataThumbnail.Initialize(_scrollRect, seedData);
                    seedDataThumbnail.transform.SetParent(_gridLayoutGropup.transform, false);
                    _allThumbnails.Add(seedDataThumbnail);

                    await UniTask.Delay(3, cancellationToken: _cancellationToken.Token);
                }

#if (UNITY_EDITOR && PIXELCANVAS_EDITOR)
                seedDataPaths = Directory.GetFiles(GlobalValue._editorSeedDataPath, GlobalValue._jsonSearchPattern, SearchOption.AllDirectories);
                foreach (var dataPath in seedDataPaths)
                {
                    if (SeedData.LoadFromPath(dataPath, out var migrationUpdated, out var seedData) != EPixelCanvas_Result.Success)
                        continue;

                    var seedDataThumbnail = GameObject.Instantiate(_thumbnailPrefab).GetComponent<SeedDataViewerItem>();
                    seedDataThumbnail.Initialize(_scrollRect, seedData);
                    seedDataThumbnail.transform.SetParent(_gridLayoutGropup.transform, false);
                    _allThumbnails.Add(seedDataThumbnail);

                    await UniTask.Yield();
                }
#else
                var tasks = new List<UniTask>();
                foreach (var locator in Addressables.ResourceLocators)
                {
                    foreach (var key in locator.Keys)
                    {
                        if (key is string keyString == false)
                            continue;
                        if (keyString.Contains("/") == false)
                            continue;
                        if (locator.Locate(key, typeof(TextAsset), out IList<IResourceLocation> locations) == false)
                            continue;

                        var task = SeedData.LoadFromAddressables_Async(locations[0]).ContinueWith((asyncData) =>
                        {
                            if (asyncData.result != EPixelCanvas_Result.Success)
                                return;

                            var seedDataThumbnail = GameObject.Instantiate(_thumbnailPrefab).GetComponent<SeedDataViewerItem>();
                            seedDataThumbnail.Initialize(_scrollRect, asyncData.seedData);
                            seedDataThumbnail.transform.SetParent(_gridLayoutGropup.transform, false);
                            _allThumbnails.Add(seedDataThumbnail);
                        });
                        tasks.Add(task);

                        await UniTask.Yield();
                    }
                }
                await UniTask.WhenAll(tasks);
#endif
            }
            catch (System.Exception e)
            {
                Debug.LogError($"GenerateThumbnails Error : {e}");
            }
        }

        string[] _paths = new string[] { };

        public void OnPointerDown()
        {
            EventManager.Notify(EPixelArtEventID.CloseSeedDataPopup);
        }

        private void ClearList()
        {
            _searchResultThumbnails.Clear();
        }

        protected void Search(string str)
        {
            ClearList();

            if (string.IsNullOrEmpty(str) == false)
            {
                //Search by Multiple Keywords
                var keywords = str.Split(' ');
                _searchResultThumbnailsTemp.Clear();

                foreach (var keyword in keywords)
                {
                    foreach (var thumbnail in DataList)
                    {
                        if (thumbnail.CompareData(keyword) == true)
                            _searchResultThumbnailsTemp.Add(thumbnail);
                    }

                    _searchResultThumbnails = _searchResultThumbnailsTemp.ToList();
                    _searchResultThumbnailsTemp.Clear();
                }
            }
            
            foreach (var thumbnail in _allThumbnails)
            {
                thumbnail.gameObject.SetActive(false);
            }

            foreach (var thumbnail in DataList)
            {
                thumbnail.gameObject.SetActive(true);
            }
        }

        private async void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OpenSeedDataListViewer:
                    gameObject.SetActive(true);
                    UpdateSeedDataList();
                    break;
                case EPixelArtEventID.CloseSeedDataListViewer:
                    gameObject.SetActive(false);
                    break;
                case EPixelArtEventID.AddItemToSeedDataListViewer:
                    {
                        var seedData = datas[0] as SeedData;
                        if (seedData == null)
                            return;

                        var seedDataThumbnail = GameObject.Instantiate(_thumbnailPrefab).GetComponent<SeedDataViewerItem>();
                        seedDataThumbnail.Initialize(_scrollRect, seedData);
                        seedDataThumbnail.transform.SetParent(_gridLayoutGropup.transform, false);
                        _allThumbnails.Add(seedDataThumbnail);
                    }
                    break;
                case EPixelArtEventID.UpdateSeedDataListViewer:
                    UpdateSeedDataList();
                    break;
                case EPixelArtEventID.FileDragDrop:
                    {
                        var paths = datas as string[];

                        _operationToolMode = true;

                        Release();
                        _cancellationToken = new CancellationTokenSource();

                        foreach (var dataPath in paths)
                        {
                            switch (Path.GetExtension(dataPath))
                            {
                                case GlobalValue._bytesExtension:
                                case GlobalValue._jsonExtension:
                                    {
                                        if (SeedData.LoadFromPath(dataPath, out var migrationUpdated, out var seedData) != EPixelCanvas_Result.Success)
                                            continue;

                                        var seedDataThumbnail = GameObject.Instantiate(_thumbnailPrefab).GetComponent<SeedDataViewerItem>();
                                        seedDataThumbnail.Initialize(_scrollRect, seedData);
                                        seedDataThumbnail.transform.SetParent(_gridLayoutGropup.transform, false);
                                        _allThumbnails.Add(seedDataThumbnail);

                                        await UniTask.NextFrame(cancellationToken: _cancellationToken.Token);
                                    }
                                    break;
                                case GlobalValue._zipExtension:
                                    {
                                        using ZipArchive archive = ZipFile.OpenRead(dataPath);
                                        {
                                            foreach (ZipArchiveEntry entry in archive.Entries)
                                            {
                                                if (entry.FullName.EndsWith(GlobalValue._bytesExtension, StringComparison.OrdinalIgnoreCase) == false)
                                                    continue;

                                                var allBytes = default(byte[]);
                                                using (Stream stream = entry.Open())
                                                {
                                                    using (MemoryStream ms = new MemoryStream())
                                                    {
                                                        stream.CopyTo(ms);
                                                        allBytes = ms.ToArray();
                                                    }
                                                }

                                                var parseResult = ByteDataParser.Instance.TryParseToSeedData(allBytes, out var _, out var seedData);
                                                if (parseResult != EPixelCanvas_Result.Success)
                                                {
                                                    seedData = null;
                                                    Debug.LogError($"Binary Parse Fail : {parseResult}");
                                                    continue;
                                                }

                                                var seedDataThumbnail = GameObject.Instantiate(_thumbnailPrefab).GetComponent<SeedDataViewerItem>();
                                                seedDataThumbnail.Initialize(_scrollRect, seedData);
                                                seedDataThumbnail.transform.SetParent(_gridLayoutGropup.transform, false);
                                                _allThumbnails.Add(seedDataThumbnail);

                                                await UniTask.NextFrame(cancellationToken: _cancellationToken.Token);
                                            }
                                        }
                                    }
                                    break;
                            }
                        }
                    }
                    break;
            }
        }
    }
}