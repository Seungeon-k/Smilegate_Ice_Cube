using System;
using System.Collections.Generic;
using System.Globalization;
using UnityEditor.AddressableAssets.GUI;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.VAddressable;

namespace UnityEditor.VAddressable
{
    public class VAddressableCatalogBuilder
    {
        public static void Build(AddressableAssetsSettingsGroupEditor.BuildMenuContext context, string buildPath, string version = "1.0.0")
        {
            var data = BuildData(context, version);
            
            var jsonText = JsonUtility.ToJson(data);
            
            if (data.UserFrameworkMode == UserFrameworkMode.USGUser || data.UserFrameworkMode == UserFrameworkMode.GameUser)
            {
                var vcatalogUserPath = $"{buildPath}/{VAddressableCatalogData.GetUserFileName()}";
                VAddressableUtil.WriteFile(vcatalogUserPath, jsonText);
            }
            else
            {
                var vcatalogVPath = $"{buildPath}/{VAddressableCatalogData.GetVFileName(data.ActiveCategoryData.Name)}";
                VAddressableUtil.WriteFile(vcatalogVPath, jsonText);
            }
        }

        private static VAddressableCatalogData BuildData(AddressableAssetsSettingsGroupEditor.BuildMenuContext context, string version = "1.0.0")
        {
            VAddressableCatalogData data = new VAddressableCatalogData();

            data.DependencyCategoryDatas = new List<VAddressableCategoryData>();
            data.ActiveCategoryData = new(context.Settings.Builder.activeCategory.name);
            
            if (context.Settings.Builder.buildScope == BuildScope.CategoryAndDependencies)
            {
                foreach (var dependencyCategory in context.Settings.Builder.activeCategory.Dependencies)
                {
                    data.DependencyCategoryDatas.Add(new (dependencyCategory.name));
                }
            }
            
            data.Version = version;
            data.UtcCreateAt = DateTime.UtcNow.ToString(CultureInfo.InvariantCulture);
            data.UserFrameworkMode = context.Settings.Builder.activeCategory.UserFrameworkMode;
            data.BuildTarget = context.BuildTarget.ToString();

            return data;
        }
    }
}