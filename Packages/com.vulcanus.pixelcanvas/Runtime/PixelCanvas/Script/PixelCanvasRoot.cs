using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

namespace PixelCanvas
{

    public enum EExecusionOrder
    {
        PixelCanvasRoot = -1,
    }

    [DefaultExecutionOrder((int)EExecusionOrder.PixelCanvasRoot)]
    public class PixelCanvasRoot : MonoBehaviour
    {
        [SerializeField] private Camera _uiCamera;
        [SerializeField] private Camera _modelCamera;
        [SerializeField] private PixelCanvas _pixelCanvas;

        private Action _inactivatePixelCanvas;
        private int _prvQualityLevel;
        private int _prvScreenHeight;

		public void Initialize(Action inactivatePixelCanvas)
        {
             _inactivatePixelCanvas = inactivatePixelCanvas;
        }

        public void InactivatePixelCanvas()
        {
            if (_inactivatePixelCanvas != null)
                _inactivatePixelCanvas.Invoke();
        }

        private void OnEnable()
        {
            _prvQualityLevel = QualitySettings.GetQualityLevel();
            QualitySettings.SetQualityLevel(2);

#if (UNITY_EDITOR && PIXELCANVAS_EDITOR)
            _prvScreenHeight = Screen.currentResolution.height;
            SetResolution(720);
#endif
        }

        private void OnDisable()
        {
            QualitySettings.SetQualityLevel(_prvQualityLevel);

#if (UNITY_EDITOR && PIXELCANVAS_EDITOR)
            SetResolution(_prvScreenHeight);
#endif
        }

        private void OnDestroy()
        {
            EventManager.Destroy();
			ResourceManager.Instance.ReleaseLongTermResources();
		}

        private void SetResolution(int targetResolutionY)
        {
            var targetResolutionX = (int)(Screen.width * ((float)targetResolutionY / Screen.height));
            Screen.SetResolution(targetResolutionX, targetResolutionY, false);
            Canvas.ForceUpdateCanvases();
        }
    }
}