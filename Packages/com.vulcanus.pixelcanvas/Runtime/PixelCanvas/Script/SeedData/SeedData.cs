using System;
using System.IO;
using System.Runtime.InteropServices;

using Newtonsoft.Json.Linq;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.Experimental.Rendering;
using UnityEngine.ResourceManagement.ResourceLocations;

using Unity.Profiling;

using UnityEngine.ResourceManagement.AsyncOperations;

using Cysharp.Threading.Tasks;

#if UNITY_EDITOR
using UnityEditor;
#endif

namespace PixelCanvas
{
    public enum EUpscaleType : byte
    {
        None = 0,
        Xbrz = 1,
    }

    public enum EFilterMode : byte
    {
        Point = 0,
        Bilinear = 1,
    }

    [System.Flags]
    public enum EBitFlagSave
    {
        None = 0,
        ApplySeedTarget = 1 << 0,
        ForceGenerateThumbnail = 1 << 1,

        ALL = ~0
    }

    [System.Flags]
    public enum EBitFlagGenerateThumbnail
    {
        None = 0,
        ForceGenerate = 1 << 0,
        SaveToStorage = 1 << 1,

        ALL = ~0
    }

    // IMPORTANT. NEVER!! DO NOT CHANGE the order Of Properties
    // It is Serialized to SeedData based on current order.
    [Serializable]
    [StructLayout(LayoutKind.Sequential)]
    public abstract partial class SeedData
    {
        //Base Data
        public string _version;
        public bool _isOfficial;
        public string _guid;
        public string _modelDataName;
        public string _name;
        public string _author;
        public string _generatedDate;
        public string _lastModifiedDate;
        public string _sealedDate;

        //Seed Texture
        public EUpscaleType _upscaleType;
        public EFilterMode _filterMode;
        public byte _scale;
        public ushort _textureWidth;
        public ushort _textureHeight;
        public byte[] _seedTextureByte;

        //Uber Texture
        public ushort _uberTextureWidth;
        public ushort _uberTextureHeight;
        public byte[] _uberTextureByte;

        [NonSerialized] public ESeedDataType _seedDataType;
        [NonSerialized] public RenderTexture _seedTarget;
        [NonSerialized] public RenderTexture _originSeedTarget;
        [NonSerialized] public RenderTexture _uberTarget;
        [NonSerialized] public RenderTexture _originUberTarget;
        [NonSerialized] public string _storagePath;

        public int2 ScaledTextureSize
        {
            get
            {
                var scale = Math.Clamp(_scale, (byte)1, (byte)4);
                return new int2(_textureWidth * scale, _textureHeight * scale);
            }
        }

        public Texture2D Thumbnail
        {
            get
            {
                if (_thumbnail == null)
                    _thumbnail = GetThumbnail(EBitFlagGenerateThumbnail.None);
                return _thumbnail;
            }
        }
        private Texture2D _thumbnail;

        public ModelData ModelData
        {
            get
            {
                if (_modelDataHandle.IsValid() == false)
                {
                    var path = GlobalValue.GetModelDataPath(_seedDataType, _modelDataName);
                    var locations = Addressables.LoadResourceLocationsAsync(path, typeof(ModelData)).WaitForCompletion();
                    if (locations.Count == 0)
                    {
                        Debug.LogError($"Model Data Not Found : {path}");
                        return null;
                    }

                    _modelDataHandle = Addressables.LoadAssetAsync<ModelData>(path);
                    _modelData = _modelDataHandle.WaitForCompletion();
                }
                return _modelData;
            }
        }
        private ModelData _modelData;
        private AsyncOperationHandle<ModelData> _modelDataHandle;

        public static SeedData GenerateSeedData<T>(Texture2D baseTexture, Texture2D uberTexture) where T : SeedData, new()
        {
            var strGuid = Guid.NewGuid().ToString();
            var fileName = $"{strGuid}";
            var name = "NewCanvas";

            var seedData = new T();
            seedData._version = DataVersionMigrator.Instance.GetLatestVersion(seedData._seedDataType);
            seedData._isOfficial = false;
            seedData._guid = strGuid;
            seedData._name = name;
            seedData._author = "MISSING_NAME";
            seedData._generatedDate = Utility.GetUtcTime();
            seedData._lastModifiedDate = Utility.GetUtcTime();
            seedData._sealedDate = Utility.GetUtcTime();
            seedData._upscaleType = EUpscaleType.Xbrz;
            seedData._filterMode = EFilterMode.Bilinear;
            seedData._scale = 3;
            seedData._textureWidth = (baseTexture != null) ? (ushort)baseTexture.width : (ushort)64;
            seedData._textureHeight = (baseTexture != null) ? (ushort)baseTexture.height : (ushort)64;
            seedData._seedTextureByte = (baseTexture != null) ? baseTexture.EncodeToPNG() : new byte[0];

            seedData._uberTextureWidth = (uberTexture != null) ? (ushort)uberTexture.width : (ushort)64;
            seedData._uberTextureHeight = (uberTexture != null) ? (ushort)uberTexture.height : (ushort)64;
            seedData._uberTextureByte = (uberTexture != null) ? uberTexture.EncodeToPNG() : new byte[0];

            //Non-Serialized
            seedData._seedTarget = new RenderTexture(seedData._textureWidth, seedData._textureHeight, 0, GraphicsFormat.R8G8B8A8_SRGB);
            seedData._seedTarget.name = name;
            seedData._seedTarget.filterMode = FilterMode.Point;
            Graphics.Blit((baseTexture != null) ? baseTexture : Texture2D.whiteTexture, seedData._seedTarget);

            seedData._originSeedTarget = new RenderTexture(seedData._textureWidth, seedData._textureHeight, 0, GraphicsFormat.R8G8B8A8_SRGB);
            seedData._originSeedTarget.name = name;
            seedData._originSeedTarget.filterMode = FilterMode.Point;
            Graphics.Blit((baseTexture != null) ? baseTexture : Texture2D.whiteTexture, seedData._originSeedTarget);

            seedData.Initialize();
            seedData._storagePath = Path.Combine(GlobalValue.GetLocalSeedDataPath(seedData._seedDataType), $"{fileName}{GlobalValue._jsonExtension}");

            //Extension Data
            switch (seedData)
            {
                case SeedData_Canvas canvasSeedData:
                    {
                    }
                    break;

                case SeedData_Pet petSeedData:
                    {
                        petSeedData._modelDataName = "Party_Pet_Cat";
                    }
                    break;
                case SeedData_Costume costumeSeedData:
                    {
                        costumeSeedData._modelDataName = "Party_Penguin_Body_Marine";
                    }
                    break;
                default:
                    break;
            }

            return seedData;
        }

        public virtual void Initialize()
        {
            DataVersionMigrator.Instance.TryGetVersion(_version, out var seedDataType, out _, out _);
            _seedDataType = (ESeedDataType)seedDataType;
        }

        public virtual void Release()
        {
            UnloadTexture();

            _modelData = null;
            if (_modelDataHandle.IsValid() == true)
                _modelDataHandle.Release();
        }

