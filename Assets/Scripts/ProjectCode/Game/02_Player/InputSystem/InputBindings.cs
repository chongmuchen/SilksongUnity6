using System;
using System.IO;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.InputSystem.Controls;
using NewKey = UnityEngine.InputSystem.Key;
using NewMouse = UnityEngine.InputSystem.Mouse;

namespace InputSystem
{
	public sealed class BindingListenOptions
	{
		public bool IncludeControllers = true;
		public bool IncludeUnknownControllers;
		public bool IncludeNonStandardControls = true;
		public bool IncludeMouseButtons;
		public bool IncludeMouseScrollWheel;
		public bool IncludeKeys = true;
		public bool IncludeModifiersAsFirstClassKeys;
		public uint MaxAllowedBindings;
		public uint MaxAllowedBindingsPerType;
		public bool AllowDuplicateBindingsPerSet;
		public bool UnsetDuplicateBindingsOnSet;
		public bool RejectRedundantBindings;
		public BindingSource ReplaceBinding;
		public Func<PlayerAction, BindingSource, bool> OnBindingFound;
		public Action<PlayerAction, BindingSource> OnBindingAdded;
		public Action<PlayerAction, BindingSource, BindingSourceRejectionType> OnBindingRejected;
		public Action<PlayerAction> OnBindingEnded;

		internal bool CallOnBindingFound(PlayerAction action, BindingSource binding)
		{
			return OnBindingFound?.Invoke(action, binding) ?? true;
		}

		internal void CallOnBindingAdded(PlayerAction action, BindingSource binding)
		{
			OnBindingAdded?.Invoke(action, binding);
		}

		internal void CallOnBindingRejected(PlayerAction action, BindingSource binding, BindingSourceRejectionType rejection)
		{
			OnBindingRejected?.Invoke(action, binding, rejection);
		}

		internal void CallOnBindingEnded(PlayerAction action)
		{
			OnBindingEnded?.Invoke(action);
		}
	}

	public abstract class BindingSource : IEquatable<BindingSource>
	{
		public abstract string Name { get; }
		public abstract string DeviceName { get; }
		public abstract InputDeviceClass DeviceClass { get; }
		public abstract InputDeviceStyle DeviceStyle { get; }
		public abstract BindingSourceType BindingSourceType { get; }
		internal PlayerAction BoundTo { get; set; }

		public abstract float GetValue(InputDevice inputDevice);
		public abstract bool GetState(InputDevice inputDevice);
		internal virtual float GetPreviousValue(InputDevice inputDevice) => 0f;
		public abstract bool Equals(BindingSource other);
		public abstract void Save(BinaryWriter writer);
		public abstract void Load(BinaryReader reader, ushort dataFormatVersion);

		public override bool Equals(object obj)
		{
			return obj is BindingSource other && Equals(other);
		}

		public override int GetHashCode()
		{
			return HashCode.Combine((int)BindingSourceType, Name);
		}

		public static bool operator ==(BindingSource left, BindingSource right)
		{
			return ReferenceEquals(left, right) || (!ReferenceEquals(left, null) && left.Equals(right));
		}

		public static bool operator !=(BindingSource left, BindingSource right)
		{
			return !(left == right);
		}
	}

	public readonly struct KeyCombo : IEquatable<KeyCombo>
	{
		private readonly Key key;

		public int IncludeCount => key == Key.None ? 0 : 1;

		public KeyCombo(Key key)
		{
			this.key = key;
		}

		public Key GetInclude(int index)
		{
			if (index != 0 || key == Key.None)
			{
				throw new ArgumentOutOfRangeException(nameof(index));
			}
			return key;
		}

		public bool Equals(KeyCombo other) => key == other.key;

		public override bool Equals(object obj) => obj is KeyCombo other && Equals(other);

		public override int GetHashCode() => (int)key;

		public override string ToString() => key.ToString();
	}

	public sealed class KeyBindingSource : BindingSource
	{
		public KeyCombo Control { get; private set; }

		public override string Name => Control.ToString();
		public override string DeviceName => "Keyboard";
		public override InputDeviceClass DeviceClass => InputDeviceClass.Keyboard;
		public override InputDeviceStyle DeviceStyle => InputDeviceStyle.Unknown;
		public override BindingSourceType BindingSourceType => BindingSourceType.KeyBindingSource;

		private Key MappedKey => Control.IncludeCount == 1 ? Control.GetInclude(0) : Key.None;

		public KeyBindingSource(Key key)
		{
			Control = new KeyCombo(key);
		}

		public KeyBindingSource(params Key[] keys)
			: this(keys != null && keys.Length > 0 ? keys[0] : Key.None)
		{
		}

		public KeyBindingSource(KeyCombo control)
		{
			Control = control;
		}

		public override float GetValue(InputDevice inputDevice)
		{
			return Read(previousFrame: false);
		}

		internal override float GetPreviousValue(InputDevice inputDevice)
		{
			return Read(previousFrame: true);
		}

