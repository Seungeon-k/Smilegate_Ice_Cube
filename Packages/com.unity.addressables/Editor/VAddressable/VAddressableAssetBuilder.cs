using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor.AddressableAssets;
using UnityEditor.AddressableAssets.Build;
using UnityEditor.AddressableAssets.GUI;
using UnityEditor.AddressableAssets.Settings;
using UnityEditor.AddressableAssets.Settings.GroupSchemas;
using UnityEditor.Build.Pipeline.Utilities;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.VAddressable;
using Object = UnityEngine.Object;

namespace UnityEditor.VAddressable
{
    [Serializable]
    public class VAddressableAssetBuilder
    {
        public VAddressableGroupCategory activeCategory;
        public BuildScope buildScope = BuildScope.CategoryOnly;

        public List<VAddressableGroupCategory> Categories => AddressableCategoryUtil.GetCategoryAll();
        
        public static void DoGUI(Object targetObject)
        {
            var builder = AddressableAssetSettingsDefaultObject.Settings.Builder;
            DoGUI(builder, targetObject);
        }

        public static void DoGUI(VAddressableAssetBuilder builder, Object targetObject)
        {
            List<VAddressableGroupCategory> categories = builder.Categories;
            var categoryNames = categories.Select(category => category.name).ToArray();
            var currentCategoryIndex = categories.IndexOf(builder.activeCategory);
            if (currentCategoryIndex == -1)
            {
                currentCategoryIndex = categories.Count - 1;
            }
                
            EditorGUI.BeginChangeCheck();
            var newCategoryIndex = EditorGUILayout.Popup(new GUIContent("Category"), currentCategoryIndex, categoryNames);
            if (EditorGUI.EndChangeCheck() && newCategoryIndex != currentCategoryIndex)
            {
                if (targetObject != null)
                {
                    Undo.RecordObject(targetObject, targetObject.name + "Builder Category Index");
                }
                
                builder.activeCategory = categories[newCategoryIndex];
                
                SetDirtyAndSelection();
            }
                
            EditorGUI.BeginChangeCheck();
            var currentCategoryRange = builder.buildScope;
            var newCategoryRange = (BuildScope)EditorGUILayout.Popup(new GUIContent("BuildScope"), (int)currentCategoryRange, Enum.GetNames(typeof(BuildScope)));
            if (EditorGUI.EndChangeCheck() && newCategoryRange != currentCategoryRange)
            {
                if (targetObject != null)
                {
                    Undo.RecordObject(targetObject, targetObject.name + "Builder Category BuildScope");
                }
                
                builder.buildScope = newCategoryRange;
                
                SetDirtyAndSelection();
            }
            
            // GUILayout.Space(12f);
            // if (GUILayout.Button(new GUIContent("Update Catalog Build/Load Path"), "Minibutton", GUILayout.ExpandWidth(true)))
            // {
            //     UpdateCatalogFromCategory(builder.activeCategory);
            //     
            //     SetDirtyAndSelection();
            // }
                
            // if (GUILayout.Button(new GUIContent("Include All Groups In Build"), "Minibutton", GUILayout.ExpandWidth(true)))
            // {
            //     IncludeAllGroupsInBuild();
            //     
            //      SetDirtyAndSelection();
            // }
                
            // if (GUILayout.Button(new GUIContent("Update Include In Build"), "Minibutton", GUILayout.ExpandWidth(true)))
            // {
            //     UpdateIncludeInBuildFromCategory();
            // }

            return;

            void SetDirtyAndSelection()
            {
                EditorUtility.SetDirty(AddressableAssetSettingsDefaultObject.Settings);
                Selection.activeObject = AddressableAssetSettingsDefaultObject.Settings;
            }
        }

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        public static string VBuildPath => AddressableAssetSettingsDefaultObject.Settings.profileSettings.GetValueByName(AddressableAssetSettingsDefaultObject.Settings.activeProfileId, nameof(VBuildPath));

        public static string VArchiveDirectoryPath
        {
            get => SessionState.GetString("VBGenerate_LocationPath", null);
            set
            {
                SessionState.SetString("VBGenerate_LocationPath", value);
            }
        }

        public static void SetDefaultVArchiveDirectoryPath()
        {
            VArchiveDirectoryPath = "Bundles";
        }
        
        public static List<BuildTarget> BuildTargets = new()
        {
            BuildTarget.StandaloneWindows64,
            BuildTarget.StandaloneLinux64,
            BuildTarget.Android,
            BuildTarget.iOS
        };

