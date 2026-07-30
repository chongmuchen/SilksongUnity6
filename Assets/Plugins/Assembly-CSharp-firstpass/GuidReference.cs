using System;
using UnityEngine;

[Serializable]
public class GuidReference : ISerializationCallbackReceiver
{
	private GameObject cachedReference;

	private bool isCacheSet;

	[SerializeField]
	private byte[] serializedGuid;

	private Guid guid;

	private Action<GameObject> addDelegate;

	private Action removeDelegate;

	public GameObject gameObject
	{
		get
		{
			if (isCacheSet)
			{
				return cachedReference;
			}
			cachedReference = GuidManager.ResolveGuid(guid, addDelegate, removeDelegate);
			isCacheSet = true;
			return cachedReference;
		}
		private set
		{
		}
	}

	public event Action<GameObject> OnGuidAdded = delegate
	{
	};

	public event Action OnGuidRemoved = delegate
	{
	};

	public GuidReference()
	{
	}

	public GuidReference(GuidComponent target)
	{
		guid = target.GetGuid();
	}

	private void GuidAdded(GameObject go)
	{
		cachedReference = go;
		this.OnGuidAdded(go);
	}

	private void GuidRemoved()
	{
		cachedReference = null;
		isCacheSet = false;
		this.OnGuidRemoved();
	}

	public void OnBeforeSerialize()
	{
		serializedGuid = guid.ToByteArray();
	}

	public void OnAfterDeserialize()
	{
		cachedReference = null;
		isCacheSet = false;
		if (serializedGuid == null || serializedGuid.Length != 16)
		{
			serializedGuid = new byte[16];
		}
		guid = new Guid(serializedGuid);
		addDelegate = GuidAdded;
		removeDelegate = GuidRemoved;
	}
}
