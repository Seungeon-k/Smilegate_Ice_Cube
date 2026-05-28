using System;
using System.Collections.Generic;

using CommonFramework.Runtime.Global.Defines;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;

namespace VirtualCamera
{
    public static class GlobalValue
    {
        public static readonly int _Params = Shader.PropertyToID("_Params");

        public const string BloomHQ = "_BLOOM_HQ";
        public const string UseRGBM = "_USE_RGBM";
        public static readonly int _Bloom_Params = Shader.PropertyToID("_Bloom_Params");
        public static readonly int _Bloom_RGBM = Shader.PropertyToID("_Bloom_RGBM");
        public static readonly int _Bloom_Texture = Shader.PropertyToID("_Bloom_Texture");
        public static readonly int sourceTex = Shader.PropertyToID("_SourceTex");
        public static readonly int scaleBias = Shader.PropertyToID("_ScaleBias");
        public static readonly int _SourceTexLowMip = Shader.PropertyToID("_SourceTexLowMip");
        public static readonly int _LensDirt_Texture = Shader.PropertyToID("_LensDirt_Texture");
        public static readonly int _LensDirt_Params = Shader.PropertyToID("_LensDirt_Params");
        public static readonly int _LensDirt_Intensity = Shader.PropertyToID("_LensDirt_Intensity");
        public static readonly int _Distortion_Params1 = Shader.PropertyToID("_Distortion_Params1");
        public static readonly int _Distortion_Params2 = Shader.PropertyToID("_Distortion_Params2");

        public static readonly int _Lut_Params = Shader.PropertyToID("_Lut_Params");
        public static readonly int _UserLut_Params = Shader.PropertyToID("_UserLut_Params");
        public static readonly int _InternalLut = Shader.PropertyToID("_InternalLut");
        public static readonly int _UserLut = Shader.PropertyToID("_UserLut");

        public readonly static int _Time = Shader.PropertyToID("_Time");
        public readonly static int _WorldSpaceCameraPos = Shader.PropertyToID("_WorldSpaceCameraPos");
        public readonly static int _ScreenParams = Shader.PropertyToID("_ScreenParams");
        public readonly static int _ScaledScreenParams = Shader.PropertyToID("_ScaledScreenParams");
        public readonly static int _ZBufferParams = Shader.PropertyToID("_ZBufferParams");
        public readonly static int _unity_OrthoParams = Shader.PropertyToID("unity_OrthoParams");
        public readonly static int _unity_SpecCube0 = Shader.PropertyToID("unity_SpecCube0");
    }

    [ExecuteAlways]
    public partial class VirtualCamera : MonoBehaviour
    {
        public bool orthographic;
        public float orthographicSize = 1;

        [Range(1, 179)] public float fieldOfView = 60f;
        [SerializeField] private float nearClipPlane = 0.01f;
        [SerializeField] private float farClipPlane = 1000f;
        [SerializeField] private Color _clearColor = Color.black;
        [SerializeField] private Texture _clearTexture = null;

        [SerializeField] private Cubemap _environmentMap;

        public float aspect => (float)_backBuffer.width / _backBuffer.height;
        public int2 bufferSize = new int2(512, 512);

        public RenderTexture ColorBuffer
        {
            get => _backBuffer;
            set => _backBuffer = value;
        }
        [SerializeField] private RenderTexture _backBuffer;
        [SerializeField] private RenderTexture _outputBuffer;
        private bool _backbufferGenerated = false;

        [Space(20)]
        [SerializeField] private List<Renderer> _renderers;

        [Space(20)]
        [SerializeField] private bool _enablePostprocess;
        [SerializeField] private PostProcess _postprocess;

        private string _cmdName;
        private Matrix4x4 _vpMatrix;

        private void Awake()
        {
            _cmdName = $"Render Virtual Camera({GetInstanceID()})";
        }

        private void OnEnable()
        {
            if (_backBuffer == null)
            {
                if (_enablePostprocess == true)
                    _backBuffer = new RenderTexture(bufferSize.x, bufferSize.y, GraphicsFormat.B10G11R11_UFloatPack32, GraphicsFormat.D24_UNorm_S8_UInt);
                else
                    _backBuffer = new RenderTexture(bufferSize.x, bufferSize.y, GraphicsFormat.R8G8B8A8_SRGB, GraphicsFormat.D24_UNorm_S8_UInt);
                _backBuffer.Create();
                _backbufferGenerated = true;
            }
            RenderPipelineManager.endContextRendering += RenderPipelineManager_BeginFrameRendering;
        }