        private static void SetProfile(string profile)
        {
            var settings = AddressableAssetSettingsDefaultObject.Settings;
            string profileId = settings.profileSettings.GetProfileId(profile);
            if (String.IsNullOrEmpty(profileId))
                Debug.LogWarning($"Couldn't find a profile named, {profile}, " + $"using current profile instead.");
            else
                settings.activeProfileId = profileId;
        }

        public static void UpdateCatalogFromActiveCategory()
        {
            UpdateCatalogFromCategory(AddressableAssetSettingsDefaultObject.Settings.Builder.activeCategory);
        }
        
        public static void UpdateCatalogFromCategory(VAddressableGroupCategory category)
        {
            var settings = AddressableAssetSettingsDefaultObject.Settings;

            settings.RemoteCatalogBuildPath.SetVariableByName(settings, $"{category.name}{ProfileGroupType.k_PrefixSeparator}BuildPath");
            settings.RemoteCatalogLoadPath.SetVariableByName(settings, $"{category.name}{ProfileGroupType.k_PrefixSeparator}LoadPath");
            
            EditorUtility.SetDirty(settings);
        }

        public static void IncludeAllGroupsInBuild () => SetIncludeInBuildForAllGroups(true);

        private static void SetIncludeInBuildForAllGroups(bool isIncludeInBuild)
        {
            var groups = AddressableAssetSettingsDefaultObject.Settings.groups;
            groups.ForEach(group =>
            {
                var bundleSchema = group.GetSchema<BundledAssetGroupSchema>();
                if (bundleSchema == null) return;
                
                bundleSchema.IncludeInBuild = isIncludeInBuild;
            });
        }

        public static void UpdateIncludeInBuildFromCategory()
        {
            var builder = AddressableAssetSettingsDefaultObject.Settings.Builder;
            var groups = AddressableAssetSettingsDefaultObject.Settings.groups;
            var activeCategory = builder.activeCategory;
            var categoryRange = builder.buildScope;
            
            if(categoryRange == BuildScope.CategoryOnly)
            {
                
                //activeCategory를 제외한 나머지 Category의 Group은 include in build = false
                foreach (var group in groups)
                {
                    var bundleSchema = group.GetSchema<BundledAssetGroupSchema>();
                    if (bundleSchema == null)
                        continue;

                    //var groupCategory = AddressableCategoryUtil.GetCategory(group);
                    bundleSchema.IncludeInBuild = true;//(groupCategory == activeCategory);
                    EditorUtility.SetDirty(bundleSchema);
                    //Debug.Log($"groupCategory: {groupCategory} groupName: {group.Name} bundleSchema.IncludeInBuild: {bundleSchema.IncludeInBuild}");
                }
            }
            else
            {
                //activeCategory랑 dependencies 전부 순회하고 Union 한것들 제외하고 include in build = false
                var categoriesToInclude = new HashSet<VAddressableGroupCategory>();
                if (activeCategory != null)
                {
                    var queue = new Queue<VAddressableGroupCategory>();
                    queue.Enqueue(activeCategory);
                    categoriesToInclude.Add(activeCategory);

                    while (queue.Count > 0)
                    {
                        var current = queue.Dequeue();
                        if (current.Dependencies != null)
                        {
                            foreach (var dep in current.Dependencies)
                            {
                                if (dep != null && categoriesToInclude.Add(dep))
                                {
                                    queue.Enqueue(dep);
                                }
                            }
                        }
                    }
                }

                foreach (var group in groups)
                {
                    var bundleSchema = group.GetSchema<BundledAssetGroupSchema>();
                    if (bundleSchema == null)
                        continue;

                    var groupCategory = AddressableCategoryUtil.GetCategory(group);
                    bundleSchema.IncludeInBuild = categoriesToInclude.Contains(groupCategory);
                    EditorUtility.SetDirty(bundleSchema);
                    //Debug.Log($"groupCategory: {groupCategory} groupName: {group.Name} bundleSchema.IncludeInBuild: {bundleSchema.IncludeInBuild}");;
                }
            }
        }
        
        public static (bool, string) Build(BuildTarget buildTarget, bool isSkipArchive = false)
        {
            var settings = AddressableAssetSettingsDefaultObject.Settings;
            AddressableAssetsSettingsGroupEditor.BuildMenuContext context = new AddressableAssetsSettingsGroupEditor.BuildMenuContext()
            {
                buildScriptIndex = -1,
                BuildMenu = new AddressablesBuildMenuUpdateVulcanus(),
                Settings = settings,
                BuildTarget = buildTarget
            };

            AddressableAssetsSettingsGroupEditor.OnBuildAddressablesWithBuildResult(context, out var result);

            if (!string.IsNullOrEmpty(result.Error))
            {
                return (false, $"vaddressable build error: {result.Error}");
            }
            
            VAddressableCatalogBuilder.Build(context, VBuildPath);
            
            if(isSkipArchive) return (true, string.Empty);
            
            VAddressableZipper.Archive(context.BuildTarget, VBuildPath, VArchiveDirectoryPath);

            return (true, string.Empty);
        }

