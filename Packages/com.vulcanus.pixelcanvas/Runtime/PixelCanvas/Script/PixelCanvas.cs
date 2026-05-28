#define EasyButton

using System;

using UnityEngine;
using UnityEngine.UI;

using System.Diagnostics;
using System.Runtime.CompilerServices;

using UnityEngine.Rendering;

using Unity.Mathematics;

using TMPro;

using Debug = UnityEngine.Debug;

using EasyButtons;

using Cysharp.Threading.Tasks;

using System.Threading;

#if UNITY_EDITOR
    using UnityEditor;
#endif

namespace PixelCanvas
{
    public partial class PixelCanvas : MonoBehaviour
    {
        [SerializeField] private Canvas _canvas;
        [SerializeField] private RawImage _drawingLayerImage;

        [SerializeField] private Button _quitButton;
        [SerializeField] private Button _settingsButton;
        [SerializeField] private Button _saveButton;
        [SerializeField] private Button _seedDataInfoButton;
        //[SerializeField] private Button _boardTypetButton;
        [SerializeField] private Toggle _boardTypeToggle;
        [SerializeField] private ColorPallete _colorPallete;
        [SerializeField] private PixelBrushAim _brushAim;
        [SerializeField] private ToolGroup _toolGroup;

        private SeedData _seedData;
        private TaskCommandController _taskCommandController = new TaskCommandController();
        private EPaintBoardType _paintBoardType = EPaintBoardType.PaintBoard3D;
        private Vector2Int _lastScreenSize;
        private bool _lockPartition = false;
        private int _partitionIndex = -1;
        private bool _dataModified;

        [Header("Double Tab UX")]
        [SerializeField] protected Image _undoIndicator;
        [SerializeField] protected Image _redoIndicator;
        [SerializeField] protected AnimationCurve _curve;
        private CancellationTokenSource _undoCancellationTokenSource = new CancellationTokenSource();
        private CancellationTokenSource _redoCancellationTokenSource = new CancellationTokenSource();

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
        private static void OnBeforeSceneLoad()
        {
        }

        private void Awake()
        {
            _quitButton.onClick.AddListener(() =>
            {
#if PIXELCANVAS_EDITOR
                if (_dataModified == true)
                {
                    EventManager.Notify
                    (
                        EPixelArtEventID.OpenComfirmPopup,
                        EComfirmPopupType.YesNoCancel,
                        TextTable.TryGetTextDataString("ID_Text_4081", out var text) == true ? text : "Do you want to save Changes?",
                        (Action)(() =>
                        {
                            _dataModified = _seedData.Save() == false;
                            GlobalValue.Callback_OnSeedDataSaved?.Invoke(_seedData._guid);
                            EventManager.Notify(EPixelArtEventID.OpenSeedDataListViewer);
                        }),
                        (Action)(() =>
                        {
                            EventManager.Notify(EPixelArtEventID.OpenSeedDataListViewer);
                        }),
                        null
                    );
                }
                else
                {
                    EventManager.Notify(EPixelArtEventID.OpenSeedDataListViewer);
                }
#else
                var root = gameObject.GetComponentInParent<PixelCanvasRoot>();
                if (_dataModified == true && _seedData._isOfficial == false)
                {
                    EventManager.Notify
                    (
                        EPixelArtEventID.OpenComfirmPopup,
                        EComfirmPopupType.YesNoCancel,
                        TextTable.TryGetTextDataString("ID_Text_4081", out var text) == true ? text : "Do you want to save Changes?",
                        (Action)(() =>
                        {
                            _dataModified = _seedData.Save() == false;
                            GlobalValue.Callback_OnSeedDataSaved?.Invoke(_seedData._guid);

                            _seedData.Release();
                            root.InactivatePixelCanvas();
                        }),
                        (Action)(() =>
                        {
                            _seedData.Release();
                            root.InactivatePixelCanvas();
                        }),
                        null
                    );
                }
                else
                {
                    _seedData.Release();
                    root.InactivatePixelCanvas();
                }
#endif
            });

            _settingsButton.onClick.AddListener(() => { });
            _settingsButton.gameObject.SetActive(false);

            _saveButton.onClick.AddListener(() =>
            {
                if (_dataModified == false)
                    return;

                _dataModified = _seedData.Save() == false;
                GlobalValue.Callback_OnSeedDataSaved?.Invoke(_seedData._guid);
            });

            _seedDataInfoButton.onClick.AddListener(() =>
            {
                EventManager.Notify(EPixelArtEventID.OpenSeedDataViewer, _seedData);
            });

            _boardTypeToggle.onValueChanged.AddListener((flag) =>
            {
                var pointBoardType = (EPaintBoardType)((flag == true) ? 1 : 0);
                ChangePaintBoardType(pointBoardType);
                EventManager.Notify(EPixelArtEventID.ChangeTool, _toolGroup.ToolType);
            });

            _undoIndicator.gameObject.SetActive(false);
            _redoIndicator.gameObject.SetActive(false);
            gameObject.SetActive(false);
            EventManager.Register(EPixelArtEventID.OpenCanvas, NotifyEvent);
        }

