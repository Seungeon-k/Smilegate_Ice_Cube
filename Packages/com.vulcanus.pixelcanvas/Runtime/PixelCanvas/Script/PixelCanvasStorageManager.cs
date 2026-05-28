using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.ResourceLocations;

namespace PixelCanvas
{
    public enum EPixelCanvas_Result
    {
        Success = 0,

        Error,
        Error_OutofStorage,                  // Available Storage Under 100mb
        Error_StorageRootNotFound,
        Error_InvalidGuid,
        Error_NotFound,
        Error_InvalidStoragePath,
        Error_TryingToDeleteOfficial,
        Error_HmacValidation,
        Error_DifferentGUID,
        Error_FileNotFound,
        Error_AddressablesNotFound,
        Error_InvalidPetName,
        Error_StringToJObject,
        Error_ByteToJObject,

        Error_VersionParse,
        Error_GetVersionString,
        Error_InvalidSeedDataType,
        Error_MigrateBaseData,
        Error_MigrateCanvasExtensionData,
        Error_MigratePetExtensionData,

        Error_TextureByte,
        Error_SaveFailure,
        Error_JsonParse,
        Error_BinaryParse,
        Error_JObjectToSeedData,
        Error_LoadImageSeed,
        Error_LoadImageUber,

        Error_AddressablesLoadFail,
        Error_IsNull,
        Error_OfficialSeedDataNotFound,
    }

    public class PixelCanvasStorageManager
    {
        public static PixelCanvasStorageManager Instance
        {
            get
            {
                if (GlobalValue.ApplicationIsQuitting == true)
                    return null;

                if (_instance == null)
                {
                    _instance = new PixelCanvasStorageManager();
                    _instance.Initialize();
                }

                return _instance;
            }
        }
        private static PixelCanvasStorageManager _instance;

        private Dictionary<Guid, string> _dicLocalSeedDataPath;

        private void Initialize()
        {
            GlobalValue.Initialize();
        }

        public static void Destroy()
        {
            _instance?.ReleaseSeedDatas();
            _instance = null;
            ByteDataParser.Instance.Destroy();
            DataVersionMigrator.Instance.Destroy();
        }

        public EPixelCanvas_Result StoreSeedDataFromJson(string jsonSeedData)
        {
            var stringToJObjectResult = jsonSeedData.TryParseJson(out var jObject);
            if (stringToJObjectResult != EPixelCanvas_Result.Success)
                return stringToJObjectResult;

            var jObjectToSeedDataResult = JsonDataParser.TryParseToSeedData(jObject, out var migrationUpdated, out var seedData);
            if (jObjectToSeedDataResult != EPixelCanvas_Result.Success)
                return jObjectToSeedDataResult;

            seedData._storagePath = Path.Combine(GlobalValue.GetLocalSeedDataPath(seedData._seedDataType), $"{seedData._guid}{GlobalValue._jsonExtension}");
            if (seedData.Save(EBitFlagSave.ForceGenerateThumbnail) == false)
                return EPixelCanvas_Result.Error_SaveFailure;

            return EPixelCanvas_Result.Success;
        }

        public EPixelCanvas_Result StoreSeedDataFromBytes(byte[] byteSeedData)
        {
            var parseResult = ByteDataParser.Instance.TryParseToSeedData(byteSeedData, out var migrationUpdated, out var seedData);
            if (parseResult != EPixelCanvas_Result.Success)
            {
                Debug.LogError("Binary Parse Fail");
                return parseResult;
            }

            seedData._storagePath = Path.Combine(GlobalValue.GetLocalSeedDataPath(seedData._seedDataType), $"{seedData._guid}{GlobalValue._bytesExtension}");
            if (seedData.Save(EBitFlagSave.ForceGenerateThumbnail) == false)
                return EPixelCanvas_Result.Error_SaveFailure;

            return EPixelCanvas_Result.Success;
        }

        public EPixelCanvas_Result StoreSeedDataFromByteString(string byteStringSeedData)
        {
            var bytes = Convert.FromBase64String(byteStringSeedData);
            return StoreSeedDataFromBytes(bytes);
        }

