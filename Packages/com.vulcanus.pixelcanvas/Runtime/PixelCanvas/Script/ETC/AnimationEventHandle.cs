using UnityEngine;

namespace PixelCanvas
{
    public class AnimationEventHandle : MonoBehaviour
    {
        public void OnPlayUISound(AnimationEvent animEvent)
        {
            SoundManager.Instance.PlaySound(animEvent.stringParameter);
        }

        public void SetActiveFalse(AnimationEvent @event)
        {
            transform.parent.gameObject.SetActive(false);
        }
    }
}