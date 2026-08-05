using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Controls;
using UnityEngine.InputSystem.DualShock;
using UnityEngine.InputSystem.Switch;
using UnityEngine.InputSystem.XInput;
using NewInputControl = UnityEngine.InputSystem.InputControl;
using NewInputDevice = UnityEngine.InputSystem.InputDevice;

namespace TeamCherry.Input
{
	public class InputControl
	{
		private readonly Func<float> readValue;
		private readonly Func<float> readPreviousValue;

		public float StateThreshold { get; set; }

		public float LowerDeadZone { get; set; }

		public float UpperDeadZone { get; set; } = 1f;

		public float Value => ApplyDeadZone(RawValue);

		public float RawValue => readValue?.Invoke() ?? 0f;

		public bool IsPressed => Mathf.Abs(Value) > StateThreshold;

		public bool WasPressed => Mathf.Abs(Value) > StateThreshold && Mathf.Abs(PreviousValue) <= StateThreshold;

		public bool WasReleased => Mathf.Abs(Value) <= StateThreshold && Mathf.Abs(PreviousValue) > StateThreshold;

		internal float PreviousValue => ApplyDeadZone(readPreviousValue?.Invoke() ?? 0f);

		internal InputControl(Func<float> readValue, Func<float> readPreviousValue)
		{
			this.readValue = readValue;
			this.readPreviousValue = readPreviousValue;
		}

		private float ApplyDeadZone(float value)
		{
			float magnitude = Mathf.Abs(value);
			if (magnitude <= LowerDeadZone)
			{
				return 0f;
			}
			if (UpperDeadZone <= LowerDeadZone || magnitude >= UpperDeadZone)
			{
				return Mathf.Sign(value);
			}
			return Mathf.Sign(value) * Mathf.InverseLerp(LowerDeadZone, UpperDeadZone, magnitude);
		}
	}

	public class TwoAxisInputControl
	{
		private readonly Func<Vector2> readValue;
		private readonly Func<Vector2> readPreviousValue;
		private Vector2 filteredValue;
		private Vector2 filteredPreviousValue;
		private bool usesFilteredValue;

		public float StateThreshold { get; set; }

		public virtual float LowerDeadZone { get; set; }

		public virtual float UpperDeadZone { get; set; } = 1f;

		public virtual Vector2 Value => ApplyDeadZone(usesFilteredValue ? filteredValue : (readValue?.Invoke() ?? Vector2.zero));

		public Vector2 Vector => Value;

		public float X => Value.x;

		public float Y => Value.y;

		public bool IsPressed => Value.sqrMagnitude > StateThreshold * StateThreshold;

		public bool WasPressed => Value.sqrMagnitude > StateThreshold * StateThreshold && PreviousValue.sqrMagnitude <= StateThreshold * StateThreshold;

		public bool WasReleased => Value.sqrMagnitude <= StateThreshold * StateThreshold && PreviousValue.sqrMagnitude > StateThreshold * StateThreshold;

		protected virtual Vector2 PreviousValue => ApplyDeadZone(usesFilteredValue ? filteredPreviousValue : (readPreviousValue?.Invoke() ?? Vector2.zero));

		public TwoAxisInputControl()
		{
		}

		internal TwoAxisInputControl(Func<Vector2> readValue, Func<Vector2> readPreviousValue)
		{
			this.readValue = readValue;
			this.readPreviousValue = readPreviousValue;
		}

		public void Filter(TwoAxisInputControl source, float deltaTime)
		{
			usesFilteredValue = true;
			filteredPreviousValue = filteredValue;
			filteredValue = source?.Value ?? Vector2.zero;
		}

		protected Vector2 ApplyDeadZone(Vector2 value)
		{
			float magnitude = value.magnitude;
			if (magnitude <= LowerDeadZone)
			{
				return Vector2.zero;
			}
			if (UpperDeadZone <= LowerDeadZone || magnitude >= UpperDeadZone)
			{
				return magnitude > Mathf.Epsilon ? value / magnitude : Vector2.zero;
			}
			float normalizedMagnitude = Mathf.InverseLerp(LowerDeadZone, UpperDeadZone, magnitude);
			return value.normalized * normalizedMagnitude;
		}
	}