        public EPixelCanvas_Result TryGetInstantSeedDataThumbnail(string jsonSeedData, out Texture2D texture)
        {
            texture = null;

            var stringToJObjectResult = jsonSeedData.TryParseJson(out var jObject);
            if (stringToJObjectResult != EPixelCanvas_Result.Success)
            {
                Debug.LogError("Json Parse Fail");
                return stringToJObjectResult;
            }

            var result = JsonDataParser.TryParseToSeedData(jObject, out var migrationUpdated, out var seedData);
            if (result != EPixelCanvas_Result.Success)
                return result;

            seedData._storagePath = Path.Combine(GlobalValue.GetLocalSeedDataPath(seedData._seedDataType), $"{seedData._guid}{GlobalValue._jsonExtension}");

            texture = seedData.Thumbnail;
            return EPixelCanvas_Result.Success;
        }

        public Texture2D GetInstantSeedDataThumbnail(byte[] byteSeedData)
        {
            var parseResult = ByteDataParser.Instance.TryParseToSeedData(byteSeedData, out var migrationUpdated, out var seedData);
            if (parseResult != EPixelCanvas_Result.Success)
            {
                Debug.LogError($"Binary Parse Fail : {parseResult}");
                return null;
            }

            seedData._storagePath = Path.Combine(GlobalValue.GetLocalSeedDataPath(seedData._seedDataType), $"{seedData._guid}{GlobalValue._bytesExtension}");

            return seedData.Thumbnail;
        }

        public EPixelCanvas_Result TryGetEmptySeedDataThumbnail(ESeedDataType seedDataType, string modelDataName, out Texture2D emptyThumbnail)
        {
            var emptyThumbnailPath = GlobalValue.GetOfficialEmptyThumbnailPath(seedDataType, modelDataName);

            var location = default(IResourceLocation);
            var locations = Addressables.LoadResourceLocationsAsync(emptyThumbnailPath, typeof(Texture2D)).WaitForCompletion();
            if (locations.Count == 0)
            {
                emptyThumbnail = null;
                return EPixelCanvas_Result.Error_AddressablesNotFound;
            }

            location = locations[0];
            var assetHandle = Addressables.LoadAssetAsync<Texture2D>(location);
            emptyThumbnail = assetHandle.WaitForCompletion();
            return EPixelCanvas_Result.Success;
        }

        public EPixelCanvas_Result TryGetOfficialSeedDataThumbnail(ESeedDataType seedDataType, string modelDataName, string seedDataName, out Texture2D thumbnail)
        {
            var thumbnailPath = GlobalValue.GetOfficialThumbnailPath(seedDataType, modelDataName, seedDataName);

            var locations = Addressables.LoadResourceLocationsAsync(thumbnailPath, typeof(Texture2D)).WaitForCompletion();
            if (locations.Count == 0)
            {
                thumbnail = null;
                return EPixelCanvas_Result.Error_AddressablesNotFound;
            }

            var assetHandle = Addressables.LoadAssetAsync<Texture2D>(thumbnailPath);
            thumbnail = assetHandle.WaitForCompletion();
            return EPixelCanvas_Result.Success;
        }

        public Texture2D GetLocalSeedDataThumbnail(string strGuid)
        {
            if (Guid.TryParse(strGuid, out var guid) == false)
                return null;
            if (_dicLocalSeedDataPath.TryGetValue(guid, out var seedDataPath) == false)
            {
                var foundPaths = Directory.GetFiles(GlobalValue._localPixelCanvasPath, $"{guid.ToString()}{GlobalValue._bytesExtension}", SearchOption.AllDirectories);
                if (foundPaths.Length == 0)
                    return null;

                _dicLocalSeedDataPath.Add(guid, foundPaths[0]);
                seedDataPath = foundPaths[0];
            }

            var thumbnailPath = Path.Combine(Utility.GetParentDirectory(seedDataPath), "Thumbnail");
            thumbnailPath = Path.Combine(thumbnailPath, $"{Path.GetFileNameWithoutExtension(seedDataPath)}{GlobalValue._pngExtension}");

            if (File.Exists(thumbnailPath) == true)
            {
                // Thumbnail Texture Exists
                var bytes = File.ReadAllBytes(thumbnailPath);
                var thumbnail = new Texture2D(1, 1);
                thumbnail.name = Path.GetFileNameWithoutExtension(thumbnailPath);

                if (thumbnail.LoadImage(bytes, false) == true)
                    return thumbnail;
                return null;
            }
            else
            {
                //Generate Thumbnail from SeedData
                var result = SeedData.LoadFromPath(seedDataPath, out var migrationUpdated, out var seedData);
                if (result != EPixelCanvas_Result.Success)
                    return null;

                seedData.Save(EBitFlagSave.ForceGenerateThumbnail);
                return seedData.Thumbnail;
            }
        }

