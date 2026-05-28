using System;
using System.Collections.Generic;

using EasyButtons;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.Experimental.Rendering;

#if UNITY_EDITOR
    using UnityEditor;
#endif

namespace PixelCanvas
{
    [AttributeUsage(AttributeTargets.Class)]
    public sealed class AssetPathAttribute : Attribute
    {
        public string Path { get; }

        public AssetPathAttribute(string filePath)
        {
            Path = filePath;
        }
    }

    //[CreateAssetMenu(fileName = "ResourceManager", menuName = "PixelCanvas/ResourceManager", order = 1)]
    [AssetPath("ResourceManager")]
    public partial class ResourceManager : ScriptableObject
    {
        public static ResourceManager Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = Resources.Load<ResourceManager>(GetResourcePath());
                }
                return _instance;
            }
        }
        private static ResourceManager _instance;

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
        private static void OnBeforeSceneLoad()
        {
            _instance = null;
        }

        private static string GetResourcePath()
        {
            var attributes = typeof(ResourceManager).GetCustomAttributes(true);

            foreach (object attribute in attributes)
            {
                if (attribute is AssetPathAttribute pathAttribute)
                    return pathAttribute.Path;
            }
            Debug.LogError($"{typeof(ResourceManager)} does not have {nameof(AssetPathAttribute)}.");
            return string.Empty;
        }

        public GameObject PixelCanvasRootPerfab => _pixelCanvasRootPerfab;
        [SerializeField] private GameObject _pixelCanvasRootPerfab;

        public Shader VulcanusSimpleLitShader => _vulcanusSimpleLitShader;
        public Shader VulcanusLitShader => _vulcanusLitShader;
        [Header("Vulcanus Shader")]
        [SerializeField] private Shader _vulcanusSimpleLitShader;
        [SerializeField] private Shader _vulcanusLitShader;

        public ComputeShader DiffRegionShader => _diffRegionShader;
        [Header("Command")]
        [SerializeField] private ComputeShader _diffRegionShader;
        [SerializeField] private Shader _colorDiffShader;
        [SerializeField] private Shader _undoRedoShader;
        [SerializeField] private Shader _brushShader;
        [SerializeField] private Shader _drawingLayerMergerShader;
        [SerializeField] private Shader _uvOutlineShader;
        [SerializeField] private Shader _modelThumbnailShader;
        [SerializeField] private Shader _meshLocalPositionBakerShader;
        [SerializeField] private Shader _brushProjectorShader;
        [SerializeField] private Shader _projectionBrushApplierShader;
        [SerializeField] private Shader _depthBakerShader;
        [SerializeField] private Shader _depthCopierShader;
        [SerializeField] private Shader _jumpFloodShader;
        [SerializeField] private Shader _regionDrawerShader;
        [SerializeField] private Shader _sdfMergerShader;

        [Header("Upscale Algorithm")]
        [SerializeField] private Shader _upscaleShader_Xbrz;

        public RenderTexture SeedTarget => _seedTarget;
        [Space(20)]
        [Header("Render Target")]
        [SerializeField] private RenderTexture _seedTarget;

        public RenderTexture DrawingLayerTarget => _drawingLayerTarget;
        [SerializeField] private RenderTexture _drawingLayerTarget;

        public RenderTexture MergedTarget => _mergedTarget;
        [SerializeField] private RenderTexture _mergedTarget;

        public RenderTexture CanvasTarget => _canvasTarget;
        [SerializeField] private RenderTexture _canvasTarget;

        public RenderTexture ScaledTarget => _scaledTarget;
        [SerializeField] private RenderTexture _scaledTarget;

        public RenderTexture ColorDiffTarget => _colorDiffTarget;
        [SerializeField] private RenderTexture _colorDiffTarget;

        public RenderTexture ThumbnailTarget
        {
            get
            {
                if (_thumbnailTarget == null)
                {
                    _thumbnailTarget = new RenderTexture(256, 256, GraphicsFormat.R16G16B16A16_SFloat, GraphicsFormat.D24_UNorm_S8_UInt);
                    _thumbnailTarget.filterMode = FilterMode.Bilinear;
                    _thumbnailTarget.antiAliasing = 4;
                    _thumbnailTarget.Create();
                }
                return _thumbnailTarget;
            }
        }
        private RenderTexture _thumbnailTarget;

        public Material DummyModelMaterial => _dummyModelMaterial;
        [Space(20)]
        [Header("Model Material")]
        [SerializeField] private Material _dummyModelMaterial;

        public Material ModelPrefabMaterial => _modelPrefabMaterial;
        [SerializeField] private Material _modelPrefabMaterial;

        public Material MergedImageUIMaterial => _mergedImageUIMaterial;
        [Space(20)]
        [Header("UI Material")]
        [SerializeField] private Material _mergedImageUIMaterial;

        public Material UndoRedoMaterial
        {
            get
            {
                if (_undoRedoMaterial == null)
                    _undoRedoMaterial = new Material(_undoRedoShader);
                return _undoRedoMaterial;
            }
        }
        private Material _undoRedoMaterial;

        public Material ColorDiffMaterial
        {
            get
            {
                if (_colorDiffMaterial == null)
                    _colorDiffMaterial = new Material(_colorDiffShader);
                return _colorDiffMaterial;
            }
        }
        private Material _colorDiffMaterial;

        public Material BrushMaterial
        {
            get
            {
                if (_brushMaterial == null)
                    _brushMaterial = new Material(_brushShader);
                return _brushMaterial;
            }
        }
        private Material _brushMaterial;

        public Material DrawingLayerMergerMaterial
        {
            get
            {
                if (_drawingLayerMergerMaterial == null)
                    _drawingLayerMergerMaterial = new Material(_drawingLayerMergerShader);
                return _drawingLayerMergerMaterial;
            }
        }
        private Material _drawingLayerMergerMaterial;

        public Material UvOutlineMaterial
        {
            get
            {
                if (_uvOutlineMaterial == null)
                    _uvOutlineMaterial = new Material(_uvOutlineShader);
                return _uvOutlineMaterial;
            }
        }
        private Material _uvOutlineMaterial;

        public Material UpscaleMaterial
        {
            get
            {
                if (_upscaleMaterial == null)
                    _upscaleMaterial = new Material(_upscaleShader_Xbrz);
                return _upscaleMaterial;
            }
        }
        private Material _upscaleMaterial;

        public Material ModelThumbnailMaterial
        {
            get
            {
                if (_modelThumbnailMaterial == null)
                    _modelThumbnailMaterial = new Material(_modelThumbnailShader);
                return _modelThumbnailMaterial;
            }
        }
        private Material _modelThumbnailMaterial;

        public Material JumpFloodMaterial
        {
            get
            {
                if (_jumpFloodMaterial == null)
                    _jumpFloodMaterial = new Material(_jumpFloodShader);
                return _jumpFloodMaterial;
            }
        }
        private Material _jumpFloodMaterial;


        public Material RegionDrawerMaterial
        {
            get
            {
                if (_regionDrawerMaterial == null)
                    _regionDrawerMaterial = new Material(_regionDrawerShader);
                return _regionDrawerMaterial;
            }
        }
        private Material _regionDrawerMaterial;

        public Material SdfMergerMaterial
        {
            get
            {
                if (_sdfMergerMaterial == null)
                    _sdfMergerMaterial = new Material(_sdfMergerShader);
                return _sdfMergerMaterial;
            }
        }
        private Material _sdfMergerMaterial;

        //Texture2D Seed Data for Color Spoid execution Performance Optimization
        public Texture2D SeedTexture => _seedTexture;
        [Space(20)]
        [Header("Texture")]
        [SerializeField] private Texture2D _seedTexture;

        public Texture2D ErrorImage => _errorImage;
        [SerializeField] private Texture2D _errorImage;

        [Space(20)]
        [Header("Gesture Value")]
        public float _doubleTabTimeThreshold = 0.2f;

        [Space(20)]
        [Header("Global Value")]
        public float2 _zoomMinMax = new float2(0.5f, 10);
        public float2 _brushMinMaxSize = new float2(1, 20);
        public float2 _brushSoftnessMinMax = new float2(0f, 1f);
        public float2 _brushMinMaxFlow = new float2(0, 1);
        public float2 _paintMinMaxThreshold = new float2(0, 1);
        public float _fingerToolTimeThreashold = 0.8f;
        public float _fingerToolDragThreashold = 5;

        [Header("PaintBoard 2D")]
        public float _zoomAngleThreashold = 10.0f;

        [Header("PaintBoard 3D")]
        public float _cameraRotationSensitivity = 1;
        public float _cameraRotationDampingFactor = 10;

        [Space(20)]
        [Header("Thumbnail")]
        public float3 _thumbnailLightDirection = new float3(-0.5f, -1, -0.5f);
        public float3 _thumbnailCameraTarget = new float3(0f, 0.35f, 0);
        public float3 _thumbnailCameraOffsetDirection = new float3(-0.5f, 0.3f, 1);
        [Range(0.01f, 100)] public float _thumbnailCameraDistance = 1;
        [Range(1, 120)] public float _thumbnailCameraFOV = 60f;
        [Range(0.1f, 1)] public float _thumbnailPadding = 0.25f;
        [Range(0.1f, 20)] public float _thumbnailGausianBlurRadius = 1;
        [Range(1, 10)] public int _geodesicDomeRadius = 3;
        [Range(1, 10)] public int _geodesicDomeFrequency = 5;
        [Range(0, 1)] public float _raySurfaceNormalAllowance = 0.97f;
        public Texture _thumbnailEmptyMark;

        [Space(20)]
        [Header("Brush")]
        [SerializeField] private float _brushBoardMoverMultiplier = 2;
        public static float BrushBoardMoverMultiplier => Instance._brushBoardMoverMultiplier;

        public int[] UVGridCenterRatio => _uvGridCenterRatio;
        private int[] _uvGridCenterRatio;

        public bool TryGetAudioClip(string name, out AudioClip audioClip)
        {
            if (_dicAudioClips == null)
            {
                audioClip = null;
                return false;
            }
            return _dicAudioClips.TryGetValue(name, out audioClip);
        }
        private Dictionary<string, AudioClip> _dicAudioClips;
        [SerializeField] private AudioClip[] _audioClips;

        public void Initialize(SeedData seedData)
        {
            ReleaseShortTermResources();

            _seedTarget = seedData._seedTarget;

            _seedTexture = new Texture2D(seedData._textureWidth, seedData._textureHeight, GraphicsFormat.R8G8B8A8_SRGB, TextureCreationFlags.None);
            _seedTexture.filterMode = FilterMode.Point;
            seedData._seedTarget.CopyTo(_seedTexture);

            _mergedTarget = new RenderTexture(_seedTarget.width, _seedTarget.height, 0, GraphicsFormat.R8G8B8A8_SRGB);
            _mergedTarget.name = "MergedRenderTexture";
            _mergedTarget.filterMode = FilterMode.Point;
            Graphics.Blit(seedData._seedTarget, _mergedTarget);

            _canvasTarget = new RenderTexture(_seedTarget.width, _seedTarget.height, 0, GraphicsFormat.R8G8B8A8_SRGB);
            _canvasTarget.name = "CanvasRenderTexture";
            _canvasTarget.filterMode = FilterMode.Point;
            Graphics.Blit(seedData._seedTarget, _mergedTarget);

            _drawingLayerTarget = new RenderTexture(_seedTarget.width, _seedTarget.height, 0, GraphicsFormat.R8G8B8A8_SRGB);
            _drawingLayerTarget.name = "DrawingLayerTexture";
            _drawingLayerTarget.filterMode = FilterMode.Point;
            _drawingLayerTarget.enableRandomWrite = true;
            _drawingLayerTarget.Create();
            Graphics.Blit(Texture2D.blackTexture, _drawingLayerTarget);

            var scaledSize = new uint2((uint)_seedTarget.width, (uint)_seedTarget.height) * seedData._scale;
            _scaledTarget = new RenderTexture((int)scaledSize.x, (int)scaledSize.y, 0, GraphicsFormat.R8G8B8A8_SRGB);
            switch (seedData._filterMode)
            {
                case EFilterMode.Point:
                    _scaledTarget.filterMode = FilterMode.Point;
                    break;
                case EFilterMode.Bilinear:
                    _scaledTarget.filterMode = FilterMode.Bilinear;
                    break;
            }

            _colorDiffTarget = new RenderTexture(_seedTarget.width, _seedTarget.height, 0, RenderTextureFormat.ARGBFloat);
            _colorDiffTarget.filterMode = FilterMode.Point;

            if (_dicAudioClips == null)
            {
                _dicAudioClips = new Dictionary<string, AudioClip>();
                foreach (var audioClip in _audioClips)
                {
                    if (audioClip == null)
                        continue;
                    _dicAudioClips.Add(audioClip.name, audioClip);
                }
            }
        }

        public void ReleaseShortTermResources()
        {
            //GameObject.Destroy(_seedTarget);
            GameObject.Destroy(_mergedTarget);
            GameObject.Destroy(_canvasTarget);
            GameObject.Destroy(_drawingLayerTarget);
            GameObject.Destroy(_scaledTarget);
            GameObject.Destroy(_colorDiffTarget);
        }

        public void ReleaseLongTermResources()
        {
            ReleaseShortTermResources();
            GameObject.Destroy(_thumbnailTarget);

            GameObject.Destroy(_undoRedoMaterial);
            GameObject.Destroy(_colorDiffMaterial);
            GameObject.Destroy(_uvOutlineMaterial);
            GameObject.Destroy(_brushMaterial);
            GameObject.Destroy(_drawingLayerMergerMaterial);
            GameObject.Destroy(_upscaleMaterial);
            GameObject.Destroy(_modelThumbnailMaterial);
            GameObject.Destroy(_jumpFloodMaterial);
            GameObject.Destroy(_regionDrawerMaterial);
            GameObject.Destroy(_sdfMergerMaterial);

            foreach (var texture2D in _dicTempTexture2D)
                GameObject.DestroyImmediate(texture2D.Value);
            _dicTempTexture2D.Clear();
        }

        public Texture2D GetTemporaryTexture2D(int2 key)
        {
            if (_dicTempTexture2D.TryGetValue(key, out var texture) == false)
            {
                texture = new Texture2D(key.x, key.y, TextureFormat.ARGB32, false);
                texture.filterMode = FilterMode.Point;
                _dicTempTexture2D.Add(key, texture);
            }
            return texture;
        }
        private Dictionary<int2, Texture2D> _dicTempTexture2D = new Dictionary<int2, Texture2D>();
    }

#if UNITY_EDITOR
    public partial class ResourceManager
    {
        [Button]
        private void ShowModelThumbnailMaterial()
        {
            EditorUtility.OpenPropertyEditor(ModelThumbnailMaterial);
        }
    }
#endif
}