	public sealed class InputDevice : IEquatable<InputDevice>
	{
		private readonly Gamepad gamepad;
		private readonly Dictionary<InputControlType, InputControl> controls = new Dictionary<InputControlType, InputControl>();
		private Vector2 leftStickValue;
		private Vector2 previousLeftStickValue;
		private Vector2 rightStickValue;
		private Vector2 previousRightStickValue;
		private Vector2 dpadValue;
		private Vector2 previousDpadValue;
		private float leftTriggerValue;
		private float previousLeftTriggerValue;
		private float rightTriggerValue;
		private float previousRightTriggerValue;

		public static readonly InputDevice Null = new InputDevice(null);

		internal Gamepad Gamepad => gamepad;

		public string Name => gamepad?.displayName ?? gamepad?.description.product ?? "Controller";

		public bool IsAttached => gamepad != null && gamepad.added;

		public bool IsUnknown => gamepad == null;

		public InputDeviceClass DeviceClass => gamepad == null ? InputDeviceClass.Unknown : InputDeviceClass.Controller;

		public InputDeviceStyle DeviceStyle => DetectStyle(gamepad);

		public TwoAxisInputControl LeftStick { get; }

		public TwoAxisInputControl RightStick { get; }

		public TwoAxisInputControl DPad { get; }

		public TwoAxisInputControl Direction { get; }

		public InputControl AnyButton { get; }

		public InputControl Action1 => GetControl(InputControlType.Action1);

		public InputControl Action2 => GetControl(InputControlType.Action2);

		public InputControl Action3 => GetControl(InputControlType.Action3);

		public InputControl Action4 => GetControl(InputControlType.Action4);

		public InputControl DPadUp => GetControl(InputControlType.DPadUp);

		public InputControl DPadDown => GetControl(InputControlType.DPadDown);

		public InputControl DPadLeft => GetControl(InputControlType.DPadLeft);

		public InputControl DPadRight => GetControl(InputControlType.DPadRight);

		public InputControl LeftBumper => GetControl(InputControlType.LeftBumper);

		public InputControl RightBumper => GetControl(InputControlType.RightBumper);

		public InputControl LeftTrigger => GetControl(InputControlType.LeftTrigger);

		public InputControl RightTrigger => GetControl(InputControlType.RightTrigger);

		public bool AnyButtonIsPressed => AnyButton.IsPressed;

		public bool AnyButtonWasPressed => AnyButton.WasPressed;

		public bool AnyButtonWasReleased => AnyButton.WasReleased;

		internal InputDevice(Gamepad gamepad)
		{
			this.gamepad = gamepad;
			CaptureInputState(advancePrevious: false);
			LeftStick = new TwoAxisInputControl(() => leftStickValue, () => previousLeftStickValue)
			{
				LowerDeadZone = 0.2f,
				UpperDeadZone = 0.9f
			};
			RightStick = new TwoAxisInputControl(() => rightStickValue, () => previousRightStickValue)
			{
				LowerDeadZone = 0.2f,
				UpperDeadZone = 0.9f
			};
			DPad = new TwoAxisInputControl(() => dpadValue, () => previousDpadValue)
			{
				LowerDeadZone = 0.2f,
				UpperDeadZone = 0.9f
			};
			Direction = new TwoAxisInputControl(ReadDirection, ReadPreviousDirection);
			AnyButton = new InputControl(ReadAnyButton, ReadPreviousAnyButton);
		}

