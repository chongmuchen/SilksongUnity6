using UnityEngine;

public class DeactivateNextFrame : MonoBehaviour
{
	private int deactivateCounter;

	private void OnEnable()
	{
		deactivateCounter = 0;
	}

	private void Update()
	{
		if (deactivateCounter == 1)
		{
			deactivateCounter = 2;
		}
		else if (deactivateCounter == 2)
		{
			deactivateCounter = 0;
			base.gameObject.SetActive(value: false);
		}
	}

	public void DoDeactivateNextFrame()
	{
		deactivateCounter = 1;
	}
}
