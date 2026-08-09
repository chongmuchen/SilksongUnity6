using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	/// <summary>
	/// Compatibility action for FSMs serialized with the legacy, capital-D type name.
	/// New FSMs should use PlayMaker's GetPosition2d action.
	/// </summary>
	[ActionCategory(ActionCategory.Transform)]
	[Tooltip("Gets the 2D Position of a Game Object and stores it in a Vector2 Variable or each Axis in a Float Variable")]
	public class GetPosition2D : FsmStateAction
	{
		[RequiredField]
		public FsmOwnerDefault gameObject;

		[UIHint(UIHint.Variable)]
		public FsmVector2 vector;

		[UIHint(UIHint.Variable)]
		public FsmFloat x;

		[UIHint(UIHint.Variable)]
		public FsmFloat y;

		public Space space;

		public bool everyFrame;

		public override void Reset()
		{
			gameObject = null;
			vector = null;
			x = null;
			y = null;
			space = Space.World;
			everyFrame = false;
		}

		public override void OnEnter()
		{
			DoGetPosition();
			if (!everyFrame)
			{
				Finish();
			}
		}

		public override void OnUpdate()
		{
			DoGetPosition();
		}

		private void DoGetPosition()
		{
			GameObject target = Fsm.GetOwnerDefaultTarget(gameObject);
			if (target == null)
			{
				return;
			}

			Vector3 position = space == Space.World
				? target.transform.position
				: target.transform.localPosition;
			vector.Value = position;
			x.Value = position.x;
			y.Value = position.y;
		}
	}
}
