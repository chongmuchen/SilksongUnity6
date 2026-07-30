namespace HutongGames.PlayMaker.Actions
{
	public class DetachDynamicHierarchy : FsmStateAction
	{
		[RequiredField]
		[CheckForComponent(typeof(ResetDynamicHierarchy))]
		public FsmOwnerDefault Target;

		public FsmOwnerDefault DetachTarget;

		public FsmBool Recursive;

		public override void Reset()
		{
			Target = null;
			DetachTarget = null;
			Recursive = false;
		}

		public override void OnEnter()
		{
			ResetDynamicHierarchy safe = Target.GetSafe<ResetDynamicHierarchy>(this);
			if (safe != null)
			{
				safe.Disconnect(DetachTarget.GetSafe(this), Recursive.Value);
			}
			Finish();
		}
	}
}