        private void Start()
        {
            ToolGroup.ToolSettings.Initialize();
        }

        public void Release()
        {
            ResourceManager.Instance.ReleaseShortTermResources();
            if (_taskCommandController != null)
                _taskCommandController.Release();
        }

        private void OnEnable()
        {
            EventManager.Register(EPixelArtEventID.AddTaskCommand, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangePaintBoardType, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangeUpscaleMultiplier, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangeFilterMode, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangePartitionByIndex, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangePartitionByAddingIndex, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangePartitionByUV, NotifyEvent);
            EventManager.Register(EPixelArtEventID.LockPartition, NotifyEvent);
            EventManager.Register(EPixelArtEventID.UndoRedo, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnCanvasModified, NotifyEvent);
            EventManager.Register(EPixelArtEventID.ChangeModel, NotifyEvent);
            EventManager.Register(EPixelArtEventID.RevertSeedData, NotifyEvent);
            //EventManager.Register(EPixelArtEventID.Editor_OnModelDataGenerated, NotifyEvent);
        }

        private void OnDisable()
        {
            EventManager.Unregister(EPixelArtEventID.AddTaskCommand, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangePaintBoardType, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangeUpscaleMultiplier, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangeFilterMode, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangePartitionByIndex, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangePartitionByAddingIndex, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangePartitionByUV, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.LockPartition, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.UndoRedo, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnCanvasModified, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.ChangeModel, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.RevertSeedData, NotifyEvent);
            //EventManager.Unregister(EPixelArtEventID.Editor_OnModelDataGenerated, NotifyEvent);
            Release();
        }

        private void OnDestroy()
        {
            EventManager.Unregister(EPixelArtEventID.OpenCanvas, NotifyEvent);
        }

        private void SetSeedData(SeedData seedData)
        {
            if (_seedData != null)
                _seedData.Release();
            _seedData = seedData;
            _seedData.LoadTexture();
            Shader.SetGlobalTexture(GlobalValue._UVOutlineTex, _seedData.ModelData._uvOutlineTexture);

            EventManager.Notify(EPixelArtEventID.OnSeedDataChanged, _seedData);
        }

        public void GenerateTexture(SeedData seedData)
        {
            ResourceManager.Instance.Initialize(seedData);
            _taskCommandController.Initialize(seedData._seedTarget);

            //var renderer = _projectionDrawLayerQuad.GetComponent<Renderer>();
            ////renderer.material.SetTexture(GlobalValue._BaseMap, ResourceManager.Instance.ProjectionDrawLayerTarget);

#if UNITY_EDITOR
            _drawingLayerImage.texture = ResourceManager.Instance.DrawingLayerTarget;
#else
            _drawingLayerImage.gameObject.SetActive(false);
#endif

            EventManager.Notify(EPixelArtEventID.OnTextureGenerated);
            EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
        }

        private void ChangePaintBoardType(EPaintBoardType paintBoardType)
        {
            _paintBoardType = paintBoardType;

            var animator = _boardTypeToggle.GetComponent<Animator>();
            if (_paintBoardType == EPaintBoardType.PaintBoard3D)
                animator.Play("Btn_Toggle_2D");
            else
                animator.Play("Btn_Toggle_3D");

            EventManager.Notify(EPixelArtEventID.OnPaintBoardTypeChanged, _paintBoardType);
        }

