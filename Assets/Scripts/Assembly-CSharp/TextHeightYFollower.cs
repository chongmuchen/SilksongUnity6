using System;
using System.Collections.Generic;
using TeamCherry.SharedUtils;
using UnityEngine;

[ExecuteAlways]
[DisallowMultipleComponent]
public sealed class TextHeightYFollower : MonoBehaviour
{
	private const float DefaultGizmoExtent = 1.5f;

	[Header("Sources")]
	[Tooltip("Text containers whose height changes will drive this object's Y position.")]
	[SerializeField]
	private List<TextMeshProContainerFitter> containers = new List<TextMeshProContainerFitter>();

	[Header("Positioning")]
	[Tooltip("Additional offset from the computed BOTTOM edge (Top of source - reported height). Positive pushes the follower downward.")]
	[SerializeField]
	private float extraYOffset;

	[Header("Local Y Clamp")]
	[Tooltip("If enabled, localPosition.y will not exceed this value.")]
	[SerializeField]
	private OverrideFloat maxLocalY;

	[Tooltip("If enabled, localPosition.y will not go below this value.")]
	[SerializeField]
	private OverrideFloat minLocalY;

	[Header("Gizmos")]
	[Tooltip("Draw gizmos to visualize min/max local Y if they are enabled.")]
	[SerializeField]
	private bool drawGizmos = true;

	[Tooltip("Half-width of the gizmo line drawn at min/max local Y (in world units).")]
	[Min(0f)]
	[SerializeField]
	private float gizmoHalfExtent = 1.5f;

	private readonly Dictionary<TextMeshProContainerFitter, Action<float>> subscriptions = new Dictionary<TextMeshProContainerFitter, Action<float>>();

	private Transform cachedTransform;

	private Transform CachedTransform
	{
		get
		{
			if (cachedTransform == null)
			{
				cachedTransform = base.transform;
			}
			return cachedTransform;
		}
	}

	private void OnEnable()
	{
		cachedTransform = base.transform;
		SubscribeAll();
		RecomputeFromFirstActiveContainer();
	}

	private void OnDisable()
	{
		UnsubscribeAll();
	}

	private void OnValidate()
	{
		cachedTransform = base.transform;
		if (base.isActiveAndEnabled)
		{
			UnsubscribeAll();
			SubscribeAll();
			RecomputeFromFirstActiveContainer();
		}
		if (gizmoHalfExtent < 0f)
		{
			gizmoHalfExtent = 0f;
		}
	}

	[ContextMenu("Reposition Now")]
	public void RecomputeFromFirstActiveContainer()
	{
		foreach (TextMeshProContainerFitter container in containers)
		{
			if (container != null && container.gameObject.activeInHierarchy)
			{
				ApplyPositionFrom(container, 0f);
				break;
			}
		}
	}

	private void SubscribeAll()
	{
		if (containers == null)
		{
			return;
		}
		foreach (TextMeshProContainerFitter container in containers)
		{
			Subscribe(container);
		}
	}

	private void UnsubscribeAll()
	{
		foreach (KeyValuePair<TextMeshProContainerFitter, Action<float>> subscription in subscriptions)
		{
			TextMeshProContainerFitter key = subscription.Key;
			Action<float> value = subscription.Value;
			if (key != null)
			{
				key.OnHeightUpdated = (Action<float>)Delegate.Remove(key.OnHeightUpdated, value);
			}
		}
		subscriptions.Clear();
	}

	private void Subscribe(TextMeshProContainerFitter container)
	{
		if (!(container == null) && !subscriptions.ContainsKey(container))
		{
			subscriptions[container] = Handler;
			TextMeshProContainerFitter textMeshProContainerFitter = container;
			textMeshProContainerFitter.OnHeightUpdated = (Action<float>)Delegate.Combine(textMeshProContainerFitter.OnHeightUpdated, new Action<float>(Handler));
		}
		void Handler(float height)
		{
			if (!(container == null) && container.gameObject.activeInHierarchy)
			{
				ApplyPositionFrom(container, height);
			}
		}
	}

	private void ApplyPositionFrom(TextMeshProContainerFitter source, float height)
	{
		if (!(source == null))
		{
			ApplyPositionFrom(source.transform, height);
		}
	}

	private void ApplyPositionFrom(Transform sourceTransform, float height)
	{
		Transform obj = CachedTransform;
		float y = GetTopWorldY(sourceTransform) - height + extraYOffset;
		Vector3 position = obj.position;
		position = new Vector3(position.x, y, position.z);
		obj.position = position;
		Vector3 localPosition = obj.localPosition;
		if (maxLocalY.IsEnabled)
		{
			localPosition.y = Mathf.Min(localPosition.y, maxLocalY.Value);
		}
		if (minLocalY.IsEnabled)
		{
			localPosition.y = Mathf.Max(localPosition.y, minLocalY.Value);
		}
		obj.localPosition = localPosition;
	}

	private static float GetTopWorldY(Transform sourceTransform)
	{
		RectTransform rectTransform = sourceTransform as RectTransform;
		if (rectTransform != null)
		{
			Vector3[] array = new Vector3[4];
			rectTransform.GetWorldCorners(array);
			return Mathf.Max(array[1].y, array[2].y);
		}
		return sourceTransform.position.y;
	}
}
