using UnityEngine;
using UnityEngine.InputSystem;

namespace InControl
{
	public class UnityKeyboardProvider : IKeyboardProvider
	{
		public readonly struct KeyMapping
		{
			private readonly Key source;

			private readonly UnityEngine.InputSystem.Key target0;

			private readonly UnityEngine.InputSystem.Key target1;

			private readonly string name;

			private readonly string macName;

			public bool IsPressed
			{
				get
				{
					Keyboard current = Keyboard.current;
					if (current != null)
					{
						if (target0 != UnityEngine.InputSystem.Key.None && current[target0].isPressed)
						{
							return true;
						}
						if (target1 != UnityEngine.InputSystem.Key.None && current[target1].isPressed)
						{
							return true;
						}
					}
					return false;
				}
			}

			public string Name
			{
				get
				{
					if (Application.platform == RuntimePlatform.OSXEditor || Application.platform == RuntimePlatform.OSXPlayer)
					{
						return macName;
					}
					return name;
				}
			}

			public KeyMapping(Key source, string name, UnityEngine.InputSystem.Key target)
			{
				this.source = source;
				this.name = name;
				macName = name;
				target0 = target;
				target1 = UnityEngine.InputSystem.Key.None;
			}

			public KeyMapping(Key source, string name, UnityEngine.InputSystem.Key target0, UnityEngine.InputSystem.Key target1)
			{
				this.source = source;
				this.name = name;
				macName = name;
				this.target0 = target0;
				this.target1 = target1;
			}

			public KeyMapping(Key source, string name, string macName, UnityEngine.InputSystem.Key target)
			{
				this.source = source;
				this.name = name;
				this.macName = macName;
				target0 = target;
				target1 = UnityEngine.InputSystem.Key.None;
			}

			public KeyMapping(Key source, string name, string macName, UnityEngine.InputSystem.Key target0, UnityEngine.InputSystem.Key target1)
			{
				this.source = source;
				this.name = name;
				this.macName = macName;
				this.target0 = target0;
				this.target1 = target1;
			}
		}

