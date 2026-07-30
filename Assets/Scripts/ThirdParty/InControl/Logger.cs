using System;

namespace InControl
{
	public static class Logger
	{
		public static event Action<LogMessage> OnLogMessage;

		public static void LogInfo(string text)
		{
			if (Logger.OnLogMessage != null)
			{
				LogMessage obj = new LogMessage
				{
					Text = text,
					Type = LogMessageType.Info
				};
				Logger.OnLogMessage(obj);
			}
		}

		public static void LogWarning(string text)
		{
			if (Logger.OnLogMessage != null)
			{
				LogMessage obj = new LogMessage
				{
					Text = text,
					Type = LogMessageType.Warning
				};
				Logger.OnLogMessage(obj);
			}
		}

		public static void LogError(string text)
		{
			if (Logger.OnLogMessage != null)
			{
				LogMessage obj = new LogMessage
				{
					Text = text,
					Type = LogMessageType.Error
				};
				Logger.OnLogMessage(obj);
			}
		}
	}
}
