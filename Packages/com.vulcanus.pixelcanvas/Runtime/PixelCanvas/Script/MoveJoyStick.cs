using PixelCanvas;
using Unity.Mathematics;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UI;

using VirtualCamera;

namespace PixelCanvas
{
	enum EControllerType
	{
		KeyMouse,
		GamePad,
		Touch,
	}

	public enum ETouchType
	{
		None,
		Pressed,
		DoublePressed,
	}

	public class MoveJoyStick : MonoBehaviour, IDragHandler, IPointerUpHandler, IPointerDownHandler
	{
		[SerializeField] private VirtualCamera.VirtualCamera _targetCamera;
		[SerializeField] private Image _normalModeImg;
		[SerializeField] private Image _innerCircleImg;

		[SerializeField] private float _halfRange;
		[SerializeField] private float _minAlpha = 0.1f;
		[SerializeField] private float _maxAlpha = 0.7f;
		[SerializeField] private float _fadeDuration = 0.5f;
		[SerializeField] private float _speed = 50;

		private bool _lateralMoveMode;
		private Vector2 _pressOffset;

		public float HorizontalValue => _inputVector.x;
		public float VerticalValue => _inputVector.y;
		public Vector2 InputVector => _inputVector;
		private Vector2 _inputVector;

		private ETouchType _pressType = ETouchType.None;
		private float _doubleTabTimer = 0;
		private EControllerType _controllerType;

		private bool _active = true;
		private int _buttonPointerID = -1;

		// Use this for initialization
		private void Awake()
		{
			_normalModeImg.CrossFadeAlpha(_minAlpha, _fadeDuration, true);
			_innerCircleImg.CrossFadeAlpha(_minAlpha, _fadeDuration, true);
		}

		private void OnEnable() 
		{
			EventManager.Register(EPixelArtEventID.ToggleJoystick, NotifyEvent);
		}

        private void OnDisable()
        {
			EventManager.Unregister(EPixelArtEventID.ToggleJoystick, NotifyEvent);
        }

		private void Update()
		{
			if (_active == false)
				return;

			//if (Input.GetAxis("Horizontal") != 0 ||
			//	Input.GetAxis("Vertical") != 0 ||
			//	Input.GetButtonDown("AButton") == true ||
			//	Input.GetButtonDown("BButton") == true ||
			//	Input.GetButtonDown("XButton") == true ||
			//	Input.GetButtonDown("YButton") == true)
			//	_controllerType = EControllerType.GamePad;

			if (Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.D) ||
				Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.W) ||
				Input.GetKey(KeyCode.Space) || Input.GetKey(KeyCode.LeftShift))
				_controllerType = EControllerType.KeyMouse;

			switch (_controllerType)
			{
				case EControllerType.Touch:
					{
						if (_pressType == ETouchType.None)
							break;

						var delta = Vector3.zero;
						if (_lateralMoveMode == false)
						{
							delta += _targetCamera.transform.right * _inputVector.x;
							delta += _targetCamera.transform.forward * _inputVector.y;
						}
						else
						{
							delta += _targetCamera.transform.right * _inputVector.x;
							delta += Vector3.up * _inputVector.y;
						}

						if (_pressType == ETouchType.DoublePressed)
							delta *= _speed * 3;
						else
							delta *= _speed;

						if (delta == Vector3.zero)
							break;
						_targetCamera.transform.position += delta * Time.unscaledDeltaTime;
						EventManager.Notify(EPixelArtEventID.ResetAimPosition);
					}
					break;

				case EControllerType.GamePad:
					//var horizontal = Input.GetAxis("Horizontal");
					//var vertical = Input.GetAxis("Vertical");

					//if (Mathf.Abs(horizontal) >= 0.1f || Mathf.Abs(vertical) >= 0.1f)
					//{
					//	_inputVector.x = horizontal;
					//	_inputVector.y = vertical;
					//	if (Input.GetButton("AButton") == true)
					//		_player.StatusData.IsSprintMove = true;
					//	else
					//		_player.StatusData.IsSprintMove = false;
					//}
					//else
					//{
					//	_inputVector.x = 0;
					//}

					//if(Input.GetAxis("RightHorizontal") != 0)
					//	DebugX.LogError(Input.GetAxis("RightHorizontal"));
					//if (Input.GetAxis("RightVertical") != 0)
					//	DebugX.LogError(Input.GetAxis("RightVertical"));


					//if (Input.GetButtonDown("AButton") == true)
					//	DebugX.LogError("A");
					//if (Input.GetButtonDown("BButton") == true)
					//	DebugX.LogError("B");
					//if (Input.GetButtonDown("XButton") == true)
					//	DebugX.LogError("X");
					//if (Input.GetButtonDown("YButton") == true)
					//	DebugX.LogError("Y");
					//if (Input.GetAxis("LTrigger") > 0)
					//	DebugX.LogError(Input.GetAxis("LTrigger"));
					//if (Input.GetAxis("RTrigger") > 0)
					//	DebugX.LogError(Input.GetAxis("RTrigger"));
					break;
				case EControllerType.KeyMouse:
					{
						var delta = Vector3.zero;
						if (Input.GetKey(KeyCode.A))
							delta -= _targetCamera.transform.right;
						if (Input.GetKey(KeyCode.D) == true)
							delta += _targetCamera.transform.right;
						if (Input.GetKey(KeyCode.S))
							delta -= _targetCamera.transform.forward;
						if (Input.GetKey(KeyCode.W))
							delta += _targetCamera.transform.forward;
						if (Input.GetKey(KeyCode.Q))
							delta -= _targetCamera.transform.up;
						if (Input.GetKey(KeyCode.E))
							delta += _targetCamera.transform.up;
						delta.Normalize();

						if (Input.GetKey(KeyCode.LeftShift) == true)
							delta *= _speed * 3;
						else
							delta *= _speed;

						if (delta == Vector3.zero)
							break;
						_targetCamera.transform.position += delta * Time.unscaledDeltaTime;
						EventManager.Notify(EPixelArtEventID.ResetAimPosition);
					}
					break;
			}

