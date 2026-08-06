using System;
using System.IO;
using UnityEngine;

public class JsonSharedData : CustomSharedData
{
	private readonly bool useEncryption;

	private readonly string saveDir;

	private readonly string dataPath;

	private bool isLoading;

	public JsonSharedData(string saveDir, string fileName, bool useEncryption)
	{
		this.saveDir = saveDir;
		dataPath = Path.Combine(saveDir, fileName);
		this.useEncryption = useEncryption;
		Load();
	}

	public override void Save()
	{
		if (isLoading)
		{
			return;
		}
		SaveDataUtility.AddTaskToAsyncQueue(delegate
		{
			try
			{
				string text = SaveToJSON();
				byte[] data = SaveFileCodec.EncodeJson(text, useEncryption);
				if (!Directory.Exists(saveDir))
				{
					Directory.CreateDirectory(saveDir);
				}
				WriteAllBytesSafe(dataPath, data);
			}
			catch (Exception exception)
			{
				Debug.LogException(exception);
			}
		});
	}

	public void Load()
	{
		isLoading = true;
		try
		{
			string text = dataPath;
			string backupPath = GetBackupPath(text);
			if ((File.Exists(text) || File.Exists(backupPath)) && !TryLoadFromPath(text))
			{
				Debug.LogWarning("Primary save at '" + text + "' invalid or corrupted. Trying backup.");
				if (!TryLoadFromPath(backupPath))
				{
					Debug.LogError("Backup save is also invalid/corrupted.");
				}
			}
		}
		catch (Exception message)
		{
			Debug.LogError(message);
		}
		finally
		{
			isLoading = false;
		}
	}

	private static void WriteAllBytesSafe(string path, byte[] data)
	{
		string directoryName = Path.GetDirectoryName(path);
		string fileName = Path.GetFileName(path);
		string text = Path.Combine(directoryName, fileName + ".tmp");
		string backupPath = GetBackupPath(path);
		if (!Directory.Exists(directoryName))
		{
			Directory.CreateDirectory(directoryName);
		}
		using (FileStream fileStream = new FileStream(text, FileMode.Create, FileAccess.Write, FileShare.None, 4096, FileOptions.WriteThrough))
		{
			fileStream.Write(data, 0, data.Length);
			try
			{
				fileStream.Flush(flushToDisk: true);
			}
			catch
			{
				fileStream.Flush();
			}
		}
		try
		{
			if (File.Exists(path))
			{
				File.Replace(text, path, backupPath, ignoreMetadataErrors: true);
			}
			else
			{
				File.Move(text, path);
			}
		}
		catch (PlatformNotSupportedException)
		{
			if (File.Exists(backupPath))
			{
				File.Delete(backupPath);
			}
			if (File.Exists(path))
			{
				File.Move(path, backupPath);
			}
			File.Move(text, path);
		}
		catch (Exception arg)
		{
			if (File.Exists(text))
			{
				File.Delete(text);
			}
			Debug.LogError($"Failed to data to {path}: {arg}");
		}
	}

	private static string GetBackupPath(string path)
	{
		string directoryName = Path.GetDirectoryName(path);
		string fileName = Path.GetFileName(path);
		return Path.Combine(directoryName, fileName + ".bak");
	}

	private bool TryLoadFromPath(string path)
	{
		if (!File.Exists(path))
		{
			return false;
		}
		byte[] array = File.ReadAllBytes(path);
		if (array == null || array.Length == 0)
		{
			return false;
		}
		string text2 = SaveFileCodec.DecodeJson(array, legacyUseEncryption: useEncryption);
		if (string.IsNullOrEmpty(text2))
		{
			return false;
		}
		LoadFromJSON(text2);
		return true;
	}
}
