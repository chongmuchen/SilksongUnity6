namespace HutongGames.PlayMaker.Actions
{
	public class AutoEquipCrestV4 : FsmStateAction
	{
		[ObjectType(typeof(ToolCrest))]
		public FsmObject Crest;

		public FsmBool SkipToAppear;

		public FsmBool IsTemp;

		public FsmBool RemoveTools;

		public override void Reset()
		{
			Crest = null;
			SkipToAppear = null;
			IsTemp = null;
			RemoveTools = true;
		}

		public override void OnEnter()
		{
			if (SkipToAppear.Value)
			{
				BindOrbHudFrame.SkipToNextAppear = true;
			}
			ToolItemManager.AutoEquip(Crest.Value as ToolCrest, IsTemp.Value, RemoveTools.Value);
			BindOrbHudFrame.SkipToNextAppear = false;
			Finish();
		}
	}
}
