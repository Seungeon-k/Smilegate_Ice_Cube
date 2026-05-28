using System;
using System.Runtime.CompilerServices;

using UnityEngine;

namespace PixelCanvas
{
    [Serializable]
    public struct IntervalTimerGate
    {
        public float MaxTime
        {
            set => _maxIntervalTime = value;
            get => _maxIntervalTime;
        }

        [SerializeField] private float _maxIntervalTime;
        private float _time;

        public IntervalTimerGate(float maxIntervalTime)
        {
            _maxIntervalTime = maxIntervalTime;
            _time = 0;
        }

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public void RandomStart() => _time = Time.time - UnityEngine.Random.Range(0, _maxIntervalTime);

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public void Reset() => _time = Time.time;

        [MethodImpl(MethodImplOptions.AggressiveInlining)]
        public bool Update()
        {
            var delta = Time.time - _time;
            if (_maxIntervalTime <= delta)
            {
                _time = Time.time;
                //_time = Time.time - (delta - _maxIntervalTime);
                //_time = Time.time - (delta);
                return true;
            }
            return false;
        }
    }
}