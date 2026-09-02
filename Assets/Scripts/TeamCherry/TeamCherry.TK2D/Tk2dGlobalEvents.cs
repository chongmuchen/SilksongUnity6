using System.Collections.Generic;
using TeamCherry.SharedUtils;
using UnityEngine;

public static class Tk2dGlobalEvents
{
	public interface IListener
	{
		void ColliderUpdated(GameObject gameObject);

		void TilemapChunkCreated(Transform grandChild);

		bool IsFrozenCameraRendering();
	}

	private static List<IListener> _listeners;

	public static void AddListener(IListener listener)
	{
		if (_listeners == null)
		{
			_listeners = new List<IListener>();
		}
		_listeners.AddIfNotPresent(listener);
	}

	public static void RemoveListener(IListener listener)
	{
		_listeners?.Remove(listener);
	}

	public static void ColliderUpdated(GameObject gameObject)
	{
		if (_listeners == null)
		{
			return;
		}
		foreach (IListener listener in _listeners)
		{
			listener.ColliderUpdated(gameObject);
		}
	}

	public static void TilemapChunkCreated(Transform grandChild)
	{
		if (_listeners == null)
		{
			return;
		}
		foreach (IListener listener in _listeners)
		{
			listener.TilemapChunkCreated(grandChild);
		}
	}

	public static bool IsFrozenCameraRendering()
	{
		if (_listeners == null)
		{
			return false;
		}
		foreach (IListener listener in _listeners)
		{
			if (listener.IsFrozenCameraRendering())
			{
				return true;
			}
		}
		return false;
	}
}