		public override bool GetState(InputDevice inputDevice) => GetValue(inputDevice) > 0f;

		public override bool Equals(BindingSource other)
		{
			return other is KeyBindingSource source && Control.Equals(source.Control);
		}

		public override void Save(BinaryWriter writer) => writer.Write((int)MappedKey);

		public override void Load(BinaryReader reader, ushort dataFormatVersion)
		{
			Control = new KeyCombo((Key)reader.ReadInt32());
		}

		private float Read(bool previousFrame)
		{
			Keyboard keyboard = Keyboard.current;
			if (keyboard == null || !KeyMapper.TryGetControls(MappedKey, keyboard, out KeyControl first, out KeyControl second))
			{
				return 0f;
			}
			float firstValue = first == null ? 0f : (previousFrame ? first.ReadValueFromPreviousFrame() : first.ReadValue());
			float secondValue = second == null ? 0f : (previousFrame ? second.ReadValueFromPreviousFrame() : second.ReadValue());
			return Mathf.Max(firstValue, secondValue);
		}
	}

	public sealed class MouseBindingSource : BindingSource
	{
		public Mouse Control { get; private set; }

		public override string Name => Control.ToString();
		public override string DeviceName => "Mouse";
		public override InputDeviceClass DeviceClass => InputDeviceClass.Mouse;
		public override InputDeviceStyle DeviceStyle => InputDeviceStyle.Unknown;
		public override BindingSourceType BindingSourceType => BindingSourceType.MouseBindingSource;

		public MouseBindingSource(Mouse control)
		{
			Control = control;
		}

		public override float GetValue(InputDevice inputDevice) => Read(previousFrame: false);

		internal override float GetPreviousValue(InputDevice inputDevice) => Read(previousFrame: true);

		public override bool GetState(InputDevice inputDevice) => Mathf.Abs(GetValue(inputDevice)) > 0f;

		public override bool Equals(BindingSource other)
		{
			return other is MouseBindingSource source && Control == source.Control;
		}

		public override void Save(BinaryWriter writer) => writer.Write((int)Control);

		public override void Load(BinaryReader reader, ushort dataFormatVersion)
		{
			Control = (Mouse)reader.ReadInt32();
		}

		private float Read(bool previousFrame)
		{
			NewMouse mouse = NewMouse.current;
			if (mouse == null)
			{
				return 0f;
			}
			ButtonControl button = GetButton(mouse, Control);
			if (button != null)
			{
				return previousFrame ? button.ReadValueFromPreviousFrame() : button.ReadValue();
			}
			Vector2 delta = previousFrame ? mouse.delta.ReadValueFromPreviousFrame() : mouse.delta.ReadValue();
			Vector2 scroll = previousFrame ? mouse.scroll.ReadValueFromPreviousFrame() : mouse.scroll.ReadValue();
			switch (Control)
			{
			case Mouse.NegativeX:
				return Mathf.Max(0f, -delta.x);
			case Mouse.PositiveX:
				return Mathf.Max(0f, delta.x);
			case Mouse.NegativeY:
				return Mathf.Max(0f, -delta.y);
			case Mouse.PositiveY:
				return Mathf.Max(0f, delta.y);
			case Mouse.PositiveScrollWheel:
				return Mathf.Max(0f, Mathf.Abs(scroll.x) > Mathf.Abs(scroll.y) ? scroll.x : scroll.y);
			case Mouse.NegativeScrollWheel:
				return Mathf.Max(0f, -(Mathf.Abs(scroll.x) > Mathf.Abs(scroll.y) ? scroll.x : scroll.y));
			default:
				return 0f;
			}
		}

		internal static ButtonControl GetButton(NewMouse mouse, Mouse control)
		{
			switch (control)
			{
			case Mouse.LeftButton:
				return mouse.leftButton;
			case Mouse.RightButton:
				return mouse.rightButton;
			case Mouse.MiddleButton:
				return mouse.middleButton;
			case Mouse.Button4:
				return mouse.backButton;
			case Mouse.Button5:
				return mouse.forwardButton;
			default:
				return null;
			}
		}
	}

	public sealed class DeviceBindingSource : BindingSource
	{
		public InputControlType Control { get; private set; }

		public override string Name => Control.ToString();
		public override string DeviceName => (BoundTo?.Device ?? InputManager.ActiveDevice)?.Name ?? "Controller";
		public override InputDeviceClass DeviceClass => InputDeviceClass.Controller;
		public override InputDeviceStyle DeviceStyle => (BoundTo?.Device ?? InputManager.ActiveDevice)?.DeviceStyle ?? InputDeviceStyle.Unknown;
		public override BindingSourceType BindingSourceType => BindingSourceType.DeviceBindingSource;

		public DeviceBindingSource(InputControlType control)
		{
			Control = control;
		}

		public override float GetValue(InputDevice inputDevice)
		{
			return ResolveDevice(inputDevice).GetControl(Control).Value;
		}

		internal override float GetPreviousValue(InputDevice inputDevice)
		{
			return ResolveDevice(inputDevice).GetControl(Control).PreviousValue;
		}

