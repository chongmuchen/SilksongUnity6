using System;
using System.Collections.Generic;

public static class SaveDataUpgradeHandler
{
	private class SceneSplit
	{
		public string SceneName { get; private set; }

		public Version TargetVersion { get; private set; }

		public string[] NewSceneNames { get; private set; }

		public SceneSplit(string sceneName, string version, params string[] newSceneNames)
		{
			SceneName = sceneName;
			TargetVersion = new Version(version);
			NewSceneNames = newSceneNames;
		}
	}

	private struct SaveDataUpgrade
	{
		public Version TargetVersion;

		public Action<SceneData, PlayerData> UpgradeAction;
	}

	private static readonly SceneSplit[] _splitScenes = new SceneSplit[0];

	private static readonly SaveDataUpgrade[] _saveDataUpgrades = new SaveDataUpgrade[1]
	{
		new SaveDataUpgrade
		{
			TargetVersion = null,
			UpgradeAction = delegate(SceneData sceneData, PlayerData playerData)
			{
				if (playerData.wardBossDefeated && !playerData.Relics.GetData("Psalm Cylinder Ward").IsCollected && (!(playerData.respawnScene == "Ward_02") || !(playerData.respawnMarkerName == "Silk Heart Memory Respawn Marker")))
				{
					sceneData.PersistentBools.SetValue(new PersistentItemData<bool>
					{
						SceneName = "Under_08",
						ID = "One Way Wall",
						Value = true
					});
				}
			}
		}
	};

	private static bool ShouldHandleUpgrade(Version targetVersion, string saveFileVersion)
	{
		saveFileVersion = SaveDataUtility.CleanupVersionText(saveFileVersion);
		Version value = new Version(saveFileVersion);
		return targetVersion.CompareTo(value) > 0;
	}

	private static void UpdateMap(SceneSplit sceneSplit, HashSet<string> scenesMapped)
	{
		if (scenesMapped.Contains(sceneSplit.SceneName))
		{
			string[] newSceneNames = sceneSplit.NewSceneNames;
			foreach (string item in newSceneNames)
			{
				scenesMapped.Add(item);
			}
		}
	}

	public static void UpgradeSaveData(SceneData sceneData, PlayerData playerData)
	{
		SceneSplit[] splitScenes = _splitScenes;
		foreach (SceneSplit sceneSplit in splitScenes)
		{
			if (ShouldHandleUpgrade(sceneSplit.TargetVersion, playerData.version))
			{
				UpdateMap(sceneSplit, playerData.scenesMapped);
			}
		}
		SaveDataUpgrade[] saveDataUpgrades = _saveDataUpgrades;
		for (int i = 0; i < saveDataUpgrades.Length; i++)
		{
			SaveDataUpgrade saveDataUpgrade = saveDataUpgrades[i];
			if (saveDataUpgrade.TargetVersion == null || ShouldHandleUpgrade(saveDataUpgrade.TargetVersion, playerData.version))
			{
				saveDataUpgrade.UpgradeAction(sceneData, playerData);
			}
		}
	}
}