		internal void CaptureInputState(bool advancePrevious = true)
		{
			Vector2 newLeftStick = gamepad?.leftStick.ReadUnprocessedValue() ?? Vector2.zero;
			Vector2 newRightStick = gamepad?.rightStick.ReadUnprocessedValue() ?? Vector2.zero;
			Vector2 newDpad = gamepad?.dpad.ReadUnprocessedValue() ?? Vector2.zero;
			float newLeftTrigger = gamepad?.leftTrigger.ReadUnprocessedValue() ?? 0f;
			float newRightTrigger = gamepad?.rightTrigger.ReadUnprocessedValue() ?? 0f;
			previousLeftStickValue = advancePrevious ? leftStickValue : newLeftStick;
			previousRightStickValue = advancePrevious ? rightStickValue : newRightStick;
			previousDpadValue = advancePrevious ? dpadValue : newDpad;
			previousLeftTriggerValue = advancePrevious ? leftTriggerValue : newLeftTrigger;
			previousRightTriggerValue = advancePrevious ? rightTriggerValue : newRightTrigger;
			leftStickValue = newLeftStick;
			rightStickValue = newRightStick;
			dpadValue = newDpad;
			leftTriggerValue = newLeftTrigger;
			rightTriggerValue = newRightTrigger;
		}

		internal bool HasInput
		{
			get
			{
				if (gamepad == null || !gamepad.added)
				{
					return false;
				}
				if (LeftStick.Value.sqrMagnitude > Mathf.Epsilon || RightStick.Value.sqrMagnitude > Mathf.Epsilon ||
					DPad.Value.sqrMagnitude > Mathf.Epsilon || LeftTrigger.Value > Mathf.Epsilon || RightTrigger.Value > Mathf.Epsilon)
				{
					return true;
				}
				foreach (NewInputControl control in gamepad.allControls)
				{
					if (control is ButtonControl button && button.isPressed)
					{
						return true;
					}
				}
				return false;
			}
		}

		public InputControl GetControl(InputControlType controlType)
		{
			if (!controls.TryGetValue(controlType, out InputControl control))
			{
				control = new InputControl(
					() => ReadMappedControlValue(controlType, previousFrame: false),
					() => ReadMappedControlValue(controlType, previousFrame: true));
				if (UsesDeadZone(controlType))
				{
					control.LowerDeadZone = 0.2f;
					control.UpperDeadZone = 0.9f;
				}
				controls.Add(controlType, control);
			}
			return control;
		}

		public void Vibrate(float leftMotor, float rightMotor)
		{
			gamepad?.SetMotorSpeeds(Mathf.Clamp01(leftMotor), Mathf.Clamp01(rightMotor));
		}

		public void Vibrate(float intensity)
		{
			Vibrate(intensity, intensity);
		}

		public void StopVibration()
		{
			gamepad?.ResetHaptics();
		}

		public bool Equals(InputDevice other)
		{
			if (ReferenceEquals(null, other))
			{
				return false;
			}
			return ReferenceEquals(gamepad, other.gamepad);
		}

		public override bool Equals(object obj)
		{
			return obj is InputDevice other && Equals(other);
		}

		public override int GetHashCode()
		{
			return gamepad != null ? gamepad.deviceId : 0;
		}

		public static bool operator ==(InputDevice left, InputDevice right)
		{
			return ReferenceEquals(left, right) || (!ReferenceEquals(left, null) && left.Equals(right));
		}

		public static bool operator !=(InputDevice left, InputDevice right)
		{
			return !(left == right);
		}

