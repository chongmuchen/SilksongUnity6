using UnityEngine;

public sealed class InventoryAudioFadeOut : MonoBehaviour
{
	[SerializeField]
	private AudioSource audioSource;

	[SerializeField]
	private bool recordVolumeOnFade;

	[SerializeField]
	private float fadeDuration = 0.075f;

	[SerializeField]
	private bool stopOnDisable = true;

	private float fadeVelocity;

	private float recordedVolume;

	private bool isFading;

	private InventoryPaneList paneList;

	private void Awake()
	{
		if (audioSource == null)
		{
			audioSource = GetComponent<AudioSource>();
			if (audioSource == null)
			{
				base.enabled = false;
				return;
			}
		}
		recordedVolume = audioSource.volume;
		paneList = GetComponentInParent<InventoryPaneList>();
		if (paneList != null)
		{
			paneList.ClosingInventory += FadeOut;
		}
	}

	private void OnEnable()
	{
		audioSource.volume = recordedVolume;
		isFading = false;
	}

	private void OnDisable()
	{
		if (stopOnDisable && audioSource != null)
		{
			audioSource.Stop();
		}
	}

	private void OnDestroy()
	{
		if (paneList != null)
		{
			paneList.ClosingInventory -= FadeOut;
		}
	}

	private void OnValidate()
	{
		if (audioSource == null)
		{
			audioSource = GetComponent<AudioSource>();
		}
	}

	private void Update()
	{
		if (isFading)
		{
			float volume = audioSource.volume;
			audioSource.volume = Mathf.SmoothDamp(volume, 0f, ref fadeVelocity, fadeDuration, float.PositiveInfinity, Time.unscaledDeltaTime);
		}
	}

	public void FadeOut()
	{
		if (!isFading)
		{
			if (recordVolumeOnFade)
			{
				recordedVolume = audioSource.volume;
			}
			fadeVelocity = 0f;
			isFading = true;
		}
	}
}
