using System;
using System.Collections;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Web;

using Unity.Mathematics;

using UnityEngine;

namespace PixelCanvas
{
    public static class GlobalValue
    {
        public readonly static int _PrvPartition = Shader.PropertyToID(nameof(_PrvPartition));
        public readonly static int _Partition = Shader.PropertyToID(nameof(_Partition));
        public readonly static int _PartitionLock = Shader.PropertyToID(nameof(_PartitionLock));
        public readonly static int _PartitionChangedTime = Shader.PropertyToID(nameof(_PartitionChangedTime));
        public readonly static int _TimeGuagePressedTime = Shader.PropertyToID(nameof(_TimeGuagePressedTime));
        public readonly static int _UVOutlineTex = Shader.PropertyToID(nameof(_UVOutlineTex));
        public readonly static int _PixelIndexCoord = Shader.PropertyToID(nameof(_PixelIndexCoord));
        public readonly static int _ColorBuffer = Shader.PropertyToID(nameof(_ColorBuffer));
        public readonly static int _BaseMap = Shader.PropertyToID(nameof(_BaseMap));
        public readonly static int _MainTex = Shader.PropertyToID(nameof(_MainTex));
        public readonly static int _UberMap = Shader.PropertyToID(nameof(_UberMap));
        public readonly static int _SeedTex = Shader.PropertyToID(nameof(_SeedTex));
        public readonly static int _SeedRWTex = Shader.PropertyToID(nameof(_SeedRWTex));
        public readonly static int _RWTargetTex = Shader.PropertyToID(nameof(_RWTargetTex));
        public readonly static int _BrushColor = Shader.PropertyToID(nameof(_BrushColor));
        public readonly static int _Parameters0 = Shader.PropertyToID(nameof(_Parameters0));
        public readonly static int _Parameters1 = Shader.PropertyToID(nameof(_Parameters1));
        public readonly static int _BrushProjectorDepthTex = Shader.PropertyToID(nameof(_BrushProjectorDepthTex));
        public readonly static int _BrushStyle = Shader.PropertyToID(nameof(_BrushStyle));
        public readonly static int _Alpha = Shader.PropertyToID(nameof(_Alpha));
        public readonly static int _PrvRaycastPositionWS = Shader.PropertyToID(nameof(_PrvRaycastPositionWS));
        public readonly static int _RaycastPositionWS = Shader.PropertyToID(nameof(_RaycastPositionWS));
        public readonly static int _Color1 = Shader.PropertyToID(nameof(_Color1));
        public readonly static int _Color2 = Shader.PropertyToID(nameof(_Color2));
        public readonly static int _Mode = Shader.PropertyToID(nameof(_Mode));
        public readonly static int _HSV = Shader.PropertyToID(nameof(_HSV));
        public readonly static int _HSV_MIN = Shader.PropertyToID(nameof(_HSV_MIN));
        public readonly static int _HSV_MAX = Shader.PropertyToID(nameof(_HSV_MAX));
        public readonly static int _LocalPositionTex = Shader.PropertyToID(nameof(_LocalPositionTex));
        public readonly static int _PressTimeGuageRatio = Shader.PropertyToID(nameof(_PressTimeGuageRatio));
        public readonly static int _RectSize = Shader.PropertyToID(nameof(_RectSize));
        public readonly static int _EventTime = Shader.PropertyToID(nameof(_EventTime));
        public readonly static int _ZoomRatio = Shader.PropertyToID(nameof(_ZoomRatio));

        public readonly static int _Metallic = Shader.PropertyToID(nameof(_Metallic));
        public readonly static int _Smoothness = Shader.PropertyToID(nameof(_Smoothness));
        public readonly static int _EmissionPower = Shader.PropertyToID(nameof(_EmissionPower));

        public readonly static int _EnvironmentReflections = Shader.PropertyToID(nameof(_EnvironmentReflections));
        public readonly static int _ENVIRONMENTREFLECTIONS_OFF = Shader.PropertyToID(nameof(_ENVIRONMENTREFLECTIONS_OFF));

        //public readonly static int _Time = Shader.PropertyToID("_Time");
        //public readonly static int _WorldSpaceCameraPos = Shader.PropertyToID("_WorldSpaceCameraPos");
        //public readonly static int _ScreenParams = Shader.PropertyToID("_ScreenParams");
        //public readonly static int _ScaledScreenParams = Shader.PropertyToID("_ScaledScreenParams");
        //public readonly static int _ZBufferParams = Shader.PropertyToID("_ZBufferParams");
        //public readonly static int _unity_OrthoParams = Shader.PropertyToID("unity_OrthoParams");
        //public readonly static int _unity_SpecCube0 = Shader.PropertyToID("unity_SpecCube0");

        //Extension
        public const string _jsonExtension = ".json";
        public const string _bytesExtension = ".bytes";
        public const string _zipExtension = ".zip";
        public const string _pngExtension = ".png";
        public const string _prefabExtension = ".prefab";
        public const string _assetExtension = ".asset";
        public const string _fbxExtension = ".fbx";

