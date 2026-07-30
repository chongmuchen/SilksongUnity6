using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	public class SetDamageHeroAndRecord : FsmStateAction
	{
		[UIHint(UIHint.Variable)]
		public FsmOwnerDefault Target;

		[RequiredField]
		public new FsmBool Enabled;

		public override void Reset()
		{
			Target = null;
			Enabled = null;
		}

		public override void OnEnter()
		{
			GameObject safe = Target.GetSafe(this);
			if (safe != null)
			{
				DamageHero component = safe.GetComponent<DamageHero>();
				if (component != null)
				{
					DamageHero.ToggleDamaged(component, Enabled.Value);
				}
			}
			Finish();
		}
	}
}