        private void Update()
        {
            UpdateScreenSize();

            if (Input.GetKeyDown(KeyCode.LeftArrow) == true)
            {
                var partitionIndex = _partitionIndex - 1;
                if (partitionIndex <= -1)
                    partitionIndex = _seedData.ModelData._partitions.Length - 1;
                ChangePartition(partitionIndex);
            }

            if (Input.GetKeyDown(KeyCode.RightArrow) == true)
            {
                var partitionIndex = _partitionIndex + 1;
                if (_seedData.ModelData._partitions.Length <= partitionIndex)
                    partitionIndex = 0;
                ChangePartition(partitionIndex);
            }
        }

        private void UpdateScreenSize()
        {
            var screenSize = new Vector2Int(Screen.width, Screen.height);
            if (_lastScreenSize == screenSize)
                return;

            _lastScreenSize = screenSize;
            EventManager.Notify(EPixelArtEventID.OnScreenSizeChanged, screenSize);
        }

        private void ChangePartition(int newIndex)
        {
            if (_lockPartition == true)
                return;

            if (_partitionIndex == newIndex)
                return;

            if (_partitionIndex == -1)
                _partitionIndex = 0;

            var prvPartition = _seedData.ModelData._partitions[_partitionIndex];
            Shader.SetGlobalVector(GlobalValue._PrvPartition, new Vector4(prvPartition._normPartition.min.x, prvPartition._normPartition.min.y, prvPartition._normPartition.max.x, prvPartition._normPartition.max.y));
            _partitionIndex = newIndex;
            var partition = _seedData.ModelData._partitions[newIndex];
            Shader.SetGlobalVector(GlobalValue._Partition, new Vector4(partition._normPartition.min.x, partition._normPartition.min.y, partition._normPartition.max.x, partition._normPartition.max.y));
            Shader.SetGlobalFloat(GlobalValue._PartitionChangedTime, Time.time);

            EventManager.Notify(EPixelArtEventID.OnPartitionChanged, _seedData.ModelData._partitions[_partitionIndex]);
        }

        protected async UniTask UndoRedoIndicatorAlpha(Image image, Color color, CancellationToken token)
        {
            var destroy = this.GetCancellationTokenOnDestroy();
            var tempColor = color;
            var maxTime = _curve[_curve.length - 1].time;
            var time = Time.unscaledTime;

            image.gameObject.SetActive(true);
            while (true)
            {
                if (destroy.IsCancellationRequested == true)
                    return;
                if (token.IsCancellationRequested == true)
                    return;
                var elapsedTime = Time.unscaledTime - time;
                if (maxTime < elapsedTime)
                    break;

                tempColor.a = _curve.Evaluate(elapsedTime);
                image.color = tempColor;
                await UniTask.Yield();
            }
            image.gameObject.SetActive(false);
        }

        private void ChangePartition(float2 uv)
        {
            var newIndex = 0;
            for (var i = 1; i < _seedData.ModelData._partitions.Length; ++i)
            {
                if (_seedData.ModelData._partitions[i]._normPartition.Contains(uv) == true)
                {
                    if (_partitionIndex == i)
                        return;
                    newIndex = i;
                    break;
                }
            }
            ChangePartition(newIndex);
        }