        public void LoadSeedDatas()
        {
            {
                //var targetLocator = Addressables.ResourceLocators.FirstOrDefault(locator => locator.LocatorId.Contains("PixelCanvas"));
                //foreach (var locator in Addressables.ResourceLocators)
                //{
                //    //var lo = locator.Locate("PixelCanvas", typeof(DefaultAsset), );
                //    //"Pet/Party_Pet_ChickenS1/Party_Pet_ChickenS1(Empty).png"

                //    if (locator.Locate("Pet/Party_Pet_ChickenS1", typeof(TextAsset), out var loca) == false)
                //        continue;

                //    foreach (var key in locator.Keys)
                //    {
                //        if (key is string keyString == false)
                //            continue;
                //        if (keyString.Contains("/") == false)
                //            continue;
                //        if (locator.Locate(key, typeof(ModelData), out IList<IResourceLocation> locations) == false)
                //            continue;

                //        var fileName = Path.GetFileNameWithoutExtension(locations[0].ToString());
                //    }
                //}
            }


            //Validate Local File Resources
            _dicLocalSeedDataPath = new Dictionary<Guid, string>();
            var seedDataPaths = Directory.GetFiles(GlobalValue._localPixelCanvasPath, GlobalValue._bytesSearchPattern, SearchOption.AllDirectories);
            foreach (var seedDataPath in seedDataPaths)
            {
                Register(seedDataPath);
            }

#if (UNITY_EDITOR && PIXELCANVAS_EDITOR)
            seedDataPaths = Directory.GetFiles(GlobalValue._editorSeedDataPath, GlobalValue._jsonSearchPattern, SearchOption.AllDirectories);
            foreach (var seedDataPath in seedDataPaths)
            {
                var result = SeedData.LoadFromPath(seedDataPath, out var migrationUpdated, out var seedData);
                switch (result)
                {
                    case EPixelCanvas_Result.Error_HmacValidation:
                        DeleteByPath(seedDataPath);
                        break;
                }
                if (result != EPixelCanvas_Result.Success)
                    continue;

                if (migrationUpdated == true)
                    seedData.Save(EBitFlagSave.ForceGenerateThumbnail);
                else
                    seedData.GetThumbnail(EBitFlagGenerateThumbnail.SaveToStorage);
            }
#else

#endif
            //Check SeedData & Thumbnail Pair
        }

        public void ReleaseSeedDatas()
        {
            _dicLocalSeedDataPath.Clear();
        }

        public EPixelCanvas_Result TryGetOfficialSeedData(ESeedDataType seedDataType, string officialModelDataName, string seedDataName, out SeedData seedData)
        {
#if (UNITY_EDITOR && PIXELCANVAS_EDITOR)
            return SeedData.LoadFromPath(Path.Combine(GlobalValue.GetEditorSeedDataDirectory(seedDataType), $"{seedDataName}{GlobalValue._jsonExtension}"), out var _, out seedData);
#else
            return SeedData.LoadFromAddressables(seedDataType, officialModelDataName, seedDataName, out var _, out seedData);
#endif
        }

