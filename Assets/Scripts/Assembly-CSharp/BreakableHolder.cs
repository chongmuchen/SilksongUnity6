using System;
using GlobalSettings;
using TeamCherry.SharedUtils;
using UnityEngine;
using UnityEngine.Events;

public class BreakableHolder : DebugDrawColliderRuntimeAdder, IHitResponder, IBreakerBreakable
{
	private enum HitDirection
	{
		Left = 0,
		Right = 1,
		Down = 2
	}

	[Serializable]
	private struct ObjectFling
	{
		public GameObject Object;

		public MinMaxFloat LeftAngleRange;

		public MinMaxFloat RightAngleRange;

		public MinMaxFloat FlingSpeedRange;
	}

	[SerializeField]
	private PersistentIntItem persistent;

	[Space]
	[SerializeField]
	private int finalPayout;

	[SerializeField]
	private int payoutPerHit;

	[SerializeField]
	private int totalHits;

	private int hitsLeft;

	[SerializeField]
	private float hitCooldown = 0.15f;

	private double lastHitTime;

	private bool isBroken;

	[SerializeField]
	private bool resetHitsOnBreak;

	[SerializeField]
	private float noiseRadius = 3f;

	[SerializeField]
	private Probability.ProbabilityGameObject[] holdingGameObjects;

	[SerializeField]
	private ObjectFling[] debrisParts;

	[SerializeField]
	private Vector3 originOffset;

	[SerializeField]
	private MinMaxFloat rightAngleRange;

	[SerializeField]
	private MinMaxFloat leftAngleRange;

	[SerializeField]
	private float angleOffset;

	[SerializeField]
	private MinMaxFloat flingSpeedRange;

	[Space]
	[SerializeField]
	private bool canBreakFromBreaker = true;

	[SerializeField]
	private Breakable forwardToBreakable;

	[Space]
	[SerializeField]
	private GameObject strikePrefab;

	[SerializeField]
	private GameObject breakPrefab;

	[SerializeField]
	private GameObject hitFlingPrefab;

	[SerializeField]
	private GameObject hitDustPrefab;

	[SerializeField]
	private CameraShakeTarget hitCameraShake;

	[SerializeField]
	private CameraShakeTarget breakCameraShake;

	[SerializeField]
	public bool noHitShake;

	[SerializeField]
	private AudioSource audioPlayerPrefab;

	[SerializeField]
	private AudioEventRandom breakSound;

	[SerializeField]
	private AudioEventRandom hitSound;

	[SerializeField]
	private RandomAudioClipTable hitSoundTable;

	[Space]
	public UnityEvent Break;

	public UnityEvent Broken;

	public UnityEvent HitStarted;

	public UnityEvent HitEnded;

	private GameObject breakEffects;

	public BreakableBreaker.BreakableTypes BreakableType => BreakableBreaker.BreakableTypes.Basic;

	GameObject IBreakerBreakable.gameObject => base.gameObject;

	protected override void Awake()
	{
		base.Awake();
		if (!GetComponent<PersonalObjectPool>())
		{
			PersonalObjectPool personalObjectPool = base.gameObject.AddComponent<PersonalObjectPool>();
			Probability.ProbabilityGameObject[] array = holdingGameObjects;
			foreach (Probability.ProbabilityGameObject probabilityGameObject in array)
			{
				personalObjectPool.startupPool.Add(new StartupPool
				{
					prefab = probabilityGameObject.Prefab,
					initialiseSpawnedObjects = true,
					size = finalPayout + payoutPerHit * totalHits
				});
			}
		}
	}

	private void OnEnable()
	{
		ResetHits();
	}

	private void Start()
	{
		if ((bool)persistent)
		{
			persistent.OnGetSaveState += delegate(out int value)
			{
				value = hitsLeft;
				if ((bool)forwardToBreakable)
				{
					forwardToBreakable.SetHitsToBreak(hitsLeft);
				}
			};
			persistent.OnSetSaveState += delegate(int value)
			{
				hitsLeft = value;
				if (hitsLeft <= 0)
				{
					SetBroken();
					if ((bool)forwardToBreakable)
					{
						forwardToBreakable.SetAlreadyBroken();
					}
				}
			};
		}
		if ((bool)forwardToBreakable)
		{
			forwardToBreakable.SetHitsToBreak(hitsLeft);
			float num = forwardToBreakable.GetHitCoolDown();
			if (num > 0f)
			{
				hitCooldown = ((hitCooldown > 0f) ? Mathf.Min(hitCooldown, num) : num);
				num = Mathf.Min(hitCooldown, num);
			}
			forwardToBreakable.SetHitCoolDownDuration(num);
		}
		if (breakPrefab != null)
		{
			Transform transform = base.transform;
			breakEffects = UnityEngine.Object.Instantiate(breakPrefab, transform.position, transform.rotation);
			breakEffects.SetActive(value: false);
		}
	}

