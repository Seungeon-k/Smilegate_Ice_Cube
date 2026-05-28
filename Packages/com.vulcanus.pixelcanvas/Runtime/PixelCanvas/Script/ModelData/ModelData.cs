using System;

using Unity.Mathematics;

using UnityEngine;

using System.IO;

using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

using System.Collections.Generic;
using Unity.Collections;


#if UNITY_EDITOR
using UnityEditor.SceneManagement;
using UnityEditor;
#endif

namespace PixelCanvas
{
    [Serializable]
    public struct TransformData
    {
        public TransformData(Transform transform) : this()
        {
            Position = transform.position;
            Rotation = transform.rotation;
            Scale = transform.localScale;
        }
        public Vector3 Position;
        public Quaternion Rotation;
        public Vector3 Scale;
    }

    [Serializable]
    public class PixelPartition
    {
        public string _name;
        public RectInt _partition;
    }

    [Serializable]
    public partial class Partition
    {
        public string _name;
        public Rect _normPartition;
    }

    [CreateAssetMenu(fileName = "New ModelData", menuName = "PixelCanvas/ModelData", order = 1)]
    [Serializable]
    public partial class ModelData : ScriptableObject
    {
        public ESeedDataType _seedDataType;

        public GameObject _avatarPrefab;
        public GameObject _modelPrefab;

        public Texture _uvOutlineTexture;
        public uint _thumbnailVersion;

        public Vector3 _modelPivot;
        public TransformData _cameraTransform;

        [InspectorReadOnly] public Partition[] _partitions;
    }

#if UNITY_EDITOR
    public class CustomMenu
    {
        [MenuItem("Assets/Create/PixelCanvas/FBX --> ModelData")]
        private static void EditAsset()
        {
            var selectedAsset = Selection.activeObject;
            if (selectedAsset == null)
                return;
            var fbxPath = AssetDatabase.GetAssetPath(selectedAsset);
            if (Path.GetExtension(fbxPath) != GlobalValue._fbxExtension)
                return;

            var name = Path.GetFileNameWithoutExtension(fbxPath);
            var resourcePath = Path.GetDirectoryName(fbxPath);

            if (name != Path.GetFileNameWithoutExtension(Directory.GetParent(fbxPath).FullName))
            {
                resourcePath = Path.Combine("Assets", Path.GetRelativePath(Application.dataPath, resourcePath));
                resourcePath = Path.Combine(resourcePath, name);
                if (Directory.Exists(resourcePath) == false)
                {
                    Directory.CreateDirectory(resourcePath);
                    AssetDatabase.Refresh();
                }

                var newFbxPath = Path.Combine(resourcePath, $"{name}{GlobalValue._fbxExtension}");
                var error = AssetDatabase.MoveAsset(fbxPath, newFbxPath);
                if (!string.IsNullOrEmpty(error))
                {
                    Debug.LogError($"Failed to move asset: {error}");
                    return;
                }
                AssetDatabase.Refresh();
            }

            var modelData = ScriptableObject.CreateInstance<ModelData>();
            modelData.name = name;
            AssetDatabase.CreateAsset(modelData, Path.Combine(resourcePath, $"{name}{GlobalValue._assetExtension}"));
            AssetDatabase.Refresh();
            modelData.GenerateRuntimeData();
        }
    }

    public partial class ModelData
    {
        [Space(30)]
        [Header("Editor Properties")]
        public GameObject _modelFBX;
        public PixelPartition[] _pixelPartitions;
        public Texture _uvOutlineTexture_Origin;
        public Texture2D _emptyThumbnail;

        public static Material ColorMaterial
        {
            get
            {
                if (_colorMaterial == null)
                {
                    var shader = Shader.Find("Hidden/Internal-Colored");
                    _colorMaterial = new Material(shader);
                    _colorMaterial.hideFlags = HideFlags.HideAndDontSave;
                    _colorMaterial.SetInt("_SrcBlend", (int)BlendMode.One);
                    _colorMaterial.SetInt("_DstBlend", (int)BlendMode.Zero);
                    _colorMaterial.SetInt("_Cull", (int)CullMode.Back);
                    _colorMaterial.SetInt("ZWrite", 0);
                }
                return _colorMaterial;
            }
        }
        private static Material _colorMaterial;