        public void LoadTexture()
        {
            //Seed Texture
            var tempTexture2D = default(Texture2D);
            if (0 < _seedTextureByte.Length)
            {
                tempTexture2D = ResourceManager.Instance.GetTemporaryTexture2D(new int2(_textureWidth, _textureHeight));
                tempTexture2D.filterMode = FilterMode.Point;
                tempTexture2D.LoadImage(_seedTextureByte);
                tempTexture2D.Apply();

                _seedTarget = new RenderTexture(_textureWidth, _textureHeight, 0, GraphicsFormat.R8G8B8A8_SRGB);
                _seedTarget.name = "SeedTarget";
                _seedTarget.filterMode = FilterMode.Point;
                Graphics.Blit(tempTexture2D, _seedTarget);

                _originSeedTarget = new RenderTexture(_textureWidth, _textureHeight, 0, GraphicsFormat.R8G8B8A8_SRGB);
                _originSeedTarget.name = "OriginSeedTarget";
                _originSeedTarget.filterMode = FilterMode.Point;
                Graphics.Blit(tempTexture2D, _originSeedTarget);
            }

            //Uber Texture
            var uberTexture2D = default(Texture2D);
            if (0 < _uberTextureByte.Length)
            {
                uberTexture2D = ResourceManager.Instance.GetTemporaryTexture2D(new int2(_uberTextureWidth, _uberTextureHeight));
                uberTexture2D.filterMode = FilterMode.Point;
                uberTexture2D.LoadImage(_uberTextureByte);
                uberTexture2D.Apply();

                _uberTarget = new RenderTexture(_uberTextureWidth, _uberTextureHeight, 0, GraphicsFormat.R8G8B8A8_SRGB);
                _uberTarget.name = "UberTarget";
                _uberTarget.filterMode = FilterMode.Point;
                Graphics.Blit(uberTexture2D, _uberTarget);

                _originUberTarget = new RenderTexture(_uberTextureWidth, _uberTextureHeight, 0, GraphicsFormat.R8G8B8A8_SRGB);
                _originUberTarget.name = "OriginUberTarget";
                _originUberTarget.filterMode = FilterMode.Point;
                Graphics.Blit(uberTexture2D, _originUberTarget);
            }
        }

        public void UnloadTexture()
        {
            GameObject.DestroyImmediate(_seedTarget);
            _seedTarget = null;

            GameObject.DestroyImmediate(_originSeedTarget);
            _originSeedTarget = null;

            GameObject.DestroyImmediate(_uberTarget);
            _uberTarget = null;

            GameObject.DestroyImmediate(_originUberTarget);
            _originUberTarget = null;

            if (_isOfficial == false)
                GameObject.DestroyImmediate(_thumbnail);
            _thumbnail = null;
        }

        public void RevertToOriginTexture()
        {
            if (PixelCanvasStorageManager.Instance.TryGetOfficialSeedData(_seedDataType, _modelDataName, _name, out var officialSeedData) != EPixelCanvas_Result.Success)
            {
                //Revert to Origin Model SeedData on case Official SeedData Name Not found
                if (PixelCanvasStorageManager.Instance.TryGetOfficialSeedData(_seedDataType, _modelDataName, _modelDataName, out officialSeedData) != EPixelCanvas_Result.Success)
                    return;
            }

            officialSeedData.LoadTexture();
            Graphics.Blit(officialSeedData._originSeedTarget, ResourceManager.Instance.MergedTarget);
            EventManager.Notify(EPixelArtEventID.AddTaskCommand, new BrushCommand(ECanvasType.Albedo));
            EventManager.Notify(EPixelArtEventID.ShowToastMessage, "ID_Text_4090"); // "Initialized"
            EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
            officialSeedData.UnloadTexture();
        }

        public struct SeedDataResult_Async
        {
            public EPixelCanvas_Result result;
            public bool migrationUpdated;
            public SeedData seedData;
        }
        public static async UniTask<SeedDataResult_Async> LoadFromAddressables_Async(IResourceLocation path)
        {
            var textHandle = Addressables.LoadAssetAsync<TextAsset>(path);
            var textAsset = await textHandle.Task;
            if (textHandle.Status != UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationStatus.Succeeded)
            {
                Debug.LogError("SEEDDATA Error 311");
                return new SeedDataResult_Async { result = EPixelCanvas_Result.Error_AddressablesLoadFail };
            }

            using (new ProfilerMarker("LoadAsyncFromPath").Auto())
            {
                var stringPath = path.ToString();
                var extension = Path.GetExtension(stringPath.ToString());
                var strGuid = Path.GetFileNameWithoutExtension(stringPath);

                var seedData = default(SeedData);
                var migrationUpdated = false;
                switch (extension)
                {
                    case GlobalValue._jsonExtension:
                        using (new ProfilerMarker("JSON").Auto())
                        {
                            var stringToJObjectResult = textAsset.text.TryParseJson(out var jObject);
                            if (stringToJObjectResult != EPixelCanvas_Result.Success)
                            {
                                Debug.LogError("Json Parse Fail");
                                return new SeedDataResult_Async { result = stringToJObjectResult };
                            }
                            var result = JsonDataParser.TryParseToSeedData(jObject, out migrationUpdated, out seedData);
                            if (result != EPixelCanvas_Result.Success)
                                return new SeedDataResult_Async { result = result };

                            seedData._storagePath = stringPath;
                        }
                        break;
                    case GlobalValue._bytesExtension:
                        using (new ProfilerMarker("Bytes").Auto())
                        {
                            var byteAsset = textAsset.bytes;
                            var parseResult = ByteDataParser.Instance.TryParseToSeedData(byteAsset, out migrationUpdated, out seedData);
                            if (parseResult != EPixelCanvas_Result.Success)
                            {
                                Debug.LogError($"Binary Parse Fail : {parseResult}");
                                return new SeedDataResult_Async { result = parseResult };
                            }

                            seedData._storagePath = stringPath;
                        }
                        break;
                    default:
                        throw new InvalidOperationException($"Unexpected Extension Type: {extension}");
                }

                // No need to Check EPixelCanvas_Result.Error_DifferentGUID on Official SeedData 

                return new SeedDataResult_Async { result = EPixelCanvas_Result.Success, migrationUpdated = migrationUpdated, seedData = seedData };
            }
        }

