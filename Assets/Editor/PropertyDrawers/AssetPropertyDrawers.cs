using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

[CustomPropertyDrawer(typeof(AssetPickerDropdownAttribute))]
public sealed class AssetPickerDropdownDrawer : PropertyDrawer
{
	public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
	{
		return CollectionDrawerGUI.IsCollection(property)
			? CollectionDrawerGUI.GetHeight(
				property,
				fixedSize: -1,
				index => $"Element {index}",
				(element, elementLabel) => EditorGUIUtility.singleLineHeight)
			: EditorGUIUtility.singleLineHeight;
	}

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		Type objectType = PropertyDrawerReflection.GetFieldElementType(fieldInfo);
		EditorGUI.BeginProperty(position, label, property);
		if (CollectionDrawerGUI.IsCollection(property))
		{
			CollectionDrawerGUI.OnGUI(
				position,
				property,
				label,
				fixedSize: -1,
				index => $"Element {index}",
				(element, elementLabel) => EditorGUIUtility.singleLineHeight,
				(elementPosition, element, elementLabel) =>
					AssetPickerDropdownGUI.Draw(elementPosition, element, elementLabel, objectType));
		}
		else
		{
			AssetPickerDropdownGUI.Draw(position, property, label, objectType);
		}
		EditorGUI.EndProperty();
	}
}

internal static class AssetPickerDropdownGUI
{
	private sealed class AssetOptions
	{
		public Object[] Assets;

		public string[] Names;
	}

	private static readonly Dictionary<Type, AssetOptions> optionsByType = new Dictionary<Type, AssetOptions>();

	static AssetPickerDropdownGUI()
	{
		EditorApplication.projectChanged += optionsByType.Clear;
	}

	public static void Draw(Rect position, SerializedProperty property, GUIContent label, Type objectType)
	{
		if (property.propertyType != SerializedPropertyType.ObjectReference ||
			objectType == null ||
			!typeof(Object).IsAssignableFrom(objectType))
		{
			EditorGUI.PropertyField(position, property, label, includeChildren: true);
			return;
		}

		AssetOptions options = GetOptions(objectType);
		List<Object> values = new List<Object>(options.Assets.Length + 2) { null };
		List<string> names = new List<string>(options.Names.Length + 2) { "<None>" };
		Object current = property.objectReferenceValue;
		if (current != null && Array.IndexOf(options.Assets, current) < 0)
		{
			values.Add(current);
			names.Add($"[Unlisted] {current.name}");
		}
		values.AddRange(options.Assets);
		names.AddRange(options.Names);

		int selected = Math.Max(0, values.IndexOf(current));
		EditorGUI.BeginChangeCheck();
		selected = EditorGUI.Popup(position, label.text, selected, names.ToArray(), EditorStyles.popup);
		if (EditorGUI.EndChangeCheck())
		{
			property.objectReferenceValue = values[selected];
		}
	}

	private static AssetOptions GetOptions(Type objectType)
	{
		if (optionsByType.TryGetValue(objectType, out AssetOptions options))
		{
			return options;
		}

		var entries = AssetDatabase.FindAssets("t:" + objectType.Name)
			.Select(AssetDatabase.GUIDToAssetPath)
			.Distinct()
			.Select(path => new
			{
				Path = path,
				Asset = AssetDatabase.LoadAssetAtPath(path, objectType)
			})
			.Where(entry => entry.Asset != null && objectType.IsInstanceOfType(entry.Asset))
			.OrderBy(entry => entry.Asset.name, StringComparer.OrdinalIgnoreCase)
			.ThenBy(entry => entry.Path, StringComparer.OrdinalIgnoreCase)
			.ToArray();

		Dictionary<string, int> duplicateCounts = entries
			.GroupBy(entry => entry.Asset.name)
			.ToDictionary(group => group.Key, group => group.Count());
		options = new AssetOptions
		{
			Assets = entries.Select(entry => entry.Asset).ToArray(),
			Names = entries
				.Select(entry => duplicateCounts[entry.Asset.name] > 1
					? $"{entry.Asset.name} — {entry.Path}"
					: entry.Asset.name)
				.ToArray()
		};
		optionsByType[objectType] = options;
		return options;
	}
}

[CustomPropertyDrawer(typeof(EnsurePrefabAttribute))]
public sealed class EnsurePrefabDrawer : PropertyDrawer
{
	public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
	{
		float height = EditorGUIUtility.singleLineHeight;
		if (HasInvalidReference(property))
		{
			height += EditorGUIUtility.standardVerticalSpacing + EditorGUIUtility.singleLineHeight * 2f;
		}
		return height;
	}

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		if (property.propertyType != SerializedPropertyType.ObjectReference)
		{
			EditorGUI.PropertyField(position, property, label, includeChildren: true);
			return;
		}

		bool invalid = HasInvalidReference(property);
		Color oldColor = GUI.color;
		if (invalid)
		{
			GUI.color = Color.Lerp(oldColor, new Color(1f, 0.45f, 0.45f, oldColor.a), 0.55f);
		}

		Rect fieldRect = new Rect(position.x, position.y, position.width, EditorGUIUtility.singleLineHeight);
		Type objectType = PropertyDrawerReflection.GetFieldElementType(fieldInfo);
		property.objectReferenceValue = EditorGUI.ObjectField(
			fieldRect,
			label,
			property.objectReferenceValue,
			objectType,
			allowSceneObjects: false);
		GUI.color = oldColor;

