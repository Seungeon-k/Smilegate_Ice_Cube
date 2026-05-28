using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;

using Newtonsoft.Json.Linq;

using UnityEngine;

namespace PixelCanvas
{
    public partial class ByteDataParser : Singleton<ByteDataParser>
    {
        private abstract class SeedDataParser
        {
            protected Tuple<int, Action<JObject, BinaryReader>>[] _toJosonParser;

            public abstract void Initialize();

            public void Release()
            {
                _toJosonParser = null;
            }

            public void ParseData(int curBaseVersion, JObject jObject, BinaryReader binaryReader)
            {
                Initialize();

                for (var i = _toJosonParser.Length - 1; 0 <= i; --i)
                {
                    var majorVersion = _toJosonParser[i].Item1;
                    if (majorVersion <= curBaseVersion)
                    {
                        _toJosonParser[i].Item2(jObject, binaryReader);
                        break;
                    }
                }
            }
        }

        private SeedDataParser _baseParser;
        private SeedDataParser _canvasExtensionParser;
        private SeedDataParser _petExtensionParser;
        private SeedDataParser_CostumeExtension _costumeExtensionParser;

        protected override void Initialize()
        {
            _baseParser = new SeedDataParser_Base();
            _canvasExtensionParser = new SeedDataParser_CanvasExtension();
            _petExtensionParser = new SeedDataParser_PetExtension();
            _costumeExtensionParser = new SeedDataParser_CostumeExtension();
        }

        public override void Destroy()
        {
            base.Destroy();

            _baseParser.Release();
            _baseParser = null;

            _canvasExtensionParser.Release();
            _canvasExtensionParser = null;

            _petExtensionParser.Release();
            _petExtensionParser = null;

            _costumeExtensionParser.Release();
            _costumeExtensionParser = null;
        }

        public void Save<T>(T data, string path)
        {
            var seedDataType = data.GetType();
            if (seedDataType.IsSerializable == false)
                return;

            using (var ms = new MemoryStream())
            {
                var flags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.DeclaredOnly;

                //Base SeedData Field
                WriteField(ms, seedDataType.BaseType.GetFields(flags));

                //Extension SeedData Field
                WriteField(ms, seedDataType.GetFields(flags));

                var encryptedBytes = AesHmacCrypto.Encrypt(ms.ToArray());
                File.WriteAllBytes(path, encryptedBytes);
            }

            void WriteField(MemoryStream ms, FieldInfo[] fields)
            {
                var bw = new BinaryWriter(ms);
                foreach (var field in fields)
                {
                    if (field.IsDefined(typeof(NonSerializedAttribute), false) == true)
                        continue;

                    if (field.IsPublic == false && field.IsDefined(typeof(SerializeField), false) == false)
                        continue;

                    var fieldData = field.GetValue(data);
                    if (field.FieldType.IsEnum == true)
                    {
                        var underlyingType = Enum.GetUnderlyingType(field.FieldType);
                        fieldData = Convert.ChangeType(fieldData, underlyingType);
                    }

                    switch (fieldData)
                    {
                        case bool boolValue:        bw.Write(boolValue); break;
                        case byte byteValue:        bw.Write(byteValue); break;
                        case sbyte sbyteValue:      bw.Write(sbyteValue); break;
                        case char charValue:        bw.Write(charValue); break;
                        case double doubleValue:    bw.Write(doubleValue); break;
                        case decimal decimalValue:  bw.Write(decimalValue); break;
                        case short shortValue:      bw.Write(shortValue); break;
                        case ushort ushortValue:    bw.Write(ushortValue); break;
                        case int intValue:          bw.Write(intValue); break;
                        case uint uintValue:        bw.Write(uintValue); break;
                        case long longValue:        bw.Write(longValue); break;
                        case ulong ulongValue:      bw.Write(ulongValue); break;
                        case float floatValue:      bw.Write(floatValue); break;
                        case string stringValue:    bw.Write(stringValue ?? ""); break;
                        case byte[] byteArray:      bw.Write(byteArray.Length); bw.Write(byteArray); break;
                        case char[] charArray:      bw.Write(charArray.Length); bw.Write(charArray); break;
                        default:
                            throw new ArgumentException($"Unsupported type: {fieldData?.GetType().Name}");
                    }
                    //Debug.LogError($"{field.Name} - {field.FieldType.Name}");
                }
            }
        }

        private readonly Dictionary<Type, Action<FieldInfo, object, BinaryReader>> _typeActions = new()
        {
            { typeof(bool),    (field, data, reader) => field.SetValue(data, reader.ReadBoolean()) },
            { typeof(byte),    (field, data, reader) => field.SetValue(data, reader.ReadByte()) },
            { typeof(sbyte),   (field, data, reader) => field.SetValue(data, reader.ReadSByte()) },
            { typeof(char),    (field, data, reader) => field.SetValue(data, reader.ReadChar()) },
            { typeof(double),  (field, data, reader) => field.SetValue(data, reader.ReadDouble()) },
            { typeof(decimal), (field, data, reader) => field.SetValue(data, reader.ReadDecimal()) },
            { typeof(short),   (field, data, reader) => field.SetValue(data, reader.ReadInt16()) },
            { typeof(ushort),  (field, data, reader) => field.SetValue(data, reader.ReadUInt16()) },
            { typeof(int),     (field, data, reader) => field.SetValue(data, reader.ReadInt32()) },
            { typeof(uint),    (field, data, reader) => field.SetValue(data, reader.ReadUInt32()) },
            { typeof(long),    (field, data, reader) => field.SetValue(data, reader.ReadInt64()) },
            { typeof(ulong),   (field, data, reader) => field.SetValue(data, reader.ReadUInt64()) },
            { typeof(float),   (field, data, reader) => field.SetValue(data, reader.ReadSingle()) },
            { typeof(string),  (field, data, reader) => field.SetValue(data, reader.ReadString()) },
            { typeof(byte[]),  (field, data, reader) => field.SetValue(data, reader.ReadBytes(reader.ReadInt32())) },
            { typeof(char[]),  (field, data, reader) => field.SetValue(data, reader.ReadChars(reader.ReadInt32())) }
        };