        private static Dictionary<string, string> PartsToTextKey
        {
            get
            {
                if (_partsToTextKey == null)
                {
                    _partsToTextKey = new Dictionary<string, string>
                    {
                        { "All",         "ID_Text_4097"},
                        { "Accessory",   "ID_Text_4098"},
                        { "Arm",         "ID_Text_4099"},
                        { "Mouth",       "ID_Text_4100"},
                        { "Body",        "ID_Text_4101"},
                        { "Clothes",     "ID_Text_4102"},
                        { "Detail",      "ID_Text_4103"},
                        { "Ear",         "ID_Text_4104"},
                        { "Eye",         "ID_Text_4105"},
                        { "Face",        "ID_Text_4106"},
                        { "Head",        "ID_Text_4107"},
                        { "Leg",         "ID_Text_4108"},
                        { "Tail",        "ID_Text_4109"},
                        { "Hair",        "ID_Text_4110"},
                        { "Wing",        "ID_Text_4111"},
                        { "Horn",        "ID_Text_4112"},
                    };
                }
                return _partsToTextKey;
            }
        }
        private static Dictionary<string, string> _partsToTextKey;


        public virtual void Initialize()
        {
            if (_pixelPartitions != null && _pixelPartitions.Length != 0)
                return;

            _pixelPartitions = new PixelPartition[] {
                new PixelPartition
                {
                    _name = "All",
                    _partition = new RectInt(0, 0, 64, 64)
                }
            };
        }

        public void SetCameraTransform(Transform transform)
        {
            _cameraTransform = new TransformData(transform);
        }

        //[Button]
        public void GenerateRuntimeData()
        {
            var modelDataPath = AssetDatabase.GetAssetPath(this);
            var modelDataDirectory = Path.GetDirectoryName(modelDataPath);
            var editorPath = Path.Combine(modelDataDirectory, "Editor");

            var categoryName = Path.GetFileNameWithoutExtension(Utility.GetParentDirectory(modelDataPath));
            switch (categoryName)
            {
                case "Canvas":
                    _seedDataType = ESeedDataType.Canvas;
                    break;
                case "Costume":
                    _seedDataType = ESeedDataType.Costume;
                    break;
                case "Pet":
                    _seedDataType = ESeedDataType.Pet;
                    break;
                default:
                    EditorUtility.DisplayDialog("부적절한 ModelData 경로", $"적합한 경로 변경 필요", "OK");
                    return;
            }

            if (Directory.Exists(editorPath) == false)
            {
                Directory.CreateDirectory(editorPath);
                AssetDatabase.Refresh();
            }
            var seedDataPath = Path.Combine(modelDataDirectory, "SeedData");
            if (Directory.Exists(seedDataPath) == false)
            {
                Directory.CreateDirectory(seedDataPath);
                AssetDatabase.Refresh();
            }

            if (GenerateNormalizedPartition() == false)
                return;

            GenerateModelPrefab();
            if (_modelPrefab == null)
            {
                Debug.LogError("<color=red>ModelPrefab Missing</color>");
                return;
            }

            GenerateEmptyThumbnail();
            GenerateSDFOutline();

            EditorUtility.SetDirty(this);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            Debug.Log($"<color=green>[{name}] Validation Successed</color>");
        }