        private void OnDisable()
        {
            RenderPipelineManager.endContextRendering -= RenderPipelineManager_BeginFrameRendering;
        }

        private void OnDestroy()
        {
            if (_backbufferGenerated == true)
                GameObject.DestroyImmediate(_backBuffer);
        }

        private void RenderPipelineManager_BeginFrameRendering(ScriptableRenderContext context, List<Camera> cameras)
        {
            if (cameras.Count == 0)
                return;
            if (cameras[0].cameraType != CameraType.Game)
                return;

            var cmd = BeginRendering();
            Render(cmd);
            EndRendering(cmd);
        }

        public void AddRenderer(IEnumerable<Renderer> renderers)
        {
            _renderers.AddRange(renderers);
        }

        public void AddRenderer(Renderer renderer)
        {
            _renderers.Add(renderer);
        }

        public void ClearRenderer()
        {
            _renderers.Clear();
        }

        private CommandBuffer BeginRendering()
        {
            var cmd = CommandBufferPool.Get(_cmdName);
            cmd.BeginSample("Render");
            {
                var viewMatrix = Matrix4x4.TRS(transform.position, transform.rotation, new Vector3(1, 1, -1)).inverse;
                var projectionMatrix = default(Matrix4x4);
                if (orthographic == true)
                {
                    float height = orthographicSize;
                    float width = height * aspect;
                    var size = new float2(width, height);
                    projectionMatrix = Matrix4x4.Ortho(-size.x, size.x, -size.y, size.y, nearClipPlane, farClipPlane);
                }
                else
                    projectionMatrix = Matrix4x4.Perspective(fieldOfView, aspect, nearClipPlane, farClipPlane);

                cmd.SetRenderTarget(new RenderTargetIdentifier(_backBuffer));
                cmd.ClearRenderTarget(true, true, _clearColor);

                if (_clearTexture != null)
                {
                    cmd.Blit(_clearTexture, _backBuffer);
                }

                cmd.SetProjectionMatrix(projectionMatrix);
                cmd.SetViewMatrix(viewMatrix);

                _vpMatrix = projectionMatrix * viewMatrix;

                var cameraWidth = (float)_backBuffer.width;
                var cameraHeight = (float)_backBuffer.height;
                var scaledCameraWidth = (float)cameraWidth;
                var scaledCameraHeight = (float)cameraHeight;

                var near = nearClipPlane;
                var far = farClipPlane;
                var invNear = Mathf.Approximately(near, 0.0f) ? 0.0f : 1.0f / near;
                var invFar = Mathf.Approximately(far, 0.0f) ? 0.0f : 1.0f / far;
                var isOrthographic = orthographic ? 1.0f : 0.0f;

                var zc0 = 1.0f - far * invNear;
                var zc1 = far * invNear;

                var zBufferParams = new Vector4(zc0, zc1, zc0 * invFar, zc1 * invFar);
                if (SystemInfo.usesReversedZBuffer)
                {
                    zBufferParams.y += zBufferParams.x;
                    zBufferParams.x = -zBufferParams.x;
                    zBufferParams.w += zBufferParams.z;
                    zBufferParams.z = -zBufferParams.z;
                }

                var orthoParams = new Vector4(orthographicSize * aspect, orthographicSize, 0.0f, isOrthographic);

                cmd.SetGlobalVector(GlobalValue._Time, new Vector4(Time.time / 20, Time.time, Time.time * 2, Time.time * 3));
                cmd.SetGlobalVector(GlobalValue._WorldSpaceCameraPos, transform.position);
                cmd.SetGlobalVector(GlobalValue._ScreenParams, new Vector4(cameraWidth, cameraHeight, 1.0f + 1.0f / cameraWidth, 1.0f + 1.0f / cameraHeight));
                cmd.SetGlobalVector(GlobalValue._ScaledScreenParams, new Vector4(scaledCameraWidth, scaledCameraHeight, 1.0f + 1.0f / scaledCameraWidth, 1.0f + 1.0f / scaledCameraHeight));
                cmd.SetGlobalVector(GlobalValue._ZBufferParams, zBufferParams);
                cmd.SetGlobalVector(GlobalValue._unity_OrthoParams, orthoParams);
                cmd.SetGlobalTexture(GlobalValue._unity_SpecCube0, _environmentMap);
            }
            return cmd;
        }

