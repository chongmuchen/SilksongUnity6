using System;
using GlobalEnums;
using TeamCherry.Localization;

[Serializable]
public struct InventoryItemButtonPromptData
{
	public HeroActionButton Action;

	public bool IsMenuButton;

	public bool DisabledWhenBareInventory;

	[LocalisedString.NotRequired]
	public LocalisedString UseText;

	public LocalisedString ResponseText;

	[LocalisedString.NotRequired]
	public LocalisedString ConditionText;

	public HeroActionButton MenuAction
	{
		get
		{
			if (!IsMenuButton)
			{
				return Action;
			}
			if (Platform.Current.GetAcceptRejectInputStyle(ManagerSingleton<InputHandler>.Instance.activeGamepadType) == Platform.AcceptRejectInputStyles.JapaneseStyle)
			{
				switch (Action)
				{
				case HeroActionButton.JUMP:
					return HeroActionButton.CAST;
				case HeroActionButton.CAST:
					return HeroActionButton.JUMP;
				}
			}
			return Action;
		}
	}
}
