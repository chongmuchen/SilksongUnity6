using TeamCherry.SharedUtils;
using UnityEngine;

public class ActivateColliderWhenNotInside : MonoBehaviour
{
	[SerializeField]
	private Collider2D collider;

	[SerializeField]
	private bool onEnable;

	[SerializeField]
	private bool overrideLayerMask;

	[SerializeField]
	private LayerMask layerMask;

	[SerializeField]
	private MinMaxFloat activeYRange;

	private bool waitingToEnable;

	private void OnDrawGizmosSelected()
	{
		Vector3 position = base.transform.position;
		Gizmos.DrawLine(position + new Vector3(0f, activeYRange.Start, 0f), position + new Vector3(0f, activeYRange.End, 0f));
	}

	private void Awake()
	{
		if (!overrideLayerMask)
		{
			layerMask = Helper.GetCollidingLayerMaskForLayer(collider.gameObject.layer);
		}
	}

	private void OnEnable()
	{
		if (onEnable)
		{
			ActivateCollider();
		}
	}

	private void OnDisable()
	{
		if (onEnable)
		{
			DeactivateCollider();
		}
	}

	private void Update()
	{
		if (waitingToEnable && (bool)collider && !IsInsideCollider())
		{
			collider.enabled = true;
			waitingToEnable = false;
		}
	}

	[ContextMenu("Activate", true)]
	[ContextMenu("Deactivate", true)]
	private bool CanTest()
	{
		return Application.isPlaying;
	}

	[ContextMenu("Activate")]
	public void ActivateCollider()
	{
		if ((bool)collider)
		{
			if (!IsInsideCollider())
			{
				collider.enabled = true;
			}
			else
			{
				waitingToEnable = true;
			}
		}
	}

	[ContextMenu("Deactivate")]
	public void DeactivateCollider()
	{
		if ((bool)collider)
		{
			collider.enabled = false;
			waitingToEnable = false;
		}
	}

	private bool IsInsideCollider()
	{
		if (!base.isActiveAndEnabled)
		{
			return false;
		}
		BoxCollider2D boxCollider2D = collider as BoxCollider2D;
		if (boxCollider2D != null)
		{
			Collider2D collider2D = Physics2D.OverlapBox(base.transform.TransformPoint(boxCollider2D.offset), boxCollider2D.size, base.transform.rotation.z, layerMask);
			if (!collider2D)
			{
				return false;
			}
			if (Mathf.Abs(activeYRange.Start) > Mathf.Epsilon && Mathf.Abs(activeYRange.End) > Mathf.Epsilon)
			{
				Vector3 position = base.transform.position;
				Vector3 position2 = collider2D.transform.position;
				if (!new MinMaxFloat(position.y + activeYRange.Start, position.y + activeYRange.End).IsInRange(position2.y))
				{
					return false;
				}
			}
			return true;
		}
		CircleCollider2D circleCollider2D = collider as CircleCollider2D;
		if (circleCollider2D != null)
		{
			return Physics2D.OverlapCircle(base.transform.TransformPoint(circleCollider2D.offset), circleCollider2D.radius, layerMask);
		}
		return false;
	}
}