        public bool TryGetLocalSeedData(Guid guid, out SeedData seedData)
        {
            if (_dicLocalSeedDataPath.TryGetValue(guid, out var seedDataPath) == false)
            {
                var foundPaths = Directory.GetFiles(GlobalValue._localPixelCanvasPath, $"{guid.ToString()}{GlobalValue._bytesExtension}", SearchOption.AllDirectories);
                if (foundPaths.Length == 0)
                {
                    seedData = null;
                    return false;
                }
                _dicLocalSeedDataPath.Add(guid, foundPaths[0]);
                seedDataPath = foundPaths[0];
            }

            var result = SeedData.LoadFromPath(seedDataPath, out var migrationUpdated, out seedData);
            if (result != EPixelCanvas_Result.Success)
            {
                DeleteByPath(seedDataPath);
                return false;
            }

            if (migrationUpdated == true)
                seedData.Save(EBitFlagSave.ForceGenerateThumbnail);

            return true;
        }

        public EPixelCanvas_Result TryGetPetSeedDataAsBytes(Guid guid, out byte[] bytes)
        {
            bytes = null;

            var path = Path.Combine(GlobalValue.GetLocalSeedDataPath(ESeedDataType.Pet), $"{guid.ToString()}{GlobalValue._bytesExtension}");
            if (File.Exists(path) == false)
                return EPixelCanvas_Result.Error_FileNotFound;

            bytes = File.ReadAllBytes(path);
            return EPixelCanvas_Result.Success;
        }

        public EPixelCanvas_Result TryGetPetSeedDataAsByteString(Guid guid, out string byteStringSeedData)
        {
            byteStringSeedData = string.Empty;

            var result = TryGetPetSeedDataAsBytes(guid, out var bytes);
            if (result != EPixelCanvas_Result.Success)
                return result;

            byteStringSeedData = Convert.ToBase64String(bytes);
            return EPixelCanvas_Result.Success;
        }

        public EPixelCanvas_Result Delete(SeedData seedData)
        {
            if (seedData == null)
                return EPixelCanvas_Result.Error_IsNull;

            return DeleteByPath(seedData._storagePath);
        }

        public EPixelCanvas_Result Delete(string strGuid)
        {
            if (Guid.TryParse(strGuid, out var guid) == false)
                return EPixelCanvas_Result.Error_InvalidGuid;

            if (_dicLocalSeedDataPath.TryGetValue(guid, out var seedDataPath) == false)
                return EPixelCanvas_Result.Error_NotFound;

            return DeleteByPath(seedDataPath);
        }

        public List<EPixelCanvas_Result> Delete(List<string> lstStrGuid)
        {
            var results = new List<EPixelCanvas_Result>();

            foreach (var strGuid in lstStrGuid)
                results.Add(Delete(strGuid));
            return results;
        }

        public EPixelCanvas_Result DeleteByPath(string path)
        {
            if (File.Exists(path) == true)
                File.Delete(path);

            var thumbnailPath = Path.Combine(Utility.GetParentDirectory(path), "Thumbnail");
            thumbnailPath = Path.Combine(thumbnailPath, $"{Path.GetFileNameWithoutExtension(path)}{GlobalValue._pngExtension}");
            if (File.Exists(thumbnailPath) == true)
                File.Delete(thumbnailPath);

            Unregister(path);

            return EPixelCanvas_Result.Success;
        }

        //public bool MoveSeedData(string oldPath, string newPath, SeedData seedData)
        //{
        //    if (File.Exists(oldPath) == false)
        //        return false;

        //    if (oldPath == newPath)
        //        return false;

        //    var directory = Path.GetDirectoryName(newPath);
        //    if (Directory.Exists(directory) == false)
        //        Directory.CreateDirectory(directory);

        //    File.Move(oldPath, newPath);
        //    Debug.LogError($"File Path Moved : {oldPath} -> {newPath}");

        //    seedData._storagePath = newPath;
        //    return true;
        //}

        public SeedData CopySeedData(SeedData seedData)
        {
            return seedData.GenerateClone();
        }

