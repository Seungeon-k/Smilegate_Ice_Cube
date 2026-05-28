
#if UNITY_EDITOR

using DevTool;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

namespace DevTool
{
    public class AssetGUIDRegeneratorMenu
    {
        //[MenuItem("Assets/Regenerate GUID/Files Only", true)]
        //public static bool RegenerateGUID_Validation()
        //{
        //    return DoValidation();
        //}

        //[MenuItem("Assets/Regenerate GUID/Files and Folders", true)]
        //public static bool RegenerateGUIDWithFolders_Validation()
        //{
        //    return DoValidation();
        //}

        //private static bool DoValidation()
        //{
        //    var bAreSelectedAssetsValid = true;

        //    foreach (var guid in Selection.assetGUIDs)
        //    {
        //        var assetPath = AssetDatabase.GUIDToAssetPath(guid);
        //        bAreSelectedAssetsValid = !string.IsNullOrEmpty(guid) && guid != "0";
        //    }

        //    return bAreSelectedAssetsValid;
        //}

        //[MenuItem("Assets/Regenerate GUID/Files Only")]
        //public static void RegenerateGUID_Implementation()
        //{
        //    DoImplementation(false);
        //}

        //[MenuItem("Assets/Regenerate GUID/Files and Folders")]
        //public static void RegenerateGUIDWithFolders_Implementation()
        //{
        //    DoImplementation(true);
        //}

        private static void DoImplementation(bool includeFolders)
        {
            //var assetGUIDS = AssetGUIDRegenerator.ExtractGUIDs(Selection.assetGUIDs, includeFolders);

            //var option = EditorUtility.DisplayDialogComplex($"Regenerate GUID for {assetGUIDS.Length} asset/s",
            //    "DISCLAIMER: Intentionally modifying asset GUID is not recommended unless certain issues are encountered. " +
            //    "\n\nMake sure you have a backup or is using a version control system. \n\nThis operation can take a long time on larger projects. Do you want to proceed?",
            //    "Yes, please", "Nope", "I need more info");

            //if (option == 0)
            //{
            //    AssetDatabase.StartAssetEditing();
            //    AssetGUIDRegenerator.RegenerateGUIDs(assetGUIDS);
            //    AssetDatabase.StopAssetEditing();
            //    AssetDatabase.SaveAssets();
            //    AssetDatabase.Refresh();
            //}
            //else if (option == 2)
            //{
            //    Application.OpenURL("https://github.com/jeffjads/unity-guid-regenerator/blob/master/README.md");
            //}
        }
    }

    public class GenerateGuidInfo
    {
        public string version;
        public string orignGuid;
        public string generateGuid;
        public string assetPath;
        public string description;
    }

    
    public class AssetGUIDRegeneratorWindow : EditorWindow
    {
        public class ResultInfo
        {
            public UnityEngine.Object _asset;
            public string _assetPath;
            public string _guid;
            public bool bignore = false;
            public bool bfixignore = false;
        }


        private static string FilePath = $"Packages/com.vulcanus.devtools/";
        private static string OfficialPath = $"Packages/com.v.gameframework.resources/Runtime/Official";


        [SerializeField] public DefaultAsset folder;
        [SerializeField] private DefaultAsset checkFolder;

        // 찾은 에셋들 캐시
        //private readonly List<UnityEngine.Object> _assets = new List<UnityEngine.Object>();
        private List<ResultInfo>        _resultInfos            = new List<ResultInfo>();
        private List<GenerateGuidInfo>  _generateGuidInfos      = new List<GenerateGuidInfo>();

        private HashSet<string>         _orignGuidSet           = new HashSet<string>();
        private HashSet<string>         _generateGuidSet        = new HashSet<string>();

        public bool loaded = false;
        private Vector2 _scroll1;
        private Vector2 _scroll2;

        private bool bShowAssetList = true;
        private bool bShowGUIDList = false;

        private int selectFilterIndex = 0;
        private string[] showFilterOptions = new string[] { "All", "Red", "Gray"};

        private string findGUIDField = "";