        public static EPixelCanvas_Result LoadFromAddressables(ESeedDataType seedDataType, string officialModelDataName, string seedDataName, out bool migrationUpdated, out SeedData seedData)
        {
            var seedDataPath = GlobalValue.GetOfficialSeedDataPath(seedDataType, officialModelDataName, seedDataName);
            var seedDataLocations = Addressables.LoadResourceLocationsAsync(seedDataPath, typeof(TextAsset)).WaitForCompletion();
            if (seedDataLocations.Count == 0)
            {
                seedData = null;
                migrationUpdated = false;
                return EPixelCanvas_Result.Error_OfficialSeedDataNotFound;
            }

            var location = seedDataLocations[0];
            var textAsset = Addressables.LoadAssetAsync<TextAsset>(location).WaitForCompletion();
            var stringPath = location.ToString();
            var strGuid = Path.GetFileNameWithoutExtension(stringPath);
            var extension = Path.GetExtension(stringPath.ToString());

            switch (extension)
            {
                case GlobalValue._jsonExtension:
                    using (new ProfilerMarker("JSON").Auto())
                    {
                        var stringToJObjectResult = textAsset.text.TryParseJson(out var jObject);
                        if (stringToJObjectResult != EPixelCanvas_Result.Success)
                        {
                            Debug.LogError("Json Parse Fail");
                            seedData = null;
                            migrationUpdated = false;
                            return stringToJObjectResult;
                        }
                        var result = JsonDataParser.TryParseToSeedData(jObject, out migrationUpdated, out seedData);
                        if (result != EPixelCanvas_Result.Success)
                            return result;
                    }
                    break;
                case GlobalValue._bytesExtension:
                    using (new ProfilerMarker("Bytes").Auto())
                    {
                        var byteAsset = textAsset.bytes;
                        var parseResult = ByteDataParser.Instance.TryParseToSeedData(byteAsset, out migrationUpdated, out seedData);
                        if (parseResult != EPixelCanvas_Result.Success)
                        {
                            Debug.LogError($"Binary Parse Fail : {parseResult}");
                            return parseResult;
                        }
                    }
                    break;
                default:
                    throw new InvalidOperationException($"Unexpected Extension Type: {extension}");
            }

            // No need to Check EPixelCanvas_Result.Error_DifferentGUID on Official SeedData 

            return EPixelCanvas_Result.Success;
        }

        public static EPixelCanvas_Result LoadFromPath(string path, out bool migrationUpdated, out SeedData seedData)
        {
            migrationUpdated = false;

            if (File.Exists(path) == false)
            {
                seedData = null;
                Debug.LogError($"Save file not found - {path}");
                return EPixelCanvas_Result.Error_FileNotFound;
            }

            // File To JObject
            var jObject = default(JObject);
            var extension = Path.GetExtension(path);
            var strGuid = Path.GetFileNameWithoutExtension(path);
            switch (extension)
            {
                case GlobalValue._jsonExtension:
                    var jsonString = File.ReadAllText(path);
                    var stringToJObjectResult = jsonString.TryParseJson(out jObject);
                    if (stringToJObjectResult != EPixelCanvas_Result.Success)
                    {
                        seedData = null;
                        Debug.LogError($"Json Parse Fail - {path}");
                        return stringToJObjectResult;
                    }

                    var result = JsonDataParser.TryParseToSeedData(jObject, out migrationUpdated, out seedData);
                    if (result != EPixelCanvas_Result.Success)
                    {
                        return result;
                    }

                    break;
                case GlobalValue._bytesExtension:
                    var byteAsset = File.ReadAllBytes(path);
                    var parseResult = ByteDataParser.Instance.TryParseToSeedData(byteAsset, out migrationUpdated, out seedData);
                    if (parseResult != EPixelCanvas_Result.Success)
                    {
                        seedData = null;
                        Debug.LogError($"Binary Parse Fail : {parseResult}");
                        return parseResult;
                    }
                    break;
                default:
                    throw new InvalidOperationException($"Unexpected Extension Type: {extension}");
            }

            if (seedData._isOfficial == false && strGuid != seedData._guid)
            {
                Debug.LogError(seedData._guid);
                seedData = null;
                return EPixelCanvas_Result.Error_DifferentGUID;
            }

            seedData._storagePath = path;
            seedData.Initialize();
            return EPixelCanvas_Result.Success;
        }

        public bool Save(EBitFlagSave saveBitFlag = EBitFlagSave.ALL)
        {
#if !(UNITY_EDITOR && PIXELCANVAS_EDITOR)
            if (_isOfficial == true)
                return false;
#endif

            _lastModifiedDate = Utility.GetUtcTime();
            _sealedDate = Utility.GetUtcTime();

            if (saveBitFlag.Contains(EBitFlagSave.ApplySeedTarget) == true)
            {
                if (_seedTarget != null)
                {
                    var texture = _seedTarget.CloneToTexture2D();
                    _seedTextureByte = texture.EncodeToPNG();
                    GameObject.DestroyImmediate(texture);

                    _textureWidth = (ushort)_seedTarget.width;
                    _textureHeight = (ushort)_seedTarget.height;
                }
                else
                {
                    if (_seedTextureByte == null)
                        _seedTextureByte = new byte[0];
                    _textureWidth = 0;
                    _textureHeight = 0;
                }

                if (_uberTarget != null)
                {
                    var texture = _uberTarget.CloneToTexture2D();
                    _uberTextureByte = texture.EncodeToPNG();
                    GameObject.DestroyImmediate(texture);

                    _uberTextureWidth = (ushort)_uberTarget.width;
                    _uberTextureHeight = (ushort)_uberTarget.height;
                }
                else
                {
                    if (_uberTextureByte == null)
                        _uberTextureByte = new byte[0];
                    _uberTextureWidth = 0;
                    _uberTextureHeight = 0;
                }
            }

            var thumbnailBitFlag = EBitFlagGenerateThumbnail.SaveToStorage;
            if (saveBitFlag.Contains(EBitFlagSave.ForceGenerateThumbnail) == true)
                thumbnailBitFlag |= EBitFlagGenerateThumbnail.ForceGenerate;
            _thumbnail = GetThumbnail(thumbnailBitFlag);

            if (string.IsNullOrEmpty(_storagePath) == true)
            {
                Debug.LogError($"{_name} : StoragePath is Null");
                return false;
            }

            return PixelCanvasStorageManager.Instance.SaveSeedData(_storagePath, this);
        }

        public bool SaveBin(EBitFlagSave saveBitFlag = EBitFlagSave.ALL)
        {
            var binPath = Path.ChangeExtension(_storagePath, GlobalValue._bytesExtension);

            if (saveBitFlag.Contains(EBitFlagSave.ApplySeedTarget) == true)
            {
                if (_seedTarget != null)
                {
                    var texture = _seedTarget.CloneToTexture2D();
                    _seedTextureByte = texture.EncodeToPNG();
                    GameObject.DestroyImmediate(texture);
                }
                else
                {
                    if (_seedTextureByte == null)
                        _seedTextureByte = new byte[0];
                }

                if (_uberTarget != null)
                {
                    var texture = _uberTarget.CloneToTexture2D();
                    _uberTextureByte = texture.EncodeToPNG();
                    GameObject.DestroyImmediate(texture);
                }
                else
                {
                    if (_uberTextureByte == null)
                        _uberTextureByte = new byte[0];
                }
            }

            var thumbnailBitFlag = EBitFlagGenerateThumbnail.SaveToStorage;
            if (saveBitFlag.Contains(EBitFlagSave.ForceGenerateThumbnail) == true)
                thumbnailBitFlag |= EBitFlagGenerateThumbnail.ForceGenerate;
            _thumbnail = GetThumbnail(thumbnailBitFlag);

            if (string.IsNullOrEmpty(_storagePath) == true)
            {
                Debug.LogError($"{_name} : StoragePath is Null");
                return false;
            }

            return PixelCanvasStorageManager.Instance.SaveSeedData(binPath, this);
        }

