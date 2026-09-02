using UnityEngine;

public class Tk2dSpriteSetKeywords : MonoBehaviour
{
	[SerializeField]
	private tk2dSprite sprite;

	[SerializeField]
	private string[] keywords;

	private void Reset()
	{
		sprite = GetComponent<tk2dSprite>();
	}

	private void Awake()
	{
		if (sprite == null)
		{
			sprite = GetComponent<tk2dSprite>();
			if (sprite == null)
			{
				base.enabled = false;
				return;
			}
		}
		string[] array = keywords;
		foreach (string keyword in array)
		{
			sprite.EnableKeyword(keyword);
		}
	}
}
