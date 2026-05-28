using System.Threading;

using Cysharp.Threading.Tasks;

using TMPro;

using UnityEngine;

namespace PixelCanvas
{
    public class UIToastMesaage : MonoBehaviour
    {
        [SerializeField] private Animator _animator;
        [SerializeField] private CanvasGroup _canvasGroup;
        [SerializeField] private TMP_Text _text;
        [SerializeField] protected AnimationCurve _curve;

        private CancellationTokenSource _cancellationTokenSource = new CancellationTokenSource();

        private void Awake()
        {
            _animator.Play("Toast_Message", 0, 1);
            EventManager.Register(EPixelArtEventID.ShowToastMessage, NotifyEvent);
        }

        private void OnDestroy()
        {
            EventManager.Unregister(EPixelArtEventID.ShowToastMessage, NotifyEvent);
        }

        private async void ShowToastMessage(string message, CancellationToken token)
        {
            if (TextTable.TryGetTextDataString(message, out var text) == true)
                message = text;

            _text.text = message;
            _animator.Play("Toast_Message", 0, 0);

            //var maxTime = _curve[_curve.length - 1].time;
            //var time = Time.unscaledTime;

            //var destroy = this.GetCancellationTokenOnDestroy();
            //while (true)
            //{
            //    if (destroy.IsCancellationRequested == true)
            //        return;
            //    if (token.IsCancellationRequested == true)
            //        return;
            //    var elapsedTime = Time.unscaledTime - time;
            //    if (maxTime < elapsedTime)
            //        break;

            //    _canvasGroup.alpha = _curve.Evaluate(elapsedTime);
            //    await UniTask.Yield();
            //}
        }

        private void NotifyEvent(EPixelArtEventID id, params object[] datas)
        {
            switch (id)
            {
                case EPixelArtEventID.ShowToastMessage:
                    {
                        var message = datas[0] as string;

                        if (_cancellationTokenSource != null)
                        {
                            _cancellationTokenSource.Cancel();
                            _cancellationTokenSource.Dispose();
                        }
                        _cancellationTokenSource = new CancellationTokenSource();
                        ShowToastMessage(message, _cancellationTokenSource.Token);
                    }
                    break;
            }
        }
    }
}