		internal static NewInputControl ResolveControl(Gamepad source, InputControlType controlType)
		{
			if (source == null)
			{
				return null;
			}
			switch (controlType)
			{
			case InputControlType.LeftStickUp:
				return source.leftStick.up;
			case InputControlType.LeftStickDown:
				return source.leftStick.down;
			case InputControlType.LeftStickLeft:
				return source.leftStick.left;
			case InputControlType.LeftStickRight:
				return source.leftStick.right;
			case InputControlType.LeftStickButton:
				return source.leftStickButton;
			case InputControlType.RightStickUp:
				return source.rightStick.up;
			case InputControlType.RightStickDown:
				return source.rightStick.down;
			case InputControlType.RightStickLeft:
				return source.rightStick.left;
			case InputControlType.RightStickRight:
				return source.rightStick.right;
			case InputControlType.RightStickButton:
				return source.rightStickButton;
			case InputControlType.DPadUp:
				return source.dpad.up;
			case InputControlType.DPadDown:
				return source.dpad.down;
			case InputControlType.DPadLeft:
				return source.dpad.left;
			case InputControlType.DPadRight:
				return source.dpad.right;
			case InputControlType.LeftTrigger:
				return source.leftTrigger;
			case InputControlType.RightTrigger:
				return source.rightTrigger;
			case InputControlType.LeftBumper:
				return source.leftShoulder;
			case InputControlType.RightBumper:
				return source.rightShoulder;
			case InputControlType.Action1:
				return source.buttonSouth;
			case InputControlType.Action2:
				return source.buttonEast;
			case InputControlType.Action3:
				return source.buttonWest;
			case InputControlType.Action4:
				return source.buttonNorth;
			case InputControlType.Back:
			case InputControlType.Select:
			case InputControlType.Share:
			case InputControlType.View:
			case InputControlType.Minus:
			case InputControlType.Create:
				return source.selectButton;
			case InputControlType.Start:
			case InputControlType.Options:
			case InputControlType.Pause:
			case InputControlType.Menu:
			case InputControlType.Plus:
				return source.startButton;
			case InputControlType.System:
			case InputControlType.Home:
			case InputControlType.Guide:
			case InputControlType.Command:
				return source.TryGetChildControl<ButtonControl>("systemButton") ?? source.startButton;
			case InputControlType.TouchPadButton:
				return source.TryGetChildControl<ButtonControl>("touchpadButton");
			case InputControlType.LeftStickX:
				return source.leftStick.x;
			case InputControlType.LeftStickY:
				return source.leftStick.y;
			case InputControlType.RightStickX:
				return source.rightStick.x;
			case InputControlType.RightStickY:
				return source.rightStick.y;
			case InputControlType.DPadX:
				return source.dpad.x;
			case InputControlType.DPadY:
				return source.dpad.y;
			default:
				return null;
			}
		}

		internal static InputControlType GetControlType(Gamepad source, NewInputControl control)
		{
			if (source == null || control == null)
			{
				return InputControlType.None;
			}
			InputControlType[] candidates =
			{
				InputControlType.Action1, InputControlType.Action2, InputControlType.Action3, InputControlType.Action4,
				InputControlType.LeftBumper, InputControlType.RightBumper, InputControlType.LeftTrigger, InputControlType.RightTrigger,
				InputControlType.LeftStickButton, InputControlType.RightStickButton,
				InputControlType.DPadUp, InputControlType.DPadDown, InputControlType.DPadLeft, InputControlType.DPadRight,
				InputControlType.Start, InputControlType.Select, InputControlType.TouchPadButton
			};
			foreach (InputControlType candidate in candidates)
			{
				if (ReferenceEquals(ResolveControl(source, candidate), control))
				{
					return candidate;
				}
			}
			return InputControlType.None;
		}

		private Vector2 ReadDirection()
		{
			Vector2 stick = LeftStick.Value;
			Vector2 dpad = DPad.Value;
			return dpad.sqrMagnitude > stick.sqrMagnitude ? dpad : stick;
		}

		private Vector2 ReadPreviousDirection()
		{
			Vector2 stick = ApplyVectorDeadZone(previousLeftStickValue, 0.2f, 0.9f);
			Vector2 dpad = ApplySeparateDeadZone(previousDpadValue, 0.2f, 0.9f);
			return dpad.sqrMagnitude > stick.sqrMagnitude ? dpad : stick;
		}