        public SeedData GenerateClone(string newStrGuid = "")
        {
            if (string.IsNullOrEmpty(newStrGuid) == true)
                newStrGuid = Guid.NewGuid().ToString();

            var copiedSeedData = this.MemberwiseClone() as SeedData;
            copiedSeedData._guid = newStrGuid;

#if (UNITY_EDITOR && PIXELCANVAS_EDITOR)
            var extension = Path.GetExtension(_storagePath);
            var fileName = Utility.GetValidFileName(Path.GetDirectoryName(_storagePath), Path.GetFileNameWithoutExtension(_storagePath));
            copiedSeedData._isOfficial = true;
            copiedSeedData._name = fileName;
            copiedSeedData._author = "Official";
            copiedSeedData._storagePath = Path.Combine(GlobalValue.GetEditorSeedDataDirectory(_seedDataType), $"{fileName}{extension}");
#else
            var fileName = $"{newStrGuid}";
            copiedSeedData._isOfficial = false;
            copiedSeedData._storagePath = Path.Combine(GlobalValue.GetLocalSeedDataPath(_seedDataType), $"{newStrGuid}{GlobalValue._bytesExtension}");
#endif
            return copiedSeedData;
        }

        public Texture2D GetThumbnail(EBitFlagGenerateThumbnail bitFlag)
        {
            var thumbnailPath = string.Empty;
            var thumbnail = default(Texture2D);

#if (UNITY_EDITOR && PIXELCANVAS_EDITOR)
            if (_isOfficial == true)
                thumbnailPath = Path.Combine(GlobalValue.GetEditorThumbnailDirectory(_seedDataType), $"{Path.GetFileNameWithoutExtension(_storagePath)}{GlobalValue._pngExtension}");
            else
                thumbnailPath = Path.Combine(GlobalValue.GetLocalThumbnailPath(_seedDataType), $"{_guid}{GlobalValue._pngExtension}");
#else
            if (_isOfficial == true)
            {
                var result = PixelCanvasStorageManager.Instance.TryGetOfficialSeedDataThumbnail(_seedDataType, _modelDataName, Path.GetFileNameWithoutExtension(_storagePath), out thumbnail);
                return thumbnail;
            }
            else
                thumbnailPath = Path.Combine(GlobalValue.GetLocalThumbnailPath(_seedDataType), $"{_guid}{GlobalValue._pngExtension}");
#endif

            var modelData = ModelData;
            if (modelData == null)
                return ResourceManager.Instance.ErrorImage;

            if (bitFlag.Contains(EBitFlagGenerateThumbnail.ForceGenerate) == false)
            {
                if (File.Exists(thumbnailPath) == true)
                {
                    var bytes = File.ReadAllBytes(thumbnailPath);
                    thumbnail = new Texture2D(1, 1);
                    if (thumbnail.LoadImage(bytes, false) == true)
                    {
                        // 3byte integer(A"RGB")
                        var pixelByteData = thumbnail.GetPixelData<byte>(0);
                        var thumbnailVersion = (uint)((pixelByteData[1]) | (pixelByteData[2] << 8) | (pixelByteData[3] << 16));

                        if (thumbnailVersion != modelData._thumbnailVersion)
                        {
                            bitFlag |= EBitFlagGenerateThumbnail.SaveToStorage;
                            Debug.LogError($"Thumbnail Version Updated : {thumbnailPath}");
                        }
                        else
                        {
                            thumbnail.name = Path.GetFileNameWithoutExtension(thumbnailPath);
                            return thumbnail;
                        }
                    }
                }
            }
            var upscaleSeedDataResult = PixelUpscaler.UpscaleSeedData(this, out var upscaledSeedTexture, out var upscaledUberTexture, false);
            if (upscaleSeedDataResult != EPixelCanvas_Result.Success)
            {
                Debug.LogError($"{upscaleSeedDataResult} : Error On GenerateThumbnail");
                return ResourceManager.Instance.ErrorImage;
            }

            var material = VulcanusRPUtility.GenerateMaterial(EShaderType.SimpleLit, upscaledSeedTexture, upscaledUberTexture);

            var modelPosition = Vector3.zero;
            var modelMatrix = Matrix4x4.TRS(modelPosition, modelData._cameraTransform.Rotation, Vector3.one);
            var cameraOffsetDirection = math.normalize(ResourceManager.Instance._thumbnailCameraOffsetDirection);
            var cameraData = new VirtualCamera.VirtualCamera.CameraData
            {
                position = modelData._cameraTransform.Position,
                rotation = modelData._cameraTransform.Rotation,
                orthographic = false,
                orthographicSize = 1,
                fieldOfView = ResourceManager.Instance._thumbnailCameraFOV,
                nearClipPlane = 0.01f,
                farClipPlane = 30f,
                clearRenderTarget = true,
                clearColor = new Color(0, 0, 0, 0),
                renderTexture = ResourceManager.Instance.ThumbnailTarget,
                enablePostprocess = true,
            };

            //if (modelData._avatarPrefab != null)
            //{
            //    var seedData_Costume = this as SeedData_Costume;
            //    //seedData_Costume._partsType

            //    var instance = GameObject.Instantiate(modelData._avatarPrefab);
            //    instance.transform.Find("Party_Penguin_Head").gameObject.SetActive(false);
            //    instance.transform.Find("Party_Penguin_Body").gameObject.SetActive(false);
            //    instance.transform.Find("Party_Penguin_Foot").gameObject.SetActive(false);

            //    var costume = GameObject.Instantiate(modelData._modelPrefab);
            //    Utility.ValidateAnimatorBones(instance.transform, costume.transform);

            //    var renderers = instance.GetComponentsInChildren<Renderer>();
            //    VirtualCamera.BeginRender(cameraData, out var cmd);
            //    VirtualCamera.Render(cmd, renderers[0], new[] { material });
            //    VirtualCamera.EndRender(cmd);
            //}
            //else
            {
                VirtualCamera.VirtualCamera.BeginRender(out var cmd, cameraData);

                //Set Light Properties
                var dir = math.normalize(ResourceManager.Instance._thumbnailLightDirection);
                var lightPos = new Vector4(dir.x, dir.y, dir.z, 0.0f);
                var finalColor = new Color(1, 1, 1).linear;
                cmd.SetGlobalVector("_MainLightPosition", lightPos);
                cmd.SetGlobalColor("_MainLightColor", finalColor);

                var renderers = modelData._modelPrefab.GetComponentsInChildren<Renderer>();
                switch (_seedDataType)
                {
                    case ESeedDataType.Canvas:
                        {

                        }
                        break;
                    case ESeedDataType.Pet:
                        {
                            var materials = renderers[0].sharedMaterials;
                            for (var i = 0; i < materials.Length; ++i)
                                materials[i] = material;
                            VirtualCamera.VirtualCamera.Render(cmd, renderers[0], materials);
                        }
                        break;
                    case ESeedDataType.Costume:
                        {
                            //※ Multi-Material Issue
                            var costumeSeedData = this as SeedData_Costume;
                            var materials = renderers[0].sharedMaterials;

                            ////materials[0] = ResourceManager.Instance.DummyModelMaterial;
                            ////materials[1] = ResourceManager.Instance.DummyModelMaterial;
                            //materials[0] = null;
                            //materials[1] = ResourceManager.Instance.ModelInliningMaterial;
                            //VirtualCamera.Render(cmd, renderers[0], materials);
                            //cmd.ClearRenderTarget(true, false, Color.white);

                            if (1 < materials.Length)
                            {
                                for (var i = 0; i < materials.Length; ++i)
                                    materials[i] = material;
                                materials[0] = null;
                                //materials[0] = ResourceManager.Instance.DummyModelMaterial;
                            }
                            else
                            {
                                materials[0] = material;
                            }

                            //if (costumeSeedData._partsType == EPartsType.UpperBody)
                            //{
                            //    var head = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/AddressablesResources/PixelCanvas/Costume/Resource/Party_Penguin_Avatar/Party_Penguin_Head.prefab");
                            //    VirtualCamera.Render(cmd, head.GetComponentInChildren<Renderer>(), new Material[] { ResourceManager.Instance.DepthBakerMaterial });
                            //    materials[0] = ResourceManager.Instance.DepthBakerMaterial;
                            //}

                            VirtualCamera.VirtualCamera.Render(cmd, renderers[0], materials);
                        }
                        break;
                }

                VirtualCamera.VirtualCamera.EndRender(cmd, cameraData);
            }

            //R16G16B16A16_SFloat -> R8G8B8A8_SRGB Conversion
            var temp = RenderTexture.GetTemporary(256, 256, 0, GraphicsFormat.R8G8B8A8_SRGB, 1);
            temp.filterMode = FilterMode.Bilinear;
            temp.Create();

            Graphics.Blit(cameraData.renderTexture, temp);
            thumbnail = temp.CloneToTexture2D(TextureFormat.RGBA32);
            thumbnail.name = Path.GetFileNameWithoutExtension(thumbnailPath);
            RenderTexture.ReleaseTemporary(temp);

            //Transforming Thumbnail to Readable Texture
            if (thumbnail.LoadImage(thumbnail.EncodeToPNG(), false) == false)
                return ResourceManager.Instance.ErrorImage;

            // 3byte integer(A"RGB")
            var newBytes = thumbnail.GetPixelData<byte>(0);
            newBytes[0] = 0;                                                    // Alpha Must be Zero.
            newBytes[1] = (byte)(modelData._thumbnailVersion & 0xFF);           // R
            newBytes[2] = (byte)((modelData._thumbnailVersion >> 8) & 0xFF);    // G
            newBytes[3] = (byte)((modelData._thumbnailVersion >> 16) & 0xFF);   // B
            thumbnail.SetPixelData(newBytes, 0);

            thumbnail.name = Path.GetFileNameWithoutExtension(thumbnailPath);
            if (bitFlag.Contains(EBitFlagGenerateThumbnail.SaveToStorage) == true)
                thumbnail.Save(thumbnailPath);

            //Release
            GameObject.DestroyImmediate(material);

            return thumbnail;
        }

