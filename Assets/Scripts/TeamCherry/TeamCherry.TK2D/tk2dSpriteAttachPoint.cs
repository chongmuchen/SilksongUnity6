using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
[AddComponentMenu("2D Toolkit/Sprite/tk2dSpriteAttachPoint")]
public class tk2dSpriteAttachPoint : MonoBehaviour
{
	private tk2dBaseSprite sprite;

	public List<Transform> attachPoints = new List<Transform>();

	private static bool[] attachPointUpdated = new bool[32];

	public bool deactivateUnusedAttachPoints;

	private Dictionary<Transform, string> cachedInstanceNames = new Dictionary<Transform, string>();

	private void Awake()
	{
		if (sprite == null)
		{
			sprite = GetComponent<tk2dBaseSprite>();
			if (sprite != null)
			{
				HandleSpriteChanged(sprite);
			}
		}
	}

	private void OnEnable()
	{
		if (sprite != null)
		{
			sprite.SpriteChanged += HandleSpriteChanged;
		}
	}

	private void OnDisable()
	{
		if (sprite != null)
		{
			sprite.SpriteChanged -= HandleSpriteChanged;
		}
	}

	private void UpdateAttachPointTransform(tk2dSpriteDefinition.AttachPoint attachPoint, Transform t)
	{
		t.localPosition = Vector3.Scale(attachPoint.position, sprite.scale);
		t.localScale = sprite.scale;
		float num = Mathf.Sign(sprite.scale.x) * Mathf.Sign(sprite.scale.y);
		t.localEulerAngles = new Vector3(0f, 0f, attachPoint.angle * num);
	}

	private string GetInstanceName(Transform t)
	{
		string value = "";
		if (cachedInstanceNames.TryGetValue(t, out value))
		{
			return value;
		}
		cachedInstanceNames[t] = t.name;
		return t.name;
	}

	private void HandleSpriteChanged(tk2dBaseSprite spr)
	{
		tk2dSpriteDefinition currentSprite = spr.CurrentSprite;
		if (currentSprite == null)
		{
			Debug.LogErrorFormat("Sprite Definition was null for GameObject: {0}", spr.gameObject.name);
			return;
		}
		if (currentSprite.attachPoints == null)
		{
			Debug.LogErrorFormat("attachPoints was null for SpriteDefinition: {0}, GameObject: {1}", currentSprite.name, spr.gameObject.name);
			return;
		}
		int num = Mathf.Max(currentSprite.attachPoints.Length, attachPoints.Count);
		if (num > attachPointUpdated.Length)
		{
			attachPointUpdated = new bool[num];
		}
		tk2dSpriteDefinition.AttachPoint[] array = currentSprite.attachPoints;
		foreach (tk2dSpriteDefinition.AttachPoint attachPoint in array)
		{
			bool flag = false;
			int num2 = 0;
			for (int j = 0; j < attachPoints.Count; j++)
			{
				Transform transform = attachPoints[j];
				if (transform != null && GetInstanceName(transform) == attachPoint.name)
				{
					attachPointUpdated[num2] = true;
					UpdateAttachPointTransform(attachPoint, transform);
					flag = true;
				}
				num2++;
			}
			if (!flag)
			{
				Transform transform2 = new GameObject(attachPoint.name).transform;
				transform2.parent = base.transform;
				UpdateAttachPointTransform(attachPoint, transform2);
				attachPointUpdated[attachPoints.Count] = true;
				attachPoints.Add(transform2);
			}
		}
		if (!deactivateUnusedAttachPoints)
		{
			return;
		}
		for (int k = 0; k < attachPoints.Count; k++)
		{
			if (attachPoints[k] != null)
			{
				GameObject gameObject = attachPoints[k].gameObject;
				if (attachPointUpdated[k] && !gameObject.activeSelf)
				{
					gameObject.SetActive(value: true);
				}
				else if (!attachPointUpdated[k] && gameObject.activeSelf)
				{
					gameObject.SetActive(value: false);
				}
			}
			attachPointUpdated[k] = false;
		}
	}
}
