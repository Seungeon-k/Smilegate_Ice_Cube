using System.IO;

using UnityEditor;
using UnityEditor.AddressableAssets;

using UnityEngine;

namespace PixelCanvas
{
    [UnityEditor.CustomEditor(typeof(ModelData), true)]
    public class ModelDataEditor : UnityEditor.Editor
    {
        public override void OnInspectorGUI()
        {
            var data = (ModelData)target;

            DrawDefaultInspector();
            EditorGUILayout.Space();

            using (var scope = new GUIColorScope(EGUIColorScopeType.Background, Color.green))
            {
                if (GUILayout.Button("Validate Data", GUILayout.Height(50)))
                {
                    data.GenerateRuntimeData();
                    SetupAddressables(data.name);

                    if (GUI.changed == true)
                    {
                        EditorUtility.SetDirty(data);
                        AssetDatabase.SaveAssets();
                    }
                }
            }
        }

        private void SetupAddressables(string modelDataName)
        {
            var settings = AddressableAssetSettingsDefaultObject.Settings;
            var addressablesGroup = settings.FindGroup("PixelCanvas Packed Assets");

            var DirectoryGUIDs = AssetDatabase.FindAssets($"{modelDataName} t:DefaultAsset", new string[] { "Assets/AddressablesResources/PixelCanvas/Pet" });

            foreach (var directoryGUID in DirectoryGUIDs)
            {
                var folderPath = AssetDatabase.GUIDToAssetPath(directoryGUID);
                if (Path.GetFileNameWithoutExtension(folderPath) != modelDataName)
                    continue;

                if (AssetDatabase.IsValidFolder(folderPath) == false)
                    continue;

                //Set Addressables Enable Check & Simplify Addressables Name
                var addressablesEntry = settings.FindAssetEntry(directoryGUID);
                if (addressablesEntry == null)
                    addressablesEntry = settings.CreateOrMoveEntry(directoryGUID, addressablesGroup);

                var addressablesKey = folderPath.Replace("Assets/AddressablesResources/PixelCanvas/", "");
                if (addressablesEntry.address != addressablesKey)
                {
                    addressablesEntry.SetAddress(addressablesKey);
                    Debug.LogError($"<color=green>Addressables Setup Enabled</color> : {addressablesKey}");
                }
            }
        }
    }
}
