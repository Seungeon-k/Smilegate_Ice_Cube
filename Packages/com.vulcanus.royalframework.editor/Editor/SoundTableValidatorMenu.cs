#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.AddressableAssets;
using UnityEditor.AddressableAssets.Settings;
using UnityEngine;

namespace GeneratedTable
{
    public static class SoundTableValidatorMenu
    {
        [MenuItem("Tools/Sound/Validate All SoundTables")]
        public static void ValidateAll()
        {
            var guids = AssetDatabase.FindAssets("t:SoundScriptableObject");
            int errorCount = 0;

            foreach (var g in guids)
            {
                var path = AssetDatabase.GUIDToAssetPath(g);
                var table = AssetDatabase.LoadAssetAtPath<SoundScriptableObject>(path);
                if (table == null || table.ClipNames == null) continue;

                for (int i = 0; i < table.ClipNames.Length; i++)
                {
                    var c = table.ClipNames[i];
                    if (c == null || string.IsNullOrEmpty(c.fileName) || c.fileName.Contains(" "))
                    {
                        Debug.LogWarning($"[{table.name}] ClipNames[{i}] 비정상", table);
                        errorCount++;
                        continue;
                    }

                    string folder = SoundPathUtil.GetFolder(c.path);
                    string found = SoundPathUtil.FindAudioClipPath(folder, c.fileName);
                    if (string.IsNullOrEmpty(found))
                    {
                        Debug.LogWarning($"[{table.name}] 찾을수 없음 : '{c.fileName}' (path={c.path})");
                        errorCount++;
                        continue;
                    }

                    // ✅ Addressables 등록 여부 검사
                    if (!AddressableUtil.IsRegistered(found, out var entry, out var address))
                    {
                        Debug.LogWarning($"[{table.name}] Addressable 등록이 않되어 있음: '{c.fileName}' (asset={found})");
                        errorCount++;
                    }
                    else
                    {
                        // ✅ Address 키 규칙 검사 (원하는 규칙으로 expectedAddress를 만들면 됨)
                        string expectedAddress = c.fileName;
                        // 예: path까지 포함한 키면
                        // string expectedAddress = $"{c.path.Alias()}/{c.fileName}";

                        if (address.Contains(expectedAddress) == false)
                        {
                            Debug.LogWarning($"[{table.name}] Address mismatch. expected='{expectedAddress}', actual='{address}'");
                            errorCount++;
                        }
                    }
                }
            }

            Debug.LogWarning($"SoundTable 검사 완료 에러:{errorCount}");
        }
    }

    public static class SoundPathUtil
    {
        // project 규칙에 맞게 path(enum) -> 폴더 경로로 매핑
        public static string GetFolder(SoundLabelType path)
        {
            string rootPath = "Assets/CommonAssets/AddressablesResources/UGCCommon/Sounds/";
            switch (path)
            {

                case SoundLabelType.Voice_Penguin: return rootPath+ "Common/Voice/Penguin";
                case SoundLabelType.EventScene: return rootPath + "Common/EventScene";
                case SoundLabelType.UI: return rootPath + "Common/UI";
                case SoundLabelType.BGM: return rootPath + "Common/BGM";
                case SoundLabelType.SFX: return rootPath + "Common/SFX";
                case SoundLabelType.AMB: return rootPath + "Common/AMB";
                case SoundLabelType.XMas_2025: 
                case SoundLabelType.v001Event: return rootPath + "v001Event";
                case SoundLabelType.v002Event: return rootPath + "v002Event";
                case SoundLabelType.v003Event: return rootPath + "v003Event";
            }

            return "";
        }

        public static string FindAudioClipPath(string folder, string fileName)
        {
            // 폴더 제한 + 이름 일치로 AudioClip 찾기
            var guids = AssetDatabase.FindAssets($"t:AudioClip {fileName}", new[] {$"{folder}"});
            foreach (var g in guids)
            {
                var p = AssetDatabase.GUIDToAssetPath(g);
                var clip = AssetDatabase.LoadAssetAtPath<AudioClip>(p);
                if (clip != null && clip.name == fileName)
                    return p;
            }
            return null;
        }
    }

    public static class AddressableUtil
    {
        public static bool IsRegistered(string assetPath, out AddressableAssetEntry entry, out string address)
        {
            entry = null;
            address = null;

            var settings = AddressableAssetSettingsDefaultObject.Settings;
            if (settings == null) return false;

            string guid = AssetDatabase.AssetPathToGUID(assetPath);
            if (string.IsNullOrEmpty(guid)) return false;

            entry = settings.FindAssetEntry(guid);
            if (entry == null) return false;

            address = entry.address;
            return true;
        }
    }
}
#endif