        private void Render(CommandBuffer cmd)
        {
            if (_renderers == null)
                return;
            foreach (var renderer in _renderers)
            {
                if (renderer.enabled == false)
                    continue;
                if (renderer.gameObject.activeInHierarchy == false)
                    continue;
                for (var i = 0; i < renderer.sharedMaterials.Length; ++i)
                {
                    if (renderer.sharedMaterials[i] == null)
                        continue;
                    cmd.DrawRenderer(renderer, renderer.sharedMaterials[i], i, 0);
                }
            }
        }

        private void EndRendering(CommandBuffer cmd)
        {
            if (_enablePostprocess == true)
                _postprocess.Execute(cmd, _backBuffer);
            if (_outputBuffer != null)
                cmd.Blit(_backBuffer, _outputBuffer);

            cmd.EndSample("Render");

            Graphics.ExecuteCommandBuffer(cmd);
            cmd.Clear();
            CommandBufferPool.Release(cmd);
        }

        public Ray ViewportPointToRay(Vector2 viewportPosition)
        {
            var viewMatrix = Matrix4x4.TRS(transform.position, transform.rotation, new Vector3(1, 1, -1));
            var projectionMatrix = default(Matrix4x4);
            if (orthographic == true)
            {
                float height = orthographicSize;
                float width = height * aspect;
                var size = new float2(width, height);
                projectionMatrix = Matrix4x4.Ortho(-size.x, size.x, -size.y, size.y, nearClipPlane, farClipPlane);
            }
            else
                projectionMatrix = Matrix4x4.Perspective(fieldOfView, aspect, nearClipPlane, farClipPlane);

            var m = projectionMatrix * viewMatrix.inverse;
            var mInv = m.inverse;
            // near clipping plane point
            var p = new Vector4(viewportPosition.x * 2 - 1, viewportPosition.y * 2 - 1, -1, 1f);
            var p0 = mInv * p;
            p0 /= p0.w;
            // far clipping plane point
            p.z = 1;
            var p1 = mInv * p;
            p1 /= p1.w;
            return new Ray(p0, (p1 - p0).normalized);
        }

        public Vector2 WorldToScreenSpace(Vector3 positionWS)
        {
            var positionCS = _vpMatrix * new Vector4(positionWS.x, positionWS.y, positionWS.z, 1.0f);

            if (positionCS.w <= 0)
                return new Vector2(-1, -1);

            var positionNDC = new Vector3(positionCS.x / positionCS.w, positionCS.y / positionCS.w, positionCS.z / positionCS.w);

            var screenX = (positionNDC.x + 1.0f) / 2.0f * _backBuffer.width;
            var screenY = (positionNDC.y + 1.0f) / 2.0f * _backBuffer.height;
            return new Vector2(screenX, screenY);
        }

