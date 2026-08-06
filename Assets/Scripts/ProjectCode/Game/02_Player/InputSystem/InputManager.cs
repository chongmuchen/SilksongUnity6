using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Linq;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Controls;
using NewInputDevice = UnityEngine.InputSystem.InputDevice;
using NewMouse = UnityEngine.InputSystem.Mouse;
using NativeInputActionMap = UnityEngine.InputSystem.InputActionMap;
using UnityInputSystem = UnityEngine.InputSystem.InputSystem;

namespace InputSystem
{
	/// <summary>
	/// Project input runtime backed by Unity's Input System. The public surface mirrors the
	/// small subset of InControl that the game uses so gameplay and saved bindings stay stable.
	/// </summary>
	public static class InputManager
	{
		private static readonly List<InputDevice> devices = new List<InputDevice>();
		private static readonly ReadOnlyCollection<InputDevice> readOnlyDevices = devices.AsReadOnly();
		private static readonly Dictionary<int, InputDevice> devicesById = new Dictionary<int, InputDevice>();
		private static readonly HashSet<PlayerActionSet> actionSets = new HashSet<PlayerActionSet>();

		private static PlayerAction listeningAction;
		private static BindingSource listeningCandidate;
		private static InputDevice listeningDevice;
		private static int listeningPhase;
		private static int lastPolledFrame = -1;
		private static ulong currentTick;
		private static InputDevice activeDevice = InputDevice.Null;

		public static bool IsSetup { get; private set; }

		public static ReadOnlyCollection<InputDevice> Devices => readOnlyDevices;

		public static InputDevice ActiveDevice => activeDevice ?? InputDevice.Null;

		public static BindingSourceType LastInputType { get; private set; }

		public static InputDeviceClass LastDeviceClass { get; private set; }

		public static InputDeviceStyle LastDeviceStyle { get; private set; }

		public static ulong LastInputTypeChangedTick { get; private set; }

		public static bool AnyKeyIsPressed => Keyboard.current?.anyKey.isPressed ?? false;

		internal static ulong CurrentInputTick => currentTick;

		public static event Action OnSetupCompleted;
		public static event Action<InputDevice> OnDeviceAttached;
		public static event Action<InputDevice> OnDeviceDetached;
		public static event Action<InputDevice> OnActiveDeviceChanged;

		[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.SubsystemRegistration)]
		private static void ResetRuntime()
		{
			UnityInputSystem.onAfterUpdate -= HandleAfterUpdate;
			UnityInputSystem.onDeviceChange -= HandleDeviceChange;
			foreach (InputDevice device in devices)
			{
				device.StopVibration();
			}
			devices.Clear();
			devicesById.Clear();
			actionSets.Clear();
			listeningAction = null;
			listeningCandidate = null;
			listeningDevice = null;
			listeningPhase = 0;
			lastPolledFrame = -1;
			currentTick = 0;
			activeDevice = InputDevice.Null;
			LastInputType = BindingSourceType.None;
			LastDeviceClass = InputDeviceClass.Unknown;
			LastDeviceStyle = InputDeviceStyle.Unknown;
			LastInputTypeChangedTick = 0;
			IsSetup = false;
			OnSetupCompleted = null;
			OnDeviceAttached = null;
			OnDeviceDetached = null;
			OnActiveDeviceChanged = null;
		}

