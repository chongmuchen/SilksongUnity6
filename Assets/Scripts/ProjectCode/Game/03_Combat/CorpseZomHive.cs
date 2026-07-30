using UnityEngine;

public class CorpseZomHive : CorpseChunker
{
	protected override void LandEffects()
	{
		base.LandEffects();
		GameObject gameObject = GameObject.FindWithTag("Extra Tag");
		if (!gameObject)
		{
			return;
		}
		for (int i = 0; i < 3; i++)
		{
			int index = Random.Range(0, gameObject.transform.childCount);
			Transform child = gameObject.transform.GetChild(index);
			if ((bool)child)
			{
				child.SetParent(null);
				child.position = base.transform.position;
				FSMUtility.SendEventToGameObject(child.gameObject, "SPAWN");
				FlingUtils.FlingObject(new FlingUtils.SelfConfig
				{
					Object = child.gameObject,
					SpeedMin = 5f,
					SpeedMax = 10f,
					AngleMin = 0f,
					AngleMax = 180f
				}, base.transform, Vector3.zero);
			}
		}
	}
}
