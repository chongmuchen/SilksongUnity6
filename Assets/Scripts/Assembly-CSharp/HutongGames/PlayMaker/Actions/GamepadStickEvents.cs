using System;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Controls;

namespace HutongGames.PlayMaker.Actions
{
	[Tooltip("Checks a Gamepad stick and translates its offset into events. Assumes an Xbox-style gamepad with four face buttons, two triggers, two shoulder buttons, and two menu buttons.")]
	public class GamepadStickEvents : GamepadActionBase
	{
		public enum Stick
		{
			LeftStick = 0,
			RightStick = 1,
			DPad = 2
		}

		[ObjectType(typeof(Stick))]
		[Tooltip("The Gamepad stick to test.")]
		public FsmEnum stick;

		[Tooltip("Event to send if input is to the left.")]
		public FsmEvent leftEvent;

		[Tooltip("Event to send if input is to the right.")]
		public FsmEvent rightEvent;

		[Tooltip("Event to send if input is to the up.")]
		public FsmEvent upEvent;

		[Tooltip("Event to send if input is to the down.")]
		public FsmEvent downEvent;

		[Tooltip("Event to send if input is in any direction.")]
		public FsmEvent anyDirection;

		[Tooltip("Event to send if no axis input (centered).")]
		public FsmEvent noDirection;

		public override void Reset()
		{
			base.Reset();
			stick = null;
			leftEvent = null;
			rightEvent = null;
			upEvent = null;
			downEvent = null;
			anyDirection = null;
			noDirection = null;
		}

		protected override void Execute()
		{
			InputControl control = GetControl();
			if (control == null)
			{
				return;
			}
			Vector2 vector = Vector2.zero;
			if (control is StickControl stickControl)
			{
				vector = stickControl.ReadValue();
			}
			if (control is DpadControl dpadControl)
			{
				vector = dpadControl.ReadValue();
			}
			if (vector.sqrMagnitude.Equals(0f))
			{
				if (noDirection != null)
				{
					base.Fsm.Event(noDirection);
				}
				return;
			}
			float num = Mathf.Atan2(vector.y, vector.x) * 57.29578f + 45f;
			if (num < 0f)
			{
				num += 360f;
			}
			int num2 = (int)(num / 90f);
			if (num2 == 0 && rightEvent != null)
			{
				base.Fsm.Event(rightEvent);
			}
			else if (num2 == 1 && upEvent != null)
			{
				base.Fsm.Event(upEvent);
			}
			else if (num2 == 2 && leftEvent != null)
			{
				base.Fsm.Event(leftEvent);
			}
			else if (num2 == 3 && downEvent != null)
			{
				base.Fsm.Event(downEvent);
			}
			else if (anyDirection != null)
			{
				base.Fsm.Event(anyDirection);
			}
		}

		private InputControl GetControl()
		{
			return (Stick)(object)stick.Value switch
			{
				Stick.LeftStick => gamepad.leftStick, 
				Stick.RightStick => gamepad.rightStick, 
				Stick.DPad => gamepad.dpad, 
				_ => throw new ArgumentOutOfRangeException(), 
			};
		}
	}
}