        private bool GenerateModelPrefab()
        {
            if (name.Contains("New ModelData"))
            {
                EditorUtility.DisplayDialog("부적절한 ModelData 이름", $"적합한 Pet이름으로 변경 필요", "OK");
                return false;
            }

            var modelDataPath = AssetDatabase.GetAssetPath(this);
            var resourceDirectory = Path.GetDirectoryName(modelDataPath);

            var modelFBXPath = Path.Combine(resourceDirectory, $"{name}{GlobalValue._fbxExtension}");
            _modelFBX = AssetDatabase.LoadAssetAtPath<GameObject>(modelFBXPath);

            var impoerter = AssetImporter.GetAtPath(modelFBXPath) as ModelImporter;
            if (impoerter != null)
            {
                impoerter.isReadable = true;
                impoerter.SaveAndReimport();
            }

            if (_modelFBX == null)
            {
                EditorUtility.DisplayDialog("Missing Resource", $"{modelFBXPath} FBX 없음", "OK");
                return false;
            }

            var modelPrefabPath = Path.Combine(resourceDirectory, $"{name}{GlobalValue._prefabExtension}");
            if (AssetDatabase.LoadAssetAtPath<GameObject>(modelPrefabPath) == null)
            {
                var originModelPrefab = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/AddressablesResources/PixelCanvas/Common/ModelPrefab.prefab");
                var instance = PrefabUtility.InstantiatePrefab(originModelPrefab) as GameObject;
                _modelPrefab = PrefabUtility.SaveAsPrefabAssetAndConnect(instance, modelPrefabPath, InteractionMode.AutomatedAction);
                GameObject.DestroyImmediate(instance);
            }

            PrefabStageUtility.OpenPrefab(modelPrefabPath);
            {
                var loadedPrefab = PrefabStageUtility.GetCurrentPrefabStage().prefabContentsRoot;

                var thumbnailCameraHandle = loadedPrefab.GetComponentInChildren<ThumbnailCameraHandle>();
                thumbnailCameraHandle.ModelData = this;

                var modelFBXInstance = default(GameObject);
                var model = loadedPrefab.transform.Find("ModelFBX");
                if (model == null)
                {
                    modelFBXInstance = PrefabUtility.InstantiatePrefab(_modelFBX, loadedPrefab.transform) as GameObject;
                    modelFBXInstance.name = "ModelFBX";
                    thumbnailCameraHandle.ModelFBX = modelFBXInstance;
                }
                else
                {
                    thumbnailCameraHandle.ModelFBX = model.gameObject;
                    modelFBXInstance = model.gameObject;
                    if (PrefabUtility.GetCorrespondingObjectFromSource(model).gameObject != _modelFBX)
                    {
                        GameObject.DestroyImmediate(model.gameObject);
                        modelFBXInstance = PrefabUtility.InstantiatePrefab(_modelFBX, loadedPrefab.transform) as GameObject;
                        modelFBXInstance.name = "ModelFBX";
                        thumbnailCameraHandle.ModelFBX = modelFBXInstance;
                    }
                }

                //Set Vulcanus Shader Material to Renderers(Avoid Mesh Stripping)
                var renderers = modelFBXInstance.GetComponentsInChildren<Renderer>();
                foreach (var renderer in renderers)
                {
                    var materials = renderer.sharedMaterials;
                    for (var i = 0; i < materials.Length; ++i)
                    {
                        materials[i] = ResourceManager.Instance.ModelPrefabMaterial;
                    }
                    renderer.sharedMaterials = materials;
                }

                _modelPrefab = PrefabUtility.SaveAsPrefabAssetAndConnect(loadedPrefab, modelPrefabPath, InteractionMode.AutomatedAction);
            }
            StageUtility.GoBackToPreviousStage();

            Selection.activeObject = this;
            return true;
        }

