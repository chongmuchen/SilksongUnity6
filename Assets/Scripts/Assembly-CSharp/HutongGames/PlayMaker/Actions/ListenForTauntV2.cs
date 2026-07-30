using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("Controls")]
	[Tooltip("Listens for an action button press (using HeroActions InControl mappings).")]
	public class ListenForTauntV2 : FsmStateAction
	{
		public FsmOwnerDefault Target;

		public FsmEvent WasPressed;

		public FsmEvent WasReleased;

		public FsmEvent IsPressed;

		public FsmEvent IsNotPressed;

		public FsmBool ActiveBool;

		public FsmFloat DelayBeforeActive;

		private GameManager gm;

		private InputHandler inputHandler;

		private float timer;

		public override void Reset()
		{
			Target = null;
			WasPressed = null;
			WasReleased = null;
			IsPressed = null;
			IsNotPressed = null;
			ActiveBool = new FsmBool
			{
				UseVariable = true
			};
			DelayBeforeActive = null;
		}

		public override void OnEnter()
		{
			gm = GameManager.instance;
			inputHandler = gm.GetComponent<InputHandler>();
			timer = DelayBeforeActive.Value;
		}

		public override void OnUpdate()
		{
			if (gm.isPaused)
			{
				return;
			}
			if (!ActiveBool.IsNone && !ActiveBool.Value)
			{
				timer = DelayBeforeActive.Value;
				return;
			}
			if (timer > 0f)
			{
				timer -= Time.deltaTime;
				return;
			}
			if (inputHandler.inputActions.Taunt.WasPressed)
			{
				base.Fsm.Event(WasPressed);
			}
			if (inputHandler.inputActions.Taunt.WasReleased)
			{
				base.Fsm.Event(WasReleased);
			}
			if (inputHandler.inputActions.Taunt.IsPressed)
			{
				base.Fsm.Event(IsPressed);
			}
			if (!inputHandler.inputActions.Taunt.IsPressed)
			{
				base.Fsm.Event(IsNotPressed);
			}
		}
	}
}
