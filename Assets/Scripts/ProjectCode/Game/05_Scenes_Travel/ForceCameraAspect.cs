using System;
using System.Collections;
using TeamCherry.SharedUtils;
using UnityEngine;

public class ForceCameraAspect : MonoBehaviour
{
	[SerializeField]
	private Transform anchorTopLeft;

	[SerializeField]
	private Camera clearCamera;

	private tk2dCamera tk2dCam;

	private Camera hudCam;

	private float initialFov;

	private float initialHudCamSize;

	private int lastX;

	private int lastY;

	private float scaleAdjust;

	private float fovOffset;

	private float extraFovOffset;

	private Coroutine fovTransitionRoutine;

	public static float CurrentViewportAspect { get; private set; }

	public static float CurrentMainCamHeightMult { get; private set; }

	public static float CurrentMainCamFov { get; private set; }

	public static event Action<float> ViewportAspectChanged;

	public static event Action<float> MainCamHeightMultChanged;

	public static event Action<float> MainCamFovChanged;

	private void Awake()
	{
		tk2dCam = GetComponent<tk2dCamera>();
		CurrentViewportAspect = 1.7777778f;
		clearCamera.enabled = false;
	}

	private void Start()
	{
		hudCam = GameCameras.instance.hudCamera;
		initialFov = tk2dCam.CameraSettings.fieldOfView;
		initialHudCamSize = hudCam.orthographicSize;
		AutoScaleViewport();
	}

	private void Update()
	{
		if (lastX != Screen.width || lastY != Screen.height)
		{
			float num = AutoScaleViewport();
			lastX = Screen.width;
			lastY = Screen.height;
			ForceCameraAspect.ViewportAspectChanged?.Invoke(num);
			CurrentViewportAspect = num;
		}
	}

	public void SetOverscanViewport(float adjustment)
	{
		scaleAdjust = adjustment;
		AutoScaleViewport();
	}

	private float AutoScaleViewport()
	{
		Rect newViewPortRect;
		float heightMult;
		float result = AutoScaleViewportShared(scaleAdjust, in tk2dCam.CameraSettings.rect, out newViewPortRect, out heightMult);
		tk2dCam.CameraSettings.rect = newViewPortRect;
		hudCam.rect = newViewPortRect;
		ForceCameraAspect.MainCamHeightMultChanged?.Invoke(heightMult);
		CurrentMainCamHeightMult = heightMult;
		float num = (initialFov + fovOffset + extraFovOffset) * heightMult;
		tk2dCam.CameraSettings.fieldOfView = num;
		ForceCameraAspect.MainCamFovChanged?.Invoke(num);
		CurrentMainCamFov = num;
		hudCam.orthographicSize = initialHudCamSize * heightMult;
		if ((bool)anchorTopLeft)
		{
			anchorTopLeft.localPosition = new Vector3(0f, hudCam.orthographicSize - initialHudCamSize, 0f);
		}
		clearCamera.enabled = newViewPortRect.x > Mathf.Epsilon || newViewPortRect.y > Mathf.Epsilon;
		return result;
	}

	public static float AutoScaleViewportShared(float scaleAdjust, in Rect currentViewportRect, out Rect newViewPortRect, out float heightMult)
	{
		float num = (float)Screen.width / (float)Screen.height;
		float clampedBetween = new MinMaxFloat(1.6f, 2.3916667f).GetClampedBetween(num);
		float num2 = num / clampedBetween;
		float num3 = 1f + scaleAdjust;
		newViewPortRect = currentViewportRect;
		if (num2 < 1f)
		{
			newViewPortRect.width = 1f * num3;
			newViewPortRect.height = num2 * num3;
			float x = (1f - newViewPortRect.width) / 2f;
			newViewPortRect.x = x;
			float y = (1f - newViewPortRect.height) / 2f;
			newViewPortRect.y = y;
		}
		else
		{
			float num4 = 1f / num2;
			newViewPortRect.width = num4 * num3;
			newViewPortRect.height = 1f * num3;
			float x2 = (1f - newViewPortRect.width) / 2f;
			newViewPortRect.x = x2;
			float y2 = (1f - newViewPortRect.height) / 2f;
			newViewPortRect.y = y2;
		}
		if (clampedBetween < 1.7777778f)
		{
			heightMult = 1.7777778f / clampedBetween;
		}
		else
		{
			heightMult = 1f;
		}
		return clampedBetween;
	}

	public void SetFovOffset(float offset, float transitionTime, AnimationCurve curve)
	{
		if (fovTransitionRoutine != null)
		{
			StopCoroutine(fovTransitionRoutine);
			fovTransitionRoutine = null;
		}
		if (!Mathf.Approximately(offset, fovOffset))
		{
			if (transitionTime <= Mathf.Epsilon)
			{
				fovOffset = offset;
				AutoScaleViewport();
			}
			else
			{
				fovTransitionRoutine = StartCoroutine(TransitionFovOffset(offset, transitionTime, curve));
			}
		}
	}

	private IEnumerator TransitionFovOffset(float newOffset, float transitionTime, AnimationCurve curve)
	{
		float initialOffset = fovOffset;
		for (float elapsed = 0f; elapsed < transitionTime; elapsed += Time.deltaTime)
		{
			float t = curve.Evaluate(elapsed / transitionTime);
			fovOffset = Mathf.Lerp(initialOffset, newOffset, t);
			AutoScaleViewport();
			yield return null;
		}
		fovOffset = newOffset;
		AutoScaleViewport();
		fovTransitionRoutine = null;
	}

	public void SetExtraFovOffset(float value)
	{
		extraFovOffset = value;
		AutoScaleViewport();
	}
}
