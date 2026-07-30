using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public sealed class EnsureSnapshotRestore : MonoBehaviour
{
	private const float DEFAULT_TRANSITION = 0.25f;

	private HashSet<AudioMixerSnapshot> snapshots = new HashSet<AudioMixerSnapshot>();

	private void OnDisable()
	{
		foreach (AudioMixerSnapshot snapshot in snapshots)
		{
			if (!(snapshot == null))
			{
				snapshot.TransitionTo(0.25f);
			}
		}
		snapshots.Clear();
	}

	public void Add(AudioMixerSnapshot audioMixerSnapshot)
	{
		snapshots.Add(audioMixerSnapshot);
	}

	public void Remove(AudioMixerSnapshot audioMixerSnapshot)
	{
		snapshots.Remove(audioMixerSnapshot);
	}
}