        // 무시할 GUID 리스트
        //이미 아래 GUID로 배포되어 바뀌면 안된다
        private string[] ignoreList = new string[]
        {
            "e7de36f48d372a94d9fc1275aec90f56", // Katuri_Merged
            "ab686bfaaa2bbeb4a97c91f26affe5b0", // Katuri_Merged_Outline_BasicBlue
            "c902eae356035454d97a556ad4a6f05c", // Katuri_Merged_Outline_Black_Alpha_01
            "5c7df5a99e8990748a62574c8f61e8f2", // Katuri_Merged_Outline_White_Alpha_02
            "146d18bf98c1af64c8d6c00a068cb210", // Katuri_Merged_Outline_Black_Alpha_03
            "89a7b2c2ec19b934fb6f1c6076bc2433", // Katuri_Merged_Outline_Blue
            "76242e79cf5147848a420cc434eddff4", // Katuri_Merged_Outline_Blue_Alpha_01
            "ff4879b28bd823f4c8db153f88c7dacb", // Katuri_Merged_Outline_Blue_Alpha_02
            "96ffce168a4067348a36d64f229fdbca", // Katuri_Merged_Outline_Blue_Alpha_03
            "db63f77a947a8ad408eddcc1d3a572ff", // Katuri_Merged_Outline_Blue_Alpha_04
            "7062a4258a6c47b4790b431e87f008a0", // Katuri_Merged_Outline_Blue_Shadow_01
            "34d99ad2ff6b7ce4480eeca8981328da", // Katuri_Merged_Outline_Brown
            "a269008decb9587458720edd2150ca09", // Katuri_Merged_Outline_Brown_Alpha_01
            "194d1d0a057d0634c8c8ca499652462e", // Katuri_Merged_Outline_DarkBlue
            "5907483db6f0fd344a96440f6660b4e2", // Katuri_Merged_Outline_Goods
            "c8342aaf3a1809948bc9468d13560238", // Katuri_Merged_Outline_Green
            "b1d46e9aab0d38c449bb477cb584c17e", // Katuri_Merged_Outline_Green_Alpha_01
            "04b51baefc63b784b8e13be8bd983db5", // Katuri_Merged_Outline_Green_Alpha_02
            "eed6ced3eaa09ae42ac4dac8204d565c", // Katuri_Merged_Outline_Mint
            "f7fcab48b4f7f1f45ae33228418f2ebc", // Katuri_Merged_Outline_Mint_02
            "75a5c06836743bb42b93321fcbdd9aa6", // Katuri_Merged_Outline_Mint_03
            "5c7e01cec74f6a645b63e7abded26fd9", // Katuri_Merged_Outline_Mint_Alpha_01
            "54d4c9039833ee94f97e6837e3ed299c", // Katuri_Merged_Outline_Navy
            "3468893448a466a4a9addd733a3a7c0c", // Katuri_Merged_Outline_Navy_Alpha_01
            "de045b97ce2acc943bfd723ec908aa7f", // Katuri_Merged_Outline_Orange_Alpha_01
            "96b25fa64ddfe354b8419b11d4ef794a", // Katuri_Merged_Outline_PetBanner_01_01_Pink
            "922c604b7296a08438f2f2ad92790094", // Katuri_Merged_Outline_PetBanner_01_02_DarkRed
            "546fb9b49880d3440b25b623318839ad", // Katuri_Merged_Outline_Pink_Alpha_Shadow_01 1
            "128b044de4ac0044ca186220d1825271", // Katuri_Merged_Outline_Purple
            "19ba8b8e345b49d41b25ed66b4ff05ee", // Katuri_Merged_Outline_Red
            "e00d7d18d47595f4b9246c99248e4c21", // Katuri_Merged_Outline_Red_Alpha_01
            "584cb9bd04ab1d44798c65ee10023bfd", // Katuri_Merged_Outline_SkyBlueOutline
            "5a61001060d790244ac8f7f66b514b8d", // Katuri_Merged_Outline_SkyBlueOutline_02
            "025c05a46ef9ae74dae5eb6c51b1b23f", // Katuri_Merged_Outline_SkyBlue_Shaodw_01
            "43e5c7d5ae8400246a9963cad8572a9a", // Katuri_Merged_Outline_SpyGauge_01
            "76d9854558d8f53419a7bd6ffdd4e9c1", // Katuri_Merged_Outline_SpyGauge_02
            "e6c3578ed4f8f9541959874d3555393d", // Katuri_Merged_Outline_StageTitle
            "e31f71fe297484c4ebb1a38ba5aa1f9f", // Katuri_Merged_Outline_Survivor
            "d415368e2011c2b4c83f08da3bbf18c7", // Katuri_Merged_Outline_Tag_Bonus
            "aaa6a6918c090dc43a1372d9dd7518cb", // Katuri_Merged_Outline_Tag_Hot
            "6f2d2f4f5c66110409b732cb3f4e138d", // Katuri_Merged_Outline_Tag_New
            "bb1e4e8c97b478f468bc142a2ccba86c", // Katuri_Merged_Outline_Time_Blue
            "7b20f96399916d943a26cfa2e69e67f5", // Katuri_Merged_Outline_Time_Navy
            "a5573839364d3ee4c8677df3afd43fe8", // Katuri_Merged_Outline_Time_Orange
            "fb908cf4ca4419b4c8c57c658ea2efe3", // Katuri_Merged_Outline_Time_Pink
            "bf2be4fd5c5cb0b4f884f5dfcb3439c9", // Katuri_Merged_Outline_TopTitle
            "e249e7e13a5c28b42b0473ede0551fbd", // Katuri_Merged_Outline_Vic
            "f1c38be43339c424c8f9da5d0c6e4641", // Katuri_Merged_Outline_White
            "1043de4474e8b25459e657546a8a4581", // Katuri_Merged_Outline_White_Alpha_01
            "50130fae647d7a544be390074aaebf45", // Katuri_Merged_Outline_White_Alpha_02
            "60c532f8871626b4b8021e1784548922", // Katuri_Merged_Outline_Yellow_Alpha_01

            "3bf77cb63ca93a641b4af0e4520ec0a5", // UI_Icon_Stage_Big_Bomb
            "e7e523caaf0bcbc48b7f94b004210fe0", // UI_Icon_Stage_Billiardball
            "45b064f733124cb4099a2ff521986710", // UI_Icon_Stage_Colorswitch
            "4a186d57b23a1664781a7a69a5305d0a", // UI_Icon_Stage_CreepingIcePlate
            "24fd4684cac9d5549adcce7112d7bf61", // UI_Icon_Stage_EmptyRoyal
            "1b67339ee5239b442ae4712c23172fb4", // UI_Icon_Stage_EmptyRun
            "fe55c3ff1a674b7458d0ffced9d74aec", // UI_Icon_Stage_EnsibleFight
            "97f7021ccddcd704882c2eebe0ae6717", // UI_Icon_Stage_FinalStage
            "e02a883e88b51a240afdd7f9d08dca5f", // UI_Icon_Stage_LastStage
            "93d270b620029c74ebc66a087f2b788f", // UI_Icon_Stage_Lavezone
            "9a6355479a6836f4f8ad981ac0a66c76", // UI_Icon_Stage_RedGreenLight
            "b4d969d4e99691b44a49dce12d5a5479", // UI_Icon_Stage_UpandDown
            "340743aff023a3240beb0de2adddc377", // UI_Icon_Stage_Wall

            "445252745cb9db44fa51cd76e27bf8f4", // katuri_hangul_characters
            "6512e8e874f64e340b757afad9288cfe", // katuri_merged
        };  


