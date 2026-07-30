using UnityEngine;

namespace HutongGames.PlayMaker.Actions
{
	public class HeroStealEnemyCurrency : FsmStateAction
	{
		public FsmOwnerDefault Enemy;

		public override void Reset()
		{
			Enemy = null;
		}

		public override void OnEnter()
		{
			GameObject safe = Enemy.GetSafe(this);
			if ((bool)safe)
			{
				HealthManager componentInParent = safe.GetComponentInParent<HealthManager>();
				if ((bool)componentInParent)
				{
					componentInParent.DoStealHit();
				}
			}
			Finish();
		}
	}
}