        //Search Extension Pattern
        public const string _jsonSearchPattern = "*.json";
        public const string _bytesSearchPattern = "*.bytes";
        public const string _pngSearchPattern = "*.png";

        private static readonly string[] _seedDataTypes;

        //Editor Path
        public static readonly string _editorSeedDataPath = $"{Application.streamingAssetsPath}/PixelCanvas";

        private static readonly string _editorSeedDataPath_Canvas = $"{Application.streamingAssetsPath}/PixelCanvas/Canvas/SeedData";
        private static readonly string _editorSeedDataPath_Pet = $"{Application.streamingAssetsPath}/PixelCanvas/Pet/SeedData";
        private static readonly string _editorSeedDataPath_Costume = $"{Application.streamingAssetsPath}/PixelCanvas/Costume/SeedData";
        private static readonly List<string> _editorPaths = new List<string> { _editorSeedDataPath_Canvas, _editorSeedDataPath_Pet, _editorSeedDataPath_Costume };

        //Runtime Path
        public static readonly string _localPixelCanvasPath = $"{Application.persistentDataPath}/PixelCanvas";
        public static readonly string _localPixelCanvasPath_Temp = $"{Application.persistentDataPath}/PixelCanvas/Temp";

        private static readonly string _localSeedDataPath_Canvas = $"{Application.persistentDataPath}/PixelCanvas/Canvas/SeedData";
        private static readonly string _localSeedDataPath_Pet = $"{Application.persistentDataPath}/PixelCanvas/Pet/SeedData";
        private static readonly string _localSeedDataPath_Costume = $"{Application.persistentDataPath}/PixelCanvas/Costume/SeedData";
        private static readonly string _localThumbnailPath_Canvas = $"{Application.persistentDataPath}/PixelCanvas/Canvas/Thumbnail";
        private static readonly string _localThumbnailPath_Pet = $"{Application.persistentDataPath}/PixelCanvas/Pet/Thumbnail";
        private static readonly string _localThumbnailPath_Costume = $"{Application.persistentDataPath}/PixelCanvas/Costume/Thumbnail";
        private static readonly List<string> _runtimePaths = new List<string> { _localPixelCanvasPath, _localPixelCanvasPath_Temp, _localSeedDataPath_Canvas, _localThumbnailPath_Canvas, _localSeedDataPath_Pet, _localThumbnailPath_Pet, _localSeedDataPath_Costume, _localThumbnailPath_Costume };

        public readonly static int _DefaultLayer = LayerMask.GetMask("Default");
        public readonly static int _UILayer = LayerMask.GetMask("UI");

        public static bool ExecuteAction;
        public static bool ApplicationIsQuitting;

        //To Lua Event Callback
        public static Action Callback_OnPixelCanvasQuit;
        public static Action<string> Callback_OnSeedDataSaved;
        public static Action Callback_OnSeedDataSchemaUpdated;
        public static Action<bool> Callback_OnSeedDataListValidated;
        public static Func<string, string> GetTextDataString;

#if PIXELCANVAS_EDITOR
        //※ Must Be Removed Later(Use Addressables Table Data)
        public static Dictionary<string, string> KeyToTableString
        {
            get
            {
                if (_keyToTableString == null)
                {
                    _keyToTableString = new Dictionary<string, string>
                    {
                        { "ID_NO", "아니오" },
                        { "ID_POPUP_CANCEL", "취소" },
                        { "ID_YES", "네" },
                        { "ID_POPUP_CONFIRM", "확인" },
                        { "ID_SOCCER_PLAYER_2", "이름" },
                        { "ID_Text_4077", "픽셀캔버스" },

                        { "ID_Text_4078", "크기" },
                        { "ID_Text_4079", "부드러움" },
                        { "ID_Text_4080", "채우기 허용치" },
                        { "ID_Text_4113", "전체 초기화" },
                        { "ID_Text_4081", "변경된 내용을 저장할까요?" },
                        { "ID_Text_4082", "업스케일링" },
                        { "ID_Text_4083", "없음" },
                        { "ID_Text_4084", "Xbrz" },
                        { "ID_Text_4085", "업스케일 수치" },
                        { "ID_Text_4086", "텍스쳐 필터링" },
                        { "ID_Text_4087", "점 필터링" },
                        { "ID_Text_4088", "선형 필터링" },
                        { "ID_Text_4089", "저장 완료" },
                        { "ID_Text_4090", "초기화 완료" },
                        { "ID_Text_4091", "취소 됨" },
                        { "ID_Text_4092", "복사 됨" },
                        { "ID_Text_4093", "잘라내기" },
                        { "ID_Text_4094", "붙여넣기" },
                        { "ID_Text_4095", "되돌리기" },
                        { "ID_Text_4096", "복원" },

                        { "ID_Text_4097", "전체"},
                        { "ID_Text_4098", "악세서리"},
                        { "ID_Text_4099", "팔"},
                        { "ID_Text_4100", "입"},
                        { "ID_Text_4101", "몸"},
                        { "ID_Text_4102", "옷"},
                        { "ID_Text_4103", "디테일"},
                        { "ID_Text_4104", "귀"},
                        { "ID_Text_4105", "눈"},
                        { "ID_Text_4106", "얼굴"},
                        { "ID_Text_4107", "머리"},
                        { "ID_Text_4108", "다리"},
                        { "ID_Text_4109", "꼬리"},
                        { "ID_Text_4110", "머리카락"},
                        { "ID_Text_4111", "날개"},
                        { "ID_Text_4112", "뿔"},
                    };
                }
                return _keyToTableString;
            }
        }
        private static Dictionary<string, string> _keyToTableString;
#endif

