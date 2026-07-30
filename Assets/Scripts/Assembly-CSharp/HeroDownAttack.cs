using System.Collections.Generic;
using GlobalEnums;
using UnityEngine;

public class HeroDownAttack : MonoBehaviour
{
	private HeroController hc;

	private NailAttackBase attack;

	private bool bounceQueued;

	private Collider2D lastCollider;

	private HashSet<GameObject> damagedGameObjects = new HashSet<GameObject>();

	private void Awake()
	{
		hc = HeroController.instance;
		attack = GetComponent<NailAttackBase>();
		attack.AttackStarting += OnAttackStarting;
		attack.EndedDamage += OnEndedDamage;
		attack.EnemyDamager.HitResponded += OnHitResponded;
	}

	private void OnTriggerEnter2D(Collider2D otherCollider)
	{
		if ((bool)attack && attack.IsDamagerActive && (bool)otherCollider)
		{
			GameObject gameObject = otherCollider.gameObject;
			PhysLayers layer = (PhysLayers)gameObject.layer;
			bool flag = attack.EnemyDamager.manualTrigger && layer == PhysLayers.ENEMIES;
			if ((!flag || attack.CanDamageEnemies) && ((!flag && layer != PhysLayers.INTERACTIVE_OBJECT && layer != PhysLayers.TERRAIN && !gameObject.GetComponent<TinkEffect>() && !gameObject.GetComponentInParent<ToolBoomerang>()) || !attack.EnemyDamager.DoDamage(otherCollider)) && (flag || layer == PhysLayers.INTERACTIVE_OBJECT || layer == PhysLayers.HERO_ATTACK))
			{
				lastCollider = otherCollider;
				ContinueBounceTrigger(otherCollider.gameObject);
				lastCollider = null;
			}
		}
	}

	private static bool IsNonBounce(GameObject obj)
	{
		NonBouncer component = obj.GetComponent<NonBouncer>();
		if ((bool)component && component.active)
		{
			return true;
		}
		if ((bool)obj.GetComponent<BounceBalloon>())
		{
			return true;
		}
		return false;
	}

	private void ContinueBounceTrigger(GameObject otherObj)
	{
		if (IsNonBounce(otherObj))
		{
			return;
		}
		DamageHero component = otherObj.GetComponent<DamageHero>();
		if ((bool)component)
		{
			if (!attack.CanHitSpikes && component.hazardType == HazardType.SPIKES)
			{
				return;
			}
			if (component.hazardType <= HazardType.ENEMY && !component.noBounceCooldown && !component.GetComponent<HealthManager>())
			{
				component.SetCooldown(0.5f);
			}
			if ((bool)attack.EnemyDamager)
			{
				if (lastCollider != null)
				{
					attack.EnemyDamager.TryDoDamage(lastCollider);
				}
				else if (damagedGameObjects.Add(component.gameObject))
				{
					attack.EnemyDamager.DoDamage(component.gameObject);
				}
			}
		}
		if (hc.CanCustomRecoil())
		{
			bounceQueued = true;
			attack.QueueBounce();
		}
	}

	private void OnAttackStarting()
	{
		bounceQueued = false;
		damagedGameObjects.Clear();
	}

	private void OnEndedDamage(bool didHit)
	{
		if (!didHit)
		{
			return;
		}
		damagedGameObjects.Clear();
		if (bounceQueued)
		{
			bounceQueued = false;
			NailSlash nailSlash = attack as NailSlash;
			if (!(nailSlash == null))
			{
				hc.AffectedByGravity(gravityApplies: true);
				nailSlash.DoDownspikeBounce();
			}
		}
	}

	private void OnHitResponded(DamageEnemies.HitResponse hitResponse)
	{
		if (!attack.IsDamagerActive || hc.IsStunned)
		{
			return;
		}
		PhysLayers layer = (PhysLayers)hitResponse.Target.layer;
		if (layer != PhysLayers.TERRAIN && layer != PhysLayers.SOFT_TERRAIN && !IsNonBounce(hitResponse.Target))
		{
			hc.StartDownspikeInvulnerability();
			if (hc.CanCustomRecoil())
			{
				hc.AffectedByGravity(gravityApplies: false);
				hc.ResetVelocity();
			}
			ContinueBounceTrigger(hitResponse.Target);
		}
	}
}