		public override bool GetState(InputDevice inputDevice) => ResolveDevice(inputDevice).GetControl(Control).IsPressed;

		public override bool Equals(BindingSource other)
		{
			return other is DeviceBindingSource source && Control == source.Control;
		}

		public override void Save(BinaryWriter writer) => writer.Write((int)Control);

		public override void Load(BinaryReader reader, ushort dataFormatVersion)
		{
			Control = (InputControlType)reader.ReadInt32();
		}

		private static InputDevice ResolveDevice(InputDevice inputDevice)
		{
			return inputDevice == null || inputDevice == InputDevice.Null ? InputManager.ActiveDevice : inputDevice;
		}
	}

	internal static class KeyMapper
	{
		internal static bool TryGetControls(Key key, Keyboard keyboard, out KeyControl first, out KeyControl second)
		{
			first = null;
			second = null;
			if (keyboard == null || !TryToInputSystemKey(key, out NewKey firstKey, out NewKey secondKey))
			{
				return false;
			}
			if (firstKey != NewKey.None)
			{
				first = keyboard[firstKey];
			}
			if (secondKey != NewKey.None)
			{
				second = keyboard[secondKey];
			}
			return first != null || second != null;
		}

		internal static bool TryFromInputSystemKey(NewKey key, out Key result)
		{
			result = Key.None;
			if (key >= NewKey.Digit0 && key <= NewKey.Digit9)
			{
				result = (Key)((int)Key.Key0 + ((int)key - (int)NewKey.Digit0));
				return true;
			}
			if (key >= NewKey.Numpad0 && key <= NewKey.Numpad9)
			{
				result = (Key)((int)Key.Pad0 + ((int)key - (int)NewKey.Numpad0));
				return true;
			}
			switch (key)
			{
			case NewKey.Enter: result = Key.Return; return true;
			case NewKey.LeftCtrl: result = Key.LeftControl; return true;
			case NewKey.RightCtrl: result = Key.RightControl; return true;
			case NewKey.LeftMeta: result = Key.LeftCommand; return true;
			case NewKey.RightMeta: result = Key.RightCommand; return true;
			case NewKey.NumLock: result = Key.Numlock; return true;
			case NewKey.NumpadDivide: result = Key.PadDivide; return true;
			case NewKey.NumpadMultiply: result = Key.PadMultiply; return true;
			case NewKey.NumpadMinus: result = Key.PadMinus; return true;
			case NewKey.NumpadPlus: result = Key.PadPlus; return true;
			case NewKey.NumpadEnter: result = Key.PadEnter; return true;
			case NewKey.NumpadPeriod: result = Key.PadPeriod; return true;
			case NewKey.NumpadEquals: result = Key.PadEquals; return true;
			default:
				return Enum.TryParse(key.ToString(), out result) && result != Key.None;
			}
		}

		private static bool TryToInputSystemKey(Key key, out NewKey first, out NewKey second)
		{
			first = NewKey.None;
			second = NewKey.None;
			if (key >= Key.Key0 && key <= Key.Key9)
			{
				first = (NewKey)((int)NewKey.Digit0 + ((int)key - (int)Key.Key0));
				return true;
			}
			if (key >= Key.Pad0 && key <= Key.Pad9)
			{
				first = (NewKey)((int)NewKey.Numpad0 + ((int)key - (int)Key.Pad0));
				return true;
			}
			switch (key)
			{
			case Key.None: return false;
			case Key.Shift: first = NewKey.LeftShift; second = NewKey.RightShift; return true;
			case Key.Alt: first = NewKey.LeftAlt; second = NewKey.RightAlt; return true;
			case Key.Command: first = NewKey.LeftMeta; second = NewKey.RightMeta; return true;
			case Key.Control: first = NewKey.LeftCtrl; second = NewKey.RightCtrl; return true;
			case Key.LeftControl: first = NewKey.LeftCtrl; return true;
			case Key.RightControl: first = NewKey.RightCtrl; return true;
			case Key.LeftCommand: first = NewKey.LeftMeta; return true;
			case Key.RightCommand: first = NewKey.RightMeta; return true;
			case Key.Return: first = NewKey.Enter; return true;
			case Key.Numlock: first = NewKey.NumLock; return true;
			case Key.PadDivide: first = NewKey.NumpadDivide; return true;
			case Key.PadMultiply: first = NewKey.NumpadMultiply; return true;
			case Key.PadMinus: first = NewKey.NumpadMinus; return true;
			case Key.PadPlus: first = NewKey.NumpadPlus; return true;
			case Key.PadEnter: first = NewKey.NumpadEnter; return true;
			case Key.PadPeriod: first = NewKey.NumpadPeriod; return true;
			case Key.PadEquals: first = NewKey.NumpadEquals; return true;
			case Key.AltGr: first = NewKey.RightAlt; return true;
			default:
				return Enum.TryParse(key.ToString(), out first) && first != NewKey.None;
			}
		}
	}
}
