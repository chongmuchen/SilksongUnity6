using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	public class MatchAudioSourceTime : FsmStateAction
	{
		public FsmGameObject SourceAudio;

		public FsmGameObject TargetAudio;

		public bool everyFrame;

		public override void Reset()
		{
			SourceAudio = null;
			TargetAudio = null;
			everyFrame = false;
		}

		public override void OnEnter()
		{
			AudioSource component = SourceAudio.Value.GetComponent<AudioSource>();
			AudioSource component2 = SourceAudio.Value.GetComponent<AudioSource>();
			if ((bool)component && (bool)component2)
			{
				component2.time = component.time;
			}
			Finish();
		}
	}
}
