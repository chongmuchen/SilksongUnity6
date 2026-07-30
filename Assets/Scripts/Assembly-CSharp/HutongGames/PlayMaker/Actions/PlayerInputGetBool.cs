namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("PlayerInput")]
	[Tooltip("Get the Bool value from an InputAction in a PlayerInput component.")]
	public class PlayerInputGetBool : PlayerInputUpdateActionBase
	{
		[UIHint(UIHint.Variable)]
		[Tooltip("Store the Input Bool value.")]
		public FsmBool storeBool;

		public override void Reset()
		{
			base.Reset();
			storeBool = null;
		}

		protected override void Execute()
		{
			if (action != null)
			{
				storeBool.Value = action.ReadValue<bool>();
			}
		}
	}
}
