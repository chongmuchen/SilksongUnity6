using TeamCherry.SharedUtils;
using UnityEngine;

public class CorpseChunker : Corpse
{
	[Header("Chunker Variables")]
	[SerializeField]
	private bool instantChunker;

	[Space]
	[SerializeField]
	private GameObject effects;

	[SerializeField]
	private GameObject chunks;

	[SerializeField]
	private bool keepMeshRendererActive;

	protected override bool DoLandEffectsInstantly => instantChunker;

	protected override void LandEffects()
	{
		base.LandEffects();
		if ((bool)body)
		{
			body.linearVelocity = Vector2.zero;
		}
		splatAudioClipTable.SpawnAndPlayOneShot(audioPlayerPrefab, base.transform.position);
		BloodSpawner.SpawnBlood(base.transform.position, 30, 30, 5f, 30f, 60f, 120f);
		GameCameras instance = GameCameras.instance;
		if ((bool)instance)
		{
			instance.cameraShakeFSM.SendEvent("EnemyKillShake");
		}
		if ((bool)effects)
		{
			effects.SetActive(value: true);
		}
		if ((bool)chunks)
		{
			chunks.SetActive(value: true);
			chunks.transform.SetParent(null, worldPositionStays: true);
			FlingUtils.FlingChildren(new FlingUtils.ChildrenConfig
			{
				Parent = chunks,
				SpeedMin = 15f,
				SpeedMax = 20f,
				AngleMin = 60f,
				AngleMax = 120f,
				OriginVariationX = 0f,
				OriginVariationY = 0f
			}, base.transform, Vector3.zero, new MinMaxFloat(0f, 0.001f));
		}
		if ((bool)meshRenderer && !keepMeshRendererActive)
		{
			meshRenderer.enabled = false;
		}
	}
}
