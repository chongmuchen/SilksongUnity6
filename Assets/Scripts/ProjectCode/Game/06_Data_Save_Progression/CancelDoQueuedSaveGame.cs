using HutongGames.PlayMaker;

public class CancelDoQueuedSaveGame : FsmStateAction
{
	public override void OnEnter()
	{
		GameManager unsafeInstance = GameManager.UnsafeInstance;
		if ((bool)unsafeInstance)
		{
			unsafeInstance.CancelDoQueuedSaveGame();
		}
		Finish();
	}
}
