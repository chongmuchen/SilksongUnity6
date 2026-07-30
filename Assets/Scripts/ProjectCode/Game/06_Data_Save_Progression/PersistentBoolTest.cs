using System;

[Serializable]
public class PersistentBoolTest : PersistentItemTest<bool>
{
	public override bool IsFulfilled
	{
		get
		{
			SceneData instance = SceneData.instance;
			if (instance == null)
			{
				return false;
			}
			if (!instance.PersistentBools.TryGetValue(SceneName, ID, out var value))
			{
				return false;
			}
			return value.Value == ExpectedValue;
		}
	}
}
