using Cysharp.Threading.Tasks;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

using Unity.Mathematics;

using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.EventSystems;
using UnityEngine.UI;

using VirtualCamera;

namespace PixelCanvas
{
    public class ResultViewer : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler, IScrollHandler
    {
        [SerializeField] private Environment3D_ResultViewer _environment3D;
        [SerializeField] private RawImage _rawImage;
        [SerializeField] private Transform _model;
        [SerializeField] private MeshFilter _meshFilter;
        [SerializeField] private MeshRenderer _meshRenderer;
        [SerializeField] private Toggle _partitionVisibleToggle;

        [Header("Fidget Spinnger Propoerties")]
        [SerializeField] private float _deltaMultiplier = 5;
        [SerializeField] private float _toIdleDeltaThreashold = 5;

        private int _dragEventEnterCounter;
        private bool _toIdleAvailable;

        private Dictionary<int, PointerEventData> _inputCollector = new Dictionary<int, PointerEventData>();

        private void Awake()
        {
            _partitionVisibleToggle.onValueChanged.AddListener((toggle) => 
            {
                Shader.SetGlobalFloat(GlobalValue._PartitionLock, 1 - ((toggle) ? 0 : 1));
            });

            _rawImage.material.SetFloat("_Toggle", 0);
            _rawImage.material.SetFloat("_ToggleTime", 0);
		}

        private void Update()
        {
            _dragEventEnterCounter = 0;

            // if (_draggedOnPrvFrame == false)
            //     _dragForce *= 0.5f;
            
            if (_environment3D.Pressed == true)
                _dragForce *= 0.8f;

            _draggedOnPrvFrame = false;
        }

        private bool _draggedOnPrvFrame;
        private Vector2 _dragForce;

        public void OnPointerDown(PointerEventData eventData)
        {
            if (1 < _inputCollector.Count)
                return;
            _inputCollector.Add(eventData.pointerId, eventData);

            _rawImage.material.SetFloat("_Toggle", 1);
            _rawImage.material.SetFloat("_ToggleTime", Time.time);

            _environment3D.Pressed = true;
            _toIdleAvailable = false;
        }

        public void OnDrag(PointerEventData eventData)
        {
            if (_inputCollector.ContainsKey(eventData.pointerId) == false)
                return;

            switch(_inputCollector.Count)
            {
                case 1:
                    {
                        _toIdleAvailable = true;
                        _draggedOnPrvFrame = true;

                        var delta = eventData.delta;
                        var forceDelta = _environment3D.ForceDelta;

                        if (0 < forceDelta.x)
                            forceDelta.x = math.clamp(forceDelta.x - delta.x, 0, float.MaxValue);
                        else if (0 > forceDelta.x)
                            forceDelta.x = math.clamp(forceDelta.x - delta.x, float.MinValue, 0);
                        else
                            forceDelta.x = 0;

                        if (0 < forceDelta.y)
                            forceDelta.y = math.clamp(forceDelta.y - delta.y, 0, float.MaxValue);
                        else if (0 > forceDelta.y)
                            forceDelta.y = math.clamp(forceDelta.y - delta.y, float.MinValue, 0);
                        else
                            forceDelta.y = 0;

                        delta = (_environment3D.ForceDelta - forceDelta) + eventData.delta;
                        _environment3D.ForceDelta = forceDelta;

                        if (forceDelta.sqrMagnitude == 0)
                        {
                            if (math.sign(_dragForce.x) != math.sign(delta.x))
                                _dragForce.x = 0;
                            if (math.sign(_dragForce.y) != math.sign(delta.y))
                                _dragForce.y = 0;
                        }
                        //_dragForce = _dragForce + delta;

                        var euler = _environment3D.Euler;
                        euler += delta;
                        euler.x = euler.x % 360;
                        euler.y = Mathf.Clamp(euler.y, -90, 90);
                        _environment3D.Euler = euler;
                        _environment3D.ModelHandle.transform.rotation = Quaternion.Euler(0, -euler.x, 0);
                        _environment3D.ModelHandle.transform.rotation = Quaternion.Euler(euler.y, 0, 0) * _environment3D.ModelHandle.transform.rotation;
                    }
                    break;
                case 2:
                    {
                        _dragEventEnterCounter++;
                        if (_dragEventEnterCounter != 2)
                            return;

                        var eventData_0 = _inputCollector.First().Value;
                        var eventData_1 = _inputCollector.Last().Value;

                        var prvTouchZeroPos = eventData_0.position - eventData_0.delta;
                        var prvTouchOnePos = eventData_1.position - eventData_1.delta;
                        var prevTouchDeltaMag = (prvTouchZeroPos - prvTouchOnePos).magnitude;
                        var touchDeltaMag = (eventData_0.position - eventData_1.position).magnitude;
                        var prvMultiTouchCenterPos = (prvTouchZeroPos + prvTouchOnePos) * 0.5f;
                        var currMultiTouchCenterPos = (eventData_0.position + eventData_1.position) * 0.5f;
                        var multiTouchCenterPosDelata = currMultiTouchCenterPos - prvMultiTouchCenterPos;

                        var pinchDelta = (touchDeltaMag - prevTouchDeltaMag) * 0.3f;
                        _environment3D.VirtualCamera.fieldOfView -= pinchDelta;
                        _environment3D.VirtualCamera.fieldOfView = Mathf.Clamp(_environment3D.VirtualCamera.fieldOfView, 20, 90);

                        _toIdleAvailable = true;

                    }
                    break;
            }
        }

        public void OnPointerUp(PointerEventData eventData)
        {
            if (_inputCollector.ContainsKey(eventData.pointerId) == false)
                return;
            _inputCollector.Remove(eventData.pointerId);

            if (_inputCollector.Count == 0)
            {
                _rawImage.material.SetFloat("_Toggle", 0);
                _rawImage.material.SetFloat("_ToggleTime", Time.time);
            }

            _environment3D.Pressed = false;

            var forceDelta = _environment3D.ForceDelta;
            var curForceDeltaAbs = math.abs(_environment3D.ForceDelta);
            var inputForceDeltaAbs = math.abs(_dragForce * _deltaMultiplier);
            var curForceDeltaSign = math.sign(_environment3D.ForceDelta);
            var inputForceDeltaSign = math.sign(_dragForce * _deltaMultiplier);

            if (curForceDeltaSign.x == 0 || curForceDeltaSign.x == inputForceDeltaSign.x)
                forceDelta.x = inputForceDeltaSign.x * math.max(curForceDeltaAbs.x, inputForceDeltaAbs.x);

            if (curForceDeltaSign.y == 0 || curForceDeltaSign.y == inputForceDeltaSign.y)
                forceDelta.y = inputForceDeltaSign.y * math.max(curForceDeltaAbs.y, inputForceDeltaAbs.y);

            _environment3D.ForceDelta = forceDelta;
            _dragForce = Vector2.zero;

            if (_toIdleAvailable == false)
                _environment3D.RotateToIdle(0.2f);
        }

        public void OnScroll(PointerEventData eventData)
        {
            _environment3D.VirtualCamera.fieldOfView -= eventData.scrollDelta.y;
            _environment3D.VirtualCamera.fieldOfView = Mathf.Clamp(_environment3D.VirtualCamera.fieldOfView, 20, 90);
        }
        
        private void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
            }
        }
    }
}