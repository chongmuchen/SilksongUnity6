using UnityEngine;
using UnityEngine.Audio;

namespace HutongGames.PlayMaker.Actions
{
	public class AudioSnapshotRestore : FsmStateAction
	{
		public enum Action
		{
			Add = 0,
			Remove = 1
		}

		[RequiredField]
		public FsmOwnerDefault owner;

		[RequiredField]
		[ObjectType(typeof(AudioMixerSnapshot))]
		public FsmObject snapshot;

		[ObjectType(typeof(Action))]
		public FsmEnum action;

		public override void Reset()
		{
			owner = null;
			snapshot = null;
		}

		public override void OnEnter()
		{
			GameObject safe = owner.GetSafe(this);
			if (safe != null)
			{
				EnsureSnapshotRestore ensureSnapshotRestore = safe.AddComponentIfNotPresent<EnsureSnapshotRestore>();
				switch ((Action)(object)action.Value)
				{
				case Action.Add:
					ensureSnapshotRestore.Add((AudioMixerSnapshot)snapshot.Value);
					break;
				default:
					ensureSnapshotRestore.Remove((AudioMixerSnapshot)snapshot.Value);
					break;
				}
			}
			Finish();
		}
	}
}
