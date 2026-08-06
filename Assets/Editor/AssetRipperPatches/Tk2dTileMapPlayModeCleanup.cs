using UnityEditor;
using UnityEngine;

[InitializeOnLoad]
internal static class Tk2dTileMapPlayModeCleanup
{
	static Tk2dTileMapPlayModeCleanup()
	{
		EditorApplication.playModeStateChanged += OnPlayModeStateChanged;
	}

	private static void OnPlayModeStateChanged(PlayModeStateChange state)
	{
		if (state != PlayModeStateChange.ExitingPlayMode)
		{
			return;
		}

		tk2dTileMap[] tileMaps = Object.FindObjectsByType<tk2dTileMap>(FindObjectsInactive.Include);
		foreach (tk2dTileMap tileMap in tileMaps)
		{
			ClearPersistentMeshReferences(tileMap);
		}
	}

	private static void ClearPersistentMeshReferences(tk2dTileMap tileMap)
	{
		SerializedObject serializedTileMap = new SerializedObject(tileMap);
		SerializedProperty property = serializedTileMap.GetIterator();
		bool changed = false;

		while (property.Next(enterChildren: true))
		{
			if (property.propertyType != SerializedPropertyType.ObjectReference)
			{
				continue;
			}

			Mesh mesh = property.objectReferenceValue as Mesh;
			if (mesh == null || !EditorUtility.IsPersistent(mesh))
			{
				continue;
			}

			// Older tk2d builds call DestroyImmediate on every referenced mesh from
			// OnDestroy. Unity 6 rejects that call for asset-backed meshes, so leave
			// those assets to Unity and only let tk2d destroy its runtime meshes.
			property.objectReferenceValue = null;
			changed = true;
		}

		if (changed)
		{
			serializedTileMap.ApplyModifiedPropertiesWithoutUndo();
		}
	}
}