        public EPixelCanvas_Result TryGenerateMaterial(out Material material)
        {
            var upscaleResult = PixelUpscaler.UpscaleSeedData(this, out var upscaledSeedTexture, out var upscaledUberTexture, true);
            if (upscaleResult != EPixelCanvas_Result.Success)
            {
                material = null;
                return upscaleResult;
            }

            material = VulcanusRPUtility.GenerateMaterial(EShaderType.SimpleLit, upscaledSeedTexture, upscaledUberTexture);
            return EPixelCanvas_Result.Success;
        }
    }

#if UNITY_EDITOR
    public abstract partial class SeedData
    {
        //public ESeedDataFormat SeedDataFormat => (Path.GetExtension(_storagePath) == GlobalValue._jsonExtension) ? ESeedDataFormat.Json : ESeedDataFormat.Bytes;

        public virtual void DrawGUI()
        {
            EditorGUILayout.LabelField("Version", _version);
            _isOfficial = EditorGUILayout.Toggle("Official", _isOfficial);
            _modelDataName = EditorGUILayout.TextField("ModelData", _modelDataName);
            _name = EditorGUILayout.TextField("Name", _name);
            _author = EditorGUILayout.TextField("Author", _author);
            _upscaleType = (EUpscaleType)EditorGUILayout.EnumPopup("UpscaleType", _upscaleType);
            _filterMode = (EFilterMode)EditorGUILayout.EnumPopup("FilterMode", _filterMode);
            _scale = (byte)EditorGUILayout.IntSlider("Scale", _scale, 1, 4);

            EditorGUILayout.LabelField("Generated Time", Utility.ParseDateTime(_generatedDate).ToString());
            EditorGUILayout.LabelField("Last Modified Time", Utility.ParseDateTime(_lastModifiedDate).ToString());
            //EditorGUILayout.LabelField("Sealed Time", Utility.ParseDateTime(_selectedSeedData._sealedDate).ToString());

            EditorGUILayout.LabelField("Storage Path", _storagePath);
            EditorGUILayout.LabelField("Size", $"{_textureWidth} X {_textureHeight}");
            GUILayout.Space(10);
        }
    }
#endif

