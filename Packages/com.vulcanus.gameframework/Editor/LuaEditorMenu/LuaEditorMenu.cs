using System.Diagnostics;
using UnityEditor;
using UnityEngine;
using System.IO;
using Debug = UnityEngine.Debug;

namespace GameFramework.Editor.LuaEditorMenu
{
    public static class LuaEditorMenu
    {
        private const string CodeWorkspaceFileExtension = "code-workspace";

        [MenuItem("VEditor/Open Lua Editor", priority = 999999)]
        public static void OpenLuaEditor()
        {
#if USE_VSCODE_INSTALLER
            InstallAndRunLuaEditor();
#else
            CheckAndRunLuaEditor();
#endif
        }

        private static void CheckAndRunLuaEditor()
        {
            if (!FileAssociationHelper.HasAssociationForExtension(CodeWorkspaceFileExtension))
            {
                // TODO: 메시지 문구 수정 및 다국어 지원
                if (!EditorUtility.DisplayDialog("Lua Editor", "Install Visual Studio Code to edit Lua scripts?",
                        "Yes", "No"))
                    return;

                Application.OpenURL("https://code.visualstudio.com/download");
                return;
            }

            var workspaceFile = FindCodeWorkspaceFile();
            if (!string.IsNullOrEmpty(workspaceFile))
            {
                Process.Start(workspaceFile);
            }
            else
            {
                Debug.LogError("Failed to find workspace file.");
            }
        }

        private static void InstallAndRunLuaEditor()
        {
            LuaEditorInstaller.Clear();

            if (!LuaEditorInstaller.IsEditorInstalled())
            {
                // TODO: 메시지 문구 수정 및 다국어 지원
                if (!EditorUtility.DisplayDialog("Lua Editor", "Install Visual Studio Code to edit Lua scripts?",
                        "Yes", "No"))
                    return;

                Debug.Log("Installing Lua Editor.");
                (bool installed, string message) = LuaEditorInstaller.InstallEditor();
                if (!installed)
                {
                    Debug.LogError($"Failed to install Lua Editor - {message}");
                    return;
                }

                Debug.Log(message);
            }

            if (!LuaEditorInstaller.IsLuaExtensionInstalled())
            {
                Debug.Log("Installing Lua Extension.");
                if (!LuaEditorInstaller.InstallLuaExtension())
                {
                    Debug.LogError("Failed to install VS Code Lua Extension.");
                    return;
                }

                Debug.Log("VS Code Lua Extension installed.");
            }

            var workspaceFile = FindCodeWorkspaceFile();
            if (!string.IsNullOrEmpty(workspaceFile))
            {
                LuaEditorInstaller.OpenProject(workspaceFile);
            }
            else
            {
                Debug.LogError("Failed to find workspace file.");
            }
        }

        private static string FindCodeWorkspaceFile()
        {
            var workspaceFiles = Directory.GetFiles(Directory.GetCurrentDirectory(), $"*.{CodeWorkspaceFileExtension}",
                SearchOption.TopDirectoryOnly);
            return workspaceFiles.Length > 0 ? workspaceFiles[0] : null;
        }
    }
}