		[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
		private static void InitializeBeforeSceneLoad()
		{
			Initialize();
		}

		public static void Initialize()
		{
			if (IsSetup)
			{
				return;
			}
			UnityInputSystem.onDeviceChange += HandleDeviceChange;
			UnityInputSystem.onAfterUpdate += HandleAfterUpdate;
			// Project-wide actions are the source templates. Runtime action sets use private
			// map instances (the same isolation model used by PlayerInput) so legacy rebinding
			// cannot mutate the imported asset or another temporary UI action set.
			UnityInputSystem.actions?.Disable();
			foreach (Gamepad gamepad in Gamepad.all)
			{
				AttachGamepad(gamepad);
			}
			IsSetup = true;
			OnSetupCompleted?.Invoke();
		}

		internal static NativeInputActionMap CreateActionMapInstance(string actionMapName)
		{
			Initialize();
			if (!string.IsNullOrWhiteSpace(actionMapName))
			{
				NativeInputActionMap template = UnityInputSystem.actions?.FindActionMap(actionMapName, throwIfNotFound: false);
				if (template != null)
				{
					return template.Clone();
				}
				Debug.LogWarning($"Project-wide Input Actions map '{actionMapName}' was not found. A runtime fallback map was created.");
			}
			return new NativeInputActionMap(string.IsNullOrWhiteSpace(actionMapName) ? "Runtime" : actionMapName);
		}

		internal static void AttachPlayerActionSet(PlayerActionSet actionSet)
		{
			Initialize();
			if (actionSet != null)
			{
				actionSets.Add(actionSet);
			}
		}

		internal static void DetachPlayerActionSet(PlayerActionSet actionSet)
		{
			if (actionSet == null)
			{
				return;
			}
			if (actionSet.ListeningAction != null)
			{
				StopListening(actionSet.ListeningAction);
			}
			actionSets.Remove(actionSet);
		}

		internal static void StartListening(PlayerAction action)
		{
			if (action == null)
			{
				return;
			}
			Initialize();
			if (listeningAction != null && listeningAction != action)
			{
				StopListening(listeningAction);
			}
			listeningAction = action;
			action.Owner.ListeningAction = action;
			listeningCandidate = null;
			listeningDevice = null;
			listeningPhase = 0;
		}

		internal static void StopListening(PlayerAction action)
		{
			if (action == null || listeningAction != action)
			{
				return;
			}
			BindingListenOptions options = action.EffectiveListenOptions;
			action.Owner.ListeningAction = null;
			listeningAction = null;
			listeningCandidate = null;
			listeningDevice = null;
			listeningPhase = 0;
			options.CallOnBindingEnded(action);
		}

		private static void HandleAfterUpdate()
		{
			if (!IsSetup || lastPolledFrame == Time.frameCount)
			{
				return;
			}
			lastPolledFrame = Time.frameCount;
			currentTick++;
			for (int i = 0; i < devices.Count; i++)
			{
				devices[i].CaptureInputState();
			}
			PollLastActiveInput();
			PollPlayerActionSets();
			PollBindingListener();
		}

		private static void HandleDeviceChange(NewInputDevice device, InputDeviceChange change)
		{
			if (!(device is Gamepad gamepad))
			{
				return;
			}
			switch (change)
			{
			case InputDeviceChange.Added:
			case InputDeviceChange.Reconnected:
			case InputDeviceChange.Enabled:
				AttachGamepad(gamepad);
				break;
			case InputDeviceChange.Disconnected:
			case InputDeviceChange.Removed:
			case InputDeviceChange.Disabled:
				DetachGamepad(gamepad);
				break;
			}
		}

		private static void AttachGamepad(Gamepad gamepad)
		{
			if (gamepad == null || devicesById.ContainsKey(gamepad.deviceId))
			{
				return;
			}
			InputDevice device = new InputDevice(gamepad);
			devicesById.Add(gamepad.deviceId, device);
			devices.Add(device);
			devices.Sort((left, right) => left.Gamepad.deviceId.CompareTo(right.Gamepad.deviceId));
			OnDeviceAttached?.Invoke(device);
		}

		private static void DetachGamepad(Gamepad gamepad)
		{
			if (gamepad == null || !devicesById.TryGetValue(gamepad.deviceId, out InputDevice device))
			{
				return;
			}
			device.StopVibration();
			devicesById.Remove(gamepad.deviceId);
			devices.Remove(device);
			if (activeDevice == device)
			{
				SetActiveDevice(InputDevice.Null);
			}
			OnDeviceDetached?.Invoke(device);
		}

		private static void PollLastActiveInput()
		{
			Keyboard keyboard = Keyboard.current;
			if (keyboard != null && keyboard.anyKey.wasPressedThisFrame)
			{
				SetLastInput(BindingSourceType.KeyBindingSource, InputDeviceClass.Keyboard, InputDeviceStyle.Unknown);
			}

			NewMouse mouse = NewMouse.current;
			if (mouse != null && MouseHadActivity(mouse))
			{
				SetLastInput(BindingSourceType.MouseBindingSource, InputDeviceClass.Mouse, InputDeviceStyle.Unknown);
			}

			InputDevice selectedDevice = ActiveDevice;
			if (selectedDevice == InputDevice.Null || !selectedDevice.IsAttached || !selectedDevice.HasInput)
			{
				selectedDevice = null;
				foreach (InputDevice device in devices)
				{
					if (device.HasInput)
					{
						selectedDevice = device;
						break;
					}
				}
			}
			if (selectedDevice != null && selectedDevice != InputDevice.Null)
			{
				SetActiveDevice(selectedDevice);
				SetLastInput(BindingSourceType.DeviceBindingSource, InputDeviceClass.Controller, selectedDevice.DeviceStyle);
			}
		}

		private static bool MouseHadActivity(NewMouse mouse)
		{
			return mouse.leftButton.wasPressedThisFrame || mouse.rightButton.wasPressedThisFrame ||
				mouse.middleButton.wasPressedThisFrame || mouse.backButton.wasPressedThisFrame ||
				mouse.forwardButton.wasPressedThisFrame || mouse.scroll.ReadValue().sqrMagnitude > 0.0001f ||
				mouse.delta.ReadValue().sqrMagnitude > 1f;
		}

		private static void PollPlayerActionSets()
		{
			foreach (PlayerActionSet actionSet in actionSets)
			{
				actionSet.PollInputActivity();
			}
		}

		private static void SetActiveDevice(InputDevice device)
		{
			device ??= InputDevice.Null;
			if (activeDevice == device)
			{
				return;
			}
			activeDevice = device;
			OnActiveDeviceChanged?.Invoke(activeDevice);
		}

		private static void SetLastInput(BindingSourceType type, InputDeviceClass deviceClass, InputDeviceStyle deviceStyle)
		{
			if (LastInputType == type && LastDeviceClass == deviceClass && LastDeviceStyle == deviceStyle)
			{
				return;
			}
			LastInputType = type;
			LastDeviceClass = deviceClass;
			LastDeviceStyle = deviceStyle;
			LastInputTypeChangedTick = currentTick;
		}

		private static void PollBindingListener()
		{
			PlayerAction action = listeningAction;
			if (action == null || !action.IsListeningForBinding)
			{
				return;
			}
			BindingListenOptions options = action.EffectiveListenOptions;
			if (listeningPhase == 2)
			{
				if (!IsCandidatePressed(listeningCandidate, listeningDevice))
				{
					BindingSource candidate = listeningCandidate;
					listeningCandidate = null;
					listeningDevice = null;
					listeningPhase = 0;
					ProcessCandidate(action, options, candidate);
				}
				return;
			}

			BindingSource detected = DetectPressedCandidate(options, out InputDevice detectedDevice);
			if (listeningPhase == 0)
			{
				if (detected == null)
				{
					listeningPhase = 1;
				}
				return;
			}
			if (detected != null)
			{
				listeningCandidate = detected;
				listeningDevice = detectedDevice;
				listeningPhase = 2;
			}
		}

		private static BindingSource DetectPressedCandidate(BindingListenOptions options, out InputDevice detectedDevice)
		{
			detectedDevice = null;
			if (options.IncludeControllers)
			{
				InputDevice device = ActiveDevice;
				if (device != InputDevice.Null)
				{
					foreach (InputControlType controlType in RebindableControllerControls)
					{
						if (!options.IncludeNonStandardControls && !IsStandardControl(controlType))
						{
							continue;
						}
						if (device.GetControl(controlType).Value > 0.5f)
						{
							detectedDevice = device;
							return new DeviceBindingSource(controlType);
						}
					}
				}
			}

			if (options.IncludeKeys && Keyboard.current != null)
			{
				foreach (KeyControl keyControl in Keyboard.current.allKeys)
				{
					if (keyControl.isPressed && KeyMapper.TryFromInputSystemKey(keyControl.keyCode, out Key key))
					{
						return new KeyBindingSource(key);
					}
				}
			}

			if (options.IncludeMouseButtons && NewMouse.current != null)
			{
				for (Mouse control = Mouse.LeftButton; control <= Mouse.Button5; control++)
				{
					ButtonControl button = MouseBindingSource.GetButton(NewMouse.current, control);
					if (button != null && button.isPressed)
					{
						return new MouseBindingSource(control);
					}
				}
			}

			if (options.IncludeMouseScrollWheel && NewMouse.current != null)
			{
				Vector2 scroll = NewMouse.current.scroll.ReadValue();
				float primary = Mathf.Abs(scroll.x) > Mathf.Abs(scroll.y) ? scroll.x : scroll.y;
				if (primary > 0.001f)
				{
					return new MouseBindingSource(Mouse.PositiveScrollWheel);
				}
				if (primary < -0.001f)
				{
					return new MouseBindingSource(Mouse.NegativeScrollWheel);
				}
			}
			return null;
		}

		private static bool IsCandidatePressed(BindingSource candidate, InputDevice device)
		{
			if (candidate == null)
			{
				return false;
			}
			return candidate.GetState(device ?? ActiveDevice);
		}

		private static void ProcessCandidate(PlayerAction action, BindingListenOptions options, BindingSource candidate)
		{
			if (action == null || candidate == null || listeningAction != action || !options.CallOnBindingFound(action, candidate))
			{
				return;
			}
			if (action.HasBinding(candidate))
			{
				if (options.RejectRedundantBindings)
				{
					options.CallOnBindingRejected(action, candidate, BindingSourceRejectionType.DuplicateBindingOnAction);
					return;
				}
				StopListening(action);
				options.CallOnBindingAdded(action, candidate);
				return;
			}

			if (options.UnsetDuplicateBindingsOnSet)
			{
				foreach (PlayerAction otherAction in action.Owner.Actions)
				{
					otherAction.RemoveBinding(candidate);
				}
			}
			if (!options.AllowDuplicateBindingsPerSet && action.Owner.HasBinding(candidate))
			{
				options.CallOnBindingRejected(action, candidate, BindingSourceRejectionType.DuplicateBindingOnActionSet);
				return;
			}

			StopListening(action);
			if (options.ReplaceBinding == null)
			{
				if (options.MaxAllowedBindingsPerType != 0)
				{
					while ((uint)action.Bindings.Count(binding => binding.BindingSourceType == candidate.BindingSourceType) >= options.MaxAllowedBindingsPerType)
					{
						BindingSource first = action.Bindings.First(binding => binding.BindingSourceType == candidate.BindingSourceType);
						action.RemoveBinding(first);
					}
				}
				else if (options.MaxAllowedBindings != 0)
				{
					while ((uint)action.Bindings.Count >= options.MaxAllowedBindings)
					{
						action.RemoveBinding(action.Bindings[0]);
					}
				}
				action.AddBinding(candidate);
			}
			else
			{
				action.ReplaceBinding(options.ReplaceBinding, candidate);
			}
			options.CallOnBindingAdded(action, candidate);
		}

		private static readonly InputControlType[] RebindableControllerControls =
		{
			InputControlType.Action1, InputControlType.Action2, InputControlType.Action3, InputControlType.Action4,
			InputControlType.LeftBumper, InputControlType.RightBumper, InputControlType.LeftTrigger, InputControlType.RightTrigger,
			InputControlType.LeftStickButton, InputControlType.RightStickButton,
			InputControlType.DPadUp, InputControlType.DPadDown, InputControlType.DPadLeft, InputControlType.DPadRight,
			InputControlType.LeftStickUp, InputControlType.LeftStickDown, InputControlType.LeftStickLeft, InputControlType.LeftStickRight,
			InputControlType.RightStickUp, InputControlType.RightStickDown, InputControlType.RightStickLeft, InputControlType.RightStickRight,
			InputControlType.Start, InputControlType.Select, InputControlType.TouchPadButton, InputControlType.Command
		};

		private static bool IsStandardControl(InputControlType controlType)
		{
			return (controlType >= InputControlType.LeftStickUp && controlType <= InputControlType.Action12) ||
				(controlType >= InputControlType.Command && controlType <= InputControlType.RightCommand);
		}
	}
}