    public partial class ByteDataParser
    {
        private class SeedDataParser_Base : SeedDataParser
        {
            public override void Initialize()
            {
                if (_toJosonParser != null)
                    return;

                var version = 0;
                //=======================================================================================
                _toJosonParser = new Tuple<int, Action<JObject, BinaryReader>>[]
                {
                    Tuple.Create<int, Action<JObject, BinaryReader>>(
                        //0
                        version++,
                        (JObject jObject, BinaryReader reader) =>
                        {
                            jObject.Add("_version", reader.ReadString());
                            jObject.Add("_isOfficial", reader.ReadBoolean());
                            jObject.Add("_guid", reader.ReadString());
                            jObject.Add("_name", reader.ReadString());
                            jObject.Add("_author", reader.ReadString());
                            jObject.Add("_generatedDate", reader.ReadString());
                            jObject.Add("_lastModifiedDate", reader.ReadString());
                            jObject.Add("_sealedDate", reader.ReadString());
                            jObject.Add("_upscaleType", reader.ReadByte());
                            jObject.Add("_filterMode", reader.ReadByte());
                            jObject.Add("_scale", reader.ReadByte());
                            jObject.Add("_textureWidth", reader.ReadUInt16());
                            jObject.Add("_textureHeight", reader.ReadUInt16());
                            jObject.Add("_seedTextureByte", reader.ReadBytes(reader.ReadInt32()));
                        }
                    ),

                    Tuple.Create<int, Action<JObject, BinaryReader>>(
                        //1
                        version++,
                        (JObject jObject, BinaryReader reader) =>
                        {
                            jObject.Add("_version", reader.ReadString());
                            jObject.Add("_isOfficial", reader.ReadBoolean());
                            jObject.Add("_guid", reader.ReadString());
                            jObject.Add("_name", reader.ReadString());
                            jObject.Add("_author", reader.ReadString());
                            jObject.Add("_generatedDate", reader.ReadString());
                            jObject.Add("_lastModifiedDate", reader.ReadString());
                            jObject.Add("_sealedDate", reader.ReadString());
                            jObject.Add("_upscaleType", reader.ReadByte());
                            jObject.Add("_filterMode", reader.ReadByte());
                            jObject.Add("_scale", reader.ReadByte());
                            jObject.Add("_textureWidth", reader.ReadUInt16());
                            jObject.Add("_textureHeight", reader.ReadUInt16());
                            jObject.Add("_seedTextureByte", reader.ReadBytes(reader.ReadInt32()));
                        }
                    ),

                    Tuple.Create<int, Action<JObject, BinaryReader>>(
                        //2
                        version++,
                        (JObject jObject, BinaryReader reader) =>
                        {
                            jObject.Add("_version", reader.ReadString());
                            jObject.Add("_isOfficial", reader.ReadBoolean());
                            jObject.Add("_guid", reader.ReadString());
                            jObject.Add("_modelDataName", reader.ReadString());
                            jObject.Add("_name", reader.ReadString());
                            jObject.Add("_author", reader.ReadString());
                            jObject.Add("_generatedDate", reader.ReadString());
                            jObject.Add("_lastModifiedDate", reader.ReadString());
                            jObject.Add("_sealedDate", reader.ReadString());
                            jObject.Add("_upscaleType", reader.ReadByte());
                            jObject.Add("_filterMode", reader.ReadByte());
                            jObject.Add("_scale", reader.ReadByte());
                            jObject.Add("_textureWidth", reader.ReadUInt16());
                            jObject.Add("_textureHeight", reader.ReadUInt16());
                            jObject.Add("_seedTextureByte", reader.ReadBytes(reader.ReadInt32()));
                        }
                    ),

                    Tuple.Create<int, Action<JObject, BinaryReader>>(
                        //3
                        version++,
                        (JObject jObject, BinaryReader reader) =>
                        {
                            jObject.Add("_version", reader.ReadString());
                            jObject.Add("_isOfficial", reader.ReadBoolean());
                            jObject.Add("_guid", reader.ReadString());
                            jObject.Add("_modelDataName", reader.ReadString());
                            jObject.Add("_name", reader.ReadString());
                            jObject.Add("_author", reader.ReadString());
                            jObject.Add("_generatedDate", reader.ReadString());
                            jObject.Add("_lastModifiedDate", reader.ReadString());
                            jObject.Add("_sealedDate", reader.ReadString());
                            jObject.Add("_upscaleType", reader.ReadByte());
                            jObject.Add("_filterMode", reader.ReadByte());
                            jObject.Add("_scale", reader.ReadByte());
                            jObject.Add("_textureWidth", reader.ReadUInt16());
                            jObject.Add("_textureHeight", reader.ReadUInt16());
                            jObject.Add("_seedTextureByte", reader.ReadBytes(reader.ReadInt32()));
                            jObject.Add("_uberTextureWidth", reader.ReadUInt16());
                            jObject.Add("_uberTextureHeight", reader.ReadUInt16());
                            jObject.Add("_uberTextureByte", reader.ReadBytes(reader.ReadInt32()));
                        }
                    ),
                };
            }
        }
    }

    public partial class DataVersionMigrator
    {
        private class SeedDataMigrator_Base : SeedDataMigrator
        {
            public override void Initialize()
            {
                if (_updater != null)
                    return;

                //=======================================================================================
                _updater = new Func<JObject, bool>[]
                {
                    //Update 0 --> 1
                    (jObject) =>
                    {
                        if (jObject.GetData<string>("_generatedDate", out var _generatedDate) == true)
                        {
                            var time = DateTime.ParseExact(_generatedDate, "yyyy-MM-dd HH:mm:ss", null);
                            jObject["_generatedDate"] = time.ToString("yyMMddHH:mm:ss");
                        }
                        else
                            return false;

                        if (jObject.GetData<string>("_lastModifiedDate", out var _lastModifiedDate) == true)
                        {
                            var time = DateTime.ParseExact(_lastModifiedDate, "yyyy-MM-dd HH:mm:ss", null);
                            jObject["_lastModifiedDate"] = time.ToString("yyMMddHH:mm:ss");
                        }
                        else
                            return false;

                        if (jObject.GetData<string>("_sealedDate", out var _sealedDate) == true)
                        {
                            var time = DateTime.ParseExact(_sealedDate, "yyyy-MM-dd HH:mm:ss", null);
                            jObject["_sealedDate"] = time.ToString("yyMMddHH:mm:ss");
                        }
                        else
                            return false;

                        return true;
                    },

                    //Update 1 --> 2
                    (jObject) =>
                    {
                        if (jObject.GetData<ushort>("_meshType", out var _meshType) == true)
                        {
                            switch (_meshType)
                            {
                                case 0: jObject["_modelDataName"] = "Party_Pet_Cat";        break;
                                case 1: jObject["_modelDataName"] = "Party_Pet_Cat";        break;
                                case 2: jObject["_modelDataName"] = "Party_Pet_Puppy";      break;
                                case 3: jObject["_modelDataName"] = "Party_Pet_Alpaca";     break;
                                case 4: jObject["_modelDataName"] = "Party_Pet_Chicken";    break;
                                case 5: jObject["_modelDataName"] = "Party_Pet_Meerkat";    break;
                                case 6: jObject["_modelDataName"] = "Party_Pet_HarpSeal";   break;
                                case 7: jObject["_modelDataName"] = "Party_Pet_Lizard";     break;
                                case 8: jObject["_modelDataName"] = "Party_Pet_Duck";       break;
                                case 9: jObject["_modelDataName"] = "Party_Pet_PolarBear";  break;
                            }
                        }

                        if (jObject.GetData<string>("_prefabName", out var _prefabName) == true)
                        {
                            jObject["_modelDataName"] = _prefabName;
                        }
                        return true;
                    },

                    //Update 2 --> 3
                    (jObject) =>
                    {
                        if (jObject.GetData<ushort>("_textureWidth", out var _textureWidth) == true)
                        {
                            jObject["_uberTextureWidth"] = _textureWidth;
                        }

                        if (jObject.GetData<string>("_textureHeight", out var _textureHeight) == true)
                        {
                            jObject["_uberTextureHeight"] = _textureHeight;
                        }

                        jObject["_uberTextureByte"] = new byte[0];

                        return true;
                    },
                };
            }
        }

    }
}



