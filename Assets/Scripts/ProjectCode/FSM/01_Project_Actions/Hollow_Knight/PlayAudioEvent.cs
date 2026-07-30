using System;
using HutongGames.PlayMaker;
using UnityEngine;

[ActionCategory("Hollow Knight")]
public class PlayAudioEvent : PlayAudioEventBase
{
	[ObjectType(typeof(AudioClip))]
	public FsmObject audioClip;

	public override void Reset()
	{
		base.Reset();
		audioClip = null;
	}

	protected override AudioSource SpawnAudioEvent(Vector3 position, Action onRecycle)
	{
		AudioEvent audioEvent = new AudioEvent
		{
			Clip = (audioClip.Value as AudioClip),
			PitchMin = pitchMin.Value,
			PitchMax = pitchMax.Value,
			Volume = volume.Value
		};
		if (audioPlayerPrefab.IsNone)
		{
			return audioEvent.SpawnAndPlayOneShot(position, onRecycle);
		}
		return audioEvent.SpawnAndPlayOneShot(audioPlayerPrefab.Value as AudioSource, position, onRecycle);
	}
}
