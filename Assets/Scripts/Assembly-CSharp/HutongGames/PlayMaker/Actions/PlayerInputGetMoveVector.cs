using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("PlayerInput")]
	[Tooltip("Gets a world direction Vector from an InputAction in a PlayerInput component. Typically used for a third person controller with Relative To set to the camera. This works like the Get Axis Vector action for the old Input System.")]
	public class PlayerInputGetMoveVector : PlayerInputUpdateActionBase
	{
		public enum AxisPlane
		{
			XZ = 0,
			XY = 1,
			YZ = 2
		}

		[RequiredField]
		[Tooltip("Sets the world axis the input maps to. The remaining axis will be set to zero.")]
		public AxisPlane mapToPlane;

		[Tooltip("Calculate a vector relative to this game object. Typically the camera.")]
		public FsmGameObject relativeTo;

		[Tooltip("Normally axis values are in the range -1 to 1. Use the multiplier to make this range bigger. \nE.g., A multiplier of 100 returns values from -100 to 100.\nTypically this represents the maximum movement speed.")]
		public FsmFloat multiplier;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store the magnitude of the vector. Useful if you want to measure the strength of the input and react accordingly. Hint: Use {{Float Compare}}.")]
		public FsmFloat storeMagnitude;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store the move vector in a Vector3 variable.")]
		public FsmVector3 storeMoveVector;

		public override void Reset()
		{
			base.Reset();
			multiplier = 1f;
			mapToPlane = AxisPlane.XZ;
			relativeTo = null;
			storeMagnitude = null;
			storeMoveVector = null;
		}

		protected override void Execute()
		{
			if (action == null)
			{
				return;
			}
			Vector2 vector = action.ReadValue<Vector2>();
			Vector3 vector2 = default(Vector3);
			Vector3 vector3 = default(Vector3);
			if (relativeTo.Value == null)
			{
				switch (mapToPlane)
				{
				case AxisPlane.XZ:
					vector2 = Vector3.forward;
					vector3 = Vector3.right;
					break;
				case AxisPlane.XY:
					vector2 = Vector3.up;
					vector3 = Vector3.right;
					break;
				case AxisPlane.YZ:
					vector2 = Vector3.up;
					vector3 = Vector3.forward;
					break;
				}
			}
			else
			{
				Transform transform = relativeTo.Value.transform;
				switch (mapToPlane)
				{
				case AxisPlane.XZ:
					vector2 = transform.TransformDirection(Vector3.forward);
					vector2.y = 0f;
					vector2 = vector2.normalized;
					vector3 = new Vector3(vector2.z, 0f, 0f - vector2.x);
					break;
				case AxisPlane.XY:
				case AxisPlane.YZ:
					vector2 = Vector3.up;
					vector2.z = 0f;
					vector2 = vector2.normalized;
					vector3 = transform.TransformDirection(Vector3.right);
					break;
				}
			}
			Vector3 value = vector.x * vector3 + vector.y * vector2;
			value *= multiplier.Value;
			storeMoveVector.Value = value;
			if (!storeMagnitude.IsNone)
			{
				storeMagnitude.Value = value.magnitude;
			}
		}
	}
}