        [MenuItem("Tools/DevTools/AssetGUIDRegenerator")]
        public static void Open()
        {
            var window = GetWindow<AssetGUIDRegeneratorWindow>("AssetGUIDRegeneratorWindow");
            DefaultAsset officialFolder = AssetDatabase.LoadAssetAtPath<DefaultAsset>(OfficialPath);
            window.folder = officialFolder;

            // 오피셜 폴더 세팅 후 리스트 갱신
            window.loaded = false;
            window.RefreshAssetList();
        }

        public void SaveGuidData(List<GenerateGuidInfo> result)
        {
            string path = FilePath + "/GenerateGuidInfo.csv";
            AssetGUIDRegenerator.SaveToCsv(path, result);

            _generateGuidInfos = result;

            _orignGuidSet.Clear();
            _generateGuidSet.Clear();

            foreach (var info in _generateGuidInfos)
            {
                _orignGuidSet.Add(info.orignGuid);
                _generateGuidSet.Add(info.generateGuid);
            }
        }

        public void LoadGuidData()
        {
            string path = FilePath + "/GenerateGuidInfo.csv";
            var loadData = AssetGUIDRegenerator.LoadFromCsv(path);
            _generateGuidInfos = loadData;

            _orignGuidSet.Clear();
            _generateGuidSet.Clear();

            foreach (var info in _generateGuidInfos)
            {
                _orignGuidSet.Add(info.orignGuid);
                _generateGuidSet.Add(info.generateGuid);
            }
        }