        public EPixelCanvas_Result TryParseToSeedData(byte[] bytes, out bool migrationUpdated, out SeedData seedData)
        {
            //AES-Hmac Validation
            var decryptResult = AesHmacCrypto.TryDecrypt(bytes, out var decryptedBytes);
            if (decryptResult != EPixelCanvas_Result.Success)
            {
                migrationUpdated = false;
                seedData = null;
                return decryptResult;
            }

            using (var stream = new MemoryStream(decryptedBytes))
            {
                using var binaryReader = new BinaryReader(stream);
                try
                {
                    //Peek SchemaVersion
                    var schemaVersion = binaryReader.ReadString();
                    binaryReader.BaseStream.Position = 0;

                    //Get Type & Version Data
                    DataVersionMigrator.Instance.TryGetVersion(schemaVersion, out var seedDataType, out var baseVersion, out var extensionVersion);

                    // Parsing Latest Version
                    if (schemaVersion == DataVersionMigrator.Instance.GetLatestVersion((ESeedDataType)seedDataType))
                    {
                        migrationUpdated = false;

                        switch ((ESeedDataType)seedDataType)
                        {
                            case ESeedDataType.Canvas:
                                seedData = new SeedData_Canvas();
                                break;
                            case ESeedDataType.Pet:
                                seedData = new SeedData_Pet();
                                break;
                            case ESeedDataType.Costume:
                                seedData = new SeedData_Costume();
                                break;
                            default:
                                Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                                throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
                        }

                        ReadField(binaryReader, seedData);

                        return EPixelCanvas_Result.Success;
                    }
                    else // Version Migration Needed During Parse
                    {
                        //SeedData Base
                        var jObject = new JObject();
                        _baseParser.ParseData(baseVersion, jObject, binaryReader);

                        //SeedData Extension
                        switch ((ESeedDataType)seedDataType)
                        {
                            case ESeedDataType.Canvas:
                                _canvasExtensionParser.ParseData(extensionVersion, jObject, binaryReader);
                                break;
                            case ESeedDataType.Pet:
                                _petExtensionParser.ParseData(extensionVersion, jObject, binaryReader);
                                break;
                            case ESeedDataType.Costume:
                                _costumeExtensionParser.ParseData(extensionVersion, jObject, binaryReader);
                                break;
                            default:
                                Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                                throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
                        }

                        if (binaryReader.BaseStream.Length - binaryReader.BaseStream.Position != 0)
                            throw (new Exception("Remain Bytes on Binary SeedData Parsing"));

                        JsonDataParser.TryParseToSeedData(jObject, out migrationUpdated, out seedData);
                        return EPixelCanvas_Result.Success;
                    }
                }
                catch (Exception e)
                {
                    migrationUpdated = false;
                    seedData = null;
                    binaryReader.Close();
                    Debug.LogError(e);
                    return EPixelCanvas_Result.Error_BinaryParse;
                }

                void ReadField(BinaryReader binaryReader, SeedData seedData)
                {
                    var fields = seedData.GetType().GetFields(BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
                    foreach (var field in fields)
                    {
                        if (field.IsDefined(typeof(NonSerializedAttribute), false) == true)
                            continue;

                        if (field.IsPublic == false && field.IsDefined(typeof(SerializeField), false) == false)
                            continue;

                        var fieldType = field.FieldType;
                        if (field.FieldType.IsEnum == true)
                            fieldType = Enum.GetUnderlyingType(field.FieldType);

                        if (_typeActions.TryGetValue(fieldType, out var action) == false)
                            throw new ArgumentException($"Unsupported type: {fieldType.Name}");

                        action(field, seedData, binaryReader);
                    }
                }
            }
        }
    }
}


/*
                var newPath = Path.ChangeExtension(path, ".txt");
                Debug.LogError($"byte Length = {ms.ToArray().Length}");

                var byteData = ms.ToArray();
                var byte2String = Convert.ToBase64String(byteData);
                var string2Byte = Convert.FromBase64String(byte2String);

                Debug.LogError(string2Byte.Length);
                File.WriteAllText(newPath, byte2String);

                System.Threading.Thread.Sleep(50);

                var txt = File.ReadAllText(newPath);
                Debug.LogError($"txt Length = {txt.Length}");

                var b = Convert.FromBase64String(txt);
                Debug.LogError($"new byte Length = {b.Length}");

                TryParseToSeedData(b, out var j);
                Debug.LogError(SeedData.TryParseToSeedData(j, out var migrationUpdated, out var seedData));
                seedData.LoadTexture();
                UnityEditor.EditorUtility.OpenPropertyEditor(seedData._seedTarget);
 */