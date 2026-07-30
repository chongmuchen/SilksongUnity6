using UnityEngine;

public class MenuButtonAdvancedControllerListCondition : MenuButtonListCondition
{
	[SerializeField]
	private bool flip;

	public override bool IsFulfilled()
	{
		RuntimePlatform platform = Application.platform;
		bool flag = platform == RuntimePlatform.WindowsEditor || platform == RuntimePlatform.WindowsPlayer || platform == RuntimePlatform.OSXEditor || platform == RuntimePlatform.OSXPlayer || platform == RuntimePlatform.LinuxEditor || platform == RuntimePlatform.LinuxPlayer;
		if (!flip)
		{
			return flag;
		}
		return !flag;
	}
}
