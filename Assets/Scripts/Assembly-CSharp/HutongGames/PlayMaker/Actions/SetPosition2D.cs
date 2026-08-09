using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	/// <summary>
	/// Compatibility action for FSMs serialized with the legacy, capital-D type name.
	/// New FSMs should use PlayMaker's SetPosition2d action.
	/// </summary>
	[ActionCategory(ActionCategory.Transform)]
	public class SetPosition2D : FsmStateAction
	{
		[RequiredField]
		public FsmOwnerDefault GameObject;

		public FsmVector2 Vector;

		[HideIf("UsingVector")]
		public FsmFloat X;

		[HideIf("UsingVector")]
		public FsmFloat Y;

		public Space Space;

		public bool EveryFrame;

		public bool UsingVector()
		{
			return !Vector.IsNone;
		}

		public override void Reset()
		{
			GameObject = null;
			Vector = new FsmVector2 { UseVariable = true };
			X = null;
			Y = null;
			Space = Space.World;
			EveryFrame = false;
		}

		public override void OnEnter()
		{
			DoSetPosition();
			if (!EveryFrame)
			{
				Finish();
			}
		}

		public override void OnUpdate()
		{
			DoSetPosition();
		}

		private void DoSetPosition()
		{
			UnityEngine.GameObject target = Fsm.GetOwnerDefaultTarget(GameObject);
			if (target == null)
			{
				return;
			}

			Vector3 currentPosition = Space == Space.World
				? target.transform.position
				: target.transform.localPosition;
			Vector2 position = UsingVector()
				? Vector.Value
				: new Vector2(X.IsNone ? currentPosition.x : X.Value, Y.IsNone ? currentPosition.y : Y.Value);

			currentPosition.x = position.x;
			currentPosition.y = position.y;
			if (Space == Space.World)
			{
				target.transform.position = currentPosition;
			}
			else
			{
				target.transform.localPosition = currentPosition;
			}
		}
	}
}
