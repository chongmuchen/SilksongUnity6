using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using UnityEngine;
using UnityEngine.InputSystem;
using NativeInputAction = UnityEngine.InputSystem.InputAction;
using NativeInputActionMap = UnityEngine.InputSystem.InputActionMap;

namespace InputSystem
{
	public class PlayerAction
	{
		private readonly List<BindingSource> defaultBindings = new List<BindingSource>();
		private readonly List<BindingSource> regularBindings = new List<BindingSource>();
		private readonly ReadOnlyCollection<BindingSource> bindings;
		private int suppressFrame = -1;
		private int lastActivityFrame = -1;
		private InputDevice activeDevice = InputDevice.Null;
		private BindingSourceType lastInputType;
		private InputDeviceClass lastDeviceClass;
		private InputDeviceStyle lastDeviceStyle;
		private ulong lastInputTypeChangedTick;
		private readonly NativeInputAction nativeAction;

		public string Name { get; }
		public PlayerActionSet Owner { get; }
		public BindingListenOptions ListenOptions;
		public object UserData { get; set; }
		public bool Enabled { get; set; } = true;
		public float StateThreshold { get; set; }
		public ReadOnlyCollection<BindingSource> Bindings => bindings;
		public bool IsListeningForBinding => Owner.IsListeningWith(this);
		public InputDevice ActiveDevice => activeDevice != null && activeDevice.IsAttached ? activeDevice : InputDevice.Null;
		public BindingSourceType LastInputType => lastInputType;
		public InputDeviceClass LastDeviceClass => lastDeviceClass;
		public InputDeviceStyle LastDeviceStyle => lastDeviceStyle;
		public ulong LastInputTypeChangedTick => lastInputTypeChangedTick;

		public float Value => CanReadInput ? ReadValue(previousFrame: false) : 0f;

		public float RawValue => Value;

		public bool IsPressed => Mathf.Abs(Value) > StateThreshold;

		public bool WasPressed
		{
			get
			{
				if (!CanReadInput)
				{
					return false;
				}
				return Mathf.Abs(ReadValue(previousFrame: false)) > StateThreshold && Mathf.Abs(ReadValue(previousFrame: true)) <= StateThreshold;
			}
		}

		public bool WasReleased
		{
			get
			{
				if (!CanReadInput)
				{
					return false;
				}
				return Mathf.Abs(ReadValue(previousFrame: false)) <= StateThreshold && Mathf.Abs(ReadValue(previousFrame: true)) > StateThreshold;
			}
		}

		private bool CanReadInput => Enabled && Owner.Enabled && suppressFrame != Time.frameCount &&
			(!Owner.PreventInputWhileListeningForBinding || !Owner.IsListeningForBinding);

		internal float PreviousValue => CanReadInput ? ReadValue(previousFrame: true) : 0f;

		internal InputDevice Device => Owner.Device ?? InputManager.ActiveDevice;

		internal NativeInputAction NativeAction => nativeAction;

		internal PlayerAction(string name, PlayerActionSet owner)
		{
			Name = name;
			Owner = owner;
			nativeAction = owner.GetOrCreateNativeAction(name, InputActionType.Button, "Button");
			bindings = new ReadOnlyCollection<BindingSource>(regularBindings);
			ImportDefaultBindingsFromNativeAction();
			owner.AddPlayerAction(this);
		}

		public void AddDefaultBinding(BindingSource binding)
		{
			if (binding == null)
			{
				return;
			}
			BindingSource defaultBinding = defaultBindings.FirstOrDefault(item => item == binding);
			if (defaultBinding == null)
			{
				defaultBinding = binding;
				defaultBindings.Add(defaultBinding);
			}
			if (!HasBinding(defaultBinding))
			{
				AddBindingInternal(defaultBinding);
			}
		}

		public void AddDefaultBinding(params Key[] keys) => AddDefaultBinding(new KeyBindingSource(keys));

		public void AddDefaultBinding(KeyCombo keyCombo) => AddDefaultBinding(new KeyBindingSource(keyCombo));

		public void AddDefaultBinding(Mouse control) => AddDefaultBinding(new MouseBindingSource(control));

		public void AddDefaultBinding(InputControlType control) => AddDefaultBinding(new DeviceBindingSource(control));

		public bool AddBinding(BindingSource binding)
		{
			return AddBindingInternal(binding);
		}

		public bool HasBinding(BindingSource binding) => FindBinding(binding) != null;

		public BindingSource FindBinding(BindingSource binding)
		{
			if (binding == null)
			{
				return null;
			}
			return regularBindings.FirstOrDefault(item => item == binding);
		}