        public bool SaveSeedData(string path, SeedData seedData)
        {
            if (string.IsNullOrEmpty(path) == true)
                return false;

            var directory = Path.GetDirectoryName(path);
            if (Directory.Exists(directory) == false)
                Directory.CreateDirectory(directory);

            var extension = Path.GetExtension(path);
            switch (extension)
            {
                case GlobalValue._jsonExtension:
                    var json = JsonUtility.ToJson(seedData, true);
                    File.WriteAllText(path, json);
                    break;
                case GlobalValue._bytesExtension:
                    ByteDataParser.Instance.Save(seedData, path);
                    break;
                default:
                    return false;
            }
            seedData._storagePath = path;

            Register(path);

            EventManager.Notify(EPixelArtEventID.ShowToastMessage, "ID_Text_4089 "); //Canvas Saved;

#if UNITY_EDITOR
            UnityEditor.AssetDatabase.Refresh();
#endif
            return true;
        }

        public void Register(string path)
        {
            var strGuid = Path.GetFileNameWithoutExtension(path);
            if (Guid.TryParse(strGuid, out var guid) == false)
                return;

            _dicLocalSeedDataPath.TryAdd(guid, path);
        }

        public void Unregister(string path)
        {
            var strGuid = Path.GetFileNameWithoutExtension(path);
            if (Guid.TryParse(strGuid, out var guid) == false)
                return;

            if (_dicLocalSeedDataPath.ContainsKey(guid) == true)
                _dicLocalSeedDataPath.Remove(guid);
        }

        public void ValidateSeedDataList(ESeedDataType seedDataType, List<string> strGuids)
        {
            var path = string.Empty;
            switch (seedDataType)
            {
                case ESeedDataType.None:
                    break;
                case ESeedDataType.Canvas:
                    path = $"{Application.persistentDataPath}/PixelCanvas/Canvas";
                    break;
                case ESeedDataType.Pet:
                    path = $"{Application.persistentDataPath}/PixelCanvas/Pet";
                    break;
                case ESeedDataType.Costume:
                    path = $"{Application.persistentDataPath}/PixelCanvas/Costume";
                    break;
            }

            var hashValidGuids = new HashSet<string>(strGuids);
            var seedDataListChanged = false;

            var seedDataPaths = Directory.GetFiles(path, GlobalValue._bytesSearchPattern, SearchOption.AllDirectories);
            foreach (var seedDataPath in seedDataPaths)
            {
                var strGuid = Path.GetFileNameWithoutExtension(seedDataPath);
                if (hashValidGuids.Contains(strGuid) == true)
                    continue;

                Delete(strGuid);
                seedDataListChanged = true;
            }

            var thumbnailPaths = Directory.GetFiles(path, GlobalValue._pngSearchPattern, SearchOption.AllDirectories);
            foreach (var thumbnailPath in thumbnailPaths)
            {
                var strGuid = Path.GetFileNameWithoutExtension(thumbnailPath);
                if (hashValidGuids.Contains(strGuid) == true)
                    continue;

                File.Delete(thumbnailPath);
            }

            GlobalValue.Callback_OnSeedDataListValidated?.Invoke(seedDataListChanged);
        }

        public bool IsSeedDataStorageEmpty(ESeedDataType seedDataType)
        {
            //var seedDataPaths = Directory.GetFiles(GlobalValue.GetLocalSeedDataPath(seedDataType), GlobalValue._pngSearchPattern, SearchOption.AllDirectories);
            //foreach (var seedDataPath in seedDataPaths)
            //    return false;

            var seedDataPaths = Directory.GetFiles(GlobalValue.GetLocalSeedDataPath(seedDataType), GlobalValue._bytesSearchPattern, SearchOption.AllDirectories);
            foreach (var seedDataPath in seedDataPaths)
                return false;
            return true;
        }

        public EPixelCanvas_Result IsStorageAvailable()
        {
            var rootPath = Path.GetPathRoot(GlobalValue._localPixelCanvasPath);
            rootPath = rootPath.Replace('\\', '/');

            var toMb = 1024 * 1024;
            var availableStorageThreashold = toMb * 100; // 100mb

            var drives = DriveInfo.GetDrives();
            foreach (var drive in drives)
            {
                var rootDirectory = drive.RootDirectory.FullName.Replace('\\', '/');
                if (rootPath != rootDirectory)
                    continue;

                var availableFreeSpace = drive.AvailableFreeSpace / toMb;
                if (availableStorageThreashold < availableFreeSpace)
                {
                    return EPixelCanvas_Result.Success;
                }
                else
                {
                    Debug.LogError($"Available Storage Threashold Failed : {availableFreeSpace}mb");
                    return EPixelCanvas_Result.Error_OutofStorage;
                }
            }

            Debug.LogError($"No Storage found as : {rootPath}");
            return EPixelCanvas_Result.Error_StorageRootNotFound;
        }

