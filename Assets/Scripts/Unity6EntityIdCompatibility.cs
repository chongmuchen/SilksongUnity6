using UnityEngine;

/// <summary>
/// Compatibility bridge for code compiled before Unity 6.5 widened object
/// identifiers from 32-bit Instance IDs to 64-bit Entity IDs.
///
/// This preserves the legacy integer-shaped API used by the recovered code.
/// New code should store and compare EntityId values directly.
/// </summary>
internal static class Unity6EntityIdCompatibility
{
	public static int GetLegacyInstanceId(this Object value)
	{
		return unchecked((int)EntityId.ToULong(value.GetEntityId()));
	}
}