		public void RemoveBinding(BindingSource binding)
		{
			BindingSource existing = FindBinding(binding);
			if (existing == null)
			{
				return;
			}
			regularBindings.Remove(existing);
			existing.BoundTo = null;
			RebuildNativeBindings();
		}

		public bool ReplaceBinding(BindingSource findBinding, BindingSource withBinding)
		{
			if (findBinding == null || withBinding == null || withBinding.BoundTo != null)
			{
				return false;
			}
			BindingSource existing = FindBinding(findBinding);
			if (existing == null)
			{
				return false;
			}
			int index = regularBindings.IndexOf(existing);
			existing.BoundTo = null;
			regularBindings[index] = withBinding;
			withBinding.BoundTo = this;
			RebuildNativeBindings();
			return true;
		}

		public void ClearBindings()
		{
			foreach (BindingSource binding in regularBindings)
			{
				binding.BoundTo = null;
			}
			regularBindings.Clear();
			RebuildNativeBindings();
		}

		public void ResetBindings()
		{
			ClearBindings();
			foreach (BindingSource binding in defaultBindings)
			{
				AddBindingInternal(binding);
			}
		}

		public void ListenForBinding()
		{
			EffectiveListenOptions.ReplaceBinding = null;
			InputManager.StartListening(this);
		}

		public void ListenForBindingReplacing(BindingSource binding)
		{
			EffectiveListenOptions.ReplaceBinding = binding;
			InputManager.StartListening(this);
		}

		public void StopListeningForBinding()
		{
			InputManager.StopListening(this);
		}

		public void ClearInputState()
		{
			suppressFrame = Time.frameCount;
		}

		public static implicit operator bool(PlayerAction action)
		{
			return action != null && action.IsPressed;
		}

		private bool AddBindingInternal(BindingSource binding)
		{
			if (binding == null || regularBindings.Contains(binding))
			{
				return false;
			}
			if (binding.BoundTo != null && binding.BoundTo != this)
			{
				return false;
			}
			regularBindings.Add(binding);
			binding.BoundTo = this;
			RebuildNativeBindings();
			return true;
		}

		private float ReadValue(bool previousFrame)
		{
			float result = previousFrame ? 0f : ReadNativeValue();
			InputDevice device = Device;
			BindingSource activityBinding = null;
			float activityValue = 0f;
			for (int i = regularBindings.Count - 1; i >= 0; i--)
			{
				BindingSource binding = regularBindings[i];
				float value = previousFrame ? binding.GetPreviousValue(device) : binding.GetValue(device);
				if (Mathf.Abs(value) > Mathf.Abs(result))
				{
					result = value;
				}
				if (!previousFrame && Mathf.Abs(value) > Mathf.Abs(activityValue))
				{
					activityValue = value;
					activityBinding = binding;
				}
			}
			if (!previousFrame && lastActivityFrame != Time.frameCount && activityBinding != null && Mathf.Abs(result) > Mathf.Epsilon)
			{
				RecordInputActivity(activityBinding, device);
				lastActivityFrame = Time.frameCount;
			}
			return result;
		}

		private float ReadNativeValue()
		{
			if (nativeAction == null)
			{
				return 0f;
			}
			Owner.EnsureNativeActionsEnabled();
			return nativeAction.ReadValue<float>();
		}

		private void ImportDefaultBindingsFromNativeAction()
		{
			if (nativeAction == null)
			{
				return;
			}
			foreach (InputBinding inputBinding in nativeAction.bindings)
			{
				if (inputBinding.isComposite || inputBinding.isPartOfComposite ||
					!BindingPathMapper.TryCreateBinding(inputBinding.path, out BindingSource binding) ||
					defaultBindings.Any(item => item == binding))
				{
					continue;
				}
				defaultBindings.Add(binding);
				regularBindings.Add(binding);
				binding.BoundTo = this;
			}
		}

		private void RebuildNativeBindings()
		{
			if (nativeAction == null)
			{
				return;
			}
			bool wasEnabled = nativeAction.enabled;
			if (wasEnabled)
			{
				nativeAction.Disable();
			}
			for (int i = nativeAction.bindings.Count - 1; i >= 0; i--)
			{
				nativeAction.ChangeBinding(i).Erase();
			}
			HashSet<string> paths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
			foreach (BindingSource binding in regularBindings)
			{
				foreach (string path in binding.ControlPaths)
				{
					if (!string.IsNullOrWhiteSpace(path) && paths.Add(path))
					{
						nativeAction.AddBinding(path,
							processors: BindingPathMapper.GetProcessors(path),
							groups: BindingPathMapper.GetBindingGroup(path));
					}
				}
			}
			if (wasEnabled)
			{
				nativeAction.Enable();
			}
		}

