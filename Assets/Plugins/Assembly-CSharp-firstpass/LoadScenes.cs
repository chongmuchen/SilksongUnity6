using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LoadScenes : MonoBehaviour
{
	[Serializable]
	public struct SceneInfo
	{
		public string name;

		public bool shouldLoad;
	}

	public List<SceneInfo> scenes = new List<SceneInfo>();

	private void Update()
	{
		foreach (SceneInfo scene in scenes)
		{
			Scene sceneByName = SceneManager.GetSceneByName(scene.name);
			if (scene.shouldLoad && !sceneByName.isLoaded)
			{
				SceneManager.LoadScene(scene.name, LoadSceneMode.Additive);
			}
			if (!scene.shouldLoad && sceneByName.isLoaded)
			{
				SceneManager.UnloadSceneAsync(sceneByName);
			}
		}
	}
}