        private void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.AddTaskCommand:
                    {
                        var taskCommand = datas[0] as TaskCommand;
                        _taskCommandController.AddCommand(taskCommand);
                        _dataModified = true;
                    }
                    break;
                case EPixelArtEventID.OpenCanvas:
                    {
                        var seedData = datas[0] as SeedData;
                        if (seedData == null)
                            return;

                        gameObject.SetActive(true);

                        _lockPartition = false;
                        _partitionIndex = -1;
                        _dataModified = false;

                        ChangePaintBoardType(EPaintBoardType.PaintBoard3D);
                        SetSeedData(seedData);
                        GenerateTexture(seedData);
                        ChangePartition(0);

                        EventManager.Notify(EPixelArtEventID.OnOpenCanvas);
                        EventManager.Notify(EPixelArtEventID.LockPartition, false, true);
                        EventManager.Notify(EPixelArtEventID.ChangeTool, EToolType.Brush);
                        EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
                    }
                    break;
                case EPixelArtEventID.ChangePaintBoardType:
                    {
                        var paintBoardType = (EPaintBoardType)datas[0];
                        if (_paintBoardType == paintBoardType)
                            return;

                        ChangePaintBoardType(1 - _paintBoardType);
                        EventManager.Notify(EPixelArtEventID.ChangeTool, _toolGroup.ToolType);
                    }
                    break;
                case EPixelArtEventID.ChangeFilterMode:
                    {
                        var seedData = datas[0] as SeedData;
                        switch (seedData._filterMode)
                        {
                            case EFilterMode.Point:
                                ResourceManager.Instance.ScaledTarget.filterMode = FilterMode.Point;
                                break;
                            case EFilterMode.Bilinear:
                                ResourceManager.Instance.ScaledTarget.filterMode = FilterMode.Bilinear;
                                break;
                        }
                    }
                    break;
                case EPixelArtEventID.ChangeUpscaleMultiplier:
                    {
                        var seedData = datas[0] as SeedData;
                        GenerateTexture(seedData);

                        Shader.SetGlobalTexture(GlobalValue._SeedTex, ResourceManager.Instance.CanvasTarget);
                        Shader.SetGlobalVector(GlobalValue._Parameters1, new float4(_seedData._textureWidth, _seedData._textureHeight, _seedData.ScaledTextureSize.x, _seedData.ScaledTextureSize.y));
                        EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
                    }
                    break;
                case EPixelArtEventID.UndoRedo:
                    {
                        var undoRedoFlag = (ERedoUndo)datas[0];

                        var result = _taskCommandController.ExecuteRedoUndo(undoRedoFlag);
                        var indcatorColor = (result == true) ? Color.white : Color.black;

                        switch (undoRedoFlag)
                        {
                            case ERedoUndo.Undo:
                                if (_undoCancellationTokenSource != null)
                                {
                                    _undoCancellationTokenSource.Cancel();
                                    _undoCancellationTokenSource.Dispose();
                                }
                                _undoCancellationTokenSource = new CancellationTokenSource();
                                UndoRedoIndicatorAlpha(_undoIndicator, indcatorColor, _undoCancellationTokenSource.Token);
                                break;
                            case ERedoUndo.Redo:
                                if (_redoCancellationTokenSource != null)
                                {
                                    _redoCancellationTokenSource.Cancel();
                                    _redoCancellationTokenSource.Dispose();
                                }
                                _redoCancellationTokenSource = new CancellationTokenSource();
                                UndoRedoIndicatorAlpha(_redoIndicator, indcatorColor, _redoCancellationTokenSource.Token);
                                break;
                        }

                        if (result == false)
                            return;

                        _dataModified = true;

                        EventManager.Notify(EPixelArtEventID.ShowToastMessage, (undoRedoFlag == ERedoUndo.Undo) ? "ID_Text_4095" : "ID_Text_4096"); // Undo : Redo;
                        EventManager.Notify(EPixelArtEventID.OnUndoRedo, datas[0]);
                        EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
                    }
                    break;
                case EPixelArtEventID.OnCanvasModified:
                    {
                        _dataModified = true;
                    }
                    break;
                case EPixelArtEventID.ChangePartitionByIndex:
                    {
                        var partitionIndex = (int)datas[0];
                        ChangePartition(partitionIndex);
                    }
                    break;
                case EPixelArtEventID.ChangePartitionByAddingIndex:
                    {
                        var additionalIndex = (int)datas[0];
                        var partitionIndex = _partitionIndex + additionalIndex;
                        if (_seedData.ModelData._partitions.Length <= partitionIndex)
                            partitionIndex = 0;
                        else if (partitionIndex <= -1)
                            partitionIndex = _seedData.ModelData._partitions.Length - 1;

                        ChangePartition(partitionIndex);
                    }
                    break;
                case EPixelArtEventID.ChangePartitionByUV:
                    {
                        var uv = (Vector2)datas[0];
                        ChangePartition(uv);
                    }
                    break;
                case EPixelArtEventID.LockPartition:
                    {
                        var lockPartition = (bool)datas[0];
                        var reserveCanvasUpdate = (bool)datas[1];

                        _lockPartition = lockPartition;

                        if (lockPartition == false)
                            _partitionIndex = -1;

                        Shader.SetGlobalFloat(GlobalValue._PartitionLock, (lockPartition == true) ? 1 : 0);
                        EventManager.Notify(EPixelArtEventID.OnLockPartition, lockPartition);

                        if (reserveCanvasUpdate == true)
                            EventManager.Notify(EPixelArtEventID.ReserveCanvasUpdate);
                    }
                    break;
                case EPixelArtEventID.ChangeModel:
                    {
                        var mesh = datas[0] as Mesh;
                        //ChangeModel(mesh);
                    }
                    break;
                case EPixelArtEventID.RevertSeedData:
                    {
                        _seedData.RevertToOriginTexture();
                    }
                    break;
                    //case EPixelArtEventID.Editor_OnModelDataGenerated:

                    //    switch (_seedData)
                    //    {
                    //        case SeedData_Canvas canvasSeedData:
                    //            {

                    //            }
                    //            break;
                    //        case SeedData_Pet petSeedData:
                    //            {
                    //                var modelDataPack = ResourceManager.Instance.ModelDataManager;
                    //                if (0 <= petSeedData._meshType && petSeedData._meshType < modelDataPack._modelDatas.Length)
                    //                    _modelDataName = modelDataPack._modelDatas[petSeedData._meshType];
                    //                else
                    //                    _modelDataName = modelDataPack._modelDatas[0];
                    //            }
                    //            break;
                    //        case SeedData_Costume seedData_Costume:
                    //            {

                    //            }
                    //            break;
                    //    }

                    //    EventManager.Notify(EPixelArtEventID.OnModelDataChanged, _modelDataName);
                    //    ChangePartition(_partitionIndex);
                    //    break;
            }
        }
    }

#if UNITY_EDITOR
    public partial class PixelCanvas
    {
        [Button]
        public void BackupAndDeleteSeedDataPath()
        {
            PixelCanvasStorageManager.Instance.BackupAndDeleteSeedDataPath();
        }

        [Button]
        public void TestReadPixel(bool toggle)
        {
            var nUV = new int2(30, 30);
            var loop = 1000;

            if (toggle == true)
            {
                var vectorBuffer = new ComputeBuffer(1, 16);
                var computeShader = ResourceManager.Instance.DiffRegionShader;
                var kernelIndex = computeShader.FindKernel("CSReadPixel");
                computeShader.SetVector(GlobalValue._PixelIndexCoord, new Vector4(nUV.x, nUV.y, 0, 0));
                computeShader.SetTexture(kernelIndex, GlobalValue._SeedRWTex, ResourceManager.Instance.SeedTarget);
                computeShader.SetBuffer(kernelIndex, GlobalValue._ColorBuffer, vectorBuffer);

                var timer = new ElapsedTimer("Compute Read Pixel");
                for (var i = 0; i < loop; ++i)
                {
                    computeShader.Dispatch(kernelIndex, 1, 1, 1);
                    var vectorData = new Vector4[1];
                    vectorBuffer.GetData(vectorData);
                    var color = new Color(vectorData[0].x, vectorData[0].y, vectorData[0].z, vectorData[0].w);
                }
                Debug.LogError(timer.Stop());
            }
            else
            {
                var timer = new ElapsedTimer("Read Pixel");
                for (var i = 0; i < loop; ++i)
                {
                    var color = ResourceManager.Instance.SeedTarget.GetPixel(nUV.x, nUV.y);
                }
                Debug.LogError(timer.Stop());
            }
        }

        [Button]
        private RenderTexture GenerateUVOutline(Mesh mesh)
        {
            if (mesh == null)
                return null;

            var textureSize = new Vector2Int(256, 256);
            var renderTexture = new RenderTexture(textureSize.x, textureSize.y, 0, RenderTextureFormat.ARGB32);
            Graphics.Blit(Texture2D.blackTexture, renderTexture);
            renderTexture.filterMode = FilterMode.Bilinear;

            var indices = mesh.GetIndices(0);
            var uvs = mesh.uv;

            var shader = Shader.Find("Hidden/Internal-Colored");
            var lineMaterial = new Material(shader);
            lineMaterial.hideFlags = HideFlags.HideAndDontSave;
            lineMaterial.SetInt("_SrcBlend", (int)BlendMode.One);
            lineMaterial.SetInt("_DstBlend", (int)BlendMode.Zero);
            lineMaterial.SetInt("_Cull", (int)CullMode.Off);
            lineMaterial.SetInt("_ZWrite", 0);

            try
            {
                GL.PushMatrix();
                {
                    GL.LoadOrtho();
                    GL.Viewport(new Rect(0, 0, textureSize.x, textureSize.y));
                    lineMaterial.SetPass(0);

                    Graphics.SetRenderTarget(renderTexture);
                    GL.Clear(false, true, new Color(0, 0, 0, 0));

                    GL.Color(Color.white);

                    GL.Begin(GL.TRIANGLES);
                    for (var i = 0; i < indices.Length; ++i)
                    {
                        var uv = uvs[indices[i]];
                        GL.Vertex(new Vector3(uv.x, uv.y, 0));
                    }
                    GL.End();

                    Graphics.SetRenderTarget(null);
                }
                GL.PopMatrix();
            }
            catch (System.Exception e)
            {
                Debug.LogError(e);
            }

            renderTexture.name = "UV Outline";
            GameObject.DestroyImmediate(lineMaterial);
            EditorUtility.OpenPropertyEditor(renderTexture);
            renderTexture.CloneToTexture2D().Save("Assets/Test.png");
            return renderTexture;
        }
    }