        private bool GenerateNormalizedPartition()
        {
            var seedTextureSize = new int2(_pixelPartitions[0]._partition.size.x, _pixelPartitions[0]._partition.size.y);

            //Genereate Normalized Partition
            _partitions = new Partition[_pixelPartitions.Length];
            for (var i = 0; i < _pixelPartitions.Length; ++i)
            {
                var partitionPos = new float2(_pixelPartitions[i]._partition.position.x, _pixelPartitions[i]._partition.position.y);
                var partitionSize = new float2(_pixelPartitions[i]._partition.size.x, _pixelPartitions[i]._partition.size.y);

                if (partitionPos.x < 0 || seedTextureSize.x <= partitionPos.x)
                {
                    Debug.LogError($"Invalid Partition Data : - {name} - {_pixelPartitions[i]._name}\nX Verticies");
                    return false;
                }

                if (partitionPos.x + partitionSize.x < 0 || seedTextureSize.x < partitionPos.x + partitionSize.x)
                {
                    Debug.LogError($"Invalid Partition Data : - {name} - {_pixelPartitions[i]._name}\nWidth");
                    return false;
                }

                if (partitionPos.y < 0 || seedTextureSize.y <= partitionPos.y)
                {
                    Debug.LogError($"Invalid Partition Data : - {name} - {_pixelPartitions[i]._name}\nY Verticies");
                    return false;
                }

                if (partitionPos.y + partitionSize.y < 0 || seedTextureSize.y < partitionPos.y + partitionSize.y)
                {
                    Debug.LogError($"Invalid Partition Data : - {name} - {_pixelPartitions[i]._name}\nHeight");
                    return false;
                }

                _partitions[i] = new Partition();

                var parseResult = ParseNameToKey(_pixelPartitions[i]._name, out var key);
                if (parseResult != ENameToKeyParseResult.Success)
                    return false;

                _partitions[i]._name = key;
                var normPartition = new Rect(partitionPos / seedTextureSize, partitionSize / seedTextureSize);
                _partitions[i]._normPartition = normPartition;

            }
            return true;

            static ENameToKeyParseResult ParseNameToKey(in string partsName, out string key)
            {
                var splitResult = partsName.Split('_');
                if (0 == splitResult.Length)
                {
                    key = null;
                    EditorUtility.DisplayDialog("부적절한 Partition 이름", $"{ENameToKeyParseResult.Fail_SplitCountIsZero}\n[{partsName}]", "OK");
                    return ENameToKeyParseResult.Fail_SplitCountIsZero;
                }

                if (PartsToTextKey.TryGetValue(splitResult[0], out key) == false)
                {
                    key = null;
                    EditorUtility.DisplayDialog("부적절한 Partition 이름", $"{ENameToKeyParseResult.Fail_NameNotFound}\n[{partsName}]", "OK");
                    return ENameToKeyParseResult.Fail_NameNotFound;
                }

                for (var i = 1; i < splitResult.Length; ++i)
                {
                    if (int.TryParse(splitResult[i], out var number) == false)
                    {
                        key = null;
                        EditorUtility.DisplayDialog("부적절한 Partition 이름", $"{ENameToKeyParseResult.Fail_NumberParse}\n[{partsName}]", "OK");
                        return ENameToKeyParseResult.Fail_NumberParse;
                    }
                    key += $"@{splitResult[i]}";
                }

                return ENameToKeyParseResult.Success;
            }
        }

        enum ENameToKeyParseResult
        {
            Success,
            Fail_SplitCountIsZero,
            Fail_NameNotFound,
            Fail_NumberParse,
        }

