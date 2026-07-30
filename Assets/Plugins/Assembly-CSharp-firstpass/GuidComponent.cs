using System;
using UnityEngine;

[ExecuteInEditMode]
[DisallowMultipleComponent]
public class GuidComponent : MonoBehaviour, ISerializationCallbackReceiver
{
	private Guid guid = Guid.Empty;

	[SerializeField]
	private byte[] serializedGuid;

	public bool IsGuidAssigned()
	{
		return guid != Guid.Empty;
	}

	private void CreateGuid()
	{
		if (serializedGuid == null || serializedGuid.Length != 16)
		{
			guid = Guid.NewGuid();
			serializedGuid = guid.ToByteArray();
		}
		else if (guid == Guid.Empty)
		{
			guid = new Guid(serializedGuid);
		}
		if (guid != Guid.Empty && !GuidManager.Add(this))
		{
			serializedGuid = null;
			guid = Guid.Empty;
			CreateGuid();
		}
	}

	public void OnBeforeSerialize()
	{
		if (guid != Guid.Empty)
		{
			serializedGuid = guid.ToByteArray();
		}
	}

	public void OnAfterDeserialize()
	{
		if (serializedGuid != null && serializedGuid.Length == 16)
		{
			guid = new Guid(serializedGuid);
		}
	}

	private void Awake()
	{
		CreateGuid();
	}

	private void OnValidate()
	{
		CreateGuid();
	}

	public Guid GetGuid()
	{
		if (guid == Guid.Empty && serializedGuid != null && serializedGuid.Length == 16)
		{
			guid = new Guid(serializedGuid);
		}
		return guid;
	}

	public void OnDestroy()
	{
		GuidManager.Remove(guid);
	}
}
