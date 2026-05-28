using System.Collections.Generic;

using Cysharp.Threading.Tasks;

using Unity.Mathematics;

using UnityEngine;

using VirtualCamera;

namespace PixelCanvas
{
    public enum EIdleTransformType
    {
        Default,
        PintchDefault
    }

    public abstract class Environment3D : MonoBehaviour
    {
        public VirtualCamera.VirtualCamera VirtualCamera => _virtualCamera;
        [SerializeField] protected VirtualCamera.VirtualCamera _virtualCamera;

        [SerializeField] protected Renderer[] _backgroundRenderers;

        public Transform ModelHandle => _modelHandle;
        [SerializeField] protected Transform _modelHandle;
        protected Renderer _modelRenderer;

        public Transform TouchPivot => _touchPivot;
        [SerializeField] private Transform _touchPivot = null;

        protected SeedData _seedData;
        protected GameObject _modelInstance;
        protected Dictionary<string, Transform> _dicBone;

        protected static readonly Dictionary<EPartsType, string> _penguinBoneLookup = new Dictionary<EPartsType, string>
        {
            { EPartsType.Head_Acc, "Head_Acc_Point" },
            { EPartsType.Face_Acc, "Face_Acc_Point" },
            { EPartsType.Back_Acc, "Back_Acc_Point" },
        };

        protected virtual void Awake()
        {
            _dicBone = new Dictionary<string, Transform>();

            EventManager.Register(EPixelArtEventID.OnOpenCanvas, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnTextureGenerated, NotifyEvent);
            EventManager.Register(EPixelArtEventID.OnSeedDataChanged, NotifyEvent);
        }

        protected virtual void OnDestroy()
        {
            EventManager.Unregister(EPixelArtEventID.OnOpenCanvas, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnTextureGenerated, NotifyEvent);
            EventManager.Unregister(EPixelArtEventID.OnSeedDataChanged, NotifyEvent);
        }

        protected virtual void OnEnable()
        {
        }

        protected virtual void OnDisable()
        {
        }

        protected virtual void Update()
        {
            if (_seedData == null)
                return;
        }

        public async void RotateModelToIdle(float maxTime, EIdleTransformType idleTransformType = EIdleTransformType.Default)
        {
            var begTime = Time.time;
            var begPosition = _modelHandle.transform.position;
            var begRotation = _modelHandle.transform.rotation;
            var begScale = _modelHandle.transform.localScale;
            var begFOV = _virtualCamera.fieldOfView;

            switch (idleTransformType)
            {
                case EIdleTransformType.Default:
                    {
                        var endPosition = _virtualCamera.transform.position + Vector3.forward * _seedData.ModelData._cameraTransform.Position.magnitude;
                        var endRotation = Quaternion.Inverse(_seedData.ModelData._cameraTransform.Rotation);
                        var endScale = Vector3.one;
                        var endFOV = 60f;

                        while (true)
                        {
                            var elapsedTime = Time.time - begTime;
                            var ratio = Mathf.InverseLerp(0, maxTime, elapsedTime);
                            ratio = Mathf.Clamp01(ratio);
                            _modelHandle.transform.position = Vector3.Lerp(begPosition, endPosition, ratio);
                            _modelHandle.transform.rotation = Quaternion.Lerp(begRotation, endRotation, ratio);
                            _modelHandle.transform.localScale = Vector3.Lerp(begScale, endScale, ratio);
                            _virtualCamera.fieldOfView = math.lerp(begFOV, endFOV, ratio);

                            if (ratio == 1)
                                break;

                            await UniTask.Yield();
                        }
                    }
                    break;
                case EIdleTransformType.PintchDefault:
                    {
                        var endPosition = _virtualCamera.transform.position + Vector3.forward * _seedData.ModelData._cameraTransform.Position.magnitude;
                        var endRotation = Quaternion.Inverse(_seedData.ModelData._cameraTransform.Rotation);
                        var endScale = Vector3.one;
                        var endFOV = 60f;

                        while (true)
                        {
                            var elapsedTime = Time.time - begTime;
                            var ratio = Mathf.InverseLerp(0, maxTime, elapsedTime);
                            ratio = Mathf.Clamp01(ratio);
                            _modelHandle.transform.position = Vector3.Lerp(begPosition, endPosition, ratio);
                            _modelHandle.transform.localScale = Vector3.Lerp(begScale, endScale, ratio);
                            _virtualCamera.fieldOfView = math.lerp(begFOV, endFOV, ratio);

                            if (ratio == 1)
                                break;

                            await UniTask.Yield();
                        }
                    }
                    break;
            }
        }