		private void RecordInputActivity(BindingSource binding, InputDevice device)
		{
			lastInputType = binding.BindingSourceType;
			lastDeviceClass = binding.DeviceClass;
			lastDeviceStyle = binding.BindingSourceType == BindingSourceType.DeviceBindingSource
				? (device ?? InputDevice.Null).DeviceStyle
				: InputDeviceStyle.Unknown;
			activeDevice = binding.BindingSourceType == BindingSourceType.DeviceBindingSource
				? (device ?? InputDevice.Null)
				: InputDevice.Null;
			lastInputTypeChangedTick = InputManager.CurrentInputTick;
			Owner.RecordInputActivity(this);
		}

		internal void PollInputActivity()
		{
			if (CanReadInput)
			{
				ReadValue(previousFrame: false);
			}
		}

		internal BindingListenOptions EffectiveListenOptions => ListenOptions ?? Owner.ListenOptions;
	}

	public class PlayerTwoAxisAction : TwoAxisInputControl
	{
		private readonly PlayerAction negativeXAction;
		private readonly PlayerAction positiveXAction;
		private readonly PlayerAction negativeYAction;
		private readonly PlayerAction positiveYAction;

		public bool InvertXAxis { get; set; }
		public bool InvertYAxis { get; set; }
		public object UserData { get; set; }
		public BindingSourceType LastInputType
		{
			get
			{
				PlayerAction latest = LatestAction;
				return latest?.LastInputType ?? BindingSourceType.None;
			}
		}

		// These setters were no-ops on the previous PlayerTwoAxisAction implementation.
		public override float LowerDeadZone
		{
			get => 0f;
			set { }
		}

		public override float UpperDeadZone
		{
			get => 1f;
			set { }
		}

		public override Vector2 Value
		{
			get
			{
				float x = Mathf.Clamp(positiveXAction.Value - negativeXAction.Value, -1f, 1f);
				float y = Mathf.Clamp(positiveYAction.Value - negativeYAction.Value, -1f, 1f);
				return new Vector2(InvertXAxis ? -x : x, InvertYAxis ? -y : y);
			}
		}

		protected override Vector2 PreviousValue
		{
			get
			{
				float x = ReadPrevious(positiveXAction) - ReadPrevious(negativeXAction);
				float y = ReadPrevious(positiveYAction) - ReadPrevious(negativeYAction);
				return new Vector2(InvertXAxis ? -x : x, InvertYAxis ? -y : y);
			}
		}

		internal PlayerTwoAxisAction(PlayerAction negativeXAction, PlayerAction positiveXAction, PlayerAction negativeYAction, PlayerAction positiveYAction)
		{
			this.negativeXAction = negativeXAction;
			this.positiveXAction = positiveXAction;
			this.negativeYAction = negativeYAction;
			this.positiveYAction = positiveYAction;
		}

		public void ClearInputState()
		{
			negativeXAction.ClearInputState();
			positiveXAction.ClearInputState();
			negativeYAction.ClearInputState();
			positiveYAction.ClearInputState();
		}

		private static float ReadPrevious(PlayerAction action) => action.PreviousValue;

		private PlayerAction LatestAction
		{
			get
			{
				PlayerAction[] actions = { negativeXAction, positiveXAction, negativeYAction, positiveYAction };
				return actions.OrderByDescending(action => action.LastInputTypeChangedTick).FirstOrDefault();
			}
		}
	}

	public abstract class PlayerActionSet
	{
		private readonly List<PlayerAction> actions = new List<PlayerAction>();
		private readonly List<PlayerTwoAxisAction> twoAxisActions = new List<PlayerTwoAxisAction>();
		private readonly Dictionary<string, PlayerAction> actionsByName = new Dictionary<string, PlayerAction>();
		private readonly ReadOnlyCollection<PlayerAction> readOnlyActions;
		private BindingListenOptions listenOptions = new BindingListenOptions();
		private InputDevice activeDevice = InputDevice.Null;
		private BindingSourceType lastInputType;
		private ulong lastInputTypeChangedTick;
		private InputDeviceClass lastDeviceClass;
		private InputDeviceStyle lastDeviceStyle;
		private readonly NativeInputActionMap nativeActionMap;
		private bool nativeActionsEnabled;
		private bool enabled = true;

		internal PlayerAction ListeningAction { get; set; }

		public InputDevice Device { get; set; }
		public ReadOnlyCollection<PlayerAction> Actions => readOnlyActions;
		public bool Enabled
		{
			get => enabled;
			set
			{
				enabled = value;
				if (nativeActionMap == null)
				{
					return;
				}
				if (enabled)
				{
					EnsureNativeActionsEnabled();
				}
				else if (nativeActionsEnabled)
				{
					nativeActionMap.Disable();
					nativeActionsEnabled = false;
				}
			}
		}
		public bool PreventInputWhileListeningForBinding { get; set; } = true;
		public object UserData { get; set; }
		public bool IsListeningForBinding => ListeningAction != null;
		public InputDevice ActiveDevice => activeDevice != null && activeDevice.IsAttached ? activeDevice : InputDevice.Null;
		public BindingSourceType LastInputType => lastInputType;
		public ulong LastInputTypeChangedTick => lastInputTypeChangedTick;
		public InputDeviceClass LastDeviceClass => lastDeviceClass;
		public InputDeviceStyle LastDeviceStyle => lastDeviceStyle;

