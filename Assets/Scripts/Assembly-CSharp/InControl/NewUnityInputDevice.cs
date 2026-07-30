using UnityEngine.InputSystem;
using UnityEngine.InputSystem.DualShock;
using UnityEngine.InputSystem.Switch;
using UnityEngine.InputSystem.XInput;

namespace InControl
{
	public class NewUnityInputDevice : InputDevice
	{
		private const float lowerDeadZone = 0.2f;

		private const float upperDeadZone = 0.9f;

		public readonly Gamepad UnityGamepad;

		private readonly InputControlType leftCommandControl;

		private readonly InputControlType rightCommandControl;

		private readonly bool isNintendoLayout;

		public NewUnityInputDevice(Gamepad unityGamepad)
		{
			UnityGamepad = unityGamepad;
			base.SortOrder = unityGamepad.deviceId;
			base.DeviceClass = InputDeviceClass.Controller;
			base.DeviceStyle = DetectDeviceStyle(unityGamepad);
			leftCommandControl = base.DeviceStyle.LeftCommandControl();
			rightCommandControl = base.DeviceStyle.RightCommandControl();
			base.Name = unityGamepad.displayName;
			base.Meta = unityGamepad.displayName;
			AddControl(InputControlType.LeftStickLeft, "Left Stick Left", 0.2f, 0.9f);
			AddControl(InputControlType.LeftStickRight, "Left Stick Right", 0.2f, 0.9f);
			AddControl(InputControlType.LeftStickUp, "Left Stick Up", 0.2f, 0.9f);
			AddControl(InputControlType.LeftStickDown, "Left Stick Down", 0.2f, 0.9f);
			AddControl(InputControlType.RightStickLeft, "Right Stick Left", 0.2f, 0.9f);
			AddControl(InputControlType.RightStickRight, "Right Stick Right", 0.2f, 0.9f);
			AddControl(InputControlType.RightStickUp, "Right Stick Up", 0.2f, 0.9f);
			AddControl(InputControlType.RightStickDown, "Right Stick Down", 0.2f, 0.9f);
			AddControl(InputControlType.LeftTrigger, unityGamepad.leftTrigger.displayName, 0.2f, 0.9f);
			AddControl(InputControlType.RightTrigger, unityGamepad.rightTrigger.displayName, 0.2f, 0.9f);
			AddControl(InputControlType.DPadUp, "DPad Up", 0.2f, 0.9f);
			AddControl(InputControlType.DPadDown, "DPad Down", 0.2f, 0.9f);
			AddControl(InputControlType.DPadLeft, "DPad Left", 0.2f, 0.9f);
			AddControl(InputControlType.DPadRight, "DPad Right", 0.2f, 0.9f);
			AddControl(isNintendoLayout ? InputControlType.Action2 : InputControlType.Action1, unityGamepad.buttonWest.displayName);
			AddControl(isNintendoLayout ? InputControlType.Action1 : InputControlType.Action2, unityGamepad.buttonNorth.displayName);
			AddControl(isNintendoLayout ? InputControlType.Action4 : InputControlType.Action3, unityGamepad.buttonEast.displayName);
			AddControl(isNintendoLayout ? InputControlType.Action3 : InputControlType.Action4, unityGamepad.buttonSouth.displayName);
			AddControl(InputControlType.LeftBumper, unityGamepad.leftShoulder.displayName);
			AddControl(InputControlType.RightBumper, unityGamepad.rightShoulder.displayName);
			AddControl(InputControlType.LeftStickButton, unityGamepad.leftStickButton.displayName);
			AddControl(InputControlType.RightStickButton, unityGamepad.rightStickButton.displayName);
			AddControl(leftCommandControl, unityGamepad.selectButton.displayName);
			AddControl(rightCommandControl, unityGamepad.startButton.displayName);
			if (unityGamepad is DualShockGamepad dualShockGamepad)
			{
				AddControl(InputControlType.TouchPadButton, dualShockGamepad.touchpadButton.displayName);
			}
		}

