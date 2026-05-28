using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace PixelCanvas
{
    public class PixelCanvasActivatorButton : MonoBehaviour
    {
        [SerializeField] private Button _button;
        [SerializeField] private GameObject _pixelCanvasPrefab;

        private List<Camera> _cameras;
        private PixelCanvasRoot _pixelCanvas;

        private void Awake()
        {
            _cameras = new List<Camera>();

            _button.onClick.AddListener(() =>
            {
                if (_pixelCanvas == null)
                {
                    ActivatePixelCanvas();
                }
                else
                {
                    InactivatePixelCanvas();
                }
            });
        }

        private void ActivatePixelCanvas()
        {
            _cameras.Clear();

            //SceneManager.GetSceneByName("Main");
            var mainScene = SceneManager.GetSceneAt(0);
            for (var i = 0; i < SceneManager.sceneCount; ++i)
            {
                var scene = SceneManager.GetSceneAt(i);

                foreach (var rootObject in scene.GetRootGameObjects())
                {
                    foreach (var camera in rootObject.transform.GetComponentsInChildren<Camera>())
                    {
                        switch (camera.name)
                        {
                            case "MainCamera":
                            case "UIAppCamera":
                                _cameras.Add(camera);
                                break;
                        }
                    }
                }
            }
            var instance = GameObject.Instantiate(_pixelCanvasPrefab);
            SceneManager.MoveGameObjectToScene(instance.gameObject, mainScene);

            _pixelCanvas = instance.GetComponent<PixelCanvasRoot>();
            _pixelCanvas.Initialize(InactivatePixelCanvas);
            _pixelCanvas.transform.position = new Vector3(0, 100, 0);

            foreach (var camera in _cameras)
                camera.gameObject.SetActive(false);

            //_button.gameObject.SetActive(false);
        }

        private void InactivatePixelCanvas()
        {
            GameObject.Destroy(_pixelCanvas.gameObject);
            foreach (var camera in _cameras)
                camera.gameObject.SetActive(true);

            //_button.gameObject.SetActive(true);
        }
    }
}