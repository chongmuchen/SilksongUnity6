namespace HutongGames.PlayMaker.Actions
{
	public sealed class SetHeroStunned : FsmStateAction
	{
		public FsmBool stunned;

		public FsmBool resetOnExit;

		private HeroController hc;

		public override void Reset()
		{
			stunned = null;
			resetOnExit = null;
		}

		public override void OnEnter()
		{
			hc = HeroController.instance;
			if (hc != null)
			{
				hc.IsStunned = stunned.Value;
			}
		}

		public override void OnExit()
		{
			if (resetOnExit.Value && hc != null)
			{
				hc.IsStunned = false;
			}
			hc = null;
		}
	}
}
