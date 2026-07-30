using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.UI;

public class NavigationAssigner : MonoBehaviour
{
	[SerializeField]
	private Navigation.Mode mode = Navigation.Mode.Explicit;

	[SerializeField]
	private List<Selectable> selectables = new List<Selectable>();

	[ContextMenu("Gather")]
	private void Gather()
	{
		selectables = GetComponentsInChildren<Selectable>().Union(selectables).ToList();
	}

	[ContextMenu("Assign")]
	private void AssignNavigation()
	{
		selectables.RemoveAll((Selectable o) => o == null);
		if (selectables.Count > 1)
		{
			Selectable selectOnUp = selectables[selectables.Count - 1];
			for (int num = 0; num < selectables.Count; num++)
			{
				Selectable selectable = selectables[num];
				Selectable selectOnDown = ((num < selectables.Count - 1) ? selectables[num + 1] : selectables[0]);
				Navigation navigation = selectable.navigation;
				navigation.selectOnUp = selectOnUp;
				navigation.selectOnDown = selectOnDown;
				selectable.navigation = navigation;
				selectOnUp = selectable;
			}
		}
	}
}
