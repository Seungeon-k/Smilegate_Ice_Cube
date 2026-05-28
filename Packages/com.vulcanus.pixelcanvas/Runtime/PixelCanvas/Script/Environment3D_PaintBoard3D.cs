using UnityEngine;
using UnityEngine.AddressableAssets;

namespace PixelCanvas
{
    public class Environment3D_PaintBoard3D : Environment3D
    {
        private bool _rotaterDragged;
        private bool _pressed;
        private bool _draged;
        private Vector2 _cameraRevolutionEuler = new Vector2(180, 0);
        private Vector2 _euler;

        private IntervalTimerGate _intervalTimer = new IntervalTimerGate(1);

        [SerializeField] protected Material _modelMaterial;

        protected override void Awake()
        {
            base.Awake();
            _modelMaterial = Instantiate(_modelMaterial);
        }

        protected override void OnEnable()
        {
            base.OnEnable();
        }

        protected override void OnDisable()
        {
            base.OnDisable();
        }

        protected override void OnDestroy()
        {
            base.OnDestroy();
            GameObject.Destroy(_modelMaterial);
        }

        protected override void Update()
        {
            base.Update();
            if (_seedData == null)
                return;

            //Initialize Position & FOV on Model Frustum Culling Failed.
            if (_intervalTimer.Update() == true)
            {
                var bounds = _modelRenderer.bounds;
                if (_virtualCamera.CheckFrustumCulling(bounds) == false)
                    RotateModelToIdle(0.3f, EIdleTransformType.PintchDefault);
            }
        }

        private bool TryGenerateInstancePrefab(string partsName, out GameObject instance)
        {
            instance = null;

            var rootPath = "Assets/AddressablesResources/PixelCanvas/Costume/ModelData";
            var prefabPath = $"{rootPath}/{partsName}{GlobalValue._prefabExtension}";
            var locations = Addressables.LoadResourceLocationsAsync(prefabPath, typeof(GameObject)).WaitForCompletion();
            if (locations.Count == 0)
                return false;

            var assetHandle = Addressables.LoadAssetAsync<GameObject>(prefabPath);
            var prefab = assetHandle.WaitForCompletion();
            instance = GameObject.Instantiate(prefab);
            return true;
        }

        protected override void SpawnModel(SeedData seedData)
        {
            base.SpawnModel(seedData);

            //_modelHandle.transform.rotation = Quaternion.identity;
        }

        protected override void SetMaterial()
        {
            _modelMaterial.SetTexture(GlobalValue._MainTex, ResourceManager.Instance.CanvasTarget);
            _modelMaterial.SetVector(GlobalValue._Parameters1, new Vector4(_seedData._textureWidth, _seedData._textureHeight, 0, 0));

            var renderer = _modelInstance.GetComponentInChildren<Renderer>();
            var materials = renderer.sharedMaterials;
            if (1 < materials.Length)
            {
                for (var i = 0; i < materials.Length; ++i)
                    materials[i] = _modelMaterial;
                materials[0] = ResourceManager.Instance.DummyModelMaterial;
            }
            else
            {
                materials[0] = _modelMaterial;
            }
            renderer.materials = materials;
        }

        internal override void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            base.NotifyEvent(id, datas);

