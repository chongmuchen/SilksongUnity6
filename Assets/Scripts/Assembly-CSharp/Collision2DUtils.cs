using UnityEngine;

public static class Collision2DUtils
{
	public struct Collision2DSafeContact
	{
		public Vector2 Point;

		public Vector2 Normal;

		public bool IsLegitimate;
	}

	private static ContactPoint2D[] contactsBuffer = new ContactPoint2D[1];

	public static Collision2DSafeContact GetSafeContact(this Collision2D collision)
	{
		if (collision.GetContacts(contactsBuffer) >= 1)
		{
			ContactPoint2D contactPoint2D = contactsBuffer[0];
			return new Collision2DSafeContact
			{
				Point = contactPoint2D.point,
				Normal = contactPoint2D.normal,
				IsLegitimate = true
			};
		}
		Vector2 vector = collision.collider.transform.TransformPoint(collision.collider.offset);
		Vector2 vector2 = collision.otherCollider.transform.TransformPoint(collision.otherCollider.offset);
		return new Collision2DSafeContact
		{
			Point = (vector2 + vector) * 0.5f,
			Normal = (vector2 - vector).normalized,
			IsLegitimate = false
		};
	}
}