        private void GenerateEmptyThumbnail()
        {
            var resourceManager = ResourceManager.Instance;

            var baseTarget = RenderTexture.GetTemporary(resourceManager.ThumbnailTarget.descriptor);
            baseTarget.name = nameof(baseTarget);
            var blurTarget = RenderTexture.GetTemporary(resourceManager.ThumbnailTarget.descriptor);
            blurTarget.name = nameof(blurTarget);
            var targetThumbnail = RenderTexture.GetTemporary(resourceManager.ThumbnailTarget.descriptor);
            targetThumbnail.name = nameof(targetThumbnail);

            //VirtualCamera.RenderMesh(
            //    new VirtualCamera.CameraData
            //    {
            //        position = _cameraTransform.Verticies,
            //        rotation = _cameraTransform.Rotation,
            //        orthographic = false,
            //        orthographicSize = 1,
            //        fieldOfView = 60,
            //        nearClipPlane = 0.01f,
            //        farClipPlane = 30f,
            //        clearColor = new Color(0, 0, 0, 0.0f),
            //        renderTexture = baseTarget
            //    },
            //    _mesh, resourceManager.ModelThumbnailMaterial, Quaternion.identity, null, 1);

            var instance = GameObject.Instantiate(_modelPrefab);
            var renderers = instance.GetComponentsInChildren<Renderer>();
            foreach (var renderer in renderers)
            {
                var materials = renderer.sharedMaterials;
                for (var i = 0; i < materials.Length; ++i)
                    materials[i] = resourceManager.ModelThumbnailMaterial;
                renderer.sharedMaterials = materials;
            }

            VirtualCamera.VirtualCamera.Render(
                new VirtualCamera.VirtualCamera.CameraData
                {
                    position = _cameraTransform.Position,
                    rotation = _cameraTransform.Rotation,
                    orthographic = false,
                    orthographicSize = 1,
                    fieldOfView = 60,
                    nearClipPlane = 0.01f,
                    farClipPlane = 30f,
                    clearColor = new Color(0, 0, 0, 0.0f),
                    renderTexture = baseTarget
                },
                renderers
            );
            GameObject.DestroyImmediate(instance);

            resourceManager.ModelThumbnailMaterial.SetFloat("_BlurRadius", resourceManager._thumbnailGausianBlurRadius);
            resourceManager.ModelThumbnailMaterial.SetInt("_TextureWidth", baseTarget.width);
            resourceManager.ModelThumbnailMaterial.SetInt("_TextureHeight", baseTarget.height);

            Graphics.Blit(Texture2D.blackTexture, blurTarget);
            Graphics.Blit(Texture2D.blackTexture, targetThumbnail);
            Graphics.Blit(baseTarget, blurTarget, resourceManager.ModelThumbnailMaterial, 2);

            resourceManager.ModelThumbnailMaterial.SetTexture("_BlurTex", blurTarget);
            resourceManager.ModelThumbnailMaterial.SetTexture("_EmptyMark", resourceManager._thumbnailEmptyMark);
            Graphics.Blit(baseTarget, targetThumbnail, resourceManager.ModelThumbnailMaterial, 3);

            //Draw Question Mark
            GL.PushMatrix();
            GL.LoadPixelMatrix(0, baseTarget.width, baseTarget.height, 0);
            {
                Graphics.SetRenderTarget(targetThumbnail);

                var rect = new Rect();
                rect.size = new Vector2(baseTarget.width * 0.3f, baseTarget.height * 0.3f);
                rect.center = new Vector2(baseTarget.width * 0.5f, baseTarget.height * 0.5f);
                Graphics.DrawTexture(rect, resourceManager._thumbnailEmptyMark, new Rect(0, 0, 1, 1), 0, 0, 0, 0, new Color(1, 1, 1, 0.15f));
            }
            GL.PopMatrix();
            Graphics.SetRenderTarget(null);

            //EditorUtility.OpenPropertyEditor(baseTarget);
            //EditorUtility.OpenPropertyEditor(blurTarget);
            //EditorUtility.OpenPropertyEditor(targetThumbnail);    

            var path = AssetDatabase.GetAssetPath(_modelPrefab);
            var directory = Path.GetDirectoryName(path);
            if (Directory.Exists(directory) == false)
                Directory.CreateDirectory(directory);

            var emptyThumbnailPath = Path.Combine(directory, $"{_modelPrefab.name}(Empty){GlobalValue._pngExtension}");
            var thumbnail = targetThumbnail.CloneToTexture2D();
            thumbnail.Save(emptyThumbnailPath);
            AssetDatabase.Refresh();

            var textureImporter = TextureImporter.GetAtPath(emptyThumbnailPath) as TextureImporter;
            if (textureImporter != null)
            {
                textureImporter.textureType = TextureImporterType.Default;
                textureImporter.mipmapEnabled = false;
                textureImporter.maxTextureSize = 128;
                textureImporter.textureCompression = TextureImporterCompression.Compressed;

                var androidSettings = textureImporter.GetPlatformTextureSettings("Android");
                androidSettings.overridden = true;
                androidSettings.maxTextureSize = textureImporter.maxTextureSize;
                androidSettings.format = TextureImporterFormat.ASTC_4x4;
                textureImporter.SetPlatformTextureSettings(androidSettings);

                var iosSettings = textureImporter.GetPlatformTextureSettings("iPhone");
                iosSettings.overridden = androidSettings.overridden;
                iosSettings.resizeAlgorithm = androidSettings.resizeAlgorithm;
                iosSettings.maxTextureSize = androidSettings.maxTextureSize;
                iosSettings.format = androidSettings.format;
                textureImporter.SetPlatformTextureSettings(iosSettings);

                textureImporter.SaveAndReimport();
            }

            _emptyThumbnail = AssetDatabase.LoadAssetAtPath<Texture2D>(emptyThumbnailPath);
        }