	public IHitResponder.HitResponse Hit(HitInstance damageInstance)
	{
		return DoHit(damageInstance.AttackType, damageInstance.Direction, damageInstance.Source, damageInstance.MagnitudeMultiplier) ? IHitResponder.Response.GenericHit : IHitResponder.Response.None;
	}

	private bool DoHit(AttackTypes attackType, float direction, GameObject source, float flingMultiplier)
	{
		if (hitsLeft <= 0)
		{
			return false;
		}
		bool flag;
		if (attackType == AttackTypes.Heavy)
		{
			hitsLeft--;
			flag = true;
		}
		else
		{
			if (lastHitTime > Time.timeAsDouble)
			{
				return false;
			}
			lastHitTime = Time.timeAsDouble + (double)hitCooldown;
			hitsLeft--;
			flag = hitsLeft <= 0;
		}
		DoHitWithPayout(flag, direction, source.transform.position.x > base.transform.position.x, flingMultiplier);
		if (!flag)
		{
			return true;
		}
		SetBroken();
		if ((bool)forwardToBreakable)
		{
			forwardToBreakable.BreakSelf();
		}
		return true;
	}

	private void DoHitWithPayout(bool doBreak, float direction, bool isFromRight, float flingMultiplier)
	{
		if ((bool)strikePrefab)
		{
			strikePrefab.Spawn(base.transform.position);
		}
		FlingHolding(payoutPerHit, isFromRight, flingMultiplier);
		DoHit(doBreak, direction, isFromRight, flingMultiplier);
	}

	private void DoHit(bool doBreak, float direction, bool isFromRight, float flingMultiplier)
	{
		if (doBreak)
		{
			while (hitsLeft > 0)
			{
				hitsLeft--;
				FlingHolding(payoutPerHit, isFromRight, flingMultiplier);
			}
			breakCameraShake.DoShake(this);
			breakSound.SpawnAndPlayOneShot(audioPlayerPrefab, base.transform.position);
			FlingHolding(finalPayout, isFromRight, flingMultiplier);
			if ((bool)breakEffects)
			{
				breakEffects.transform.position = base.transform.position;
				breakEffects.SetActive(value: true);
			}
			Break.Invoke();
			ObjectFling[] array = debrisParts;
			for (int i = 0; i < array.Length; i++)
			{
				ObjectFling objectFling = array[i];
				if ((bool)objectFling.Object)
				{
					objectFling.Object.SetActive(value: true);
					MinMaxFloat minMaxFloat = (isFromRight ? objectFling.RightAngleRange : objectFling.LeftAngleRange);
					FlingUtils.FlingObject(new FlingUtils.SelfConfig
					{
						Object = objectFling.Object,
						SpeedMin = objectFling.FlingSpeedRange.Start,
						SpeedMax = objectFling.FlingSpeedRange.End,
						AngleMin = minMaxFloat.Start,
						AngleMax = minMaxFloat.End
					}, base.transform, Vector3.zero);
				}
			}
			return;
		}
		hitCameraShake.DoShake(this);
		if ((bool)hitSoundTable)
		{
			hitSoundTable.SpawnAndPlayOneShot(base.transform.position);
		}
		else
		{
			hitSound.SpawnAndPlayOneShot(audioPlayerPrefab, base.transform.position);
		}
		HitDirection hitDirection = HitDirection.Down;
		if (direction < 45f)
		{
			hitDirection = HitDirection.Right;
		}
		else if (direction < 135f)
		{
			hitDirection = HitDirection.Down;
		}
		else if (direction < 225f)
		{
			hitDirection = HitDirection.Left;
		}
		switch (hitDirection)
		{
		case HitDirection.Right:
			if (!base.transform.eulerAngles.z.IsWithinTolerance(10f, 270f))
			{
				DoHitEffects(20f, 40f, new Vector3(0f, 90f, 270f));
			}
			break;
		case HitDirection.Left:
			if (!base.transform.eulerAngles.x.IsWithinTolerance(10f, 90f))
			{
				DoHitEffects(100f, 140f, new Vector3(180f, 90f, 270f));
			}
			break;
		case HitDirection.Down:
			if (!base.transform.eulerAngles.z.IsWithinTolerance(10f, 180f))
			{
				DoHitEffects(70f, 110f, new Vector3(-90f, -180f, -180f));
			}
			break;
		}
		HitStarted.Invoke();
		Vector3 initialPosition = base.transform.position;
		if (!noHitShake)
		{
			this.StartTimerRoutine(0f, 0.2f, delegate(float time)
			{
				Vector3 vector = new Vector3(UnityEngine.Random.Range(-0.05f, 0.05f), UnityEngine.Random.Range(-0.05f, 0.05f));
				base.transform.position = Vector3.Lerp(initialPosition + vector, initialPosition, time);
			}, null, delegate
			{
				HitEnded.Invoke();
			});
		}
	}