#endif

    public class ElapsedTimer : IDisposable
    {
        private Stopwatch _sw = null;
        private string _name;
        private string _info;
        private volatile bool _disposed = false;

        public ElapsedTimer(string name, [CallerMemberName] string memberName = "", [CallerFilePath] string filePath = "", [CallerLineNumber] int lineNumber = 0)
        {
            _sw = new Stopwatch();
            _name = name;
            _info = $"{filePath}\t[{lineNumber}]\t{memberName}";
            _sw.Start();
        }

        ~ElapsedTimer()
        {
            Dispose(false);
        }

        public void Dispose()
        {
            Dispose(true);
        }

        public string Stop()
        {
            _sw.Stop();
            return $"{_sw.Elapsed.TotalSeconds: 0.0000000} - {_name}";
        }

        protected virtual void Dispose(bool disposing)
        {
            if (_disposed == true)
                return;

            if (disposing == true)
            {
                _sw.Stop();
                Debug.LogError($"{_name} - time:{_sw.Elapsed.TotalSeconds: 0.0000000}\n\n");
                //Console.Write($"{_name}\ntime:{_sw.Elapsed.TotalSeconds: 00.0000000}\n\n");
                //Console.Write($"{_name}\ntime:{_sw.Elapsed}\nticks:{_sw.ElapsedTicks}\nmilsec:{_sw.ElapsedMilliseconds}\n\n");
                GC.SuppressFinalize(this);
            }

            _disposed = true;
        }
    }

}


