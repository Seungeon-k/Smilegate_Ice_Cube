#if UNITY_EDITOR

using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEditor;
using UnityEditor.SceneManagement;

namespace PixelCanvas
{
    [InitializeOnLoad]
    public class EditorPlayModeSettings
    {
        static EditorPlayModeSettings()
        {
            EditorSceneManager.activeSceneChangedInEditMode += EditorSceneManager_activeSceneChangedInEditMode;
        }

        private static void EditorSceneManager_activeSceneChangedInEditMode(Scene arg0, Scene arg1)
        {
            //EditorSettings.enterPlayModeOptionsEnabled = (arg1.name == "PixelCanvas");
        }

        [RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
        private static void OnBeforeSceneLoad()
        {
        }
    }
}
#endif