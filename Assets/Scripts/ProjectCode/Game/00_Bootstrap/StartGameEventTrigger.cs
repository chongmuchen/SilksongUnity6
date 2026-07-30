using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;

public class StartGameEventTrigger : MenuButtonListCondition, ISubmitHandler, IEventSystemHandler, IPointerClickHandler
{
	[SerializeField]
	private bool permaDeath;

	[SerializeField]
	private bool bossRush;

	private bool hasTriggered;

	private readonly List<StartGameEventTrigger> others = new List<StartGameEventTrigger>();

	private void OnDisable()
	{
		hasTriggered = false;
	}

	private void Start()
	{
		foreach (Transform item in base.transform.parent)
		{
			StartGameEventTrigger component = item.GetComponent<StartGameEventTrigger>();
			if ((bool)component)
			{
				others.Add(component);
			}
		}
	}

	public void OnSubmit(BaseEventData eventData)
	{
		if (hasTriggered)
		{
			return;
		}
		hasTriggered = true;
		foreach (StartGameEventTrigger other in others)
		{
			other.hasTriggered = true;
		}
		UIManager.instance.StartNewGame(permaDeath, bossRush);
	}

	public void OnPointerClick(PointerEventData eventData)
	{
		OnSubmit(eventData);
	}

	public override bool IsFulfilled()
	{
		bool result = true;
		if (permaDeath && GameManager.instance.GetStatusRecordInt("RecPermadeathMode") == 0)
		{
			result = false;
		}
		if (bossRush && GameManager.instance.GetStatusRecordInt("RecBossRushMode") == 0)
		{
			result = false;
		}
		return result;
	}
}
