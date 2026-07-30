namespace HutongGames.PlayMaker.Actions
{
	public class ClearHeroEffectsInstant : FsmStateAction
	{
		private HeroController hc;

		public override void OnEnter()
		{
			hc = HeroController.instance;
			hc.ClearEffectsInstant();
			Finish();
		}
	}
}
