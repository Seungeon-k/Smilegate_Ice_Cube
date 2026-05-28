using System;
using System.Diagnostics;

using Newtonsoft.Json.Linq;

namespace PixelCanvas
{
    public enum ESeedDataType : byte
    {
        None = 0,
        Canvas,
        Pet,
        Costume,
    }

    public partial class DataVersionMigrator : Singleton<DataVersionMigrator>
    {
        private abstract class SeedDataMigrator
        {
            protected Func<JObject, bool>[] _updater;

            public int LatestVersion
            {
                get
                {
                    Initialize();
                    return _updater.Length;
                }
            }

            public abstract void Initialize();

            public void Release()
            {
                _updater = null;
            }

            public bool MigrateData(int curBaseVersion, JObject jObject, out bool migrated)
            {
                Initialize();

                migrated = false;
                try
                {
                    for (var i = curBaseVersion; i < _updater.Length; ++i)
                    {
                        if (_updater[i].Invoke(jObject) == false)
                            return false;
                        migrated = true;
                    }
                    return true;
                }
                catch (Exception e)
                {
                    UnityEngine.Debug.LogError($"Migration Failed - {e}");
                    return false;
                }
            }
        }

        private static SeedDataMigrator _baseMigrator;
        private static SeedDataMigrator _canvasMigrator;
        private static SeedDataMigrator _petMigrator;
        private static SeedDataMigrator _costumeMigrator;

        protected override void Initialize()
        {
            _baseMigrator = new SeedDataMigrator_Base();
            _canvasMigrator = new SeedDataMigrator_CanvasExtension();
            _petMigrator = new SeedDataMigrator_PetExtension();
            _costumeMigrator = new SeedDataMigrator_CostumeExtension();
        }

        public override void Destroy()
        {
            base.Destroy();

            _baseMigrator.Release();
            _baseMigrator = null;

            _canvasMigrator.Release();
            _canvasMigrator = null;

            _petMigrator.Release();
            _petMigrator = null;

            _costumeMigrator.Release();
            _costumeMigrator = null;
        }

        public string GetLatestVersion(ESeedDataType seedDataType)
        {
            switch (seedDataType)
            {
                case ESeedDataType.Canvas:
                    return $"{(int)ESeedDataType.Canvas}.{_baseMigrator.LatestVersion}.{0}";
                case ESeedDataType.Pet:
                    return $"{(int)ESeedDataType.Pet}.{_baseMigrator.LatestVersion}.{_petMigrator.LatestVersion}";
                case ESeedDataType.Costume:
                    return $"{(int)ESeedDataType.Costume}.{_baseMigrator.LatestVersion}.{_costumeMigrator.LatestVersion}";
                default:
                    Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                    throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
            }
        }

        public bool TryGetVersion(string version, out int seedDataType, out int baseVersion, out int extensionVersion)
        {
            seedDataType = -1;
            baseVersion = -1;
            extensionVersion = -1;

            var splitted = version.Split('.');
            if (splitted.Length != 3)
                return false;
            if (int.TryParse(splitted[0], out seedDataType) == false)
                return false;
            if (int.TryParse(splitted[1], out baseVersion) == false)
                return false;
            if (int.TryParse(splitted[2], out extensionVersion) == false)
                return false;
            return true;
        }

        public EPixelCanvas_Result Migrate(JObject jObject, out int seedDataType, out int baseVersion, out int extensionVersion, out bool migrated)
        {
            migrated = false;
            seedDataType = default;
            baseVersion = default;
            extensionVersion = default;

            if (jObject.GetData<string>("_version", out var schemaVersion) == false)
                return EPixelCanvas_Result.Error_GetVersionString;

            if (TryGetVersion(schemaVersion, out seedDataType, out baseVersion, out extensionVersion) == false)
                return EPixelCanvas_Result.Error_VersionParse;

            //SeedData Base Migration
            if (_baseMigrator.MigrateData(baseVersion, jObject, out var baseMigrated) == false)
                return EPixelCanvas_Result.Error_MigrateBaseData;
            migrated |= baseMigrated;

            //SeedData Extension Migration
            var extensionMigrated = false;
            switch ((ESeedDataType)seedDataType)
            {
                case ESeedDataType.Canvas:
                    {
                        if (_canvasMigrator.MigrateData(extensionVersion, jObject, out extensionMigrated) == false)
                            return EPixelCanvas_Result.Error_MigratePetExtensionData;
                    }
                    break;
                case ESeedDataType.Pet:
                    {
                        if (_petMigrator.MigrateData(extensionVersion, jObject, out extensionMigrated) == false)
                            return EPixelCanvas_Result.Error_MigratePetExtensionData;
                    }
                    break;
                case ESeedDataType.Costume:
                    {
                        if (_costumeMigrator.MigrateData(extensionVersion, jObject, out extensionMigrated) == false)
                            return EPixelCanvas_Result.Error_MigratePetExtensionData;
                    }
                    break;
                default:
                    return EPixelCanvas_Result.Error_InvalidSeedDataType;
            }
            migrated |= extensionMigrated;

            jObject["_version"] = GetLatestVersion((ESeedDataType)seedDataType);
            return EPixelCanvas_Result.Success;
        }

    }
}


