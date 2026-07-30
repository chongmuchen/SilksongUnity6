using System.Collections.Generic;
using UnityEngine;

[DisallowMultipleComponent]
public sealed class HeroInvincibilitySource : MonoBehaviour
{
	private static readonly HashSet<Object> UNITY_SOURCES = new HashSet<Object>();

	private static readonly HashSet<object> MANAGED_SOURCES = new HashSet<object>();

	[SerializeField]
	private bool addOnEnable;

	private bool started;

	private bool added;

	public static int Count => UNITY_SOURCES.Count + MANAGED_SOURCES.Count;

	public static bool IsActive
	{
		get
		{
			foreach (object mANAGED_SOURCE in MANAGED_SOURCES)
			{
				if (mANAGED_SOURCE != null)
				{
					return true;
				}
			}
			foreach (Object uNITY_SOURCE in UNITY_SOURCES)
			{
				if (!(uNITY_SOURCE == null))
				{
					return true;
				}
			}
			return false;
		}
	}

	[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
	private static void ResetStatics()
	{
		UNITY_SOURCES.Clear();
		MANAGED_SOURCES.Clear();
	}

	private void Start()
	{
		started = true;
		if (addOnEnable)
		{
			Add();
		}
	}

	private void OnEnable()
	{
		if (started && addOnEnable)
		{
			Add();
		}
	}

	private void OnDisable()
	{
		Remove();
	}

	private void OnDestroy()
	{
		Remove();
	}

	public void Add()
	{
		if (!added)
		{
			added = true;
			Add(this);
		}
	}

	public void Remove()
	{
		if (added)
		{
			added = false;
			Remove(this);
		}
	}

	public void SetInvincible(bool invincible)
	{
		if (invincible)
		{
			Add();
		}
		else
		{
			Remove();
		}
	}

	public static void Add(Object src)
	{
		PurgeStaleUnity();
		if (!(src == null))
		{
			UNITY_SOURCES.Add(src);
		}
	}

	public static void Add(object src)
	{
		if (src is Object src2)
		{
			Add(src2);
		}
		else if (src != null)
		{
			MANAGED_SOURCES.Add(src);
		}
	}

	public static bool Remove(Object src)
	{
		return UNITY_SOURCES.Remove(src);
	}

	public static bool Remove(object src)
	{
		if (src is Object src2)
		{
			return Remove(src2);
		}
		if (src == null)
		{
			return false;
		}
		return MANAGED_SOURCES.Remove(src);
	}

	public static void Clear()
	{
		MANAGED_SOURCES.Clear();
		UNITY_SOURCES.Clear();
	}

	private static void PurgeStaleUnity()
	{
		UNITY_SOURCES.RemoveWhere((Object u) => u == null);
	}
}
