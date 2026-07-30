using UnityEngine;

public class DebandEffect : MonoBehaviour
{
	[SerializeField]
	private Material material;

	private void OnRenderImage(RenderTexture source, RenderTexture destination)
	{
		Graphics.Blit(source, destination, material, 0);
	}
}