/*
 
            EMigrationResult AlphaMigration(JObject jObject)
            {
                if (jObject.GetData<ushort>("_version", out var schemaVersion) == false)
                    return EMigrationResult.Success_LatestVersion;

                var idx = schemaVersion;
                for (var i = idx; i < _alphaMigrationcommands.Count; ++i)
                    _alphaMigrationcommands[i].Invoke(jObject);

                return EMigrationResult.Success_VersionUpdated;
            }


            void InitializeAlphaMigrationCommands()
            {
                if (_alphaMigrationcommands != null)
                    return;
                _alphaMigrationcommands = new List<Action<JObject>>();

                //version (0 => 1)
                _alphaMigrationcommands.Add((jObject) =>
                {
                    if (jObject.GetData<int2>("_textureSize", out var _textureSize) == true)
                    {
                        jObject["_textureWidth"] = (ushort)_textureSize.x;
                        jObject["_textureHeight"] = (ushort)_textureSize.y;
                    }
                });

                //version (1 => 2)
                _alphaMigrationcommands.Add((jObject) =>
                {
                    jObject["_version"] = 2;

                    if (jObject.GetData<string>("_generatedDate", out var _generatedDate))
                        jObject["_generatedDate"] = Utility.ParseDateTime(_generatedDate).ToString("yyyy-MM-dd HH:mm:ss");

                    if (jObject.GetData<string>("_generatedDate", out var _lastModifiedDate))
                        jObject["_lastModifiedDate"] = Utility.ParseDateTime(_lastModifiedDate).ToString("yyyy-MM-dd HH:mm:ss");

                    if (jObject.GetData<string>("_sealedDate", out var _sealedDate))
                        jObject["_sealedDate"] = Utility.ParseDateTime(_sealedDate).ToString("yyyy-MM-dd HH:mm:ss");
                });

                //version (2 => 3)
                _alphaMigrationcommands.Add((jObject) =>
                {
                    jObject["_isOfficial"] = 0;
                    if (jObject.GetData<string>("_directory", out var _directory))
                    {
                        if (_directory.Contains("Packages/") == true)
                            jObject["_isOfficial"] = 1;
                    }
                });

                //version (3 => 4)
                _alphaMigrationcommands.Add((jObject) =>
                {
                    if (jObject.GetData<ushort>("_meshType", out var meshType))
                    {
                        jObject["_meshType"] = meshType + 1;
                    }
                    else
                    {
                        jObject["_meshType"] = 0;
                    }
                });

                //version (4 => 5)
                _alphaMigrationcommands.Add((jObject) =>
                {
                    if (jObject.GetData<byte>("_isOfficial", out var isOfficial))
                    {
                        jObject["_isOfficial"] = isOfficial == 1;
                    }
                    else
                    {
                        jObject["_isOfficial"] = isOfficial == 0;
                    }
                });

                //version (5 => 6)
                _alphaMigrationcommands.Add((jObject) =>
                {
                    if (jObject.GetData<string>("_guid", out var guid))
                    {
                        jObject["_guid"] = guid;
                    }
                    else
                    {
                        jObject["_guid"] = Guid.NewGuid().ToString();
                    }
                });

                //version (6 => 7)
                _alphaMigrationcommands.Add((jObject) =>
                {
                    if (jObject.GetData<string>("_version", out var guid))
                    {
                        jObject["_version"] = "0.0.0";
                    }
                });
            }
 */