using System.Collections.Generic;
using UnityEngine;

public class SurfaceWaterFloat : MonoBehaviour
{
	[SerializeField]
	private float waterLevel;

	[SerializeField]
	private float bounceDamp;

	private readonly List<SurfaceWaterFloater> floaters = new List<SurfaceWaterFloater>();

	private SurfaceWaterRegion parentRegion;

	private void OnDrawGizmosSelected()
	{
		Vector3 position = base.transform.position;
		position.y += waterLevel;
		Gizmos.DrawWireSphere(position, 0.2f);
	}

	private void Awake()
	{
		parentRegion = GetComponentInParent<SurfaceWaterRegion>();
	}

	private void OnTriggerEnter2D(Collider2D collision)
	{
		SurfaceWaterFloater component = collision.GetComponent<SurfaceWaterFloater>();
		if ((bool)component && floaters.AddIfNotPresent(component))
		{
			component.SetInWater(value: true);
		}
	}

	private void OnTriggerExit2D(Collider2D collision)
	{
		SurfaceWaterFloater component = collision.GetComponent<SurfaceWaterFloater>();
		if ((bool)component && floaters.Remove(component))
		{
			component.SetInWater(value: false);
		}
	}

	private void FixedUpdate()
	{
		Transform obj = base.transform;
		float num = obj.position.y + waterLevel;
		Quaternion rotation = obj.rotation;
		float flowSpeed = parentRegion.FlowSpeed;
		bool flag = Mathf.Abs(flowSpeed) > 0.001f && Mathf.Abs(rotation.eulerAngles.z) > 1f;
		for (int num2 = floaters.Count - 1; num2 >= 0; num2--)
		{
			SurfaceWaterFloater surfaceWaterFloater = floaters[num2];
			float floatMultiplier = surfaceWaterFloater.FloatMultiplier;
			if (!(floatMultiplier <= Mathf.Epsilon))
			{
				if (flag)
				{
					surfaceWaterFloater.MoveWithSurface(flowSpeed, rotation);
				}
				else
				{
					float num3 = num + surfaceWaterFloater.SurfaceOffset;
					float num4 = 1f - (((Vector2)surfaceWaterFloater.transform.position).y - num3) / surfaceWaterFloater.FloatCushion;
					if (num4 > 0f)
					{
						float num5 = (0f - Physics2D.gravity.y) * surfaceWaterFloater.GravityScale * (num4 - surfaceWaterFloater.Velocity * bounceDamp);
						num5 *= floatMultiplier;
						surfaceWaterFloater.AddForce(num5);
						surfaceWaterFloater.AddFlowSpeed(flowSpeed, rotation);
					}
					surfaceWaterFloater.Dampen();
				}
			}
		}
	}
}
