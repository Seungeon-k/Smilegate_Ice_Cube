using System.Collections.Generic;
using System.Linq;
using UnityEditor.VAddressable;
using UnityEngine;

namespace UnityEditor.AddressableAssets.Settings.GroupSchemas
{
    // 각 Group에 부착될 Schema: 카테고리 이름 저장
    [CreateAssetMenu(menuName = "Addressables/Category/Group Category Schema", fileName = "VAddressableGroupCategorySchema")]
    public class VAddressableGroupCategorySchema : AddressableAssetGroupSchema
    {
        [SerializeField] private VAddressableGroupCategory _category;

        public VAddressableGroupCategory Category
        {
            get => _category;
            set
            {
                _category = value;
                SetDirty(true);
            }
        }

        public string CategoryName => _category == null ? AddressableCategoryUtil.DefaultCategory : _category.name;

        public override void OnGUI()
        {
            EditorGUI.BeginChangeCheck();
            var newCategory = EditorGUILayout.ObjectField("Category", _category, typeof(VAddressableGroupCategory), false) as VAddressableGroupCategory;

            if (EditorGUI.EndChangeCheck())
            {
                if (_category != newCategory)
                {
                    Undo.RecordObject(this, "Change Category");
                    _category = newCategory;
                    SetDirty(true);
                }
            }

        }
    }

    public static class AddressableCategoryUtil
    {
        public const string DefaultCategory = "Uncategorized";
        public const string DefaultCategoryPath = "Assets/AddressableAssetsData/GroupCategories/Uncategorized.asset";
        public const string CategoryDirectoryPath = "Assets/AddressableAssetsData/GroupCategories";

        public static VAddressableGroupCategory GetCategory(AddressableAssetGroup group)
        {
            if (group == null) return null;
            
            var s = group.GetSchema<VAddressableGroupCategorySchema>();
            if (s == null || s.Category == null)
            {
                return AssetDatabase.LoadAssetAtPath<VAddressableGroupCategory>(DefaultCategoryPath);
            }
            
            return s.Category;
        }
        public static List<VAddressableGroupCategory> GetCategoryAll()
        {
            var guids = AssetDatabase.FindAssets($"t:{nameof(VAddressableGroupCategory)}", new[] { CategoryDirectoryPath });
            return guids
                .Select(AssetDatabase.GUIDToAssetPath)
                .Select(AssetDatabase.LoadAssetAtPath<VAddressableGroupCategory>)
                .Where(c => c != null)
                .ToList();
        }


        public static void SetCategory(AddressableAssetGroup group, VAddressableGroupCategory category)
        {
            if (group == null) return;
            var s = group.GetSchema<VAddressableGroupCategorySchema>();
            if (s == null)
                s = group.AddSchema<VAddressableGroupCategorySchema>();

            s.Category = category;

            var bundledAssetGroupSchema = group.GetSchema<BundledAssetGroupSchema>();
            if (bundledAssetGroupSchema != null)
            {
                var settings = AddressableAssetSettingsDefaultObject.Settings;
                bundledAssetGroupSchema.BuildPath.SetVariableByName(settings, $"{s.Category.name}{ProfileGroupType.k_PrefixSeparator}BuildPath");
                bundledAssetGroupSchema.LoadPath.SetVariableByName(settings, $"{s.Category.name}{ProfileGroupType.k_PrefixSeparator}LoadPath");
            }
            
            group.SetDirty(AddressableAssetSettings.ModificationEvent.GroupSchemaModified, group, true, true);
        }
    }
}