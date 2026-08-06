using InputSystem;
using UnityEngine;

[RequireComponent(typeof(HollowKnightInputModule))]
public class InputModuleBinder : MonoBehaviour
{
	public class MyActionSet : PlayerActionSet
	{
		public PlayerAction Submit;

		public PlayerAction Cancel;

		public PlayerAction Left;

		public PlayerAction Right;

		public PlayerAction Up;

		public PlayerAction Down;

		public PlayerTwoAxisAction Move;

		public MyActionSet()
		{
			Submit = CreatePlayerAction("Submit");
			Cancel = CreatePlayerAction("Cancel");
			Left = CreatePlayerAction("Left");
			Right = CreatePlayerAction("Right");
			Up = CreatePlayerAction("Up");
			Down = CreatePlayerAction("Down");
			Move = CreateTwoAxisPlayerAction(Left, Right, Down, Up);
		}
	}

	private MyActionSet actions;

	private InputHandler ih;

	private void OnEnable()
	{
		actions = new MyActionSet();
		BindAndApplyActions();
		HollowKnightInputModule component = GetComponent<HollowKnightInputModule>();
		component.SubmitAction = actions.Submit;
		component.CancelAction = actions.Cancel;
		component.MoveAction = actions.Move;
		ih = ManagerSingleton<InputHandler>.Instance;
		if ((bool)ih)
		{
			ih.RefreshActiveControllerEvent += BindAndApplyActions;
		}
	}

	private void OnDisable()
	{
		if ((bool)ih)
		{
			ih.RefreshActiveControllerEvent -= BindAndApplyActions;
			ih = null;
		}
		actions.Destroy();
	}

	private void BindAndApplyActions()
	{
		actions.Submit.ClearBindings();
		actions.Cancel.ClearBindings();
		if (!ih)
		{
			ih = ManagerSingleton<InputHandler>.Instance;
		}
		Platform.AcceptRejectInputStyles acceptRejectInputStyles = (ih ? Platform.Current.GetAcceptRejectInputStyle(ih.activeGamepadType) : Platform.AcceptRejectInputStyles.NonJapaneseStyle);
		if (acceptRejectInputStyles == Platform.AcceptRejectInputStyles.NonJapaneseStyle || acceptRejectInputStyles != Platform.AcceptRejectInputStyles.JapaneseStyle)
		{
			actions.Submit.AddDefaultBinding(InputControlType.Action1);
			actions.Submit.AddDefaultBinding(Key.Space);
			actions.Submit.AddDefaultBinding(Key.Return);
			actions.Cancel.AddDefaultBinding(InputControlType.Action2);
			actions.Cancel.AddDefaultBinding(Key.Escape);
		}
		else
		{
			actions.Cancel.AddDefaultBinding(InputControlType.Action1);
			actions.Cancel.AddDefaultBinding(Key.Escape);
			actions.Submit.AddDefaultBinding(InputControlType.Action2);
			actions.Submit.AddDefaultBinding(Key.Space);
			actions.Submit.AddDefaultBinding(Key.Return);
		}
		actions.Up.ClearBindings();
		actions.Up.AddDefaultBinding(Key.UpArrow);
		actions.Up.AddDefaultBinding(InputControlType.LeftStickUp);
		actions.Up.AddDefaultBinding(InputControlType.DPadUp);
		actions.Down.ClearBindings();
		actions.Down.AddDefaultBinding(Key.DownArrow);
		actions.Down.AddDefaultBinding(InputControlType.LeftStickDown);
		actions.Down.AddDefaultBinding(InputControlType.DPadDown);
		actions.Left.ClearBindings();
		actions.Left.AddDefaultBinding(Key.LeftArrow);
		actions.Left.AddDefaultBinding(InputControlType.LeftStickLeft);
		actions.Left.AddDefaultBinding(InputControlType.DPadLeft);
		actions.Right.ClearBindings();
		actions.Right.AddDefaultBinding(Key.RightArrow);
		actions.Right.AddDefaultBinding(InputControlType.LeftStickRight);
		actions.Right.AddDefaultBinding(InputControlType.DPadRight);
	}
}
