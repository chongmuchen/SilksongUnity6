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
		private readonly HashSet<BindingSource> nativeBackedBindings = new HashSet<BindingSource>();
		private readonly ReadOnlyCollection<BindingSource> bindings;
		private int suppressFrame = -1;
		private int lastActivityFrame = -1;
		private bool aggregateBindingsNativeBacked = true;
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

		internal bool AllBindingsNativeBacked => regularBindings.All(binding => nativeBackedBindings.Contains(binding));

		internal bool CanReadNativeValue => CanReadInput && regularBindings.Count > 0 &&
			AllBindingsNativeBacked && aggregateBindingsNativeBacked;

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
				if ((previousFrame || !nativeBackedBindings.Contains(binding)) && Mathf.Abs(value) > Mathf.Abs(result))
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
				nativeBackedBindings.Add(binding);
				binding.BoundTo = this;
			}
		}

		private void RebuildNativeBindings()
		{
			if (nativeAction == null)
			{
				return;
			}
			List<NativeBindingCandidate> desiredBindings = new List<NativeBindingCandidate>();
			Dictionary<BindingSource, int> requiredPathCounts = new Dictionary<BindingSource, int>();
			Dictionary<BindingSource, int> assignedPathCounts = new Dictionary<BindingSource, int>();
			foreach (BindingSource binding in regularBindings)
			{
				HashSet<string> bindingPaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
				foreach (string path in binding.ControlPaths)
				{
					if (!string.IsNullOrWhiteSpace(path) && bindingPaths.Add(path))
					{
						desiredBindings.Add(new NativeBindingCandidate(binding, path, BindingPathMapper.GetBindingGroup(path)));
					}
				}
				if (bindingPaths.Count > 0)
				{
					requiredPathCounts[binding] = bindingPaths.Count;
					assignedPathCounts[binding] = 0;
				}
			}

			bool[] assigned = new bool[desiredBindings.Count];
			for (int bindingIndex = 0; bindingIndex < nativeAction.bindings.Count; bindingIndex++)
			{
				InputBinding nativeBinding = nativeAction.bindings[bindingIndex];
				if (nativeBinding.isComposite || nativeBinding.isPartOfComposite)
				{
					continue;
				}
				string bindingGroup = GetNativeBindingGroup(nativeBinding);
				int candidateIndex = -1;
				int nativeControlKind = BindingPathMapper.GetControlKind(nativeBinding.path);
				for (int candidate = 0; candidate < desiredBindings.Count; candidate++)
				{
					if (!assigned[candidate] &&
						string.Equals(desiredBindings[candidate].Group, bindingGroup, StringComparison.OrdinalIgnoreCase) &&
						BindingPathMapper.GetControlKind(desiredBindings[candidate].Path) == nativeControlKind)
					{
						candidateIndex = candidate;
						break;
					}
				}
				if (candidateIndex < 0)
				{
					for (int candidate = 0; candidate < desiredBindings.Count; candidate++)
					{
						if (!assigned[candidate] && string.Equals(desiredBindings[candidate].Group, bindingGroup, StringComparison.OrdinalIgnoreCase))
						{
							candidateIndex = candidate;
							break;
						}
					}
				}
				if (candidateIndex < 0)
				{
					nativeAction.ApplyBindingOverride(bindingIndex, string.Empty);
					continue;
				}
				NativeBindingCandidate selected = desiredBindings[candidateIndex];
				assigned[candidateIndex] = true;
				assignedPathCounts[selected.Source]++;
				nativeAction.ApplyBindingOverride(bindingIndex, new InputBinding
				{
					overridePath = selected.Path,
					overrideProcessors = BindingPathMapper.GetOverrideProcessors(selected.Path, nativeBinding.processors)
				});
			}

			nativeBackedBindings.Clear();
			foreach (KeyValuePair<BindingSource, int> required in requiredPathCounts)
			{
				if (assignedPathCounts[required.Key] == required.Value)
				{
					nativeBackedBindings.Add(required.Key);
				}
			}
			Owner.SyncAggregateBinding(this);
		}

		internal List<string> GetControlPaths(string bindingGroup)
		{
			List<string> paths = new List<string>();
			HashSet<string> uniquePaths = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
			foreach (BindingSource binding in regularBindings)
			{
				foreach (string path in binding.ControlPaths)
				{
					if (!string.IsNullOrWhiteSpace(path) &&
						string.Equals(BindingPathMapper.GetBindingGroup(path), bindingGroup, StringComparison.OrdinalIgnoreCase) &&
						uniquePaths.Add(path))
					{
						paths.Add(path);
					}
				}
			}
			return paths;
		}

		internal void SetAggregateBindingsNativeBacked(bool value) => aggregateBindingsNativeBacked = value;

		private static string GetNativeBindingGroup(InputBinding binding)
		{
			if (!string.IsNullOrWhiteSpace(binding.groups))
			{
				if (binding.groups.IndexOf("Gamepad", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					return "Gamepad";
				}
				if (binding.groups.IndexOf("Keyboard&Mouse", StringComparison.OrdinalIgnoreCase) >= 0)
				{
					return "Keyboard&Mouse";
				}
			}
			return BindingPathMapper.GetBindingGroup(binding.path);
		}

		private readonly struct NativeBindingCandidate
		{
			internal readonly BindingSource Source;
			internal readonly string Path;
			internal readonly string Group;

			internal NativeBindingCandidate(BindingSource source, string path, string group)
			{
				Source = source;
				Path = path;
				Group = group;
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
		private readonly NativeInputAction nativeAction;

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
				Vector2 value;
				if (CanReadNativeAction)
				{
					negativeXAction.Owner.EnsureNativeActionsEnabled();
					value = nativeAction.ReadValue<Vector2>();
				}
				else
				{
					float x = Mathf.Clamp(positiveXAction.Value - negativeXAction.Value, -1f, 1f);
					float y = Mathf.Clamp(positiveYAction.Value - negativeYAction.Value, -1f, 1f);
					value = new Vector2(x, y);
				}
				return new Vector2(InvertXAxis ? -value.x : value.x, InvertYAxis ? -value.y : value.y);
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

		internal PlayerTwoAxisAction(PlayerAction negativeXAction, PlayerAction positiveXAction, PlayerAction negativeYAction, PlayerAction positiveYAction,
			NativeInputAction nativeAction = null)
		{
			this.negativeXAction = negativeXAction;
			this.positiveXAction = positiveXAction;
			this.negativeYAction = negativeYAction;
			this.positiveYAction = positiveYAction;
			this.nativeAction = nativeAction;
		}

		public void ClearInputState()
		{
			negativeXAction.ClearInputState();
			positiveXAction.ClearInputState();
			negativeYAction.ClearInputState();
			positiveYAction.ClearInputState();
		}

		private static float ReadPrevious(PlayerAction action) => action.PreviousValue;

		private bool CanReadNativeAction => nativeAction != null && negativeXAction.CanReadNativeValue &&
			positiveXAction.CanReadNativeValue && negativeYAction.CanReadNativeValue && positiveYAction.CanReadNativeValue;

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
		private readonly Dictionary<PlayerAction, AggregateBinding> aggregateBindings = new Dictionary<PlayerAction, AggregateBinding>();
		private readonly ReadOnlyCollection<PlayerAction> readOnlyActions;
		private BindingListenOptions listenOptions = new BindingListenOptions();
		private InputDevice device;
		private InputDevice activeDevice = InputDevice.Null;
		private BindingSourceType lastInputType;
		private ulong lastInputTypeChangedTick;
		private InputDeviceClass lastDeviceClass;
		private InputDeviceStyle lastDeviceStyle;
		private readonly NativeInputActionMap nativeActionMap;
		private readonly bool ownsNativeActionMap;
		private bool enabled = true;

		internal PlayerAction ListeningAction { get; set; }

		public InputDevice Device
		{
			get => device;
			set
			{
				device = value;
				if (nativeActionMap != null)
				{
					if (value == null || value == InputDevice.Null || value.Gamepad == null)
					{
						nativeActionMap.devices = null;
					}
					else
					{
						List<UnityEngine.InputSystem.InputDevice> devices = new List<UnityEngine.InputSystem.InputDevice> { value.Gamepad };
						if (Keyboard.current != null)
						{
							devices.Add(Keyboard.current);
						}
						if (UnityEngine.InputSystem.Mouse.current != null)
						{
							devices.Add(UnityEngine.InputSystem.Mouse.current);
						}
						nativeActionMap.devices = devices.ToArray();
					}
				}
			}
		}
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
				else if (ownsNativeActionMap && nativeActionMap.enabled)
				{
					nativeActionMap.Disable();
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

		protected PlayerActionSet(string actionMapName = null, bool createPrivateCopy = false)
		{
			readOnlyActions = new ReadOnlyCollection<PlayerAction>(actions);
			nativeActionMap = InputManager.GetActionMap(actionMapName ?? GetType().Name, createPrivateCopy, out bool ownsMap);
			ownsNativeActionMap = ownsMap;
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
			if (!ownsNativeActionMap && nativeActionMap != null && device != null)
			{
				nativeActionMap.devices = null;
			}
			if (ownsNativeActionMap && nativeActionMap != null)
			{
				nativeActionMap.Disable();
				nativeActionMap.Dispose();
			}
		}

		protected PlayerAction CreatePlayerAction(string name)
		{
			return new PlayerAction(name, this);
		}

		protected PlayerTwoAxisAction CreateTwoAxisPlayerAction(PlayerAction negativeXAction, PlayerAction positiveXAction, PlayerAction negativeYAction,
			PlayerAction positiveYAction, string nativeActionName = null)
		{
			NativeInputAction nativeAction = string.IsNullOrWhiteSpace(nativeActionName)
				? null
				: nativeActionMap?.FindAction(nativeActionName, throwIfNotFound: false);
			PlayerTwoAxisAction action = new PlayerTwoAxisAction(negativeXAction, positiveXAction, negativeYAction, positiveYAction, nativeAction);
			twoAxisActions.Add(action);
			if (nativeAction != null)
			{
				aggregateBindings[negativeXAction] = new AggregateBinding(nativeAction, "left");
				aggregateBindings[positiveXAction] = new AggregateBinding(nativeAction, "right");
				aggregateBindings[negativeYAction] = new AggregateBinding(nativeAction, "down");
				aggregateBindings[positiveYAction] = new AggregateBinding(nativeAction, "up");
				SyncAggregateBinding(negativeXAction);
				SyncAggregateBinding(positiveXAction);
				SyncAggregateBinding(negativeYAction);
				SyncAggregateBinding(positiveYAction);
			}
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
			if (!ownsNativeActionMap)
			{
				Debug.LogError($"Action '{name}' was not found in the project-wide map '{nativeActionMap.name}'.");
				return null;
			}
			bool wasEnabled = nativeActionMap.enabled;
			if (wasEnabled)
			{
				nativeActionMap.Disable();
			}
			action = nativeActionMap.AddAction(name, type, expectedControlLayout: expectedControlType);
			if (wasEnabled)
			{
				EnsureNativeActionsEnabled();
			}
			return action;
		}

		internal void EnsureNativeActionsEnabled()
		{
			if (!enabled || nativeActionMap == null || nativeActionMap.enabled)
			{
				return;
			}
			nativeActionMap.Enable();
		}

		internal void SyncAggregateBinding(PlayerAction sourceAction)
		{
			if (sourceAction == null || !aggregateBindings.TryGetValue(sourceAction, out AggregateBinding aggregate))
			{
				return;
			}
			bool allPathsAssigned = true;
			string[] bindingGroups = { "Keyboard&Mouse", "Gamepad" };
			foreach (string bindingGroup in bindingGroups)
			{
				List<string> paths = sourceAction.GetControlPaths(bindingGroup);
				List<int> bindingIndices = new List<int>();
				for (int i = 0; i < aggregate.Action.bindings.Count; i++)
				{
					InputBinding binding = aggregate.Action.bindings[i];
					if (binding.isPartOfComposite && string.Equals(binding.name, aggregate.PartName, StringComparison.OrdinalIgnoreCase) &&
						!string.IsNullOrEmpty(binding.groups) && binding.groups.IndexOf(bindingGroup, StringComparison.OrdinalIgnoreCase) >= 0)
					{
						bindingIndices.Add(i);
					}
				}

				bool[] assigned = new bool[paths.Count];
				foreach (int bindingIndex in bindingIndices)
				{
					InputBinding binding = aggregate.Action.bindings[bindingIndex];
					int pathIndex = FindAggregatePath(paths, assigned, BindingPathMapper.GetControlKind(binding.path));
					string path = pathIndex >= 0 ? paths[pathIndex] : string.Empty;
					if (pathIndex >= 0)
					{
						assigned[pathIndex] = true;
					}
					aggregate.Action.ApplyBindingOverride(bindingIndex, new InputBinding
					{
						overridePath = path,
						overrideProcessors = BindingPathMapper.GetOverrideProcessors(path, binding.processors)
					});
				}
				allPathsAssigned &= assigned.All(value => value);
			}
			sourceAction.SetAggregateBindingsNativeBacked(allPathsAssigned);
		}

		private static int FindAggregatePath(List<string> paths, bool[] assigned, int targetControlKind)
		{
			for (int i = 0; i < paths.Count; i++)
			{
				if (!assigned[i] && BindingPathMapper.GetControlKind(paths[i]) == targetControlKind)
				{
					return i;
				}
			}
			for (int i = 0; i < paths.Count; i++)
			{
				if (!assigned[i])
				{
					return i;
				}
			}
			return -1;
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

		private readonly struct AggregateBinding
		{
			internal readonly NativeInputAction Action;
			internal readonly string PartName;

			internal AggregateBinding(NativeInputAction action, string partName)
			{
				Action = action;
				PartName = partName;
			}
		}
	}
}