			var position = _targetCamera.transform.localPosition;
			_targetCamera.transform.localPosition = math.clamp((float3)position, new float3(-4.9f), new float3(4.9f));
		}

		public void OnPointerDown(PointerEventData ped)
		{
			if (_active == false)
				return;

			if (_buttonPointerID != -1)
				return;
			_buttonPointerID = ped.pointerId;

            _controllerType = EControllerType.Touch;

			_normalModeImg.CrossFadeAlpha(_maxAlpha, _fadeDuration, true);
			_innerCircleImg.CrossFadeAlpha(_maxAlpha, _fadeDuration, true);
			_pressType = ETouchType.Pressed;

			if (Time.unscaledTime - _doubleTabTimer <= 0.3f)
			{
				_pressType = ETouchType.DoublePressed;
			}
			_doubleTabTimer = Time.unscaledTime;

			if (RectTransformUtility.ScreenPointToLocalPointInRectangle(_normalModeImg.rectTransform, ped.position, ped.pressEventCamera, out var pos))
			{
				var delta = pos.magnitude;
				var direction = pos / delta;

				delta = Mathf.Clamp(delta, 0, _halfRange);
				_pressOffset = direction * (delta / _halfRange);
			}

			EventManager.Notify(EPixelArtEventID.SwapMovingMode, true);
		}

		public void OnDrag(PointerEventData ped)
		{
			if (_active == false)
				return;

			if (_buttonPointerID != ped.pointerId)
				return;

            if (RectTransformUtility.ScreenPointToLocalPointInRectangle(_normalModeImg.rectTransform, ped.position, ped.pressEventCamera, out var pos))
			{
				var delta = pos.magnitude;
				var direction = pos / delta;

				_inputVector = direction * (delta / _halfRange) - _pressOffset;
				var magnitude = _inputVector.magnitude;
				direction = _inputVector / magnitude;
				_inputVector = direction * Mathf.Clamp(magnitude, 0, 1);
				_innerCircleImg.rectTransform.anchoredPosition = _inputVector * _halfRange;

				//if (_lateralMoveMode == false)
				//{
				//	if (3.5f < ped.radius.x)
				//	{
				//		_lateralMoveMode = true;
				//		_normalModeImg.CrossFadeAlpha(0, 0.1f, true);
				//	}
				//}
			}
		}

		public void OnPointerUp(PointerEventData ped)
		{
			if (_active == false)
				return;

            if (_buttonPointerID != ped.pointerId)
                return;
			_buttonPointerID = -1;

            _normalModeImg.CrossFadeAlpha(_minAlpha, _fadeDuration, true);
			_innerCircleImg.CrossFadeAlpha(_minAlpha, _fadeDuration, true);

			_pressType = ETouchType.None;
			_inputVector = Vector2.zero;
			_innerCircleImg.rectTransform.anchoredPosition = Vector2.zero;
			_lateralMoveMode = false;

			EventManager.Notify(EPixelArtEventID.SwapMovingMode, false);
		}

		private void NotifyEvent(EPixelArtEventID id, params object[] datas)
		{
			switch (id)
			{
				case EPixelArtEventID.ToggleJoystick:
					{
						var trigger = (bool)datas[0];
						_active = trigger;

						if (trigger == true)
                        {
							_normalModeImg.CrossFadeAlpha(_minAlpha, _fadeDuration, true);
							_innerCircleImg.CrossFadeAlpha(_minAlpha, _fadeDuration, true);
						}
                        else
                        {
							_normalModeImg.CrossFadeAlpha(_minAlpha * 0.1f, _fadeDuration, true);
							_innerCircleImg.CrossFadeAlpha(_minAlpha * 0.1f, _fadeDuration, true);

                            _buttonPointerID = -1;
                            _pressType = ETouchType.None;
                            _inputVector = Vector2.zero;
                            _innerCircleImg.rectTransform.anchoredPosition = Vector2.zero;
                            _lateralMoveMode = false;
                        }
					}
					break;
			}
		}
	}
}