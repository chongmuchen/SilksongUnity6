using System;
using System.Collections.Generic;
using UnityEngine;

public class CoreLoop : MonoBehaviour
{
	// 一条按不受 Time.timeScale 影响的时间延后执行的任务。
	private class DelayedInvoke
	{
		public float TimeRemaining;

		public Action Action;
	}

	private static CoreLoop instance;

	// 下一批要在主线程执行的任务。执行回调期间新加入的任务会留到下一批。
	private static List<Action> invokeNextActions = new List<Action>();

	// 当前正在执行的任务缓冲区；与 invokeNextActions 交换使用，避免重复分配列表。
	private static List<Action> invokeNextActionsBuffer = new List<Action>();

	// 防止同一批任务被重复注册到 Unity 的消息循环。
	private static bool isFiringInvokeNext = false;

	private static List<DelayedInvoke> delayedInvokes = new List<DelayedInvoke>();

	private static readonly object invokeOnGameThreadMutex = new object();

	// 由任意线程提交、等待主线程接收的任务。访问时必须持有 invokeOnGameThreadMutex。
	private static List<Action> pendingActions = new List<Action>();

	// 主线程已经接收的任务缓冲区；与 pendingActions 交换使用，缩短持锁时间。
	private static List<Action> executingActions = new List<Action>();

	[RuntimeInitializeOnLoadMethod(RuntimeInitializeLoadType.BeforeSceneLoad)]
	private static void Init()
	{
		GameObject coreLoopObject = new GameObject("CoreLoop");
		instance = coreLoopObject.AddComponent<CoreLoop>();
		UnityEngine.Object.DontDestroyOnLoad(coreLoopObject);
	}

	/// <summary>
	/// 将任务加入下一次主线程回调。此方法本身不提供跨线程同步。
	/// </summary>
	public static void InvokeNext(Action action)
	{
		invokeNextActions.Add(action);
		EnqueueInvokeNext();
	}

	/// <summary>
	/// 忽略空任务，并将有效任务安全地提交给主线程。
	/// </summary>
	public static void InvokeSafe(Action action)
	{
		if (action != null)
		{
			InvokeOnGameThread(action);
		}
	}

	private static void EnqueueInvokeNext()
	{
		if (!isFiringInvokeNext)
		{
			isFiringInvokeNext = true;
			instance.Invoke(nameof(FireInvokeNext), 0f);
		}
	}

	protected void FireInvokeNext()
	{
		isFiringInvokeNext = false;

		// 先交换生产队列和执行缓冲区。回调执行期间产生的新任务不会修改当前遍历的列表。
		List<Action> actionsToExecute = invokeNextActions;
		invokeNextActions = invokeNextActionsBuffer;
		invokeNextActionsBuffer = actionsToExecute;

		for (int i = 0; i < invokeNextActionsBuffer.Count; i++)
		{
			Action action = invokeNextActionsBuffer[i];
			if (action != null)
			{
				try
				{
					action();
				}
				catch (Exception exception)
				{
					Debug.LogException(exception);
				}
			}
		}
		invokeNextActionsBuffer.Clear();
	}

	/// <summary>
	/// 从任意线程提交任务。任务会由主线程的 Update 接收并安排执行。
	/// </summary>
	public static void InvokeOnGameThread(Action action)
	{
		lock (invokeOnGameThreadMutex)
		{
			pendingActions.Add(action);
		}
	}

	protected void Update()
	{
		// 锁内只交换列表，不执行用户回调，避免长时间阻塞提交任务的线程。
		lock (invokeOnGameThreadMutex)
		{
			List<Action> actionsToSchedule = pendingActions;
			pendingActions = executingActions;
			executingActions = actionsToSchedule;
		}

		if (executingActions.Count > 0)
		{
			for (int i = 0; i < executingActions.Count; i++)
			{
				InvokeNext(executingActions[i]);
			}
			executingActions.Clear();
		}

		// 正向遍历时同步回退索引，确保删除到期项后不会跳过其后一项。
		for (int j = 0; j < delayedInvokes.Count; j++)
		{
			DelayedInvoke delayedInvoke = delayedInvokes[j];
			delayedInvoke.TimeRemaining -= Time.unscaledDeltaTime;
			if (delayedInvoke.TimeRemaining <= 0f)
			{
				delayedInvokes.RemoveAt(j--);
				InvokeNext(delayedInvoke.Action);
			}
		}
	}
}