        private void OnGUI()
        {
            if (!loaded)
            {
                LoadGuidData();
                loaded = true;
            }

            EditorGUILayout.LabelField("폴더 선택", EditorStyles.boldLabel);
            EditorGUI.BeginChangeCheck();
            folder = (DefaultAsset)EditorGUILayout.ObjectField("Folder", folder, typeof(DefaultAsset), false); // Scene 오브젝트 불가

            if (EditorGUI.EndChangeCheck())
            {
                // 폴더가 바뀌면 자동으로 리스트 갱신
                RefreshAssetList();
            }

            // 폴더 유효성 체크
            string folderPath = folder != null ? AssetDatabase.GetAssetPath(folder) : null;
            if (folder == null || string.IsNullOrEmpty(folderPath) || !AssetDatabase.IsValidFolder(folderPath))
            {
                EditorGUILayout.HelpBox("Project 창에서 폴더를 선택해 주세요.", MessageType.Info);
                return;
            }

            if (GUILayout.Button("GUID 히스토리 파일 재로드 / 에셋 리스트 새로고침"))
            {
                LoadGuidData();
                RefreshAssetList();
                loaded = true;
            }

            List<string> guidsToChange = new List<string>();
            foreach (var resultInfo in _resultInfos)
            {
                if(resultInfo.bignore)
                    continue;

                guidsToChange.Add(resultInfo._guid);
            }

            if (GUILayout.Button("해당 에셋 리스트 GUID 변경"))
            {
                var result = AssetGUIDRegenerator.DoRegenerateGUIDs(guidsToChange.ToArray(), _generateGuidInfos);
                SaveGuidData(result);
                RefreshAssetList();
            }

            if (GUILayout.Button("해당 에셋 리스트 리버스"))
            {
                var result = AssetGUIDRegenerator.DoRegenerateGUIDs(guidsToChange.ToArray(), _generateGuidInfos, true);
                RefreshAssetList();
            }

            if (GUILayout.Button("List에 있는 에셋만 변경"))
            {
                var result = AssetGUIDRegenerator.DoRegenerateGUIDs(guidsToChange.ToArray(), _generateGuidInfos, false, true);
                RefreshAssetList();
            }

            EditorGUILayout.BeginHorizontal();

            findGUIDField = EditorGUILayout.TextField(findGUIDField, GUILayout.Width(310));

            if (GUILayout.Button("GUID 찾기"))
            {
                foreach (var generateGuid in _generateGuidInfos)
                {
                    if(generateGuid.orignGuid == findGUIDField || generateGuid.generateGuid == findGUIDField)
                    {
                        Debug.LogError($"구 GUID : {generateGuid.orignGuid} -> 새 GUID : {generateGuid.generateGuid} , 변경 당시 Asset Path : {generateGuid.assetPath} , 버전 정보 : {generateGuid.version}");
                    }
                }
            }
            EditorGUILayout.EndHorizontal();



            checkFolder = (DefaultAsset)EditorGUILayout.ObjectField("Check Folder", checkFolder, typeof(DefaultAsset), false); // Scene 오브젝트 불가
            string checkfolderPath = checkFolder != null ? AssetDatabase.GetAssetPath(checkFolder) : null;

            if (GUILayout.Button("Text기반 GUID체크"))
            {
                var list = GuidReferenceSearcher.FindAssetsThatContainGuidText(checkfolderPath, _generateGuidInfos, false);
            }

            if (GUILayout.Button("Text기반 GUID변경"))
            {
                var list = GuidReferenceSearcher.FindAssetsThatContainGuidText(checkfolderPath, _generateGuidInfos, true);
            }

            if (GUILayout.Button("구GUID 에셋 삭제"))
            {
                GuidReferenceSearcher.FindAssetsAndDelete(checkfolderPath, _generateGuidInfos);
            }

            EditorGUILayout.Space();

            EditorGUILayout.BeginHorizontal();

            List<ResultInfo> greenList = new List<ResultInfo>();
            List<ResultInfo> redList = new List<ResultInfo>();
            List<ResultInfo> grayList = new List<ResultInfo>();
            foreach (var resultInfo in _resultInfos)
            {
                if (_orignGuidSet.Contains(resultInfo._guid))
                {
                    redList.Add(resultInfo);
                }
                else if (_generateGuidSet.Contains(resultInfo._guid))
                {
                    greenList.Add(resultInfo);
                }
                else
                {
                    if(resultInfo.bfixignore == false)
                        grayList.Add(resultInfo);
                }
            }

            var oldColor = GUI.contentColor;
            selectFilterIndex = EditorGUILayout.Popup(selectFilterIndex, showFilterOptions, GUILayout.Width(200));
            EditorGUILayout.LabelField($"에셋 개수: {_resultInfos.Count}");
            EditorGUILayout.LabelField($"변경된 리스트 : {greenList.Count}");
            GUI.contentColor = Color.red;
            EditorGUILayout.LabelField($"구GUID 리스트 : {redList.Count}");
            EditorGUILayout.LabelField($"변경되지 않은 리스트 : {grayList.Count}");
            GUI.contentColor = oldColor;

            EditorGUILayout.EndHorizontal();


            List<ResultInfo> viewList = new List<ResultInfo>();
            if(selectFilterIndex == 0)
                viewList = _resultInfos;
            else if (selectFilterIndex == 1)
                viewList = redList;
            else if(selectFilterIndex == 2)
                viewList = grayList;

            bShowAssetList = EditorGUILayout.BeginFoldoutHeaderGroup(bShowAssetList, "에셋 리스트");
            if (bShowAssetList)
            {
                // 에셋 리스트 표시
                _scroll1 = EditorGUILayout.BeginScrollView(_scroll1);
                var oldBgColor = GUI.backgroundColor;
                foreach (var resultInfo in viewList)
                {
                    EditorGUILayout.BeginHorizontal();

                    if (_orignGuidSet.Contains(resultInfo._guid))
                    {
                        GUI.backgroundColor = Color.red;
                    }
                    else if (_generateGuidSet.Contains(resultInfo._guid))
                    {
                        GUI.backgroundColor = Color.green;
                    }
                    else
                    {
                        GUI.backgroundColor = oldBgColor;
                    }

                    EditorGUI.BeginDisabledGroup(resultInfo.bfixignore);
                    {
                        // 에셋 ObjectField (읽기 전용 느낌으로)
                        EditorGUILayout.ObjectField(resultInfo._asset, typeof(UnityEngine.Object), false, GUILayout.Width(400));
                        if (GUILayout.Button("ChangeGUID", GUILayout.Width(100)))
                        {
                            var result = AssetGUIDRegenerator.DoRegenerateGUIDs(new string[] { resultInfo._guid }, _generateGuidInfos);
                            SaveGuidData(result);
                            RefreshAssetList();
                        }

                        if (GUILayout.Button("ReverseGUID", GUILayout.Width(100)))
                        {
                            AssetGUIDRegenerator.DoRegenerateGUIDs(new string[] { resultInfo._guid }, _generateGuidInfos, true);
                            RefreshAssetList();
                        }
                    }
                    EditorGUI.EndDisabledGroup();


                    if (GUILayout.Button("Ping", GUILayout.Width(50)))
                    {
                        EditorGUIUtility.PingObject(resultInfo._asset);
                    }

                    EditorGUI.BeginDisabledGroup(resultInfo.bfixignore);
                    {
                        EditorGUILayout.LabelField($"현재 GUID : {resultInfo._guid}", GUILayout.Width(350));

                        // bignore
                        resultInfo.bignore = EditorGUILayout.Toggle($"Ignore", resultInfo.bignore, GUILayout.Width(100));
                    }
                    EditorGUI.EndDisabledGroup();

                    EditorGUILayout.EndHorizontal();
                    GUI.backgroundColor = oldBgColor;
                }
                EditorGUILayout.EndScrollView();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();


            bShowGUIDList = EditorGUILayout.BeginFoldoutHeaderGroup(bShowGUIDList, "GUID 데이터 리스트");
            if (bShowGUIDList)
            {
                _scroll2 = EditorGUILayout.BeginScrollView(_scroll2);
                foreach (var generateGuid in _generateGuidInfos)
                {
                    EditorGUILayout.BeginHorizontal();

                    EditorGUILayout.LabelField($"구 GUID : ", GUILayout.Width(60));
                    EditorGUILayout.TextField($"{generateGuid.orignGuid}", GUILayout.Width(250));
                    EditorGUILayout.LabelField($"-> 새 GUID : ", GUILayout.Width(80));
                    EditorGUILayout.TextField($"{generateGuid.generateGuid}", GUILayout.Width(250));
                    EditorGUILayout.LabelField($"변경 당시 Asset Path : {generateGuid.assetPath}", GUILayout.Width(650));
                    EditorGUILayout.LabelField($"버전 정보 : {generateGuid.version}", GUILayout.Width(200));

                    EditorGUILayout.EndHorizontal();
                }
                EditorGUILayout.EndScrollView();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

        }

        public void RefreshAssetList()
        {
            _resultInfos.Clear();

            if (folder == null)
                return;

            string folderPath = AssetDatabase.GetAssetPath(folder);
            if (string.IsNullOrEmpty(folderPath) || !AssetDatabase.IsValidFolder(folderPath))
                return;

            // 하위 폴더까지 재귀적으로 모든 에셋 GUID 검색
            string[] guids = AssetDatabase.FindAssets("", new[] { folderPath });

            foreach (string guid in guids)
            {
                string assetPath = AssetDatabase.GUIDToAssetPath(guid);

                // 폴더는 제외하고 에셋만
                if (AssetDatabase.IsValidFolder(assetPath))
                    continue;

                UnityEngine.Object asset = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(assetPath);
                if (asset != null)
                {
                    //string path = AssetDatabase.GetAssetPath(asset);
                    //string guid = AssetDatabase.AssetPathToGUID(path);

                    ResultInfo resultInfo = new ResultInfo
                    {
                        _asset = asset,
                        _assetPath = assetPath,
                        _guid = guid,
                        bignore = false,
                    };

                    if (ignoreList.Contains(guid))
                    {
                        resultInfo.bignore = true;
                        resultInfo.bfixignore = true;
                    }

                    _resultInfos.Add(resultInfo);
                }
            }

            // 원하면 이름 기준 정렬
            _resultInfos.Sort((a, b) => string.Compare(a._asset.name, b._asset.name, System.StringComparison.Ordinal));
        }
    }


    internal class AssetGUIDRegenerator
    {
        // Basically, we want to limit the types here (e.g. "t:GameObject t:Scene t:Material").
        // But to support ScriptableObjects dynamically, we just include the base of all assets which is "t:Object"
        private const string SearchFilter = "t:Object";

        //private static readonly string[] SearchDirectories = { "Assets", "Packages" };

        public static List<GenerateGuidInfo> DoRegenerateGUIDs(string[] selectedGUIDs, List<GenerateGuidInfo> generateGuidList, bool isReverse = false, bool isOnlyListGenerate = false)
        {
            AssetDatabase.StartAssetEditing();
            var result = AssetGUIDRegenerator.RegenerateGUIDs(selectedGUIDs, generateGuidList, isReverse, isOnlyListGenerate);
            AssetDatabase.StopAssetEditing();
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            return result;
        }

        public static List<GenerateGuidInfo> RegenerateGUIDs(string[] selectedGUIDs, List<GenerateGuidInfo> generateGuidList, bool isReverse, bool isOnlyListGenerate)
        {
            var assetGUIDs = AssetDatabase.FindAssets("");

            var updatedAssets = new Dictionary<string, int>();
            var skippedAssets = new List<string>();

            var inverseReferenceMap = new Dictionary<string, HashSet<string>>();

            /*
            * PREPARATION PART 1 - Initialize map to store all paths that have a reference to our selectedGUIDs
            */
            foreach (var selectedGUID in selectedGUIDs)
            {
                inverseReferenceMap[selectedGUID] = new HashSet<string>();
            }

            /*
             * PREPARATION PART 2 - Scan all assets and store the inverse reference if contains a reference to any selectedGUI...
             */
            var scanProgress = 0;
            var referencesCount = 0;
            foreach (var guid in assetGUIDs)
            {
                scanProgress++; 
                var path = AssetDatabase.GUIDToAssetPath(guid);
                if (IsDirectory(path)) continue;

                var dependencies = AssetDatabase.GetDependencies(path);
                foreach (var dependency in dependencies)
                {
                    EditorUtility.DisplayProgressBar($"Scanning guid references on:", path, (float) scanProgress / assetGUIDs.Length);

                    var dependencyGUID = AssetDatabase.AssetPathToGUID(dependency);
                    if (inverseReferenceMap.ContainsKey(dependencyGUID))
                    {
                        inverseReferenceMap[dependencyGUID].Add(path);
                        
                        // Also include .meta path. This fixes broken references when an FBX uses external materials
                        var metaPath = AssetDatabase.GetTextMetaFilePathFromAssetPath(path);
                        inverseReferenceMap[dependencyGUID].Add(metaPath);
                        
                        referencesCount++;
                    }
                }
            }

            var countProgress = 0;

            foreach (var selectedGUID in selectedGUIDs)
            {
                bool bPass = false;
                bool bFindGuid = false;
                string findGuid = "";

                // new GUID -----
                foreach (var generateGuidData in generateGuidList)
                {
                    if (isReverse)
                    {
                        bPass = true;
                        if (generateGuidData.generateGuid == selectedGUID)
                        {
                            bPass = false;
                            bFindGuid = true;
                            findGuid = generateGuidData.orignGuid;
                            Debug.LogError($"Find Existing Original GUID: {selectedGUID} -> {findGuid}");
                            break;
                        }
                    }
                    else
                    {

                        // 리스트에 있는 GUID만 변경
                        if (isOnlyListGenerate)
                        {
                            bPass = true;
                            if (generateGuidData.orignGuid == selectedGUID)
                            {
                                bPass = false;
                                bFindGuid = true;
                                findGuid = generateGuidData.generateGuid;
                                Debug.LogError($"Find Existing Generated GUID: {selectedGUID} -> {findGuid}");
                                break;
                            }
                        }
                        else
                        {
                            if (generateGuidData.generateGuid == selectedGUID)
                            {
                                bPass = true;
                                Debug.LogError($"Skip Regenerating GUID as it is already a generated GUID: {selectedGUID}");
                                break;
                            }

                            if (generateGuidData.orignGuid == selectedGUID)
                            {
                                bFindGuid = true;
                                findGuid = generateGuidData.generateGuid;
                                Debug.LogError($"Find Existing Generated GUID: {selectedGUID} -> {findGuid}");
                                break;
                            }
                        }

                    }
                }

                if (bPass)
                    continue;

                string newGUID = "";
                if(bFindGuid)
                    newGUID = findGuid;
                else
                    newGUID  = GUID.Generate().ToString();

                try
                {
                    /*
                     * PART 1 - Replace the GUID of the selected asset itself. If the .meta file does not exists or does not match the guid (which shouldn't happen), do not proceed to part 2
                     */
                    var assetPath = AssetDatabase.GUIDToAssetPath(selectedGUID);
                    var metaPath = AssetDatabase.GetTextMetaFilePathFromAssetPath(assetPath);

                    if (!File.Exists(metaPath))
                    {
                        skippedAssets.Add(assetPath);
                        throw new FileNotFoundException($"The meta file of selected asset cannot be found. Asset: {assetPath}");
                    }

                    var metaContents = File.ReadAllText(metaPath);

                    // Check if guid in .meta file matches the guid of selected asset
                    if (!metaContents.Contains(selectedGUID))
                    {
                        skippedAssets.Add(assetPath);
                        throw new ArgumentException($"The GUID of [{assetPath}] does not match the GUID in its meta file.");
                    }

                    // Allow regenerating guid of folder because modifying it doesn't seem to be harmful
                    // if (IsDirectory(assetPath)) continue;

                    // Skip scene files
                    if (assetPath.EndsWith(".unity"))
                    {
                        skippedAssets.Add(assetPath);
                        continue;
                    }

                    var metaAttributes = File.GetAttributes(metaPath);
                    var bIsInitiallyHidden = false;

                    // If the .meta file is hidden, unhide it temporarily
                    if (metaAttributes.HasFlag(FileAttributes.Hidden))
                    {
                        bIsInitiallyHidden = true;
                        HideFile(metaPath, metaAttributes);
                    }

                    metaContents = metaContents.Replace(selectedGUID, newGUID);
                    File.WriteAllText(metaPath, metaContents);

                    if (bIsInitiallyHidden) UnhideFile(metaPath, metaAttributes);

                    if (IsDirectory(assetPath))
                    {
                        // Skip PART 2 for directories as they should not have any references in assets or scenes
                        updatedAssets.Add(AssetDatabase.GUIDToAssetPath(selectedGUID), 0);
                        continue;
                    }

                    /*
                     * PART 2 - Update the GUID for all assets that references the selected GUID
                     */
                    var countReplaced = 0;
                    var referencePaths = inverseReferenceMap[selectedGUID];
                    foreach(var referencePath in referencePaths)
                    {
                        countProgress++;

                        EditorUtility.DisplayProgressBar($"Regenerating GUID: {assetPath}", referencePath, (float) countProgress / referencesCount);

                        if (IsDirectory(referencePath)) continue;

                        var contents = File.ReadAllText(referencePath);

                        if (!contents.Contains(selectedGUID)) continue;

                        contents = contents.Replace(selectedGUID, newGUID);
                        File.WriteAllText(referencePath, contents);

                        countReplaced++;
                    }

                    updatedAssets.Add(AssetDatabase.GUIDToAssetPath(selectedGUID), countReplaced);
                }
                catch (Exception e)
                {
                    Debug.LogError(e);
                }
                finally
                {
                    EditorUtility.ClearProgressBar();
                }

                if(!bFindGuid)
                {
                    GenerateGuidInfo info = new GenerateGuidInfo
                    {
                        version = DateTime.Now.ToString("MMddHHmm"),
                        orignGuid = selectedGUID,
                        generateGuid = newGUID,
                        assetPath = AssetDatabase.GUIDToAssetPath(selectedGUID),
                        description = ""
                    };
                    generateGuidList.Add(info);
                }
            }

            if (EditorUtility.DisplayDialog("Regenerate GUID",
                $"Regenerated GUID for {updatedAssets.Count} assets. \nSee console logs for detailed report.", "Done"))
            {
                var message = $"<b>GUID Regenerator</b>\n";

                if (updatedAssets.Count > 0) message += $"<b><color=green>{updatedAssets.Count} Updated Asset/s</color></b>\tSelect this log for more info\n";
                message = updatedAssets.Aggregate(message, (current, kvp) => current + $"{kvp.Value} references\t{kvp.Key}\n");

                if (skippedAssets.Count > 0) message += $"\n<b><color=red>{skippedAssets.Count} Skipped Asset/s</color></b>\n";
                message = skippedAssets.Aggregate(message, (current, skipped) => current + $"{skipped}\n");

                Debug.Log($"{message}");
            }

            return generateGuidList;
        }

        // Searches for Directories and extracts all asset guids inside it using AssetDatabase.FindAssets
        public static string[] ExtractGUIDs(string[] selectedGUIDs, bool includeFolders)
        {
            var finalGuids = new List<string>();
            foreach (var guid in selectedGUIDs)
            {
                var assetPath = AssetDatabase.GUIDToAssetPath(guid);
                if (IsDirectory(assetPath))
                {
                    string[] searchDirectory = {assetPath};

                    if (includeFolders) finalGuids.Add(guid);
                    finalGuids.AddRange(AssetDatabase.FindAssets(SearchFilter, searchDirectory));
                }
                else
                {
                    finalGuids.Add(guid);
                }
            }

            return finalGuids.ToArray();
        }

        private static void HideFile(string path, FileAttributes attributes)
        {
            attributes &= ~FileAttributes.Hidden;
            File.SetAttributes(path, attributes);
        }

        private static void UnhideFile(string path, FileAttributes attributes)
        {
            attributes |= FileAttributes.Hidden;
            File.SetAttributes(path, attributes);
        }

        public static bool IsDirectory(string path) => File.GetAttributes(path).HasFlag(FileAttributes.Directory);


        /// <summary>
        /// GenerateGuidInfo 리스트를 CSV 파일로 저장
        /// </summary>
        public static void SaveToCsv(string filePath, IList<GenerateGuidInfo> list)
        {
            if (list == null)
            {
                Debug.LogWarning("SaveToCsv: list is null");
                return;
            }

            var sb = new StringBuilder();

            // 헤더
            sb.AppendLine("version,orignGuid,generateGuid,assetPath,description");

            foreach (var item in list)
            {
                string line = string.Join(",",
                    EscapeCsv(item.version),
                    EscapeCsv(item.orignGuid),
                    EscapeCsv(item.generateGuid),
                    EscapeCsv(item.assetPath),
                    EscapeCsv(item.description)
                );

                sb.AppendLine(line);
            }

            // UTF-8 with BOM (엑셀 호환용)
            var encoding = new UTF8Encoding(encoderShouldEmitUTF8Identifier: true);
            File.WriteAllText(filePath, sb.ToString(), encoding);

            Debug.Log($"GenerateGuidInfoCsvUtility.SaveToCsv: Saved {list.Count} rows to {filePath}");
        }

        /// <summary>
        /// CSV 파일에서 GenerateGuidInfo 리스트를 로드
        /// </summary>
        public static List<GenerateGuidInfo> LoadFromCsv(string filePath)
        {
            var result = new List<GenerateGuidInfo>();

            if (!File.Exists(filePath))
            {
                Debug.LogWarning($"LoadFromCsv: File not found: {filePath}");
                return result;
            }

            // UTF-8로 읽기 (BOM 자동 처리)
            string[] lines = File.ReadAllLines(filePath, Encoding.UTF8);
            if (lines.Length <= 1)
            {
                return result;
            }

            // 0번 라인은 헤더라 가정하고 1번부터 읽음
            for (int i = 1; i < lines.Length; i++)
            {
                string line = lines[i];

                if (string.IsNullOrWhiteSpace(line))
                    continue;

                List<string> fields = ParseCsvLine(line);

                // 컬럼 수 체크 (4개 미만이면 스킵)
                if (fields.Count < 4)
                {
                    Debug.LogWarning($"LoadFromCsv: Invalid line (not enough columns) at {i}: {line}");
                    continue;
                }

                var info = new GenerateGuidInfo
                {
                    version = fields[0],
                    orignGuid = fields[1],
                    generateGuid = fields[2],
                    assetPath = fields[3],
                    description = fields[4],
                };

                result.Add(info);
            }

            Debug.Log($"GenerateGuidInfoCsvUtility.LoadFromCsv: Loaded {result.Count} rows from {filePath}");
            return result;
        }

        /// <summary>
        /// CSV 필드 이스케이프
        /// 콤마, 따옴표, 줄바꿈이 있으면 "로 감싸고 내부의 "는 "" 로 치환
        /// </summary>
        private static string EscapeCsv(string value)
        {
            if (string.IsNullOrEmpty(value))
                return "";

            bool mustQuote =
                value.Contains(",") ||
                value.Contains("\"") ||
                value.Contains("\n") ||
                value.Contains("\r");

            if (mustQuote)
            {
                value = value.Replace("\"", "\"\""); // " -> ""
                return $"\"{value}\"";
            }

            return value;
        }

        /// <summary>
        /// CSV 한 줄을 파싱해서 필드 리스트로 반환
        /// (따옴표/콤마 처리)
        /// </summary>
        private static List<string> ParseCsvLine(string line)
        {
            var result = new List<string>();
            if (string.IsNullOrEmpty(line))
            {
                result.Add("");
                return result;
            }

            var sb = new StringBuilder();
            bool inQuotes = false;

            for (int i = 0; i < line.Length; i++)
            {
                char c = line[i];

                if (inQuotes)
                {
                    if (c == '"')
                    {
                        // "" -> "
                        if (i + 1 < line.Length && line[i + 1] == '"')
                        {
                            sb.Append('"');
                            i++; // 다음 따옴표 스킵
                        }
                        else
                        {
                            // 닫는 따옴표
                            inQuotes = false;
                        }
                    }
                    else
                    {
                        sb.Append(c);
                    }
                }
                else
                {
                    if (c == ',')
                    {
                        // 필드 종료
                        result.Add(sb.ToString());
                        sb.Length = 0;
                    }
                    else if (c == '"')
                    {
                        // 따옴표 필드 시작
                        inQuotes = true;
                    }
                    else
                    {
                        sb.Append(c);
                    }
                }
            }

            // 마지막 필드 추가
            result.Add(sb.ToString());

            return result;
        }
    }
}

public class GuidReferenceSearcherMenu
{
    //[MenuItem("Tools/GUID/Find References (Deleted Asset)")]
    //public static void FindReferences(string guid)
    //{
    //    if (string.IsNullOrEmpty(guid))
    //    {
    //        Debug.LogWarning("GUID가 비어 있습니다.");
    //        return;
    //    }

