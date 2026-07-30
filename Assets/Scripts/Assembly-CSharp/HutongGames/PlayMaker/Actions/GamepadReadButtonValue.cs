using UnityEngine.InputSystem.Controls;

namespace HutongGames.PlayMaker.Actions
{
	[Tooltip("Reads the value of a Gamepad button. Assumes an Xbox-style gamepad with four face buttons, two triggers, two shoulder buttons, and two menu buttons.")]
	public class GamepadReadButtonValue : GamepadActionBase
	{
		[ObjectType(typeof(GamepadButton))]
		[Tooltip("The Gamepad button to test.")]
		public FsmEnum button;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store button's current value.")]
		public FsmFloat storeFloatValue;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store if the button is pressed. This is true if its current value is greater than a predetermined threshold.")]
		public FsmBool isPressed;

		public override void Reset()
		{
			base.Reset();
			button = null;
			storeFloatValue = null;
		}

		protected override void Execute()
		{
			ButtonControl buttonControl = GetButtonControl((GamepadButton)(object)button.Value);
			if (buttonControl != null)
			{
				storeFloatValue.Value = buttonControl.ReadValue();
				isPressed.Value = buttonControl.isPressed;
			}
		}

		public override void OnEnter()
		{
			LogWarning("Action requires new Input System!");
			Finish();
		}
	}
}
