using System.Text;
using System.Text.RegularExpressions;
using UnityEngine;

namespace InControl.UnityDeviceProfiles
{
	[Preserve]
	[UnityInputDeviceProfile]
	public class PlayStation4MacBluetoothUnityProfile : InputDeviceProfile
	{
		private double GetMacOSVersion()
		{
			string[] array = Regex.Replace(new StringBuilder(SystemInfo.operatingSystem).Replace(",", ".").ToString(), "[^0-9.]", "").Split('.');
			if (array.Length < 2)
			{
				return 0.0;
			}
			if (!double.TryParse(new StringBuilder(array[0]).Append(".").Append(array[1]).ToString(), out var result))
			{
				return 0.0;
			}
			return result;
		}

		public override void Define()
		{
			base.Define();
			string text = "®";
			base.DeviceName = "PlayStation 4 Controller";
			base.DeviceNotes = "PlayStation 4 Controller on macOS";
			base.DeviceClass = InputDeviceClass.Controller;
			base.DeviceStyle = InputDeviceStyle.PlayStation4;
			base.IncludePlatforms = new string[1] { "OS X" };
			base.Matchers = new InputDeviceMatcher[3]
			{
				new InputDeviceMatcher
				{
					NameLiteral = "Unknown Wireless Controller"
				},
				new InputDeviceMatcher
				{
					NameLiteral = "Sony Interactive Entertainment DUALSHOCK" + text + "4 USB Wireless Adaptor"
				},
				new InputDeviceMatcher
				{
					NameLiteral = "Unknown DUALSHOCK 4 Wireless Controller"
				}
			};
			base.ButtonMappings = new InputControlMapping[12]
			{
				new InputControlMapping
				{
					Name = "Cross",
					Target = InputControlType.Action1,
					Source = InputDeviceProfile.Button(1)
				},
				new InputControlMapping
				{
					Name = "Circle",
					Target = InputControlType.Action2,
					Source = InputDeviceProfile.Button(2)
				},
				new InputControlMapping
				{
					Name = "Square",
					Target = InputControlType.Action3,
					Source = InputDeviceProfile.Button(0)
				},
				new InputControlMapping
				{
					Name = "Triangle",
					Target = InputControlType.Action4,
					Source = InputDeviceProfile.Button(3)
				},
				new InputControlMapping
				{
					Name = "Left Bumper",
					Target = InputControlType.LeftBumper,
					Source = InputDeviceProfile.Button(4)
				},
				new InputControlMapping
				{
					Name = "Right Bumper",
					Target = InputControlType.RightBumper,
					Source = InputDeviceProfile.Button(5)
				},
				new InputControlMapping
				{
					Name = "Share",
					Target = InputControlType.Share,
					Source = InputDeviceProfile.Button(8)
				},
				new InputControlMapping
				{
					Name = "Options",
					Target = InputControlType.Options,
					Source = InputDeviceProfile.Button(9)
				},
				new InputControlMapping
				{
					Name = "L3",
					Target = InputControlType.LeftStickButton,
					Source = InputDeviceProfile.Button(10)
				},
				new InputControlMapping
				{
					Name = "R3",
					Target = InputControlType.RightStickButton,
					Source = InputDeviceProfile.Button(11)
				},
				new InputControlMapping
				{
					Name = "System",
					Target = InputControlType.System,
					Source = InputDeviceProfile.Button(12)
				},
				new InputControlMapping
				{
					Name = "TouchPad Button",
					Target = InputControlType.TouchPadButton,
					Source = InputDeviceProfile.Button(13)
				}
			};
			double macOSVersion = GetMacOSVersion();
			int analog;
			int analog2;
			if (macOSVersion >= 12.3)
			{
				analog = 7;
				analog2 = 8;
			}
			else if (macOSVersion >= 10.1)
			{
				analog = 6;
				analog2 = 7;
			}
			else
			{
				analog = 10;
				analog2 = 11;
			}
			base.AnalogMappings = new InputControlMapping[14]
			{
				InputDeviceProfile.LeftStickLeftMapping(0),
				InputDeviceProfile.LeftStickRightMapping(0),
				InputDeviceProfile.LeftStickUpMapping(1),
				InputDeviceProfile.LeftStickDownMapping(1),
				InputDeviceProfile.RightStickLeftMapping(2),
				InputDeviceProfile.RightStickRightMapping(2),
				InputDeviceProfile.RightStickUpMapping(3),
				InputDeviceProfile.RightStickDownMapping(3),
				InputDeviceProfile.LeftTriggerMapping(4),
				InputDeviceProfile.RightTriggerMapping(5),
				InputDeviceProfile.DPadLeftMapping(analog),
				InputDeviceProfile.DPadRightMapping(analog),
				InputDeviceProfile.DPadUpMapping(analog2),
				InputDeviceProfile.DPadDownMapping(analog2)
			};
		}
	}
}