		private float ReadMappedControlValue(InputControlType controlType, bool previousFrame)
		{
			Vector2 left = ApplyVectorDeadZone(previousFrame ? previousLeftStickValue : leftStickValue, 0.2f, 0.9f);
			Vector2 right = ApplyVectorDeadZone(previousFrame ? previousRightStickValue : rightStickValue, 0.2f, 0.9f);
			Vector2 dpad = ApplySeparateDeadZone(previousFrame ? previousDpadValue : dpadValue, 0.2f, 0.9f);
			switch (controlType)
			{
			case InputControlType.LeftStickUp: return Mathf.Max(0f, left.y);
			case InputControlType.LeftStickDown: return Mathf.Max(0f, -left.y);
			case InputControlType.LeftStickLeft: return Mathf.Max(0f, -left.x);
			case InputControlType.LeftStickRight: return Mathf.Max(0f, left.x);
			case InputControlType.RightStickUp: return Mathf.Max(0f, right.y);
			case InputControlType.RightStickDown: return Mathf.Max(0f, -right.y);
			case InputControlType.RightStickLeft: return Mathf.Max(0f, -right.x);
			case InputControlType.RightStickRight: return Mathf.Max(0f, right.x);
			case InputControlType.DPadUp: return Mathf.Max(0f, dpad.y);
			case InputControlType.DPadDown: return Mathf.Max(0f, -dpad.y);
			case InputControlType.DPadLeft: return Mathf.Max(0f, -dpad.x);
			case InputControlType.DPadRight: return Mathf.Max(0f, dpad.x);
			case InputControlType.LeftTrigger: return previousFrame ? previousLeftTriggerValue : leftTriggerValue;
			case InputControlType.RightTrigger: return previousFrame ? previousRightTriggerValue : rightTriggerValue;
			case InputControlType.LeftStickX: return left.x;
			case InputControlType.LeftStickY: return left.y;
			case InputControlType.RightStickX: return right.x;
			case InputControlType.RightStickY: return right.y;
			case InputControlType.DPadX: return dpad.x;
			case InputControlType.DPadY: return dpad.y;
			case InputControlType.Command:
				return Mathf.Max(ReadControlValue(gamepad?.selectButton, previousFrame), ReadControlValue(gamepad?.startButton, previousFrame));
			case InputControlType.LeftCommand:
				return ReadControlValue(gamepad?.selectButton, previousFrame);
			case InputControlType.RightCommand:
				return ReadControlValue(gamepad?.startButton, previousFrame);
			default:
				NewInputControl control = ResolveControl(gamepad, controlType);
				return ReadControlValue(control, previousFrame);
			}
		}

		private float ReadAnyButton()
		{
			return HasButtonState(previousFrame: false) ? 1f : 0f;
		}

		private float ReadPreviousAnyButton()
		{
			return HasButtonState(previousFrame: true) ? 1f : 0f;
		}

		private bool HasButtonState(bool previousFrame)
		{
			if (gamepad == null)
			{
				return false;
			}
			ButtonControl[] buttons = { gamepad.buttonSouth, gamepad.buttonEast, gamepad.buttonWest, gamepad.buttonNorth };
			foreach (ButtonControl button in buttons)
			{
				float value = previousFrame ? button.ReadValueFromPreviousFrame() : button.ReadValue();
				if (button.IsValueConsideredPressed(value))
				{
					return true;
				}
			}
			return false;
		}

		private static float ReadControlValue(NewInputControl control)
		{
			switch (control)
			{
			case ButtonControl button:
				return button.ReadValue();
			case AxisControl axis:
				return axis.ReadValue();
			default:
				return 0f;
			}
		}

		private static float ReadControlValue(NewInputControl control, bool previousFrame)
		{
			return previousFrame ? ReadPreviousControlValue(control) : ReadControlValue(control);
		}

		private static float ReadPreviousControlValue(NewInputControl control)
		{
			switch (control)
			{
			case ButtonControl button:
				return button.ReadValueFromPreviousFrame();
			case AxisControl axis:
				return axis.ReadValueFromPreviousFrame();
			default:
				return 0f;
			}
		}

