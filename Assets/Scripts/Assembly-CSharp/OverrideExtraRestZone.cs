using GlobalEnums;
using UnityEngine;

public class OverrideExtraRestZone : MonoBehaviour
{
	public ExtraRestZones extraRestZone;

	private void Start()
	{
		GameManager.instance.GetSceneManagerComponent().extraRestZone = extraRestZone;
	}
}
