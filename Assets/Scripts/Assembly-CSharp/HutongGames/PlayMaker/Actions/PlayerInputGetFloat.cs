namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("PlayerInput")]
	[Tooltip("Get the float value from an InputAction in a PlayerInput component.")]
	public class PlayerInputGetFloat : PlayerInputUpdateActionBase
	{
		[UIHint(UIHint.Variable)]
		[Tooltip("Store the Input Float value.")]
		public FsmFloat storeFloat;

		public override void Reset()
		{
			base.Reset();
			storeFloat = null;
		}

		protected override void Execute()
		{
			if (action != null)
			{
				storeFloat.Value = action.ReadValue<float>();
			}
		}
	}
}