		private static InputDeviceStyle DetectStyle(NewInputDevice device)
		{
			if (device == null)
			{
				return InputDeviceStyle.Unknown;
			}
			if (device is DualSenseGamepadHID)
			{
				return InputDeviceStyle.PlayStation5;
			}
			if (device is DualShockGamepad)
			{
				return InputDeviceStyle.PlayStation4;
			}
			if (device is SwitchProControllerHID)
			{
				return InputDeviceStyle.NintendoSwitch;
			}
			if (device is XInputController)
			{
				return InputDeviceStyle.XboxOne;
			}
			string identity = string.Join(" ", device.layout, device.displayName, device.description.interfaceName,
				device.description.manufacturer, device.description.product).ToLowerInvariant();
			if (identity.Contains("dualsense") || identity.Contains("playstation 5") || identity.Contains("ps5"))
			{
				return InputDeviceStyle.PlayStation5;
			}
			if (identity.Contains("dualshock 4") || identity.Contains("playstation 4") || identity.Contains("ps4"))
			{
				return InputDeviceStyle.PlayStation4;
			}
			if (identity.Contains("dualshock 3") || identity.Contains("playstation 3") || identity.Contains("ps3"))
			{
				return InputDeviceStyle.PlayStation3;
			}
			if (identity.Contains("switch") || identity.Contains("nintendo") || identity.Contains("joy-con") || identity.Contains("joycon"))
			{
				return InputDeviceStyle.NintendoSwitch;
			}
			if (identity.Contains("series x") || identity.Contains("series s"))
			{
				return InputDeviceStyle.XboxSeriesX;
			}
			if (identity.Contains("xbox one") || identity.Contains("xinput"))
			{
				return InputDeviceStyle.XboxOne;
			}
			if (identity.Contains("xbox 360"))
			{
				return InputDeviceStyle.Xbox360;
			}
			if (identity.Contains("steam deck"))
			{
				return InputDeviceStyle.SteamDeck;
			}
			if (identity.Contains("stadia"))
			{
				return InputDeviceStyle.GoogleStadia;
			}
			if (identity.Contains("logitech"))
			{
				return InputDeviceStyle.Logitech;
			}
			return InputDeviceStyle.Unknown;
		}

		private static bool UsesDeadZone(InputControlType controlType)
		{
			return controlType == InputControlType.LeftTrigger || controlType == InputControlType.RightTrigger ||
				(controlType >= InputControlType.Analog0 && controlType <= InputControlType.Analog19);
		}

		private static Vector2 ApplyVectorDeadZone(Vector2 value, float lowerDeadZone, float upperDeadZone)
		{
			float magnitude = value.magnitude;
			if (magnitude <= lowerDeadZone)
			{
				return Vector2.zero;
			}
			if (upperDeadZone <= lowerDeadZone || magnitude >= upperDeadZone)
			{
				return value.normalized;
			}
			return value.normalized * Mathf.InverseLerp(lowerDeadZone, upperDeadZone, magnitude);
		}

		private static Vector2 ApplySeparateDeadZone(Vector2 value, float lowerDeadZone, float upperDeadZone)
		{
			float x = ApplyScalarDeadZone(value.x, lowerDeadZone, upperDeadZone);
			float y = ApplyScalarDeadZone(value.y, lowerDeadZone, upperDeadZone);
			Vector2 result = new Vector2(x, y);
			return result.sqrMagnitude > Mathf.Epsilon ? result.normalized : Vector2.zero;
		}

		private static float ApplyScalarDeadZone(float value, float lowerDeadZone, float upperDeadZone)
		{
			float magnitude = Mathf.Abs(value);
			if (magnitude < lowerDeadZone)
			{
				return 0f;
			}
			if (magnitude > upperDeadZone)
			{
				return Mathf.Sign(value);
			}
			return Mathf.Sign(value) * (magnitude - lowerDeadZone) / (upperDeadZone - lowerDeadZone);
		}

	}
}