    //    var list = GuidReferenceSearcher.FindAssetsThatContainGuidText(guid);

    //    if (list.Count == 0)
    //    {
    //        Debug.Log($"GUID {guid} 를 참조하는 에셋을 찾지 못했습니다.");
    //        return;
    //    }

    //    Debug.Log($"GUID {guid} 를 참조하는 에셋 목록 ({list.Count}개):");
    //    foreach (var path in list)
    //    {
    //        var obj = AssetDatabase.LoadAssetAtPath<UnityEngine.Object>(path);
    //        Debug.Log(path, obj);
    //    }
    //}
}

public static class GuidReferenceSearcher
{
    // 검색할 확장자들 (필요에 따라 추가/삭제 가능)
    private static readonly string[] TargetExtensions =
    {
        ".unity",   // 씬
        ".prefab",  // 프리팹
        ".asset",   // ScriptableObject 등
        ".mat",     // 머티리얼
        ".anim",    // 애니메이션
        ".controller",        // Animator Controller
        ".overrideController" // Animator Override Controller
        // 필요하면 더 추가
    };

    /// <summary>
    /// 삭제된 리소스여도 GUID 문자열을 포함하고 있는 모든 에셋 경로를 찾는다.
    /// </summary>
    public static List<string> FindAssetsThatContainGuidText(string checkPath, List<GenerateGuidInfo> generateGuidInfos, bool bChangeGUID)
    {
        var result = new List<string>();

        string assetsRoot = Application.dataPath; // 예: C:/Project/Assets
        //var allFiles = Directory.GetFiles(assetsRoot, "*.*", SearchOption.AllDirectories);
        var allFiles = Directory.GetFiles(checkPath, "*.*", SearchOption.AllDirectories);

        foreach (var fullPath in allFiles)
        {
            string ext = Path.GetExtension(fullPath);
            if (!IsTargetExtension(ext))
                continue;

            string text;
            try
            {
                text = File.ReadAllText(fullPath);
            }
            catch
            {
                // 바이너리거나 읽기 오류 등
                continue;
            }

            bool bEdit = false;
            foreach (var generateGuidInfo in generateGuidInfos)
            {
                if (text.Contains(generateGuidInfo.orignGuid))
                {
                    if(bChangeGUID)
                    {
                        text = text.Replace(generateGuidInfo.orignGuid, generateGuidInfo.generateGuid);
                        bEdit = true;
                    }
                    Debug.LogError($"Path :{fullPath}, GUID : {generateGuidInfo.orignGuid}");
                }
            }
            
            if (bEdit)
            {
                File.WriteAllText(fullPath, text);
                Debug.LogError($"Write File : {fullPath}");
            }
        }

        Debug.LogError($"체크 완료");

        return result;
    }

