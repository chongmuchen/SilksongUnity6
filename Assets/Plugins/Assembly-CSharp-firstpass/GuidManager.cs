using System;
using System.Collections.Generic;
using UnityEngine;

public class GuidManager
{
	private struct GuidInfo
	{
		public GameObject go;

		public event Action<GameObject> OnAdd;

		public event Action OnRemove;

		public GuidInfo(GuidComponent comp)
		{
			go = comp.gameObject;
			this.OnRemove = null;
			this.OnAdd = null;
		}

		public void HandleAddCallback()
		{
			if (this.OnAdd != null)
			{
				this.OnAdd(go);
			}
		}

		public void HandleRemoveCallback()
		{
			if (this.OnRemove != null)
			{
				this.OnRemove();
			}
		}
	}

	private static GuidManager Instance;

	private Dictionary<Guid, GuidInfo> guidToObjectMap;

	public static bool Add(GuidComponent guidComponent)
	{
		if (Instance == null)
		{
			Instance = new GuidManager();
		}
		return Instance.InternalAdd(guidComponent);
	}

	public static void Remove(Guid guid)
	{
		if (Instance == null)
		{
			Instance = new GuidManager();
		}
		Instance.InternalRemove(guid);
	}

	public static GameObject ResolveGuid(Guid guid, Action<GameObject> onAddCallback, Action onRemoveCallback)
	{
		if (Instance == null)
		{
			Instance = new GuidManager();
		}
		return Instance.ResolveGuidInternal(guid, onAddCallback, onRemoveCallback);
	}

	public static GameObject ResolveGuid(Guid guid, Action onDestroyCallback)
	{
		if (Instance == null)
		{
			Instance = new GuidManager();
		}
		return Instance.ResolveGuidInternal(guid, null, onDestroyCallback);
	}

	public static GameObject ResolveGuid(Guid guid)
	{
		if (Instance == null)
		{
			Instance = new GuidManager();
		}
		return Instance.ResolveGuidInternal(guid, null, null);
	}

	private GuidManager()
	{
		guidToObjectMap = new Dictionary<Guid, GuidInfo>();
	}

	private bool InternalAdd(GuidComponent guidComponent)
	{
		Guid guid = guidComponent.GetGuid();
		GuidInfo value = new GuidInfo(guidComponent);
		if (!guidToObjectMap.ContainsKey(guid))
		{
			guidToObjectMap.Add(guid, value);
			return true;
		}
		GuidInfo value2 = guidToObjectMap[guid];
		if (value2.go != null && value2.go != guidComponent.gameObject)
		{
			if (!Application.isPlaying)
			{
				Debug.LogWarningFormat(guidComponent, "Guid Collision Detected while creating {0}.\nAssigning new Guid.", (guidComponent != null) ? guidComponent.name : "NULL");
			}
			return false;
		}
		value2.go = value.go;
		value2.HandleAddCallback();
		guidToObjectMap[guid] = value2;
		return true;
	}

	private void InternalRemove(Guid guid)
	{
		if (guidToObjectMap.TryGetValue(guid, out var value))
		{
			value.HandleRemoveCallback();
		}
		guidToObjectMap.Remove(guid);
	}

	private GameObject ResolveGuidInternal(Guid guid, Action<GameObject> onAddCallback, Action onRemoveCallback)
	{
		if (guidToObjectMap.TryGetValue(guid, out var value))
		{
			if (onAddCallback != null)
			{
				value.OnAdd += onAddCallback;
			}
			if (onRemoveCallback != null)
			{
				value.OnRemove += onRemoveCallback;
			}
			guidToObjectMap[guid] = value;
			return value.go;
		}
		if (onAddCallback != null)
		{
			value.OnAdd += onAddCallback;
		}
		if (onRemoveCallback != null)
		{
			value.OnRemove += onRemoveCallback;
		}
		guidToObjectMap.Add(guid, value);
		return null;
	}
}
