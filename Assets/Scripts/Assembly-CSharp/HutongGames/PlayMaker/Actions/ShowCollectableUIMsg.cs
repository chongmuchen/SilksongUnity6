using TeamCherry.Localization;
using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	public class ShowCollectableUIMsg : FsmStateAction
	{
		private struct UIMsgData : ICollectableUIMsgItem, IUIMsgPopupItem
		{
			public string Name;

			public Sprite Icon;

			public float IconScale;

			public float GetUIMsgIconScale()
			{
				return IconScale;
			}

			public bool HasUpgradeIcon()
			{
				return false;
			}

			public string GetUIMsgName()
			{
				return Name;
			}

			public Sprite GetUIMsgSprite()
			{
				return Icon;
			}

			public Object GetRepresentingObject()
			{
				return null;
			}
		}

		[RequiredField]
		public FsmString TranslationSheet;

		[RequiredField]
		public FsmString TranslationKey;

		[ObjectType(typeof(Sprite))]
		[RequiredField]
		public FsmObject Icon;

		[RequiredField]
		public FsmFloat IconScale;

		public override void Reset()
		{
			TranslationSheet = null;
			TranslationKey = null;
			Icon = null;
			IconScale = 1f;
		}

		public override void OnEnter()
		{
			CollectableUIMsg.Spawn(new UIMsgData
			{
				Name = new LocalisedString(TranslationSheet.Value, TranslationKey.Value),
				Icon = (Icon.Value as Sprite),
				IconScale = IconScale.Value
			});
			Finish();
		}
	}
}
