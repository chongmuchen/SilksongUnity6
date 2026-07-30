using System.Collections;
using InControl;
using TeamCherry.Localization;
using UnityEngine;
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;
using UnityEngine.ResourceManagement.ResourceProviders;
using UnityEngine.SceneManagement;

public class StartManager : MonoBehaviour
{
	public Animator startManagerAnimator;

	[SerializeField]
	private StandaloneLoadingSpinner loadSpinnerPrefab;

	[SerializeField]
	private InControlManager inControlManager;

	[Header("Language Select")]
	[SerializeField]
	private Camera camera;

	[SerializeField]
	private AddressableReferenceGameObject<LanguageSelector> languageSelectorReference;

	private AsyncOperation loadop;

	private const float FADE_SPEED = 1.6f;

	private bool confirmedLanguage;

	private IEnumerator Start()
	{
		if (inControlManager != null)
		{
			Object.DontDestroyOnLoad(Object.Instantiate(inControlManager).gameObject);
		}
		bool hasLoadedLanguageSelector = false;
		AsyncOperationHandle<GameObject> languageSelectorHandle = default(AsyncOperationHandle<GameObject>);
		LanguageSelector languageSelector = null;
		bool flag = !CheckIsLanguageSet();
		bool finished = true;
		bool isLoadingLanguageSelect = flag && Platform.Current.ShowLanguageSelect;
		if (isLoadingLanguageSelect)
		{
			finished = false;
			languageSelectorHandle = languageSelectorReference.InstantiateAsyncCustom(base.transform, delegate
			{
				languageSelector = languageSelectorReference.Component;
				hasLoadedLanguageSelector = languageSelector;
				finished = true;
				if (hasLoadedLanguageSelector)
				{
					languageSelector.SetCamera(camera);
				}
				else
				{
					Debug.LogError($"Failed to load language selector. {languageSelectorHandle.OperationException}", this);
				}
			});
			yield return null;
		}
		Platform.Current.SetSceneLoadState(isInProgress: true);
		QuitToMenu.StartLoadCoreManagers();
		yield return null;
		AsyncOperationHandle<SceneInstance> loadHandle = default(AsyncOperationHandle<SceneInstance>);
		bool startedLoadingMenu = false;
		AsyncLoadOrderingManager.DoActionAfterAllLoadsComplete(delegate
		{
			loadHandle = Addressables.LoadSceneAsync("Scenes/Menu_Title", LoadSceneMode.Single, activateOnLoad: false);
			startedLoadingMenu = true;
		});
		LanguageCode currentLanguage = Language.CurrentLanguage();
		if (isLoadingLanguageSelect)
		{
			if (!languageSelectorHandle.IsValid())
			{
				Debug.Log("Language select handle is invalid");
			}
			if (languageSelectorHandle.IsValid() && !languageSelectorHandle.IsDone)
			{
				yield return languageSelectorHandle;
			}
			while (!finished)
			{
				yield return null;
			}
			if (hasLoadedLanguageSelector)
			{
				yield return languageSelector.DoLanguageSelect();
			}
		}
		bool showIntroSequence = true;
		RuntimePlatform platform = Application.platform;
		bool showLoadingIcon = platform == RuntimePlatform.PS4 || platform == RuntimePlatform.XboxOne || platform == RuntimePlatform.GameCoreXboxOne;
		while (!Platform.Current.IsSharedDataMounted)
		{
			yield return null;
		}
		bool flag2 = false;
		if (TeamCherry.Localization.LocalizationProjectSettings.TryGetSavedLanguageCode(out var languageCode))
		{
			LanguageCode languageEnum = LocalizationSettings.GetLanguageEnum(languageCode);
			if (currentLanguage != languageEnum)
			{
				flag2 = true;
			}
		}
		if (flag2)
		{
			Language.LoadLanguage();
			ChangeFontByLanguage[] array = Object.FindObjectsByType<ChangeFontByLanguage>(FindObjectsSortMode.None);
			for (int num = 0; num < array.Length; num++)
			{
				array[num].SetFont();
			}
			ChangePositionByLanguage[] array2 = Object.FindObjectsByType<ChangePositionByLanguage>(FindObjectsSortMode.None);
			for (int num = 0; num < array2.Length; num++)
			{
				array2[num].DoOffset();
			}
			ActivatePerLanguage[] array3 = Object.FindObjectsByType<ActivatePerLanguage>(FindObjectsSortMode.None);
			for (int num = 0; num < array3.Length; num++)
			{
				array3[num].UpdateLanguage();
			}
			ChangeByLanguageBase[] array4 = Object.FindObjectsByType<ChangeByLanguageBase>(FindObjectsSortMode.None);
			for (int num = 0; num < array4.Length; num++)
			{
				array4[num].DoUpdate();
			}
			SetTextMeshProGameText[] componentsInChildren = GetComponentsInChildren<SetTextMeshProGameText>(includeInactive: true);
			for (int num = 0; num < componentsInChildren.Length; num++)
			{
				componentsInChildren[num].UpdateText();
			}
			LogoLanguage[] componentsInChildren2 = GetComponentsInChildren<LogoLanguage>(includeInactive: true);
			for (int num = 0; num < componentsInChildren2.Length; num++)
			{
				componentsInChildren2[num].SetSprite();
			}
		}
		if (showIntroSequence)
		{
			startManagerAnimator.SetBool("WillShowQuote", value: true);
			startManagerAnimator.SetTrigger("Start");
			int loadingIconNameHash = Animator.StringToHash("LoadingIcon");
			while (startManagerAnimator.GetCurrentAnimatorStateInfo(0).shortNameHash != loadingIconNameHash)
			{
				yield return null;
			}
		}
		Platform.Current.SetSceneLoadState(isInProgress: true, isHighPriority: true);
		if (showLoadingIcon)
		{
			Object.Instantiate(loadSpinnerPrefab).Setup(null);
		}
		while (!startedLoadingMenu)
		{
			yield return null;
		}
		yield return loadHandle;
		yield return loadHandle.Result.ActivateAsync();
	}

	private void OnDestroy()
	{
		languageSelectorReference?.Dispose();
	}

	public void SwitchToMenuScene()
	{
		loadop.allowSceneActivation = true;
	}

	public bool CheckIsLanguageSet()
	{
		return Platform.Current.LocalSharedData.GetBool("GameLangSet", def: false);
	}
}