        public void BackupAndDeleteSeedDataPath()
        {
            GlobalValue.Initialize();

            var itrtrFile = Directory.EnumerateFiles(GlobalValue._localPixelCanvasPath, "*.*", SearchOption.AllDirectories);
            if (itrtrFile.Any() == false)
                return;

            var dir = new DirectoryInfo(GlobalValue._localPixelCanvasPath);
            if (dir.Exists == true)
            {
                var utcNow = DateTime.UtcNow;
                var time = $"{utcNow:yy_MM_dd_HH_mm_ss_fff}";

                var newPath = Path.Combine(Application.persistentDataPath, $"PixelCanvas{time}");
                CopyDirectory(GlobalValue._localPixelCanvasPath, newPath);
                dir.Delete(true);
            }

            static void CopyDirectory(string sourceFolder, string destFolder)
            {
                if (Directory.Exists(destFolder) == false)
                    Directory.CreateDirectory(destFolder);

                var files = Directory.GetFiles(sourceFolder);
                var folders = Directory.GetDirectories(sourceFolder);

                foreach (string file in files)
                {
                    var name = Path.GetFileName(file);
                    var dest = Path.Combine(destFolder, name);
                    File.Copy(file, dest);
                }

                foreach (string folder in folders)
                {
                    var name = Path.GetFileName(folder);
                    var dest = Path.Combine(destFolder, name);
                    CopyDirectory(folder, dest);
                }
            }

        }
    }
}


