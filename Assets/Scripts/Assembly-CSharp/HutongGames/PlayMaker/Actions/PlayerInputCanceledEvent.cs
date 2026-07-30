using UnityEngine.InputSystem;

namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("PlayerInput")]
	[Tooltip("Sends an Event when an InputAction in a PlayerInput component is Canceled.")]
	public class PlayerInputCanceledEvent : PlayerInputActionBase
	{
		[Tooltip("The event to send on Input Canceled")]
		public FsmEvent sendEvent;

		public override void Reset()
		{
			base.Reset();
			sendEvent = null;
		}

		protected override void OnCanceled(InputAction.CallbackContext ctx)
		{
			base.Fsm.Event(sendEvent);
		}
	}
}