        public static string GetZipperDestinationArchiveFileName(BuildTarget buildTarget)
        {
            return VAddressableZipper.GetZipperDestinationArchiveFileName(buildTarget, VArchiveDirectoryPath);
        }
        
        public static string GetMergedFileName(BuildTarget buildTarget)
        {
            return VAddressableZipper.GetMergedFileName(buildTarget, VArchiveDirectoryPath);
        }

        //[MenuItem("Window/Asset Management/Addressables/Build With SaveFolderPanel (Current BuildTarget)")]
        public static void BuildWithSaveFolderPanel()
        {
            var savedFolderPath = EditorUtility.SaveFolderPanel("Save bundle to folder", "", "");
            if (string.IsNullOrWhiteSpace(savedFolderPath))
            {
                Debug.Log("Save folder path is empty.");
                return;
            }

            var settings = AddressableAssetSettingsDefaultObject.Settings;
            AddressableAssetsSettingsGroupEditor.BuildMenuContext context = new AddressableAssetsSettingsGroupEditor.BuildMenuContext()
            {
                buildScriptIndex = -1,
                BuildMenu = new AddressablesBuildMenuUpdateVulcanus(),
                Settings = settings,
                BuildTarget = EditorUserBuildSettings.activeBuildTarget
            };

            AddressableAssetsSettingsGroupEditor.OnBuildAddressables(context);

            //AddressableAssetZip.ZipAssetBundles(AddressableAssetSettingsDefaultObject.Settings.Builder.activeCategory, context.BuildTarget, savedFolderPath, deleteSourceDirectory: true);
        }

        public static void ClearBuildCacheAll()
        {
            //Library/com.unity.addressables/aa
            var targetDirectory = Path.Combine(Addressables.LibraryPath, Addressables.StreamingAssetsSubFolder);
            if (Directory.Exists(targetDirectory))
            {
                Directory.Delete(targetDirectory, true);
            }
            BuildCache.PurgeCache(false);
        }

        public static void ClearAddressablesContentStateBinFileAll()
        {
            foreach (var buildTarget in BuildTargets)
            {
                var targetDirectory = Path.GetDirectoryName(Application.dataPath) + "/" + Addressables.LibraryPath + PlatformMappingService.GetAddressablesPlatformPathInternal(buildTarget);
                if (Directory.Exists(targetDirectory))
                {
                    Directory.Delete(targetDirectory, true);
                }    
            }
            
            Directory.Delete(AddressableAssetSettingsDefaultObject.kDefaultConfigFolder, true);
        }

        public static void ClearBundles()
        {
            ClearDirectory(VArchiveDirectoryPath);
            
            void ClearDirectory(string path)
            {
                if (!Directory.Exists(path))
                    return;

                // 모든 파일 삭제
                foreach (var file in Directory.GetFiles(path))
                {
                    File.Delete(file);
                }

                // 모든 서브 폴더 삭제
                foreach (var dir in Directory.GetDirectories(path))
                {
                    Directory.Delete(dir, true);
                }
            }
        }

        public static bool BeginFoldoutHeaderGroupWithHelp(bool isActive, GUIContent content, Action helpAction = null, int indent = 0, Action<Rect> menuAction = null)
            => AddressablesGUIUtility.BeginFoldoutHeaderGroupWithHelp(isActive, content, helpAction, indent, menuAction);
    }
    
    

    // Unity Linux, iOS 에러가 발생함
    // [MenuItem("Window/Asset Management/Addressables/Build (All BuildTarget)")]
    // public static void BuildAll()
    // {
    //     BuildTarget activeBuildTarget = EditorUserBuildSettings.activeBuildTarget;
    //     var sw = Stopwatch.StartNew();
    //     try
    //     {
    //         List<BuildTarget> buildTargets = new()
    //         {
    //             /* BuildTarget.StandaloneLinux64 ,*/ BuildTarget.StandaloneWindows64, BuildTarget.Android, BuildTarget.iOS
    //         };
    //         buildTargets.ForEach(Build);
    //     }
    //     finally
    //     {
    //         EditorUserBuildSettings.SwitchActiveBuildTarget(BuildPipeline.GetBuildTargetGroup(activeBuildTarget), activeBuildTarget);
    //         sw.Stop();
    //         Debug.Log($"BuildAll execution time: {sw.ElapsedMilliseconds}ms");
    //     }
    // }



}