using System;
using TeamCherry.Localization;
using UnityEngine;
using UnityEngine.AddressableAssets;

public class LocalizationProjectSettings : LocalizationProjectSettingsBase
{
	[Serializable]
	public struct BoxTest
	{
		public string[] IncludeTitles;

		public AssetReferenceGameObject TextBoxPrefab;
	}

	[Header("Pull Conditions")]
	[SerializeField]
	private string[] pullExcludeSheets;

	[SerializeField]
	private string[] pullExcludeKeys;

	[Header("Box Tests")]
	[SerializeField]
	private string[] boxTestExcludeSheets;

	[SerializeField]
	private string[] boxTestExcludeKeys;

	[SerializeField]
	private BoxTest[] boxTests;

	private const string LAST_LANGUAGE_KEY = "M2H_lastLanguage";

	public override bool TryGetSavedLanguageCode(out string languageCode)
	{
		if ((bool)Platform.Current && Platform.Current.LocalSharedData.HasKey("M2H_lastLanguage"))
		{
			languageCode = Platform.Current.LocalSharedData.GetString("M2H_lastLanguage", "");
			return true;
		}
		languageCode = "EN";
		return false;
	}

	public override SystemLanguage GetSystemLanguage()
	{
		return Platform.Current?.GetSystemLanguage() ?? Application.systemLanguage;
	}

	public override void OnSwitchedLanguage(LanguageCode newLang)
	{
		if ((bool)Platform.Current)
		{
			Platform.Current.LocalSharedData.SetString("M2H_lastLanguage", newLang.ToString() ?? "");
			Platform.Current.LocalSharedData.Save();
		}
	}

	public override bool CanPullSheet(string sheetTitle)
	{
		if (string.IsNullOrEmpty(sheetTitle))
		{
			return false;
		}
		string[] array = pullExcludeSheets;
		for (int i = 0; i < array.Length; i++)
		{
			if (array[i] == sheetTitle)
			{
				return false;
			}
		}
		return true;
	}

	public override bool CanPullText(string sheetTitle, string key)
	{
		if (string.IsNullOrEmpty(key))
		{
			return false;
		}
		string[] array = pullExcludeKeys;
		foreach (string value in array)
		{
			if (key.Contains(value))
			{
				return false;
			}
		}
		return true;
	}

	public override bool ShouldCheckText(string sheetTitle, string key)
	{
		string[] array = boxTestExcludeSheets;
		for (int i = 0; i < array.Length; i++)
		{
			if (array[i] == sheetTitle)
			{
				return false;
			}
		}
		array = boxTestExcludeKeys;
		foreach (string value in array)
		{
			if (key.Contains(value))
			{
				return false;
			}
		}
		return true;
	}

	public override bool IsTextOverflowing(string sheetTitle, string text)
	{
		return false;
	}
}