	private void DoHitEffects(float pAngleMin, float pAngleMax, Vector3 dustRotation)
	{
		if ((bool)hitFlingPrefab)
		{
			FlingUtils.SpawnAndFling(new FlingUtils.Config
			{
				Prefab = hitFlingPrefab,
				AmountMin = 3,
				AmountMax = 5,
				SpeedMin = 15f,
				SpeedMax = 20f,
				AngleMin = pAngleMin,
				AngleMax = pAngleMax,
				OriginVariationX = 0.25f,
				OriginVariationY = 0.25f
			}, base.transform, Vector3.zero);
		}
		if ((bool)hitDustPrefab)
		{
			hitDustPrefab.Spawn(base.transform.position + new Vector3(0f, 0f, 0.1f), Quaternion.Euler(dustRotation));
		}
	}

	private void SetBroken()
	{
		if (!isBroken)
		{
			isBroken = true;
			Broken.Invoke();
			NoiseMaker.CreateNoise(base.transform.position, noiseRadius, NoiseMaker.Intensities.Normal);
			Collider2D component = GetComponent<Collider2D>();
			if ((bool)component)
			{
				component.enabled = false;
			}
			if (resetHitsOnBreak)
			{
				ResetHits();
			}
		}
	}

	private void ResetHits()
	{
		isBroken = false;
		hitsLeft = totalHits;
	}

	private void FlingHolding(int amount, bool isDirectionRight, float flingMultiplier)
	{
		GameObject randomGameObjectByProbability = Probability.GetRandomGameObjectByProbability(holdingGameObjects);
		if ((bool)randomGameObjectByProbability)
		{
			Vector3 lossyScale = base.transform.lossyScale;
			if (lossyScale.x < 0f)
			{
				isDirectionRight = !isDirectionRight;
			}
			if (lossyScale.y < 0f)
			{
				isDirectionRight = !isDirectionRight;
			}
			MinMaxFloat relativeAngleRange = GetRelativeAngleRange(isDirectionRight ? rightAngleRange : leftAngleRange);
			if (Gameplay.IsShellShardPrefab(randomGameObjectByProbability))
			{
				FlingUtils.SpawnAndFlingShellShards(new FlingUtils.Config
				{
					Prefab = randomGameObjectByProbability,
					AmountMin = amount,
					AmountMax = amount,
					SpeedMin = flingSpeedRange.Start * flingMultiplier,
					SpeedMax = flingSpeedRange.End * flingMultiplier,
					AngleMin = relativeAngleRange.Start,
					AngleMax = relativeAngleRange.End,
					OriginVariationX = 0.25f,
					OriginVariationY = 0.25f
				}, base.transform, originOffset);
			}
			else
			{
				FlingUtils.SpawnAndFling(new FlingUtils.Config
				{
					Prefab = randomGameObjectByProbability,
					AmountMin = amount,
					AmountMax = amount,
					SpeedMin = flingSpeedRange.Start * flingMultiplier,
					SpeedMax = flingSpeedRange.End * flingMultiplier,
					AngleMin = relativeAngleRange.Start,
					AngleMax = relativeAngleRange.End,
					OriginVariationX = 0.25f,
					OriginVariationY = 0.25f
				}, base.transform, originOffset);
			}
		}
	}

	private void OnDrawGizmosSelected()
	{
		Vector3 position = base.transform.TransformPoint(originOffset);
		HandleHelper.Draw2DAngle(position, GetRelativeAngleRange(leftAngleRange).Start, GetRelativeAngleRange(leftAngleRange).End, 1f);
		HandleHelper.Draw2DAngle(position, GetRelativeAngleRange(rightAngleRange).Start, GetRelativeAngleRange(rightAngleRange).End, 1f);
	}

	private MinMaxFloat GetRelativeAngleRange(MinMaxFloat angleRange)
	{
		float num = angleOffset * Mathf.Sign(base.transform.localScale.x);
		float num2 = base.transform.eulerAngles.z + num;
		return new MinMaxFloat(angleRange.Start + num2, angleRange.End + num2);
	}

	public void BreakFromBreaker(BreakableBreaker breaker)
	{
		if (canBreakFromBreaker && !isBroken)
		{
			bool flag = breaker.transform.position.x > base.transform.position.x;
			float direction = ((!flag) ? 1 : (-1));
			if ((bool)strikePrefab)
			{
				strikePrefab.Spawn(base.transform.position);
			}
			DoHit(doBreak: true, direction, flag, 1f);
			SetBroken();
			if ((bool)forwardToBreakable)
			{
				forwardToBreakable.BreakSelf();
			}
		}
	}

	public void HitFromBreaker(BreakableBreaker breaker)
	{
		if (canBreakFromBreaker)
		{
			float direction = ((breaker.transform.position.x > base.transform.position.x) ? 180 : 0);
			DoHit(AttackTypes.Generic, direction, breaker.gameObject, 1f);
		}
	}

	public override void AddDebugDrawComponent()
	{
		DebugDrawColliderRuntime.AddOrUpdate(base.gameObject);
	}
}
