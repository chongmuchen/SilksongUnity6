using UnityEngine.InputSystem.Controls;

namespace HutongGames.PlayMaker.Actions
{
	[Tooltip("Checks Gamepad buttons. Assumes an Xbox-style gamepad with four face buttons, two triggers, two shoulder buttons, and two menu buttons.")]
	public class GamepadButtonEvents : GamepadActionBase
	{
		[ObjectType(typeof(GamepadButton))]
		[Tooltip("The Gamepad button to test.")]
		public FsmEnum button;

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
			button = GamepadButton.ButtonEast;
			isPressed = null;
			isPressedEvent = null;
			wasPressedThisFrame = null;
			wasReleasedThisFrame = null;
		}

		protected override void Execute()
		{
			ButtonControl buttonControl = GetButtonControl((GamepadButton)(object)button.Value);
			isPressed.Value = buttonControl.isPressed;
			if (isPressedEvent != null && buttonControl.isPressed)
			{
				base.Fsm.Event(isPressedEvent);
			}
			if (wasPressedThisFrame != null && buttonControl.wasPressedThisFrame)
			{
				base.Fsm.Event(wasPressedThisFrame);
			}
			if (wasReleasedThisFrame != null && buttonControl.wasReleasedThisFrame)
			{
				base.Fsm.Event(wasReleasedThisFrame);
			}
		}
	}
}
