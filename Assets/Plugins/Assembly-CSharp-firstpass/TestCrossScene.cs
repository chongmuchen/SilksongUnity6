using UnityEngine;

public class TestCrossScene : MonoBehaviour
{
	public GuidReference crossSceneReference = new GuidReference();

	private Renderer cachedRenderer;

	private void Awake()
	{
		crossSceneReference.OnGuidRemoved += ClearCache;
	}

	private void Update()
	{
		if (crossSceneReference.gameObject != null)
		{
			base.transform.Rotate(new Vector3(0f, 1f, 0f), 10f * Time.deltaTime);
			if (cachedRenderer == null)
			{
				cachedRenderer = crossSceneReference.gameObject.GetComponent<Renderer>();
			}
			if (cachedRenderer != null)
			{
				cachedRenderer.gameObject.transform.Rotate(new Vector3(0f, 1f, 0f), 10f * Time.deltaTime, Space.World);
			}
		}
	}

	private void ClearCache()
	{
		cachedRenderer = null;
	}

	private void TestPerformance()
	{
		for (int i = 0; i < 10000; i++)
		{
			_ = crossSceneReference.gameObject;
		}
	}
}
