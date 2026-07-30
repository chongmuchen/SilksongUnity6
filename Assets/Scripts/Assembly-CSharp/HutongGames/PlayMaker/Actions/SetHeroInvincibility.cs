using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	public class SetHeroInvincibility : FsmStateAction
	{
		public FsmOwnerDefault Target;

		public FsmBool Invincible;

		public override void Reset()
		{
			Target = null;
			Invincible = null;
		}

		public override void OnEnter()
		{
			GameObject safe = Target.GetSafe(this);
			if (safe == null)
			{
				safe = base.Owner;
			}
			if (safe != null)
			{
				safe.AddComponentIfNotPresent<HeroInvincibilitySource>().SetInvincible(Invincible.Value);
			}
			Finish();
		}
	}
}