		public override void Update(ulong updateTick, float deltaTime)
		{
			UpdateLeftStickWithValue(UnityGamepad.leftStick.ReadUnprocessedValue(), updateTick, deltaTime);
			UpdateRightStickWithValue(UnityGamepad.rightStick.ReadUnprocessedValue(), updateTick, deltaTime);
			UpdateWithValue(InputControlType.LeftTrigger, UnityGamepad.leftTrigger.ReadUnprocessedValue(), updateTick, deltaTime);
			UpdateWithValue(InputControlType.RightTrigger, UnityGamepad.rightTrigger.ReadUnprocessedValue(), updateTick, deltaTime);
			UpdateWithState(InputControlType.DPadUp, UnityGamepad.dpad.up.isPressed, updateTick, updateTick);
			UpdateWithState(InputControlType.DPadDown, UnityGamepad.dpad.down.isPressed, updateTick, updateTick);
			UpdateWithState(InputControlType.DPadLeft, UnityGamepad.dpad.left.isPressed, updateTick, updateTick);
			UpdateWithState(InputControlType.DPadRight, UnityGamepad.dpad.right.isPressed, updateTick, updateTick);
			UpdateWithState(isNintendoLayout ? InputControlType.Action2 : InputControlType.Action1, UnityGamepad.buttonSouth.isPressed, updateTick, updateTick);
			UpdateWithState(isNintendoLayout ? InputControlType.Action1 : InputControlType.Action2, UnityGamepad.buttonEast.isPressed, updateTick, updateTick);
			UpdateWithState(isNintendoLayout ? InputControlType.Action4 : InputControlType.Action3, UnityGamepad.buttonWest.isPressed, updateTick, updateTick);
			UpdateWithState(isNintendoLayout ? InputControlType.Action3 : InputControlType.Action4, UnityGamepad.buttonNorth.isPressed, updateTick, updateTick);
			UpdateWithState(InputControlType.LeftBumper, UnityGamepad.leftShoulder.isPressed, updateTick, updateTick);
			UpdateWithState(InputControlType.RightBumper, UnityGamepad.rightShoulder.isPressed, updateTick, updateTick);
			UpdateWithState(InputControlType.LeftStickButton, UnityGamepad.leftStickButton.isPressed, updateTick, updateTick);
			UpdateWithState(InputControlType.RightStickButton, UnityGamepad.rightStickButton.isPressed, updateTick, updateTick);
			UpdateWithState(leftCommandControl, UnityGamepad.selectButton.isPressed, updateTick, updateTick);
			UpdateWithState(rightCommandControl, UnityGamepad.startButton.isPressed, updateTick, updateTick);
			if (UnityGamepad is DualShockGamepad dualShockGamepad)
			{
				UpdateWithState(InputControlType.TouchPadButton, dualShockGamepad.touchpadButton.isPressed, updateTick, updateTick);
			}
		}

		public override void Vibrate(float leftMotor, float rightMotor)
		{
			if (base.IsAttached)
			{
				UnityGamepad.SetMotorSpeeds(leftMotor, rightMotor);
			}
		}

		private static InputDeviceStyle DetectDeviceStyle(UnityEngine.InputSystem.InputDevice unityDevice)
		{
			if (!(unityDevice is XInputController))
			{
				if (!(unityDevice is DualSenseGamepadHID))
				{
					if (!(unityDevice is DualShockGamepad))
					{
						if (unityDevice is SwitchProControllerHID)
						{
							return InputDeviceStyle.NintendoSwitch;
						}
						return InputDeviceStyle.Unknown;
					}
					return InputDeviceStyle.PlayStation4;
				}
				return InputDeviceStyle.PlayStation5;
			}
			return InputDeviceStyle.XboxOne;
		}
	}
}
