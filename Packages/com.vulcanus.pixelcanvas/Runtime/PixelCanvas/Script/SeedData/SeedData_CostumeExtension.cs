using System;
using System.IO;
using System.Runtime.InteropServices;

using Newtonsoft.Json.Linq;

using UnityEngine;
using Unity.Mathematics;
using UnityEngine.AddressableAssets;



#if UNITY_EDITOR
    using UnityEditor;
#endif

namespace PixelCanvas
{
    public enum EBoneIndex_Penguin : byte
    {
        Bip001 = 1,
        Bip001_Pelvis = 2,
        Bip001_L_Thigh = 3,
        Bip001_L_Calf = 4,
        Bip001_L_Foot = 5,
        Bip001_L_Toe0 = 6,
        Bip001_R_Thigh = 7,
        Bip001_R_Calf = 8,
        Bip001_R_Foot = 9,
        Bip001_R_Toe0 = 10,
        Bip001_Spine = 11,
        Bip001_Spine1 = 12,
        Back_Acc_Bone_001 = 13,
        Back_Acc_Bone_002 = 14,
        Back_Acc_Point = 15,
        Bip001_Head = 16,
        B_Eye_L = 17,
        B_Eye_R = 18,
        B_Mouth01 = 19,
        B_Mouth0 = 20,
        Face_Acc_Point = 21,
        Head_Acc_Point = 22,
        Bip001_L_UpperArm = 23,
        Bip001_L_Forearm = 24,
        Bip001_L_Hand = 25,
        weapon_point_L = 26,
        Bip001_R_UpperArm = 27,
        Bip001_R_Forearm = 28,
        Bip001_R_Hand = 29,
        weapon_point_R = 30,
    }

    public enum EPartsType : byte
    {
        Head = 1,
        UpperBody = 2,
        LowerBody = 3,
        FullBody = 4,
        Foot = 5,

        Head_Acc = 6,
        Face_Acc = 7,
        Back_Acc = 8,
        Neck_Acc = 9,

        Right_Weapon = 10,
        Left_Weapon = 11,
    }

    [Serializable]
    [StructLayout(LayoutKind.Sequential)]
    public partial class SeedData_Costume : SeedData
    {
        public EPartsType _partsType;

        public SeedData_Costume() : base()
        {
            _seedDataType = ESeedDataType.Costume;
        }

        public override void Initialize()
        {
            base.Initialize();
        }
    }

#if UNITY_EDITOR
    public partial class SeedData_Costume
    {
        public override void DrawGUI()
        {
            base.DrawGUI();

            var cachedColor = GUI.backgroundColor;
            GUI.backgroundColor = Color.yellow;
            GUILayout.BeginVertical("Helpbox");
            GUILayout.Label("Costume Extended Data");
            {
                _partsType = (EPartsType)EditorGUILayout.EnumPopup("Parts Type", _partsType);
            }
            GUILayout.EndVertical();
            GUI.backgroundColor = cachedColor;
            GUILayout.Space(20);
        }
    }
#endif

    public partial class ByteDataParser
    {
        private class SeedDataParser_CostumeExtension : SeedDataParser
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
                            jObject.Add("_prefabName", reader.ReadString());
                        }
                    ),

                    Tuple.Create<int, Action<JObject, BinaryReader>>(
                        //1
                        version++,
                        (JObject jObject, BinaryReader reader) =>
                        {
                            jObject.Add("_prefabName", reader.ReadString());
                            jObject.Add("_partsType", reader.ReadByte());
                        }
                    ),

                    Tuple.Create<int, Action<JObject, BinaryReader>>(
                        //2
                        version++,
                        (JObject jObject, BinaryReader reader) =>
                        {
                            jObject.Add("_partsType", reader.ReadByte());
                        }
                    ),
                };
            }
        }
    }

    public partial class DataVersionMigrator
    {
        private class SeedDataMigrator_CostumeExtension : SeedDataMigrator
        {
            private static readonly string[] PartsTypes = { "_head", "_body", "_fullbody", "_foot", "_achead", "_acface", "_acback", "_acneck" };

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
                        if (jObject.GetData<string>("_prefabName", out var _prefabName) == true)
                        {
                            var isValid = false;
                            foreach (var partsType in PartsTypes)
                            {
                                if (_prefabName.ToLower().Contains(partsType) == false)
                                    continue;

                                switch(partsType)
                                {
                                    case "_head":       jObject["_partsType"] = (byte)EPartsType.Head;          break;
                                    case "_body":       jObject["_partsType"] = (byte)EPartsType.UpperBody;     break;
                                    case "_fullbody":   jObject["_partsType"] = (byte)EPartsType.FullBody;      break;
                                    case "_foot":       jObject["_partsType"] = (byte)EPartsType.Foot;          break;
                                    case "_achead":     jObject["_partsType"] = (byte)EPartsType.Head_Acc;      break;
                                    case "_acface":     jObject["_partsType"] = (byte)EPartsType.Face_Acc;      break;
                                    case "_acback":     jObject["_partsType"] = (byte)EPartsType.Back_Acc;      break;
                                    case "_acneck":     jObject["_partsType"] = (byte)EPartsType.Neck_Acc;      break;
                                }
                                isValid = true;
                                break;
                            }
                            if (isValid == false)
                                return false;
                        }
                        else
                            return false;

                        return true;
                    },

                    //Update 1 --> 2
                    (jObject) =>
                    {
                        jObject.Remove("_prefabName");
                        return true;
                    }

                };
            }
        }
    }
}