    public class deleteReult
    {
        public string _assetPath;
        public string _guid;
    }

    public static void FindAssetsAndDelete(string folderPath, List<GenerateGuidInfo> generateGuidInfos)
    {
        // 하위 폴더까지 재귀적으로 모든 에셋 GUID 검색
        string[] guids = AssetDatabase.FindAssets("", new[] { folderPath });
        List<deleteReult> deleteAssetPaths = new List<deleteReult>();

        foreach (string guid in guids)
        {
            string assetPath = AssetDatabase.GUIDToAssetPath(guid);

            // 폴더는 제외하고 에셋만
            if (AssetDatabase.IsValidFolder(assetPath))
                continue;

            foreach (var generateGuidInfo in generateGuidInfos)
            {
                if (generateGuidInfo.orignGuid == guid)
                {
                    string newAssetPath = AssetDatabase.GUIDToAssetPath(generateGuidInfo.generateGuid);
                    if(newAssetPath != string.Empty)
                        deleteAssetPaths.Add( new deleteReult() { _assetPath = assetPath, _guid = guid });
                }
            }
        }

        foreach (var path in deleteAssetPaths)
        {
            if (string.IsNullOrEmpty(path._assetPath))
                continue;

            bool success = AssetDatabase.DeleteAsset(path._assetPath);

            if (!success)
                Debug.LogWarning($"삭제 실패: {path._assetPath}, GUID {path._guid}");

            Debug.LogWarning($"삭제한 Asset : {path._assetPath} , GUID {path._guid}");
        }

        AssetDatabase.Refresh();
    }


    private static bool IsTargetExtension(string ext)
    {
        if (string.IsNullOrEmpty(ext))
            return false;

        for (int i = 0; i < TargetExtensions.Length; i++)
        {
            if (ext.Equals(TargetExtensions[i], System.StringComparison.OrdinalIgnoreCase))
                return true;
        }

        return false;
    }
}
#endif
