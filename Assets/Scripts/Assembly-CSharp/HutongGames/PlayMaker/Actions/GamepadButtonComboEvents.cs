using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Controls;

namespace HutongGames.PlayMaker.Actions
{
	[Tooltip("Checks Gamepad buttons for combos. Combos are either buttons pressed at the same time or pressed in a specific sequence. Assumes an Xbox-style gamepad with four face buttons, two triggers, two shoulder buttons, and two menu buttons.")]
	public class GamepadButtonComboEvents : GamepadActionBase
	{
		public enum Combo
		{
			SameTime = 0,
			Sequence = 1
		}

		[ObjectType(typeof(Combo))]
		[Tooltip("The type of combo to detect.")]
		public FsmEnum combo;

		[ArrayEditor(typeof(GamepadButton), "Button", 0, 0, 65536)]
		[Tooltip("The Gamepad button to test.")]
		public FsmArray buttons;

		[Tooltip("Time allowed for the next button press. Generally shorter for Same Time combos and longer for Sequences.")]
		public FsmFloat timeWindow;

		[Tooltip("Use unscaled time for time window.")]
		public FsmBool realTime;

		[UIHint(UIHint.Variable)]
		[Tooltip("Store if the combo was detected.")]
		public FsmBool didSucceed;

		[Tooltip("Event to send if the combo was successfully executed.")]
		public FsmEvent successEvent;

		[Tooltip("Event to send if the combo failed (started but timed-out).")]
		public FsmEvent failedEvent;

		[Tooltip("Log Debug info to the Unity Console.")]
		public FsmBool debug;

		private bool comboStarted;

		private int stepInSequence;

		private float timer;

		private readonly List<ButtonControl> comboButtons = new List<ButtonControl>();

		private List<ButtonControl> buttonsPressed = new List<ButtonControl>();

		private List<ButtonControl> validNextButtons;

		public override void Reset()
		{
			base.Reset();
			buttons = null;
			timeWindow = 0.2f;
			realTime = null;
			didSucceed = null;
			successEvent = null;
			failedEvent = null;
			debug = null;
		}

		public override void OnEnter()
		{
			gamepad = Gamepad.current;
			if (gamepad != null && buttons.Length != 0)
			{
				object[] values = buttons.Values;
				foreach (object obj in values)
				{
					comboButtons.Add(GetButtonControl((GamepadButton)obj));
				}
				ResetCombo();
			}
		}

		private void ResetCombo()
		{
			if ((Combo)(object)combo.Value == Combo.SameTime)
			{
				validNextButtons = new List<ButtonControl>(comboButtons);
			}
			else
			{
				validNextButtons = new List<ButtonControl> { comboButtons[0] };
			}
			buttonsPressed.Clear();
			didSucceed.Value = false;
			comboStarted = false;
			stepInSequence = 0;
			timer = 0f;
		}

		protected override void Execute()
		{
			if (buttons.Length == 0)
			{
				return;
			}
			if (comboStarted)
			{
				timer += Time.deltaTime;
				if (timer > timeWindow.Value)
				{
					if (debug.Value)
					{
						Log("Combo Failed: Timeout");
					}
					base.Fsm.Event(failedEvent);
					ResetCombo();
				}
			}
			foreach (ButtonControl item in new List<ButtonControl>(validNextButtons))
			{
				if (item.wasPressedThisFrame)
				{
					DoComboStep(item);
				}
			}
		}

		private void DoComboStep(ButtonControl lastPressedButton)
		{
			if (!comboStarted)
			{
				comboStarted = true;
			}
			if (debug.Value)
			{
				Log("Combo Button: " + lastPressedButton.name);
			}
			timer = 0f;
			if ((Combo)(object)combo.Value == Combo.SameTime)
			{
				validNextButtons.Remove(lastPressedButton);
			}
			else
			{
				validNextButtons.Clear();
				stepInSequence++;
				if (stepInSequence < comboButtons.Count)
				{
					validNextButtons.Add(comboButtons[stepInSequence]);
				}
			}
			if (validNextButtons.Count == 0)
			{
				if (debug.Value)
				{
					Log("Combo Succeeded!");
				}
				didSucceed.Value = true;
				base.Fsm.Event(successEvent);
				ResetCombo();
			}
		}
	}
}
