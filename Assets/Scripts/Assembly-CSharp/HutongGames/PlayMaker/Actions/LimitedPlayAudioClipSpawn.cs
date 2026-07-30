using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	public class LimitedPlayAudioClipSpawn : LimitedPlayAudioBase
	{
		[Space]
		[ObjectType(typeof(AudioSource))]
		public FsmObject AudioPlayerPrefab;

		[RequiredField]
		[ObjectType(typeof(AudioClip))]
		public FsmObject audioClip;

		public FsmOwnerDefault SpawnPoint;

		public FsmVector3 SpawnPosition;

		[UIHint(UIHint.Variable)]
		public FsmGameObject StoreSpawned;

		public override void Reset()
		{
			base.Reset();
			audioClip = null;
			AudioPlayerPrefab = new FsmObject
			{
				UseVariable = true
			};
			SpawnPoint = null;
			SpawnPosition = null;
			StoreSpawned = null;
		}

		protected override bool PlayAudio(out AudioSource audioSource)
		{
			StoreSpawned.Value = null;
			Vector3 value = SpawnPosition.Value;
			GameObject safe = SpawnPoint.GetSafe(this);
			if ((bool)safe)
			{
				value += safe.transform.position;
			}
			bool result = false;
			audioSource = new AudioEvent
			{
				Clip = (audioClip.Value as AudioClip),
				PitchMax = 1f,
				PitchMin = 1f,
				Volume = 1f
			}.SpawnAndPlayOneShot(AudioPlayerPrefab.Value as AudioSource, value);
			if (audioSource != null)
			{
				result = true;
				if (!StoreSpawned.IsNone)
				{
					StoreSpawned.Value = audioSource.gameObject;
				}
			}
			else
			{
				audioSource = null;
			}
			return result;
		}
	}
}