		if (invalid)
		{
			Rect helpRect = new Rect(
				position.x,
				fieldRect.yMax + EditorGUIUtility.standardVerticalSpacing,
				position.width,
				EditorGUIUtility.singleLineHeight * 2f);
			EditorGUI.HelpBox(helpRect, "This reference must come from a prefab asset, not a scene object.", MessageType.Error);
		}
	}

	private static bool HasInvalidReference(SerializedProperty property)
	{
		Object value = property.objectReferenceValue;
		return value != null &&
			(!EditorUtility.IsPersistent(value) || !PrefabUtility.IsPartOfPrefabAsset(value));
	}
}

[CustomPropertyDrawer(typeof(QuickCreateAssetAttribute))]
public sealed class QuickCreateAssetDrawer : PropertyDrawer
{
	private const float ButtonWidth = 58f;

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		if (property.propertyType != SerializedPropertyType.ObjectReference)
		{
			EditorGUI.PropertyField(position, property, label, includeChildren: true);
			return;
		}

		QuickCreateAssetAttribute quickCreate = (QuickCreateAssetAttribute)attribute;
		Type assetType = PropertyDrawerReflection.GetFieldElementType(fieldInfo);
		bool canCreate = property.objectReferenceValue == null &&
			assetType != null &&
			typeof(ScriptableObject).IsAssignableFrom(assetType) &&
			!assetType.IsAbstract;

		Rect fieldRect = position;
		if (canCreate)
		{
			fieldRect.width -= ButtonWidth + 4f;
		}
		property.objectReferenceValue = EditorGUI.ObjectField(
			fieldRect,
			label,
			property.objectReferenceValue,
			assetType,
			allowSceneObjects: false);

		if (!canCreate)
		{
			return;
		}

		Rect buttonRect = new Rect(fieldRect.xMax + 4f, position.y, ButtonWidth, position.height);
		if (GUI.Button(buttonRect, "Create"))
		{
			CreateAsset(property, assetType, quickCreate);
		}
	}

	private static void CreateAsset(
		SerializedProperty property,
		Type assetType,
		QuickCreateAssetAttribute quickCreate)
	{
		string folder = EnsureFolder(quickCreate.FolderPath);
		string path = EditorUtility.SaveFilePanelInProject(
			$"Create {assetType.Name}",
			assetType.Name + ".asset",
			"asset",
			$"Choose where to create the new {assetType.Name}.",
			folder);
		if (string.IsNullOrEmpty(path))
		{
			return;
		}

		ScriptableObject asset = ScriptableObject.CreateInstance(assetType);
		object parent = PropertyDrawerReflection.GetParentObject(property);
		if (PropertyDrawerReflection.TryGetMemberValue(parent, quickCreate.SourceField, out object sourceValue))
		{
			PropertyDrawerReflection.TrySetMemberValue(asset, quickCreate.TargetField, sourceValue);
		}

		path = AssetDatabase.GenerateUniqueAssetPath(path);
		AssetDatabase.CreateAsset(asset, path);
		Undo.RegisterCreatedObjectUndo(asset, $"Create {assetType.Name}");
		EditorUtility.SetDirty(asset);
		AssetDatabase.SaveAssets();

		property.objectReferenceValue = asset;
		property.serializedObject.ApplyModifiedProperties();
		Selection.activeObject = asset;
		EditorGUIUtility.PingObject(asset);
		GUIUtility.ExitGUI();
	}

	private static string EnsureFolder(string requestedFolder)
	{
		string normalized = (requestedFolder ?? string.Empty).Replace('\\', '/').Trim('/');
		string folder = normalized.StartsWith("Assets", StringComparison.Ordinal)
			? normalized
			: string.IsNullOrEmpty(normalized) ? "Assets" : "Assets/" + normalized;
		if (AssetDatabase.IsValidFolder(folder))
		{
			return folder;
		}

		string[] segments = folder.Split('/');
		string current = segments[0];
		for (int i = 1; i < segments.Length; i++)
		{
			string next = current + "/" + segments[i];
			if (!AssetDatabase.IsValidFolder(next))
			{
				AssetDatabase.CreateFolder(current, segments[i]);
			}
			current = next;
		}
		return folder;
	}
}

[CustomPropertyDrawer(typeof(SpritePreviewAttribute))]
public sealed class SpritePreviewDrawer : PropertyDrawer
{
	public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
	{
		SpritePreviewAttribute preview = (SpritePreviewAttribute)attribute;
		return EditorGUIUtility.singleLineHeight +
			EditorGUIUtility.standardVerticalSpacing +
			Mathf.Max(0f, preview.previewHeight);
	}

	public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
	{
		if (property.propertyType != SerializedPropertyType.ObjectReference)
		{
			EditorGUI.PropertyField(position, property, label, includeChildren: true);
			return;
		}

		Rect fieldRect = new Rect(position.x, position.y, position.width, EditorGUIUtility.singleLineHeight);
		property.objectReferenceValue = EditorGUI.ObjectField(
			fieldRect,
			label,
			property.objectReferenceValue,
			typeof(Sprite),
			allowSceneObjects: false);

		SpritePreviewAttribute preview = (SpritePreviewAttribute)attribute;
		Rect previewRect = new Rect(
			EditorGUI.IndentedRect(position).x,
			fieldRect.yMax + EditorGUIUtility.standardVerticalSpacing,
			EditorGUI.IndentedRect(position).width,
			Mathf.Max(0f, preview.previewHeight));
		GUI.Box(previewRect, GUIContent.none);

		Sprite sprite = property.objectReferenceValue as Sprite;
		if (sprite == null)
		{
			return;
		}

		Texture texture = AssetPreview.GetAssetPreview(sprite) ?? AssetPreview.GetMiniThumbnail(sprite);
		if (texture != null)
		{
			GUI.DrawTexture(previewRect, texture, ScaleMode.ScaleToFit, alphaBlend: true);
		}
	}
}