        public Vector3 WorldToViewportManual(Vector3 positionWS)
        {
            var viewMatrix = Matrix4x4.TRS(transform.position, transform.rotation, new Vector3(1, 1, -1)).inverse;
            var projectionMatrix = default(Matrix4x4);
            if (orthographic == true)
            {
                float height = orthographicSize;
                float width = height * aspect;
                var size = new float2(width, height);
                projectionMatrix = Matrix4x4.Ortho(-size.x, size.x, -size.y, size.y, nearClipPlane, farClipPlane);
            }
            else
                projectionMatrix = Matrix4x4.Perspective(fieldOfView, aspect, nearClipPlane, farClipPlane);

            var vpMatrix = projectionMatrix * viewMatrix;

            var clipPoint = vpMatrix * new Vector4(positionWS.x, positionWS.y, positionWS.z, 1.0f);

            // positionCS.w가 0 이하이면 점이 카메라 뒤에 있거나 무한대에 있는 것입니다.
            if (clipPoint.w <= 0)
            {
                // Unity의 동작과 유사하게 z값만 음수로 반환하거나 할 수 있습니다.
                return new Vector3(0, 0, clipPoint.w);
            }

            // 4. 원근 나누기(Perspective Divide)를 통해 NDC 좌표를 계산합니다.
            Vector3 ndcPoint = new Vector3(clipPoint.x / clipPoint.w, clipPoint.y / clipPoint.w, clipPoint.z / clipPoint.w);

            // 5. NDC(-1 ~ 1)를 Viewport(0 ~ 1) 공간으로 변환합니다.
            float viewportX = (ndcPoint.x + 1.0f) / 2.0f;
            float viewportY = (ndcPoint.y + 1.0f) / 2.0f;

            // 6. Z값은 Unity의 WorldToViewportPoint와 동일하게 카메라와의 월드 거리를 사용합니다.
            // 이 거리는 View 공간에서의 Z값과 같습니다.
            Vector4 viewPoint = viewMatrix * new Vector4(positionWS.x, positionWS.y, positionWS.z, 1.0f);
            float worldDistance = -viewPoint.z; // Unity는 오른손 좌표계를 사용하므로 카메라 앞이 -Z 방향

            return new Vector3(viewportX, viewportY, worldDistance);
        }

        public struct CameraData
        {
            public Vector3 position;
            public Quaternion rotation;
            public bool orthographic;
            public float orthographicSize;
            public float fieldOfView;
            public float nearClipPlane;
            public float farClipPlane;
            public Color clearColor;
            public bool clearRenderTarget;
            public RenderTexture renderTexture;
            public bool enablePostprocess;
        }

        public struct RenderCommand
        {

        }

        public static void BeginRender(out CommandBuffer cmd, in CameraData cameraData)
        {
            var cameraWidth = (float)cameraData.renderTexture.width;
            var cameraHeight = (float)cameraData.renderTexture.height;
            var scaledCameraWidth = (float)cameraWidth;
            var scaledCameraHeight = (float)cameraHeight;
            var aspect = cameraWidth / cameraHeight;

            var viewMatrix = Matrix4x4.TRS(cameraData.position, cameraData.rotation, new Vector3(1, 1, -1));
            var projectionMatrix = default(Matrix4x4);
            if (cameraData.orthographic == true)
            {
                float height = cameraData.orthographicSize;
                float width = height * aspect;
                var size = new float2(width, height);
                projectionMatrix = Matrix4x4.Ortho(-size.x, size.x, -size.y, size.y, cameraData.nearClipPlane, cameraData.farClipPlane);
            }
            else
                projectionMatrix = Matrix4x4.Perspective(cameraData.fieldOfView, aspect, cameraData.nearClipPlane, cameraData.farClipPlane);

            var near = cameraData.nearClipPlane;
            var far = cameraData.farClipPlane;
            var invNear = Mathf.Approximately(near, 0.0f) ? 0.0f : 1.0f / near;
            var invFar = Mathf.Approximately(far, 0.0f) ? 0.0f : 1.0f / far;
            var isOrthographic = cameraData.orthographic ? 1.0f : 0.0f;

            var zc0 = 1.0f - far * invNear;
            var zc1 = far * invNear;
            var zBufferParams = new Vector4(zc0, zc1, zc0 * invFar, zc1 * invFar);
            if (SystemInfo.usesReversedZBuffer)
            {
                zBufferParams.y += zBufferParams.x;
                zBufferParams.x = -zBufferParams.x;
                zBufferParams.w += zBufferParams.z;
                zBufferParams.z = -zBufferParams.z;
            }

            var orthoParams = new Vector4(cameraData.orthographicSize * aspect, cameraData.orthographicSize, 0.0f, isOrthographic);

            cmd = CommandBufferPool.Get("Virtual Camera(Instance)");
            cmd.BeginSample("Set VirtualCamera Render Status");
            {
                cmd.SetRenderTarget(new RenderTargetIdentifier(cameraData.renderTexture));
                if (cameraData.clearRenderTarget == true)
                    cmd.ClearRenderTarget(true, true, cameraData.clearColor, 1);

                cmd.SetProjectionMatrix(projectionMatrix);
                cmd.SetViewMatrix(viewMatrix.inverse);
                cmd.SetGlobalVector(GlobalValue._Time, new Vector4(Time.time / 20, Time.time, Time.time * 2, Time.time * 3));
                cmd.SetGlobalVector(GlobalValue._WorldSpaceCameraPos, cameraData.position);
                cmd.SetGlobalVector(GlobalValue._ScreenParams, new Vector4(cameraWidth, cameraHeight, 1.0f + 1.0f / cameraWidth, 1.0f + 1.0f / cameraHeight));
                cmd.SetGlobalVector(GlobalValue._ScaledScreenParams, new Vector4(scaledCameraWidth, scaledCameraHeight, 1.0f + 1.0f / scaledCameraWidth, 1.0f + 1.0f / scaledCameraHeight));
                cmd.SetGlobalVector(GlobalValue._ZBufferParams, zBufferParams);
                cmd.SetGlobalVector(GlobalValue._unity_OrthoParams, orthoParams);
            }
            cmd.EndSample("Set VirtualCamera Render Status");

        }

