namespace HutongGames.PlayMaker.Actions
{
	public class GetIsHeroInputBlocked : FSMUtility.CheckFsmStateEveryFrameAction
	{
		public override bool IsTrue => HeroController.instance.IsInputBlocked();
	}
}
