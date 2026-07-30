namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("PlayerInput")]
	[Tooltip("Sends an Event when an InputAction in a PlayerInput component is Triggered.")]
	public class PlayerInputTriggeredEvent : PlayerInputActionBase
	{
		[Tooltip("The event to send on Input Triggered.")]
		public FsmEvent sendEvent;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store the input value.")]
		public FsmBool storeValue;

		public override void Reset()
		{
			base.Reset();
			sendEvent = null;
			storeValue = null;
		}

		public override void OnUpdate()
		{
			base.OnUpdate();
			if (m_inputAction != null)
			{
				storeValue.Value = m_inputAction.triggered;
				if (m_inputAction.triggered)
				{
					base.Fsm.Event(sendEvent);
				}
			}
		}
	}
}