        private bool GenerateSDFOutline()
        {
            var modelDataPath = AssetDatabase.GetAssetPath(this);
            var resourceDirectory = Path.GetDirectoryName(modelDataPath);

            if (_uvOutlineTexture_Origin == null)
            {
                var originUVTextureDirectory = Path.Combine(resourceDirectory, "Editor");
                var originUVTexturePath = Path.Combine(originUVTextureDirectory, $"{name}_UV{GlobalValue._pngExtension}");

                if (Directory.Exists(originUVTextureDirectory) == false)
                {
                    Directory.CreateDirectory(originUVTextureDirectory);
                    AssetDatabase.Refresh();
                }

                var tempOriginUVTexturePath = Path.Combine(resourceDirectory, $"{name}_UV{GlobalValue._pngExtension}");
                var tempOriginUVTexture = AssetDatabase.LoadAssetAtPath<Texture>(tempOriginUVTexturePath);
                if (tempOriginUVTexture != null)
                {
                    AssetDatabase.MoveAsset(tempOriginUVTexturePath, originUVTexturePath);
                    AssetDatabase.Refresh();
                }

                _uvOutlineTexture_Origin = AssetDatabase.LoadAssetAtPath<Texture>(originUVTexturePath);
                if (_uvOutlineTexture_Origin == null)
                {
                    EditorUtility.DisplayDialog("Missing Resource", $"Uv Outline Texture_Origin 없음", "OK");
                    return false;
                }
            }

            //Partition Outline SDF Generation
            var partitionOutlineTarget = RenderTexture.GetTemporary(_uvOutlineTexture_Origin.width, _uvOutlineTexture_Origin.height, 0, GraphicsFormat.R8G8B8A8_UNorm);
            Graphics.SetRenderTarget(partitionOutlineTarget);
            GL.PushMatrix();
            {
                GL.LoadOrtho();

                GL.Clear(false, true, new Color(0, 0, 0, 1));
                foreach (var partition in _partitions)
                {
                    if (partition._name == "All")
                        continue;

                    var min = partition._normPartition.min;
                    var max = partition._normPartition.max;

                    ColorMaterial.SetPass(0);
                    GL.Color(new Color(1, 1, 1, 1));
                    GL.Begin(GL.LINE_STRIP);
                    {
                        GL.Vertex3(min.x, min.y, 0);
                        GL.Vertex3(min.x, max.y, 0);
                        GL.Vertex3(max.x, max.y, 0);
                        GL.Vertex3(max.x, min.y, 0);
                        GL.Vertex3(min.x, min.y, 0);
                    }
                    GL.End();
                }
            }
            GL.PopMatrix();
            Graphics.SetRenderTarget(null);
            var partitionOutlineSDF = GenerateSDF(partitionOutlineTarget);

            //UV Outline SDF Generation
            var originPath = AssetDatabase.GetAssetPath(_uvOutlineTexture_Origin);
            var originTextureImporter = TextureImporter.GetAtPath(originPath) as TextureImporter;
            if (originTextureImporter != null)
            {
                originTextureImporter.textureType = TextureImporterType.Default;
                originTextureImporter.mipmapEnabled = false;
                originTextureImporter.textureCompression = TextureImporterCompression.Uncompressed;
                originTextureImporter.SaveAndReimport();
            }

            var uvOutlineSDF = GenerateSDF(_uvOutlineTexture_Origin);

            //Merge (Partition & UV) Outlines
            ResourceManager.Instance.SdfMergerMaterial.SetFloat("_ColorMask", (int)ColorWriteMask.Green);
            Graphics.Blit(partitionOutlineSDF, uvOutlineSDF, ResourceManager.Instance.SdfMergerMaterial);

            var path = AssetDatabase.GetAssetPath(_modelPrefab);
            path = Path.Combine(resourceDirectory, $"{_modelPrefab.name}_UV(SDF){GlobalValue._pngExtension}");
            uvOutlineSDF.CloneToTexture2D().Save(path);
            AssetDatabase.Refresh();

            //Set Texture Settings
            var textureImporter = TextureImporter.GetAtPath(path) as TextureImporter;
            if (textureImporter != null)
            {
                textureImporter.textureType = TextureImporterType.Default;
                textureImporter.mipmapEnabled = false;
                textureImporter.maxTextureSize = 256;
                textureImporter.textureCompression = TextureImporterCompression.Uncompressed;
                textureImporter.textureFormat = TextureImporterFormat.RGBA32;

                var androidSettings = textureImporter.GetPlatformTextureSettings("Android");
                androidSettings.overridden = true;
                androidSettings.maxTextureSize = textureImporter.maxTextureSize;
                androidSettings.textureCompression = TextureImporterCompression.Uncompressed;
                androidSettings.format = TextureImporterFormat.RGBA32;
                textureImporter.SetPlatformTextureSettings(androidSettings);

                var iosSettings = textureImporter.GetPlatformTextureSettings("iPhone");
                iosSettings.overridden = androidSettings.overridden;
                iosSettings.resizeAlgorithm = androidSettings.resizeAlgorithm;
                iosSettings.maxTextureSize = androidSettings.maxTextureSize;
                iosSettings.textureCompression = TextureImporterCompression.Uncompressed;
                iosSettings.format = TextureImporterFormat.RGBA32;
                textureImporter.SetPlatformTextureSettings(iosSettings);

                textureImporter.SaveAndReimport();
            }

            _uvOutlineTexture = AssetDatabase.LoadAssetAtPath<Texture>(path);
            //EditorUtility.OpenPropertyEditor(renderTarget);
            return true;
        }

