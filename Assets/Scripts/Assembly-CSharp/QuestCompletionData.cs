using System;

[Serializable]
public class QuestCompletionData : SerializableNamedList<QuestCompletionData.Completion, QuestCompletionData.NamedCompletion>
{
	[Serializable]
	public class NamedCompletion : SerializableNamedData<Completion>
	{
	}

	[Serializable]
	public struct Completion
	{
		public bool HasBeenSeen;

		public bool IsAccepted;

		public int CompletedCount;

		public bool IsCompleted;

		public bool WasEverCompleted;

		public void SetCompleted()
		{
			IsCompleted = true;
			WasEverCompleted = true;
		}
	}

	public static Completion Accepted => new Completion
	{
		IsAccepted = true
	};

	public static Completion Completed => new Completion
	{
		IsAccepted = true,
		IsCompleted = true
	};
}
