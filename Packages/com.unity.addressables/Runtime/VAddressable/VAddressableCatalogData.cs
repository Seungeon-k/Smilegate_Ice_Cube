using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine.Serialization;

namespace UnityEngine.VAddressable
{
    [Serializable]
    public class VAddressableCatalogData
    {
        public static string GetUserFileName() => "vcatalog.json";
        
        public static string GetVFileName(string categoryName) => $"vcatalog_{categoryName}.json";

        public VAddressableCategoryData ActiveCategoryData;
        public List<VAddressableCategoryData> DependencyCategoryDatas;
        public string Version;
        public string UtcCreateAt;
        public UserFrameworkMode UserFrameworkMode;
        public string BuildTarget; 
        
        
        //Platform - win, linux, android, ios 
        //SubPlatform - client, server
        //Checksum - HashingMethods.Calculate
        
        //ProjectId? UgcId?
    }
    
    [Serializable]
    public class VAddressableCategoryData
    {
        public string Name;

        public VAddressableCategoryData(string categoryName)
        {
            Name = categoryName;
        }
    }
}