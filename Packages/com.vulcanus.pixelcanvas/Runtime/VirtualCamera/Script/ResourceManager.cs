using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace VirtualCamera
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

    [CreateAssetMenu(fileName = "ResourceManager", menuName = "VirtualCamera/ResourceManager", order = 1)]
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

        [Header("Postprocess")]
        [SerializeField] private PostProcess _globalPostprocess;
        public PostProcess GlobalPostprocess => _globalPostprocess;
    }
}
