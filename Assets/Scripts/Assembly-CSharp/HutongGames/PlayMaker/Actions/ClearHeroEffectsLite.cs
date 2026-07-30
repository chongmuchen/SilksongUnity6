namespace HutongGames.PlayMaker.Actions
{
	public class ClearHeroEffectsLite : FsmStateAction
	{
		private HeroController hc;

		public override void OnEnter()
		{
			hc = HeroController.instance;
			hc.ClearEffectsLite();
			Finish();
		}
	}
}
