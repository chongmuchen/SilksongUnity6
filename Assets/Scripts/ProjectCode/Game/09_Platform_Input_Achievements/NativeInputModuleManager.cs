using InControl;
using UnityEngine;

public class NativeInputModuleManager : MonoBehaviour
{
	private InControlManager manager;

	private void Awake()
	{
		manager = GetComponent<InControlManager>();
		if (manager == null)
		{
			Debug.LogError("Unable to find input manager.");
			return;
		}
		if (InputManager.IsSetup)
		{
			Debug.LogError("Too late to enable native input module.");
			return;
		}
		GameManager instance = GameManager.instance;
		GameSettings gameSettings = (instance ? instance.gameSettings : new GameSettings());
		gameSettings.LoadControllerSettings();
		manager.enableNativeInput = gameSettings.nativeInput;
		manager.nativeInputEnableXInput = gameSettings.xInput;
		manager.nativeInputEnableMFi = gameSettings.appleMFi;
	}
}
