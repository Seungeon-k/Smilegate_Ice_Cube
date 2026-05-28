using System;

using Newtonsoft.Json.Linq;

using UnityEngine;

namespace PixelCanvas
{

    public partial class JsonDataParser
    {
        public static EPixelCanvas_Result TryParseToSeedData(JObject jObject, out bool migrationUpdated, out SeedData seedData)
        {
            migrationUpdated = false;
            seedData = null;

            // Update Version Migration
            var migrationResult = DataVersionMigrator.Instance.Migrate(jObject, out var seedDataType, out var baseVersion, out var extensionVersion, out migrationUpdated);
            if (migrationResult != EPixelCanvas_Result.Success)
                return migrationResult;

            // JObject to SeedData
            try
            {
                switch ((ESeedDataType)seedDataType)
                {
                    case ESeedDataType.Canvas:
                        seedData = jObject.ToObject<SeedData_Canvas>();
                        break;
                    case ESeedDataType.Pet:
                        seedData = jObject.ToObject<SeedData_Pet>();
                        break;
                    case ESeedDataType.Costume:
                        seedData = jObject.ToObject<SeedData_Costume>();
                        break;
                    default:
                        Debug.Assert(false, $"Unexpected SeedDataType value: {seedDataType}");
                        throw new InvalidOperationException($"Unexpected SeedDataType value: {seedDataType}");
                }
            }
            catch (Exception e)
            {
                Debug.LogError($"Error_JObjectToSeedData - {e}");
                return EPixelCanvas_Result.Error_JObjectToSeedData;
            }

            seedData.Initialize();
            return EPixelCanvas_Result.Success;
        }
    }
}