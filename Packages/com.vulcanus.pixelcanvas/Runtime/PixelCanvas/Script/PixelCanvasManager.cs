
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;
using UnityEngine.SceneManagement;

namespace PixelCanvas
{
	public class PixelCanvasManager : MonoSingleton<PixelCanvasManager>
	{
		private PixelCanvasRoot _pixelCanvasRoot;
		private List<Camera> _cameras = new List<Camera>();
        private List<Light> _lights = new List<Light>();

		[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
		private static void OnBeforeSceneLoad()
		{
		}

		protected override void Initialize()
		{
			var mainScene = SceneManager.GetSceneAt(0);
			SceneManager.MoveGameObjectToScene(gameObject, mainScene);

			PixelCanvasStorageManager.Instance.LoadSeedDatas();

#if !(UNITY_EDITOR && PIXELCANVAS_EDITOR)
			transform.position = new Vector3(0, 100, 0);
#endif		
		}

		protected override void Destroy()
		{
			base.Destroy();

			GameObject.Destroy(SoundManager.Instance.gameObject);
		}

		private void OnApplicationQuit()
		{
			PixelCanvasStorageManager.Destroy();
		}

		public void OpenSeedDataList()
		{
			ActivatePixelCanvas();
			EventManager.Notify(EPixelArtEventID.OpenSeedDataListViewer);
		}

		public EPixelCanvas_Result OpenSeedData(ESeedDataType seedDataType, string strGuid, string officialModelDataName, string officialSeedDataName)
		{
            var guid = new Guid(strGuid);
			if (PixelCanvasStorageManager.Instance.TryGetLocalSeedData(guid, out var seedData) == false)
			{
                if (PixelCanvasStorageManager.Instance.TryGetOfficialSeedData(seedDataType, officialModelDataName, officialSeedDataName, out var officialSeedData) != EPixelCanvas_Result.Success)
					return EPixelCanvas_Result.Error_InvalidPetName;

                seedData = officialSeedData.GenerateClone(strGuid);
			}

			//Assert.IsNotNull(seedData);

            ActivatePixelCanvas();
            //return EPixelCanvas_Result .Failure_ActivatePixelCanvas

            EventManager.Notify(EPixelArtEventID.OpenCanvas, seedData);
			return EPixelCanvas_Result.Success;
        }

		private void ActivatePixelCanvas()
		{
            //Camera
			_cameras.Clear();
			for (var i = 0; i < SceneManager.sceneCount; ++i)
			{
				var scene = SceneManager.GetSceneAt(i);

				foreach (var rootObject in scene.GetRootGameObjects())
				{
					foreach (var camera in rootObject.transform.GetComponentsInChildren<Camera>())
					{
						if (camera.isActiveAndEnabled == false)
							continue;
						_cameras.Add(camera);
					}
				}
			}
			foreach (var camera in _cameras)
				camera.enabled = false;

            //Light
            _lights.Clear();
            for (var i = 0; i < SceneManager.sceneCount; ++i)
            {
                var scene = SceneManager.GetSceneAt(i);

                foreach (var rootObject in scene.GetRootGameObjects())
                {
                    foreach (var light in rootObject.transform.GetComponentsInChildren<Light>())
                    {
                        if (light.isActiveAndEnabled == false)
                            continue;
                        _lights.Add(light);
                    }
                }
            }
            foreach (var light in _lights)
                light.enabled = false;

            if (_pixelCanvasRoot == null)
			{
				var instance = GameObject.Instantiate(ResourceManager.Instance.PixelCanvasRootPerfab, transform);
				_pixelCanvasRoot = instance.GetComponent<PixelCanvasRoot>();
				_pixelCanvasRoot.Initialize(InactivatePixelCanvas);
			}
        }

		public void InactivatePixelCanvas()
		{
			if (_pixelCanvasRoot == null)
				return;

			GameObject.Destroy(_pixelCanvasRoot.gameObject);
			_pixelCanvasRoot = null;

            foreach (var camera in _cameras)
            {
                if (camera != null)
                    camera.enabled = true;
            }

            foreach (var light in _lights)
            {
                if (light != null)
                    light.enabled = true;
            }

            GlobalValue.Callback_OnPixelCanvasQuit?.Invoke();
        }

		public void OnDestroyZone()
		{
            if (_pixelCanvasRoot == null)
                return;

            GameObject.Destroy(_pixelCanvasRoot.gameObject);
			_pixelCanvasRoot = null;
        }
    }
}