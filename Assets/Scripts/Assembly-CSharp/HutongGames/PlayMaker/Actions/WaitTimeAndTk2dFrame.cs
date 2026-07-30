using System;
using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	public class WaitTimeAndTk2dFrame : FsmStateAction
	{
		[CheckForComponent(typeof(tk2dSpriteAnimator))]
		public FsmOwnerDefault Tk2dAnimator;

		[RequiredField]
		public FsmFloat Time;

		public FsmEvent FinishEvent;

		private float timer;

		private bool queuedEnd;

		private tk2dSpriteAnimator animator;

		public override void Reset()
		{
			Tk2dAnimator = null;
			Time = 1f;
			FinishEvent = null;
		}

		public override void OnEnter()
		{
			if (Time.Value <= 0f)
			{
				base.Fsm.Event(FinishEvent);
				Finish();
				return;
			}
			timer = 0f;
			queuedEnd = false;
			GameObject safe = Tk2dAnimator.GetSafe(this);
			animator = (safe ? safe.GetComponent<tk2dSpriteAnimator>() : null);
			if (animator == null)
			{
				Debug.LogError("Tk2d animator was null", base.Owner);
				Finish();
			}
			tk2dSpriteAnimator obj = animator;
			obj.FrameChanged = (Action<tk2dSpriteAnimator, tk2dSpriteAnimationClip, int, int>)Delegate.Combine(obj.FrameChanged, new Action<tk2dSpriteAnimator, tk2dSpriteAnimationClip, int, int>(OnFrameChanged));
			tk2dSpriteAnimator obj2 = animator;
			obj2.AnimationCompleted = (Action<tk2dSpriteAnimator, tk2dSpriteAnimationClip>)Delegate.Combine(obj2.AnimationCompleted, new Action<tk2dSpriteAnimator, tk2dSpriteAnimationClip>(OnAnimationCompleted));
		}

		public override void OnUpdate()
		{
			if (queuedEnd)
			{
				return;
			}
			timer += UnityEngine.Time.deltaTime;
			if (timer >= Time.Value)
			{
				if (animator.Playing)
				{
					queuedEnd = true;
				}
				else
				{
					End();
				}
			}
		}

		public override void OnExit()
		{
			if ((bool)animator)
			{
				tk2dSpriteAnimator obj = animator;
				obj.FrameChanged = (Action<tk2dSpriteAnimator, tk2dSpriteAnimationClip, int, int>)Delegate.Remove(obj.FrameChanged, new Action<tk2dSpriteAnimator, tk2dSpriteAnimationClip, int, int>(OnFrameChanged));
				tk2dSpriteAnimator obj2 = animator;
				obj2.AnimationCompleted = (Action<tk2dSpriteAnimator, tk2dSpriteAnimationClip>)Delegate.Remove(obj2.AnimationCompleted, new Action<tk2dSpriteAnimator, tk2dSpriteAnimationClip>(OnAnimationCompleted));
			}
		}

		private void End()
		{
			Finish();
			if (FinishEvent != null)
			{
				base.Fsm.Event(FinishEvent);
			}
		}

		private void OnFrameChanged(tk2dSpriteAnimator eventAnimator, tk2dSpriteAnimationClip clip, int previousFrame, int currentFrame)
		{
			if (queuedEnd)
			{
				End();
			}
		}

		private void OnAnimationCompleted(tk2dSpriteAnimator arg1, tk2dSpriteAnimationClip arg2)
		{
			if (queuedEnd)
			{
				End();
			}
		}
	}
}
