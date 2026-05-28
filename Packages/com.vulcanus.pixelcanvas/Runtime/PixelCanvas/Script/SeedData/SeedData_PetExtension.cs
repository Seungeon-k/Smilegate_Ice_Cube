using System.IO;
using System;

using Newtonsoft.Json.Linq;

using UnityEngine;

using System.Runtime.InteropServices;

using Unity.Mathematics;
using UnityEngine.AddressableAssets;
using UnityEngine.Rendering;



#if UNITY_EDITOR
    using UnityEditor;
#endif

namespace PixelCanvas
{
    [Serializable]
    [StructLayout(LayoutKind.Sequential)]
    public partial class SeedData_Pet : SeedData
    {
        //Extended Data

        public SeedData_Pet() : base()
        {
            _seedDataType = ESeedDataType.Pet;
        }

        public override void Initialize()
        {
            base.Initialize();
        }
    }

#if UNITY_EDITOR
    public partial class SeedData_Pet
    {
        public override void DrawGUI()
        {
            base.DrawGUI();

            var cachedColor = GUI.backgroundColor;
            GUI.backgroundColor = Color.yellow;
            GUILayout.BeginVertical("Helpbox");
            GUILayout.Label("Pet Extended Data");
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
        private class SeedDataParser_PetExtension : SeedDataParser
        {
            public override void Initialize()
            {
                if (_toJosonParser != null)
                    return;

                var version = 0;
                //=======================================================================================
                _toJosonParser = new Tuple<int, Action<JObject, BinaryReader>>[]
                {
                    Tuple.Create<int, Action<JObject, BinaryReader>>(
                        //0
                        version++,
                        (JObject jObject, BinaryReader reader) =>
                        {
                            jObject.Add("_meshType", reader.ReadUInt16());
                        }
                    ),

                    Tuple.Create<int, Action<JObject, BinaryReader>>(
                        //1
                        version++,
                        (JObject jObject, BinaryReader reader) =>
                        {
                        }
                    ),
                };
            }
        }
    }

    public partial class DataVersionMigrator
    {
        private class SeedDataMigrator_PetExtension : SeedDataMigrator
        {
            public override void Initialize()
            {
                if (_updater != null)
                    return;

                //=======================================================================================
                _updater = new Func<JObject, bool>[]
                {
                     //Update 0 --> 1
                    (jObject) =>
                    {
                        jObject.Remove("_meshType");
                        return true;
                    }
                };
            }
        }

    }
}