        static GlobalValue() 
        {
            _seedDataTypes = Enum.GetNames(typeof(ESeedDataType));
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
        private static void OnBeforeSceneLoad()
        {
            ApplicationIsQuitting = false;
        }

        public static void Initialize()
        {
            foreach (var path in GlobalValue._runtimePaths)
            {
                if (Directory.Exists(path) == false)
                    Directory.CreateDirectory(path);
            }

#if (UNITY_EDITOR && PIXELCANVAS_EDITOR)
            foreach (var path in GlobalValue._editorPaths)
            {
                if (Directory.Exists(path) == false)
                    Directory.CreateDirectory(path);
            }
#endif
        }

        public static string GetEditorSeedDataDirectory(ESeedDataType seedDataType)
        {
            if (seedDataType <= 0 || _seedDataTypes.Length <= (int)seedDataType)
            {
                Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
            }
            return Path.Combine(Application.streamingAssetsPath, "PixelCanvas", _seedDataTypes[(int)seedDataType], "SeedData");
        }

        public static string GetEditorThumbnailDirectory(ESeedDataType seedDataType)
        {
            if (seedDataType <= 0 || _seedDataTypes.Length <= (int)seedDataType)
            {
                Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
            }
            return Path.Combine(Application.streamingAssetsPath, "PixelCanvas", _seedDataTypes[(int)seedDataType], "SeedData");
        }

        public static string GetOfficialSeedDataPath(ESeedDataType seedDataType, string modelDataName, string seedDataName)
        {
            if (seedDataType <= 0 || _seedDataTypes.Length <= (int)seedDataType)
            {
                Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
            }

            //Use '/' Separator on Addressables Path
            return $"{_seedDataTypes[(int)seedDataType]}/{modelDataName}/{"SeedData"}/{seedDataName}{GlobalValue._bytesExtension}";
        }

        public static string GetModelDataPath(ESeedDataType seedDataType, string modelDataName)
        {
            if (seedDataType <= 0 || _seedDataTypes.Length <= (int)seedDataType)
            {
                Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
            }

            //Use '/' Separator on Addressables Path
            return $"{_seedDataTypes[(int)seedDataType]}/{modelDataName}/{modelDataName}{GlobalValue._assetExtension}";
        }

        public static string GetOfficialThumbnailPath(ESeedDataType seedDataType, string modelDataName, string seedDataName)
        {
            if (seedDataType <= 0 || _seedDataTypes.Length <= (int)seedDataType)
            {
                Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
            }

            //Use '/' Separator on Addressables
            return $"{_seedDataTypes[(int)seedDataType]}/{modelDataName}/SeedData/{seedDataName}{GlobalValue._pngExtension}";
        }

        public static string GetOfficialEmptyThumbnailPath(ESeedDataType seedDataType, string modelDataName)
        {
            if (seedDataType <= 0 || _seedDataTypes.Length <= (int)seedDataType)
            {
                Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
            }

            //Use '/' Separator on Addressables
            return $"{_seedDataTypes[(int)seedDataType]}/{modelDataName}/{modelDataName}(Empty){GlobalValue._pngExtension}";
        }

        public static string GetLocalSeedDataPath(ESeedDataType seedDataType)
        {
            switch (seedDataType)
            {
                case ESeedDataType.Canvas:
                    return GlobalValue._localSeedDataPath_Canvas;
                case ESeedDataType.Pet:
                    return GlobalValue._localSeedDataPath_Pet;
                case ESeedDataType.Costume:
                    return GlobalValue._localSeedDataPath_Costume;
                default:
                    Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                    throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
            }
        }

        public static string GetLocalThumbnailPath(ESeedDataType seedDataType)
        {
            switch (seedDataType)
            {
                case ESeedDataType.Canvas:
                    return GlobalValue._localThumbnailPath_Canvas;
                case ESeedDataType.Pet:
                    return GlobalValue._localThumbnailPath_Pet;
                case ESeedDataType.Costume:
                    return GlobalValue._localThumbnailPath_Costume;
                default:
                    Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                    throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
            }
        }

    }
}