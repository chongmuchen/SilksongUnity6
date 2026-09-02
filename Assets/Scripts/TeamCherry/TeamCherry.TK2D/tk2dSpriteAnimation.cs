using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("2D Toolkit/Backend/tk2dSpriteAnimation")]
public class tk2dSpriteAnimation : MonoBehaviour
{
	private struct AnimationInfo
	{
		public tk2dSpriteAnimationClip clip;

		public int id;

		public AnimationInfo(tk2dSpriteAnimationClip clip, int id)
		{
			this.clip = clip;
			this.id = id;
		}
	}

	public tk2dSpriteAnimationClip[] clips;

	private Dictionary<string, AnimationInfo> lookup = new Dictionary<string, AnimationInfo>();

	private bool isValid;

	public tk2dSpriteAnimationClip FirstValidClip
	{
		get
		{
			for (int i = 0; i < clips.Length; i++)
			{
				if (!clips[i].Empty && clips[i].frames[0].spriteCollection != null && clips[i].frames[0].spriteId != -1)
				{
					return clips[i];
				}
			}
			return null;
		}
	}

	private void Start()
	{
		ValidateLookup();
	}

	public void ValidateLookup()
	{
		if (isValid)
		{
			return;
		}
		isValid = true;
		if (clips == null)
		{
			return;
		}
		for (int i = 0; i < clips.Length; i++)
		{
			tk2dSpriteAnimationClip tk2dSpriteAnimationClip2 = clips[i];
			if (tk2dSpriteAnimationClip2 != null)
			{
				string text = tk2dSpriteAnimationClip2.name;
				if (!string.IsNullOrEmpty(text) && !lookup.TryAdd(text, new AnimationInfo(tk2dSpriteAnimationClip2, i)))
				{
					string.IsNullOrEmpty(text);
				}
			}
		}
	}

	public tk2dSpriteAnimationClip GetClipByName(string name)
	{
		ValidateLookup();
		if (lookup.TryGetValue(name, out var value))
		{
			return value.clip;
		}
		return null;
	}

	public tk2dSpriteAnimationClip GetClipById(int id)
	{
		if (id < 0 || id >= clips.Length || clips[id].Empty)
		{
			return null;
		}
		return clips[id];
	}

	public int GetClipIdByName(string name)
	{
		ValidateLookup();
		if (lookup.TryGetValue(name, out var value))
		{
			return value.id;
		}
		return -1;
	}

	public int GetClipIdByName(tk2dSpriteAnimationClip clip)
	{
		for (int i = 0; i < clips.Length; i++)
		{
			if (clips[i] == clip)
			{
				return i;
			}
		}
		return -1;
	}
}
