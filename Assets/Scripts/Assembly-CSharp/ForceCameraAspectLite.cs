using UnityEngine;

public class ForceCameraAspectLite : MonoBehaviour
{
	public Camera sceneCamera;

	private bool viewportChanged;

	private int lastX;

	private int lastY;

	private float scaleAdjust;

	private void Start()
	{
		AutoScaleViewport();
	}

	private void Update()
	{
		viewportChanged = false;
		if (lastX != Screen.width)
		{
			viewportChanged = true;
		}
		if (lastY != Screen.height)
		{
			viewportChanged = true;
		}
		if (viewportChanged)
		{
			AutoScaleViewport();
		}
		lastX = Screen.width;
		lastY = Screen.height;
	}

	private void AutoScaleViewport()
	{
		ForceCameraAspect.AutoScaleViewportShared(scaleAdjust, sceneCamera.rect, out var newViewPortRect, out var _);
		sceneCamera.rect = newViewPortRect;
	}
}
