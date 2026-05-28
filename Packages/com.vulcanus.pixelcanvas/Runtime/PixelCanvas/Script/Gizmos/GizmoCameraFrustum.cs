
using UnityEngine;

namespace PixelCanvas
{
    [ExecuteAlways]
    public class GizmoCameraFrustum : MonoBehaviour
    {
#if UNITY_EDITOR
        private Camera _camera;
        private static Vector3[] _frustumCorner = new Vector3[4];

        private void Awake()
        {
            _camera = GetComponent<Camera>();
        }

        private void OnEnable() { }

        private void OnDrawGizmos()
        {
            if (enabled == false)
                return;

            if (_camera == null)
                return;

            if (_camera.orthographic == true)
            {
                float height = 2f * _camera.orthographicSize;
                float width = height * _camera.aspect;
                float depth = _camera.farClipPlane;

                var size = new Vector3(width, height, depth);

                Gizmos.DrawWireCube(_camera.transform.position + Vector3.forward * depth / 2, size);
            }
            else
            {
                Gizmos.matrix = _camera.transform.localToWorldMatrix;

                var distance = _camera.transform.position.y;
                _camera.CalculateFrustumCorners(new Rect(0, 0, 1, 1), distance, Camera.MonoOrStereoscopicEye.Mono, _frustumCorner);

                Gizmos.DrawFrustum(Vector3.zero,
                    _camera.fieldOfView,
                    _camera.farClipPlane,
                    _camera.nearClipPlane,
                    _camera.aspect);

                Gizmos.matrix = Matrix4x4.identity;
            }
        }
#endif
    }
}
