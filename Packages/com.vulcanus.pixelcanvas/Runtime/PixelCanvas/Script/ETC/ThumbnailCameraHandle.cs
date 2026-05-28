using EasyButtons;

using UnityEngine;

namespace PixelCanvas
{
    [ExecuteAlways]
    public partial class ThumbnailCameraHandle : MonoBehaviour
    {
        public Vector3 ModelPivot
        {
            get => _modelPivot;
            set => _modelPivot = value;
        }
        [SerializeField] private Vector3 _modelPivot = new Vector3(0, 1, -0.2f);

        public Vector3 CameraPivot
        {
            get => _cameraPivot;
            set => _cameraPivot = value;
        }
        [SerializeField] private Vector3 _cameraPivot;

        public Vector3 GimbalEuler;
        public Vector3 LocalEuler;

        public float CameraDistance => _cameraDistance;
        [SerializeField][Range(0, 10)] private float _cameraDistance;

        public ModelData ModelData
        {
            get => _modelData;
            set => _modelData = value;
        }
        [SerializeField] private ModelData _modelData;

        public GameObject ModelFBX
        {
            get => _modelFBX;
            set => _modelFBX = value;
        }
        [SerializeField] private GameObject _modelFBX;

        private void Awake()
        {
#if !UNITY_EDITOR
            gameObject.SetActive(false);
#endif
            transform.hideFlags = HideFlags.NotEditable;
        }

        private void OnEnable()
        {
            
        }
    }

#if UNITY_EDITOR
    public partial class ThumbnailCameraHandle
    {
        [Button]
        public void SetIdentity()
        {
            GimbalEuler = new Vector3(0, 0, 0);
            LocalEuler = new Vector3(0, 0, 0);
        }

        public void OnValidate()
        {
            if (_modelData == null)
                return;

            var offset = new Vector3(0, 0, -_cameraDistance);
            transform.position = Quaternion.Euler(GimbalEuler.x, 0, 0) * offset;
            transform.position = Quaternion.Euler(0, GimbalEuler.y, 0) * transform.position;
            transform.position += CameraPivot;

            transform.rotation = Quaternion.Euler(GimbalEuler.x, GimbalEuler.y, 0) * Quaternion.Euler(LocalEuler);
            _modelData.SetCameraTransform(transform);
            _modelData._modelPivot = _modelPivot;

            transform.hideFlags = HideFlags.NotEditable;
        }

        private void OnDrawGizmos()
        {
            Gizmos.color = new Color(0, 1, 0, 1f);
            Gizmos.DrawWireCube(_cameraPivot, new Vector3(0.1f, 0.1f, 0.1f));
            Gizmos.DrawLine(transform.position, _cameraPivot);

            Gizmos.color = new Color(1, 1, 0, 1f);
            Gizmos.DrawCube(ModelPivot, Vector3.one * 0.1f);

            //    var vertexCount = 100;
            //    var degree = 360f / vertexCount;
            //    for (var i = 0; i < vertexCount; ++i)
            //    {
            //        //   Gizmos.DrawLine();
            //    }

            //    Gizmos.color = new Color(0, 1, 1, 0.3f);
            //    Gizmos.DrawWireCube(_modelFBX.transform.position + _modelData._massBounds.center, _modelData._massBounds.size);
            //    Gizmos.color = new Color(0, 1, 1, 1);
            //    Gizmos.DrawCube(_modelFBX.transform.position + _modelData._massBounds.center, new Vector3(0.03f, 0.03f, 0.03f));
        }
    }
#endif
}