		public BindingListenOptions ListenOptions
		{
			get => listenOptions;
			set => listenOptions = value ?? new BindingListenOptions();
		}

		public PlayerAction this[string actionName] => actionsByName[actionName];

		protected PlayerActionSet(string actionMapName = null)
		{
			readOnlyActions = new ReadOnlyCollection<PlayerAction>(actions);
			nativeActionMap = InputManager.CreateActionMapInstance(actionMapName ?? GetType().Name);
			InputManager.AttachPlayerActionSet(this);
		}

		public void Destroy()
		{
			Enabled = false;
			if (ListeningAction != null)
			{
				InputManager.StopListening(ListeningAction);
			}
			InputManager.DetachPlayerActionSet(this);
			if (nativeActionMap != null)
			{
				nativeActionMap.Disable();
				nativeActionMap.Dispose();
				nativeActionsEnabled = false;
			}
		}

		protected PlayerAction CreatePlayerAction(string name)
		{
			return new PlayerAction(name, this);
		}

		protected PlayerTwoAxisAction CreateTwoAxisPlayerAction(PlayerAction negativeXAction, PlayerAction positiveXAction, PlayerAction negativeYAction, PlayerAction positiveYAction)
		{
			PlayerTwoAxisAction action = new PlayerTwoAxisAction(negativeXAction, positiveXAction, negativeYAction, positiveYAction);
			twoAxisActions.Add(action);
			return action;
		}

		public PlayerAction GetPlayerActionByName(string actionName)
		{
			return actionsByName.TryGetValue(actionName, out PlayerAction action) ? action : null;
		}

		public void Reset()
		{
			foreach (PlayerAction action in actions)
			{
				action.ResetBindings();
			}
		}

		public void RemoveBinding(BindingSource binding)
		{
			foreach (PlayerAction action in actions)
			{
				action.RemoveBinding(binding);
			}
		}

		public bool HasBinding(BindingSource binding)
		{
			return binding != null && actions.Any(action => action.HasBinding(binding));
		}

		public void ClearInputState()
		{
			foreach (PlayerAction action in actions)
			{
				action.ClearInputState();
			}
			foreach (PlayerTwoAxisAction action in twoAxisActions)
			{
				action.ClearInputState();
			}
		}

		internal void AddPlayerAction(PlayerAction action)
		{
			if (actionsByName.ContainsKey(action.Name))
			{
				throw new InvalidOperationException($"Action '{action.Name}' already exists in this set.");
			}
			actions.Add(action);
			actionsByName.Add(action.Name, action);
		}

		internal bool IsListeningWith(PlayerAction action) => ListeningAction == action;

		internal void PollInputActivity()
		{
			EnsureNativeActionsEnabled();
			foreach (PlayerAction action in actions)
			{
				action.PollInputActivity();
			}
		}

		internal NativeInputAction GetOrCreateNativeAction(string name, InputActionType type, string expectedControlType)
		{
			if (nativeActionMap == null)
			{
				return null;
			}
			NativeInputAction action = nativeActionMap.FindAction(name, throwIfNotFound: false);
			if (action != null)
			{
				return action;
			}
			bool wasEnabled = nativeActionsEnabled;
			if (wasEnabled)
			{
				nativeActionMap.Disable();
				nativeActionsEnabled = false;
			}
			action = nativeActionMap.AddAction(name, type, expectedControlType: expectedControlType);
			if (wasEnabled)
			{
				EnsureNativeActionsEnabled();
			}
			return action;
		}

		internal void EnsureNativeActionsEnabled()
		{
			if (!enabled || nativeActionsEnabled || nativeActionMap == null)
			{
				return;
			}
			nativeActionMap.Enable();
			nativeActionsEnabled = true;
		}

		internal void RecordInputActivity(PlayerAction action)
		{
			if (action == null || action.LastInputTypeChangedTick <= lastInputTypeChangedTick)
			{
				return;
			}
			activeDevice = action.ActiveDevice;
			lastInputType = action.LastInputType;
			lastInputTypeChangedTick = action.LastInputTypeChangedTick;
			lastDeviceClass = action.LastDeviceClass;
			lastDeviceStyle = action.LastDeviceStyle;
		}
	}
}