        protected void CollectBones(Transform rootAvatar)
        {
            var bip001 = rootAvatar.Find("Bip001");
            var transforms = bip001.GetComponentsInChildren<Transform>();
            foreach (var transform in transforms)
                _dicBone.Add(transform.gameObject.name, transform);
        }

        public void EquipParts(Transform rootAvatar, Transform costume, EPartsType partsType)
        {
            Utility.ValidateAnimatorBones(rootAvatar, costume);

            var lodGroups = costume.GetComponentsInChildren<LODGroup>();
            foreach (var lodGroup in lodGroups)
                lodGroup.ForceLOD(0);

            var costumeRenderer = costume.GetComponentInChildren<Renderer>();
            _virtualCamera.AddRenderer(costumeRenderer);

            switch (costumeRenderer)
            {
                case MeshRenderer meshRenderer:
                    {
                        var meshFilter = meshRenderer.GetComponent<MeshFilter>();
                        meshRenderer.gameObject.AddComponent<MeshCollider>().sharedMesh = meshFilter.sharedMesh;

                        _penguinBoneLookup.TryGetValue(partsType, out var boneName);
                        _dicBone.TryGetValue(boneName, out var bone);
                        costume.SetParent(bone, false);
                    }
                    break;
                case SkinnedMeshRenderer skinnedMeshRenderer:
                    {
                        var mesh = new Mesh();
                        skinnedMeshRenderer.BakeMesh(mesh);
                        skinnedMeshRenderer.gameObject.AddComponent<MeshCollider>().sharedMesh = mesh;
                    }
                    break;
            }
        }