        public static void Render(CommandBuffer cmd, Renderer renderer, IEnumerable<Material> materials, int shaderPass = 0)
        {
            if (renderer == null)
                return;
            if (renderer.enabled == false)
                return;
            if (renderer.gameObject.activeSelf == false)
                return;

            var idxSubMesh = -1;
            foreach (var material in materials)
            {
                idxSubMesh++;
                if (material == null)
                    continue;
                cmd.DrawRenderer(renderer, material, idxSubMesh, shaderPass);
            }
        }

        public static void EndRender(CommandBuffer cmd, in CameraData cameraData)
        {
            if (cameraData.enablePostprocess == true)
                ResourceManager.Instance.GlobalPostprocess.Execute(cmd, cameraData.renderTexture);
            //_postprocess.Execute(cmd, _backBuffer);
            //if (_outputBuffer != null)
            //    cmd.Blit(_backBuffer, _outputBuffer);

            Graphics.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        public static void Render(in CameraData cameraData, IEnumerable<Renderer> renderers, int shaderPass = 0)
        {
            BeginRender(out var cmd, in cameraData);

            foreach (var renderer in renderers)
                Render(cmd, renderer, renderer.sharedMaterials);

            EndRender(cmd, in cameraData);
        }

        public static (Vector3, Vector3) CalculateMinMax(in CameraData cameraData, Mesh mesh, Matrix4x4 objectMatrix)
        {
            var cameraWidth = (float)cameraData.renderTexture.width;
            var cameraHeight = (float)cameraData.renderTexture.height;
            var scaledCameraWidth = (float)cameraWidth;
            var scaledCameraHeight = (float)cameraHeight;
            var aspect = cameraWidth / cameraHeight;

            var viewMatrix = Matrix4x4.TRS(cameraData.position, cameraData.rotation, new Vector3(1, 1, -1));
            var projectionMatrix = default(Matrix4x4);
            if (cameraData.orthographic == true)
            {
                float height = cameraData.orthographicSize;
                float width = height * aspect;
                var size = new float2(width, height);
                projectionMatrix = Matrix4x4.Ortho(-size.x, size.x, -size.y, size.y, cameraData.nearClipPlane, cameraData.farClipPlane);
            }
            else
                projectionMatrix = Matrix4x4.Perspective(cameraData.fieldOfView, aspect, cameraData.nearClipPlane, cameraData.farClipPlane);

            var WVP = projectionMatrix * viewMatrix.inverse * objectMatrix;
            var min = new Vector3(float.MaxValue, float.MaxValue, float.MaxValue);
            var max = new Vector3(float.MinValue, float.MinValue, float.MinValue);

#if TEST_PRINT
		var testBuffer = new Texture2D(cameraData.renderTexture.width, cameraData.renderTexture.height, TextureFormat.ARGB32, false);
		var colors = testBuffer.GetPixels();
		for (var i = 0; i < colors.Length; ++i)
			colors[i] = Color.black;
        testBuffer.SetPixels(colors);
#endif

            for (var i = 0; i < mesh.vertices.Length; ++i)
            {
                //Clipping Space
                var point = new Vector4(mesh.vertices[i].x, mesh.vertices[i].y, mesh.vertices[i].z, 1);
                point = WVP * point;

                //NDC Space
                point /= point.w;

                min = Vector3.Min(min, point);
                max = Vector3.Max(max, point);

                var float3Point = (float4)point;
                float3Point += 1;
                float3Point /= 2;
                float3Point *= 127;

#if TEST_PRINT
            testBuffer.SetPixel((int)float3Point.x, (int)float3Point.y, Color.red);
#endif
            }

#if TEST_PRINT
		//Mesh Pivot Position
		{
			//Clip
			var point = projectionMatrix * viewMatrix.inverse * new Vector4(0, 0, 0, 1);

			//NDC
			point /= point.w;

			var float3Point = (float4)point;
			float3Point += 1;
			float3Point /= 2;
			float3Point *= 127;
            testBuffer?.SetPixel((int)float3Point.x, (int)float3Point.y, Color.cyan);
        }

        //Camera Target Position
        {
            //Clip
            var point = projectionMatrix * viewMatrix.inverse * new Vector4(0, 0.35f, 0, 1);

            //NDC
            point /= point.w;

            var float3Point = (float4)point;
            float3Point += 1;
            float3Point /= 2;
            float3Point *= 127;
            testBuffer?.SetPixel((int)float3Point.x, (int)float3Point.y, Color.yellow);
        }
        testBuffer.Apply();
        EditorUtility.OpenPropertyEditor(testBuffer);
#endif

            return (min, max);
        }

        private Plane[] _frustumPlanes = new Plane[6];
        public bool CheckFrustumCulling(Bounds bounds)
        {
            GeometryUtility.CalculateFrustumPlanes(_vpMatrix, _frustumPlanes);
            return GeometryUtility.TestPlanesAABB(_frustumPlanes, bounds);
        }

        static Mesh s_FullscreenMesh = null;
        public static Mesh fullscreenMesh
        {
            get
            {
                if (s_FullscreenMesh != null)
                    return s_FullscreenMesh;

                float topV = 1.0f;
                float bottomV = 0.0f;

                s_FullscreenMesh = new Mesh { name = "Fullscreen Quad" };
                s_FullscreenMesh.SetVertices(new List<Vector3>
                {
                    new Vector3(-1.0f, -1.0f, 0.0f),
                    new Vector3(-1.0f,  1.0f, 0.0f),
                    new Vector3(1.0f, -1.0f, 0.0f),
                    new Vector3(1.0f,  1.0f, 0.0f)
                });

                s_FullscreenMesh.SetUVs(0, new List<Vector2>
                {
                    new Vector2(0.0f, bottomV),
                    new Vector2(0.0f, topV),
                    new Vector2(1.0f, bottomV),
                    new Vector2(1.0f, topV)
                });

                s_FullscreenMesh.SetIndices(new[] { 0, 1, 2, 2, 1, 3 }, MeshTopology.Triangles, 0, false);
                s_FullscreenMesh.UploadMeshData(true);
                return s_FullscreenMesh;
            }
        }
    }

#if UNITY_EDITOR
    //[Icon("Packages/com.patrickgames.devkit/Runtime/Gizmos/camera_icon.png")]

