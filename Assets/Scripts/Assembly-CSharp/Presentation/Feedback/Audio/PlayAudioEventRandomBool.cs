using System;
using System.Linq;
using HutongGames.PlayMaker;
using UnityEngine;

public class PlayAudioEventRandomBool : PlayAudioEventBase
{
	[ArrayEditor(typeof(AudioClip), "", 0, 0, 65536)]
	public FsmArray audioClips;

	public FsmBool doPlay;

	public override void Reset()
	{
		base.Reset();
		audioClips = null;
		doPlay = true;
	}

	protected override AudioSource SpawnAudioEvent(Vector3 position, Action onRecycle)
	{
		if (doPlay.Value)
		{
			AudioEventRandom audioEventRandom = new AudioEventRandom
			{
				Clips = audioClips.Values.Cast<AudioClip>().ToArray(),
				PitchMin = pitchMin.Value,
				PitchMax = pitchMax.Value,
				Volume = volume.Value
			};
			if (audioPlayerPrefab.IsNone)
			{
				return audioEventRandom.SpawnAndPlayOneShot(position, onRecycle);
			}
			return audioEventRandom.SpawnAndPlayOneShot(audioPlayerPrefab.Value as AudioSource, position, onRecycle);
		}
		return null;
	}
}
