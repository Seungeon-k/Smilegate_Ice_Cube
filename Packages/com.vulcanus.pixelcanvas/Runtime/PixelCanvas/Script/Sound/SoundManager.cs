using UnityEngine;
using UnityEngine.Audio;

namespace PixelCanvas
{
    public partial class SoundManager : MonoSingleton<SoundManager>
    {
        private AudioMixer _audioMixer;
        AudioMixerGroup _audioGroupSFX = null;
        AudioMixerGroup _audioGroupBGM = null;

        private AudioSource _audioSource;

        protected override void Initialize()
        {
            _audioSource = gameObject.AddComponent<AudioSource>();

            if (_audioMixer == null)
            {
                _audioMixer = Resources.Load<AudioMixer>("BubblizMixer");
                if (_audioMixer != null)
                {
                    var groups = _audioMixer.FindMatchingGroups("Master/Ingame/SFX");
                    if (groups != null && groups.Length > 0)
                        _audioGroupSFX = groups[0];

                    groups = _audioMixer.FindMatchingGroups("Master/Ingame/BGM");
                    if (groups != null && groups.Length > 0)
                        _audioGroupBGM = groups[0];

                    _audioSource.outputAudioMixerGroup = _audioGroupSFX;
                }
            }
        }

        protected override void Destroy()
        {
            base.Destroy();

            _audioMixer = null;
            _audioGroupSFX = null;
            _audioGroupBGM = null;
        }

        public void PlaySound(string audioClipName)
        {
            if (ResourceManager.Instance.TryGetAudioClip(audioClipName, out var audioClip) == false)
                return;

            _audioSource.clip = audioClip;
            _audioSource.Play();
        }
    }

}