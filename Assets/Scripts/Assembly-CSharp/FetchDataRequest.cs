using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using UnityEngine;

public sealed class FetchDataRequest
{
	public enum Status
	{
		NotStarted = 0,
		InProgress = 1,
		Completed = 2,
		Failed = 3
	}

	private Status status;

	private readonly object statusLock;

	private readonly object listLock;

	private Action<FetchDataRequest> fetchCallbacks;

	private Action<FetchDataRequest> callbacks;

	private List<RestorePointFileWrapper> restorePoints;

	public Status State
	{
		get
		{
			lock (statusLock)
			{
				return status;
			}
		}
		set
		{
			bool flag = false;
			lock (statusLock)
			{
				flag = value == Status.Completed && status != Status.Completed;
				if (!flag)
				{
					status = value;
				}
			}
			if (flag)
			{
				OnFetchCompleted();
				lock (statusLock)
				{
					status = value;
				}
				OnFetchCompleted();
				RunCallbacks();
			}
		}
	}

	public string Name { get; set; }

	public List<RestorePointFileWrapper> RestorePoints
	{
		get
		{
			lock (listLock)
			{
				return restorePoints;
			}
		}
		set
		{
			lock (listLock)
			{
				restorePoints = value;
			}
		}
	}

	public static FetchDataRequest Error => new FetchDataRequest
	{
		status = Status.Failed
	};

	public FetchDataRequest()
	{
		statusLock = new object();
		listLock = new object();
	}

	public void AddResult(RestorePointFileWrapper data)
	{
		lock (listLock)
		{
			for (int i = 0; i < restorePoints.Count; i++)
			{
				RestorePointFileWrapper restorePointFileWrapper = restorePoints[i];
				if (data.number >= restorePointFileWrapper.number)
				{
					restorePoints.Insert(i, data);
					return;
				}
			}
			restorePoints.Add(data);
		}
	}

	public void RunOnFetchComplete(Action<FetchDataRequest> callback)
	{
		lock (statusLock)
		{
			if (status == Status.Completed || status == Status.Failed)
			{
				callback?.Invoke(this);
			}
			else
			{
				callbacks = (Action<FetchDataRequest>)Delegate.Combine(callbacks, callback);
			}
		}
	}

	public void RunOnComplete(Action<FetchDataRequest> callback)
	{
		lock (statusLock)
		{
			if (status == Status.Completed || status == Status.Failed)
			{
				callback?.Invoke(this);
			}
			else
			{
				callbacks = (Action<FetchDataRequest>)Delegate.Combine(callbacks, callback);
			}
		}
	}

	private void OnFetchCompleted()
	{
		if (fetchCallbacks != null)
		{
			Action<FetchDataRequest> action = fetchCallbacks;
			fetchCallbacks = null;
			action(this);
		}
	}

	private void RunCallbacks()
	{
		if (callbacks != null)
		{
			Action<FetchDataRequest> action = callbacks;
			callbacks = null;
			action(this);
		}
	}
}
public sealed class FetchDataRequest<T> where T : new()
{
	public sealed class FetchResult
	{
		public readonly RestorePointFileWrapper sourceData;

		public T loadedObject;

		public int order;

		public FetchResult(RestorePointFileWrapper sourceData)
		{
			this.sourceData = sourceData;
		}
	}

	public readonly FetchDataRequest dataSource;

	public readonly List<FetchResult> results = new List<FetchResult>();

	private volatile bool isComplete;

	public FetchDataRequest.Status State
	{
		get
		{
			if (dataSource.State == FetchDataRequest.Status.Completed && !Volatile.Read(ref isComplete))
			{
				return FetchDataRequest.Status.InProgress;
			}
			return dataSource.State;
		}
	}

	public FetchDataRequest(FetchDataRequest dataSource)
	{
		FetchDataRequest<T> fetchDataRequest = this;
		this.dataSource = dataSource;
		if (dataSource == null)
		{
			Debug.LogError("Data source is null");
			isComplete = true;
			return;
		}
		dataSource.RunOnFetchComplete(delegate(FetchDataRequest fetchResult)
		{
			Task.Run(delegate
			{
				try
				{
					List<RestorePointFileWrapper> list = fetchResult?.RestorePoints;
					if (list != null && list.Count != 0)
					{
						RestorePointFileWrapper[] array = list.Where(delegate(RestorePointFileWrapper rp)
						{
							if (rp == null)
							{
								Debug.LogError(dataSource.Name + " failed to load restore point");
								return false;
							}
							if (rp.data == null)
							{
								Debug.LogError(dataSource.Name + " is missing data");
								return false;
							}
							return true;
						}).ToArray();
						if (array.Length != 0)
						{
							ConcurrentBag<FetchResult> bag = new ConcurrentBag<FetchResult>();
							Parallel.ForEach(array, new ParallelOptions
							{
								MaxDegreeOfParallelism = Math.Max(1, Environment.ProcessorCount - 1)
							}, delegate(RestorePointFileWrapper rp)
							{
								FetchResult fetchResult2 = TryMakeResult(rp);
								if (fetchResult2 != null)
								{
									bag.Add(fetchResult2);
								}
							});
							lock (fetchDataRequest.results)
							{
								if (!bag.IsEmpty)
								{
									fetchDataRequest.results.AddRange(bag);
								}
							}
							fetchDataRequest.results.Sort((FetchResult a, FetchResult b) => b.order.CompareTo(a.order));
						}
					}
				}
				catch (Exception message)
				{
					Debug.LogError(message);
				}
				finally
				{
					fetchDataRequest.isComplete = true;
				}
			});
		});
	}

	private static FetchResult TryMakeResult(RestorePointFileWrapper sourceData)
	{
		try
		{
			string jsonForSaveBytesStatic = GameManager.GetJsonForSaveBytesStatic(sourceData.data);
			if (string.IsNullOrEmpty(jsonForSaveBytesStatic))
			{
				Debug.LogError("Failed to load json from bytes.");
				return null;
			}
			T val = SaveDataUtility.DeserializeSaveData<T>(jsonForSaveBytesStatic);
			if (val == null)
			{
				Debug.LogError("Failed to load " + typeof(T).Name + " from " + jsonForSaveBytesStatic + ".");
				return null;
			}
			return new FetchResult(sourceData)
			{
				loadedObject = val,
				order = sourceData.number
			};
		}
		catch (Exception message)
		{
			Debug.LogError(message);
			return null;
		}
	}
}
