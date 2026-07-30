using System.Linq;
using TeamCherry.Localization;

namespace HutongGames.PlayMaker.Actions
{
	[ActionCategory("Dialogue")]
	public class DialogueYesNoItemV6 : YesNoAction
	{
		public LocalisedFsmString Prompt;

		[ObjectType(typeof(YesNoPromptFormat))]
		public FsmEnum PromptFormat;

		[Tooltip("Optional override label")]
		public FsmString BoxLabel;

		[ArrayEditor(typeof(SavedItem), "", 0, 0, 65536)]
		public FsmArray RequiredItems;

		[ArrayEditor(VariableType.Int, "", 0, 0, 65536)]
		public FsmArray RequiredAmounts;

		public FsmInt CurrencyCost;

		[ObjectType(typeof(CurrencyType))]
		public FsmEnum CurrencyType;

		public FsmBool ShowCounter;

		public FsmBool ConsumeItem;

		[ObjectType(typeof(TakeItemTypes))]
		public FsmEnum TakeDisplay;

		[ObjectType(typeof(DisplayType))]
		public new FsmEnum DisplayType;

		[ObjectType(typeof(SavedItem))]
		public FsmObject WillGetItem;

		public override void Reset()
		{
			base.Reset();
			Prompt = null;
			PromptFormat = null;
			BoxLabel = new FsmString
			{
				UseVariable = true
			};
			RequiredItems = null;
			RequiredAmounts = null;
			CurrencyCost = null;
			CurrencyType = null;
			ShowCounter = true;
			ConsumeItem = null;
			TakeDisplay = null;
			DisplayType = null;
			WillGetItem = null;
		}

		protected override void DoOpen()
		{
			string boxLabel = GetBoxLabel();
			DialogueYesNoBox.Open(delegate
			{
				SendEvent(isYes: true);
			}, delegate
			{
				SendEvent(isYes: false);
			}, ReturnHUDAfter.Value, boxLabel, (CurrencyType)(object)CurrencyType.Value, CurrencyCost.Value, RequiredItems.objectReferences.Cast<SavedItem>().ToList(), RequiredAmounts.intValues, ShowCounter.Value, ConsumeItem.Value, WillGetItem.Value as SavedItem, (TakeItemTypes)(object)TakeDisplay.Value, (DisplayType)(object)DisplayType.Value);
		}

		protected override void DoForceClose()
		{
			DialogueYesNoBox.ForceClose();
		}

		private string GetBoxLabel()
		{
			if (!BoxLabel.IsNone && !string.IsNullOrEmpty(BoxLabel.Value))
			{
				return BoxLabel.Value;
			}
			LocalisedString localisedString = Prompt;
			if (localisedString.IsEmpty)
			{
				return string.Empty;
			}
			string text = localisedString.ToString();
			switch ((YesNoPromptFormat)(object)PromptFormat.Value)
			{
			case YesNoPromptFormat.RequiredItemName:
				foreach (SavedItem item in RequiredItems.objectReferences.Cast<SavedItem>().ToList())
				{
					if (!(item == null))
					{
						text = string.Format(text, item.GetPopupName());
						break;
					}
				}
				break;
			case YesNoPromptFormat.WillGetItemName:
			{
				SavedItem savedItem = WillGetItem.Value as SavedItem;
				if (savedItem != null)
				{
					text = string.Format(text, savedItem.GetPopupName());
				}
				break;
			}
			}
			return text;
		}
	}
}
