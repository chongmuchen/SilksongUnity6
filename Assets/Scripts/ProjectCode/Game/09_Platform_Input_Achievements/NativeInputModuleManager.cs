using InputSystem;
using UnityEngine;

public class NativeInputModuleManager : MonoBehaviour
{
	private void Awake()
	{
		// Unity Input System performs its own device discovery; the old native-backend
		// selection flags remain in GameSettings only for save-data compatibility.
		InputManager.Initialize();
	}
}
