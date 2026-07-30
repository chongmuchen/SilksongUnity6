namespace HutongGames.PlayMaker.Actions
{
	[Tooltip("Reset all edited damage hero scripts to enabled.")]
	public class ResetRecordedDamageHero : FsmStateAction
	{
		public override void Reset()
		{
		}

		public override void OnEnter()
		{
			DamageHero.ResetRecordedDamagers();
			Finish();
		}
	}
}
