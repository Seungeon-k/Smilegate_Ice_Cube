using System;
using System.IO;
using System.Runtime.InteropServices;

using Newtonsoft.Json.Linq;

using UnityEngine;

#if UNITY_EDITOR
    using UnityEditor;
#endif

namespace PixelCanvas
{
    [Serializable]
    [StructLayout(LayoutKind.Sequential)]
    public partial class SeedData_Canvas : SeedData
    {
        public SeedData_Canvas() : base()
        {
            _seedDataType = ESeedDataType.Canvas;
            _version = DataVersionMigrator.Instance.GetLatestVersion(ESeedDataType.Canvas);
        }

        //public override void Initialize()
        //{
        //    base.Initialize();
        //}
    }

#if UNITY_EDITOR
    public partial class SeedData_Canvas
    {
        public override void DrawGUI()
        {
            base.DrawGUI();

            var cachedColor = GUI.backgroundColor;
            GUI.backgroundColor = Color.yellow;
            GUILayout.BeginVertical("Helpbox");
            GUILayout.Label("Canvas Extended Data");
            {
            }
            GUILayout.EndVertical();
            GUI.backgroundColor = cachedColor;
            GUILayout.Space(20);
        }
    }
#endif

    public partial class ByteDataParser
    {
        private class SeedDataParser_CanvasExtension : SeedDataParser
        {
            public override void Initialize()
            {
                if (_toJosonParser != null)
                    return;

                //=======================================================================================
                _toJosonParser = new Tuple<int, Action<JObject, BinaryReader>>[]
                {

                };
            }
        }
    }

    public partial class DataVersionMigrator
    {
        private class SeedDataMigrator_CanvasExtension : SeedDataMigrator
        {
            public override void Initialize()
            {
                if (_updater != null)
                    return;

                //=======================================================================================
                _updater = new Func<JObject, bool>[]
                {

                };
            }
        }
    }
}