/*

public struct SeedDataResult_Async
        {
            public EPixelCanvas_Result result;
            public bool migrationUpdated;
            public SeedData seedData;
        }
        public static void LoadAsyncFromPath(IResourceLocation path, Action<SeedDataResult_Async> callback)
        {
            Addressables.LoadAssetAsync<TextAsset>(path).Completed += (assetHandle) =>
            {
                using (new ProfilerMarker("LoadAsyncFromPath").Auto())
                {
                    if (assetHandle.Status != UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationStatus.Succeeded)
                    {
                        Debug.LogError("SEEDDATA Error 311");
                        return;
                    }

                    var textAsset = assetHandle.Result;
                    var stringPath = path.ToString();

                    var jObject = default(JObject);
                    var extension = Path.GetExtension(stringPath.ToString());
                    var strGuid = Path.GetFileNameWithoutExtension(stringPath);

                    SeedDataResult_Async resultData = new SeedDataResult_Async();
                    switch (extension)
                    {
                        case GlobalValue._jsonExtension:
                            using (new ProfilerMarker("JSON").Auto())
                            {
                                var stringToJObjectResult = textAsset.text.TryParseJson(out jObject);
                                if (stringToJObjectResult != EPixelCanvas_Result.Success)
                                {
                                    Debug.LogError("Json Parse Fail");
                                    resultData.result = stringToJObjectResult;
                                    callback?.Invoke(resultData);
                                    return;
                                }
                                var result = JsonDataParser.TryParseToSeedData(jObject, out resultData.migrationUpdated, out resultData.seedData);
                                if (result != EPixelCanvas_Result.Success)
                                {
                                    resultData.result = result;
                                    callback?.Invoke(resultData);
                                    return;
                                }
                            }
                            break;
                        case GlobalValue._bytesExtension:
                            using (new ProfilerMarker("Bytes").Auto())
                            {
                                var byteAsset = textAsset.bytes;
                                var parseResult = ByteDataParser.Instance.TryParseToSeedData(byteAsset, out resultData.migrationUpdated, out resultData.seedData);
                                if (parseResult != EPixelCanvas_Result.Success)
                                {
                                    Debug.LogError($"Binary Parse Fail : {parseResult}");
                                    callback?.Invoke(resultData);
                                    return;
                                }
                            }
                            break;
                        default:
                            throw new InvalidOperationException($"Unexpected Extension Type: {extension}");
                    }

                    if (strGuid != resultData.seedData._guid)
                    {
                        resultData.seedData = null;
                        resultData.result = EPixelCanvas_Result.Error_DifferentGUID;
                        return;
                    }

                    resultData.seedData._storagePath = stringPath;
                    resultData.result = EPixelCanvas_Result.Success;
                    callback?.Invoke(resultData);
                }
            };
        }

 
//public static EPixelCanvas_Result LoadFromPath(IResourceLocation path, out bool migrationUpdated, out SeedData seedData)
        //{
        //    migrationUpdated = false;

        //    var assetHandle = Addressables.LoadAssetAsync<TextAsset>(path);
        //    var textAsset = assetHandle.WaitForCompletion();
        //    var stringPath = path.ToString();

        //    var extension = Path.GetExtension(stringPath.ToString());
        //    switch (extension)
        //    {
        //        case GlobalValue._jsonExtension:
        //            var jObject = default(JObject);

        //            var stringToJObjectResult = textAsset.text.TryParseJson(out jObject);
        //            if (stringToJObjectResult != EPixelCanvas_Result.Success)
        //            {
        //                seedData = null;
        //                Debug.LogError("Json Parse Fail");
        //                return stringToJObjectResult;
        //            }
        //            var result = TryParseToSeedData(jObject, out migrationUpdated, out seedData);
        //            if (result != EPixelCanvas_Result.Success)
        //                return result;

        //            break;
        //        case GlobalValue._bytesExtension:
        //            var parseResult = textAsset.bytes.TryParseJson(out jObject);
        //            if (parseResult != EPixelCanvas_Result.Success)
        //            {
        //                seedData = null;
        //                Debug.LogError($"Binary Parse Fail : {parseResult}");
        //                return parseResult;
        //            }
        //            break;
        //    }


        //    seedData._storagePath = stringPath;
        //    return EPixelCanvas_Result.Success;
        //}


        //public static EPixelCanvas_Result TryParseData(byte[] byteSeedData, out bool migrationUpdated, out SeedData seedData)
        //{
        //    migrationUpdated = false;
        //    seedData = null;

        //    // Update Version Migration
        //    var migrationResult = DataVersionMigrator.Instance.Migrate(jObject, out var seedDataType, out var baseVersion, out var extensionVersion, out migrationUpdated);
        //    if (migrationResult != EPixelCanvas_Result.Success)
        //        return migrationResult;

        //    // JObject to SeedData
        //    try
        //    {
        //        switch ((ESeedDataType)seedDataType)
        //        {
        //            case ESeedDataType.Canvas:
        //                seedData = jObject.ToObject<SeedData_Canvas>();
        //                break;
        //            case ESeedDataType.Pet:
        //                seedData = jObject.ToObject<SeedData_Pet>();
        //                break;
        //            case ESeedDataType.Costume:
        //                seedData = jObject.ToObject<SeedData_Costume>();
        //                break;
        //            default:
        //                Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
        //                throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
        //        }
        //    }
        //    catch (Exception e)
        //    {
        //        Debug.LogError($"Error_JObjectToSeedData - {e}");
        //        return EPixelCanvas_Result.Error_JObjectToSeedData;
        //    }

        //    seedData.Initialize();
        //    return EPixelCanvas_Result.Success;
        //}

 //public static async UniTask<SeedDataResult_Async> LoadFromAddressables_Async(IResourceLocation path)
//{
//    var textHandle = Addressables.LoadAssetAsync<TextAsset>(path);
//    var textAsset = await textHandle.Task;
//    if (textHandle.Status != UnityEngine.ResourceManagement.AsyncOperations.AsyncOperationStatus.Succeeded)
//    {
//        Debug.LogError("SEEDDATA Error 311");
//        return new SeedDataResult_Async { result = EPixelCanvas_Result.Error_AddressablesLoadFail };
//    }

//    using (new ProfilerMarker("LoadAsyncFromPath").Auto())
//    {
//        var stringPath = path.ToString();
//        var extension = Path.GetExtension(stringPath.ToString());
//        var strGuid = Path.GetFileNameWithoutExtension(stringPath);

//        var seedData = default(SeedData);
//        var migrationUpdated = false;
//        switch (extension)
//        {
//            case GlobalValue._jsonExtension:
//                using (new ProfilerMarker("JSON").Auto())
//                {
//                    var stringToJObjectResult = textAsset.text.TryParseJson(out var jObject);
//                    if (stringToJObjectResult != EPixelCanvas_Result.Success)
//                    {
//                        Debug.LogError("Json Parse Fail");
//                        return new SeedDataResult_Async { result = stringToJObjectResult };
//                    }
//                    var result = JsonDataParser.TryParseToSeedData(jObject, out migrationUpdated, out seedData);
//                    if (result != EPixelCanvas_Result.Success)
//                        return new SeedDataResult_Async { result = result };

//                    seedData._storagePath = stringPath;
//                }
//                break;
//            case GlobalValue._bytesExtension:
//                using (new ProfilerMarker("Bytes").Auto())
//                {
//                    var byteAsset = textAsset.bytes;
//                    var parseResult = ByteDataParser.Instance.TryParseToSeedData(byteAsset, out migrationUpdated, out seedData);
//                    if (parseResult != EPixelCanvas_Result.Success)
//                    {
//                        Debug.LogError($"Binary Parse Fail : {parseResult}");
//                        return new SeedDataResult_Async { result = parseResult };
//                    }

//                    seedData._storagePath = stringPath;
//                }
//                break;
//            default:
//                throw new InvalidOperationException($"Unexpected Extension Type: {extension}");
//        }

//        if (strGuid != seedData._guid)
//        {
//            return new SeedDataResult_Async 
//            { 
//                result = EPixelCanvas_Result.Error_DifferentGUID, 
//                migrationUpdated = false, 
//                seedData = null 
//            };
//        }

//        return new SeedDataResult_Async { result = EPixelCanvas_Result.Success, migrationUpdated = migrationUpdated, seedData = seedData};
//    }
//}

 */