        protected virtual void SpawnModel(SeedData seedData)
        {
            _seedData = seedData;
            var modelData = _seedData.ModelData;

            if (_modelInstance != null)
            {
                GameObject.DestroyImmediate(_modelInstance);
                _dicBone.Clear();
            }

            _modelInstance = GameObject.Instantiate(modelData._modelPrefab, _modelHandle);
            _modelInstance.transform.localPosition = -modelData._modelPivot;
            _modelInstance.SetTag("Player");

            var renderer = _modelInstance.GetComponentInChildren<Renderer>();
            _modelRenderer = renderer;
            _virtualCamera.ClearRenderer();

            foreach (var backgroundRenderer in _backgroundRenderers)
                _virtualCamera.AddRenderer(backgroundRenderer);
            _virtualCamera.AddRenderer(renderer);

            switch (renderer)
            {
                case MeshRenderer meshRenderer:
                    {
                        var meshFilter = _modelInstance.GetComponentInChildren<MeshFilter>();
                        meshFilter.gameObject.AddComponent<MeshCollider>().sharedMesh = meshFilter.sharedMesh;

                        var size = math.max(renderer.bounds.size.x, renderer.bounds.size.y);
                        var cameraLocalPosition = Vector3.zero;
                        cameraLocalPosition.z -= size;

                    }
                    break;
                case SkinnedMeshRenderer skinnedMeshRenderer:
                    {
                        var mesh = new Mesh();
                        skinnedMeshRenderer.BakeMesh(mesh);
                        skinnedMeshRenderer.gameObject.AddComponent<MeshCollider>().sharedMesh = mesh;
                        
                        //_modelInstance.transform.localPosition = _modelHandle.transform.position - skinnedMeshRenderer.bounds.center;
                    }
                    break;
            }

            //_virtualCamera.transform.position = _modelInstance.transform.position + modelData._cameraTransform.Position;
            //_virtualCamera.transform.rotation = modelData._cameraTransform.Rotation;

            //switch (_seedData._seedDataType)
            //{
            //    case ESeedDataType.Costume:
            //        {
            //            var costumeSeedData = (_seedData as SeedData_Costume);

            //            _modelInstance = GameObject.Instantiate(modelData._avatarPrefab, _modelHandle);
            //            switch (costumeSeedData._partsType)
            //            {
            //                case EPartsType.Head:
            //                    _modelInstance.transform.Find("Party_Penguin_Head").gameObject.SetActive(false);
            //                    break;
            //                case EPartsType.UpperBody:
            //                    _modelInstance.transform.Find("Party_Penguin_Body").gameObject.SetActive(false);
            //                    break;
            //                case EPartsType.LowerBody:
            //                    break;
            //                case EPartsType.FullBody:
            //                    _modelInstance.transform.Find("Party_Penguin_Head").gameObject.SetActive(false);
            //                    _modelInstance.transform.Find("Party_Penguin_Body").gameObject.SetActive(false);
            //                    _modelInstance.transform.Find("Party_Penguin_Foot").gameObject.SetActive(false);
            //                    break;
            //                case EPartsType.Foot:
            //                    _modelInstance.transform.Find("Party_Penguin_Foot").gameObject.SetActive(false);
            //                    break;
            //            }
            //            _virtualCamera.ClearRenderer();
            //            _virtualCamera.AddRenderer(_modelInstance.GetComponentsInChildren<Renderer>());
            //            CollectBones(_modelInstance.transform);

            //            var costumeInstance = GameObject.Instantiate(modelData._modelPrefab);
            //            costumeInstance.SetTag("Player");   //Set Target Renderer

            //            EquipParts(_modelInstance.transform, costumeInstance.transform, costumeSeedData._partsType);

            //            var costumeRenderer = costumeInstance.GetComponentInChildren<Renderer>();
            //            var materials = costumeRenderer.materials;
            //            if (1 < materials.Length)
            //            {
            //                for (var i = 0; i < materials.Length; ++i)
            //                    materials[i] = _modelMaterial;
            //                materials[0] = ResourceManager.Instance.DummyModelMaterial;
            //            }
            //            else
            //            {
            //                materials[0] = _modelMaterial;
            //            }
            //            costumeRenderer.materials = materials;

            //            //Centralize Model CameraPivot
            //            var renderers = _modelInstance.GetComponentsInChildren<Renderer>();
            //            var bounds = renderers[0].bounds;
            //            for (var i = 0; i < renderers.Length; ++i)
            //                bounds.Encapsulate(renderers[i].bounds);
            //            _modelInstance.transform.localPosition = _modelHandle.transform.position - bounds.center;

            //            _virtualCamera.transform.position = costumeInstance.transform.position + modelData._cameraTransform.Position;
            //            _virtualCamera.transform.rotation = modelData._cameraTransform.Rotation;
            //        }
            //        break;
            //}

            //switch (_seedData._seedDataType)
            //{
            //    case ESeedDataType.Pet:
            //        {
            //            _modelInstance = GameObject.Instantiate(modelData._modelPrefab, _modelHandle);
            //            _modelInstance.SetTag("Player");
            //            _modelInstance.transform.localPosition = -modelData._modelPivot;

            //            var meshFilter = _modelInstance.GetComponentInChildren<MeshFilter>();
            //            meshFilter.gameObject.AddComponent<MeshCollider>().sharedMesh = meshFilter.sharedMesh;

            //            var renderers = _modelInstance.GetComponentsInChildren<Renderer>();
            //            foreach (var renderer in renderers)
            //                renderer.material = _modelMaterial;

            //            var size = math.max(renderers[0].bounds.size.x, renderers[0].bounds.size.y);
            //            var cameraLocalPosition = Vector3.zero;
            //            cameraLocalPosition.z -= size;

            //            _virtualCamera.transform.position = _modelInstance.transform.position + modelData._cameraTransform.Position;
            //            _virtualCamera.transform.rotation = modelData._cameraTransform.Rotation;
            //            _virtualCamera.ClearRenderer();
            //            _virtualCamera.AddRenderer(renderers);
            //        }
            //        break;
            //    case ESeedDataType.Costume:
            //        {
            //            var costumeSeedData = (_seedData as SeedData_Costume);

            //            _modelInstance = GameObject.Instantiate(modelData._avatarPrefab, _modelHandle);
            //            switch (costumeSeedData._partsType)
            //            {
            //                case EPartsType.Head:
            //                    _modelInstance.transform.Find("Party_Penguin_Head").gameObject.SetActive(false);
            //                    break;
            //                case EPartsType.UpperBody:
            //                    _modelInstance.transform.Find("Party_Penguin_Body").gameObject.SetActive(false);
            //                    break;
            //                case EPartsType.LowerBody:
            //                    break;
            //                case EPartsType.FullBody:
            //                    _modelInstance.transform.Find("Party_Penguin_Head").gameObject.SetActive(false);
            //                    _modelInstance.transform.Find("Party_Penguin_Body").gameObject.SetActive(false);
            //                    _modelInstance.transform.Find("Party_Penguin_Foot").gameObject.SetActive(false);
            //                    break;
            //                case EPartsType.Foot:
            //                    _modelInstance.transform.Find("Party_Penguin_Foot").gameObject.SetActive(false);
            //                    break;
            //            }
            //            _virtualCamera.ClearRenderer();
            //            _virtualCamera.AddRenderer(_modelInstance.GetComponentsInChildren<Renderer>());
            //            CollectBones(_modelInstance.transform);

            //            var costumeInstance = GameObject.Instantiate(modelData._modelPrefab);
            //            costumeInstance.SetTag("Player");   //Set Target Renderer

            //            EquipParts(_modelInstance.transform, costumeInstance.transform, costumeSeedData._partsType);

            //            var costumeRenderer = costumeInstance.GetComponentInChildren<Renderer>();
            //            var materials = costumeRenderer.materials;
            //            if (1 < materials.Length)
            //            {
            //                for (var i = 0; i < materials.Length; ++i)
            //                    materials[i] = _modelMaterial; 
            //                materials[0] = ResourceManager.Instance.DummyModelMaterial;
            //            }
            //            else
            //            {
            //                materials[0] = _modelMaterial;
            //            }
            //            costumeRenderer.materials = materials;

            //            //Centralize Model CameraPivot
            //            var renderers = _modelInstance.GetComponentsInChildren<Renderer>();
            //            var bounds = renderers[0].bounds;
            //            for (var i = 0; i < renderers.Length; ++i)
            //                bounds.Encapsulate(renderers[i].bounds);
            //            _modelInstance.transform.localPosition = _modelHandle.transform.position - bounds.center;

            //            _virtualCamera.transform.position = costumeInstance.transform.position + modelData._cameraTransform.Position;
            //            _virtualCamera.transform.rotation = modelData._cameraTransform.Rotation;
            //        }
            //        break;
            //}

            SetMaterial();

            var lodGroups = _modelInstance.GetComponentsInChildren<LODGroup>();
            foreach (var lodGroup in lodGroups)
                lodGroup.ForceLOD(0);

            Physics.SyncTransforms();
        }

        protected abstract void SetMaterial();

        internal virtual void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.OnSeedDataChanged:
                    {
                        var seedData = datas[0] as SeedData;
                        _seedData = seedData;

                        SpawnModel(seedData);
                    }
                    break;
            }
        }
    }
}