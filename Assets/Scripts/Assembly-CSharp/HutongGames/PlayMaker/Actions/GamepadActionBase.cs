using System;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Controls;

namespace HutongGames.PlayMaker.Actions
{
	[NoActionTargets]
	[ActionCategory("Gamepad")]
	[SeeAlso("New Unity Input Manager")]
	public abstract class GamepadActionBase : FsmStateAction
	{
		public enum UpdateMode
		{
			Once = 0,
			Update = 1,
			FixedUpdate = 2
		}

		public const string XboxGamepad = "Assumes an Xbox-style gamepad with four face buttons, two triggers, two shoulder buttons, and two menu buttons.";

		[Tooltip("When to read the Input.")]
		public UpdateMode updateMode;

		protected Gamepad gamepad;

		public override void Reset()
		{
			updateMode = UpdateMode.Update;
		}

		public override void OnPreprocess()
		{
			base.Fsm.HandleFixedUpdate = updateMode == UpdateMode.FixedUpdate;
		}

		public override void OnEnter()
		{
			DoAction();
			if (updateMode == UpdateMode.Once)
			{
				Finish();
			}
		}

		public override void OnUpdate()
		{
			if (updateMode == UpdateMode.Update)
			{
				DoAction();
			}
		}

		public override void OnFixedUpdate()
		{
			if (updateMode == UpdateMode.FixedUpdate)
			{
				DoAction();
			}
		}

		private void DoAction()
		{
			gamepad = Gamepad.current;
			if (gamepad != null)
			{
				Execute();
			}
		}

		protected virtual void Execute()
		{
		}

		protected ButtonControl GetButtonControl(GamepadButton button)
		{
			return button switch
			{
				GamepadButton.ButtonNorth => gamepad.buttonNorth, 
				GamepadButton.ButtonEast => gamepad.buttonEast, 
				GamepadButton.ButtonWest => gamepad.buttonWest, 
				GamepadButton.ButtonSouth => gamepad.buttonSouth, 
				GamepadButton.LeftTrigger => gamepad.leftTrigger, 
				GamepadButton.RightTrigger => gamepad.rightTrigger, 
				GamepadButton.LeftShoulder => gamepad.leftShoulder, 
				GamepadButton.RightShoulder => gamepad.rightShoulder, 
				GamepadButton.SelectButton => gamepad.selectButton, 
				GamepadButton.StartButton => gamepad.startButton, 
				_ => throw new ArgumentOutOfRangeException(), 
			};
		}
	}
}
