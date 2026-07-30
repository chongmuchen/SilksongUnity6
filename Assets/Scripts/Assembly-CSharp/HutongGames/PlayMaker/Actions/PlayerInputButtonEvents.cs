namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("PlayerInput")]
	[Note("Make sure the Button is setup with the Press and Release Interaction to trigger Pressed and Released events.")]
	[Tooltip("Sends Events based InputAction buttons in a PlayerInput component.")]
	public class PlayerInputButtonEvents : PlayerInputUpdateActionBase
	{
		[UIHint(UIHint.Variable)]
		[Tooltip("Store if the button is pressed.")]
		public FsmBool isPressed;

		[Tooltip("Event to send if the button is pressed.")]
		public FsmEvent isPressedEvent;

		[Tooltip("Event to send if the button was pressed this frame.")]
		public FsmEvent wasPressedThisFrame;

		[Tooltip("Event to send if the button was released this frame.")]
		public FsmEvent wasReleasedThisFrame;

		public override void Reset()
		{
			base.Reset();
			isPressed = null;
			isPressedEvent = null;
			wasPressedThisFrame = null;
			wasReleasedThisFrame = null;
		}

		protected override void Execute()
		{
			if (action != null)
			{
				bool flag = action.ReadValue<float>() > 0f;
				isPressed.Value = flag;
				if (isPressedEvent != null && flag)
				{
					base.Fsm.Event(isPressedEvent);
				}
				if (wasPressedThisFrame != null && action.triggered && flag)
				{
					base.Fsm.Event(wasPressedThisFrame);
				}
				if (wasReleasedThisFrame != null && action.triggered && !flag)
				{
					base.Fsm.Event(wasReleasedThisFrame);
				}
			}
		}
	}
}