/*
 
[Button("TestCS")]
public void TestCS()
{
	//var cookieTextures = AssetDatabase.FindAssets("SpotLightCookie t:Texture", new string[] { "Packages" });
	var computeShaderPath = AssetDatabase.FindAssets("CSCalculateModifiedRegion", new string[] { "Packages" });
	if (computeShaderPath.Length == 0)
		return;

	var path = AssetDatabase.GUIDToAssetPath(computeShaderPath[0]);
	var computeShader = AssetDatabase.LoadAssetAtPath<ComputeShader>(path);
	var kernelIndex = computeShader.FindKernel("CSTest");

	var intData = new int[1];
	var intBuffer = new ComputeBuffer(1, 4);
	intBuffer.SetData(intData);

	Debug.LogError("====================");
	computeShader.SetFloat("_deltaTime", Time.deltaTime);
	computeShader.SetBuffer(kernelIndex, "intBuffer", intBuffer);
	//var commandBuffer = new CommandBuffer();
	//commandBuffer.DispatchCompute(computeShader, kernelIndex, 1, 1, 1);
	//Graphics.ExecuteCommandBuffer(commandBuffer);
	//commandBuffer.Dispose();

	using (new ElapsedTimer("ComputeShader"))
	{
		computeShader.Dispatch(kernelIndex, 1, 1, 1);
		Debug.LogError(intData[0]);
		intBuffer.GetData(intData);
	}
	//Graphics.CreateGraphicsFence(GraphicsFenceType.CPUSynchronisation, SynchronisationStageFlags.ComputeProcessing);

	int num = 0;
	using (new ElapsedTimer("Normal"))
	{
		for (int i = 0; i < 300000000; ++i)
		{
			num++;
		}
	}
}
 */


//public Texture2D _target;

//[EasyButtons.Button("DownScale")]
//void DownScale()
//{
//    var newTexture = new Texture2D(32, 32, TextureFormat.ARGB32, false);
//    var pixelSizeX = _target.width / 32.0f;
//    var pixelSizeY = _target.height / 32.0f;

//    for (int y = 0; y < newTexture.height; ++y)
//    {
//        for (int x = 0; x < newTexture.width; ++x)
//        {
//            var scaledX = (int)(pixelSizeX * x);
//            var scaledY = (int)(pixelSizeY * y);

//            var pixel = _target.GetPixel(scaledX, scaledY);
//            newTexture.SetPixel(x, y, pixel);
//        }
//    }

//    var directory = "Packages/com.vulcanus.render-pipelines.universal/Runtime/PixelCanvas/";
//    var name = _target.name;
//    var extension = GlobalValue._pngExtension;
//    var newTexturePath = $"{directory}\\{name}_downScaled{extension}";

//    var bytes = default(byte[]);
//    switch (extension.ToLower())
//    {
//        case ".png":
//            bytes = newTexture.EncodeToPNG();
//            break;
//        case ".jpg":
//            bytes = newTexture.EncodeToJPG();
//            break;
//        case ".tga":
//            bytes = newTexture.EncodeToTGA();
//            break;
//        default:
//            EditorUtility.DisplayDialog("Failed", "(PNG, JPG, TGA) Only", "OK");
//            break;
//    }
//    System.IO.File.WriteAllBytes(newTexturePath, bytes);
//    AssetDatabase.Refresh();

//    Object.DestroyImmediate(newTexture);

//    var scaledTexture = AssetDatabase.LoadAssetAtPath<Texture2D>(newTexturePath);
//}



//public void OnDrag(PointerEventData eventData)
//{
//}

//public void OnPointerDown(PointerEventData eventData)
//{
//    if (!RectTransformUtility.ScreenPointToLocalPointInRectangle(_seedImage.rectTransform, eventData.position, eventData.pressEventCamera, out var position))
//        return;

//    var uv = position / _seedImage.rectTransform.sizeDelta;
//    var targetTexture = _seedImage.GetTexture2D();
//    if (eventData.button == PointerEventData.InputButton.Left == true)
//    {
//        PaintDot(targetTexture, uv);

//        var seedTexture = _seedImage.GetTexture2D();
//        var radius = 10;
//        var diameter = radius * 2;
//        var positionPX = new Vector2(uv.x * seedTexture.width, uv.y * seedTexture.height);
//        var x = Math.Clamp((int)positionPX.x, radius, seedTexture.width - radius) - radius;
//        var y = Math.Clamp((int)positionPX.y, radius, seedTexture.height - radius) - radius;
//        var region = new System.Drawing.Rectangle(x, y, diameter, diameter);
//        //ApplyScale(region);
//        ApplyScale(new System.Drawing.Rectangle(0, 0, seedTexture.width, seedTexture.height));
//    }
//    else
//    {
//        PointSpoid(targetTexture, uv);
//    }
//}

//public void OnPointerUp(PointerEventData eventData)
//{

//}