using System.Collections;
using System.Collections.Generic;
using Cysharp.Threading.Tasks;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.Diagnostics;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace PixelCanvas
{
    public enum EShaderType
    {
        SimpleLit,
        Lit
    }

    public static class VulcanusRPUtility
    {
        public static Material GenerateMaterial(EShaderType shaderType, Texture baseTex, Texture uberTex)
        {
            var material = new Material((shaderType == EShaderType.SimpleLit) ? ResourceManager.Instance.VulcanusSimpleLitShader : ResourceManager.Instance.VulcanusLitShader);

            material.SetTexture(GlobalValue._BaseMap, baseTex);
            material.SetTexture(GlobalValue._UberMap, uberTex);

            if (shaderType == EShaderType.Lit)
            {
                material.SetFloat(GlobalValue._Metallic, (uberTex) ? 1f : 0f);
            }
            else
            {

            }
            material.SetFloat(GlobalValue._Smoothness, (uberTex) ? 1f : 0f);
            material.SetFloat(GlobalValue._EmissionPower, (uberTex) ? 50f : 0f);

            ValidateVulcanusMaterial(material);
            return material;
        }

        public static void ValidateVulcanusMaterial(Material material)
        {
            if (material.HasFloat(GlobalValue._EnvironmentReflections) == true)
            {
                if (material.GetFloat(GlobalValue._EnvironmentReflections) == 0)
                    material.EnableKeyword("_ENVIRONMENTREFLECTIONS_OFF");
                else
                    material.DisableKeyword("_ENVIRONMENTREFLECTIONS_OFF");
            }

            //if (material.HasTexture(GlobalValue._UberMap) == true)
            //    material.EnableKeyword("_UBERMAP");
            //else
            //    material.DisableKeyword("_UBERMAP");
        }
    }

    public class Environment3D_ResultViewer : Environment3D
    {
        [SerializeField] private float _defaultFriction = 1;
        [SerializeField] private float _toIdleDeltaThreashold = 5;

        [SerializeField] private GameObject _meshAvatar;
        private GameObject _skinnedMeshAvatar;

        private Material _modelMaterial;

        public Vector2 ForceDelta
        {
            get => _forceDelta;
            set => _forceDelta = value; 
        }
        private Vector2 _forceDelta;

        public Vector2 Euler
        {
            get => _euler;
            set => _euler = value;
        }
        private Vector2 _euler;

        public bool Pressed
        {
            get => _pressed;
            set => _pressed = value;
        }
        private bool _pressed;

        protected override void OnDestroy()
        {
            GameObject.Destroy(_modelMaterial);
        }

        protected override void Update()
        {
            base.Update();

            //_virtualCamera.CheckF
            if (_forceDelta != Vector2.zero)
            {
                _euler.x += _forceDelta.x * Time.unscaledDeltaTime;

                _euler.x = _euler.x % 360;
                _euler.y = Mathf.Clamp(_euler.y, -90, 90);
                _modelHandle.transform.rotation = Quaternion.Euler(0, -_euler.x, 0);
                _modelHandle.transform.rotation = Quaternion.Euler(_euler.y, 0, 0) * _modelHandle.transform.rotation;

                var sign = math.sign(_forceDelta);
                var abs = math.abs(_forceDelta);
                var friction = (_pressed == true) ? (abs / 0.3f) : _defaultFriction;
                _forceDelta = math.abs(abs) - friction * Time.unscaledDeltaTime;
                _forceDelta = math.clamp(_forceDelta, 0, float.MaxValue);
                _forceDelta *= (Vector2)sign;
            }
        }

        public async void RotateToIdle(float maxTime)
        {
            if (_toIdleDeltaThreashold < _forceDelta.magnitude)
                return;

            _forceDelta = Vector2.zero;

            var currRotation = _modelHandle.transform.rotation;
            var curFOV = _virtualCamera.fieldOfView;

            var begTime = Time.time;
            _euler = new Vector2(180, 0);

            while (true)
            {
                var elapsedTime = Time.time - begTime;
                var ratio = Mathf.InverseLerp(0, maxTime, elapsedTime);
                ratio = Mathf.Clamp01(ratio);
                _modelHandle.transform.rotation = Quaternion.Lerp(currRotation, Quaternion.LookRotation(Vector3.back, Vector3.up), ratio);
                _virtualCamera.fieldOfView = Mathf.Lerp(curFOV, 60, ratio);
                if (ratio == 1)
                    return;

                await UniTask.Yield();
            }
        }

        protected override void SpawnModel(SeedData seedData)
        {
            base.SpawnModel(seedData);

            _modelHandle.transform.rotation = Quaternion.LookRotation(Vector3.back, Vector3.up);
        }

        protected override void SetMaterial()
        {
            var shaderType = EShaderType.SimpleLit;

            GameObject.Destroy(_modelMaterial);
            _modelMaterial = VulcanusRPUtility.GenerateMaterial(shaderType, ResourceManager.Instance.ScaledTarget, _seedData._uberTarget);

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
                    RotateToIdle(0.2f);
                    break;
                case EPixelArtEventID.OnTextureGenerated:
                    _modelMaterial.SetTexture(GlobalValue._BaseMap, ResourceManager.Instance.ScaledTarget);
                    _modelMaterial.SetTexture(GlobalValue._UberMap, _seedData._uberTarget);
                    break;
                case EPixelArtEventID.OnSeedDataChanged:
                    _virtualCamera.transform.localPosition = Vector3.zero;
                    _virtualCamera.transform.localRotation = Quaternion.identity;
                    _modelHandle.localPosition = new Vector3(0, 0, _seedData.ModelData._cameraTransform.Position.magnitude * 1.5f);
                    break;
            }
        }
    }
}
