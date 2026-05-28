using UnityEngine;
using UnityEditor;
using System;
using System.Reflection;

namespace PixelCanvas
{
	public abstract class RootMonoBehaviour : MonoBehaviour
	{
		protected abstract void Awake();
	}

	public abstract class MonoSingleton<T> : RootMonoBehaviour where T : MonoBehaviour
	{
		public static T Instance
		{
			get
			{
				if (_instance == null)
				{
					if (GlobalValue.ApplicationIsQuitting == false) 
					{
						_instance = Component.FindObjectOfType<T>();
						if (_instance == null)
						{
							var gameObject = new GameObject($"--[{typeof(T).Name}]--");
							_instance = gameObject.AddComponent<T>();
							return _instance;
						}
						(_instance as MonoSingleton<T>).Initialize();
					}
				}
				return _instance;
			}
		}
		private static T _instance;

		protected sealed override void Awake()
		{
			//To Call Initialize On Awake
			if (_instance == null)
			{
				_instance = this as T;
				(_instance as MonoSingleton<T>).Initialize();
			}
		}

		protected abstract void Initialize();

		protected virtual void Destroy()
		{
			GameObject.DestroyImmediate(_instance.gameObject);
			_instance = null;
		}
	}
}
