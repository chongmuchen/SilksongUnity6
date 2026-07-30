using System;
using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("PlayerInput")]
	[Tooltip("Get the Vector2 value from a named InputAction in a PlayerInput component and store it in a Vector3 variable.")]
	public class PlayerInputGetVector2AsVector3 : PlayerInputUpdateActionBase
	{
		public enum Mapping
		{
			XZ = 0,
			XY = 1,
			YZ = 2
		}

		[Tooltip("Plane to map the 2d input to.")]
		public Mapping mapping;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store the Vector3 value.")]
		public FsmVector3 storeVector3;

		public override void Reset()
		{
			base.Reset();
			mapping = Mapping.XZ;
			storeVector3 = null;
		}

		protected override void Execute()
		{
			if (action != null)
			{
				Vector2 vector = action.ReadValue<Vector2>();
				switch (mapping)
				{
				case Mapping.XZ:
					storeVector3.Value = new Vector3(vector.x, 0f, vector.y);
					break;
				case Mapping.XY:
					storeVector3.Value = new Vector3(vector.x, vector.y, 0f);
					break;
				case Mapping.YZ:
					storeVector3.Value = new Vector3(0f, vector.y, vector.x);
					break;
				default:
					throw new ArgumentOutOfRangeException();
				}
			}
		}
	}
}
