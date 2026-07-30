using System;
using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.InputSystem;

namespace InControl
{
	public class UnityMouseProvider : IMouseProvider
	{
		private const string mouseXAxis = "mouse x";

		private const string mouseYAxis = "mouse y";

		private readonly bool[] lastButtonPressed = new bool[16];

		private readonly bool[] buttonPressed = new bool[16];

		private Vector2 lastPosition;

		private Vector2 position;

		private Vector2 delta;

		private Vector2 scroll;

		private static int maxSafeMouseButton = int.MaxValue;

		public void Setup()
		{
			ClearState();
		}

		public void Reset()
		{
			ClearState();
		}

		public void Update()
		{
			UnityEngine.InputSystem.Mouse current = UnityEngine.InputSystem.Mouse.current;
			if (current != null)
			{
				Array.Copy(buttonPressed, lastButtonPressed, buttonPressed.Length);
				buttonPressed[1] = current.leftButton.isPressed;
				buttonPressed[2] = current.rightButton.isPressed;
				buttonPressed[3] = current.middleButton.isPressed;
				buttonPressed[10] = current.backButton.isPressed;
				buttonPressed[11] = current.forwardButton.isPressed;
				position = current.position.ReadValue();
				delta = current.delta.ReadValue();
				scroll = current.scroll.ReadValue() / 20f;
			}
			else
			{
				ClearState();
			}
		}

		private static bool SafeGetMouseButton(int button)
		{
			if (button < maxSafeMouseButton)
			{
				try
				{
					return Input.GetMouseButton(button);
				}
				catch (ArgumentException)
				{
					maxSafeMouseButton = Mathf.Min(button, maxSafeMouseButton);
				}
			}
			return false;
		}

		private void ClearState()
		{
			Array.Clear(lastButtonPressed, 0, lastButtonPressed.Length);
			Array.Clear(buttonPressed, 0, buttonPressed.Length);
			lastPosition = Vector2.zero;
			position = Vector2.zero;
			delta = Vector2.zero;
			scroll = Vector2.zero;
		}

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		public Vector2 GetPosition()
		{
			return position;
		}

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		public float GetDeltaX()
		{
			return delta.x;
		}

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		public float GetDeltaY()
		{
			return delta.y;
		}

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		public float GetDeltaScroll()
		{
			if (!(Utility.Abs(scroll.x) > Utility.Abs(scroll.y)))
			{
				return scroll.y;
			}
			return scroll.x;
		}

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		public bool GetButtonIsPressed(Mouse control)
		{
			return buttonPressed[(int)control];
		}

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		public bool GetButtonWasPressed(Mouse control)
		{
			if (buttonPressed[(int)control])
			{
				return !lastButtonPressed[(int)control];
			}
			return false;
		}

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		public bool GetButtonWasReleased(Mouse control)
		{
			if (!buttonPressed[(int)control])
			{
				return lastButtonPressed[(int)control];
			}
			return false;
		}

		[MethodImpl(MethodImplOptions.AggressiveInlining)]
		public bool HasMousePresent()
		{
			return UnityEngine.InputSystem.Mouse.current != null;
		}
	}
}