    public partial class VirtualCamera
    {
        private void OnDrawGizmos()
        {
            if (enabled == false)
                return;

            //var assembly = Assembly.GetExecutingAssembly();
            //var packagePath = PackagePath.FindForAssembly(assembly).assetPath;
            //Gizmos.DrawIcon(transform.position, packagePath + "/Path/In/Package/Gizmo.png", true);

            var cachedColor = Gizmos.color;
            Gizmos.color = new Color(0, 1, 1, 0.3f);
            Gizmos.DrawIcon(transform.position, $"{VPackage.Path.PixelCanvas}/Runtime/VirtualCamera/camera_icon.png", true, Gizmos.color);

            if (orthographic == true)
            {
                float height = 2f * orthographicSize;
                float width = height * aspect;
                float depth = farClipPlane;

                var size = new Vector3(width, height, depth);
                Gizmos.DrawWireCube(transform.position + Vector3.forward * (depth * 0.5f), size);
            }
            else
            {
                Gizmos.matrix = transform.localToWorldMatrix;

                Gizmos.DrawFrustum(Vector3.zero,
                    fieldOfView,
                    farClipPlane,
                    nearClipPlane,
                    aspect);

                Gizmos.matrix = Matrix4x4.identity;
            }

            Gizmos.color = cachedColor;
        }
    }
#endif
}