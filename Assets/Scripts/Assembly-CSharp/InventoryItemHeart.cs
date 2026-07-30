using System;
using TeamCherry.SharedUtils;
using UnityEngine;
using UnityEngine.Events;

public class InventoryItemHeart : CustomInventoryItemCollectableDisplay
{
	[Serializable]
	[Flags]
	private enum StopAudioMode
	{
		None = 0,
		OnActivate = 1,
		OnDeactivate = 2
	}

	private static readonly int _idleAnim = Animator.StringToHash("Idle");

	private static readonly int _beatAnim = Animator.StringToHash("Beat");

	private const float DEFAULT_SMOOTH_TIME = 0.05f;

	[SerializeField]
	private Animator animator;

	[SerializeField]
	private MinMaxFloat startOffsetDelay;

	[SerializeField]
	private MinMaxFloat unselectedBeatDelay;

	[SerializeField]
	private MinMaxFloat selectedBeatDelay;

	[Space]
	[SerializeField]
	private AudioLowPassFilter lowPassFilter;

	[SerializeField]
	private float selectedCutoff;

	[SerializeField]
	private float unselectedCutoff;

	[Space]
	public UnityEvent OnBeatUnselected;

	public UnityEvent OnBeatSelected;

	[SerializeField]
	private bool handleAudioPlayStop;

	[SerializeField]
	private AudioSource audioSource;

	[SerializeField]
	private StopAudioMode stopAudioMode = StopAudioMode.OnActivate | StopAudioMode.OnDeactivate;

	[SerializeField]
	private bool updateVolume;

	[SerializeField]
	private PlayRandomAudioEvent heartBeatPlayer;

	private bool isSelected;

	private float timeUntilChillBeat;

	private float timeUntilFastBeat;

	private bool hasAudioSource;

	private float originalVolume;

	private bool hasHeartBeatPlayer;

	private void Awake()
	{
		hasAudioSource = audioSource != null;
		if (!hasAudioSource)
		{
			audioSource = GetComponentInChildren<AudioSource>();
			hasAudioSource = audioSource != null;
		}
		if (hasAudioSource)
		{
			originalVolume = audioSource.volume;
		}
		hasHeartBeatPlayer = heartBeatPlayer != null;
	}

	private void Update()
	{
		bool flag = TickChill(ref timeUntilChillBeat, unselectedBeatDelay);
		bool flag2 = TickChill(ref timeUntilFastBeat, selectedBeatDelay);
		if (isSelected)
		{
			if (!flag2)
			{
				return;
			}
			if ((bool)lowPassFilter)
			{
				lowPassFilter.cutoffFrequency = selectedCutoff;
			}
			OnBeatSelected.Invoke();
		}
		else
		{
			if (!flag)
			{
				return;
			}
			if ((bool)lowPassFilter)
			{
				lowPassFilter.cutoffFrequency = unselectedCutoff;
			}
			OnBeatUnselected.Invoke();
		}
		animator.Play(_beatAnim);
	}

	private static bool TickChill(ref float timeUntilBeat, MinMaxFloat resetVal)
	{
		if (timeUntilBeat <= 0f)
		{
			return false;
		}
		timeUntilBeat -= Time.unscaledDeltaTime;
		if (timeUntilBeat > 0f)
		{
			return false;
		}
		timeUntilBeat = resetVal.GetRandomValue();
		return true;
	}

	protected override void OnActivate()
	{
		animator.Play(_idleAnim);
		timeUntilChillBeat = unselectedBeatDelay.GetRandomValue() + startOffsetDelay.GetRandomValue();
		timeUntilFastBeat = 0f;
		isSelected = false;
		if (stopAudioMode.HasFlag(StopAudioMode.OnActivate))
		{
			StopAudio();
		}
	}

	protected override void OnDeactivate()
	{
		timeUntilChillBeat = 0f;
		timeUntilFastBeat = 0f;
		isSelected = false;
		if (stopAudioMode.HasFlag(StopAudioMode.OnDeactivate))
		{
			StopAudio();
		}
	}

	public override void OnSelect()
	{
		timeUntilFastBeat = 0.001f;
		isSelected = true;
		PlayAudio();
	}

	public override void OnDeselect()
	{
		timeUntilFastBeat = 0f;
		isSelected = false;
		StopAudio();
	}

	private void PlayAudio()
	{
		if (hasAudioSource)
		{
			if (handleAudioPlayStop)
			{
				audioSource.Play();
			}
			if (updateVolume)
			{
				audioSource.volume = originalVolume;
			}
		}
	}

	private void StopAudio()
	{
		if (hasAudioSource)
		{
			if (handleAudioPlayStop)
			{
				audioSource.Stop();
			}
			if (updateVolume)
			{
				audioSource.volume = 0f;
			}
		}
	}

	private void PlayHeartBeat()
	{
		if (hasHeartBeatPlayer)
		{
			heartBeatPlayer.Play();
		}
	}
}