/*
 public static Texture2D GenerateThumbnail(Texture baseTexture, Texture uberTexture, ModelData modelData)
{
    var dir = math.normalize(ResourceManager.Instance._thumbnailLightDirection);
    var lightPos = new Vector4(dir.x, dir.y, dir.z, 0.0f);
    Shader.SetGlobalVector("_MainLightPosition", lightPos);
    var finalColor = new Color(1, 1, 1).linear;
    Shader.SetGlobalColor("_MainLightColor", finalColor);

    //var material = ResourceManager.Instance.ModelThumbnailMaterial;
    var material = ResourceManager.Instance.VulcanusMaterial;
    material.SetTexture(GlobalValue._BaseMap, baseTexture);
    material.SetTexture(GlobalValue._UberMap, uberTexture);

    if (uberTexture != null)
    {
        material.SetFloat("_Metallic", 1f);
        material.SetFloat("_Smoothness", 1f);
        material.SetFloat("_EmissionPower", 50f);
    }
    else
    {
        material.SetFloat("_Metallic", 0);
        material.SetFloat("_Smoothness", 0);
        material.SetFloat("_EmissionPower", 0);
    }
    VulcanusRPUtility.ValidateVulcanusMaterial(material);

    var modelPosition = Vector3.zero;
    var modelMatrix = Matrix4x4.TRS(modelPosition, modelData._cameraTransform.Rotation, Vector3.one);
    var cameraOffsetDirection = math.normalize(ResourceManager.Instance._thumbnailCameraOffsetDirection);
    var cameraData = new VirtualCamera.VirtualCamera.CameraData
    {
        position = modelData._cameraTransform.Position,
        rotation = modelData._cameraTransform.Rotation,
        orthographic = false,
        orthographicSize = 1,
        fieldOfView = ResourceManager.Instance._thumbnailCameraFOV,
        nearClipPlane = 0.01f,
        farClipPlane = 30f,
        clearRenderTarget = true,
        clearColor = new Color(0, 0, 0, 0),
        renderTexture = ResourceManager.Instance.ThumbnailTarget,
        enablePostprocess = true,
    };

    //if (modelData._avatarPrefab != null)
    //{
    //    var seedData_Costume = this as SeedData_Costume;
    //    //seedData_Costume._partsType

    //    var instance = GameObject.Instantiate(modelData._avatarPrefab);
    //    instance.transform.Find("Party_Penguin_Head").gameObject.SetActive(false);
    //    instance.transform.Find("Party_Penguin_Body").gameObject.SetActive(false);
    //    instance.transform.Find("Party_Penguin_Foot").gameObject.SetActive(false);

    //    var costume = GameObject.Instantiate(modelData._modelPrefab);
    //    Utility.ValidateAnimatorBones(instance.transform, costume.transform);

    //    var renderers = instance.GetComponentsInChildren<Renderer>();
    //    VirtualCamera.BeginRender(cameraData, out var cmd);
    //    VirtualCamera.Render(cmd, renderers[0], new[] { material });
    //    VirtualCamera.EndRender(cmd);
    //}
    //else
    {
        VirtualCamera.VirtualCamera.BeginRender(out var cmd, cameraData);
        var renderers = modelData._modelPrefab.GetComponentsInChildren<Renderer>();

        switch (modelData._seedDataType)
        {
            case ESeedDataType.Canvas:
                {

                }
                break;
            case ESeedDataType.Pet:
                {
                    var materials = renderers[0].sharedMaterials;
                    for (var i = 0; i < materials.Length; ++i)
                        materials[i] = material;
                    VirtualCamera.VirtualCamera.Render(cmd, renderers[0], materials);
                }
                break;
            case ESeedDataType.Costume:
                {
                    ////※ Multi-Material Issue
                    ////var costumeSeedData = this as SeedData_Costume;
                    //var materials = renderers[0].sharedMaterials;

                    //////materials[0] = ResourceManager.Instance.DummyModelMaterial;
                    //////materials[1] = ResourceManager.Instance.DummyModelMaterial;
                    ////materials[0] = null;
                    ////materials[1] = ResourceManager.Instance.ModelInliningMaterial;
                    ////VirtualCamera.Render(cmd, renderers[0], materials);
                    ////cmd.ClearRenderTarget(true, false, Color.white);

                    //if (1 < materials.Length)
                    //{
                    //    for (var i = 0; i < materials.Length; ++i)
                    //        materials[i] = material;
                    //    materials[0] = null;
                    //    //materials[0] = ResourceManager.Instance.DummyModelMaterial;
                    //}
                    //else
                    //{
                    //    materials[0] = material;
                    //}

                    ////if (costumeSeedData._partsType == EPartsType.UpperBody)
                    ////{
                    ////    var head = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/AddressablesResources/PixelCanvas/Costume/Resource/Party_Penguin_Avatar/Party_Penguin_Head.prefab");
                    ////    VirtualCamera.Render(cmd, head.GetComponentInChildren<Renderer>(), new Material[] { ResourceManager.Instance.DepthBakerMaterial });
                    ////    materials[0] = ResourceManager.Instance.DepthBakerMaterial;
                    ////}

                    //VirtualCamera.VirtualCamera.Render(cmd, renderers[0], materials);
                }
                break;
        }

        VirtualCamera.VirtualCamera.EndRender(cmd, cameraData);
    }

    //R16G16B16A16_SFloat -> R8G8B8A8_SRGB Conversion
    var temp = RenderTexture.GetTemporary(256, 256, 0, GraphicsFormat.R8G8B8A8_SRGB, 4);
    temp.Create();
    Graphics.Blit(cameraData.renderTexture, temp);
    var thumbnail = temp.CloneToTexture2D(TextureFormat.ARGB32);
            
    RenderTexture.ReleaseTemporary(temp);

    //Transforming Thumbnail to Readable Texture
    thumbnail.LoadImage(thumbnail.EncodeToPNG(), false);

    // 3byte integer(A"RGB")
    var newBytes = thumbnail.GetPixelData<byte>(0);
    newBytes[0] = 0; //Alpha Must be Zero.
    newBytes[1] = (byte)(modelData._thumbnailVersion & 0xFF);           // R
    newBytes[2] = (byte)((modelData._thumbnailVersion >> 8) & 0xFF);    // G
    newBytes[3] = (byte)((modelData._thumbnailVersion >> 16) & 0xFF);   // B
    thumbnail.SetPixelData(newBytes, 0);

    return thumbnail;
}
 */