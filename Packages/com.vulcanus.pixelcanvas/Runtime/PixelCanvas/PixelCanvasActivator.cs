using System.Text;

using Cysharp.Threading.Tasks;

using EasyButtons;

using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.UIElements;

namespace PixelCanvas
{
    public class PixelCanvasActivator : MonoBehaviour
    {
        private async void Start()
        {
#if PIXELCANVAS_EDITOR
            Application.targetFrameRate = 60;
            PrintInfo();
#endif

            await Addressables.InitializeAsync().ToUniTask();
            await UniTask.Delay(500);
            PixelCanvasManager.Instance.OpenSeedDataList();
        }

        private void OnDestroy()
        {
        }

#if UNITY_EDITOR
        [Button(Mode = ButtonMode.EnabledInPlayMode)]
        void Test()
        {
            var result = PixelCanvasStorageManager.Instance.TryGetEmptySeedDataThumbnail(ESeedDataType.Pet, "Party_Pet_Cat_Pikachu", out var emptyThumbnail);
            if (result == EPixelCanvas_Result.Success)
                UnityEditor.EditorUtility.OpenPropertyEditor(emptyThumbnail);
        }
#endif

        public static void PrintInfo()
        {
            var strBuilder = new StringBuilder();

            strBuilder.AppendLine($"<color=green>{SystemInfo.processorType}</color>");
            strBuilder.AppendLine($"{"Core Count",-15}: {SystemInfo.processorCount}");
            strBuilder.AppendLine($"{"Frequency",-15}: {SystemInfo.processorFrequency} MHz");
            strBuilder.AppendLine($"{"Memory Size",-15}: {SystemInfo.systemMemorySize / 1024f: 00.00} GB");
            strBuilder.AppendLine();


            strBuilder.AppendLine($"<color=green>{SystemInfo.graphicsDeviceName}</color>");
            strBuilder.AppendLine($"{"Vender",-15}: {SystemInfo.graphicsDeviceVendor}");
            strBuilder.AppendLine($"{"Memory",-15}: {SystemInfo.graphicsMemorySize / 1024f: 00.00} GB");
            strBuilder.AppendLine($"{"Version",-15}: {SystemInfo.graphicsDeviceVersion}");
            strBuilder.AppendLine($"{"Shader Level",-15}: {SystemInfo.graphicsShaderLevel}");
            strBuilder.AppendLine($"{"Is UV Top Down",-15}: {SystemInfo.graphicsUVStartsAtTop}");
            strBuilder.AppendLine($"{"Supports Fence",-15}: {SystemInfo.supportsGraphicsFence}");
            strBuilder.AppendLine($"{"Device Type",-15}: {SystemInfo.graphicsDeviceType}");
            strBuilder.AppendLine($"{"Max Buffer Size",-15}: {SystemInfo.maxGraphicsBufferSize}");
            Debug.LogError(strBuilder.ToString());
        }

        //[Button(Mode = ButtonMode.EnabledInPlayMode)]
        //private void OpenSeedDataList()
        //{
        //	PixelCanvasManager.Instance.OpenSeedDataList();
        //}

        [Button(Mode = ButtonMode.EnabledInPlayMode)]
        private void Quit()
        {
            PixelCanvasManager.Instance.InactivatePixelCanvas();
        }
    }
}