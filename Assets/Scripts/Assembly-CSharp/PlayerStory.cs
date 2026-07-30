using System;
using System.Collections.Generic;

public static class PlayerStory
{
	public enum EventTypes
	{
		None = -1,
		HeartPiece = 0,
		SpoolPiece = 1,
		SimpleKey = 2,
		MemoryLocket = 3
	}

	[Serializable]
	public struct EventInfo
	{
		public EventTypes EventType;

		public string SceneName;

		public float PlayTime;
	}

	public static void RecordEvent(EventTypes eventTypes)
	{
		if (eventTypes != EventTypes.None)
		{
			GameManager instance = GameManager.instance;
			PlayerData playerData2;
			PlayerData playerData = (playerData2 = instance.playerData);
			if (playerData2.StoryEvents == null)
			{
				playerData2.StoryEvents = new List<EventInfo>();
			}
			playerData.StoryEvents.Add(new EventInfo
			{
				EventType = eventTypes,
				SceneName = instance.GetSceneNameString(),
				PlayTime = instance.PlayTime
			});
		}
	}
}
