using System;
using System.Collections.Generic;
using UnityEngine;

public class CheatCodeListener : MonoBehaviour
{
	private enum InputAction
	{
		Up = 0,
		Down = 1,
		Left = 2,
		Right = 3
	}

	private class CheatCode
	{
		public InputAction[] Sequence;

		public Action<CheatCodeListener> Response;
	}

	[SerializeField]
	private GameObject permadeathUnlockEffect;

	private readonly CheatCode[] cheatCodes = new CheatCode[1]
	{
		new CheatCode
		{
			Sequence = new InputAction[8]
			{
				InputAction.Up,
				InputAction.Down,
				InputAction.Up,
				InputAction.Down,
				InputAction.Left,
				InputAction.Right,
				InputAction.Left,
				InputAction.Right
			},
			Response = delegate(CheatCodeListener listener)
			{
				if (GameManager.instance.GetStatusRecordInt("RecPermadeathMode") == 0)
				{
					PermadeathUnlock.Unlock();
					UnityEngine.Object.Instantiate(listener.permadeathUnlockEffect);
				}
			}
		}
	};

	private readonly List<InputAction> currentSequence = new List<InputAction>();

	private HeroActions ia;

	private void Awake()
	{
		ia = ManagerSingleton<InputHandler>.Instance.inputActions;
	}

	private void OnEnable()
	{
		currentSequence.Clear();
	}

	private void Update()
	{
		int count = currentSequence.Count;
		if (ia.Up.WasPressed)
		{
			currentSequence.Add(InputAction.Up);
		}
		if (ia.Down.WasPressed)
		{
			currentSequence.Add(InputAction.Down);
		}
		if (ia.Left.WasPressed)
		{
			currentSequence.Add(InputAction.Left);
		}
		if (ia.Right.WasPressed)
		{
			currentSequence.Add(InputAction.Right);
		}
		if (currentSequence.Count <= count)
		{
			return;
		}
		CheatCode cheatCode = null;
		int num = 0;
		CheatCode[] array = cheatCodes;
		foreach (CheatCode cheatCode2 in array)
		{
			int num2 = Mathf.Min(currentSequence.Count, cheatCode2.Sequence.Length);
			bool flag = false;
			for (int j = 0; j < num2; j++)
			{
				if (cheatCode2.Sequence[j] != currentSequence[j])
				{
					flag = true;
					num++;
					break;
				}
			}
			if (!flag && currentSequence.Count >= cheatCode2.Sequence.Length)
			{
				cheatCode = cheatCode2;
				break;
			}
		}
		if (num >= cheatCodes.Length)
		{
			Debug.Log("All cheat codes failed");
			currentSequence.Clear();
		}
		if (cheatCode != null)
		{
			Debug.Log("Cheat code succeeded");
			cheatCode.Response(this);
			currentSequence.Clear();
		}
	}
}
