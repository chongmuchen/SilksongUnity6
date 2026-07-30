using UnityEngine;

public class EnemyHitEffectsGhost : MonoBehaviour, IHitEffectReciever
{
	public Vector3 effectOrigin;

	[Space]
	public AudioSource audioPlayerPrefab;

	public AudioEvent enemyDamage;

	[Space]
	public GameObject ghostHitPt;

	public GameObject slashEffectGhost1;

	public GameObject slashEffectGhost2;

	private SpriteFlash spriteFlash;

	private bool didFireThisFrame;

	protected void Awake()
	{
		spriteFlash = GetComponent<SpriteFlash>();
	}

	public void ReceiveHitEffect(HitInstance hitInstance)
	{
		if (!didFireThisFrame)
		{
			FSMUtility.SendEventToGameObject(base.gameObject, "DAMAGE FLASH", isRecursive: true);
			enemyDamage.SpawnAndPlayOneShot(audioPlayerPrefab, base.transform.position);
			if ((bool)spriteFlash)
			{
				spriteFlash.FlashEnemyHit();
			}
			GameObject gameObject = ghostHitPt.Spawn(base.transform.position + effectOrigin);
			switch (DirectionUtils.GetCardinalDirection(hitInstance.Direction))
			{
			case 0:
				gameObject.transform.SetRotation2D(-22.5f);
				FlingUtils.SpawnAndFling(new FlingUtils.Config
				{
					Prefab = slashEffectGhost1,
					AmountMin = 2,
					AmountMax = 3,
					SpeedMin = 20f,
					SpeedMax = 35f,
					AngleMin = -40f,
					AngleMax = 40f,
					OriginVariationX = 0f,
					OriginVariationY = 0f
				}, base.transform, effectOrigin);
				FlingUtils.SpawnAndFling(new FlingUtils.Config
				{
					Prefab = slashEffectGhost2,
					AmountMin = 2,
					AmountMax = 3,
					SpeedMin = 20f,
					SpeedMax = 35f,
					AngleMin = -40f,
					AngleMax = 40f,
					OriginVariationX = 0f,
					OriginVariationY = 0f
				}, base.transform, effectOrigin);
				break;
			case 2:
				gameObject.transform.SetRotation2D(160f);
				FlingUtils.SpawnAndFling(new FlingUtils.Config
				{
					Prefab = slashEffectGhost1,
					AmountMin = 2,
					AmountMax = 3,
					SpeedMin = 20f,
					SpeedMax = 35f,
					AngleMin = 140f,
					AngleMax = 220f,
					OriginVariationX = 0f,
					OriginVariationY = 0f
				}, base.transform, effectOrigin);
				FlingUtils.SpawnAndFling(new FlingUtils.Config
				{
					Prefab = slashEffectGhost2,
					AmountMin = 2,
					AmountMax = 3,
					SpeedMin = 20f,
					SpeedMax = 35f,
					AngleMin = 140f,
					AngleMax = 220f,
					OriginVariationX = 0f,
					OriginVariationY = 0f
				}, base.transform, effectOrigin);
				break;
			case 1:
				gameObject.transform.SetRotation2D(70f);
				FlingUtils.SpawnAndFling(new FlingUtils.Config
				{
					Prefab = slashEffectGhost1,
					AmountMin = 2,
					AmountMax = 3,
					SpeedMin = 20f,
					SpeedMax = 35f,
					AngleMin = 50f,
					AngleMax = 130f,
					OriginVariationX = 0f,
					OriginVariationY = 0f
				}, base.transform, effectOrigin);
				FlingUtils.SpawnAndFling(new FlingUtils.Config
				{
					Prefab = slashEffectGhost2,
					AmountMin = 2,
					AmountMax = 3,
					SpeedMin = 20f,
					SpeedMax = 35f,
					AngleMin = 50f,
					AngleMax = 130f,
					OriginVariationX = 0f,
					OriginVariationY = 0f
				}, base.transform, effectOrigin);
				break;
			case 3:
				gameObject.transform.SetRotation2D(-110f);
				FlingUtils.SpawnAndFling(new FlingUtils.Config
				{
					Prefab = slashEffectGhost1,
					AmountMin = 2,
					AmountMax = 3,
					SpeedMin = 20f,
					SpeedMax = 35f,
					AngleMin = 230f,
					AngleMax = 310f,
					OriginVariationX = 0f,
					OriginVariationY = 0f
				}, base.transform, effectOrigin);
				FlingUtils.SpawnAndFling(new FlingUtils.Config
				{
					Prefab = slashEffectGhost2,
					AmountMin = 2,
					AmountMax = 3,
					SpeedMin = 20f,
					SpeedMax = 35f,
					AngleMin = 230f,
					AngleMax = 310f,
					OriginVariationX = 0f,
					OriginVariationY = 0f
				}, base.transform, effectOrigin);
				break;
			}
			didFireThisFrame = true;
		}
	}

	protected void Update()
	{
		didFireThisFrame = false;
	}
}
