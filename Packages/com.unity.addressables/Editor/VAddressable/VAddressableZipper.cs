using System;
using System.IO;
using System.IO.Compression;
using UnityEditor.AddressableAssets;
using UnityEngine;
using CompressionLevel = System.IO.Compression.CompressionLevel;

namespace UnityEditor.VAddressable
{
    public class VAddressableZipper
    {
        public static string GetZipperDestinationArchiveFileName(BuildTarget buildTarget, string archiveDirectoryPath)
        {
            return Path.Combine(archiveDirectoryPath, GetDestinationArchiveFileName(buildTarget));
        }
        
        public static string GetMergedFileName(BuildTarget buildTarget, string archiveDirectoryPath)
        {
            return Path.Combine(archiveDirectoryPath, GetMergedFileName(buildTarget));
        }
        
        public static void Archive(BuildTarget buildTarget, string buildPath, string archiveDirectoryPath, bool deleteSourceDirectory = true)
        {
            var sourceDirectoryName = buildPath;
            var destinationArchiveFileName = Path.Combine(archiveDirectoryPath, GetDestinationArchiveFileName(buildTarget));

            if (!Directory.Exists(sourceDirectoryName))
            {
                throw new FileNotFoundException($"Source directory not found: {sourceDirectoryName}");   
            }

            if (!Directory.Exists(archiveDirectoryPath))
            {
                Directory.CreateDirectory(archiveDirectoryPath);
            }
            
            if (File.Exists(destinationArchiveFileName))
            {
                File.Delete(destinationArchiveFileName);
            }

            ZipFile.CreateFromDirectory(sourceDirectoryName, destinationArchiveFileName, CompressionLevel.Fastest, false);
            
            if (deleteSourceDirectory)
            {
                if (Directory.Exists(sourceDirectoryName))
                {
                    Directory.Delete(sourceDirectoryName, true);
                }
            }
        }

        //[MenuItem("Window/Asset Management/Addressables/Zip AssetBundles With SaveFolderPanel")]
        public static void ZipAssetBundlesWithSaveFolderPanel()
        {
            string buildPath = VAddressableAssetBuilder.VBuildPath;
            ZipAssetBundlesWithSaveFolderPanel(buildPath);
        }
        
        private static void ZipAssetBundlesWithSaveFolderPanel(string buildPath)
        {
            var savedFolderPath = EditorUtility.SaveFolderPanel("Save bundle to folder", "", "");
            if (string.IsNullOrWhiteSpace(savedFolderPath))
            {
                Debug.Log("Save folder path is empty.");
                return;
            }

            Archive(EditorUserBuildSettings.activeBuildTarget, buildPath, savedFolderPath);
        }
        
        public static string GetDestinationArchiveFileName(BuildTarget buildtarget)
        {
            var category = AddressableAssetSettingsDefaultObject.Settings.Builder.activeCategory;
            return $"{category.name}_{buildtarget}.unity3d";
        }
        
        private static string GetMergedFileName(BuildTarget buildtarget)
        {
            var category = AddressableAssetSettingsDefaultObject.Settings.Builder.activeCategory;

            var device = GetDevice(buildtarget);
            
            return $"V_{category.name}_{buildtarget}{device}.unity3d";
        }

        /// <summary>
        /// EssentialBundleDefines.Device와 동일한 구조
        /// </summary>
        private enum Device
        {
            A, 
            I, 
            W, 
            S, 
            P
        }
        
        private static string GetDevice(BuildTarget buildtarget)
        {
            return buildtarget switch
            {
                BuildTarget.StandaloneWindows64 => Device.W.ToString(),
                BuildTarget.StandaloneLinux64 => Device.S.ToString(),
                BuildTarget.Android => Device.A.ToString(),
                BuildTarget.iOS => Device.I.ToString(),
                _ => throw new ArgumentOutOfRangeException(nameof(buildtarget), buildtarget, null)
            };
        }
    }
}