        private RenderTexture GenerateSDF(Texture targetTexture)
        {
            var jumpFloodMaterial = ResourceManager.Instance.JumpFloodMaterial;
            var maxLevel = (int)math.log2(math.max(targetTexture.width, targetTexture.height));

            jumpFloodMaterial.SetInt("_MaxLevel", maxLevel);
            jumpFloodMaterial.SetInt("_TextureWidth", targetTexture.width);
            jumpFloodMaterial.SetInt("_TextureHeight", targetTexture.height);

            var temp0 = RenderTexture.GetTemporary(targetTexture.width, targetTexture.height, 0, GraphicsFormat.R32G32B32A32_SFloat);
            var temp1 = RenderTexture.GetTemporary(temp0.descriptor);

            Graphics.Blit(targetTexture, temp0, jumpFloodMaterial, 0);

            for (var i = 0; i < maxLevel; ++i)
            {
                jumpFloodMaterial.SetFloat("_Level", i + 1);
                Graphics.Blit(temp0, temp1, jumpFloodMaterial, 1);

                //Copy
                Graphics.Blit(temp1, temp0);
            }
            var renderTarget = RenderTexture.GetTemporary(temp0.descriptor);
            renderTarget.antiAliasing = 16;
            renderTarget.Create();
            Graphics.Blit(temp0, renderTarget, jumpFloodMaterial, 2);

            return renderTarget;
        }
    }

#endif
}