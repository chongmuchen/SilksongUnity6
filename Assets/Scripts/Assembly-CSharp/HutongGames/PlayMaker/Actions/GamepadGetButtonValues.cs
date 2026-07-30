using UnityEngine;
using UnityEngine.InputSystem.Controls;

namespace HutongGames.PlayMaker.Actions
{
	[Tooltip("Get values from a Gamepad button. Assumes an Xbox-style gamepad with four face buttons, two triggers, two shoulder buttons, and two menu buttons.")]
	public class GamepadGetButtonValues : GamepadActionBase
	{
		[ObjectType(typeof(GamepadButton))]
		[Tooltip("The Gamepad button to test.")]
		public FsmEnum button;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store button's current value.")]
		public FsmFloat currentValue;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store if the button is pressed. This is true if its current value is greater than a predetermined threshold.")]
		public FsmBool isPressed;

		[UIHint(UIHint.Variable)]
		[Tooltip("Stores how long the button has been pressed. Resets to zero when released.")]
		public FsmFloat heldTime;

		[UIHint(UIHint.Variable)]
		[Tooltip("Stores how many times the button has been pressed while this State was active. Useful for 'double-click' buttons.")]
		public FsmInt pressedCount;

		private float pressedStartTime;

		public override void Reset()
		{
			base.Reset();
			button = null;
			currentValue = null;
		}

		public override void OnEnter()
		{
			pressedCount.Value = 0;
			heldTime.Value = 0f;
			base.OnEnter();
		}

		protected override void Execute()
		{
			ButtonControl buttonControl = GetButtonControl((GamepadButton)(object)button.Value);
			if (buttonControl != null)
			{
				currentValue.Value = buttonControl.ReadValue();
				if (buttonControl.wasPressedThisFrame)
				{
					pressedStartTime = Time.time;
					pressedCount.Value++;
				}
				bool flag = buttonControl.isPressed;
				isPressed.Value = flag;
				if (flag)
				{
					heldTime.Value += Time.time - pressedStartTime;
				}
				else
				{
					heldTime.Value = 0f;
				}
			}
		}
	}
}
