
#if UNITY_EDITOR

using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;

namespace DevTool
{
    public class DependencyResultInfo
    {
        public UnityEngine.Object _asset;
        public string _assetPath;
        public string _guid;
        public List<string> _dependentPaths = new List<string>();
    }


    public class VFolderDependenceCheckorWindow : EditorWindow
    {
        public static string EssentialPath = $"Packages/com.v.gameframework.resources/Runtime/Essential";
        public static string OfficialPath = $"Packages/com.v.gameframework.resources/Runtime/Official";


        [SerializeField] private DefaultAsset assetFolder;
        [SerializeField] private DefaultAsset findFolder;

        private List<DependencyResultInfo>              _resultInfos        = new List<DependencyResultInfo>();
        private Dictionary<string, HashSet<string>>     _dependencyData    = new Dictionary<string, HashSet<string>>();

        private Vector2 _scroll1;
        private bool bShowAssetList = true;


        [MenuItem("Tools/DevTools/VFolderDependenceCheckor")]
        public static void Open()
        {
            GetWindow<VFolderDependenceCheckorWindow>("VFolderDependenceCheckorWindow");
        }

        private void OnGUI()
        {
            EditorGUI.BeginChangeCheck();
            assetFolder = (DefaultAsset)EditorGUILayout.ObjectField("Asset Folder", assetFolder, typeof(DefaultAsset), false); // Scene 오브젝트 불가
            if (EditorGUI.EndChangeCheck())
            {
                // 폴더가 바뀌면 자동으로 리스트 갱신
                RefreshAssetList();
            }

            findFolder = (DefaultAsset)EditorGUILayout.ObjectField("Find Folder", findFolder, typeof(DefaultAsset), false); // Scene 오브젝트 불가


            if (GUILayout.Button("새로고침"))
            {
                RefreshAssetList();
            }

            if (GUILayout.Button("디펜더시 체크"))
            {
                List<string> guidsToChange = new List<string>();
                foreach (var resultInfo in _resultInfos)
                    guidsToChange.Add(resultInfo._guid);

                string findFolderPath = AssetDatabase.GetAssetPath(findFolder);
                _dependencyData = VFolderDependencyCheckor.VFolderDependencyCheck(findFolderPath, guidsToChange.ToArray());
            }

            EditorGUILayout.Space();
            EditorGUILayout.LabelField($"에셋 개수: {_resultInfos.Count}", EditorStyles.boldLabel);
            bShowAssetList = EditorGUILayout.BeginFoldoutHeaderGroup(bShowAssetList, "에셋 리스트");
            if (bShowAssetList)
            {
                // 에셋 리스트 표시
                _scroll1 = EditorGUILayout.BeginScrollView(_scroll1);
                foreach (var resultInfo in _resultInfos)
                {
                    EditorGUILayout.BeginHorizontal();

                    // 에셋 ObjectField (읽기 전용 느낌으로)
                    EditorGUILayout.ObjectField(resultInfo._asset, typeof(UnityEngine.Object), false);

                    if (GUILayout.Button("Ping", GUILayout.Width(50)))
                        EditorGUIUtility.PingObject(resultInfo._asset);

                    EditorGUILayout.EndHorizontal();

                    if(_dependencyData == null || !_dependencyData.ContainsKey(resultInfo._guid))
                        continue;

                    HashSet<string> dependencylist = _dependencyData[resultInfo._guid];
                    foreach (var list in dependencylist)
                    {
                        EditorGUILayout.BeginHorizontal();
                        EditorGUILayout.LabelField($"    └─ {list}");
                        EditorGUILayout.EndHorizontal();
                    }
                }
                EditorGUILayout.EndScrollView();
            }
            EditorGUILayout.EndFoldoutHeaderGroup();

        }

        private void RefreshAssetList()
        {
            _resultInfos.Clear();

            if (assetFolder == null)
                return;

            string folderPath = AssetDatabase.GetAssetPath(assetFolder);
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

                    DependencyResultInfo resultInfo = new DependencyResultInfo
                    {
                        _asset = asset,
                        _assetPath = assetPath,
                        _guid = guid
                    };
                    _resultInfos.Add(resultInfo);
                }
            }

                    // 원하면 이름 기준 정렬
            _resultInfos.Sort((a, b) => string.Compare(a._asset.name, b._asset.name, System.StringComparison.Ordinal));
        }
    }

    public class VFolderDependencyCheckor
    {
        public static string OfficialPath = $"Packages/com.v.gameframework.resources/Runtime/Official";

        public static Dictionary<string, HashSet<string>> VFolderDependencyCheck(string findPath, string[] selectedGUIDs)
        {
            var inverseReferenceMap = new Dictionary<string, HashSet<string>>();
            foreach (var selectedGUID in selectedGUIDs)
            {
                inverseReferenceMap[selectedGUID] = new HashSet<string>();
            }

            string[] guids = AssetDatabase.FindAssets("", new[] { findPath });
            foreach (var guid in guids)
            {
                var path = AssetDatabase.GUIDToAssetPath(guid);
                if (IsDirectory(path)) continue;

                var dependencies = AssetDatabase.GetDependencies(path);
                foreach (var dependency in dependencies)
                {
                    var dependencyGUID = AssetDatabase.AssetPathToGUID(dependency);
                    if (inverseReferenceMap.ContainsKey(dependencyGUID))
                    {
                        inverseReferenceMap[dependencyGUID].Add(path);
                    }
                }
            }

            return inverseReferenceMap;
        }

        public static bool IsDirectory(string path) => File.GetAttributes(path).HasFlag(FileAttributes.Directory);

    }

}
#endif
