using UnityEngine.InputSystem;

namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("PlayerInput")]
	public abstract class PlayerInputUpdateActionBase : ComponentAction<PlayerInput>
	{
		public enum UpdateMode
		{
			Once = 0,
			Update = 1,
			FixedUpdate = 2
		}

		[DisplayOrder(0)]
		[RequiredField]
		[CheckForComponent(typeof(PlayerInput))]
		[Tooltip("The GameObject with the PlayerInput component.")]
		public FsmOwnerDefault gameObject;

		[DisplayOrder(1)]
		[RequiredField]
		[ObjectType(typeof(InputActionReference))]
		[Tooltip("An InputAction used by the PlayerInput component.")]
		public FsmObject inputAction;

		[Tooltip("When to read the Input.")]
		public UpdateMode updateMode;

		protected PlayerInput playerInput;

		protected InputAction action;

		public override void Reset()
		{
			gameObject = null;
			updateMode = UpdateMode.Update;
			inputAction = null;
			action = null;
		}

		public override void OnPreprocess()
		{
			base.Fsm.HandleFixedUpdate = updateMode == UpdateMode.FixedUpdate;
		}

		protected bool UpdateCache()
		{
			if (!UpdateCache(base.Fsm.GetOwnerDefaultTarget(gameObject)))
			{
				return false;
			}
			InputActionReference inputActionReference = inputAction.Value as InputActionReference;
			if (inputActionReference == null)
			{
				return false;
			}
			if (playerInput != cachedComponent)
			{
				playerInput = cachedComponent;
				action = playerInput.actions.FindAction(inputActionReference.action.id);
				if (action == null)
				{
					LogWarning("Could not find action " + inputActionReference.name);
					return false;
				}
			}
			return true;
		}

		public override void OnEnter()
		{
			if (!UpdateCache())
			{
				Finish();
			}
			Execute();
			if (updateMode == UpdateMode.Once)
			{
				Finish();
			}
		}

		public override void OnUpdate()
		{
			if (updateMode == UpdateMode.Update)
			{
				if (!UpdateCache())
				{
					Finish();
				}
				Execute();
			}
		}

		public override void OnFixedUpdate()
		{
			if (updateMode == UpdateMode.FixedUpdate)
			{
				if (!UpdateCache())
				{
					Finish();
				}
				Execute();
			}
		}

		protected virtual void Execute()
		{
		}

		public override void OnExit()
		{
			playerInput = null;
		}
	}
}
