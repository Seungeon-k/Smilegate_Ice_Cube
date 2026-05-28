using UnityEngine;
using UnityEditor;
using System.Reflection;

namespace PixelCanvas
{
	public abstract class Singleton<T> where T : class, new()
	{
		private static T _instance;

		public static T Instance
		{
			get
			{
				if (_instance != null)
					return _instance;

				if (GlobalValue.ApplicationIsQuitting == false)
				{
					_instance = new T();
					(_instance as Singleton<T>).Initialize();
				}
				return _instance;
			}
		}

		protected abstract void Initialize();

		public virtual void Destroy()
		{
			_instance = null;
		}

		public void ChangeInstance<T2>() where T2 : class, T, new()
		{
			_instance = new T2();
			(_instance as Singleton<T>).Initialize();
		}
	}
}