		public static readonly KeyMapping[] KeyMappings = new KeyMapping[132]
		{
			new KeyMapping(Key.None, "None", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Shift, "Shift", UnityEngine.InputSystem.Key.LeftShift, UnityEngine.InputSystem.Key.RightShift),
			new KeyMapping(Key.Alt, "Alt", "Option", UnityEngine.InputSystem.Key.LeftAlt, UnityEngine.InputSystem.Key.RightAlt),
			new KeyMapping(Key.Command, "Command", UnityEngine.InputSystem.Key.LeftMeta, UnityEngine.InputSystem.Key.RightMeta),
			new KeyMapping(Key.Control, "Control", UnityEngine.InputSystem.Key.LeftCtrl, UnityEngine.InputSystem.Key.RightCtrl),
			new KeyMapping(Key.LeftShift, "Left Shift", UnityEngine.InputSystem.Key.LeftShift),
			new KeyMapping(Key.LeftAlt, "Left Alt", "Left Option", UnityEngine.InputSystem.Key.LeftAlt),
			new KeyMapping(Key.LeftCommand, "Left Command", UnityEngine.InputSystem.Key.LeftMeta),
			new KeyMapping(Key.LeftControl, "Left Control", UnityEngine.InputSystem.Key.LeftCtrl),
			new KeyMapping(Key.RightShift, "Right Shift", UnityEngine.InputSystem.Key.RightShift),
			new KeyMapping(Key.RightAlt, "Right Alt", "Right Option", UnityEngine.InputSystem.Key.RightAlt),
			new KeyMapping(Key.RightCommand, "Right Command", UnityEngine.InputSystem.Key.RightMeta),
			new KeyMapping(Key.RightControl, "Right Control", UnityEngine.InputSystem.Key.RightCtrl),
			new KeyMapping(Key.Escape, "Escape", UnityEngine.InputSystem.Key.Escape),
			new KeyMapping(Key.F1, "F1", UnityEngine.InputSystem.Key.F1),
			new KeyMapping(Key.F2, "F2", UnityEngine.InputSystem.Key.F2),
			new KeyMapping(Key.F3, "F3", UnityEngine.InputSystem.Key.F3),
			new KeyMapping(Key.F4, "F4", UnityEngine.InputSystem.Key.F4),
			new KeyMapping(Key.F5, "F5", UnityEngine.InputSystem.Key.F5),
			new KeyMapping(Key.F6, "F6", UnityEngine.InputSystem.Key.F6),
			new KeyMapping(Key.F7, "F7", UnityEngine.InputSystem.Key.F7),
			new KeyMapping(Key.F8, "F8", UnityEngine.InputSystem.Key.F8),
			new KeyMapping(Key.F9, "F9", UnityEngine.InputSystem.Key.F9),
			new KeyMapping(Key.F10, "F10", UnityEngine.InputSystem.Key.F10),
			new KeyMapping(Key.F11, "F11", UnityEngine.InputSystem.Key.F11),
			new KeyMapping(Key.F12, "F12", UnityEngine.InputSystem.Key.F12),
			new KeyMapping(Key.Key0, "0", UnityEngine.InputSystem.Key.Digit0),
			new KeyMapping(Key.Key1, "1", UnityEngine.InputSystem.Key.Digit1),
			new KeyMapping(Key.Key2, "2", UnityEngine.InputSystem.Key.Digit2),
			new KeyMapping(Key.Key3, "3", UnityEngine.InputSystem.Key.Digit3),
			new KeyMapping(Key.Key4, "4", UnityEngine.InputSystem.Key.Digit4),
			new KeyMapping(Key.Key5, "5", UnityEngine.InputSystem.Key.Digit5),
			new KeyMapping(Key.Key6, "6", UnityEngine.InputSystem.Key.Digit6),
			new KeyMapping(Key.Key7, "7", UnityEngine.InputSystem.Key.Digit7),
			new KeyMapping(Key.Key8, "8", UnityEngine.InputSystem.Key.Digit8),
			new KeyMapping(Key.Key9, "9", UnityEngine.InputSystem.Key.Digit9),
			new KeyMapping(Key.A, "A", UnityEngine.InputSystem.Key.A),
			new KeyMapping(Key.B, "B", UnityEngine.InputSystem.Key.B),
			new KeyMapping(Key.C, "C", UnityEngine.InputSystem.Key.C),
			new KeyMapping(Key.D, "D", UnityEngine.InputSystem.Key.D),
			new KeyMapping(Key.E, "E", UnityEngine.InputSystem.Key.E),
			new KeyMapping(Key.F, "F", UnityEngine.InputSystem.Key.F),
			new KeyMapping(Key.G, "G", UnityEngine.InputSystem.Key.G),
			new KeyMapping(Key.H, "H", UnityEngine.InputSystem.Key.H),
			new KeyMapping(Key.I, "I", UnityEngine.InputSystem.Key.I),
			new KeyMapping(Key.J, "J", UnityEngine.InputSystem.Key.J),
			new KeyMapping(Key.K, "K", UnityEngine.InputSystem.Key.K),
			new KeyMapping(Key.L, "L", UnityEngine.InputSystem.Key.L),
			new KeyMapping(Key.M, "M", UnityEngine.InputSystem.Key.M),
			new KeyMapping(Key.N, "N", UnityEngine.InputSystem.Key.N),
			new KeyMapping(Key.O, "O", UnityEngine.InputSystem.Key.O),
			new KeyMapping(Key.P, "P", UnityEngine.InputSystem.Key.P),
			new KeyMapping(Key.Q, "Q", UnityEngine.InputSystem.Key.Q),
			new KeyMapping(Key.R, "R", UnityEngine.InputSystem.Key.R),
			new KeyMapping(Key.S, "S", UnityEngine.InputSystem.Key.S),
			new KeyMapping(Key.T, "T", UnityEngine.InputSystem.Key.T),
			new KeyMapping(Key.U, "U", UnityEngine.InputSystem.Key.U),
			new KeyMapping(Key.V, "V", UnityEngine.InputSystem.Key.V),
			new KeyMapping(Key.W, "W", UnityEngine.InputSystem.Key.W),
			new KeyMapping(Key.X, "X", UnityEngine.InputSystem.Key.X),
			new KeyMapping(Key.Y, "Y", UnityEngine.InputSystem.Key.Y),
			new KeyMapping(Key.Z, "Z", UnityEngine.InputSystem.Key.Z),
			new KeyMapping(Key.Backquote, "Backquote", UnityEngine.InputSystem.Key.Backquote),
			new KeyMapping(Key.Minus, "Minus", UnityEngine.InputSystem.Key.Minus),
			new KeyMapping(Key.Equals, "Equals", UnityEngine.InputSystem.Key.Equals),
			new KeyMapping(Key.Backspace, "Backspace", UnityEngine.InputSystem.Key.Backspace),
			new KeyMapping(Key.Tab, "Tab", UnityEngine.InputSystem.Key.Tab),
			new KeyMapping(Key.LeftBracket, "Left Bracket", UnityEngine.InputSystem.Key.LeftBracket),
			new KeyMapping(Key.RightBracket, "Right Bracket", UnityEngine.InputSystem.Key.RightBracket),
			new KeyMapping(Key.Backslash, "Backslash", UnityEngine.InputSystem.Key.Backslash),
			new KeyMapping(Key.Semicolon, "Semicolon", UnityEngine.InputSystem.Key.Semicolon),
			new KeyMapping(Key.Quote, "Quote", UnityEngine.InputSystem.Key.Quote),
			new KeyMapping(Key.Return, "Return", UnityEngine.InputSystem.Key.Enter),
			new KeyMapping(Key.Comma, "Comma", UnityEngine.InputSystem.Key.Comma),
			new KeyMapping(Key.Period, "Period", UnityEngine.InputSystem.Key.Period),
			new KeyMapping(Key.Slash, "Slash", UnityEngine.InputSystem.Key.Slash),
			new KeyMapping(Key.Space, "Space", UnityEngine.InputSystem.Key.Space),
			new KeyMapping(Key.Insert, "Insert", UnityEngine.InputSystem.Key.Insert),
			new KeyMapping(Key.Delete, "Delete", UnityEngine.InputSystem.Key.Delete),
			new KeyMapping(Key.Home, "Home", UnityEngine.InputSystem.Key.Home),
			new KeyMapping(Key.End, "End", UnityEngine.InputSystem.Key.End),
			new KeyMapping(Key.PageUp, "PageUp", UnityEngine.InputSystem.Key.PageUp),
			new KeyMapping(Key.PageDown, "PageDown", UnityEngine.InputSystem.Key.PageDown),
			new KeyMapping(Key.LeftArrow, "Left Arrow", UnityEngine.InputSystem.Key.LeftArrow),
			new KeyMapping(Key.RightArrow, "Right Arrow", UnityEngine.InputSystem.Key.RightArrow),
			new KeyMapping(Key.UpArrow, "Up Arrow", UnityEngine.InputSystem.Key.UpArrow),
			new KeyMapping(Key.DownArrow, "Down Arrow", UnityEngine.InputSystem.Key.DownArrow),
			new KeyMapping(Key.Pad0, "Numpad 0", UnityEngine.InputSystem.Key.Numpad0),
			new KeyMapping(Key.Pad1, "Numpad 1", UnityEngine.InputSystem.Key.Numpad1),
			new KeyMapping(Key.Pad2, "Numpad 2", UnityEngine.InputSystem.Key.Numpad2),
			new KeyMapping(Key.Pad3, "Numpad 3", UnityEngine.InputSystem.Key.Numpad3),
			new KeyMapping(Key.Pad4, "Numpad 4", UnityEngine.InputSystem.Key.Numpad4),
			new KeyMapping(Key.Pad5, "Numpad 5", UnityEngine.InputSystem.Key.Numpad5),
			new KeyMapping(Key.Pad6, "Numpad 6", UnityEngine.InputSystem.Key.Numpad6),
			new KeyMapping(Key.Pad7, "Numpad 7", UnityEngine.InputSystem.Key.Numpad7),
			new KeyMapping(Key.Pad8, "Numpad 8", UnityEngine.InputSystem.Key.Numpad8),
			new KeyMapping(Key.Pad9, "Numpad 9", UnityEngine.InputSystem.Key.Numpad9),
			new KeyMapping(Key.Numlock, "Numlock", UnityEngine.InputSystem.Key.NumLock),
			new KeyMapping(Key.PadDivide, "Numpad Divide", UnityEngine.InputSystem.Key.NumpadDivide),
			new KeyMapping(Key.PadMultiply, "Numpad Multiply", UnityEngine.InputSystem.Key.NumpadMultiply),
			new KeyMapping(Key.PadMinus, "Numpad Minus", UnityEngine.InputSystem.Key.NumpadMinus),
			new KeyMapping(Key.PadPlus, "Numpad Plus", UnityEngine.InputSystem.Key.NumpadPlus),
			new KeyMapping(Key.PadEnter, "Numpad Enter", UnityEngine.InputSystem.Key.NumpadEnter),
			new KeyMapping(Key.PadPeriod, "Numpad Period", UnityEngine.InputSystem.Key.NumpadPeriod),
			new KeyMapping(Key.Clear, "Clear", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.PadEquals, "Numpad Equals", UnityEngine.InputSystem.Key.NumpadEquals),
			new KeyMapping(Key.F13, "F13", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.F14, "F14", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.F15, "F15", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.AltGr, "AltGr", UnityEngine.InputSystem.Key.RightAlt),
			new KeyMapping(Key.CapsLock, "Caps Lock", UnityEngine.InputSystem.Key.CapsLock),
			new KeyMapping(Key.ExclamationMark, "Exclamation Mark", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Tilde, "Tilde", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.At, "At", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Hash, "Hash", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Dollar, "Dollar", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Percent, "Percent", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Caret, "Caret", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Ampersand, "Ampersand", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Asterisk, "Asterisk", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.LeftParen, "Left Paren", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.RightParen, "Right Paren", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Underscore, "Underscore", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Plus, "Plus", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.LeftBrace, "Left Brace", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.RightBrace, "Right Brace", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Pipe, "Pipe", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.Colon, "Colon", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.DoubleQuote, "Double Quote", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.LessThan, "Less Than", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.GreaterThan, "Greater Than", UnityEngine.InputSystem.Key.None),
			new KeyMapping(Key.QuestionMark, "Question Mark", UnityEngine.InputSystem.Key.None)
		};

		public void Setup()
		{
		}

		public void Reset()
		{
		}

		public void Update()
		{
		}

		public bool AnyKeyIsPressed()
		{
			return Keyboard.current?.anyKey.isPressed ?? false;
		}

		public bool GetKeyIsPressed(Key control)
		{
			return KeyMappings[(int)control].IsPressed;
		}

		public string GetNameForKey(Key control)
		{
			return KeyMappings[(int)control].Name;
		}
	}
}