/*
 
 
        //public Texture2D[] GetAllOfficialSeedDataThumbnail()
        //{
        //    var lstThumbnail = new List<Texture2D>();

        //    var locations = Addressables.LoadResourceLocationsAsync(GlobalValue._officialThumbnailLabel, typeof(Texture2D)).WaitForCompletion();
        //    foreach (IResourceLocation location in locations)
        //    {
        //        var assetHandle = Addressables.LoadAssetAsync<Texture2D>(location);
        //        var result = assetHandle.WaitForCompletion();
        //        lstThumbnail.Add(result);
        //    }
        //    return lstThumbnail.ToArray();
        //}


        //public Texture2D[] GetAllSeedDataThumbnails()
        //{
        //    var lstThumbnail = new List<Texture2D>();

        //    foreach (var seedDataPath in _dicLocalSeedDataPath)
        //    {
        //        seedDataPath;

        //        var thumbnail = seedData.Value.Thumbnail;
        //        if (thumbnail == null)
        //            continue;

        //        lstThumbnail.Add(thumbnail);
        //    }
        //    return lstThumbnail.ToArray();
        //}


        //public static async Task<T> AwaitTaskWithTimeout<T>(Task<T> task, TimeSpan timeout)
        //{
        //    var delayTask = Task.Delay(timeout);

        //    var completedTask = await Task.WhenAny(task, delayTask);

        //    if (completedTask == task)
        //        return await task; // Await the original task to get its result or propagate any exceptions.
        //    else
        //        throw new TimeoutException("The operation timed out.");
        //}
        //public async Task<Texture2D> GetOfficialSeedDataThumbnail_Async(ESeedDataType seedDataType, string seedDataName)
        public Texture2D GetOfficialSeedDataThumbnail_Async(ESeedDataType seedDataType, string seedDataName)
        {
            //Use '/' Separator on Addressables
            var path = $"{GlobalValue.GetOfficialThumbnailPath(seedDataType)}/{seedDataName}{GlobalValue._pngExtension}";
            var locations = Addressables.LoadResourceLocationsAsync(path, typeof(Texture2D)).WaitForCompletion();
            if (locations.Count == 0)
                return null;

            var assetHandle = Addressables.LoadAssetAsync<Texture2D>(path);
            return assetHandle.WaitForCompletion();

            ////Use '/' Separator on Addressables
            //var path = $"{GlobalValue.GetOfficialThumbnailPath(seedDataType)}/{seedDataName}{GlobalValue._pngExtension}";

            //var locationsHandle = Addressables.LoadResourceLocationsAsync(path, typeof(Texture2D));
            ////var locations = await locationsHandle.WithCancellation(cts.Token).AsTask();
            ////var locations = await AwaitTaskWithTimeout(locationsHandle.Task, TimeSpan.FromSeconds(5));
            ////var locations = locationsHandle.WaitForCompletion();
            //var locations = await locationsHandle.Task;
            //if (locations.Count == 0)
            //    return null;

            //var textureHandle = Addressables.LoadAssetAsync<Texture2D>(path);
            //var texture = await textureHandle.Task;
            ////var texture = await AwaitTaskWithTimeout(textureHandle.Task, TimeSpan.FromSeconds(5));
            //return texture;
        }


 
  //var locationsHandle = Addressables.LoadResourceLocationsAsync(GlobalValue._officialSeedDataLabel, typeof(TextAsset));
            //var locations = await locationsHandle.Task;
            //if (0 < locations.Count)
            //{
            //    var tasks = new List<UniTask>();

            //    foreach (var path in locationsHandle.Result)
            //    {
            //        var task = SeedData.LoadFromPath_Async(path).ContinueWith((asyncData) =>
            //        {
            //            if (asyncData.result != EPixelCanvas_Result.Success)
            //                return;

            //            var key = Path.GetFileNameWithoutExtension(asyncData.seedData._storagePath);
            //            if (_dicOfficialSeedData.ContainsKey(key) == false)
            //                _dicOfficialSeedData.Add(key, asyncData.seedData);
            //            else
            //                _dicOfficialSeedData[key] = asyncData.seedData;
            //        });
            //        tasks.Add(task);
            //        await UniTask.Yield();

            //        //var seedDataAsyncLoadData = await SeedData.LoadFromPath_Async(path);
            //        //if (seedDataAsyncLoadData.result != EPixelCanvas_Result.Success)
            //        //    continue;

            //        //var key = Path.GetFileNameWithoutExtension(seedDataAsyncLoadData.seedData._storagePath);
            //        //if (_dicOfficialSeedData.ContainsKey(key) == false)
            //        //    _dicOfficialSeedData.Add(key, seedDataAsyncLoadData.seedData);
            //        //else
            //        //    _dicOfficialSeedData[key] = seedDataAsyncLoadData.seedData;
            //    }
            //    await UniTask.WhenAll(tasks);
            //}
            ////Addressables.Release(locationsHandle);
 
 

            //var migratedFlag = false;
            //seedDataPaths = Directory.GetFiles(GlobalValue._localPixelCanvasPath, GlobalValue._bytesSearchPattern, SearchOption.AllDirectories);
            //foreach (var seedDataPath in seedDataPaths)
            //{
            //    var result = SeedData.LoadFromPath(seedDataPath, out var migrationUpdated, out var seedData);
            //    switch (result)
            //    {
            //        case EPixelCanvas_Result.Error_HmacValidation:
            //            DeleteByPath(seedDataPath);
            //            break;
            //    }
            //    if (result != EPixelCanvas_Result.Success)
            //        continue;

            //    migratedFlag |= migrationUpdated;
            //    if (migrationUpdated == true)
            //        seedData.Save(EBitFlagSave.ForceGenerateThumbnail);

            //    var key = new Guid(seedData._guid);
            //    if (_dicLocalSeedData.ContainsKey(key) == false)
            //        _dicLocalSeedData.Add(key, seedData);
            //    else
            //        _dicLocalSeedData[key] = seedData;

            //    await UniTask.Yield();
            //}

            //if (migratedFlag == true)
            //    GlobalValue.Callback_OnSeedDataSchemaUpdated?.Invoke();
 */