using UnityEngine;

public interface IPostprocessModule
{
	string EffectKeyword { get; }

	void UpdateProperties(Material material);
}