            switch (id)
            {
                case EPixelArtEventID.OnOpenCanvas:
                    RotateModelToIdle(0.2f);
                    break;
                case EPixelArtEventID.OnTextureGenerated:
                    _modelMaterial.SetTexture(GlobalValue._MainTex, ResourceManager.Instance.CanvasTarget);
                    _modelMaterial.SetVector(GlobalValue._Parameters1, new Vector4(ResourceManager.Instance.CanvasTarget.width, ResourceManager.Instance.CanvasTarget.height, 0, 0));
                    break;
                    //case EPixelArtEventID.RotateToIdle_Paintboard3D:
                    //    {
                    //        RotateModelToIdle(0.2f);
                    //    }
                    //    break;
                    //case EPixelArtEventID.OnOneFingerDragged:
                    //    {
                    //        var canvas = datas[0] as Canvas;
                    //        var ped = datas[1] as PointerEventData;

                    //        var screenSize = new Vector2(Screen.width, Screen.height);
                    //        var viewPortPosition = ((ped.position / screenSize) + (ped.position / screenSize)) * 0.5f;
                    //        var ray = _virtualCamera.ViewportPointToRay(viewPortPosition);
                    //        _touchPivot.position = _modelHandle.transform.position;
                    //        if (Physics.Raycast(ray, out RaycastHit hit, Mathf.Infinity, GlobalValue._DefaultLayer) == true)
                    //            _touchPivot.position = hit.point;

                    //        var distanceToTarget = Vector3.Distance(_virtualCamera.transform.position, _touchPivot.position);
                    //        var worldUnit = (distanceToTarget * 2 * Mathf.Tan(_virtualCamera.fieldOfView / 2 * Mathf.Deg2Rad)) / Screen.height;

                    //        var delta = (ped.delta / canvas.scaleFactor) * worldUnit * 100;
                    //        var right = _virtualCamera.transform.right;
                    //        var forward = (_modelHandle.transform.position - _virtualCamera.transform.position).normalized;
                    //        var up = Vector3.Cross(forward, right);

                    //        _modelHandle.transform.rotation = Quaternion.AngleAxis(-delta.x, up) * _modelHandle.transform.rotation;
                    //        _modelHandle.transform.rotation= Quaternion.AngleAxis(delta.y, right) * _modelHandle.transform.rotation;
                    //    }
                    //    break;
                    //case EPixelArtEventID.OnDoubleFingerDragged:
                    //    {
                    //        var canvas = datas[0] as Canvas;
                    //        var ped1 = datas[1] as PointerEventData;
                    //        var ped2 = datas[2] as PointerEventData;

                    //        var prvPed1Pos = ped1.position - (ped1.delta);
                    //        var prvPed2Pos = ped2.position - (ped2.delta);
                    //        var prvVector = prvPed1Pos - prvPed2Pos;
                    //        var curVector = ped1.position - ped2.position;

                    //        var screenSize = new Vector2(Screen.width, Screen.height);
                    //        var viewPortPosition = ((ped1.position / screenSize) + (ped2.position / screenSize)) * 0.5f;
                    //        var ray = _virtualCamera.ViewportPointToRay(viewPortPosition);

                    //        _touchPivot.position = _modelHandle.transform.position;
                    //        if (Physics.Raycast(ray, out RaycastHit hit, Mathf.Infinity, GlobalValue._DefaultLayer) == true)
                    //            _touchPivot.position = hit.point;

                    //        var toTarget = (_touchPivot.position - ray.origin);
                    //        var dotDIstance = Vector3.Dot(ray.direction.normalized, toTarget);
                    //        var point = ray.origin + (ray.direction.normalized * dotDIstance);


                    //        var distanceToTarget = Vector3.Distance(_virtualCamera.transform.position, _touchPivot.position);
                    //        var worldUnit = (distanceToTarget * 2 * Mathf.Tan(_virtualCamera.fieldOfView / 2 * Mathf.Deg2Rad)) / Screen.height;

                    //        var lengthBetweenPositions = (ped1.position - ped2.position).magnitude;
                    //        var prvLengthBetweenPositions = (prvPed1Pos - prvPed2Pos).magnitude;
                    //        var prvMultiTouchCenterPos = (prvPed1Pos + prvPed2Pos) * 0.5f;
                    //        var currMultiTouchCenterPos = (ped1.position + ped2.position) * 0.5f;
                    //        var multiTouchCenterPosDelata = currMultiTouchCenterPos - prvMultiTouchCenterPos;

                    //        //Move
                    //        {
                    //            multiTouchCenterPosDelata *= worldUnit;
                    //            _modelHandle.transform.position += new Vector3(multiTouchCenterPosDelata.x, multiTouchCenterPosDelata.y, 0);
                    //        }

                    //        //Scale
                    //        {
                    //            var prvPosition = _touchPivot.transform.position;
                    //            var originScale = _modelHandle.transform.localScale;
                    //            _modelHandle.transform.localScale *= lengthBetweenPositions / prvLengthBetweenPositions;
                    //            var delta = _touchPivot.position - prvPosition;
                    //            _modelHandle.transform.position -= delta;
                    //        }

                    //        //Rotate
                    //        if (70 < curVector.magnitude)  //Ignore Touches that is too narrow
                    //        {
                    //            var vector = _modelHandle.transform.position;

                    //            var quaternion = Quaternion.AngleAxis(Vector2.SignedAngle(prvVector, curVector), _virtualCamera.transform.forward);
                    //            var vector2 = vector - point;
                    //            vector2 = quaternion * vector2;
                    //            vector = point + vector2;

                    //            _modelHandle.transform.position = vector;
                    //            _modelHandle.transform.rotation = Quaternion.AngleAxis(Vector2.SignedAngle(prvVector, curVector), _virtualCamera.transform.forward) * _modelHandle.transform.rotation;
                    //        }
                    //    }
                    //    break;
            }
        }

    }
}