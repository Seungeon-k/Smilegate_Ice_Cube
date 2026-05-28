using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Unity.Profiling.LowLevel.Unsafe;

using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;

namespace PixelCanvas
{
    public static class Utility
    {
        //File================================================================================================
        public static string Move(string oldPath, string newPath)
        {
            return string.Empty;

            //if (oldPath == newPath)
            //    return string.Empty;

            //if (File.Exists(oldPath) == false)
            //    return string.Empty;

            //var newDirectory = Path.GetDirectoryName(newPath);
            //if (Directory.Exists(newDirectory) == false)
            //    Directory.CreateDirectory(newDirectory);

            //var newName = Path.GetFileNameWithoutExtension(newPath);
            //newName = Utility.GetValidFileName(newDirectory, newName);

            //var resultPath = Path.Combine(newDirectory, $"{newName}{GlobalValue._jsonExtension");
            //if (oldPath == resultPath)
            //    return resultPath;

            //File.Move(oldPath, resultPath);
            //return resultPath;
        }

        //File Name================================================================================================
        public static string GetValidFileName(string directory, string targetName)
        {
            //while (true) 
            //{
            //    var fullPath = $"{targetName}_{Guid.NewGuid().ToString()}";
            //    if (File.Exists(fullPath) == false)
            //        return fullPath;
            //}

            var fullPath = Path.Combine(directory, $"{targetName}{GlobalValue._jsonExtension}");
            if (File.Exists(fullPath) == false)
                return targetName;

            TryGetBaseName(targetName, out var baseName, out var _);
            var indexSet = new SortedSet<int>();

            foreach (var path in Directory.EnumerateFiles(directory, GlobalValue._jsonSearchPattern, SearchOption.AllDirectories))
            {
                var fileName = Path.GetFileNameWithoutExtension(path);
                if (fileName.Contains(baseName) == false)
                    continue;

                if (TryGetBaseName(fileName, out var pvtBaseName, out var pvtNumber) == false)
                    continue;

                if (baseName != pvtBaseName)
                    continue;

                indexSet.Add(pvtNumber);
            }

            var pvt = 1;
            for (var i = 1; i <= indexSet.Count + 1; ++i)
            {
                if (indexSet.Contains(i) == true)
                    continue;

                pvt = i;
                break;
            }

            var newName = (baseName.Last() == ' ') ? $"{baseName}({pvt})" : $"{baseName} ({pvt})";
            return newName;

            bool TryGetBaseName(string name, out string modifiedName, out int number)
            {
                modifiedName = name;
                number = 0;

                var idxOpen = name.LastIndexOf('(');
                if (idxOpen == -1)
                    return false;

                var idxEnd = name.LastIndexOf(')');
                if (idxEnd == -1)
                    return false;

                if (idxEnd <= idxOpen)
                    return false;

                if (idxEnd - idxOpen < 2)
                    return false;

                var stringNumber = name.Substring(idxOpen + 1, idxEnd - idxOpen - 1);
                if (int.TryParse(stringNumber, out number) == false)
                    return false;

                modifiedName = name.Substring(0, idxOpen);
                if (modifiedName.Last() == ' ')
                    modifiedName = modifiedName.TrimEnd();
                return true;
            }
        }

        public static string GetParentDirectory(string path)
        {
            //var directory = Path.GetDirectoryName(path);
            //var depths = directory.Split('/', '\\');

            //var parentDirectory = "";
            //for (var i = 0; i < depths.Length - 1; ++i)
            //{
            //    parentDirectory = Path.Combine(parentDirectory, depths[i]);
            //}
            //return parentDirectory;

            var parentDirectory = Directory.GetParent(path).Parent.FullName;
            return parentDirectory;
            //parentDirectory = Path.Combine("Assets", Path.GetRelativePath(Application.dataPath, parentDirectory));
        }

        //================================================================================================
        public static void ValidateAnimatorBones(Transform avatarTransform, Transform partsTransform)
        {
            var dicBone = new Dictionary<string, Transform>();
            var rootBip = avatarTransform.Find("Bip001");
            foreach (var transform in rootBip.GetComponentsInChildren<Transform>())
                dicBone.Add(transform.name, transform);

            var skinnedMeshRenderers = partsTransform.GetComponentsInChildren<SkinnedMeshRenderer>();
            foreach (var skinnedMeshRenderer in skinnedMeshRenderers)
            {
                var boneList = new List<Transform>();
                foreach (var bone in skinnedMeshRenderer.bones)
                    boneList.Add(dicBone[bone.name]);
                skinnedMeshRenderer.bones = boneList.ToArray();
                skinnedMeshRenderer.rootBone = dicBone[skinnedMeshRenderer.rootBone.name];
            }

            partsTransform.SetParent(avatarTransform, false);
        }

        //Time================================================================================================
        public static string GetUtcTime()
        {
            return DateTime.UtcNow.ToString("yyMMddHH:mm:ss");
        }

        public static DateTime ParseDateTime(string dateTime)
        {
            return DateTime.ParseExact(dateTime, "yyMMddHH:mm:ss", null);
        }

        public static void SetTag(this GameObject gameObject, string tag)
        {
            var transforms = gameObject.GetComponentsInChildren<Transform>();
            foreach (var transform in transforms)
            {
                transform.tag = tag;
            }
        }
    }

    public struct NanoTimer : IDisposable
    {
        private string _name;
        private long _startTime;

        public NanoTimer(string name) : this() => BeginTimer(name);

        public void Dispose() => EndTimer();

        public void BeginTimer(string name)
        {
            _name = name;
            _startTime = ProfilerUnsafeUtility.Timestamp;
        }

        public void EndTimer()
        {
            long now = ProfilerUnsafeUtility.Timestamp;
            var conversionRatio = ProfilerUnsafeUtility.TimestampToNanosecondsConversionRatio;

            var elapsedTime = (now - _startTime) * conversionRatio.Numerator / conversionRatio.Denominator / 1_000_000f;
            Debug.LogError($"{_name} : {elapsedTime}");
            //timeRecorder.time += math.step(0.0001f, elapsedTime);
        }
    }

    public static class EventTriggerUtility
    {
        public static EventTrigger.Entry Create(EventTriggerType type, UnityAction<BaseEventData> callback)
        {
            var entry = new EventTrigger.Entry();
            entry.eventID = type;
            entry.callback.AddListener(callback);
            return entry;
        }
    }

    public enum EGUIColorScopeType
    {
        Background,
        Content,
        Color,
    }

    public struct GUIColorScope : IDisposable
    {
        private EGUIColorScopeType _colorScopeType;
        private Color _originColor;

        public GUIColorScope(EGUIColorScopeType colorScopeType, Color color)
        {
            _colorScopeType = colorScopeType;
            switch (colorScopeType)
            {
                case EGUIColorScopeType.Background:
                    _originColor = GUI.backgroundColor;
                    GUI.backgroundColor = color;
                    break;
                case EGUIColorScopeType.Content:
                    _originColor = GUI.contentColor;
                    GUI.contentColor = color;
                    break;
                case EGUIColorScopeType.Color:
                    _originColor = GUI.color;
                    GUI.color = color;
                    break;
                default:
                    _originColor = color;
                    break;
            }
        }

        public void Dispose()
        {
            switch (_colorScopeType)
            {
                case EGUIColorScopeType.Background:
                    GUI.backgroundColor = _originColor;
                    break;
                case EGUIColorScopeType.Content:
                    GUI.contentColor = _originColor;
                    break;
                case EGUIColorScopeType.Color:
                    GUI.color = _originColor;
                    break;
                default:
                    break;
            }
        }
    }
}
