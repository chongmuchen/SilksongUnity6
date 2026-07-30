using System;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Controls;

namespace HutongGames.PlayMaker.Actions
{
	[Tooltip("Reads the value of a Gamepad button. Assumes an Xbox-style gamepad with four face buttons, two triggers, two shoulder buttons, and two menu buttons.")]
	public class GamepadReadStickValue : GamepadActionBase
	{
		[ObjectType(typeof(GamepadStick))]
		[Tooltip("The Gamepad stick to test.")]
		public FsmEnum stick;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store the stick's current value.")]
		public FsmVector2 storeVector2Value;

		public override void Reset()
		{
			base.Reset();
			stick = null;
			storeVector2Value = null;
		}

		protected override void Execute()
		{
			InputControl control = GetControl();
			if (control != null)
			{
				if (control is StickControl stickControl)
				{
					storeVector2Value.Value = stickControl.ReadValue();
				}
				else if (control is DpadControl dpadControl)
				{
					storeVector2Value.Value = dpadControl.ReadValue();
				}
			}
		}

		private InputControl GetControl()
		{
			return (GamepadStick)(object)stick.Value switch
			{
				GamepadStick.LeftStick => gamepad.leftStick, 
				GamepadStick.RightStick => gamepad.rightStick, 
				GamepadStick.DPad => gamepad.dpad, 
				_ => throw new ArgumentOutOfRangeException(), 
			};
		}
	}
}
